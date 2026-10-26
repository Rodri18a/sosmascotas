-- Etapa 2.2 (D103): planes Destacado y Plus con cobro manual (06, 05 §7).
--  · subscriptions: un plan pago por comercio, con período y precio
--    (congelado para los Socios Fundadores). payments: cada cobro manual
--    (transferencia, link de pago, efectivo) que registra la administración.
--    Quedan aunque se borre el comercio (son registros contables).
--  · plan_changes: historial de cada cambio de plan (lo escribe un trigger).
--    Sirve para el «antes y después del plan» de las estadísticas (D101).
--  · Vencimientos (pg_cron, todos los días): vencido el período pasa a
--    «con atraso» y a los 7 días vuelve a Básico; un Socio Fundador sin
--    suscripción vuelve a Básico al terminar su fecha.
--  · El comercio ve su plan, sus pagos y el antes/después con mi_plan(), y
--    puede pedir un plan (queda en el mini CRM). Nada se lee directo.
--  · El cobro real espera la formalización (0.0.9d, 1.9.0): hasta entonces
--    esto se usa con precio 0 o para Socios Fundadores.

create table public.subscriptions (
  id           uuid primary key default gen_random_uuid(),
  owner_type   text not null default 'business' check (owner_type in ('user', 'household', 'business')),
  owner_id     uuid not null,
  plan         text not null check (plan in ('featured', 'plus', 'pro', 'family')),
  status       text not null default 'active' check (status in ('active', 'past_due', 'cancelled', 'expired')),
  period_start date not null default current_date,
  period_end   date not null,
  provider     text not null default 'manual' check (provider in ('manual', 'google_play', 'app_store', 'mercadopago')),
  founder      boolean not null default false,
  price        numeric(10, 2) not null default 0 check (price >= 0),   -- por mes
  currency     char(3) not null default 'UYU',
  notes        text check (char_length(notes) <= 500),
  created_by   uuid default auth.uid() references auth.users (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  check (period_end >= period_start),
  check ((owner_type = 'business') = (plan in ('featured', 'plus')))
);

comment on table public.subscriptions is
  'Planes pagos (2.2, D103). Sin acceso directo: funciones de administración y mi_plan().';

-- Una sola vigente por dueño.
create unique index subscriptions_vigente_idx on public.subscriptions (owner_type, owner_id)
  where status in ('active', 'past_due');
create index subscriptions_vence_idx on public.subscriptions (period_end) where status <> 'expired';

create trigger subscriptions_updated_at
  before update on public.subscriptions
  for each row execute function public.set_updated_at();

create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  subscription_id uuid not null references public.subscriptions (id) on delete restrict,
  amount          numeric(10, 2) not null check (amount > 0),
  currency        char(3) not null default 'UYU',
  method          text not null check (method in ('transfer', 'payment_link', 'cash', 'other')),
  reference       text check (char_length(reference) <= 120),
  months          smallint not null default 1 check (months between 1 and 12),
  paid_at         timestamptz not null default now(),
  recorded_by     uuid default auth.uid() references auth.users (id) on delete set null,
  created_at      timestamptz not null default now()
);

comment on table public.payments is 'Cobros manuales de los planes (2.2, D103). Solo por admin_registrar_pago().';

create index payments_sub_idx on public.payments (subscription_id, paid_at);
create index payments_paid_idx on public.payments (paid_at);

create table public.plan_changes (
  id          bigint generated always as identity primary key,
  business_id uuid not null references public.businesses (id) on delete cascade,
  plan_before text,
  plan_after  text not null,
  changed_by  uuid,
  changed_at  timestamptz not null default now()
);

comment on table public.plan_changes is 'Historial de planes de cada comercio (2.2, D103). Lo escribe un trigger.';

create index plan_changes_business_idx on public.plan_changes (business_id, changed_at);

alter table public.subscriptions enable row level security;
alter table public.payments enable row level security;
alter table public.plan_changes enable row level security;
revoke all on public.subscriptions, public.payments, public.plan_changes from anon, authenticated;

create function public.anotar_cambio_de_plan()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if tg_op = 'INSERT' or new.plan is distinct from old.plan then
    insert into public.plan_changes (business_id, plan_before, plan_after, changed_by)
    values (new.id, case when tg_op = 'UPDATE' then old.plan end, new.plan, (select auth.uid()));
  end if;
  return null;
end;
$$;

revoke all on function public.anotar_cambio_de_plan() from public, anon, authenticated;

create trigger businesses_cambio_de_plan
  after insert or update of plan on public.businesses
  for each row execute function public.anotar_cambio_de_plan();

-- Lo que ya había: el plan actual de cada comercio pago, desde hoy.
insert into public.plan_changes (business_id, plan_before, plan_after)
select id, null, plan from public.businesses where plan <> 'basic';

-- ---------------------------------------------------------------------
-- Administración
-- ---------------------------------------------------------------------

