-- Paso 0.7.1: comercios (versión mínima de la Fase 0: veterinarias de urgencia
-- cargadas a mano). El resto de las columnas de docs/09-modelo-datos.md
-- (dueño, plan, RUT, promociones…) se suma en la Fase 1 con el portal (D59).
-- Nadie lee ni escribe la tabla directo: el mapa usa comercios_en_zona(), que
-- devuelve solo los activos de la zona visible y solo los campos públicos.

create table public.businesses (
  id            uuid primary key default gen_random_uuid(),
  business_type text not null default 'vet' check (business_type in ('vet')),
  name          text not null check (char_length(trim(name)) between 2 and 80),
  description   text check (char_length(description) <= 500),
  address       text check (char_length(address) <= 120),
  location      extensions.geography(point, 4326) not null,
  zone_id       smallint references public.zones (id),
  -- Teléfono del local (dato público del comercio, no de una persona).
  phone         text check (phone ~ '^\+?[0-9 ]{6,20}$'),
  whatsapp      text check (whatsapp ~ '^\+?[0-9 ]{6,20}$'),
  web           text check (web ~ '^https://' and char_length(web) <= 200),
  instagram     text check (instagram ~ '^[A-Za-z0-9._]{1,30}$'),
  -- Horario por día: {"mon": [["09:00","13:00"],["15:00","19:00"]], ...};
  -- un día que no está, cerrado. Lo valida horario_valido().
  hours         jsonb not null default '{}'::jsonb,
  is_24h        boolean not null default false,
  emergencies   boolean not null default false,   -- atiende urgencias
  species_ids   smallint[] not null default '{}',
  verification  text not null default 'unverified'
                check (verification in ('unverified', 'pending', 'verified')),
  status        text not null default 'active' check (status in ('active', 'hidden')),
  -- Veterinarias de ejemplo (solo dev): se borran al cargar las reales.
  is_sample     boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table public.businesses is 'Comercios. Sin acceso directo: se leen con comercios_en_zona().';

-- Valida el formato del horario: días conocidos, franjas "HH:MM"-"HH:MM".
create function public.horario_valido(h jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select jsonb_typeof(h) = 'object'
     and not exists (
       select 1 from jsonb_each(h) d
       where d.key not in ('mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun')
          or jsonb_typeof(d.value) <> 'array'
          or exists (
            select 1 from jsonb_array_elements(d.value) f
            where jsonb_typeof(f) <> 'array'
               or jsonb_array_length(f) <> 2
               or not (f ->> 0 ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$')
               or not (f ->> 1 ~ '^([01][0-9]|2[0-4]):[0-5][0-9]$')
          )
     );
$$;

alter table public.businesses
  add constraint businesses_hours_valido check (public.horario_valido(hours));

create index businesses_location_idx on public.businesses using gist (location);
create index businesses_zone_idx on public.businesses (zone_id, business_type) where status = 'active';

create trigger businesses_updated_at
  before update on public.businesses
  for each row execute function public.set_updated_at();

alter table public.businesses enable row level security;
-- Sin políticas a propósito: hasta el panel de administración (Fase 1) se
-- cargan desde la base (supabase/cargar_comercios.py).
revoke all on public.businesses from anon, authenticated;

-- Comercios activos dentro del rectángulo visible del mapa (regla de costo:
-- solo la zona visible), con los datos públicos de la ficha.
create function public.comercios_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision,
  p_tipo text default 'vet'
)
returns table (
  id uuid, business_type text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text,
  web text, instagram text, hours jsonb, is_24h boolean, emergencies boolean,
  species_ids smallint[], verified boolean, is_sample boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.business_type, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.hours, b.is_24h, b.emergencies,
         b.species_ids, b.verification = 'verified', b.is_sample
  from public.businesses b
  where b.status = 'active'
    and b.business_type = p_tipo
    and b.location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by b.emergencies desc, b.is_24h desc, b.name
  limit 300;
$$;

revoke execute on function public.comercios_en_zona(double precision, double precision, double precision, double precision, text) from public;
grant execute on function public.comercios_en_zona(double precision, double precision, double precision, double precision, text) to anon, authenticated;
