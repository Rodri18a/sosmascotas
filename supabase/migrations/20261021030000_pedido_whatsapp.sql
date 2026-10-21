-- Etapa 2.10c (D92): formas de pago y entrega del comercio, y el pedido por
-- WhatsApp. Detrás de la funcionalidad `catalogo` en la app.
--  · El comercio (plan Plus) dice qué formas de pago acepta y si hace retiro
--    en el local, envío gratis o con costo (y gratis desde cierto monto).
--  · Quien pide elige una forma de pago y una entrega entre las que ofrece;
--    el costo del envío y el total los calcula la base.
--  · La dirección de envío NO se guarda: se la pasa al comercio por WhatsApp.
--  · El pedido se guarda igual en la app (Mis pedidos y Pedidos del comercio)
--    y después la app arma el mensaje para el WhatsApp público del comercio.

create table public.order_settings (
  business_id         uuid primary key references public.businesses (id) on delete cascade,
  payment_methods     text[] not null default '{}'
                      check (payment_methods <@ array['cash', 'transfer', 'card', 'mercadopago']),
  pickup              boolean not null default true,
  shipping            boolean not null default false,
  shipping_cost       numeric(10, 2) check (shipping_cost is null or shipping_cost between 0 and 100000),  -- null o 0: gratis
  free_shipping_from  numeric(10, 2) check (free_shipping_from is null or free_shipping_from between 0 and 1000000),
  updated_at          timestamptz not null default now(),
  check (pickup or shipping)
);

comment on table public.order_settings is
  'Formas de pago y entrega de un comercio (2.10c, D92). Sin acceso directo: condiciones_pedido(), guardar_condiciones_pedido().';

create trigger order_settings_updated_at
  before update on public.order_settings
  for each row execute function public.set_updated_at();

alter table public.order_settings enable row level security;
revoke all on public.order_settings from anon, authenticated;

alter table public.orders
  add column payment_method text check (payment_method in ('cash', 'transfer', 'card', 'mercadopago')),
  add column delivery       text check (delivery in ('pickup', 'shipping')),
  add column shipping_cost  numeric(10, 2) not null default 0 check (shipping_cost >= 0);

-- Lo que se muestra al armar el pedido (también visitantes) y en el modo
-- comercio. null si el comercio no lo configuró.
create function public.condiciones_pedido(p_negocio uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'payment_methods', s.payment_methods, 'pickup', s.pickup, 'shipping', s.shipping,
    'shipping_cost', s.shipping_cost, 'free_shipping_from', s.free_shipping_from)
  from public.order_settings s
  where s.business_id = p_negocio;
$$;