-- Plan pago nuevo (o cambio de plan): cierra la vigente y abre otra.
create function public.admin_crear_suscripcion(
  p_business uuid,
  p_plan     text,
  p_precio   numeric,
  p_hasta    date,
  p_founder  boolean default false,
  p_notas    text default null
)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  sub_id uuid;
begin
  perform public.exigir_admin();
  if p_plan not in ('featured', 'plus') then raise exception 'Plan inválido' using errcode = '22023'; end if;
  if p_hasta is null or p_hasta < current_date then
    raise exception 'La fecha de vencimiento tiene que ser futura' using errcode = '22023';
  end if;
  if not exists (select 1 from public.businesses where id = p_business) then
    raise exception 'No existe' using errcode = 'P0002';
  end if;
  update public.subscriptions set status = 'cancelled', period_end = least(period_end, current_date)
   where owner_type = 'business' and owner_id = p_business and status in ('active', 'past_due');
  insert into public.subscriptions (owner_type, owner_id, plan, period_end, founder, price, notes)
  values ('business', p_business, p_plan, p_hasta, coalesce(p_founder, false), coalesce(p_precio, 0), p_notas)
  returning id into sub_id;
  update public.businesses
     set plan = p_plan,
         founder_until = case when coalesce(p_founder, false) then p_hasta else founder_until end
   where id = p_business;
  perform public.registrar_accion('crear_suscripcion', 'business', p_business::text,
                                  jsonb_build_object('plan', p_plan, 'precio', p_precio, 'hasta', p_hasta,
                                                     'fundador', coalesce(p_founder, false)));
  return sub_id;
end;
$$;

-- Cobro manual: extiende el período [p_meses] desde el vencimiento (o desde
-- hoy, si ya venció) y vuelve a activar el plan.
create function public.admin_registrar_pago(
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
  update public.subscriptions set status = 'active', period_end = nuevo_fin where id = p_sub;
  if s.owner_type = 'business' then
    update public.businesses set plan = s.plan where id = s.owner_id and plan is distinct from s.plan;
  end if;
  perform public.registrar_accion('registrar_pago', 'subscription', p_sub::text,
                                  jsonb_build_object('monto', p_monto, 'metodo', p_metodo, 'meses', p_meses,
                                                     'hasta', nuevo_fin));
  return nuevo_fin;
end;
$$;

-- Baja: el plan sigue hasta el fin del período ya pagado.
create function public.admin_cancelar_suscripcion(p_sub uuid, p_motivo text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  update public.subscriptions set status = 'cancelled',
         notes = left(concat_ws(' · ', notes, nullif(trim(p_motivo), '')), 500)
   where id = p_sub and status in ('active', 'past_due');
  if not found then raise exception 'No está vigente' using errcode = '22023'; end if;
  perform public.registrar_accion('cancelar_suscripcion', 'subscription', p_sub::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- Lista para el portal: lo que vence primero, arriba.
create function public.admin_suscripciones()
returns table (id uuid, business_id uuid, comercio text, rubro text, plan text, status text,
               period_start date, period_end date, founder boolean, price numeric,
               ultimo_pago timestamptz, pagado numeric)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select s.id, s.owner_id, b.name, b.business_type, s.plan, s.status, s.period_start, s.period_end,
         s.founder, s.price,
         (select max(p.paid_at) from public.payments p where p.subscription_id = s.id),
         (select coalesce(sum(p.amount), 0) from public.payments p where p.subscription_id = s.id)
  from public.subscriptions s
  left join public.businesses b on b.id = s.owner_id
  where s.owner_type = 'business'
  order by (s.status in ('active', 'past_due')) desc, s.period_end;
end;
$$;

-- Ingresos por mes y por plan (últimos [p_meses]).
create function public.admin_ingresos(p_meses integer default 12)
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
                   where owner_type = 'business' and status in ('active', 'past_due') group by 1) v),
    'por_mes_esperado', (select coalesce(sum(price), 0) from public.subscriptions
                         where owner_type = 'business' and status in ('active', 'past_due') and not founder)
  );
end;
$$;

-- ---------------------------------------------------------------------
-- El comercio
-- ---------------------------------------------------------------------

