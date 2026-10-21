-- Paso 2.10a (D90): servicios del comercio ("Baño y corte", "Consulta",
-- "Paseo de 1 h"). Detrás de la funcionalidad `catalogo` en la app.
--  · Se cargan y se publican solo con el plan Plus (cualquier rubro). Si el
--    plan baja, dejan de verse solos (no se borran).
--  · Lo ve cualquiera, también visitantes (D84). Un servicio sin precio se
--    "Consulta" (chat o WhatsApp, como el catálogo).
--  · La tabla no se lee directo: todo pasa por funciones.

create table public.business_services (
  id            uuid primary key default gen_random_uuid(),
  business_id   uuid not null references public.businesses (id) on delete cascade,
  name          text not null check (char_length(trim(name)) between 2 and 80),
  description   text check (char_length(description) <= 500),
  price         numeric(10, 2) check (price is null or (price >= 0 and price <= 1000000)),  -- null: "Consultar precio"
  price_from    boolean not null default false,                                           -- "desde $ X"
  duration_min  smallint check (duration_min between 5 and 1440),
  species_ids   smallint[] not null default '{}',
  available     boolean not null default true,
  sort          smallint not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (price is not null or not price_from)
);

comment on table public.business_services is
  'Servicios de un comercio (2.10a, D90). Sin acceso directo: servicios_de(), mis_servicios(), guardar_servicio().';

create index business_services_business_idx on public.business_services (business_id, sort, name);

create trigger business_services_updated_at
  before update on public.business_services
  for each row execute function public.set_updated_at();

alter table public.business_services enable row level security;
-- Sin políticas a propósito: se usa con las funciones de abajo.
revoke all on public.business_services from anon, authenticated;

-- Lo que se muestra al público: lo disponible de un comercio activo con Plus.
create function public.servicios_de(p_negocio uuid)
returns table (id uuid, name text, description text, price numeric, price_from boolean,
               duration_min smallint, species_ids smallint[])
language sql stable security definer set search_path = ''
as $$
  select s.id, s.name, s.description, s.price, s.price_from, s.duration_min, s.species_ids
  from public.business_services s
  join public.businesses b on b.id = s.business_id
  where s.business_id = p_negocio and s.available
    and b.plan = 'plus' and b.status = 'active'
  order by s.sort, s.name
  limit 100;
$$;

-- El dueño ve todo (también lo no disponible), tenga o no el plan.
create function public.mis_servicios(p_negocio uuid)
returns table (id uuid, name text, description text, price numeric, price_from boolean,
               duration_min smallint, species_ids smallint[], available boolean, sort smallint)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select s.id, s.name, s.description, s.price, s.price_from, s.duration_min, s.species_ids,
         s.available, s.sort
  from public.business_services s
  where s.business_id = p_negocio
  order by s.sort, s.name;
end;
$$;

-- Crea (sin `id`) o actualiza un servicio. Hace falta el plan Plus.
create function public.guardar_servicio(p_negocio uuid, p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not exists (select 1 from public.businesses where id = p_negocio and plan = 'plus') then
    raise exception 'Los servicios necesitan el plan Plus' using errcode = '42501';
  end if;
  if id_ is null then
    if (select count(*) from public.business_services where business_id = p_negocio) >= 50 then
      raise exception 'Máximo 50 servicios' using errcode = '54000';
    end if;
    insert into public.business_services (business_id, name, description, price, price_from,
                                          duration_min, species_ids, available, sort)
    values (p_negocio, trim(p ->> 'name'), nullif(trim(p ->> 'description'), ''),
            (p ->> 'price')::numeric, coalesce((p ->> 'price_from')::boolean, false),
            (p ->> 'duration_min')::smallint,
            coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
            coalesce((p ->> 'available')::boolean, true), coalesce((p ->> 'sort')::smallint, 0))
    returning id into id_;
  else
    update public.business_services set
      name = trim(p ->> 'name'), description = nullif(trim(p ->> 'description'), ''),
      price = (p ->> 'price')::numeric, price_from = coalesce((p ->> 'price_from')::boolean, false),
      duration_min = (p ->> 'duration_min')::smallint,
      species_ids = coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
      available = coalesce((p ->> 'available')::boolean, true),
      sort = coalesce((p ->> 'sort')::smallint, sort)
    where id = id_ and business_id = p_negocio;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  end if;
  return id_;
end;
$$;

create function public.borrar_servicio(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.business_services s
  where s.id = p_id and public.soy_duenio_de(s.business_id);
  if not found then raise exception 'No es tuyo' using errcode = '42501'; end if;
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array['mis_servicios(uuid)', 'guardar_servicio(uuid, jsonb)', 'borrar_servicio(uuid)'] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

revoke all on function public.servicios_de(uuid) from public;
grant execute on function public.servicios_de(uuid) to anon, authenticated;
