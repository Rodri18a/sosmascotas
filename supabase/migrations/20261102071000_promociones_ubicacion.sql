-- D136: la promoción trae el punto del comercio, para abrir su ficha del
-- mapa al tocarla (la app la busca en ese punto con lugares_en_zona).
drop function public.promociones_cerca(double precision, double precision, double precision, integer);
create function public.promociones_cerca(p_lat double precision, p_lng double precision,
                                         p_km double precision default 15, p_limite integer default 3)
returns table (id uuid, business_id uuid, negocio text, title text, body text, photo_path text,
               lat double precision, lng double precision)
language sql stable security definer set search_path = ''
as $$
  select p.id, b.id, b.name, p.title, p.body, p.photo_path,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry)
  from public.promotions p
  join public.businesses b on b.id = p.business_id
  where p.status = 'active' and p.ends_at > now()
    and b.status = 'active' and b.plan::text in ('featured', 'plus')
    and b.location is not null
    and extensions.st_dwithin(
          b.location,
          extensions.st_point(p_lng, p_lat)::extensions.geography,
          least(greatest(p_km, 1), 50) * 1000)
  -- Rota: el orden cambia cada hora, igual para todos.
  order by md5(p.id::text || to_char(now(), 'YYYYMMDDHH24'))
  limit least(greatest(p_limite, 1), 5);
$$;

revoke all on function public.promociones_cerca(double precision, double precision, double precision, integer) from public;
grant execute on function public.promociones_cerca(double precision, double precision, double precision, integer) to anon, authenticated;
