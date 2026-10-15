-- Paso 0.6.3: aviso push a quienes están cerca cuando se publica un SOS.
-- La Edge Function `sos-zone-alert` (la llama la app al publicar) usa
-- difundir_sos() para elegir a quién avisar y después manda las push por FCM.
-- Reglas (docs/06-reglas-negocio.md): hasta el radio de cada persona (1–20 km,
-- por defecto 5) y como máximo 3 avisos por persona por día (D57).

-- Cada SOS se difunde una sola vez.
alter table public.sos_reports add column zone_alerted_at timestamptz;

-- A quién se le avisó de cada SOS: para el tope diario y para no repetir.
create table public.sos_zone_alerts (
  sos_id     uuid not null references public.sos_reports (id) on delete cascade,
  user_id    uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (sos_id, user_id)
);

create index sos_zone_alerts_user_idx on public.sos_zone_alerts (user_id, created_at desc);

comment on table public.sos_zone_alerts is 'Avisos por zona enviados. Solo la Edge Function sos-zone-alert.';

alter table public.sos_zone_alerts enable row level security;
-- Sin políticas a propósito: nadie lee ni escribe desde la app.
revoke all on public.sos_zone_alerts from anon, authenticated;

-- Marca el SOS como difundido y devuelve a quién avisar, con sus dispositivos.
-- Si el SOS no es de p_autor, no está activo, tiene más de un día o ya se
-- difundió, no devuelve nada (llamarla dos veces no avisa dos veces).
-- La distancia se mide desde la ubicación pública (desplazada), nunca desde la
-- exacta, y hasta la zona aproximada de cada persona (D56).
create function public.difundir_sos(p_sos uuid, p_autor uuid, p_tope_diario integer default 3)
returns table (user_id uuid, distancia_m integer, tokens text[])
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  punto extensions.geography;
begin
  update public.sos_reports r
     set zone_alerted_at = now()
   where r.id = p_sos
     and r.user_id = p_autor
     and r.status = 'active'
     and r.zone_alerted_at is null
     and r.created_at > now() - interval '1 day'
  returning r.public_location into punto;
  if punto is null then
    return;
  end if;

  return query
  with candidatos as (
    select p.id, extensions.st_distance(p.approx_location, punto) as d
    from public.profiles p
    where p.approx_location is not null
      and p.id <> p_autor
      -- Primero el radio máximo (usa el índice), después el de cada persona.
      and extensions.st_dwithin(p.approx_location, punto, 20000)
      and extensions.st_distance(p.approx_location, punto) <= p.alert_radius_km * 1000
      and exists (select 1 from public.push_tokens t where t.user_id = p.id)
      and (select count(*) from public.sos_zone_alerts a
            where a.user_id = p.id and a.created_at > now() - interval '1 day') < p_tope_diario
  ), registrados as (
    insert into public.sos_zone_alerts (sos_id, user_id)
    select p_sos, c.id from candidatos c
    on conflict do nothing
    returning sos_zone_alerts.user_id
  )
  select g.user_id,
         round(c.d)::integer,
         array(select t.token from public.push_tokens t where t.user_id = g.user_id)
  from registrados g
  join candidatos c on c.id = g.user_id;
end;
$$;

revoke execute on function public.difundir_sos(uuid, uuid, integer) from public, anon, authenticated;
grant execute on function public.difundir_sos(uuid, uuid, integer) to service_role;
