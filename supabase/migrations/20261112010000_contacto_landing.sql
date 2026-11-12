-- 0.8.6d (D156, D158): formulario de contacto de la landing (huellamy.com).
-- Quien escribe deja nombre, correo, si es dueño o comercio y el mensaje; no
-- se muestran teléfonos. Los mensajes entran SOLO por la Edge Function
-- `landing-contact` (anti-bots y límite por dispositivo, con la clave de
-- servicio): desde afuera nadie puede leer, insertar ni borrar. Los lee la
-- administración y ventas en el portal → Contactos.
create table public.contact_messages (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null check (kind in ('owner', 'business', 'other')),
  name        text not null check (char_length(trim(name)) between 2 and 80),
  email       text not null check (char_length(email) <= 120
                                   and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  business    text check (char_length(business) <= 80),        -- nombre del comercio
  message     text not null check (char_length(trim(message)) between 5 and 2000),
  status      text not null default 'new' check (status in ('new', 'answered', 'archived')),
  device_hash text check (char_length(device_hash) = 64),      -- solo para el límite
  handled_by  uuid references auth.users (id) on delete set null,
  handled_at  timestamptz,
  created_at  timestamptz not null default now()
);

comment on table public.contact_messages is
  'Mensajes del formulario de la landing (D158). Entran por la Edge Function landing-contact.';

create index contact_messages_estado_idx on public.contact_messages (status, created_at desc);
create index contact_messages_dispositivo_idx on public.contact_messages (device_hash, created_at);

-- Quién y cuándo lo atendió (no lo manda el portal: lo pone la base).
create function public.contacto_atendido()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status is distinct from old.status then
    new.handled_by := (select auth.uid());
    new.handled_at := now();
  end if;
  return new;
end;
$$;

revoke all on function public.contacto_atendido() from public, anon, authenticated;

create trigger contact_messages_atendido
  before update on public.contact_messages
  for each row execute function public.contacto_atendido();

alter table public.contact_messages enable row level security;

-- Administración y ventas (D109) ven los mensajes y cambian el estado. No
-- tienen zona (llegan de la landing), así que ventas los ve todos.
create policy "equipo_ve_contactos" on public.contact_messages for select to authenticated
  using (public.es_equipo(array['sales']));
create policy "equipo_atiende_contactos" on public.contact_messages for update to authenticated
  using (public.es_equipo(array['sales']))
  with check (public.es_equipo(array['sales']));

revoke all on public.contact_messages from anon, authenticated;
grant select on public.contact_messages to authenticated;
grant update (status) on public.contact_messages to authenticated;
