-- Etapas 2.6 y 2.6b (D81): módulo Socios de la veterinaria y "Busco
-- veterinaria" (03 §14, 06).
--  · Módulos del comercio (catálogo, agenda, socios): activos solo con plan
--    Plus, si el tipo lo admite y la empresa lo prendió (regla de 06).
--  · Socios: el dueño **comparte** una mascota con su veterinaria (por
--    mascota, con consentimiento registrado y revocable). La veterinaria ve
--    nombre, especie, primer nombre del dueño y el próximo control de la
--    libreta, y puede "Recordar": se crea un recordatorio en la mascota.
--  · Busco veterinaria: opt-in por mascota (consentimiento registrado y
--    revocable). La veterinaria ve solo cantidades agregadas por especie a
--    menos de 2 km (mínimo 5 para mostrar), manda propuestas (como máximo 3
--    por mes por mascota entre todas) y recién ve a la persona cuando acepta.

-- ---------------------------------------------------------------------
-- Módulos
-- ---------------------------------------------------------------------
create table public.business_modules (
  business_id  uuid not null references public.businesses (id) on delete cascade,
  module       text not null check (module in ('catalogo', 'agenda', 'socios')),
  enabled      boolean not null default true,
  updated_at   timestamptz not null default now(),
  primary key (business_id, module)
);

alter table public.business_modules enable row level security;
create policy "ver_mis_modulos" on public.business_modules for select to authenticated
  using (public.soy_duenio_de(business_id) or public.es_admin());
revoke all on public.business_modules from anon;
revoke insert, update, delete on public.business_modules from authenticated;

-- ¿El tipo de negocio admite el módulo? (misma tabla que moduloAdmitido()).
create function public.modulo_admitido(p_tipo text, p_modalidad text, p_modulo text)
returns boolean
language sql immutable set search_path = ''
as $$
  select case
    when p_modalidad = 'online' then p_modulo = 'catalogo'
    when p_modalidad = 'domicilio' then p_modulo = 'agenda'
    when p_tipo = 'vet' then true
    when p_tipo in ('petshop', 'pharmacy') then p_modulo = 'catalogo'
    when p_tipo in ('grooming', 'hotel', 'walker', 'trainer') then p_modulo = 'agenda'
    else false
  end;
$$;

create function public.modulo_activo(p_business uuid, p_modulo text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.businesses b
    join public.business_modules m on m.business_id = b.id and m.module = p_modulo and m.enabled
    where b.id = p_business and b.plan = 'plus' and b.status = 'active'
      and public.modulo_admitido(b.business_type, b.kind, p_modulo)
  );
$$;

create function public.prender_modulo(p_business uuid, p_modulo text, p_prendido boolean)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_business) then
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

-- ---------------------------------------------------------------------
-- Socios: mascotas compartidas con su veterinaria
-- ---------------------------------------------------------------------
create table public.pet_vet_shares (
  pet_id       uuid not null references public.pets (id) on delete cascade,
  business_id  uuid not null references public.businesses (id) on delete cascade,
  shared_by    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  consent_at   timestamptz not null default now(),
  revoked_at   timestamptz,
  primary key (pet_id, business_id)
);

alter table public.pet_vet_shares enable row level security;
create policy "ver_lo_que_comparto" on public.pet_vet_shares for select to authenticated
  using (public.puedo_cuidar(pet_id));
revoke all on public.pet_vet_shares from anon;
revoke insert, update, delete on public.pet_vet_shares from authenticated;

create function public.compartir_con_veterinaria(p_pet uuid, p_business uuid, p_compartir boolean)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = (select auth.uid())) then
    raise exception 'Solo el dueño la comparte' using errcode = '42501';
  end if;
  if p_compartir then
    if not exists (select 1 from public.businesses
                   where id = p_business and business_type = 'vet' and status = 'active') then
      raise exception 'Solo con veterinarias' using errcode = '22023';
    end if;
    insert into public.pet_vet_shares (pet_id, business_id)
    values (p_pet, p_business)
    on conflict (pet_id, business_id) do update set consent_at = now(), revoked_at = null;
  else
    update public.pet_vet_shares set revoked_at = now()
     where pet_id = p_pet and business_id = p_business and revoked_at is null;
  end if;
end;
$$;

-- Socios de mi veterinaria (módulo activo): nombre, especie, primer nombre del
-- dueño y el próximo control de la libreta.
create function public.mis_socios(p_business uuid)
returns table (pet_id uuid, nombre text, especie smallint, duenio text, proximo date, proximo_que text)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not public.modulo_activo(p_business, 'socios') then
    raise exception 'El módulo Socios no está activo' using errcode = '42501';
  end if;
  return query
  select p.id, p.name, p.species_id, split_part(trim(coalesce(pr.display_name, '')), ' ', 1),
         (select min(h.next_date) from public.health_records h
          where h.pet_id = p.id and h.next_date >= current_date),
         (select h.name from public.health_records h
          where h.pet_id = p.id and h.next_date >= current_date order by h.next_date limit 1)
  from public.pet_vet_shares s
  join public.pets p on p.id = s.pet_id
  left join public.profiles pr on pr.id = p.owner_id
  where s.business_id = p_business and s.revoked_at is null
  order by 5 nulls last, p.name;
