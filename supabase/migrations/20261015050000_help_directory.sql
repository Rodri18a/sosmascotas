-- Paso 0.7.3: directorio de la pestaña Ayuda (refugios, protectoras, grupos de
-- difusión y organismos de la zona). Todo es público: se lee directo con una
-- política de lectura (solo los activos). Nadie escribe desde la app: se carga
-- con supabase/cargar_ayuda.py (D61). El 911 no está acá: va fijo en la app.

create table public.help_directory (
  id          uuid primary key default gen_random_uuid(),
  zone_id     smallint references public.zones (id),
  kind        text not null check (kind in ('refugio', 'protectora', 'grupo', 'organismo')),
  name        text not null check (char_length(trim(name)) between 2 and 80),
  description text check (char_length(description) <= 300),
  phone       text check (phone ~ '^\+?[0-9 ]{3,20}$'),
  whatsapp    text check (whatsapp ~ '^\+?[0-9 ]{6,20}$'),
  link        text check (link ~ '^https://' and char_length(link) <= 300),
  sort        smallint not null default 100,
  status      text not null default 'active' check (status in ('active', 'hidden')),
  -- Datos de ejemplo (solo dev): se borran al cargar los reales.
  is_sample   boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.help_directory is 'Directorio de Ayuda. Público (solo lectura de los activos).';

create index help_directory_zone_idx on public.help_directory (zone_id, kind, sort) where status = 'active';

create trigger help_directory_updated_at
  before update on public.help_directory
  for each row execute function public.set_updated_at();

alter table public.help_directory enable row level security;

create policy "ver_ayuda_activa" on public.help_directory for select
  to anon, authenticated
  using (status = 'active');

revoke all on public.help_directory from anon, authenticated;
grant select on public.help_directory to anon, authenticated;
