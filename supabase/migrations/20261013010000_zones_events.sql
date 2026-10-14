-- Paso 0.1.7: zonas (empezando por Pando) y eventos de métricas.
-- Ver docs/09-modelo-datos.md y docs/08-arquitectura.md (sección Métricas).

-- =====================================================================
-- ZONAS: regiones donde opera la app. Las lee cualquiera; solo el
-- administrador las crea o cambia (desde el panel o con la clave secreta).
-- =====================================================================
create table public.zones (
  id         smallint generated always as identity primary key,
  slug       text not null unique check (slug ~ '^[a-z0-9-]{2,40}$'),
  name       text not null,
  country    char(2) not null,          -- ISO 3166-1 (UY)
  timezone   text not null,             -- IANA (America/Montevideo)
  currency   char(3) not null,          -- ISO 4217 (UYU)
  area       extensions.geography(multipolygon, 4326) not null,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

comment on table public.zones is 'Zonas donde opera SOS Mascota (arranca en Pando).';

create index zones_area_idx on public.zones using gist (area);

alter table public.zones enable row level security;

-- Visitantes y usuarios ven solo las zonas activas.
create policy "zonas_activas_visibles"
  on public.zones for select
  to anon, authenticated
  using (active);

-- Desde la app solo se puede leer.
revoke insert, update, delete, truncate on public.zones from anon, authenticated;

-- Pando y alrededores (rectángulo aproximado; se ajusta con el uso real).
insert into public.zones (slug, name, country, timezone, currency, area)
values (
  'pando',
  'Pando y alrededores',
  'UY',
  'America/Montevideo',
  'UYU',
  extensions.st_geogfromtext(
    'SRID=4326;MULTIPOLYGON(((-56.08 -34.82, -55.83 -34.82, -55.83 -34.62, -56.08 -34.62, -56.08 -34.82)))'
  )
);

-- =====================================================================
-- EVENTOS: métricas anónimas (append-only). La app solo puede AGREGAR;
-- nadie los lee desde la app. Los lee el administrador (Fase 1, portal).
-- =====================================================================
create table public.events (
  id          bigint generated always as identity primary key,
  name        text not null check (name ~ '^[a-z][a-z0-9_]{1,62}$'),
  anon_id     uuid not null,             -- id al azar por instalación (no identifica a la persona)
  user_id     uuid references auth.users (id) on delete set null,  -- solo métricas internas
  zone_id     smallint references public.zones (id),
  business_id uuid,                      -- FK a businesses cuando exista (0.7.1)
  target_id   text check (char_length(target_id) <= 64),
  platform    text check (platform in ('web', 'android', 'ios')),
  props       jsonb not null default '{}'::jsonb
              check (jsonb_typeof(props) = 'object' and pg_column_size(props) <= 2048),
  created_at  timestamptz not null default now()
);

comment on table public.events is 'Eventos de métricas (append-only). A las empresas solo se les muestran agregados.';

create index events_name_created_idx on public.events (name, created_at);
create index events_zone_created_idx on public.events (zone_id, created_at);
create index events_business_created_idx on public.events (business_id, created_at)
  where business_id is not null;

alter table public.events enable row level security;

-- Cualquiera (con o sin cuenta) puede registrar un evento, pero no a nombre de otro:
-- sin sesión, user_id va vacío; con sesión, solo el propio.
create policy "registrar_eventos_propios"
  on public.events for insert
  to anon, authenticated
  with check (user_id is null or user_id = (select auth.uid()));

-- Sin políticas de select/update/delete: desde la app no se leen, cambian ni borran.
revoke select, update, delete, truncate on public.events from anon, authenticated;

-- Solo estas columnas se pueden enviar (id y created_at los pone la base).
revoke insert on public.events from anon, authenticated;
grant insert (name, anon_id, user_id, zone_id, business_id, target_id, platform, props)
  on public.events to anon, authenticated;
