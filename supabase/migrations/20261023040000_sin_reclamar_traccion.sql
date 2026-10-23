-- Paso 1.8.5 (resto): tracción de los lugares sin reclamar en el portal (D99).
-- Se agrupan como en el mapa (mismo rubro, a menos de ~30 m) y se cuentan las
-- personas que marcaron y las aperturas de la hoja (`unclaimed_open`, con el
-- id de una marca del grupo en `target_id`). Solo administración.

create function public.admin_sin_reclamar(p_dias integer default 30)
returns table (grupo text, category text, lat double precision, lng double precision,
               marcas integer, aperturas bigint, primera_marca timestamptz, google_link text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
begin
  perform public.exigir_admin();
  return query
  with marcas as (
    select m.*, extensions.st_clusterdbscan(m.location::extensions.geometry, eps := 0.0003, minpoints := 1)
             over (partition by m.category) as cl
    from public.place_marks m
    where m.business_id is null
  ),
  grupos as (
    select g.category || ':' || min(g.id::text) as grupo,
           g.category,
           avg(extensions.st_y(g.location::extensions.geometry)) as lat,
           avg(extensions.st_x(g.location::extensions.geometry)) as lng,
           count(distinct g.user_id)::int as marcas,
           min(g.created_at) as primera_marca,
           max(g.google_link) as google_link,
           array_agg(g.id::text) as ids
    from marcas g
    group by g.category, g.cl
  )
  select gr.grupo, gr.category, gr.lat, gr.lng, gr.marcas,
         (select count(*) from public.events e
          where e.name = 'unclaimed_open' and e.created_at >= desde
            and e.target_id = any (gr.ids)),
         gr.primera_marca, gr.google_link
  from grupos gr
  order by 5 desc, 6 desc, gr.primera_marca
  limit 200;
end;
$$;

revoke all on function public.admin_sin_reclamar(integer) from public, anon;
grant execute on function public.admin_sin_reclamar(integer) to authenticated;
