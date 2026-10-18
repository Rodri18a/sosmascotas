-- La lista de SOS cercanos se ordenaba con el operador <-> (distancia en una
-- esfera) y mostraba st_distance (en el elipsoide): con dos reportes casi a la
-- misma distancia podían quedar al revés de lo que dice la tarjeta. Ahora se
-- ordena por la misma distancia que se muestra (dentro de 50 km son pocos).
create or replace function public.sos_cercanos(
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
         extensions.st_distance(r.public_location, yo.punto) as distancia,
         (select f.path from public.sos_photos f where f.report_id = r.id order by f.sort limit 1)
  from public.sos_reports r
  cross join yo
  join public.species s on s.id = r.species_id
  left join public.breeds b on b.id = r.breed_id
  where r.status = 'active'
    and extensions.st_dwithin(r.public_location, yo.punto, 50000)
  order by distancia, r.created_at desc
  limit least(greatest(coalesce(p_limite, 50), 1), 100);
$$;