-- Aperturas y contactos de los 30 días después de pasar al plan pago actual
-- contra los 30 de antes (D101). null si todavía no pasaron 7 días.
create function public.antes_y_despues_del_plan(p_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  desde date;
  hasta date;
  dias  integer;
begin
  select public.dia_uy(c.changed_at) into desde
  from public.plan_changes c
  where c.business_id = p_id and c.plan_after <> 'basic'
    and coalesce(c.plan_before, 'basic') = 'basic'
  order by c.changed_at desc limit 1;
  if desde is null or desde > public.dia_uy(now()) - 7 then return null; end if;
  hasta := least(desde + 30, public.dia_uy(now()));
  dias := hasta - desde;
  return (
    select jsonb_build_object(
      'desde', desde,
      'dias', dias,
      'aperturas_antes', coalesce(sum(s.value) filter (where s.day < desde and s.metric = 'place_open'), 0),
      'aperturas_despues', coalesce(sum(s.value) filter (where s.day >= desde and s.metric = 'place_open'), 0),
      'contactos_antes', coalesce(sum(s.value) filter (where s.day < desde and public.es_contacto(s.metric)), 0),
      'contactos_despues', coalesce(sum(s.value) filter (where s.day >= desde and public.es_contacto(s.metric)), 0))
    from public.daily_stats s
    where s.business_id = p_id and s.day >= desde - dias and s.day < hasta
  );
end;
$$;

revoke all on function public.antes_y_despues_del_plan(uuid) from public, anon, authenticated;

create function public.mi_plan(p_business uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  b record;
  s public.subscriptions;
begin
  if not (public.soy_duenio_de(p_business) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select x.plan, x.founder_until into b from public.businesses x where x.id = p_business;
  select * into s from public.subscriptions
   where owner_type = 'business' and owner_id = p_business and status in ('active', 'past_due', 'cancelled')
   order by created_at desc limit 1;
  return jsonb_build_object(
    'plan', b.plan,
    'socio_fundador_hasta', b.founder_until,
    'estado', s.status,
    'vence', s.period_end,
    'precio', s.price,
    'moneda', s.currency,
    'fundador', s.founder,
    'pagos', coalesce((select jsonb_agg(jsonb_build_object('fecha', public.dia_uy(p.paid_at), 'monto', p.amount,
                                                           'metodo', p.method, 'meses', p.months)
                                        order by p.paid_at desc)
                       from public.payments p join public.subscriptions x on x.id = p.subscription_id
                       where x.owner_type = 'business' and x.owner_id = p_business), '[]'),
    'pedido_abierto', exists (select 1 from public.prospects pr
                              where pr.business_id = p_business and pr.stage in ('prospect', 'contacted', 'demo')
                                and pr.notes like 'Pidió el plan %'),
    'antes_despues', public.antes_y_despues_del_plan(p_business)
  );
end;
$$;

-- «Quiero este plan»: queda en el mini CRM para que la administración llame.
create function public.pedir_plan(p_business uuid, p_plan text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  b record;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_plan not in ('featured', 'plus') then raise exception 'Plan inválido' using errcode = '22023'; end if;
  if exists (select 1 from public.prospects pr
             where pr.business_id = p_business and pr.stage in ('prospect', 'contacted', 'demo')
               and pr.notes like 'Pidió el plan %') then
    raise exception 'Ya lo pediste: te vamos a contactar' using errcode = '23505';
  end if;
  select x.name, x.business_type into b from public.businesses x where x.id = p_business;
  insert into public.prospects (name, business_type, business_id, stage, next_contact, notes)
  values (b.name, case when b.business_type = 'agro' then null else b.business_type end, p_business,
          'contacted', current_date + 1,
          'Pidió el plan ' || case p_plan when 'plus' then 'Plus' else 'Destacado' end
          || ' desde la app el ' || to_char(public.dia_uy(now()), 'DD/MM/YYYY') || '.');
end;
$$;

-- ---------------------------------------------------------------------
-- Vencimientos (todos los días a las 03:30 de Uruguay)
-- ---------------------------------------------------------------------
create function public.vencer_planes()
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  hoy date := public.dia_uy(now());
  n integer := 0;
  c integer;
begin
  -- Período vencido sin pago: con atraso (sigue el plan 7 días de gracia).
  update public.subscriptions set status = 'past_due'
   where status = 'active' and period_end < hoy;
  -- Atraso de más de 7 días, o baja con el período terminado: vence.
  with vencidas as (
    update public.subscriptions set status = 'expired'
     where (status = 'past_due' and period_end < hoy - 7)
        or (status = 'cancelled' and period_end < hoy)
    returning owner_type, owner_id
  )
  update public.businesses b set plan = 'basic'
    from vencidas v
   where v.owner_type = 'business' and b.id = v.owner_id and b.plan <> 'basic'
     and not exists (select 1 from public.subscriptions s where s.owner_type = 'business'
                       and s.owner_id = b.id and s.status in ('active', 'past_due'));
  get diagnostics c = row_count;
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

select cron.schedule('vencer-planes', '30 6 * * *', 'select public.vencer_planes();');

revoke all on function public.admin_crear_suscripcion(uuid, text, numeric, date, boolean, text) from public, anon;
revoke all on function public.admin_registrar_pago(uuid, numeric, text, text, integer) from public, anon;
revoke all on function public.admin_cancelar_suscripcion(uuid, text) from public, anon;
revoke all on function public.admin_suscripciones() from public, anon;
revoke all on function public.admin_ingresos(integer) from public, anon;
revoke all on function public.mi_plan(uuid) from public, anon;
revoke all on function public.pedir_plan(uuid, text) from public, anon;
grant execute on function public.admin_crear_suscripcion(uuid, text, numeric, date, boolean, text) to authenticated;
grant execute on function public.admin_registrar_pago(uuid, numeric, text, text, integer) to authenticated;
grant execute on function public.admin_cancelar_suscripcion(uuid, text) to authenticated;
grant execute on function public.admin_suscripciones() to authenticated;
grant execute on function public.admin_ingresos(integer) to authenticated;
grant execute on function public.mi_plan(uuid) to authenticated;
grant execute on function public.pedir_plan(uuid, text) to authenticated;
