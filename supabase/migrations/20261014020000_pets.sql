-- Paso 0.3.2: mascotas y bucket de fotos.
-- Cada dueño ve y maneja solo sus mascotas. Lo público (página del QR, SOS) se
-- expone con funciones específicas que devuelven solo lo que el dueño eligió.

create type public.pet_sex as enum ('male', 'female', 'unknown');

create table public.pets (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null check (char_length(trim(name)) between 1 and 40),
  species_id  smallint not null references public.species (id),
  breed_id    integer,
  breed_other text check (char_length(breed_other) <= 60),
  sex         public.pet_sex not null default 'unknown',
  color       text check (char_length(color) <= 60),
  marks       text check (char_length(marks) <= 300),        -- señas particulares
  birth       date check (birth > '1980-01-01' and birth <= current_date),
  photo_path  text check (char_length(photo_path) <= 200),
  microchip   text check (microchip ~ '^[0-9]{15}$'),          -- ISO 11784: 15 dígitos
  neutered    boolean,
  notes       text check (char_length(notes) <= 1000),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- La raza tiene que ser de la misma especie.
  foreign key (species_id, breed_id) references public.breeds (species_id, id)
);

comment on table public.pets is 'Mascotas. Privadas: cada dueño ve solo las suyas.';

create index pets_owner_idx on public.pets (owner_id, created_at);

alter table public.pets enable row level security;

create policy "ver_mis_mascotas" on public.pets for select to authenticated
  using (owner_id = (select auth.uid()));
create policy "crear_mis_mascotas" on public.pets for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy "editar_mis_mascotas" on public.pets for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "borrar_mis_mascotas" on public.pets for delete to authenticated
  using (owner_id = (select auth.uid()));

revoke all on public.pets from anon;

create trigger pets_updated_at
  before update on public.pets
  for each row execute function public.set_updated_at();

-- =====================================================================
-- FOTOS: bucket público de lectura (las fotos aparecen en la página del QR y
-- en los SOS), con nombres al azar imposibles de adivinar. Solo JPEG/WebP de
-- hasta 2 MB (la app las comprime a ~200 KB y les quita la ubicación EXIF).
-- Cada usuario sube solo dentro de su carpeta: <user_id>/<archivo>.
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pet-photos', 'pet-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_de_mis_mascotas" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "cambiar_fotos_de_mis_mascotas" on storage.objects for update to authenticated
  using (bucket_id = 'pet-photos' and owner_id = (select auth.uid())::text)
  with check (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "borrar_fotos_de_mis_mascotas" on storage.objects for delete to authenticated
  using (bucket_id = 'pet-photos' and owner_id = (select auth.uid())::text);
