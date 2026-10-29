-- Tope de mascotas del plan Gratis: vuelve a 2 (D118, revierte el 5 de D111).
-- Un solo lugar para el número: lo usan el trigger y mi_plan_usuario().
-- Quien ya tiene más de 2 las conserva; solo no puede sumar otra.

create function public.tope_mascotas_gratis()
returns integer
language sql
immutable
set search_path = ''
as $$ select 2 $$;

revoke all on function public.tope_mascotas_gratis() from public, anon, authenticated;

create or replace function public.limite_mascotas()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.funcionalidad_activa('planes_usuario')
     and not public.es_pro(new.owner_id)
     and (select count(*) from public.pets where owner_id = new.owner_id) >= public.tope_mascotas_gratis() then
    raise exception 'limite_mascotas' using errcode = 'P0001',
      hint = 'Con el plan Gratis podés tener hasta 2 mascotas.';
  end if;
  return new;
end;
$$;

create or replace function public.mi_plan_usuario()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  s public.subscriptions;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select * into s from public.subscriptions
   where owner_type = 'user' and owner_id = yo and status in ('active', 'past_due', 'cancelled')
   order by created_at desc limit 1;
  return jsonb_build_object(
    'plan', (select plan::text from public.profiles where id = yo),
    'efectivo', public.plan_efectivo(yo),
    'por_hogar', public.plan_efectivo(yo) = 'family'
                 and (select plan from public.profiles where id = yo) <> 'family',
    'estado', s.status,
    'vence', s.period_end,
    'prueba', s.trial,
    'precio', s.price,
    'moneda', s.currency,
    'mascotas', (select count(*) from public.pets where owner_id = yo),
    'limite_mascotas', case when public.funcionalidad_activa('planes_usuario')
                                 and not public.es_pro(yo) then public.tope_mascotas_gratis() end,
    'prueba_familia_usada', exists (select 1 from public.subscriptions x
                                    where x.owner_type = 'user' and x.owner_id = yo
                                      and x.plan = 'family' and x.trial),
    'pedido_abierto', (select r.plan from public.user_plan_requests r
                       where r.user_id = yo and r.status = 'open')
  );
end;
$$;
