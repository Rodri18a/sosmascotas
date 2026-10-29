-- Una mascota no puede tener dos reportes de perdida a la vez (prueba a mano
-- del 29/10: se reportó dos veces la misma). Cuenta como abierto un reporte
-- activo o en revisión (oculto); resuelto o archivado deja reportar de nuevo.

-- Los repetidos que ya había: queda el más viejo y se archivan los demás.
update public.sos_reports r
   set status = 'archived'
 where r.kind = 'lost'
   and r.pet_id is not null
   and r.status in ('active', 'hidden')
   and exists (select 1 from public.sos_reports o
                where o.pet_id = r.pet_id and o.kind = 'lost'
                  and o.status in ('active', 'hidden')
                  and (o.created_at, o.id) < (r.created_at, r.id));

-- El aviso claro para la app.
create function public.sos_una_perdida_por_mascota()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.kind = 'lost' and new.pet_id is not null
     and new.status in ('active', 'hidden')
     and exists (select 1 from public.sos_reports o
                  where o.pet_id = new.pet_id and o.kind = 'lost'
                    and o.status in ('active', 'hidden') and o.id <> new.id) then
    raise exception 'ya_reportada' using errcode = 'P0001',
      hint = 'Esta mascota ya tiene un reporte de perdida abierto.';
  end if;
  return new;
end;
$$;

revoke all on function public.sos_una_perdida_por_mascota() from public, anon, authenticated;

create trigger sos_reports_una_perdida_por_mascota
  before insert or update of status on public.sos_reports
  for each row execute function public.sos_una_perdida_por_mascota();

-- Y por si dos pedidos llegan al mismo tiempo.
create unique index sos_reports_una_perdida_abierta
  on public.sos_reports (pet_id)
  where kind = 'lost' and pet_id is not null and status in ('active', 'hidden');
