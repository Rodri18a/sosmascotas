-- Etapa 3.5 (D117): equipo de la empresa en el portal de empresas.
--  · Agenda, pedidos y socios ya están en el modo comercio en pantalla grande
--    (D114). Lo que faltaba es el **equipo**: varias personas por empresa.
--  · Un solo rol, **empleado**: atiende pedidos, turnos, paseos y estadías,
--    socios, canjes, pedidos de chapitas y el catálogo. Lo del **dueño** (el
--    titular): ficha, fotos, contactos privados, plan, verificación y RENAC,
--    módulos y su configuración, estadísticas, propuestas, apadrinamiento,
--    punto de retiro y el equipo.
--  · soy_duenio_de() pasa a ser «atiendo este negocio» (dueño o empleado) y
--    soy_titular_de() es solo el dueño: las funciones del dueño se vuelven a
--    crear igual que estaban, con soy_titular_de().
--  · Se suma con un **código de invitación** (8 letras, 7 días, un uso) que
--    el dueño genera y el empleado ingresa en la app: nadie averigua si un
--    correo tiene cuenta. Hasta 10 personas por empresa.
--  · Los avisos push y el chat del comercio siguen yendo al dueño.

create table public.business_team (
  business_id uuid not null references public.businesses (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  added_by    uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  primary key (business_id, user_id)
);

create index business_team_user_idx on public.business_team (user_id);

comment on table public.business_team is
  'Empleados de cada empresa (3.5, D117). Sin acceso directo: equipo_del_negocio(), unirme_al_equipo(), quitar_del_equipo().';

create table public.business_team_invites (
  code        text primary key check (code ~ '^[A-Z2-9]{8}$'),
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_by  uuid references auth.users (id) on delete set null,
  expires_at  timestamptz not null default now() + interval '7 days',
  used_by     uuid references auth.users (id) on delete set null,
  used_at     timestamptz,
  created_at  timestamptz not null default now()
);

create index business_team_invites_business_idx on public.business_team_invites (business_id);

alter table public.business_team enable row level security;

alter table public.business_team_invites enable row level security;

revoke all on public.business_team, public.business_team_invites from anon, authenticated;

-- ---------------------------------------------------------------------
-- Quién es quién
-- ---------------------------------------------------------------------

-- El dueño (titular) del negocio.
create function public.soy_titular_de(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.businesses
                 where id = p_business and owner_id = (select auth.uid()));
$$;

-- Atiendo este negocio: el dueño o alguien de su equipo.
create or replace function public.soy_duenio_de(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select public.soy_titular_de(p_business)
      or exists (select 1 from public.business_team
                 where business_id = p_business and user_id = (select auth.uid()));
$$;

revoke all on function public.soy_titular_de(uuid) from public, anon;

grant execute on function public.soy_titular_de(uuid) to authenticated;

-- Mis negocios: los míos y los de los equipos en los que estoy (rol). El
-- RUT, solo para el dueño.
drop function public.mis_negocios();

create function public.mis_negocios()
returns table (
  id uuid, business_type text, kind text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text, web text,
  instagram text, facebook text, promo text, coverage text, hours jsonb, special_days jsonb,
  is_24h boolean, emergencies boolean, species_ids smallint[], verification text,
  renac_operator boolean, plan text, status text, rut text, founder_until date,
  renac_requested_at timestamptz, verification_requested_at timestamptz, verified boolean,
  is_sample boolean, rol text
)
language sql stable security definer set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry), extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.facebook, b.promo, b.coverage, b.hours,
         b.special_days, b.is_24h, b.emergencies, b.species_ids, b.verification,
         b.renac_operator, b.plan, b.status,
         case when b.owner_id = (select auth.uid()) then b.rut end,
         b.founder_until, b.renac_requested_at,
         b.verification_requested_at, b.verification = 'verified', b.is_sample,
         case when b.owner_id = (select auth.uid()) then 'owner' else 'employee' end
  from public.businesses b
  where b.owner_id = (select auth.uid())
     or exists (select 1 from public.business_team t
                where t.business_id = b.id and t.user_id = (select auth.uid()))
  order by (b.owner_id <> (select auth.uid())), b.created_at;
$$;

revoke all on function public.mis_negocios() from public, anon;

grant execute on function public.mis_negocios() to authenticated;

-- ---------------------------------------------------------------------
-- Equipo
-- ---------------------------------------------------------------------
create function public.invitar_al_equipo(p_negocio uuid)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  codigo text;
  letras constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'Solo el dueño arma el equipo' using errcode = '42501';
  end if;
  if (select count(*) from public.business_team where business_id = p_negocio) >= 10 then
    raise exception 'Máximo 10 personas por equipo' using errcode = '54000';
  end if;
  if (select count(*) from public.business_team_invites
      where business_id = p_negocio and used_at is null and expires_at > now()) >= 5 then
    raise exception 'Demasiadas invitaciones abiertas' using errcode = '54000';
  end if;
  loop
    codigo := (select string_agg(substr(letras, 1 + floor(random() * length(letras))::int, 1), '')
               from generate_series(1, 8));
    exit when not exists (select 1 from public.business_team_invites where code = codigo);
  end loop;
  insert into public.business_team_invites (code, business_id, created_by)
  values (codigo, p_negocio, (select auth.uid()));
  return codigo;
end;
$$;

-- El empleado ingresa el código; devuelve el id del negocio.
create function public.unirme_al_equipo(p_codigo text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  inv public.business_team_invites;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select * into inv from public.business_team_invites
  where code = upper(trim(p_codigo)) and used_at is null and expires_at > now()
  for update;
  if not found then raise exception 'Código inválido o vencido' using errcode = 'P0002'; end if;
  if exists (select 1 from public.businesses where id = inv.business_id and owner_id = yo) then
    raise exception 'Ya sos el dueño' using errcode = '22023';
  end if;
  if (select count(*) from public.business_team where business_id = inv.business_id) >= 10 then
    raise exception 'Máximo 10 personas por equipo' using errcode = '54000';
  end if;
  insert into public.business_team (business_id, user_id, added_by)
  values (inv.business_id, yo, inv.created_by)
  on conflict do nothing;
  update public.business_team_invites set used_by = yo, used_at = now() where code = inv.code;
  return inv.business_id;
end;
$$;

-- Quiénes están (primer nombre) y, para el dueño, los códigos abiertos.
create function public.equipo_del_negocio(p_negocio uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  titular boolean := public.soy_titular_de(p_negocio);
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'soy_titular', titular,
    'personas', coalesce((
      select jsonb_agg(jsonb_build_object(
               'user_id', t.user_id, 'nombre', public.primer_nombre(t.user_id),
               'desde', t.created_at, 'soy_yo', t.user_id = (select auth.uid()))
             order by t.created_at)
      from public.business_team t where t.business_id = p_negocio), '[]'),
    'invitaciones', case when titular then coalesce((
      select jsonb_agg(jsonb_build_object('code', i.code, 'expires_at', i.expires_at) order by i.created_at)
      from public.business_team_invites i
      where i.business_id = p_negocio and i.used_at is null and i.expires_at > now()), '[]')
      else '[]' end
  );
end;
$$;

-- El dueño saca a alguien; un empleado puede irse solo.
create function public.quitar_del_equipo(p_negocio uuid, p_user uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not (public.soy_titular_de(p_negocio) or p_user = (select auth.uid())) then
    raise exception 'Solo el dueño saca a alguien del equipo' using errcode = '42501';
  end if;
  delete from public.business_team where business_id = p_negocio and user_id = p_user;
  if not found then raise exception 'No está en el equipo' using errcode = 'P0002'; end if;
end;
$$;

-- El dueño anula un código sin usar.
create function public.anular_invitacion_equipo(p_codigo text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.business_team_invites i
  where i.code = p_codigo and i.used_at is null and public.soy_titular_de(i.business_id);
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
end;
$$;

revoke all on function public.invitar_al_equipo(uuid) from public, anon;

revoke all on function public.unirme_al_equipo(text) from public, anon;

revoke all on function public.equipo_del_negocio(uuid) from public, anon;

revoke all on function public.quitar_del_equipo(uuid, uuid) from public, anon;

revoke all on function public.anular_invitacion_equipo(text) from public, anon;

grant execute on function public.invitar_al_equipo(uuid) to authenticated;

grant execute on function public.unirme_al_equipo(text) to authenticated;

grant execute on function public.equipo_del_negocio(uuid) to authenticated;

grant execute on function public.quitar_del_equipo(uuid, uuid) to authenticated;

grant execute on function public.anular_invitacion_equipo(text) to authenticated;

-- ---------------------------------------------------------------------
-- Fotos y contactos privados: solo el dueño
-- ---------------------------------------------------------------------
drop policy "subir_fotos_de_mi_comercio" on public.business_photos;

drop policy "ordenar_fotos_de_mi_comercio" on public.business_photos;

drop policy "borrar_fotos_de_mi_comercio" on public.business_photos;

drop policy "ver_mis_contactos_privados" on public.business_contacts_private;

drop policy "cargar_mis_contactos_privados" on public.business_contacts_private;

drop policy "cambiar_mis_contactos_privados" on public.business_contacts_private;

drop policy "subir_fotos_del_comercio" on storage.objects;

drop policy "borrar_fotos_del_comercio" on storage.objects;

create policy "subir_fotos_de_mi_comercio" on public.business_photos for insert to authenticated
  with check (public.soy_titular_de(business_id));

create policy "ordenar_fotos_de_mi_comercio" on public.business_photos for update to authenticated
  using (public.soy_titular_de(business_id)) with check (public.soy_titular_de(business_id));

create policy "borrar_fotos_de_mi_comercio" on public.business_photos for delete to authenticated
  using (public.soy_titular_de(business_id) or public.es_admin());

create policy "ver_mis_contactos_privados" on public.business_contacts_private for select to authenticated
  using (public.soy_titular_de(business_id) or public.es_admin());

create policy "cargar_mis_contactos_privados" on public.business_contacts_private for insert to authenticated
  with check (public.soy_titular_de(business_id));

create policy "cambiar_mis_contactos_privados" on public.business_contacts_private for update to authenticated
  using (public.soy_titular_de(business_id)) with check (public.soy_titular_de(business_id));

create policy "subir_fotos_del_comercio" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'business-photos'
    and public.soy_titular_de(((storage.foldername(name))[1])::uuid)
  );

create policy "borrar_fotos_del_comercio" on storage.objects for delete to authenticated
  using (
    bucket_id = 'business-photos'
    and public.soy_titular_de(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------
-- Funciones del dueño: iguales que antes, con soy_titular_de()
-- ---------------------------------------------------------------------
-- Vigente en 20261018090000_comercios_con_cuenta.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.editar_mi_negocio(p_id uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  punto extensions.geography;
begin
  if not public.soy_titular_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not public.datos_de_negocio_validos(p) or (p ->> 'status') not in ('active', 'hidden') and p ? 'status' then
    raise exception 'Datos no permitidos' using errcode = '22023';
  end if;
  if p ? 'lat' and p ->> 'lat' is not null and p ->> 'lng' is not null then
    punto := extensions.st_setsrid(extensions.st_makepoint((p ->> 'lng')::double precision,
                                                           (p ->> 'lat')::double precision), 4326)::extensions.geography;
  end if;
  update public.businesses b set
    business_type = coalesce(p ->> 'business_type', b.business_type),
    kind = coalesce(p ->> 'kind', b.kind),
    name = coalesce(p ->> 'name', b.name),
    description = case when p ? 'description' then nullif(p ->> 'description', '') else b.description end,
    address = case when p ? 'address' then nullif(p ->> 'address', '') else b.address end,
    location = case when p ? 'lat' then punto else b.location end,
    phone = case when p ? 'phone' then nullif(p ->> 'phone', '') else b.phone end,
    whatsapp = case when p ? 'whatsapp' then nullif(p ->> 'whatsapp', '') else b.whatsapp end,
    web = case when p ? 'web' then nullif(p ->> 'web', '') else b.web end,
    instagram = case when p ? 'instagram' then nullif(p ->> 'instagram', '') else b.instagram end,
    facebook = case when p ? 'facebook' then nullif(p ->> 'facebook', '') else b.facebook end,
    -- La promoción es de los planes pagos (06).
    promo = case when p ? 'promo' and b.plan <> 'basic' then nullif(p ->> 'promo', '') else b.promo end,
    coverage = case when p ? 'coverage' then nullif(p ->> 'coverage', '') else b.coverage end,
    hours = coalesce(p -> 'hours', b.hours),
    special_days = coalesce(p -> 'special_days', b.special_days),
    is_24h = coalesce((p ->> 'is_24h')::boolean, b.is_24h),
    emergencies = coalesce((p ->> 'emergencies')::boolean, b.emergencies),
    species_ids = case when p ? 'species_ids'
                       then coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}')
                       else b.species_ids end,
    status = coalesce(p ->> 'status', b.status)
  where b.id = p_id;
end;
$$;

-- Vigente en 20261018090000_comercios_con_cuenta.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.pedir_insignia_renac(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if (select business_type from public.businesses where id = p_id) <> 'vet' then
    raise exception 'Solo para veterinarias' using errcode = '22023';
  end if;
  update public.businesses set renac_requested_at = now() where id = p_id;
end;
$$;

-- Vigente en 20261026040000_planes_y_cobros.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.pedir_plan(p_business uuid, p_plan text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  b record;
begin
  if not public.soy_titular_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_plan not in ('featured', 'plus') then raise exception 'Plan inválido' using errcode = '22023'; end if;
  if exists (select 1 from public.prospects pr
             where pr.business_id = p_business and pr.stage in ('prospect', 'contacted', 'demo')
               and pr.notes like 'Pidió el plan %') then
    raise exception 'Ya lo pediste: te vamos a contactar' using errcode = '23505';
  end if;
  select x.name, x.business_type into b from public.businesses x where x.id = p_business;
  insert into public.prospects (name, business_type, business_id, stage, next_contact, notes)
  values (b.name, case when b.business_type = 'agro' then null else b.business_type end, p_business,
          'contacted', current_date + 1,
          'Pidió el plan ' || case p_plan when 'plus' then 'Plus' else 'Destacado' end
          || ' desde la app el ' || to_char(public.dia_uy(now()), 'DD/MM/YYYY') || '.');
end;
$$;

-- Vigente en 20261018090000_comercios_con_cuenta.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.pedir_verificacion(p_id uuid, p_rut text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  update public.businesses
     set rut = regexp_replace(p_rut, '[^0-9]', '', 'g'),
         verification = case when verification = 'verified' then verification else 'pending' end,
         verification_requested_at = now()
   where id = p_id;
end;
$$;

-- Vigente en 20261019030000_socios_y_busco_veterinaria.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.prender_modulo(p_business uuid, p_modulo text, p_prendido boolean)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_prendido and not exists (
    select 1 from public.businesses
    where id = p_business and plan = 'plus'
      and public.modulo_admitido(business_type, kind, p_modulo)
  ) then
    raise exception 'El módulo necesita el plan Plus y que tu tipo de negocio lo admita'
      using errcode = '42501';
  end if;
  insert into public.business_modules (business_id, module, enabled)
  values (p_business, p_modulo, p_prendido)
  on conflict (business_id, module) do update set enabled = excluded.enabled, updated_at = now();
end;
$$;

-- Vigente en 20261026060000_agenda_turnos.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.guardar_agenda(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if (select plan from public.businesses where id = p_negocio) <> 'plus' then
    raise exception 'La agenda es del plan Plus' using errcode = '42501';
  end if;
  insert into public.agenda_settings as c (business_id, slot_min, capacity, notice_min, days_ahead, hours, service_ids)
  values (p_negocio,
          coalesce((p ->> 'slot_min')::smallint, 30),
          coalesce((p ->> 'capacity')::smallint, 1),
          coalesce((p ->> 'notice_min')::integer, 120),
          coalesce((p ->> 'days_ahead')::smallint, 30),
          case when jsonb_typeof(p -> 'hours') = 'object' then p -> 'hours' end,
          case when jsonb_typeof(p -> 'service_ids') = 'array'
               then array(select jsonb_array_elements_text(p -> 'service_ids')::uuid) end)
  on conflict (business_id) do update
     set slot_min = excluded.slot_min, capacity = excluded.capacity, notice_min = excluded.notice_min,
         days_ahead = excluded.days_ahead, hours = excluded.hours, service_ids = excluded.service_ids;
  -- Solo servicios de este comercio.
  if exists (select 1 from public.agenda_settings c, unnest(c.service_ids) sid
             where c.business_id = p_negocio
               and not exists (select 1 from public.business_services s where s.id = sid and s.business_id = p_negocio)) then
    raise exception 'Hay servicios que no son de este comercio' using errcode = '22023';
  end if;
end;
$$;

-- Vigente en 20261026060000_agenda_turnos.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.bloquear_dia(p_negocio uuid, p_dia date, p_nota text default null, p_bloquear boolean default true)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_bloquear then
    if p_dia < public.dia_uy(now()) then raise exception 'Ese día ya pasó' using errcode = '22023'; end if;
    if (select count(*) from public.agenda_blocks where business_id = p_negocio and day >= public.dia_uy(now())) >= 60 then
      raise exception 'Máximo 60 días bloqueados' using errcode = '54000';
    end if;
    insert into public.agenda_blocks (business_id, day, note) values (p_negocio, p_dia, nullif(left(trim(p_nota), 80), ''))
      on conflict (business_id, day) do update set note = excluded.note;
  else
    delete from public.agenda_blocks where business_id = p_negocio and day = p_dia;
  end if;
end;
$$;

-- Vigente en 20261021030000_pedido_whatsapp.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.guardar_condiciones_pedido(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.businesses
    where id = p_negocio and plan = 'plus'
      and public.modulo_admitido(business_type, kind, 'catalogo')
  ) then
    raise exception 'El catálogo necesita el plan Plus' using errcode = '42501';
  end if;
  insert into public.order_settings (business_id, payment_methods, pickup, shipping, shipping_cost,
                                     free_shipping_from)
  values (p_negocio,
          coalesce(array(select distinct jsonb_array_elements_text(p -> 'payment_methods')), '{}'),
          coalesce((p ->> 'pickup')::boolean, true), coalesce((p ->> 'shipping')::boolean, false),
          (p ->> 'shipping_cost')::numeric, (p ->> 'free_shipping_from')::numeric)
  on conflict (business_id) do update set
    payment_methods = excluded.payment_methods, pickup = excluded.pickup, shipping = excluded.shipping,
    shipping_cost = excluded.shipping_cost, free_shipping_from = excluded.free_shipping_from;
end;
$$;

-- Vigente en 20261028000000_contrataciones.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.guardar_cuidados(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not exists (select 1 from public.businesses where id = p_negocio and plan = 'plus'
                 and business_type in ('walker', 'hotel')) then
    raise exception 'Es para paseadores y hoteles con plan Plus' using errcode = '42501';
  end if;
  insert into public.care_settings as c (business_id, kinds, capacity, days_ahead, max_days, conditions)
  values (p_negocio,
          case when jsonb_typeof(p -> 'kinds') = 'array'
               then array(select distinct jsonb_array_elements_text(p -> 'kinds')) else '{}' end,
          coalesce((p ->> 'capacity')::smallint, 5),
          coalesce((p ->> 'days_ahead')::smallint, 60),
          coalesce((p ->> 'max_days')::smallint, 15),
          nullif(left(trim(p ->> 'conditions'), 300), ''))
  on conflict (business_id) do update
     set kinds = excluded.kinds, capacity = excluded.capacity, days_ahead = excluded.days_ahead,
         max_days = excluded.max_days, conditions = excluded.conditions;
end;
$$;

-- Vigente en 20261026040000_planes_y_cobros.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.mi_plan(p_business uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  b record;
  s public.subscriptions;
begin
  if not (public.soy_titular_de(p_business) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select x.plan, x.founder_until into b from public.businesses x where x.id = p_business;
  select * into s from public.subscriptions
   where owner_type = 'business' and owner_id = p_business and status in ('active', 'past_due', 'cancelled')
   order by created_at desc limit 1;
  return jsonb_build_object(
    'plan', b.plan,
    'socio_fundador_hasta', b.founder_until,
    'estado', s.status,
    'vence', s.period_end,
    'precio', s.price,
    'moneda', s.currency,
    'fundador', s.founder,
    'pagos', coalesce((select jsonb_agg(jsonb_build_object('fecha', public.dia_uy(p.paid_at), 'monto', p.amount,
                                                           'metodo', p.method, 'meses', p.months)
                                        order by p.paid_at desc)
                       from public.payments p join public.subscriptions x on x.id = p.subscription_id
                       where x.owner_type = 'business' and x.owner_id = p_business), '[]'),
    'pedido_abierto', exists (select 1 from public.prospects pr
                              where pr.business_id = p_business and pr.stage in ('prospect', 'contacted', 'demo')
                                and pr.notes like 'Pidió el plan %'),
    'antes_despues', public.antes_y_despues_del_plan(p_business)
  );
end;
$$;

-- Vigente en 20261026020000_estadisticas_comercio.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.estadisticas_negocio(p_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  hoy       date := public.dia_uy(now());
  mes       date := date_trunc('month', public.dia_uy(now())::timestamp)::date;
  plan_     text;
  completo  boolean;
  meses     integer;
  resultado jsonb;
begin
  if not (public.soy_titular_de(p_id) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select plan into plan_ from public.businesses where id = p_id;
  completo := plan_ in ('featured', 'plus') or public.es_admin();
  meses := case when completo then 6 else 2 end;

  with datos as (
    select s.day, s.metric, s.value from public.daily_stats s
    where s.business_id = p_id and s.day >= (mes - make_interval(months => meses - 1))::date and s.day < hoy
    union all
    -- Hoy todavía no está resumido: se cuenta en el momento.
    select c.day, c.metric, c.value
    from public.contar_eventos_comercio(public.inicio_dia_uy(hoy), now() + interval '1 minute', p_id) c
  ),
  con_contactos as (
    select day, metric, value from datos
    where completo or metric = 'place_open'
    union all
    select day, 'contactos', sum(value)::integer from datos where public.es_contacto(metric) group by day
  ),
  por_mes as (
    select date_trunc('month', day::timestamp)::date m, metric, sum(value)::integer v
    from con_contactos group by 1, 2
  ),
  por_semana as (
    select date_trunc('week', day::timestamp)::date s, metric, sum(value)::integer v
    from con_contactos
    where completo and metric in ('place_open', 'contactos')
      and day >= (date_trunc('week', hoy::timestamp) - interval '11 weeks')::date
    group by 1, 2
  )
  select jsonb_build_object(
    'plan', plan_,
    'completo', completo,
    'hoy', hoy,
    'meses', coalesce((
      select jsonb_agg(jsonb_build_object(
               'mes', g.m::date,
               'metricas', coalesce((select jsonb_object_agg(p.metric, p.v) from por_mes p where p.m = g.m::date), '{}')
             ) order by g.m)
      from generate_series((mes - make_interval(months => meses - 1))::timestamp, mes::timestamp, interval '1 month') g(m)
    ), '[]'),
    'semanas', case when completo then coalesce((
      select jsonb_agg(jsonb_build_object(
               'semana', g.s::date,
               'aperturas', coalesce((select v from por_semana p where p.s = g.s::date and p.metric = 'place_open'), 0),
               'contactos', coalesce((select v from por_semana p where p.s = g.s::date and p.metric = 'contactos'), 0)
             ) order by g.s)
      from generate_series(date_trunc('week', hoy::timestamp) - interval '11 weeks', date_trunc('week', hoy::timestamp), interval '1 week') g(s)
    ), '[]') else '[]'::jsonb end
  ) into resultado;
  return resultado;
end;
$$;

-- Vigente en 20261019040000_propuestas_a_ex_socios.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.enviar_propuesta_veterinaria(p_business uuid, p_mensaje text,
                                                     p_especie smallint default null,
                                                     p_radio_km smallint default 2)
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  punto extensions.geography;
  id_ uuid;
  n integer;
begin
  if not public.soy_titular_de(p_business) or not public.modulo_activo(p_business, 'socios') then
    raise exception 'Solo con el plan Plus y el módulo Socios activo' using errcode = '42501';
  end if;
  if (select count(*) from public.vet_proposals
      where business_id = p_business and created_at > now() - interval '7 days') >= 2 then
    raise exception 'Como máximo 2 propuestas por semana' using errcode = '54000';
  end if;
  select location into punto from public.businesses where id = p_business;
  insert into public.vet_proposals (business_id, message, species_id, radius_km)
  values (p_business, trim(p_mensaje), p_especie, least(greatest(p_radio_km, 1), 10))
  returning id into id_;
  insert into public.vet_proposal_deliveries (proposal_id, pet_id)
  select id_, p.id
  from public.vet_search_consents c
  join public.pets p on p.id = c.pet_id
  join public.profiles pr on pr.id = c.owner_id
  where c.revoked_at is null and pr.approx_location is not null
    and (p_especie is null or p.species_id = p_especie)
    and extensions.st_dwithin(pr.approx_location, punto, least(greatest(p_radio_km, 1), 10) * 1000)
    and not exists (select 1 from public.pet_vet_shares s where s.pet_id = p.id and s.business_id = p_business
                    and s.revoked_at is null)
    and (select count(*) from public.vet_proposal_deliveries d
         where d.pet_id = p.id and d.created_at > date_trunc('month', now())) < 3;
  get diagnostics n = row_count;
  return n;
end;
$$;

-- Vigente en 20261019030000_socios_y_busco_veterinaria.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.demanda_de_veterinaria(p_business uuid, p_radio_km smallint default 2)
returns table (species_id smallint, cantidad integer)
language plpgsql stable security definer set search_path = ''
as $$
declare
  punto extensions.geography;
begin
  if not public.soy_titular_de(p_business) or not public.modulo_activo(p_business, 'socios') then
    raise exception 'Solo con el plan Plus y el módulo Socios activo' using errcode = '42501';
  end if;
  select location into punto from public.businesses where id = p_business;
  return query
  select p.species_id, count(*)::int
  from public.vet_search_consents c
  join public.pets p on p.id = c.pet_id
  join public.profiles pr on pr.id = c.owner_id
  where c.revoked_at is null and pr.approx_location is not null
    and extensions.st_dwithin(pr.approx_location, punto, least(greatest(p_radio_km, 1), 10) * 1000)
  group by p.species_id
  having count(*) >= 5;
end;
$$;

-- Vigente en 20261019030000_socios_y_busco_veterinaria.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.resultados_propuestas(p_business uuid)
returns table (id uuid, message text, created_at timestamptz, enviadas integer, vistas integer, aceptadas integer)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select v.id, v.message, v.created_at,
         (select count(*)::int from public.vet_proposal_deliveries d where d.proposal_id = v.id),
         (select count(*)::int from public.vet_proposal_deliveries d where d.proposal_id = v.id and d.status <> 'sent'),
         (select count(*)::int from public.vet_proposal_deliveries d where d.proposal_id = v.id and d.status = 'accepted')
  from public.vet_proposals v where v.business_id = p_business
  order by v.created_at desc limit 50;
end;
$$;

-- Vigente en 20261026100000_apadrinamiento.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.responder_apadrinamiento(p_id uuid, p_aceptar boolean)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  s public.shelter_sponsorships;
begin
  select * into s from public.shelter_sponsorships where id = p_id for update;
  if not found or not public.soy_titular_de(s.shelter_id) then
    raise exception 'No es un ofrecimiento para tu refugio' using errcode = '42501';
  end if;
  if s.status <> 'pending' then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.shelter_sponsorships
     set status = case when coalesce(p_aceptar, false) then 'active' else 'declined' end
   where id = p_id;
end;
$$;

-- Vigente en 20261026100000_apadrinamiento.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.terminar_apadrinamiento(p_id uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  s public.shelter_sponsorships;
begin
  select * into s from public.shelter_sponsorships where id = p_id for update;
  if not found or not (public.soy_titular_de(s.shelter_id) or public.soy_titular_de(s.sponsor_id)) then
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  if not (s.status = 'active' or (s.status = 'pending' and public.soy_titular_de(s.sponsor_id))) then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.shelter_sponsorships set status = 'ended' where id = p_id;
end;
$$;

-- Vigente en 20261023030000_pedido_chapitas.sql; solo cambia soy_duenio_de → soy_titular_de.
create or replace function public.prender_punto_retiro(p_business uuid, p_prender boolean)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if not public.soy_titular_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_prender and not exists (select 1 from public.businesses
                               where id = p_business and business_type = 'vet'
                                 and verification = 'verified' and status = 'active') then
    raise exception 'solo_verificadas' using errcode = 'P0001';
  end if;
  update public.businesses set tag_pickup = coalesce(p_prender, false) where id = p_business;
end;
$$;
