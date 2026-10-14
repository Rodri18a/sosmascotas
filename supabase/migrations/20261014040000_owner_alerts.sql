-- Paso 0.4.4: contacto inverso (D41). Quien encuentra a una mascota le deja un
-- aviso al dueño con SU contacto; el dueño decide si responde. El teléfono del
-- dueño nunca sale. Los avisos los crea solo la Edge Function `owner-alert`
-- (anti-bots + límites); el dueño los lee y cambia su estado desde la app.

create type public.alert_target as enum ('qr', 'sos');
create type public.alert_status as enum ('new', 'seen', 'replied', 'scam_reported');

create table public.owner_alerts (
  id             uuid primary key default gen_random_uuid(),
  target_type    public.alert_target not null,
  target_id      uuid not null,                       -- qr_tags.id o sos_reports.id
  owner_id       uuid not null references auth.users (id) on delete cascade,
  pet_id         uuid references public.pets (id) on delete set null,
  from_user_id   uuid references auth.users (id) on delete set null,
  sender_name    text not null check (char_length(trim(sender_name)) between 1 and 60),
  sender_contact text not null check (char_length(trim(sender_contact)) between 6 and 80),  -- solo lo ve el dueño
  message        text not null check (char_length(trim(message)) between 1 and 1000),
  photo_path     text check (char_length(photo_path) <= 200),
  location       extensions.geography(point, 4326),   -- solo si quien avisa la compartió
  device_hash    text not null check (char_length(device_hash) = 64),
  status         public.alert_status not null default 'new',
  created_at     timestamptz not null default now()
);

comment on table public.owner_alerts is 'Avisos al dueño (contacto inverso). Solo los ve el dueño; los crea la Edge Function owner-alert.';

create index owner_alerts_owner_idx on public.owner_alerts (owner_id, created_at desc);
create index owner_alerts_device_idx on public.owner_alerts (device_hash, created_at);
create index owner_alerts_target_idx on public.owner_alerts (target_id, created_at);

alter table public.owner_alerts enable row level security;

create policy "ver_mis_avisos" on public.owner_alerts for select to authenticated
  using (owner_id = (select auth.uid()));
create policy "cambiar_estado_de_mis_avisos" on public.owner_alerts for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "borrar_mis_avisos" on public.owner_alerts for delete to authenticated
  using (owner_id = (select auth.uid()));

revoke all on public.owner_alerts from anon;
revoke insert, update, truncate on public.owner_alerts from authenticated;
grant update (status) on public.owner_alerts to authenticated;

-- Para que la app muestre la ubicación compartida sin tocar PostGIS.
create view public.owner_alerts_app
with (security_invoker = true) as
select a.id, a.target_type, a.target_id, a.pet_id, a.sender_name, a.sender_contact,
       a.message, a.photo_path, a.status, a.created_at,
       extensions.st_y(a.location::extensions.geometry) as lat,
       extensions.st_x(a.location::extensions.geometry) as lng
from public.owner_alerts a;

grant select on public.owner_alerts_app to authenticated;
revoke all on public.owner_alerts_app from anon;

-- =====================================================================
-- REMITENTES BLOQUEADOS: cuando el dueño marca un aviso como estafa, ese
-- dispositivo ya no le puede mandar más avisos (sin avisarle, para no darle pistas).
-- =====================================================================
create table public.blocked_senders (
  owner_id    uuid not null references auth.users (id) on delete cascade,
  device_hash text not null,
  created_at  timestamptz not null default now(),
  primary key (owner_id, device_hash)
);

alter table public.blocked_senders enable row level security;
-- Sin políticas: solo la usa la Edge Function.
revoke all on public.blocked_senders from anon, authenticated;

create function public.bloquear_remitente_estafa()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'scam_reported' and old.status is distinct from 'scam_reported' then
    insert into public.blocked_senders (owner_id, device_hash)
    values (new.owner_id, new.device_hash)
    on conflict do nothing;
  end if;
  return new;
end;
$$;

revoke execute on function public.bloquear_remitente_estafa() from public, anon, authenticated;

create trigger owner_alerts_bloquear_estafa
  after update of status on public.owner_alerts
  for each row execute function public.bloquear_remitente_estafa();