-- El dueño, con plan Plus y un tipo que admita el catálogo.
create function public.guardar_condiciones_pedido(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not exists (
    select 1 from public.businesses
    where id = p_negocio and plan = 'plus'
      and public.modulo_admitido(business_type, kind, 'catalogo')
  ) then
    raise exception 'El catálogo necesita el plan Plus' using errcode = '42501';
  end if;
  insert into public.order_settings (business_id, payment_methods, pickup, shipping, shipping_cost,
                                     free_shipping_from)
  values (p_negocio,
          coalesce(array(select distinct jsonb_array_elements_text(p -> 'payment_methods')), '{}'),
          coalesce((p ->> 'pickup')::boolean, true), coalesce((p ->> 'shipping')::boolean, false),
          (p ->> 'shipping_cost')::numeric, (p ->> 'free_shipping_from')::numeric)
  on conflict (business_id) do update set
    payment_methods = excluded.payment_methods, pickup = excluded.pickup, shipping = excluded.shipping,
    shipping_cost = excluded.shipping_cost, free_shipping_from = excluded.free_shipping_from;
end;
$$;

-- hacer_pedido() suma la forma de pago y la entrega.
drop function public.hacer_pedido(uuid, jsonb, text);

create function public.hacer_pedido(p_negocio uuid, p_items jsonb, p_nota text default null,
                                    p_pago text default null, p_entrega text default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  id_ uuid;
  pedidos integer;
  renglones integer;
  cfg public.order_settings;
  subtotal numeric;
  envio numeric := 0;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if not public.modulo_activo(p_negocio, 'catalogo') then
    raise exception 'Este comercio no toma pedidos' using errcode = '42501';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) not between 1 and 30 then
    raise exception 'Entre 1 y 30 productos' using errcode = '22023';
  end if;
  select count(*) into pedidos from public.orders
  where user_id = yo and created_at > now() - interval '1 day';
  if pedidos >= 10 then
    raise exception 'Demasiados pedidos hoy' using errcode = '54000';
  end if;
  -- Cada producto: de este comercio, disponible, con precio y sin repetir.
  select count(*) into renglones
  from jsonb_array_elements(p_items) e
  join public.catalog_items i on i.id = (e ->> 'id')::uuid
  where i.business_id = p_negocio and i.available and i.price is not null
    and (e ->> 'qty')::int between 1 and 99;
  if renglones <> jsonb_array_length(p_items)
     or (select count(distinct e ->> 'id') from jsonb_array_elements(p_items) e) <> renglones then
    raise exception 'Hay productos que no se pueden pedir' using errcode = '22023';
  end if;
  -- Pago y entrega: entre lo que ofrece el comercio (si lo configuró).
  select * into cfg from public.order_settings where business_id = p_negocio;
  if found then
    if (cardinality(cfg.payment_methods) > 0 and (p_pago is null or not p_pago = any (cfg.payment_methods)))
       or (cardinality(cfg.payment_methods) = 0 and p_pago is not null) then
      raise exception 'Forma de pago inválida' using errcode = '22023';
    end if;
    if not ((p_entrega = 'pickup' and cfg.pickup) or (p_entrega = 'shipping' and cfg.shipping)) then
      raise exception 'Entrega inválida' using errcode = '22023';
    end if;
  elsif p_pago is not null or p_entrega is not null then
    raise exception 'Este comercio no configuró pago ni entrega' using errcode = '22023';
  end if;

  select sum(i.price * (e ->> 'qty')::int) into subtotal
  from jsonb_array_elements(p_items) e
  join public.catalog_items i on i.id = (e ->> 'id')::uuid;
  if p_entrega = 'shipping'
     and not (cfg.free_shipping_from is not null and subtotal >= cfg.free_shipping_from) then
    envio := coalesce(cfg.shipping_cost, 0);
  end if;

  insert into public.orders (business_id, user_id, note, total, payment_method, delivery, shipping_cost)
  values (p_negocio, yo, nullif(trim(p_nota), ''), 0, p_pago, p_entrega, envio)
  returning id into id_;
  insert into public.order_items (order_id, item_id, name, unit_price, qty)
  select id_, i.id, i.name, i.price, (e ->> 'qty')::smallint
  from jsonb_array_elements(p_items) e
  join public.catalog_items i on i.id = (e ->> 'id')::uuid;
  update public.orders o
     set total = (select sum(r.unit_price * r.qty) from public.order_items r where r.order_id = id_) + envio
   where o.id = id_;
  return id_;
end;
$$;

-- Las dos listas devuelven también el pago, la entrega y el envío.
drop function public.mis_pedidos();
drop function public.pedidos_del_negocio(uuid);

create function public.mis_pedidos()
returns table (id uuid, number bigint, business_id uuid, business_name text, status text,
               note text, total numeric, created_at timestamptz, updated_at timestamptz, items jsonb,
               payment_method text, delivery text, shipping_cost numeric)
language sql stable security definer set search_path = ''
as $$
  select o.id, o.number, o.business_id, b.name, o.status, o.note, o.total, o.created_at, o.updated_at,
         public.renglones_pedido(o.id), o.payment_method, o.delivery, o.shipping_cost
  from public.orders o join public.businesses b on b.id = o.business_id
  where o.user_id = (select auth.uid())
  order by o.created_at desc
  limit 100;
$$;

-- Para el comercio: los abiertos primero. De quien pide, solo el primer nombre.
create function public.pedidos_del_negocio(p_negocio uuid)
returns table (id uuid, number bigint, cliente text, status text, note text, total numeric,
               created_at timestamptz, updated_at timestamptz, items jsonb,
               payment_method text, delivery text, shipping_cost numeric)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select o.id, o.number, split_part(coalesce(p.display_name, ''), ' ', 1), o.status, o.note, o.total,
         o.created_at, o.updated_at, public.renglones_pedido(o.id), o.payment_method, o.delivery,
         o.shipping_cost
  from public.orders o left join public.profiles p on p.id = o.user_id
  where o.business_id = p_negocio
  order by o.status in ('delivered', 'cancelled'), o.created_at desc
  limit 200;
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'guardar_condiciones_pedido(uuid, jsonb)', 'hacer_pedido(uuid, jsonb, text, text, text)',
    'mis_pedidos()', 'pedidos_del_negocio(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

revoke all on function public.condiciones_pedido(uuid) from public;
grant execute on function public.condiciones_pedido(uuid) to anon, authenticated;
