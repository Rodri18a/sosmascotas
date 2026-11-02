-- Plan de mejoras 3.2 (D137): informe de los espacios de publicidad para el
-- portal. Vistas y toques de cada promoción del muro y de cada banner del
-- carrusel en los últimos [p_dias] días, para vender y rendirle cuentas a cada
-- patrocinador. Los eventos ya son anónimos: acá solo se cuentan.
create function public.admin_espacios(p_dias integer default 30)
returns table (tipo text, id uuid, titulo text, de_quien text, estado text,
               vistas integer, personas integer, toques integer)
language plpgsql stable security definer set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => least(greatest(p_dias, 1), 365));
begin
  perform public.exigir_equipo(array['sales']);
  return query
  select 'promo'::text, p.id, p.title, b.name,
         case when p.status = 'active' and p.ends_at <= now() then 'ended' else p.status end,
         (select count(*)::int from public.events e
           where e.name = 'promo_view' and e.target_id = p.id and e.created_at >= desde),
         (select count(distinct e.anon_id)::int from public.events e
           where e.name = 'promo_view' and e.target_id = p.id and e.created_at >= desde),
         (select count(*)::int from public.events e
           where e.name = 'promo_click' and e.target_id = p.id and e.created_at >= desde)
  from public.promotions p
  join public.businesses b on b.id = p.business_id
  where p.created_at >= desde or (p.status = 'active' and p.ends_at > now())
  union all
  select 'banner'::text, bn.id, bn.title,
         case when bn.sponsored then bn.sponsor_name else null end,
         bn.status,
         (select count(*)::int from public.events e
           where e.name = 'banner_view' and e.target_id = bn.id and e.created_at >= desde),
         (select count(distinct e.anon_id)::int from public.events e
           where e.name = 'banner_view' and e.target_id = bn.id and e.created_at >= desde),
         (select count(*)::int from public.events e
           where e.name = 'banner_open' and e.target_id = bn.id and e.created_at >= desde)
  from public.banners bn
  where bn.status = 'published' or bn.updated_at >= desde
  order by 6 desc;
end;
$$;

revoke all on function public.admin_espacios(integer) from public, anon;
grant execute on function public.admin_espacios(integer) to authenticated;

-- Para contar rápido por objetivo.
create index if not exists events_target_idx on public.events (name, target_id, created_at)
  where target_id is not null;