end;
$$;

-- "Recordar": la veterinaria le deja un recordatorio a la mascota (suena en
-- el celular del dueño como cualquier otro).
create function public.recordar_a_socio(p_business uuid, p_pet uuid, p_titulo text, p_cuando timestamptz)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  nombre text;
begin
  if not public.soy_duenio_de(p_business) or not public.modulo_activo(p_business, 'socios') then
    raise exception 'No es tu negocio o el módulo no está activo' using errcode = '42501';
  end if;
  if not exists (select 1 from public.pet_vet_shares
                 where business_id = p_business and pet_id = p_pet and revoked_at is null) then
    raise exception 'La mascota no está compartida con vos' using errcode = '42501';
  end if;
  if p_cuando < now() or p_cuando > now() + interval '1 year' then
    raise exception 'Fecha inválida' using errcode = '22023';
  end if;
  if (select count(*) from public.reminders r
      where r.pet_id = p_pet and r.title like '%(de tu veterinaria)'
        and r.created_at > now() - interval '7 days') >= 3 then
    raise exception 'Demasiados recordatorios esta semana' using errcode = '54000';
  end if;
  select name into nombre from public.businesses where id = p_business;
  insert into public.reminders (pet_id, kind, title, dose, schedule, starts_at)
  values (p_pet, 'checkup', left(trim(p_titulo), 60) || ' (de tu veterinaria)', left(nombre, 80),
          '{"tipo": "una_vez"}', p_cuando);
end;
$$;

-- ---------------------------------------------------------------------
-- Busco veterinaria
-- ---------------------------------------------------------------------
create table public.vet_search_consents (
  pet_id       uuid primary key references public.pets (id) on delete cascade,
  owner_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  scope        text not null default 'vet' check (scope in ('vet')),
  consent_at   timestamptz not null default now(),
  revoked_at   timestamptz,
  snoozed_until timestamptz          -- "Ahora no" (Gratis: 90 días; Pro/Familia: nunca más)
);

create table public.vet_proposals (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  message      text not null check (char_length(trim(message)) between 5 and 300),
  species_id   smallint references public.species (id),
  radius_km    smallint not null default 2 check (radius_km between 1 and 10),
  created_at   timestamptz not null default now()
);

create table public.vet_proposal_deliveries (
  proposal_id  uuid not null references public.vet_proposals (id) on delete cascade,
  pet_id       uuid not null references public.pets (id) on delete cascade,
  status       text not null default 'sent' check (status in ('sent', 'seen', 'accepted', 'declined')),
  created_at   timestamptz not null default now(),
  answered_at  timestamptz,
  primary key (proposal_id, pet_id)
);

create index vet_proposal_deliveries_pet_idx on public.vet_proposal_deliveries (pet_id, created_at desc);

alter table public.vet_search_consents enable row level security;
alter table public.vet_proposals enable row level security;
alter table public.vet_proposal_deliveries enable row level security;
revoke all on public.vet_search_consents, public.vet_proposals, public.vet_proposal_deliveries
  from anon, authenticated;

create function public.busco_veterinaria(p_pet uuid, p_quiero boolean)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = yo) then
    raise exception 'Solo el dueño decide' using errcode = '42501';
  end if;
  if p_quiero then
    insert into public.vet_search_consents (pet_id, owner_id) values (p_pet, yo)
    on conflict (pet_id) do update set consent_at = now(), revoked_at = null, snoozed_until = null;
  else
    update public.vet_search_consents set revoked_at = now() where pet_id = p_pet and revoked_at is null;
  end if;
end;
$$;

-- "Ahora no": Gratis no vuelve a preguntar por 90 días; Pro y Familia, nunca.
create function public.ahora_no_busco_veterinaria(p_pet uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  plan text := (select plan::text from public.profiles where id = yo);
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = yo) then
    raise exception 'Solo el dueño decide' using errcode = '42501';
  end if;
  insert into public.vet_search_consents (pet_id, owner_id, revoked_at, snoozed_until)
  values (p_pet, yo, now(), case when plan = 'free' then now() + interval '90 days' else 'infinity' end)
  on conflict (pet_id) do update
    set snoozed_until = excluded.snoozed_until,
        revoked_at = coalesce(public.vet_search_consents.revoked_at, now());
end;
$$;

