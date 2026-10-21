-- Paso 2.10b (D90): página pública del comercio en la web liviana
-- (/n/<id>), para compartir en redes. Solo comercios activos con plan Plus.
--  · Devuelve lo mismo que ya es público en el mapa (D84): datos del local,
--    contactos públicos, horario, fotos, especies, servicios visibles y el
--    catálogo si el módulo está prendido, más el promedio de reseñas.
--  · Nunca el dueño, el RUT ni los contactos privados.
--  · Si no es Plus (o no existe, o está oculto): {"status": "not_found"}.

create function public.pagina_comercio(p_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  b public.businesses;
begin
  select * into b from public.businesses where id = p_id;
  if not found or b.status <> 'active' or b.plan <> 'plus' then
    return jsonb_build_object('status', 'not_found');
  end if;

  return jsonb_build_object(
    'status', 'ok',
    'id', b.id,
    'business_type', b.business_type,
    'kind', b.kind,
    'name', b.name,
    'description', b.description,
    'address', b.address,
    'lat', extensions.st_y(b.location::extensions.geometry),
    'lng', extensions.st_x(b.location::extensions.geometry),
    'coverage', b.coverage,
    'phone', b.phone,
    'whatsapp', b.whatsapp,
    'web', b.web,
    'instagram', b.instagram,
    'facebook', b.facebook,
    'promo', b.promo,
    'hours', b.hours,
    'special_days', b.special_days,
    'is_24h', b.is_24h,
    'emergencies', b.emergencies,
    'verified', b.verification = 'verified',
    'renac_operator', b.renac_operator,
    'species', coalesce((select jsonb_agg(s.name order by s.id) from public.species s
                         where s.id = any (b.species_ids)), '[]'::jsonb),
    'photos', coalesce((select jsonb_agg(f.path order by f.sort, f.created_at)
                        from public.business_photos f where f.business_id = b.id), '[]'::jsonb),
    'services', coalesce((select jsonb_agg(jsonb_build_object(
                            'name', s.name, 'description', s.description, 'price', s.price,
                            'price_from', s.price_from, 'duration_min', s.duration_min)
                          order by s.sort, s.name)
                          from public.business_services s
                          where s.business_id = b.id and s.available), '[]'::jsonb),
    'products', case when public.modulo_activo(b.id, 'catalogo') then
                  coalesce((select jsonb_agg(jsonb_build_object(
                              'name', i.name, 'description', i.description, 'price', i.price,
                              'photo_path', i.photo_path)
                            order by i.sort, i.name)
                            from (select * from public.catalog_items
                                  where business_id = b.id and available
                                  order by sort, name limit 60) i), '[]'::jsonb)
                else '[]'::jsonb end,
    'rating', (select round(avg(r.rating)::numeric, 1) from public.reviews r
               where r.business_id = b.id and r.status = 'active'),
    'reviews', (select count(*) from public.reviews r
                where r.business_id = b.id and r.status = 'active')
  );
end;
$$;

revoke all on function public.pagina_comercio(uuid) from public;
grant execute on function public.pagina_comercio(uuid) to anon, authenticated;
