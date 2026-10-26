-- Etapa 2.3 (D101): estadísticas para empresas y reporte mensual.
--  · daily_stats: resumen por día, comercio y métrica de los eventos que ya
--    registra la app (`events` con business_id). Sin acceso directo: lo
--    escribe resumir_estadisticas() (pg_cron, todas las noches) y se lee con
--    estadisticas_negocio(), que solo devuelve cantidades (Ley 18.331).
--  · Plan Básico: resumen (aperturas y contactos, este mes y el anterior).
--    Destacado y Plus: todas las métricas, 6 meses y 12 semanas (06).
--  · Reporte mensual: el día 1 pg_cron llama a la Edge Function
--    monthly-report, que pide los pendientes con reporte_mensual_pendiente()
--    (solo service_role) y le manda una push al dueño de cada comercio.
--    Detrás de la marca `estadisticas`. El email llega con el SMTP (0.4.4b).

-- Los días se cuentan con la hora de Uruguay.
create function public.dia_uy(p timestamptz)
returns date
language sql immutable set search_path = ''
as $$ select (p at time zone 'America/Montevideo')::date; $$;

create function public.inicio_dia_uy(p date)
returns timestamptz
language sql immutable set search_path = ''
as $$ select p::timestamp at time zone 'America/Montevideo'; $$;

create table public.daily_stats (
  day         date not null,
  business_id uuid not null references public.businesses (id) on delete cascade,
  zone_id     smallint references public.zones (id),
  metric      text not null check (metric ~ '^[a-z][a-z0-9_]{1,40}(:[a-z0-9_]{1,30})?$'),
  value       integer not null check (value >= 0),
  primary key (business_id, day, metric)
);

comment on table public.daily_stats is
  'Resumen diario de métricas por comercio (2.3, D101). Sin acceso desde la app: estadisticas_negocio().';

create index daily_stats_day_idx on public.daily_stats (day);

alter table public.daily_stats enable row level security;
revoke all on public.daily_stats from anon, authenticated;

create table public.monthly_reports (
  business_id uuid not null references public.businesses (id) on delete cascade,
  month       date not null check (extract(day from month) = 1),
  totals      jsonb not null,
  devices     smallint,
  created_at  timestamptz not null default now(),
  primary key (business_id, month)
);

comment on table public.monthly_reports is
  'Reportes mensuales ya armados por comercio (2.3, D101). Solo service_role.';

alter table public.monthly_reports enable row level security;
revoke all on public.monthly_reports from anon, authenticated;

-- Eventos que cuentan para el comercio. place_click se abre por tipo
-- (whatsapp, llamar, como_llegar, web, instagram) y se suma la cantidad de
-- personas distintas que abrieron la ficha en el día.
create function public.contar_eventos_comercio(p_desde timestamptz, p_hasta timestamptz, p_business uuid default null)
returns table (business_id uuid, day date, metric text, value integer)
language sql stable security definer set search_path = ''
as $$
  select e.business_id, public.dia_uy(e.created_at),
         case when e.name = 'place_click'
              then 'place_click:' || coalesce(nullif(regexp_replace(lower(e.props ->> 'tipo'), '[^a-z0-9_]', '', 'g'), ''), 'otro')
              else e.name end,
         count(*)::integer
  from public.events e
  where e.business_id is not null
    and (p_business is null or e.business_id = p_business)
    and e.created_at >= p_desde and e.created_at < p_hasta
    and e.name in ('place_open', 'place_click', 'favorite_add', 'place_visit', 'chat_start',
                   'catalog_open', 'catalog_ask', 'service_ask', 'business_page_open',
                   'order_create', 'review_create')
  group by 1, 2, 3
  union all
  select e.business_id, public.dia_uy(e.created_at), 'place_open_people', count(distinct e.anon_id)::integer
  from public.events e
  where e.business_id is not null
    and (p_business is null or e.business_id = p_business)
    and e.created_at >= p_desde and e.created_at < p_hasta
    and e.name = 'place_open'
  group by 1, 2;
$$;

revoke execute on function public.contar_eventos_comercio(timestamptz, timestamptz, uuid) from public, anon, authenticated;

-- Rehace el resumen de un día (se puede repetir: borra y vuelve a contar).
create function public.resumir_estadisticas(p_dia date)
returns integer
language plpgsql volatile security definer set search_path = ''
as $$
declare
  filas integer;
