-- Paso 1.8.7 (corrección): admin_demanda() fallaba con "subquery uses
-- ungrouped column": los lugares por rubro se cuentan fuera del group by.

create or replace function public.admin_demanda(p_zona smallint default null, p_dias integer default 30)
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
               'sin_resultados', x.sin_resultados,
               'lugares', (select count(*) from public.businesses b
                           where b.status = 'active' and not b.is_sample
                             and b.business_type = x.rubro
                             and (p_zona is null or b.zone_id = p_zona)))
             order by x.sin_resultados desc, x.busquedas desc), '[]'::jsonb)
      from (
        select e.props ->> 'rubro' as rubro,
               count(*) as busquedas,
               count(*) filter (where (e.props ->> 'resultados')::int = 0) as sin_resultados
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
