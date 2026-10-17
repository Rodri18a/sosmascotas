-- Paso 1.5.1: libreta sanitaria. Vacunas, desparasitaciones, controles,
-- alergias y otros registros de salud de cada mascota.
-- Privada como la mascota: solo el dueño la ve y la edita (el hogar
-- compartido de la etapa 1.6 sumará a sus integrantes).
-- Gratis para todos (regla de oro: la salud del animal no se cobra).

create table public.health_records (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references public.pets (id) on delete cascade,
  kind        text not null check (kind in ('vaccine', 'deworming', 'checkup', 'allergy', 'other')),
  name        text not null check (char_length(trim(name)) between 1 and 80),
  date        date check (date > '1980-01-01' and date <= current_date + 1),
  next_date   date check (next_date > '1980-01-01'),
  notes       text check (char_length(notes) <= 500),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  check (next_date is null or date is null or next_date >= date)
);

comment on table public.health_records is
  'Libreta sanitaria. Privada: cada dueño ve solo la de sus mascotas.';

create index health_records_pet_idx on public.health_records (pet_id, date desc);

alter table public.health_records enable row level security;

-- La mascota tiene que ser mía (pets ya filtra por dueño con su propia RLS).
create policy "ver_mi_libreta" on public.health_records for select to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "cargar_en_mi_libreta" on public.health_records for insert to authenticated
  with check (exists (select 1 from public.pets p
                      where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "editar_mi_libreta" on public.health_records for update to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.pets p
                      where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "borrar_de_mi_libreta" on public.health_records for delete to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())));

revoke all on public.health_records from anon;

create trigger health_records_updated_at
  before update on public.health_records
  for each row execute function public.set_updated_at();