-- Estado para la app: ¿se puede mostrar la tarjeta? ¿está buscando?
create function public.estado_busco_veterinaria(p_pet uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'buscando', exists (select 1 from public.vet_search_consents c
                        where c.pet_id = p_pet and c.revoked_at is null),
    'preguntar', not exists (select 1 from public.vet_search_consents c
                             where c.pet_id = p_pet
                               and (c.revoked_at is null or c.snoozed_until > now()))
                 and not exists (select 1 from public.pet_vet_shares s
                                 where s.pet_id = p_pet and s.revoked_at is null)
  )
  where exists (select 1 from public.pets where id = p_pet and owner_id = (select auth.uid()));
$$;

-- Para la veterinaria (módulo socios activo): cuántas mascotas buscan
-- veterinaria cerca, por especie, solo si son 5 o más (anónimo).
create function public.demanda_de_veterinaria(p_business uuid, p_radio_km smallint default 2)
returns table (species_id smallint, cantidad integer)
language plpgsql stable security definer set search_path = ''
as $$
declare
  punto extensions.geography;
begin
  if not public.soy_duenio_de(p_business) or not public.modulo_activo(p_business, 'socios') then
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

-- Mandar una propuesta: llega a cada mascota que busca cerca y que este mes
-- recibió menos de 3 (entre todas las veterinarias). Devuelve a cuántas.
create function public.enviar_propuesta_veterinaria(p_business uuid, p_mensaje text,
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
  if not public.soy_duenio_de(p_business) or not public.modulo_activo(p_business, 'socios') then
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
    and not exists (select 1 from public.pet_vet_shares s where s.pet_id = p.id and s.business_id = p_business)
    and (select count(*) from public.vet_proposal_deliveries d
         where d.pet_id = p.id and d.created_at > date_trunc('month', now())) < 3;
  get diagnostics n = row_count;
  return n;
end;
$$;

-- Resultados de mis propuestas (enviadas, vistas, aceptadas).
create function public.resultados_propuestas(p_business uuid)
returns table (id uuid, message text, created_at timestamptz, enviadas integer, vistas integer, aceptadas integer)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_business) then
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

-- Bandeja "Propuestas para Toby" (el dueño).
create function public.propuestas_para(p_pet uuid)
returns table (proposal_id uuid, business_id uuid, negocio text, message text, status text, created_at timestamptz)
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = (select auth.uid())) then
    raise exception 'Solo el dueño' using errcode = '42501';
  end if;
  update public.vet_proposal_deliveries set status = 'seen'
   where pet_id = p_pet and status = 'sent';
  return query
  select d.proposal_id, v.business_id, b.name, v.message, d.status, d.created_at
  from public.vet_proposal_deliveries d
  join public.vet_proposals v on v.id = d.proposal_id
  join public.businesses b on b.id = v.business_id
  where d.pet_id = p_pet
  order by d.created_at desc;
end;
$$;

-- Aceptar (la mascota pasa a ser socia: se comparte con esa veterinaria) o
-- rechazar una propuesta.
create function public.responder_propuesta(p_proposal uuid, p_pet uuid, p_acepto boolean)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  negocio uuid;
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = (select auth.uid())) then
    raise exception 'Solo el dueño' using errcode = '42501';
  end if;
  update public.vet_proposal_deliveries
     set status = case when p_acepto then 'accepted' else 'declined' end, answered_at = now()
   where proposal_id = p_proposal and pet_id = p_pet and status in ('sent', 'seen');
  if not found then raise exception 'No existe o ya respondiste' using errcode = 'P0002'; end if;
  select business_id into negocio from public.vet_proposals where id = p_proposal;
  if p_acepto then
    insert into public.pet_vet_shares (pet_id, business_id) values (p_pet, negocio)
    on conflict (pet_id, business_id) do update set consent_at = now(), revoked_at = null;
  end if;
  return negocio;
end;
$$;

-- Admin: poner el plan de un comercio (hasta que haya cobros, 2.2).
create function public.admin_plan_comercio(p_business uuid, p_plan text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_plan not in ('basic', 'featured', 'plus') then
    raise exception 'Plan inválido' using errcode = '22023';
  end if;
  update public.businesses set plan = p_plan where id = p_business;
  perform public.registrar_accion('plan_comercio', 'business', p_business::text, jsonb_build_object('plan', p_plan));
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'modulo_activo(uuid, text)', 'prender_modulo(uuid, text, boolean)',
    'compartir_con_veterinaria(uuid, uuid, boolean)', 'mis_socios(uuid)',
    'recordar_a_socio(uuid, uuid, text, timestamptz)', 'busco_veterinaria(uuid, boolean)',
    'ahora_no_busco_veterinaria(uuid)', 'estado_busco_veterinaria(uuid)',
    'demanda_de_veterinaria(uuid, smallint)', 'enviar_propuesta_veterinaria(uuid, text, smallint, smallint)',
    'resultados_propuestas(uuid)', 'propuestas_para(uuid)', 'responder_propuesta(uuid, uuid, boolean)',
    'admin_plan_comercio(uuid, text)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
