-- Etapa 2.1 (D111): planes Pro y Familia para usuarios, con cobro manual.
--  · Misma tabla `subscriptions` que los comercios (D103), con
--    owner_type = 'user'. La administración da el plan, registra los pagos
--    y lo da de baja; `profiles.plan` refleja el plan vigente.
--  · Familia: sus integrantes (no los cuidadores temporales) tienen lo
--    mismo que Pro mientras el plan del dueño del hogar esté vigente.
--  · Todo depende de la funcionalidad `planes_usuario` (se crea con
--    funcionalidades.py; si no existe, está apagada y nada cambia):
--      - plan Gratis: hasta 5 mascotas propias (quien ya tenga más las
--        conserva, pero no suma otra);
--      - hogar compartido: hace falta Familia; la primera invitación abre
--        30 días gratis de Familia (una sola vez por persona).
--  · «Quiero Pro / Familia» queda en `user_plan_requests` para la
--    administración. El cobro real espera la formalización (1.9.0).
--  · Regla de oro (D06): SOS, QR, foto, recordatorios no dependen del plan.

alter table public.subscriptions
  add column trial boolean not null default false;

comment on column public.subscriptions.trial is 'Prueba gratis (los 30 días de Familia, D111).';

create table public.user_plan_requests (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  plan       text not null check (plan in ('pro', 'family')),
  status     text not null default 'open' check (status in ('open', 'done', 'discarded')),
  created_at timestamptz not null default now(),
  closed_at  timestamptz
);

comment on table public.user_plan_requests is
  'Pedidos de plan Pro o Familia desde la app (2.1, D111). Sin acceso directo.';

create unique index user_plan_requests_abierto_idx on public.user_plan_requests (user_id) where status = 'open';

alter table public.user_plan_requests enable row level security;
revoke all on public.user_plan_requests from anon, authenticated;

-- ---------------------------------------------------------------------
-- ¿Qué plan tiene en la práctica?
-- ---------------------------------------------------------------------

