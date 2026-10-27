-- Cierre del paso 3.6 (D110): cada integrante del equipo ve solo sus zonas.
--  · `team_zones`: qué zonas tiene cada integrante de moderación o ventas.
--    Sin acceso directo; la administración las asigna desde el portal.
--  · `admin` ve todo, como antes. Un integrante **sin zonas no ve nada**
--    (para que nadie quede con acceso de más por un olvido).
--  · Qué zona tiene cada cosa:
--      SOS → su zona · mensaje y persona → la zona del perfil · reseña,
--      lugar y propuesta → la zona del lugar · denuncia y lugar sin reclamar
--      → el punto cae dentro de una de sus zonas · caso de éxito y prospecto
--      → su zona (columna nueva en `prospects`).
--  · Se reescriben las funciones de cada área (siguen llamando a
--    exigir_equipo(), D109) con el filtro o el control de zona.

create table public.team_zones (
  user_id    uuid not null references auth.users (id) on delete cascade,
  zone_id    smallint not null references public.zones (id) on delete cascade,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, zone_id)
);

alter table public.team_zones enable row level security;
-- Sin políticas: solo se lee y se escribe desde las funciones de abajo.
revoke all on public.team_zones from anon, authenticated;

-- ---------------------------------------------------------------------
-- Ayudas
-- ---------------------------------------------------------------------

-- ¿La cuenta puede ver lo de esa zona? Admin, siempre (aunque no tenga zona).
create function public.ve_zona(p_zona smallint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.es_admin()
      or (p_zona is not null and exists (
            select 1 from public.team_zones t
            where t.user_id = (select auth.uid()) and t.zone_id = p_zona));
$$;

-- ¿El punto cae dentro de alguna zona de la cuenta?
create function public.ve_punto(p extensions.geography)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.es_admin()
      or (p is not null and exists (
            select 1 from public.team_zones t
            join public.zones z on z.id = t.zone_id
            where t.user_id = (select auth.uid()) and extensions.st_covers(z.area, p)));
$$;

create function public.exigir_zona(p_zona smallint)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.ve_zona(p_zona) then
    raise exception 'fuera_de_tu_zona' using errcode = '42501';
  end if;
end;
$$;

create function public.exigir_punto(p extensions.geography)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.ve_punto(p) then
    raise exception 'fuera_de_tu_zona' using errcode = '42501';
  end if;
end;
$$;

-- La zona que contiene el punto (la prendida primero).
create function public.zona_de_punto(p extensions.geography)
returns smallint
language sql
stable
security definer
set search_path = ''
as $$
  select z.id from public.zones z
  where p is not null and extensions.st_covers(z.area, p)
  order by z.active desc, z.id
  limit 1;
$$;

-- Para lo que se carga sin zona: la primera del integrante (admin: ninguna).
create function public.mi_primera_zona()
returns smallint
language sql
stable
security definer
set search_path = ''
as $$
  select case when public.es_admin() then null
              else (select min(t.zone_id) from public.team_zones t
                    where t.user_id = (select auth.uid())) end;
$$;

revoke all on function public.ve_zona(smallint) from public, anon;
-- La política de `prospects` la llama con los permisos de quien consulta;
-- solo dice algo de la propia cuenta (como es_equipo()).
grant execute on function public.ve_zona(smallint) to authenticated;
revoke all on function public.ve_punto(extensions.geography) from public, anon, authenticated;
revoke all on function public.exigir_zona(smallint) from public, anon, authenticated;
revoke all on function public.exigir_punto(extensions.geography) from public, anon, authenticated;
revoke all on function public.zona_de_punto(extensions.geography) from public, anon, authenticated;
revoke all on function public.mi_primera_zona() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Equipo: zonas de cada integrante
-- ---------------------------------------------------------------------

-- Para el portal: las zonas que ve la cuenta (null si no es del equipo).
create function public.mis_zonas_equipo()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if public.mi_rol_equipo() is null then
    return null;
  end if;
  return jsonb_build_object(
    'todas', public.es_admin(),
    'zonas', coalesce((
      select jsonb_agg(z.name order by z.name)
      from public.team_zones t join public.zones z on z.id = t.zone_id
      where t.user_id = (select auth.uid())), '[]'::jsonb));
end;
$$;

create or replace function public.admin_equipo()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'user_id', p.id, 'email', u.email, 'nombre', p.display_name, 'rol', p.role::text,
      'yo', p.id = (select auth.uid()),
      'ultima_accion', (select max(a.created_at) from public.admin_actions a where a.admin_id = p.id),
      'zonas', coalesce((select jsonb_agg(jsonb_build_object('id', z.id, 'name', z.name) order by z.name)
                         from public.team_zones t join public.zones z on z.id = t.zone_id
                         where t.user_id = p.id), '[]'::jsonb)
    ) order by p.role::text, u.email)
    from public.profiles p
    join auth.users u on u.id = p.id
    where p.role::text in ('admin', 'moderator', 'sales')
  ), '[]'::jsonb);
