-- Paso 0.2.1: perfiles de usuario y contactos privados.
-- Ver docs/09-modelo-datos.md y la regla 7 de CLAUDE.md (contacto inverso).

create type public.user_role as enum ('user', 'admin');
create type public.user_plan as enum ('free', 'pro', 'family');

-- =====================================================================
-- PERFILES: uno por cuenta, creado automáticamente al registrarse.
-- Cada persona ve y edita solo el suyo. El plan y el rol NO se cambian
-- desde la app (los cambia el sistema de pagos o el administrador).
-- =====================================================================
create table public.profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  display_name      text check (char_length(display_name) between 1 and 40),
  avatar_path       text check (char_length(avatar_path) <= 200),
  role              public.user_role not null default 'user',
  plan              public.user_plan not null default 'free',
  zone_id           smallint references public.zones (id),
  prefs             jsonb not null default '{}'::jsonb
                    check (jsonb_typeof(prefs) = 'object' and pg_column_size(prefs) <= 2048),
  alert_radius_km   smallint not null default 5 check (alert_radius_km between 1 and 20),
  terms_version     text check (char_length(terms_version) <= 40),
  terms_accepted_at timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on table public.profiles is 'Perfil de cada cuenta. Privado: cada persona ve solo el suyo.';

alter table public.profiles enable row level security;

create policy "ver_mi_perfil"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()));

create policy "editar_mi_perfil"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Sin políticas de insert/delete: lo crea el trigger y se borra con la cuenta.
revoke all on public.profiles from anon;
revoke insert, update, delete, truncate on public.profiles from authenticated;
-- Solo estas columnas se pueden editar (nunca role ni plan).
grant update (display_name, avatar_path, zone_id, prefs, alert_radius_km, terms_version, terms_accepted_at)
  on public.profiles to authenticated;

-- Mantener updated_at.
create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Crear el perfil al registrarse (nombre tomado de Google o del email).
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, zone_id)
  values (
    new.id,
    left(
      coalesce(
        nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
        nullif(trim(new.raw_user_meta_data ->> 'name'), ''),
        nullif(split_part(new.email, '@', 1), ''),
        'Usuario'
      ),
      40
    ),
    (select id from public.zones where slug = 'pando')
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- CONTACTOS PRIVADOS: teléfono y WhatsApp del dueño.
-- NADIE los lee desde la app: solo las Edge Functions (con la clave secreta).
-- Así el número nunca llega a otros usuarios (contacto inverso, D41).
-- =====================================================================
create table public.private_contacts (
  user_id              uuid primary key references auth.users (id) on delete cascade,
  phone                text check (phone ~ '^\+?[0-9 ]{6,20}$'),
  whatsapp             text check (whatsapp ~ '^\+?[0-9 ]{6,20}$'),
  show_whatsapp_direct boolean not null default false,
  updated_at           timestamptz not null default now()
);

comment on table public.private_contacts is 'Teléfonos de los dueños. Solo accesible desde Edge Functions.';

alter table public.private_contacts enable row level security;
-- Sin políticas a propósito: con RLS activo y sin políticas, nadie accede desde la app.
revoke all on public.private_contacts from anon, authenticated;

create trigger private_contacts_updated_at
  before update on public.private_contacts
  for each row execute function public.set_updated_at();
