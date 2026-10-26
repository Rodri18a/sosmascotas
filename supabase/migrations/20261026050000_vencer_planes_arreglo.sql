-- Arreglo de vencer_planes() (2.2, D103): dentro de la misma sentencia, la
-- consulta «¿tiene otra vigente?» veía todavía como «con atraso» la
-- suscripción que se acababa de vencer, y el comercio no volvía a Básico.
-- Ahora se excluyen las que se vencieron en esa misma pasada.
create or replace function public.vencer_planes()
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  hoy date := public.dia_uy(now());
  n integer := 0;
  c integer;
begin
  -- Período vencido sin pago: con atraso (sigue el plan 7 días de gracia).
  update public.subscriptions set status = 'past_due'
   where status = 'active' and period_end < hoy;
  -- Atraso de más de 7 días, o baja con el período terminado: vence.
  with vencidas as (
    update public.subscriptions set status = 'expired'
     where (status = 'past_due' and period_end < hoy - 7)
        or (status = 'cancelled' and period_end < hoy)
    returning id, owner_type, owner_id
  )
  update public.businesses b set plan = 'basic'
    from vencidas v
   where v.owner_type = 'business' and b.id = v.owner_id and b.plan <> 'basic'
     and not exists (select 1 from public.subscriptions s where s.owner_type = 'business'
                       and s.owner_id = b.id and s.status in ('active', 'past_due')
                       and s.id not in (select x.id from vencidas x));
  get diagnostics c = row_count;
  n := n + c;
  -- Socio Fundador sin suscripción: vuelve a Básico al terminar su fecha.
  update public.businesses b set plan = 'basic'
   where b.plan <> 'basic' and b.founder_until is not null and b.founder_until < hoy
     and not exists (select 1 from public.subscriptions s where s.owner_type = 'business'
                       and s.owner_id = b.id and s.status in ('active', 'past_due'));
  get diagnostics c = row_count;
  return n + c;
end;
$$;

revoke all on function public.vencer_planes() from public, anon, authenticated;