end;
$$;

-- Reemplaza las zonas de un integrante de moderación o ventas.
create function public.admin_zonas_integrante(p_user uuid, p_zonas smallint[])
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  zonas smallint[] := coalesce(p_zonas, '{}');
begin
  if not exists (select 1 from public.profiles
                 where id = p_user and role::text in ('moderator', 'sales')) then
    raise exception 'solo_equipo' using errcode = '22023';
  end if;
  if exists (select 1 from unnest(zonas) z(id)
             where not exists (select 1 from public.zones x where x.id = z.id)) then
    raise exception 'No existe esa zona' using errcode = 'P0002';
  end if;
  delete from public.team_zones where user_id = p_user and zone_id <> all (zonas);
  insert into public.team_zones (user_id, zone_id, created_by)
  select p_user, z, yo from unnest(zonas) z
  on conflict do nothing;
  perform public.registrar_accion('zonas_integrante', 'user', p_user::text,
                                  jsonb_build_object('zonas', to_jsonb(zonas)));
end;
$$;

-- Igual que en D109; al salir del equipo o pasar a admin, se le quitan las zonas.
create or replace function public.admin_poner_rol(p_email text, p_rol text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  quien uuid;
  antes text;
begin
  if p_rol not in ('admin', 'moderator', 'sales', 'user') then
    raise exception 'rol_invalido' using errcode = '22023';
  end if;
  select u.id into quien from auth.users u where lower(u.email) = lower(trim(p_email));
  if quien is null then
    raise exception 'sin_cuenta' using errcode = 'P0002';
  end if;
  if quien = yo then
    raise exception 'no_tu_propio_rol' using errcode = 'P0001';
  end if;
  select role::text into antes from public.profiles where id = quien;
  if antes = 'admin' and p_rol <> 'admin'
     and (select count(*) from public.profiles where role::text = 'admin') <= 1 then
    raise exception 'ultimo_admin' using errcode = 'P0001';
  end if;
  update public.profiles set role = p_rol::public.user_role where id = quien;
  if p_rol in ('admin', 'user') then
    delete from public.team_zones where user_id = quien;
  end if;
  perform public.registrar_accion('poner_rol', 'user', quien::text,
                                  jsonb_build_object('antes', antes, 'ahora', p_rol));
end;
$$;

-- ---------------------------------------------------------------------
-- Moderación
-- ---------------------------------------------------------------------

create or replace function public.admin_moderacion()
returns table (target_type text, target_id uuid, autor_id uuid, autor_nombre text, texto text,
               estado text, reportes integer, motivos text[], ultimo_reporte timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  return query
  select 'sos'::text, s.id, s.user_id, p.display_name,
         concat_ws(' · ', s.kind::text, s.name, s.description),
         s.status::text,
         (select count(*)::int from public.flags f where f.target_type = 'sos' and f.target_id = s.id),
         array(select f.reason from public.flags f where f.target_type = 'sos' and f.target_id = s.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'sos' and f.target_id = s.id)
  from public.sos_reports s
  left join public.profiles p on p.id = s.user_id
  where (s.status = 'hidden'
         or (s.status = 'active' and exists (select 1 from public.flags f
                                             where f.target_type = 'sos' and f.target_id = s.id)))
    and public.ve_zona(s.zone_id)
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
    and public.ve_zona(p.zone_id)
  union all
  select 'review'::text, r.id, r.user_id, p.display_name,
         concat(r.rating, '★ ', r.comment),
         r.status,
         (select count(*)::int from public.flags f where f.target_type = 'review' and f.target_id = r.id),
         array(select f.reason from public.flags f where f.target_type = 'review' and f.target_id = r.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'review' and f.target_id = r.id)
  from public.reviews r
  left join public.profiles p on p.id = r.user_id
  join public.businesses b on b.id = r.business_id
  where (r.status = 'hidden'
         or exists (select 1 from public.flags f where f.target_type = 'review' and f.target_id = r.id
                    and not exists (select 1 from public.admin_actions x
                                    where x.target_type = 'review' and x.target_id = r.id::text
                                      and x.created_at > f.created_at)))
    and public.ve_zona(b.zone_id)
  order by 9 desc nulls last;
end;
$$;

create or replace function public.admin_moderar(p_tipo text, p_id uuid, p_accion text, p_motivo text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  perform public.exigir_zona(case p_tipo
    when 'sos' then (select s.zone_id from public.sos_reports s where s.id = p_id)
    when 'message' then (select pr.zone_id from public.messages m
                         join public.profiles pr on pr.id = m.sender_id where m.id = p_id)
    when 'review' then (select b.zone_id from public.reviews r
                        join public.businesses b on b.id = r.business_id where r.id = p_id)
  end);
  if p_tipo = 'sos' and p_accion = 'aprobar' then
    update public.sos_reports set status = 'active' where id = p_id and status = 'hidden';
    delete from public.flags where target_type = 'sos' and target_id = p_id;
  elsif p_tipo = 'sos' and p_accion = 'eliminar' then
    update public.sos_reports set status = 'archived' where id = p_id;
  elsif p_tipo = 'message' and p_accion = 'aprobar' then
    null;
  elsif p_tipo = 'message' and p_accion = 'eliminar' then
    delete from public.messages where id = p_id;
  elsif p_tipo = 'review' and p_accion = 'aprobar' then
    update public.reviews set status = 'active' where id = p_id;
    delete from public.flags where target_type = 'review' and target_id = p_id;
  elsif p_tipo = 'review' and p_accion = 'eliminar' then
    delete from public.reviews where id = p_id;
  else
    raise exception 'Acción inválida' using errcode = '22023';
  end if;
  perform public.registrar_accion('moderar_' || p_accion, p_tipo, p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

create or replace function public.admin_sancionar(p_user uuid, p_tipo text, p_motivo text default null, p_dias integer default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  yo uuid := public.exigir_equipo(array['moderator']);
  id_ uuid;
begin
  perform public.exigir_zona((select zone_id from public.profiles where id = p_user));
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

create or replace function public.admin_historial_usuario(p_user uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  perform public.exigir_zona((select zone_id from public.profiles where id = p_user));
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

create or replace function public.admin_levantar_sancion(p_sancion uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  perform public.exigir_zona((select pr.zone_id from public.user_sanctions s
                              join public.profiles pr on pr.id = s.user_id where s.id = p_sancion));
  update public.user_sanctions set lifted_at = now() where id = p_sancion and lifted_at is null;
  perform public.registrar_accion('levantar_sancion', 'sanction', p_sancion::text);
end;
$$;

create or replace function public.admin_denuncias()
returns table (id uuid, reporter text, description text, lat double precision, lng double precision,
               address text, photos text[], status text, admin_note text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  return query
  select a.id, p.display_name, a.description,
         extensions.st_y(a.location::extensions.geometry), extensions.st_x(a.location::extensions.geometry),
         a.address, a.photos, a.status, a.admin_note, a.created_at
  from public.abuse_reports a left join public.profiles p on p.id = a.reporter_id
  where public.ve_punto(a.location)
  order by a.status = 'new' desc, a.created_at desc
  limit 200;
end;
$$;

create or replace function public.admin_estado_denuncia(p_id uuid, p_estado text, p_nota text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  perform public.exigir_punto((select a.location from public.abuse_reports a where a.id = p_id));
  if p_estado not in ('new', 'referred', 'closed') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  update public.abuse_reports set status = p_estado, admin_note = coalesce(p_nota, admin_note)
   where id = p_id;
  perform public.registrar_accion('denuncia_' || p_estado, 'abuse_report', p_id::text);
end;
$$;

-- ---------------------------------------------------------------------
-- Ventas
-- ---------------------------------------------------------------------

create or replace function public.admin_lugares(p_buscar text default null, p_incluir_ocultos boolean default true)
returns table (id uuid, business_type text, kind text, name text, address text, lat double precision,
               lng double precision, phone text, whatsapp text, web text, instagram text, hours jsonb,
               special_days jsonb, is_24h boolean, emergencies boolean, species_ids smallint[],
               verification text, renac_operator boolean, status text, is_sample boolean,
               description text, aperturas_30d bigint, favoritos bigint)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['sales']);
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
    and public.ve_zona(b.zone_id)
  order by b.status, b.name
  limit 500;
end;
$$;

-- La zona del lugar sale del punto (antes, siempre Pando; sigue siendo Pando
-- si el punto no cae en ninguna zona).
create or replace function public.admin_guardar_lugar(p jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  punto extensions.geography;
  zona smallint;
begin
  perform public.exigir_equipo(array['sales']);
  if (p ? 'lat') and (p ? 'lng') and p ->> 'lat' is not null and p ->> 'lng' is not null then
    punto := extensions.st_setsrid(
      extensions.st_makepoint((p ->> 'lng')::double precision, (p ->> 'lat')::double precision), 4326
    )::extensions.geography;
  end if;
  zona := public.zona_de_punto(punto);
  if id_ is null then
    zona := coalesce(zona, (select id from public.zones where slug = 'pando'));
    perform public.exigir_zona(zona);
    insert into public.businesses (
      business_type, kind, name, description, address, location, zone_id,
      phone, whatsapp, web, instagram, hours, special_days, is_24h, emergencies,
      species_ids, verification, renac_operator, status
    ) values (
      coalesce(p ->> 'business_type', 'vet'), coalesce(p ->> 'kind', 'local'),
      p ->> 'name', p ->> 'description', p ->> 'address', punto, zona,
      nullif(p ->> 'phone', ''), nullif(p ->> 'whatsapp', ''), nullif(p ->> 'web', ''),
      nullif(p ->> 'instagram', ''), coalesce(p -> 'hours', '{}'), coalesce(p -> 'special_days', '{}'),
      coalesce((p ->> 'is_24h')::boolean, false), coalesce((p ->> 'emergencies')::boolean, false),
      coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
      coalesce(p ->> 'verification', 'unverified'), coalesce((p ->> 'renac_operator')::boolean, false),
      coalesce(p ->> 'status', 'active')
    ) returning id into id_;
    perform public.registrar_accion('crear_lugar', 'business', id_::text, jsonb_build_object('nombre', p ->> 'name'));
  else
    perform public.exigir_zona((select b.zone_id from public.businesses b where b.id = id_));
    if (p ? 'lat') and zona is not null then
      perform public.exigir_zona(zona);
    end if;
    update public.businesses b set
      business_type = coalesce(p ->> 'business_type', b.business_type),
      kind = coalesce(p ->> 'kind', b.kind),
      name = coalesce(p ->> 'name', b.name),
      description = case when p ? 'description' then p ->> 'description' else b.description end,
      address = case when p ? 'address' then p ->> 'address' else b.address end,
      location = case when (p ? 'lat') then punto else b.location end,
      zone_id = case when (p ? 'lat') then coalesce(zona, b.zone_id) else b.zone_id end,
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

create or replace function public.admin_sin_reclamar(p_dias integer default 30)
returns table (grupo text, category text, lat double precision, lng double precision, marcas integer,
               aperturas bigint, primera_marca timestamptz, google_link text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
begin
  perform public.exigir_equipo(array['sales']);
  return query
  with marcas as (
    select m.*, extensions.st_clusterdbscan(m.location::extensions.geometry, eps := 0.0003, minpoints := 1)
             over (partition by m.category) as cl
    from public.place_marks m
    where m.business_id is null
      and public.ve_punto(m.location)
  ),
  grupos as (
    select g.category || ':' || min(g.id::text) as grupo,
           g.category,
           avg(extensions.st_y(g.location::extensions.geometry)) as lat,
           avg(extensions.st_x(g.location::extensions.geometry)) as lng,
           count(distinct g.user_id)::int as marcas,
           min(g.created_at) as primera_marca,
           max(g.google_link) as google_link,
           array_agg(g.id::text) as ids
    from marcas g
    group by g.category, g.cl
  )
  select gr.grupo, gr.category, gr.lat, gr.lng, gr.marcas,
         (select count(*) from public.events e
          where e.name = 'unclaimed_open' and e.created_at >= desde
            and e.target_id = any (gr.ids)),
         gr.primera_marca, gr.google_link
  from grupos gr
  order by 5 desc, 6 desc, gr.primera_marca
  limit 200;
end;
$$;

-- Sin zona elegida, un integrante usa la primera suya (admin: todas, como antes).
create or replace function public.admin_propuesta(p_rubro text default null, p_zona smallint default null,
                                                  p_negocio uuid default null, p_dias integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  dias  integer := greatest(1, least(p_dias, 365));
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
  b     record;
  rubro text := p_rubro;
  zona  smallint := p_zona;
  negocio jsonb;
begin
  perform public.exigir_equipo(array['sales']);
  if p_negocio is not null then
    select x.id, x.name, x.business_type, x.zone_id, x.plan, x.owner_id is not null as con_duenio
      into b from public.businesses x where x.id = p_negocio;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
    perform public.exigir_zona(b.zone_id);
    rubro := coalesce(rubro, b.business_type);
    zona := coalesce(zona, b.zone_id);
    negocio := jsonb_build_object(
      'nombre', b.name,
      'plan', b.plan,
      'con_duenio', b.con_duenio,
      'aperturas', (select coalesce(sum(s.value), 0) from public.daily_stats s
                    where s.business_id = p_negocio and s.metric = 'place_open' and s.day >= public.dia_uy(desde)),
      'personas', (select coalesce(sum(s.value), 0) from public.daily_stats s
                   where s.business_id = p_negocio and s.metric = 'place_open_people' and s.day >= public.dia_uy(desde)),
      'contactos', (select coalesce(sum(s.value), 0) from public.daily_stats s
                    where s.business_id = p_negocio and public.es_contacto(s.metric) and s.day >= public.dia_uy(desde)),
      'favoritos', (select count(*) from public.user_places u where u.business_id = p_negocio and u.favorite)
    );
  end if;
  zona := coalesce(zona, public.mi_primera_zona());
  perform public.exigir_zona(zona);
  if rubro is null then raise exception 'Falta el rubro' using errcode = '22023'; end if;

  return jsonb_build_object(
    'rubro', rubro,
    'dias', dias,
    'zona', (select z.name from public.zones z where z.id = zona),
    'audiencia', jsonb_build_object(
      'usuarios', public.al_menos_5((select count(*) from public.profiles pr
                                     where zona is null or pr.zone_id = zona)),
      'activos', public.al_menos_5((select count(distinct e.user_id) from public.events e
                                    where e.name = 'app_open' and e.created_at >= desde and e.user_id is not null
                                      and (zona is null or e.zone_id = zona))),
      'mascotas', coalesce((
        select jsonb_agg(jsonb_build_object('especie', s.name, 'cantidad', public.al_menos_5(t.n))
                         order by t.n desc)
        from (select pe.species_id, count(*) n
              from public.pets pe join public.profiles pr on pr.id = pe.owner_id
              where zona is null or pr.zone_id = zona
              group by 1) t
        join public.species s on s.id = t.species_id), '[]')
    ),
    'demanda', (
      select jsonb_build_object('busquedas', count(*),
                                'sin_resultados', count(*) filter (where (e.props ->> 'resultados')::int = 0))
      from public.events e
      where e.name = 'search' and e.created_at >= desde and e.props ->> 'rubro' = rubro
        and (zona is null or e.zone_id = zona)
    ),
    'oferta', (
      select jsonb_build_object('lugares', count(*),
                                'verificados', count(*) filter (where x.verification = 'verified'),
                                'pagos', count(*) filter (where x.plan <> 'basic'))
      from public.businesses x
      where x.status = 'active' and not x.is_sample and x.business_type = rubro
        and (zona is null or x.zone_id = zona)
    ),
    -- Lo que hace el rubro en la app (cuánto se abren las fichas de ese tipo).
    'rubro_aperturas', (
      select coalesce(sum(s.value), 0) from public.daily_stats s join public.businesses x on x.id = s.business_id
      where s.metric = 'place_open' and s.day >= public.dia_uy(desde) and x.business_type = rubro
        and (zona is null or s.zone_id = zona)
    ),
    'negocio', negocio,
    'casos', coalesce((
      select jsonb_agg(jsonb_build_object('comercio', c.business_name, 'cita', c.quote,
                                          'autor', c.author, 'numeros', c.numbers))
      from (select * from public.success_stories c
            where c.status = 'published' and c.business_type = rubro
            order by (c.zone_id is not distinct from zona) desc, c.updated_at desc
            limit 2) c), '[]')
  );
end;
$$;

create or replace function public.admin_registrar_propuesta(p_rubro text, p_negocio uuid default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['sales']);
  if p_negocio is not null then
    perform public.exigir_zona((select b.zone_id from public.businesses b where b.id = p_negocio));
  end if;
  perform public.registrar_accion('propuesta', 'business', coalesce(p_negocio::text, p_rubro),
                                  jsonb_build_object('rubro', p_rubro));
end;
$$;

create or replace function public.admin_casos()
returns setof public.success_stories
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['sales']);
  return query select * from public.success_stories c
               where public.ve_zona(c.zone_id)
               order by c.status desc, c.updated_at desc;
end;
$$;

create or replace function public.admin_guardar_caso(p jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  caso_id uuid := nullif(p ->> 'id', '')::uuid;
  zona smallint := coalesce(nullif(p ->> 'zone_id', '')::smallint, public.mi_primera_zona());
begin
  perform public.exigir_equipo(array['sales']);
  perform public.exigir_zona(zona);
  if caso_id is null then
    insert into public.success_stories (business_id, business_name, business_type, zone_id, quote,
                                        author, numbers, consent, status)
    values (nullif(p ->> 'business_id', '')::uuid, p ->> 'business_name', p ->> 'business_type',
            zona, p ->> 'quote', nullif(trim(p ->> 'author'), ''),
            nullif(trim(p ->> 'numbers'), ''), coalesce((p ->> 'consent')::boolean, false),
            coalesce(p ->> 'status', 'draft'))
    returning id into caso_id;
  else
    perform public.exigir_zona((select c.zone_id from public.success_stories c where c.id = caso_id));
    update public.success_stories
       set business_id = nullif(p ->> 'business_id', '')::uuid,
           business_name = p ->> 'business_name',
           business_type = p ->> 'business_type',
           zone_id = zona,
           quote = p ->> 'quote',
           author = nullif(trim(p ->> 'author'), ''),
           numbers = nullif(trim(p ->> 'numbers'), ''),
           consent = coalesce((p ->> 'consent')::boolean, false),
           status = coalesce(p ->> 'status', 'draft')
     where id = caso_id;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  end if;
  perform public.registrar_accion('guardar_caso', 'success_story', caso_id::text,
                                  jsonb_build_object('status', coalesce(p ->> 'status', 'draft')));
  return caso_id;
end;
$$;

create or replace function public.admin_borrar_caso(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['sales']);
  perform public.exigir_zona((select c.zone_id from public.success_stories c where c.id = p_id));
  delete from public.success_stories where id = p_id;
  perform public.registrar_accion('borrar_caso', 'success_story', p_id::text);
end;
$$;

-- ---------------------------------------------------------------------
-- Prospectos: con zona
-- ---------------------------------------------------------------------
alter table public.prospects add column zone_id smallint references public.zones (id);

update public.prospects x
   set zone_id = coalesce((select b.zone_id from public.businesses b where b.id = x.business_id),
                          (select z.id from public.zones z where z.slug = 'pando'));

-- Sin zona: la del lugar, si no la primera de quien lo carga, si no Pando.
create function public.prospecto_zona()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.zone_id := coalesce(new.zone_id,
                          (select b.zone_id from public.businesses b where b.id = new.business_id),
                          public.mi_primera_zona(),
                          (select z.id from public.zones z where z.slug = 'pando'));
  return new;
end;
$$;

revoke all on function public.prospecto_zona() from public, anon, authenticated;

create trigger prospects_zona
  before insert on public.prospects
  for each row execute function public.prospecto_zona();

drop policy "equipo_prospectos" on public.prospects;
create policy "equipo_prospectos" on public.prospects for all to authenticated
  using (public.es_equipo(array['sales']) and public.ve_zona(zone_id))
  with check (public.es_equipo(array['sales']) and public.ve_zona(zone_id));

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array['mis_zonas_equipo()', 'admin_zonas_integrante(uuid, smallint[])'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
