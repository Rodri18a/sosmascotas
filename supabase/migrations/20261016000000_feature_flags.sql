-- Paso 0.8.0b: habilitación gradual de funcionalidades (D64).
-- Ver docs/15-funcionalidades-graduales.md. Las tablas no se leen ni escriben
-- desde la app (los nombres revelan la hoja de ruta): se cambian con la clave
-- secreta (supabase/funcionalidades.py, 0.8.0e) y, en la Fase 1, desde el panel.
-- La app pregunta con mis_funcionalidades() y funcionalidad_activa(), que
-- también pueden usar las políticas de RLS y las Edge Functions.

-- =====================================================================
-- MARCAS: una por funcionalidad.
-- =====================================================================
create table public.feature_flags (
  key             text primary key check (key ~ '^[a-z][a-z0-9_]{2,40}$'),
  description     text not null check (char_length(trim(description)) between 3 and 300),
  stage           text not null default 'borrador'
                  check (stage in ('borrador', 'interna', 'beta', 'gradual', 'todos')),
  killed          boolean not null default false,          -- apagado de emergencia
  rollout_percent smallint not null default 0 check (rollout_percent between 0 and 100),
  -- Reglas de la etapa 'gradual' (null = sin restricción).
  zone_ids        smallint[],
  plans           text[] check (plans <@ array['free', 'pro', 'family', 'basic', 'featured', 'plus']),
  roles           text[] check (roles <@ array['user', 'business', 'admin']),
  platforms       text[] check (platforms <@ array['web', 'android', 'ios']),
  min_app_version text check (min_app_version ~ '^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$'),
  allow_anonymous boolean not null default false,          -- ¿los visitantes sin cuenta la ven?
  starts_at       timestamptz,                             -- prendido programado
  ends_at         timestamptz,                             -- apagado programado
  updated_by      uuid references auth.users (id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (starts_at is null or ends_at is null or starts_at < ends_at)
);

comment on table public.feature_flags is 'Habilitación gradual (D64). Sin acceso desde la app: se consulta con funcionalidad_activa().';

create trigger feature_flags_updated_at
  before update on public.feature_flags
  for each row execute function public.set_updated_at();

-- =====================================================================
-- BETA: personas invitadas (o excluidas) a mano.
-- =====================================================================
create table public.feature_flag_users (
  flag_key   text not null references public.feature_flags (key) on delete cascade on update cascade,
  user_id    uuid not null references auth.users (id) on delete cascade,
  enabled    boolean not null default true,   -- false = excluida aunque le toque por porcentaje
  created_at timestamptz not null default now(),
  primary key (flag_key, user_id)
);

comment on table public.feature_flag_users is 'Invitadas (enabled) o excluidas (not enabled) de cada funcionalidad.';

create index feature_flag_users_user_idx on public.feature_flag_users (user_id);

-- =====================================================================
-- HISTORIAL: quién cambió qué y cuándo. Lo escribe solo el trigger.
-- =====================================================================
create table public.feature_flag_audit (
  id         bigint generated always as identity primary key,
  flag_key   text not null,
  tabla      text not null check (tabla in ('feature_flags', 'feature_flag_users')),
  changed_by uuid,
  before     jsonb,
  after      jsonb,
  created_at timestamptz not null default now()
);

comment on table public.feature_flag_audit is 'Historial de cambios de las funcionalidades.';

create index feature_flag_audit_key_idx on public.feature_flag_audit (flag_key, created_at);

create function public.registrar_cambio_funcionalidad()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  antes   jsonb := case when tg_op <> 'INSERT' then to_jsonb(old) end;
  despues jsonb := case when tg_op <> 'DELETE' then to_jsonb(new) end;
begin
  insert into public.feature_flag_audit (flag_key, tabla, changed_by, before, after)
  values (
    coalesce(despues ->> 'key', despues ->> 'flag_key', antes ->> 'key', antes ->> 'flag_key'),
    tg_table_name,
    coalesce((select auth.uid()), (despues ->> 'updated_by')::uuid),
    antes,
    despues
  );
  return null;
end;
$$;

revoke execute on function public.registrar_cambio_funcionalidad() from public, anon, authenticated;

create trigger feature_flags_audit
  after insert or update or delete on public.feature_flags
  for each row execute function public.registrar_cambio_funcionalidad();

create trigger feature_flag_users_audit
  after insert or update or delete on public.feature_flag_users
  for each row execute function public.registrar_cambio_funcionalidad();

-- Sin acceso desde la app: RLS activo y sin políticas.
alter table public.feature_flags enable row level security;
alter table public.feature_flag_users enable row level security;
alter table public.feature_flag_audit enable row level security;
revoke all on public.feature_flags, public.feature_flag_users, public.feature_flag_audit
  from anon, authenticated;

-- =====================================================================
-- PORCENTAJE ESTABLE: 0..99 a partir de la clave y del id (de la cuenta o,
-- sin cuenta, el anon_id de métricas). Los primeros 8 caracteres hex del MD5
-- de 'clave:id' como entero sin signo, módulo 100. packages/core hace la
-- misma cuenta (0.8.0c). Al subir el porcentaje nadie pierde la funcionalidad.
-- =====================================================================
create function public.cubeta_funcionalidad(p_key text, p_id text)
returns smallint
language sql
immutable
strict
set search_path = ''
as $$
  select ((('x' || substr(md5(p_key || ':' || p_id), 1, 8))::bit(32)::bigint) % 100)::smallint;
$$;

-- '1.10.0' >= '1.9' comparando número por número.
create function public.version_al_menos(p_version text, p_minima text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
    when p_minima is null then true
    when p_version is null or p_version !~ '^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$' then false
    else string_to_array(p_version, '.')::int[] >= string_to_array(p_minima, '.')::int[]
  end;
$$;

-- =====================================================================
-- ¿La funcionalidad está prendida para quien pregunta?
-- Orden (docs/15 §5): apagado/fechas → excluida/invitada → etapa → reglas y %.
-- =====================================================================
create function public.funcionalidad_activa(
  p_key        text,
  p_anon_id    text default null,
  p_plataforma text default null,
  p_version    text default null
)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  f        public.feature_flags;
  yo       uuid := (select auth.uid());
  perfil   public.profiles;
  invitada boolean;
  id_cubeta text;
begin
  select * into f from public.feature_flags where key = p_key;
  if not found or f.killed then return false; end if;
  if f.starts_at is not null and now() < f.starts_at then return false; end if;
  if f.ends_at is not null and now() >= f.ends_at then return false; end if;
  if f.stage = 'borrador' then return false; end if;

  if yo is not null then
    select enabled into invitada from public.feature_flag_users
      where flag_key = p_key and user_id = yo;
    if invitada is false then return false; end if;
    if invitada then return true; end if;
    select * into perfil from public.profiles where id = yo;
    if perfil.role = 'admin' then return true; end if;   -- el equipo ve todo lo que no es borrador
  end if;

  if f.stage in ('interna', 'beta') then return false; end if;
  if f.stage = 'todos' then return yo is not null or f.allow_anonymous; end if;

  -- 'gradual': todas las reglas que no son null, y el porcentaje.
  if yo is null and not f.allow_anonymous then return false; end if;
  if f.zone_ids is not null and (perfil.zone_id is null or not perfil.zone_id = any (f.zone_ids)) then
    return false;   -- sin cuenta no hay zona: no le llega
  end if;
  if f.plans is not null and (perfil.plan is null or not perfil.plan::text = any (f.plans)) then
    return false;
  end if;
  if f.roles is not null and (perfil.role is null or not perfil.role::text = any (f.roles)) then
    return false;
  end if;
  if f.platforms is not null and (p_plataforma is null or not p_plataforma = any (f.platforms)) then
    return false;
  end if;
  if not public.version_al_menos(p_version, f.min_app_version) then return false; end if;

  id_cubeta := coalesce(yo::text, left(nullif(trim(p_anon_id), ''), 64));
  if id_cubeta is null then return false; end if;
  return public.cubeta_funcionalidad(f.key, id_cubeta) < f.rollout_percent;
end;
$$;

-- Todas las prendidas para quien pregunta (la app las pide al abrir).
create function public.mis_funcionalidades(
  p_anon_id    text default null,
  p_plataforma text default null,
  p_version    text default null
)
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(key order by key), '{}')
  from public.feature_flags
  where stage <> 'borrador' and not killed
    and public.funcionalidad_activa(key, p_anon_id, p_plataforma, p_version);
$$;

revoke execute on function public.cubeta_funcionalidad(text, text) from public;
revoke execute on function public.version_al_menos(text, text) from public;
revoke execute on function public.funcionalidad_activa(text, text, text, text) from public;
revoke execute on function public.mis_funcionalidades(text, text, text) from public;
grant execute on function public.funcionalidad_activa(text, text, text, text) to anon, authenticated;
grant execute on function public.mis_funcionalidades(text, text, text) to anon, authenticated;

-- Primera marca: los temas Pro del 0.8.0a, en beta mientras no haya cobro (D63).
insert into public.feature_flags (key, description, stage)
values ('temas_pro', 'Temas de colores Faro, Vecinos y Pop (plan Pro o Familia)', 'beta');
