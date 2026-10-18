-- Etapa 1.8: portal de administración v1 (D76). Todo pasa por funciones que
-- verifican el rol `admin` EN EL SERVIDOR (nunca solo en la interfaz) y cada
-- acción queda en `admin_actions`. Las tablas de datos no se abren a nadie.

-- ---------------------------------------------------------------------
-- Permiso
-- ---------------------------------------------------------------------
create function public.es_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

create function public.exigir_admin()
returns uuid
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.es_admin() then
    raise exception 'Solo para administración' using errcode = '42501';
  end if;
  return (select auth.uid());
end;
$$;

revoke all on function public.es_admin() from public, anon;
revoke all on function public.exigir_admin() from public, anon, authenticated;
grant execute on function public.es_admin() to authenticated;

-- ---------------------------------------------------------------------
-- Registro de acciones (auditoría) y sanciones
-- ---------------------------------------------------------------------
create table public.admin_actions (
  id           bigint generated always as identity primary key,
  admin_id     uuid references auth.users (id) on delete set null,
  action       text not null check (char_length(action) between 2 and 40),
  target_type  text,
  target_id    text check (char_length(target_id) <= 64),
  detail       jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now()
);

create table public.user_sanctions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  kind        text not null check (kind in ('warning', 'block')),
  reason      text check (char_length(reason) <= 300),
  until       timestamptz,                      -- bloqueo hasta (null = sin fin)
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  lifted_at   timestamptz
);

create index user_sanctions_user_idx on public.user_sanctions (user_id, created_at desc);

alter table public.admin_actions enable row level security;
alter table public.user_sanctions enable row level security;
-- Sin políticas: solo las funciones de abajo (y el panel de Supabase).
revoke all on public.admin_actions, public.user_sanctions from anon, authenticated;

create function public.registrar_accion(p_action text, p_target_type text, p_target_id text, p_detail jsonb default '{}')
returns void
language sql security definer set search_path = ''
as $$
  insert into public.admin_actions (admin_id, action, target_type, target_id, detail)
  values ((select auth.uid()), p_action, p_target_type, p_target_id, coalesce(p_detail, '{}'));
$$;

revoke all on function public.registrar_accion(text, text, text, jsonb) from public, anon, authenticated;

-- ¿Está bloqueada esta cuenta? (no publica SOS, no escribe en el chat, no
-- abre chats ni deja avisos con sesión).
create function public.esta_bloqueado(p_user uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.user_sanctions
    where user_id = p_user and kind = 'block' and lifted_at is null
      and (until is null or until > now())
  );
$$;

revoke all on function public.esta_bloqueado(uuid) from public, anon;
grant execute on function public.esta_bloqueado(uuid) to authenticated;

create function public.frenar_bloqueados()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  quien uuid;
begin
  quien := case tg_table_name
    when 'sos_reports' then new.user_id
    when 'messages' then new.sender_id
    when 'conversations' then new.created_by
    when 'owner_alerts' then new.from_user_id
  end;
  if quien is not null and public.esta_bloqueado(quien) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger sos_reports_bloqueados before insert on public.sos_reports
  for each row execute function public.frenar_bloqueados();
create trigger messages_bloqueados before insert on public.messages
  for each row execute function public.frenar_bloqueados();
create trigger conversations_bloqueados before insert on public.conversations
  for each row execute function public.frenar_bloqueados();
create trigger owner_alerts_bloqueados before insert on public.owner_alerts
  for each row execute function public.frenar_bloqueados();

-- ---------------------------------------------------------------------
-- 1.8.2 Panel general
-- ---------------------------------------------------------------------
create function public.admin_panel(p_zona smallint default null, p_dias integer default 30)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
  r jsonb;
