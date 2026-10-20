-- D86: Novedades de la comunidad en Noticias (detrás de `noticias`).
-- Se arman solas con lo que pasa en la app, sin que nadie las escriba:
--  · Reencuentros: solo si el autor del SOS lo comparte (consentimiento
--    explícito al tocar "¡Apareció!" o después, desde el reporte). Va el
--    nombre, la especie y la primera foto del SOS (ya eran públicos); nunca
--    la ubicación ni datos del dueño. Lo puede quitar cuando quiera.
--  · Adopciones concretadas, comercios verificados y eventos: ya eran
--    públicos; se anuncian sin datos de personas.
--  · Resumen de la comunidad: solo totales.
-- Los textos los arma la app (voseo, .arb) con los datos de cada fila.

create table public.community_updates (
  id           uuid primary key default gen_random_uuid(),
  kind         text not null check (kind in ('reencuentro', 'adopcion', 'comercio', 'evento')),
  sos_id       uuid unique references public.sos_reports (id) on delete cascade,
  adoption_id  uuid unique references public.adoptions (id) on delete cascade,
  business_id  uuid unique references public.businesses (id) on delete cascade,
  event_id     uuid unique references public.events_calendar (id) on delete cascade,
  -- Nombre de la mascota (puede faltar), del comercio o del evento.
  name         text check (char_length(name) <= 80),
  -- reencuentro: 'lost' | 'found'; comercio: rubro; evento: tipo.
  detail       text check (char_length(detail) <= 40),
  species_id   smallint references public.species (id),
  -- Días que estuvo perdida (reencuentro) o animales adoptados (adopción).
  amount       smallint check (amount >= 0),
  starts_at    timestamptz,
  -- "<bucket>/<ruta>" de una foto ya pública.
  photo_path   text check (char_length(photo_path) <= 240),
  zone_id      smallint references public.zones (id),
  status       text not null default 'visible' check (status in ('visible', 'hidden')),
  created_at   timestamptz not null default now(),
  check (num_nonnulls(sos_id, adoption_id, business_id, event_id) = 1),
  check ((kind = 'reencuentro') = (sos_id is not null)),
  check ((kind = 'adopcion') = (adoption_id is not null)),
  check ((kind = 'comercio') = (business_id is not null)),
  check ((kind = 'evento') = (event_id is not null))
);

comment on table public.community_updates is
  'Novedades de la comunidad (D86). Se generan solas; los reencuentros, solo con el consentimiento del autor del SOS.';

create index community_updates_fecha_idx on public.community_updates (created_at desc)
  where status = 'visible';

alter table public.community_updates enable row level security;
-- Sin políticas a propósito: se lee con novedades_comunidad().
revoke all on public.community_updates from anon, authenticated;

-- ---------------------------------------------------------------------
-- Lectura (visitantes incluidos)
-- ---------------------------------------------------------------------

