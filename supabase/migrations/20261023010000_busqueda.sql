-- Paso 1.8.7: búsqueda de lugares y demanda sin cubrir (D97).
-- La búsqueda es de lectura para todos (como el mapa) y solo devuelve lo
-- público de los lugares activos. El rubro lo reconoce la app
-- (`rubroDeBusqueda()` en packages/core) y llega en `p_rubro`.
-- Sin Places ni geocodificación (regla de costo del mapa).

-- Minúsculas y sin tildes (sin depender de la extensión unaccent).
create function public.normalizar_busqueda(p_texto text)
returns text
language sql
immutable
set search_path = ''
as $$
  select regexp_replace(
    translate(lower(trim(coalesce(p_texto, ''))),
              'áàäâéèëêíìïîóòöôúùüûñ', 'aaaaeeeeiiiioooouuuun'),
    '\s+', ' ', 'g');
$$;

-- Lugares por nombre o rubro cerca de un punto (25 km los que tienen local;
-- los "sin local", de la zona). Hasta 30, los más cercanos primero.
-- Devuelve también la zona del punto, para la métrica `search`.
create function public.buscar_lugares(
  p_texto text,
  p_rubro text,
  p_lat double precision,
  p_lng double precision
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  t text := public.normalizar_busqueda(left(p_texto, 60));
  patron text;
  punto extensions.geography;
  zona smallint;
  lugares jsonb;
begin
  if char_length(t) < 2 or p_lat is null or p_lng is null then
    return jsonb_build_object('zona', null, 'lugares', '[]'::jsonb);
  end if;
  -- El texto se busca tal cual: % y _ no son comodines.
  patron := '%' || replace(replace(replace(t, '\', '\\'), '%', '\%'), '_', '\_') || '%';
  punto := extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography;
  select z.id into zona from public.zones z
    where z.active and extensions.st_covers(z.area, punto) limit 1;

  select coalesce(jsonb_agg(to_jsonb(r) - 'distancia' order by r.distancia nulls last, r.name), '[]'::jsonb)
    into lugares
  from (
    select b.id, b.business_type, b.kind, b.name, b.description, b.address,
           extensions.st_y(b.location::extensions.geometry) as lat,
           extensions.st_x(b.location::extensions.geometry) as lng,
           b.phone, b.whatsapp, b.web, b.instagram, b.facebook,
           case when b.plan <> 'basic' then b.promo end as promo, b.plan, b.coverage,
           b.hours, b.special_days, b.is_24h,
           b.emergencies, b.species_ids, b.verification = 'verified' as verified,
           b.renac_operator, b.is_sample, b.owner_id is not null as has_owner,
           array(select f.path from public.business_photos f
                 where f.business_id = b.id order by f.sort, f.created_at) as photos,
           extensions.st_distance(b.location, punto) as distancia
    from public.businesses b
    where b.status = 'active'
      and (public.normalizar_busqueda(b.name) like patron
           or b.business_type = p_rubro)
      and ((b.kind = 'local' and extensions.st_dwithin(b.location, punto, 25000))
           or (b.kind <> 'local' and zona is not null and b.zone_id = zona))
    order by distancia nulls last, b.name
    limit 30
  ) r;

  return jsonb_build_object('zona', zona, 'lugares', lugares);
end;
$$;

revoke all on function public.buscar_lugares(text, text, double precision, double precision) from public;
grant execute on function public.buscar_lugares(text, text, double precision, double precision)
  to anon, authenticated;

-- ---------------------------------------------------------------------
-- Portal: demanda sin cubrir (05). Búsquedas por rubro contra los lugares
-- activos de ese rubro, y los textos sin rubro que no encontraron nada.
-- ---------------------------------------------------------------------
create function public.admin_demanda(p_zona smallint default null, p_dias integer default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
begin
  perform public.exigir_admin();
  return jsonb_build_object(
    'por_rubro', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'rubro', x.rubro, 'busquedas', x.busquedas,
               'sin_resultados', x.sin_resultados, 'lugares', x.lugares)
             order by x.sin_resultados desc, x.busquedas desc), '[]'::jsonb)
      from (
        select e.props ->> 'rubro' as rubro,
               count(*) as busquedas,
               count(*) filter (where (e.props ->> 'resultados')::int = 0) as sin_resultados,
               (select count(*) from public.businesses b
                where b.status = 'active' and not b.is_sample
                  and b.business_type = e.props ->> 'rubro'
                  and (p_zona is null or b.zone_id = p_zona)) as lugares
        from public.events e
        where e.name = 'search' and e.created_at >= desde
          and e.props ->> 'rubro' is not null
          and (p_zona is null or e.zone_id = p_zona)
        group by e.props ->> 'rubro'
      ) x),
    'textos_sin_resultado', (
      select coalesce(jsonb_agg(jsonb_build_object('texto', y.texto, 'veces', y.veces)
             order by y.veces desc, y.texto), '[]'::jsonb)
      from (
        select e.props ->> 'texto' as texto, count(*) as veces
        from public.events e
        where e.name = 'search' and e.created_at >= desde
          and e.props ->> 'texto' is not null
          and (p_zona is null or e.zone_id = p_zona)
        group by e.props ->> 'texto'
        order by count(*) desc
        limit 20
      ) y)
  );
end;
$$;

revoke all on function public.admin_demanda(smallint, integer) from public, anon;
grant execute on function public.admin_demanda(smallint, integer) to authenticated;
