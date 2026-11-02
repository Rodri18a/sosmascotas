-- Plan de mejoras 2.1 (D131): historial de vida de cada mascota.
-- Acontecimientos con fecha y tipo (operación, accidente, enfermedad,
-- tratamiento, diagnóstico u otro), una nota y hasta 4 fotos o documentos.
-- Las alergias siguen en la libreta (health_records), para no cargarlas dos veces.
-- Privado como la libreta: lo ven y lo editan quienes pueden cuidar la mascota
-- (el dueño y su hogar, `puedo_cuidar`). Gratis (regla de oro: es salud).

create table public.life_events (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references public.pets (id) on delete cascade,
  kind        text not null check (kind in ('surgery', 'accident', 'illness', 'treatment', 'diagnosis', 'other')),
  title       text not null check (char_length(trim(title)) between 1 and 80),
  date        date not null check (date > '1980-01-01' and date <= current_date + 1),
  notes       text check (char_length(notes) <= 1000),
  -- Rutas dentro del bucket privado pet-records: <pet_id>/<archivo>.
  files       text[] not null default '{}' check (cardinality(files) <= 4),
  created_by  uuid default auth.uid() references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.life_events is
  'Historial de vida (D131). Privado: lo ven quienes pueden cuidar la mascota.';

create index life_events_pet_idx on public.life_events (pet_id, date desc);

alter table public.life_events enable row level security;

create policy "ver_historial" on public.life_events for select to authenticated
  using (public.puedo_cuidar(pet_id));
create policy "cargar_historial" on public.life_events for insert to authenticated
  with check (public.puedo_cuidar(pet_id));
create policy "editar_historial" on public.life_events for update to authenticated
  using (public.puedo_cuidar(pet_id)) with check (public.puedo_cuidar(pet_id));
create policy "borrar_historial" on public.life_events for delete to authenticated
  using (public.puedo_cuidar(pet_id));

revoke all on public.life_events from anon;

-- Los adjuntos tienen que estar en la carpeta de esa misma mascota.
create function public.life_events_archivos_propios()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if exists (select 1 from unnest(new.files) f
             where f !~ ('^' || new.pet_id::text || '/[a-z0-9-]+\.(jpg|png|webp|pdf)$')) then
    raise exception 'Adjunto fuera de la carpeta de la mascota' using errcode = '22023';
  end if;
  return new;
end;
$$;

create trigger life_events_archivos
  before insert or update on public.life_events
  for each row execute function public.life_events_archivos_propios();

create trigger life_events_updated_at
  before update on public.life_events
  for each row execute function public.set_updated_at();

-- =====================================================================
-- ADJUNTOS: bucket privado (fotos sin ubicación EXIF y PDF de hasta 5 MB).
-- Carpeta = id de la mascota; se abren con enlaces firmados que vencen.
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pet-records', 'pet-records', false, 5242880,
        array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- La carpeta tiene que ser un uuid de una mascota que puedo cuidar.
create function public.puedo_cuidar_carpeta(p_nombre text)
returns boolean
language plpgsql stable security definer set search_path = ''
as $$
declare
  carpeta text := (storage.foldername(p_nombre))[1];
begin
  if carpeta !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  return public.puedo_cuidar(carpeta::uuid);
end;
$$;

revoke all on function public.puedo_cuidar_carpeta(text) from public, anon;
grant execute on function public.puedo_cuidar_carpeta(text) to authenticated;

create policy "ver_adjuntos_historial" on storage.objects for select to authenticated
  using (bucket_id = 'pet-records' and public.puedo_cuidar_carpeta(name));
create policy "subir_adjuntos_historial" on storage.objects for insert to authenticated
  with check (bucket_id = 'pet-records' and public.puedo_cuidar_carpeta(name));
create policy "borrar_adjuntos_historial" on storage.objects for delete to authenticated
  using (bucket_id = 'pet-records' and public.puedo_cuidar_carpeta(name));

-- Funcionalidad gradual (D64): prendida para todos (es salud, no se cobra);
-- se puede bajar a beta o apagar con supabase/funcionalidades.py.
insert into public.feature_flags (key, description, stage)
values ('historial', 'Historial de vida de cada mascota (plan de mejoras 2.1, D131)', 'todos')
on conflict (key) do nothing;
