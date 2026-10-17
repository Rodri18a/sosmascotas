-- Paso 1.5.3: recordatorios (medicación; la comida y las vacunas, en 1.5.4).
-- Privados como la mascota: solo el dueño los ve y los edita (el hogar
-- compartido de la etapa 1.6 sumará a sus integrantes y `assigned_to`).
-- El aviso lo programa cada dispositivo (notificación local): la base solo
-- guarda el recordatorio. Gratis para todos (regla de oro).
--
-- `schedule` (lo valida también packages/core, `Frecuencia`):
--   {"tipo": "cada_horas", "horas": 8}                       desde starts_at
--   {"tipo": "diaria", "horarios": ["08:00", "20:00"]}
--   {"tipo": "semanal", "dias": [1, 4], "horarios": ["09:00"]}   1 = lunes
--   {"tipo": "una_vez"}                                      en starts_at

create table public.reminders (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references public.pets (id) on delete cascade,
  kind        text not null check (kind in ('medication', 'food', 'vaccine', 'checkup')),
  title       text not null check (char_length(trim(title)) between 1 and 80),
  dose        text check (char_length(dose) <= 80),
  schedule    jsonb not null check (
    jsonb_typeof(schedule) = 'object'
    and schedule ->> 'tipo' in ('cada_horas', 'diaria', 'semanal', 'una_vez')
    and pg_column_size(schedule) <= 1000
  ),
  starts_at   timestamptz not null,
  ends_on     date,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  check (ends_on is null or ends_on >= (starts_at at time zone 'America/Montevideo')::date)
);

comment on table public.reminders is
  'Recordatorios de medicación, comida y vacunas. Privados: cada dueño ve solo los de sus mascotas.';

create index reminders_pet_idx on public.reminders (pet_id, created_at);

alter table public.reminders enable row level security;

create policy "ver_mis_recordatorios" on public.reminders for select to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "crear_mis_recordatorios" on public.reminders for insert to authenticated
  with check (exists (select 1 from public.pets p
                      where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "editar_mis_recordatorios" on public.reminders for update to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.pets p
                      where p.id = pet_id and p.owner_id = (select auth.uid())));
create policy "borrar_mis_recordatorios" on public.reminders for delete to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())));

revoke all on public.reminders from anon;

create trigger reminders_updated_at
  before update on public.reminders
  for each row execute function public.set_updated_at();
