-- Paso 0.5.4: consultas públicas de SOS (las usa cualquiera, con o sin cuenta).
-- Solo reportes activos y siempre con la ubicación APROXIMADA.

-- Pines de la zona visible del mapa: datos mínimos (regla de costo del mapa).
create function public.sos_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision
)
returns table (id uuid, kind public.sos_kind, lat double precision, lng double precision)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.kind,
         extensions.st_y(r.public_location::extensions.geometry),
         extensions.st_x(r.public_location::extensions.geometry)
  from public.sos_reports r
  where r.status = 'active'
    and r.public_location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by r.created_at desc
  limit 300;
$$;

revoke execute on function public.sos_en_zona(double precision, double precision, double precision, double precision) from public;
grant execute on function public.sos_en_zona(double precision, double precision, double precision, double precision) to anon, authenticated;

-- Lista ordenada por cercanía a un punto (dentro de 50 km), con lo justo para la tarjeta.
create function public.sos_cercanos(
  p_lat double precision, p_lng double precision, p_limite integer default 50
)
returns table (
  id uuid, kind public.sos_kind, name text, species text, species_icon text,
  breed text, color text, happened_at timestamptz, created_at timestamptz,
  distance_m double precision, photo text
)
language sql
stable
security definer
set search_path = ''
as $$
  with yo as (
    select extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography as punto
  )
  select r.id, r.kind, r.name, s.name, s.icon, coalesce(b.name, r.breed_other), r.color,
         r.happened_at, r.created_at,
         extensions.st_distance(r.public_location, yo.punto),
         (select f.path from public.sos_photos f where f.report_id = r.id order by f.sort limit 1)
  from public.sos_reports r
  cross join yo
  join public.species s on s.id = r.species_id
  left join public.breeds b on b.id = r.breed_id
  where r.status = 'active'
    and extensions.st_dwithin(r.public_location, yo.punto, 50000)
  order by r.public_location operator(extensions.<->) yo.punto
  limit least(greatest(coalesce(p_limite, 50), 1), 100);
$$;

revoke execute on function public.sos_cercanos(double precision, double precision, integer) from public;
grant execute on function public.sos_cercanos(double precision, double precision, integer) to anon, authenticated;
