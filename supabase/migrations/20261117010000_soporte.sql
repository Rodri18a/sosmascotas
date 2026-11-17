-- 0.8.6b (D160): canal de soporte para el lanzamiento.
--
-- 1. `app_settings`: datos PÚBLICOS de la plataforma que se cambian sin
--    compilar (por ahora, cómo contactar a soporte). Todo lo que se guarda
--    acá lo puede leer cualquiera: nunca secretos ni datos de personas.
--    El WhatsApp de soporte se suma después con una fila `support_whatsapp`
--    y la app lo muestra solo si existe.
-- 2. Los mensajes de soporte que se mandan desde la app («Escribinos») van a
--    `contact_messages` con kind = 'support', a nombre de la cuenta. Los ven
--    la administración y moderación; ventas sigue viendo solo los de la
--    landing.

-- ---------------------------------------------------------------- 1. ajustes
create table public.app_settings (
  key        text primary key check (key ~ '^[a-z_]{3,40}$'),
  value      text not null check (char_length(value) between 1 and 200),
  updated_at timestamptz not null default now()
);

comment on table public.app_settings is
  'Datos públicos de la plataforma (D160), por ejemplo el contacto de soporte. Los lee cualquiera: nunca secretos.';

alter table public.app_settings enable row level security;

create policy "todos_leen_ajustes_publicos" on public.app_settings for select
  to anon, authenticated
  using (true);

revoke all on public.app_settings from anon, authenticated;
grant select on public.app_settings to anon, authenticated;

insert into public.app_settings (key, value) values
  ('support_email', 'soporte@huellamy.com');

-- ------------------------------------------------- 2. mensajes de soporte
alter table public.contact_messages
  drop constraint contact_messages_kind_check;
alter table public.contact_messages
  add constraint contact_messages_kind_check
  check (kind in ('owner', 'business', 'other', 'support'));

-- Quién lo mandó (solo los de soporte). Si borra la cuenta, se borran sus
-- mensajes de soporte con su nombre y su correo.
alter table public.contact_messages
  add column user_id uuid references auth.users (id) on delete cascade;
alter table public.contact_messages
  add constraint contact_messages_soporte_con_cuenta
  check ((kind = 'support') = (user_id is not null));

create index contact_messages_usuario_idx
  on public.contact_messages (user_id, created_at)
  where user_id is not null;

comment on table public.contact_messages is
  'Mensajes de la landing (D158, entran por la Edge Function landing-contact) y de soporte desde la app (D160, por enviar_soporte).';

-- Soporte: administración y moderación. Landing: administración y ventas.
drop policy "equipo_ve_contactos" on public.contact_messages;
drop policy "equipo_atiende_contactos" on public.contact_messages;

create policy "equipo_ve_contactos" on public.contact_messages for select to authenticated
  using (
    case when kind = 'support' then public.es_equipo(array['moderator'])
         else public.es_equipo(array['sales']) end
  );
create policy "equipo_atiende_contactos" on public.contact_messages for update to authenticated
  using (
    case when kind = 'support' then public.es_equipo(array['moderator'])
         else public.es_equipo(array['sales']) end
  )
  with check (
    case when kind = 'support' then public.es_equipo(array['moderator'])
         else public.es_equipo(array['sales']) end
  );

-- «Escribinos» desde la app: solo con sesión. El nombre y el correo los pone
-- la base (los de la cuenta), así nadie escribe a nombre de otro. Hasta 5
-- mensajes por hora por cuenta.
create function public.enviar_soporte(p_mensaje text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := (select auth.uid());
  v_mensaje text := trim(coalesce(p_mensaje, ''));
  v_correo  text;
  v_nombre  text;
begin
  if v_uid is null then
    raise exception 'Hay que ingresar' using errcode = '42501';
  end if;
  if char_length(v_mensaje) not between 5 and 2000 then
    raise exception 'El mensaje tiene que tener entre 5 y 2000 letras' using errcode = '22023';
  end if;
  if (select count(*) from public.contact_messages
      where user_id = v_uid and created_at > now() - interval '1 hour') >= 5 then
    raise exception 'demasiados_mensajes' using errcode = 'P0001';
  end if;

  select lower(u.email) into v_correo from auth.users u where u.id = v_uid;
  if v_correo is null or v_correo !~* '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'La cuenta no tiene un correo para responderte' using errcode = '22023';
  end if;
  select coalesce(nullif(trim(p.display_name), ''), split_part(v_correo, '@', 1))
    into v_nombre from public.profiles p where p.id = v_uid;
  v_nombre := left(coalesce(v_nombre, split_part(v_correo, '@', 1)), 80);
  if char_length(v_nombre) < 2 then
    v_nombre := v_nombre || '.';  -- el nombre pide al menos 2 letras
  end if;

  insert into public.contact_messages (kind, name, email, message, user_id)
  values ('support', v_nombre, v_correo, v_mensaje, v_uid);
end;
$$;

revoke all on function public.enviar_soporte(text) from public, anon;
grant execute on function public.enviar_soporte(text) to authenticated;