-- 'family' o 'pro' (propio), 'family' por integrar un hogar Familia, o 'free'.
create function public.plan_efectivo(p_user uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when (select plan::text from public.profiles where id = p_user) in ('pro', 'family')
      then (select plan::text from public.profiles where id = p_user)
    when exists (select 1 from public.household_members m
                 join public.households h on h.id = m.household_id
                 join public.profiles d on d.id = h.owner_id
                 where m.user_id = p_user and m.role = 'member' and d.plan = 'family'
                   and (m.access_until is null or m.access_until > now()))
      then 'family'
    else 'free'
  end;
$$;

create function public.es_pro(p_user uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.plan_efectivo(p_user) <> 'free';
$$;

revoke all on function public.plan_efectivo(uuid) from public, anon, authenticated;
revoke all on function public.es_pro(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Límite de mascotas (plan Gratis: 5)
-- ---------------------------------------------------------------------
create function public.limite_mascotas()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.funcionalidad_activa('planes_usuario')
     and not public.es_pro(new.owner_id)
     and (select count(*) from public.pets where owner_id = new.owner_id) >= 5 then
    raise exception 'limite_mascotas' using errcode = 'P0001',
      hint = 'Con el plan Gratis podés tener hasta 5 mascotas.';
  end if;
  return new;
end;
$$;

revoke all on function public.limite_mascotas() from public, anon, authenticated;

create trigger pets_limite_plan
  before insert on public.pets
  for each row execute function public.limite_mascotas();

-- ---------------------------------------------------------------------
-- Hogar compartido con Familia (prueba de 30 días)
-- ---------------------------------------------------------------------
create function public.hogar_pide_familia()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  dueno uuid := (select owner_id from public.households where id = new.household_id);
  hoy date := public.dia_uy(now());
begin
  if not public.funcionalidad_activa('planes_usuario')
     or (select plan from public.profiles where id = dueno) = 'family' then
    return new;
  end if;
  if exists (select 1 from public.subscriptions
             where owner_type = 'user' and owner_id = dueno and plan = 'family' and trial) then
    raise exception 'plan_familia' using errcode = 'P0001',
      hint = 'El hogar compartido es del plan Familia.';
  end if;
  -- Primera vez: 30 días gratis. Un Pro vigente se cierra (Familia lo incluye).
  update public.subscriptions set status = 'cancelled', period_end = least(period_end, hoy)
   where owner_type = 'user' and owner_id = dueno and status in ('active', 'past_due');
  insert into public.subscriptions (owner_type, owner_id, plan, period_end, price, trial, notes, created_by)
  values ('user', dueno, 'family', hoy + 30, 0, true, 'Prueba de 30 días al invitar al hogar', dueno);
  update public.profiles set plan = 'family' where id = dueno;
  return new;
end;
$$;

revoke all on function public.hogar_pide_familia() from public, anon, authenticated;

create trigger household_invites_familia
  before insert on public.household_invites
  for each row execute function public.hogar_pide_familia();

-- ---------------------------------------------------------------------
-- La persona
-- ---------------------------------------------------------------------
create function public.mi_plan_usuario()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  s public.subscriptions;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select * into s from public.subscriptions
   where owner_type = 'user' and owner_id = yo and status in ('active', 'past_due', 'cancelled')
   order by created_at desc limit 1;
  return jsonb_build_object(
    'plan', (select plan::text from public.profiles where id = yo),
    'efectivo', public.plan_efectivo(yo),
    'por_hogar', public.plan_efectivo(yo) = 'family'
                 and (select plan from public.profiles where id = yo) <> 'family',
    'estado', s.status,
    'vence', s.period_end,
    'prueba', s.trial,
    'precio', s.price,
    'moneda', s.currency,
    'mascotas', (select count(*) from public.pets where owner_id = yo),
    'limite_mascotas', case when public.funcionalidad_activa('planes_usuario')
                                 and not public.es_pro(yo) then 5 end,
    'prueba_familia_usada', exists (select 1 from public.subscriptions x
                                    where x.owner_type = 'user' and x.owner_id = yo
                                      and x.plan = 'family' and x.trial),
    'pedido_abierto', (select r.plan from public.user_plan_requests r
                       where r.user_id = yo and r.status = 'open')
  );
end;
$$;

-- «Quiero Pro / Familia»: lo ve la administración en Planes y cobros.
create function public.pedir_plan_usuario(p_plan text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if p_plan not in ('pro', 'family') then raise exception 'Plan inválido' using errcode = '22023'; end if;
  if exists (select 1 from public.user_plan_requests where user_id = yo and status = 'open') then
    raise exception 'Ya lo pediste: te vamos a contactar' using errcode = '23505';
  end if;
  insert into public.user_plan_requests (user_id, plan) values (yo, p_plan);
end;
$$;

-- ---------------------------------------------------------------------
-- Administración
-- ---------------------------------------------------------------------

-- Plan Pro o Familia para una cuenta (por correo): cierra el vigente y abre otro.
create function public.admin_crear_suscripcion_usuario(
  p_email  text,
  p_plan   text,
  p_precio numeric,
  p_hasta  date,
  p_notas  text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  quien uuid;
  sub_id uuid;
begin
  perform public.exigir_admin();
  if p_plan not in ('pro', 'family') then raise exception 'Plan inválido' using errcode = '22023'; end if;
  if p_hasta is null or p_hasta < current_date then
    raise exception 'La fecha de vencimiento tiene que ser futura' using errcode = '22023';
  end if;
  select u.id into quien from auth.users u where lower(u.email) = lower(trim(p_email));
  if quien is null then raise exception 'sin_cuenta' using errcode = 'P0002'; end if;
  update public.subscriptions set status = 'cancelled', period_end = least(period_end, current_date)
   where owner_type = 'user' and owner_id = quien and status in ('active', 'past_due');
  insert into public.subscriptions (owner_type, owner_id, plan, period_end, price, notes)
  values ('user', quien, p_plan, p_hasta, coalesce(p_precio, 0), p_notas)
  returning id into sub_id;
  update public.profiles set plan = p_plan::public.user_plan where id = quien;
  update public.user_plan_requests set status = 'done', closed_at = now()
   where user_id = quien and status = 'open';
  perform public.registrar_accion('crear_suscripcion_usuario', 'user', quien::text,
                                  jsonb_build_object('plan', p_plan, 'precio', p_precio, 'hasta', p_hasta));
  return sub_id;
end;
$$;

create function public.admin_suscripciones_usuarios()
returns table (id uuid, user_id uuid, email text, nombre text, plan text, status text,
               period_start date, period_end date, trial boolean, price numeric,
               ultimo_pago timestamptz, pagado numeric)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select s.id, s.owner_id, u.email::text, p.display_name, s.plan, s.status, s.period_start, s.period_end,
         s.trial, s.price,
         (select max(x.paid_at) from public.payments x where x.subscription_id = s.id),
         (select coalesce(sum(x.amount), 0) from public.payments x where x.subscription_id = s.id)
  from public.subscriptions s
  left join auth.users u on u.id = s.owner_id
  left join public.profiles p on p.id = s.owner_id
  where s.owner_type = 'user'
  order by (s.status in ('active', 'past_due')) desc, s.period_end;
end;
$$;

create function public.admin_pedidos_plan_usuario()
returns table (id uuid, user_id uuid, email text, nombre text, plan text, created_at timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select r.id, r.user_id, u.email::text, p.display_name, r.plan, r.created_at
  from public.user_plan_requests r
  left join auth.users u on u.id = r.user_id
  left join public.profiles p on p.id = r.user_id
  where r.status = 'open'
  order by r.created_at;
end;
$$;

create function public.admin_descartar_pedido_plan(p_id uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  update public.user_plan_requests set status = 'discarded', closed_at = now()
   where id = p_id and status = 'open';
  if not found then raise exception 'No está abierto' using errcode = 'P0002'; end if;
  perform public.registrar_accion('descartar_pedido_plan', 'user_plan_request', p_id::text);
end;
$$;

-- Igual que en D103, y además pone el plan en el perfil si es de una persona.
create or replace function public.admin_registrar_pago(
  p_sub        uuid,
  p_monto      numeric,
  p_metodo     text,
  p_referencia text default null,
  p_meses      integer default 1
)
returns date
language plpgsql security definer set search_path = ''
as $$
declare
  s public.subscriptions;
  nuevo_fin date;
begin
  perform public.exigir_admin();
  select * into s from public.subscriptions where id = p_sub for update;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if s.status not in ('active', 'past_due') then
    raise exception 'La suscripción no está vigente' using errcode = '22023';
  end if;
  insert into public.payments (subscription_id, amount, currency, method, reference, months)
  values (p_sub, p_monto, s.currency, p_metodo, nullif(trim(p_referencia), ''), p_meses);
  nuevo_fin := (greatest(s.period_end, current_date) + make_interval(months => p_meses))::date;
  -- Pagar una prueba la convierte en plan pago.
  update public.subscriptions set status = 'active', period_end = nuevo_fin, trial = false where id = p_sub;
  if s.owner_type = 'business' then
    update public.businesses set plan = s.plan where id = s.owner_id and plan is distinct from s.plan;
  elsif s.owner_type = 'user' then
    update public.profiles set plan = s.plan::public.user_plan
     where id = s.owner_id and plan::text is distinct from s.plan;
  end if;
  perform public.registrar_accion('registrar_pago', 'subscription', p_sub::text,
                                  jsonb_build_object('monto', p_monto, 'metodo', p_metodo, 'meses', p_meses,
                                                     'hasta', nuevo_fin));
  return nuevo_fin;
end;
$$;

-- Ingresos: los vigentes y lo esperado por mes, de comercios y personas.
create or replace function public.admin_ingresos(p_meses integer default 12)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return jsonb_build_object(
    'por_mes', coalesce((
      select jsonb_agg(jsonb_build_object('mes', x.mes, 'plan', x.plan, 'total', x.total, 'pagos', x.pagos)
                       order by x.mes, x.plan)
      from (select date_trunc('month', public.dia_uy(p.paid_at)::timestamp)::date mes, s.plan,
                   sum(p.amount) total, count(*) pagos
            from public.payments p join public.subscriptions s on s.id = p.subscription_id
            where p.paid_at >= now() - make_interval(months => greatest(1, least(p_meses, 36)))
            group by 1, 2) x), '[]'),
    'vigentes', (select jsonb_object_agg(plan, n) from (
                   select plan, count(*) n from public.subscriptions
                   where status in ('active', 'past_due') group by 1) v),
    'por_mes_esperado', (select coalesce(sum(price), 0) from public.subscriptions
                         where status in ('active', 'past_due') and not founder and not trial)
  );
end;
$$;

-- Vencimientos (D103), ahora también de las personas: vencido el plan,
-- vuelven a Gratis (sus mascotas y su hogar quedan; solo no suman más).
create or replace function public.vencer_planes()
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  hoy date := public.dia_uy(now());
  n integer := 0;
  c integer;
begin
  -- Período vencido sin pago: con atraso (sigue el plan 7 días de gracia).
  -- Una prueba gratis no tiene gracia: vence directamente.
  update public.subscriptions set status = 'past_due'
   where status = 'active' and period_end < hoy and not trial;
  -- Atraso de más de 7 días, prueba terminada o baja con el período terminado: vence.
  with vencidas as (
    update public.subscriptions set status = 'expired'
     where (status = 'past_due' and period_end < hoy - 7)
        or (status = 'active' and trial and period_end < hoy)
        or (status = 'cancelled' and period_end < hoy)
    returning id, owner_type, owner_id
  ),
  comercios as (
    update public.businesses b set plan = 'basic'
      from vencidas v
     where v.owner_type = 'business' and b.id = v.owner_id and b.plan <> 'basic'
       and not exists (select 1 from public.subscriptions s where s.owner_type = 'business'
                         and s.owner_id = b.id and s.status in ('active', 'past_due')
                         and s.id not in (select x.id from vencidas x))
    returning 1
  ),
  personas as (
    update public.profiles p set plan = 'free'
      from vencidas v
     where v.owner_type = 'user' and p.id = v.owner_id and p.plan <> 'free'
       and not exists (select 1 from public.subscriptions s where s.owner_type = 'user'
                         and s.owner_id = p.id and s.status in ('active', 'past_due')
                         and s.id not in (select x.id from vencidas x))
    returning 1
  )
  select (select count(*) from comercios) + (select count(*) from personas) into c;
  n := n + c;
  -- Socio Fundador sin suscripción: vuelve a Básico al terminar su fecha.
  update public.businesses b set plan = 'basic'
   where b.plan <> 'basic' and b.founder_until is not null and b.founder_until < hoy
     and not exists (select 1 from public.subscriptions s where s.owner_type = 'business'
                       and s.owner_id = b.id and s.status in ('active', 'past_due'));
  get diagnostics c = row_count;
  return n + c;
end;
$$;

revoke all on function public.vencer_planes() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array[
    'mi_plan_usuario()', 'pedir_plan_usuario(text)',
    'admin_crear_suscripcion_usuario(text, text, numeric, date, text)',
    'admin_suscripciones_usuarios()', 'admin_pedidos_plan_usuario()',
    'admin_descartar_pedido_plan(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