-- Las visibles de los últimos 90 días cuyo origen sigue público.
create function public.novedades_comunidad()
returns table (id uuid, kind text, name text, detail text, species_id smallint, amount smallint,
               starts_at timestamptz, photo_path text, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select u.id, u.kind, u.name, u.detail, u.species_id, u.amount, u.starts_at, u.photo_path, u.created_at
  from public.community_updates u
  left join public.sos_reports s on s.id = u.sos_id
  left join public.adoptions a on a.id = u.adoption_id
  left join public.businesses b on b.id = u.business_id
  left join public.events_calendar e on e.id = u.event_id
  where u.status = 'visible'
    and u.created_at > now() - interval '90 days'
    and (u.sos_id is null or s.status = 'resolved')
    and (u.adoption_id is null or a.status = 'adopted')
    and (u.business_id is null or (b.status = 'active' and b.verification = 'verified'))
    and (u.event_id is null or e.status = 'active')
  order by u.created_at desc
  limit 40;
$$;

-- Totales de los últimos 30 días (y lugares verificados, de siempre).
create function public.resumen_comunidad()
returns table (reencuentros integer, adopciones integer, perdidas_activas integer, lugares_verificados integer)
language sql stable security definer set search_path = ''
as $$
  select
    (select count(*)::integer from public.sos_reports
      where status = 'resolved' and resolved_at > now() - interval '30 days'),
    (select count(*)::integer from public.adoptions
      where status = 'adopted' and updated_at > now() - interval '30 days'),
    (select count(*)::integer from public.sos_reports
      where kind = 'lost' and status = 'active'),
    (select count(*)::integer from public.businesses
      where status = 'active' and verification = 'verified' and not is_sample);
$$;

-- ---------------------------------------------------------------------
-- Reencuentros: los comparte (o los quita) el autor del SOS
-- ---------------------------------------------------------------------

create function public.compartir_reencuentro(p_sos uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r public.sos_reports;
  foto text;
begin
  select * into r from public.sos_reports where id = p_sos and user_id = yo;
  if not found or r.status <> 'resolved' then
    raise exception 'No es tu reporte o todavía no se resolvió' using errcode = '42501';
  end if;
  select ph.path into foto from public.sos_photos ph where ph.report_id = r.id order by ph.sort limit 1;
  insert into public.community_updates (kind, sos_id, name, detail, species_id, amount, photo_path, zone_id)
  values ('reencuentro', r.id, r.name, r.kind::text, r.species_id,
          least(greatest(extract(day from coalesce(r.resolved_at, now()) - r.happened_at), 0), 365)::smallint,
          foto, r.zone_id)
  on conflict (sos_id) do update set status = 'visible';
  insert into public.events (name, anon_id, user_id, target_id)
  values ('community_share', gen_random_uuid(), yo, r.id::text);
end;
$$;

create function public.quitar_reencuentro(p_sos uuid)
returns void
language sql security definer set search_path = ''
as $$
  delete from public.community_updates u
  using public.sos_reports r
  where u.sos_id = p_sos and r.id = p_sos and r.user_id = (select auth.uid());
$$;

-- ¿Este reencuentro mío está compartido?
create function public.reencuentro_compartido(p_sos uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.community_updates u
    join public.sos_reports r on r.id = u.sos_id
    where u.sos_id = p_sos and r.user_id = (select auth.uid())
  );
$$;

-- ---------------------------------------------------------------------
-- Las demás se generan solas
-- ---------------------------------------------------------------------

create function public.novedad_de_adopcion()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  animales integer;
  primero public.adoption_animals;
begin
  if new.status = 'adopted' and old.status is distinct from 'adopted' then
    select count(*) into animales from public.adoption_animals where adoption_id = new.id;
    select * into primero from public.adoption_animals where adoption_id = new.id order by id limit 1;
    insert into public.community_updates (kind, adoption_id, name, species_id, amount, photo_path, zone_id)
    values ('adopcion', new.id, case when animales = 1 then primero.name end, primero.species_id,
            animales, 'adoption-photos/' || primero.photos[1], new.zone_id)
    on conflict (adoption_id) do nothing;
  end if;
  return new;
end;
$$;

create trigger adoptions_novedad
  after update of status on public.adoptions
  for each row execute function public.novedad_de_adopcion();

create function public.novedad_de_comercio()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if new.verification = 'verified' and new.status = 'active' and not new.is_sample
     and (tg_op = 'INSERT' or old.verification is distinct from 'verified') then
    insert into public.community_updates (kind, business_id, name, detail, zone_id)
    values ('comercio', new.id, new.name, new.business_type, new.zone_id)
    on conflict (business_id) do nothing;
  end if;
  return new;
end;
$$;

create trigger businesses_novedad
  after insert or update of verification on public.businesses
  for each row execute function public.novedad_de_comercio();

create function public.novedad_de_evento()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if new.status = 'active' then
    insert into public.community_updates (kind, event_id, name, detail, starts_at, zone_id)
    values ('evento', new.id, new.title, new.kind, new.starts_at, new.zone_id)
    on conflict (event_id) do nothing;
  end if;
  return new;
end;
$$;

create trigger events_calendar_novedad
  after insert on public.events_calendar
  for each row execute function public.novedad_de_evento();

-- Lo que ya había (sin reencuentros: nadie dio el consentimiento todavía).
insert into public.community_updates (kind, business_id, name, detail, zone_id, created_at)
select 'comercio', b.id, b.name, b.business_type, b.zone_id, b.created_at
from public.businesses b
where b.verification = 'verified' and b.status = 'active' and not b.is_sample;

insert into public.community_updates (kind, event_id, name, detail, starts_at, zone_id, created_at)
select 'evento', e.id, e.title, e.kind, e.starts_at, e.zone_id, e.created_at
from public.events_calendar e
where e.status = 'active' and e.ends_at > now();

-- ---------------------------------------------------------------------
-- Moderación (portal)
-- ---------------------------------------------------------------------

create function public.admin_novedades()
returns setof public.community_updates
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query select * from public.community_updates order by created_at desc limit 200;
end;
$$;

create function public.admin_estado_novedad(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_estado not in ('visible', 'hidden') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  update public.community_updates set status = p_estado where id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  perform public.registrar_accion('estado_novedad', 'community_updates', p_id::text,
                                  jsonb_build_object('estado', p_estado));
end;
$$;

revoke all on function public.novedades_comunidad() from public;
grant execute on function public.novedades_comunidad() to anon, authenticated;
revoke all on function public.resumen_comunidad() from public;
grant execute on function public.resumen_comunidad() to anon, authenticated;
revoke all on function public.compartir_reencuentro(uuid) from public, anon;
grant execute on function public.compartir_reencuentro(uuid) to authenticated;
revoke all on function public.quitar_reencuentro(uuid) from public, anon;
grant execute on function public.quitar_reencuentro(uuid) to authenticated;
revoke all on function public.reencuentro_compartido(uuid) from public, anon;
grant execute on function public.reencuentro_compartido(uuid) to authenticated;
revoke all on function public.admin_novedades() from public, anon;
grant execute on function public.admin_novedades() to authenticated;
revoke all on function public.admin_estado_novedad(uuid, text) from public, anon;
grant execute on function public.admin_estado_novedad(uuid, text) to authenticated;
-- Las de los disparadores no se llaman desde afuera.
revoke all on function public.novedad_de_adopcion() from public, anon, authenticated;
revoke all on function public.novedad_de_comercio() from public, anon, authenticated;
revoke all on function public.novedad_de_evento() from public, anon, authenticated;