begin
  perform public.exigir_admin();
  select jsonb_build_object(
    'usuarios', (select count(*) from public.profiles p
                 where p_zona is null or p.zone_id = p_zona),
    'usuarios_nuevos', (select count(*) from public.profiles p
                        where p.created_at >= desde and (p_zona is null or p.zone_id = p_zona)),
    'activos_dia', (select count(distinct user_id) from public.events
                    where user_id is not null and created_at >= now() - interval '1 day'
                      and (p_zona is null or zone_id = p_zona)),
    'activos_semana', (select count(distinct user_id) from public.events
                       where user_id is not null and created_at >= now() - interval '7 days'
                         and (p_zona is null or zone_id = p_zona)),
    'activos_mes', (select count(distinct user_id) from public.events
                    where user_id is not null and created_at >= now() - interval '30 days'
                      and (p_zona is null or zone_id = p_zona)),
    'mascotas', (select count(*) from public.pets),
    'hogares', (select count(*) from public.households),
    'sos_activos', (select count(*) from public.sos_reports s
                    where s.status = 'active' and (p_zona is null or s.zone_id = p_zona)),
    'sos_resueltos', (select count(*) from public.sos_reports s
                      where s.status = 'resolved' and s.resolved_at >= desde
                        and (p_zona is null or s.zone_id = p_zona)),
    'sos_publicados', (select count(*) from public.sos_reports s
                       where s.created_at >= desde and (p_zona is null or s.zone_id = p_zona)),
    'sos_dias_hasta_resolver', (select round(avg(extract(epoch from (s.resolved_at - s.created_at)) / 86400)::numeric, 1)
                                from public.sos_reports s
                                where s.status = 'resolved' and s.resolved_at >= desde
                                  and (p_zona is null or s.zone_id = p_zona)),
    'escaneos_qr', (select count(*) from public.qr_scans q where q.created_at >= desde),
    'avisos', (select count(*) from public.owner_alerts a where a.created_at >= desde),
    'pendientes_moderacion', (select count(*) from public.sos_reports where status = 'hidden')
                             + (select count(distinct target_id) from public.flags f
                                where f.target_type = 'message'
                                  and not exists (select 1 from public.admin_actions x
                                                  where x.target_type = 'message'
                                                    and x.target_id = f.target_id::text)),
    'comercios_por_rubro', (select coalesce(jsonb_object_agg(business_type, n), '{}')
                            from (select business_type, count(*) n from public.businesses
                                  where status = 'active' and not is_sample
                                    and (p_zona is null or zone_id = p_zona)
                                  group by business_type) t),
    'comercios_por_estado', (select coalesce(jsonb_object_agg(verification, n), '{}')
                             from (select verification, count(*) n from public.businesses
                                   where status = 'active' and not is_sample
                                     and (p_zona is null or zone_id = p_zona)
                                   group by verification) t),
    'desde', desde
  ) into r;
  return r;
end;
$$;

