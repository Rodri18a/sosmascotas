-- Paso 1.5.5: "✅ Ya se la di" + historial. Una fila por toma marcada.
-- La única por (recordatorio, toma) evita la dosis doble cuando el hogar
-- compartido (1.6) deje marcar a varias personas: la segunda falla.
-- Privado como el recordatorio: solo el dueño de la mascota.

create table public.reminder_logs (
  id           uuid primary key default gen_random_uuid(),
  reminder_id  uuid not null references public.reminders (id) on delete cascade,
  due_at       timestamptz not null,                     -- la toma que se marcó
  done_by      uuid default auth.uid() references auth.users (id) on delete set null,
  done_at      timestamptz not null default now()
                 check (done_at <= now() + interval '5 minutes'),
  unique (reminder_id, due_at)
);

comment on table public.reminder_logs is
  'Tomas marcadas ("ya se la di"). Privadas: cada dueño ve solo las de sus mascotas.';

create index reminder_logs_reminder_idx on public.reminder_logs (reminder_id, due_at desc);

alter table public.reminder_logs enable row level security;

create policy "ver_mis_tomas" on public.reminder_logs for select to authenticated
  using (exists (select 1 from public.reminders r join public.pets p on p.id = r.pet_id
                 where r.id = reminder_id and p.owner_id = (select auth.uid())));
-- Solo a mi nombre y en recordatorios de mis mascotas.
create policy "marcar_mis_tomas" on public.reminder_logs for insert to authenticated
  with check (done_by = (select auth.uid())
              and exists (select 1 from public.reminders r join public.pets p on p.id = r.pet_id
                          where r.id = reminder_id and p.owner_id = (select auth.uid())));
-- Deshacer una marca hecha por error. No hay edición: se borra y se vuelve a marcar.
create policy "desmarcar_mis_tomas" on public.reminder_logs for delete to authenticated
  using (exists (select 1 from public.reminders r join public.pets p on p.id = r.pet_id
                 where r.id = reminder_id and p.owner_id = (select auth.uid())));

revoke all on public.reminder_logs from anon;