begin
  delete from public.daily_stats where day = p_dia;
  insert into public.daily_stats (day, business_id, zone_id, metric, value)
  select c.day, c.business_id, b.zone_id, c.metric, c.value
  from public.contar_eventos_comercio(public.inicio_dia_uy(p_dia), public.inicio_dia_uy(p_dia + 1)) c
  join public.businesses b on b.id = c.business_id;
  get diagnostics filas = row_count;
  return filas;
end;
$$;

revoke execute on function public.resumir_estadisticas(date) from public, anon, authenticated;

-- Contactos = todo lo que es una persona buscando al comercio.
create function public.es_contacto(p_metric text)
returns boolean
language sql immutable set search_path = ''
as $$
  select p_metric like 'place_click:%'
      or p_metric in ('chat_start', 'catalog_ask', 'service_ask', 'order_create');
$$;

-- Estadísticas del comercio para su dueño (o la administración).
create function public.estadisticas_negocio(p_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  hoy       date := public.dia_uy(now());
  mes       date := date_trunc('month', public.dia_uy(now())::timestamp)::date;
  plan_     text;
  completo  boolean;
  meses     integer;
  resultado jsonb;
begin
  if not (public.soy_duenio_de(p_id) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select plan into plan_ from public.businesses where id = p_id;
  completo := plan_ in ('featured', 'plus') or public.es_admin();
  meses := case when completo then 6 else 2 end;

  with datos as (
    select s.day, s.metric, s.value from public.daily_stats s
    where s.business_id = p_id and s.day >= (mes - make_interval(months => meses - 1))::date and s.day < hoy
    union all
    -- Hoy todavía no está resumido: se cuenta en el momento.
    select c.day, c.metric, c.value
    from public.contar_eventos_comercio(public.inicio_dia_uy(hoy), now() + interval '1 minute', p_id) c
  ),
  con_contactos as (
    select day, metric, value from datos
    where completo or metric = 'place_open'
    union all
    select day, 'contactos', sum(value)::integer from datos where public.es_contacto(metric) group by day
  ),
  por_mes as (
    select date_trunc('month', day::timestamp)::date m, metric, sum(value)::integer v
    from con_contactos group by 1, 2
  ),
  por_semana as (
    select date_trunc('week', day::timestamp)::date s, metric, sum(value)::integer v
    from con_contactos
    where completo and metric in ('place_open', 'contactos')
      and day >= (date_trunc('week', hoy::timestamp) - interval '11 weeks')::date
    group by 1, 2
  )
  select jsonb_build_object(
    'plan', plan_,
    'completo', completo,
    'hoy', hoy,
    'meses', coalesce((
      select jsonb_agg(jsonb_build_object(
               'mes', g.m::date,
               'metricas', coalesce((select jsonb_object_agg(p.metric, p.v) from por_mes p where p.m = g.m::date), '{}')
             ) order by g.m)
      from generate_series((mes - make_interval(months => meses - 1))::timestamp, mes::timestamp, interval '1 month') g(m)
    ), '[]'),
    'semanas', case when completo then coalesce((
      select jsonb_agg(jsonb_build_object(
               'semana', g.s::date,
               'aperturas', coalesce((select v from por_semana p where p.s = g.s::date and p.metric = 'place_open'), 0),
               'contactos', coalesce((select v from por_semana p where p.s = g.s::date and p.metric = 'contactos'), 0)
             ) order by g.s)
      from generate_series(date_trunc('week', hoy::timestamp) - interval '11 weeks', date_trunc('week', hoy::timestamp), interval '1 week') g(s)
    ), '[]') else '[]'::jsonb end
  ) into resultado;
  return resultado;
end;
$$;

revoke all on function public.estadisticas_negocio(uuid) from public, anon;
grant execute on function public.estadisticas_negocio(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Reporte mensual
-- ---------------------------------------------------------------------

-- ¿La marca `estadisticas` le llega a esta cuenta? Versión para el servidor
-- de funcionalidad_activa() (sin sesión): todos, invitada o administración.
create function public.estadisticas_para(p_usuario uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.feature_flags f
    where f.key = 'estadisticas' and not f.killed and f.stage <> 'borrador'
      and (f.starts_at is null or now() >= f.starts_at)
      and (f.ends_at is null or now() < f.ends_at)
      and not exists (select 1 from public.feature_flag_users u
                      where u.flag_key = f.key and u.user_id = p_usuario and not u.enabled)
      and (f.stage = 'todos'
           or exists (select 1 from public.feature_flag_users u
                      where u.flag_key = f.key and u.user_id = p_usuario and u.enabled)
           or exists (select 1 from public.profiles p where p.id = p_usuario and p.role = 'admin'))
  );
$$;

revoke execute on function public.estadisticas_para(uuid) from public, anon, authenticated;

-- Arma (una sola vez por comercio y mes) el reporte del mes [p_mes] y
-- devuelve a quién mandárselo. Solo comercios activos con dueño, la marca
-- prendida y algo para contar.
create function public.reporte_mensual_pendiente(p_mes date)
returns table (business_id uuid, nombre text, mes date, aperturas integer, personas integer,
               contactos integer, aperturas_antes integer, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  m date := date_trunc('month', p_mes::timestamp)::date;
begin
  if m >= date_trunc('month', public.dia_uy(now())::timestamp)::date then
    raise exception 'El mes todavía no terminó' using errcode = '22023';
  end if;
  return query
  with totales as (
    select s.business_id b,
           sum(s.value) filter (where s.day >= m and s.metric = 'place_open')::integer ap,
           sum(s.value) filter (where s.day >= m and s.metric = 'place_open_people')::integer pe,
           sum(s.value) filter (where s.day >= m and public.es_contacto(s.metric))::integer co,
           sum(s.value) filter (where s.day < m and s.metric = 'place_open')::integer ant
    from public.daily_stats s
    where s.day >= (m - interval '1 month')::date and s.day < (m + interval '1 month')::date
    group by 1
  ),
  nuevos as (
    insert into public.monthly_reports (business_id, month, totals)
    select t.b, m, jsonb_build_object('aperturas', coalesce(t.ap, 0), 'personas', coalesce(t.pe, 0),
                                      'contactos', coalesce(t.co, 0), 'aperturas_antes', coalesce(t.ant, 0))
    from totales t join public.businesses x on x.id = t.b
    where x.status = 'active' and x.owner_id is not null
      and coalesce(t.ap, 0) + coalesce(t.co, 0) > 0
      and public.estadisticas_para(x.owner_id)
    on conflict do nothing
    returning monthly_reports.business_id, monthly_reports.totals
  )
  select n.business_id, x.name, m,
         (n.totals ->> 'aperturas')::integer, (n.totals ->> 'personas')::integer,
         (n.totals ->> 'contactos')::integer, (n.totals ->> 'aperturas_antes')::integer,
         array(select t.token from public.push_tokens t where t.user_id = x.owner_id)
  from nuevos n join public.businesses x on x.id = n.business_id;
end;
$$;

revoke execute on function public.reporte_mensual_pendiente(date) from public, anon, authenticated;
grant execute on function public.reporte_mensual_pendiente(date) to service_role;

-- ---------------------------------------------------------------------
-- Tareas programadas
-- ---------------------------------------------------------------------
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;

-- Llama a la Edge Function del reporte. La dirección del proyecto y la clave
-- compartida se guardan a mano en Vault (`project_url` y
-- `monthly_report_secret`, nunca en el repositorio); sin ellas no hace nada.
create function public.pedir_reporte_mensual()
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  url   text := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url');
  clave text := (select decrypted_secret from vault.decrypted_secrets where name = 'monthly_report_secret');
begin
  if url is null or clave is null then
    raise warning 'Falta project_url o monthly_report_secret en Vault: no se pide el reporte mensual';
    return;
  end if;
  perform net.http_post(
    url := url || '/functions/v1/monthly-report',
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-cron-secret', clave),
    body := '{}'::jsonb,
    timeout_milliseconds := 60000
  );
end;
$$;

revoke execute on function public.pedir_reporte_mensual() from public, anon, authenticated;

-- 03:15 de Uruguay: ayer y anteayer (por eventos que llegan tarde).
select cron.schedule('resumir-estadisticas', '15 6 * * *', $$
  select public.resumir_estadisticas(public.dia_uy(now()) - 1);
  select public.resumir_estadisticas(public.dia_uy(now()) - 2);
$$);

-- El día 1 a las 10:00 de Uruguay (después del resumen de la noche).
select cron.schedule('reporte-mensual', '0 13 1 * *', 'select public.pedir_reporte_mensual();');

-- Lo que ya había: los últimos 400 días.
select public.resumir_estadisticas(d::date)
from generate_series(public.dia_uy(now()) - 400, public.dia_uy(now()) - 1, interval '1 day') d;