-- ---------------------------------------------------------------------
-- 1.8.3 Moderación
-- ---------------------------------------------------------------------
-- Cola: SOS ocultos por reportes (o con reportes) y mensajes reportados que
-- todavía no se resolvieron.
create function public.admin_moderacion()
returns table (
  target_type text, target_id uuid, autor_id uuid, autor_nombre text,
  texto text, estado text, reportes integer, motivos text[], ultimo_reporte timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select 'sos'::text, s.id, s.user_id, p.display_name,
         concat_ws(' · ', s.kind::text, s.name, s.description),
         s.status::text,
         (select count(*)::int from public.flags f where f.target_type = 'sos' and f.target_id = s.id),
         array(select f.reason from public.flags f where f.target_type = 'sos' and f.target_id = s.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'sos' and f.target_id = s.id)
  from public.sos_reports s
  left join public.profiles p on p.id = s.user_id
  where s.status = 'hidden'
     or (s.status = 'active' and exists (select 1 from public.flags f
                                         where f.target_type = 'sos' and f.target_id = s.id))
  union all
  select 'message'::text, m.id, m.sender_id, p.display_name,
         coalesce(m.body, case when m.attachment_path is not null then '📷' else '📍' end),
         'reported'::text,
         (select count(*)::int from public.flags f where f.target_type = 'message' and f.target_id = m.id),
         array(select f.reason from public.flags f where f.target_type = 'message' and f.target_id = m.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'message' and f.target_id = m.id)
  from public.messages m
  left join public.profiles p on p.id = m.sender_id
  where exists (select 1 from public.flags f where f.target_type = 'message' and f.target_id = m.id)
    and not exists (select 1 from public.admin_actions x
                    where x.target_type = 'message' and x.target_id = m.id::text)
  order by 9 desc nulls last;
end;
$$;

-- Acciones: aprobar (vuelve a mostrarse y se limpian los reportes), eliminar
-- (el SOS se archiva oculto; el mensaje se borra).
create function public.admin_moderar(p_tipo text, p_id uuid, p_accion text, p_motivo text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_tipo = 'sos' and p_accion = 'aprobar' then
    update public.sos_reports set status = 'active' where id = p_id and status = 'hidden';
    delete from public.flags where target_type = 'sos' and target_id = p_id;
  elsif p_tipo = 'sos' and p_accion = 'eliminar' then
    update public.sos_reports set status = 'archived' where id = p_id;
  elsif p_tipo = 'message' and p_accion = 'aprobar' then
    null;  -- queda resuelto por el registro de la acción
  elsif p_tipo = 'message' and p_accion = 'eliminar' then
    delete from public.messages where id = p_id;
  else
    raise exception 'Acción inválida' using errcode = '22023';
  end if;
  perform public.registrar_accion('moderar_' || p_accion, p_tipo, p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- Advertir o bloquear a una cuenta ([p_dias] null = sin fin); levantar.
create function public.admin_sancionar(p_user uuid, p_tipo text, p_motivo text default null, p_dias integer default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  id_ uuid;
begin
  if p_tipo not in ('warning', 'block') then
    raise exception 'Sanción inválida' using errcode = '22023';
  end if;
  if p_user = yo then
    raise exception 'No te podés sancionar' using errcode = '22023';
  end if;
  insert into public.user_sanctions (user_id, kind, reason, until, created_by)
  values (p_user, p_tipo, p_motivo,
          case when p_dias is not null then now() + make_interval(days => p_dias) end, yo)
  returning id into id_;
  perform public.registrar_accion('sancionar_' || p_tipo, 'user', p_user::text,
                                  jsonb_build_object('motivo', p_motivo, 'dias', p_dias));
  return id_;
end;
$$;

create function public.admin_levantar_sancion(p_sancion uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  update public.user_sanctions set lifted_at = now() where id = p_sancion and lifted_at is null;
  perform public.registrar_accion('levantar_sancion', 'sanction', p_sancion::text);
end;
$$;

-- Historial de una cuenta: reportes recibidos y sanciones.
create function public.admin_historial_usuario(p_user uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return jsonb_build_object(
    'nombre', (select display_name from public.profiles where id = p_user),
    'sos_reportados', (select count(distinct f.target_id) from public.flags f
                       join public.sos_reports s on s.id = f.target_id
                       where f.target_type = 'sos' and s.user_id = p_user),
    'mensajes_reportados', (select count(distinct f.target_id) from public.flags f
                            join public.messages m on m.id = f.target_id
                            where f.target_type = 'message' and m.sender_id = p_user),
    'sanciones', (select coalesce(jsonb_agg(jsonb_build_object(
                    'id', s.id, 'tipo', s.kind, 'motivo', s.reason, 'hasta', s.until,
                    'creada', s.created_at, 'levantada', s.lifted_at) order by s.created_at desc), '[]')
                  from public.user_sanctions s where s.user_id = p_user),
    'bloqueado', public.esta_bloqueado(p_user)
  );
end;
$$;

-- ---------------------------------------------------------------------
-- 1.8.4 / 1.8.5 Lugares: listar, cargar, editar, verificar, RENAC, ocultar
-- ---------------------------------------------------------------------
create function public.admin_lugares(p_buscar text default null, p_incluir_ocultos boolean default true)
returns table (
  id uuid, business_type text, kind text, name text, address text,
  lat double precision, lng double precision, phone text, whatsapp text,
  web text, instagram text, hours jsonb, special_days jsonb, is_24h boolean,
  emergencies boolean, species_ids smallint[], verification text,
  renac_operator boolean, status text, is_sample boolean, description text,
  aperturas_30d bigint, favoritos bigint
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select b.id, b.business_type, b.kind, b.name, b.address,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.hours, b.special_days, b.is_24h,
         b.emergencies, b.species_ids, b.verification, b.renac_operator, b.status,
         b.is_sample, b.description,
         (select count(*) from public.events e
          where e.business_id = b.id and e.name = 'place_open'
            and e.created_at > now() - interval '30 days'),
         (select count(*) from public.user_places u where u.business_id = b.id and u.favorite)
  from public.businesses b
  where (p_incluir_ocultos or b.status = 'active')
    and (p_buscar is null or b.name ilike '%' || p_buscar || '%')
  order by b.status, b.name
  limit 500;
end;
$$;

-- Crea (sin id) o actualiza un lugar. [p] usa los nombres de columna; lat y
-- lng van sueltos. Las validaciones son las de la tabla.
create function public.admin_guardar_lugar(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  punto extensions.geography;
begin
  perform public.exigir_admin();
  if (p ? 'lat') and (p ? 'lng') and p ->> 'lat' is not null and p ->> 'lng' is not null then
    punto := extensions.st_setsrid(
      extensions.st_makepoint((p ->> 'lng')::double precision, (p ->> 'lat')::double precision), 4326
    )::extensions.geography;
  end if;
  if id_ is null then
    insert into public.businesses (
      business_type, kind, name, description, address, location, zone_id,
      phone, whatsapp, web, instagram, hours, special_days, is_24h, emergencies,
      species_ids, verification, renac_operator, status
    ) values (
      coalesce(p ->> 'business_type', 'vet'), coalesce(p ->> 'kind', 'local'),
      p ->> 'name', p ->> 'description', p ->> 'address', punto,
      (select id from public.zones where slug = 'pando'),
      nullif(p ->> 'phone', ''), nullif(p ->> 'whatsapp', ''), nullif(p ->> 'web', ''),
      nullif(p ->> 'instagram', ''), coalesce(p -> 'hours', '{}'), coalesce(p -> 'special_days', '{}'),
      coalesce((p ->> 'is_24h')::boolean, false), coalesce((p ->> 'emergencies')::boolean, false),
      coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
      coalesce(p ->> 'verification', 'unverified'), coalesce((p ->> 'renac_operator')::boolean, false),
      coalesce(p ->> 'status', 'active')
    ) returning id into id_;
    perform public.registrar_accion('crear_lugar', 'business', id_::text, jsonb_build_object('nombre', p ->> 'name'));
  else
    update public.businesses b set
      business_type = coalesce(p ->> 'business_type', b.business_type),
      kind = coalesce(p ->> 'kind', b.kind),
      name = coalesce(p ->> 'name', b.name),
      description = case when p ? 'description' then p ->> 'description' else b.description end,
      address = case when p ? 'address' then p ->> 'address' else b.address end,
      location = case when (p ? 'lat') then punto else b.location end,
      phone = case when p ? 'phone' then nullif(p ->> 'phone', '') else b.phone end,
      whatsapp = case when p ? 'whatsapp' then nullif(p ->> 'whatsapp', '') else b.whatsapp end,
      web = case when p ? 'web' then nullif(p ->> 'web', '') else b.web end,
      instagram = case when p ? 'instagram' then nullif(p ->> 'instagram', '') else b.instagram end,
      hours = coalesce(p -> 'hours', b.hours),
      special_days = coalesce(p -> 'special_days', b.special_days),
      is_24h = coalesce((p ->> 'is_24h')::boolean, b.is_24h),
      emergencies = coalesce((p ->> 'emergencies')::boolean, b.emergencies),
      species_ids = case when p ? 'species_ids'
                         then coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}')
                         else b.species_ids end,
      verification = coalesce(p ->> 'verification', b.verification),
      renac_operator = coalesce((p ->> 'renac_operator')::boolean, b.renac_operator),
      status = coalesce(p ->> 'status', b.status)
    where b.id = id_;
    if not found then
      raise exception 'No existe' using errcode = 'P0002';
    end if;
    perform public.registrar_accion('editar_lugar', 'business', id_::text, p - 'id');
  end if;
  return id_;
end;
$$;

-- ---------------------------------------------------------------------
-- 1.8.6 Mini CRM
-- ---------------------------------------------------------------------
create table public.prospects (
  id            uuid primary key default gen_random_uuid(),
  name          text not null check (char_length(trim(name)) between 2 and 80),
  business_type text check (business_type in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                                               'hotel', 'trainer', 'pet_friendly', 'shelter')),
  business_id   uuid references public.businesses (id) on delete set null,
  contact       text check (char_length(contact) <= 120),
  stage         text not null default 'prospect'
                check (stage in ('prospect', 'contacted', 'demo', 'founder', 'paying', 'renewed', 'lost')),
  owner_id      uuid references auth.users (id) on delete set null,      -- responsable
  next_contact  date,
  notes         text check (char_length(notes) <= 4000),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create trigger prospects_updated_at
  before update on public.prospects
  for each row execute function public.set_updated_at();

alter table public.prospects enable row level security;
-- Solo administración (con el rol verificado en la base).
create policy "admin_prospectos" on public.prospects for all to authenticated
  using (public.es_admin()) with check (public.es_admin());
revoke all on public.prospects from anon;

-- ---------------------------------------------------------------------
-- 1.8.8 Directorio de Ayuda: administración (además del script)
-- ---------------------------------------------------------------------
create policy "admin_ve_toda_la_ayuda" on public.help_directory for select to authenticated
  using (public.es_admin());
create policy "admin_carga_ayuda" on public.help_directory for insert to authenticated
  with check (public.es_admin());
create policy "admin_edita_ayuda" on public.help_directory for update to authenticated
  using (public.es_admin()) with check (public.es_admin());
grant insert, update on public.help_directory to authenticated;

revoke all on function public.admin_panel(smallint, integer) from public, anon;
revoke all on function public.admin_moderacion() from public, anon;
revoke all on function public.admin_moderar(text, uuid, text, text) from public, anon;
revoke all on function public.admin_sancionar(uuid, text, text, integer) from public, anon;
revoke all on function public.admin_levantar_sancion(uuid) from public, anon;
revoke all on function public.admin_historial_usuario(uuid) from public, anon;
revoke all on function public.admin_lugares(text, boolean) from public, anon;
revoke all on function public.admin_guardar_lugar(jsonb) from public, anon;
grant execute on function public.admin_panel(smallint, integer) to authenticated;
grant execute on function public.admin_moderacion() to authenticated;
grant execute on function public.admin_moderar(text, uuid, text, text) to authenticated;
grant execute on function public.admin_sancionar(uuid, text, text, integer) to authenticated;
grant execute on function public.admin_levantar_sancion(uuid) to authenticated;
grant execute on function public.admin_historial_usuario(uuid) to authenticated;
grant execute on function public.admin_lugares(text, boolean) to authenticated;
grant execute on function public.admin_guardar_lugar(jsonb) to authenticated;
