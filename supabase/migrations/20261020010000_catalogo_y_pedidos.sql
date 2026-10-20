-- Etapa 2.5 (catálogo con "Consultar") y 3.2 (pedidos), D85. Detrás de la
-- funcionalidad `catalogo` en la app.
--  · El catálogo es un módulo del comercio: activo solo con plan Plus, si el
--    tipo lo admite (veterinaria, petshop, farmacia, tienda online) y si la
--    empresa lo prendió (modulo_activo(), D81).
--  · Lo ve cualquiera, también visitantes (prima la información, D84). Un
--    producto sin precio solo se puede "Consultar".
--  · Pedidos: cantidades y total; estados nuevo → preparando → listo →
--    entregado (o cancelado). El pago es directo al comercio (en la app, en
--    la Fase 4). El comercio ve solo el primer nombre de quien pide: nunca su
--    teléfono (contacto inverso: se hablan por el chat de la app).
--  · Ninguna tabla se lee directo: todo pasa por funciones.

create table public.catalog_items (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  name         text not null check (char_length(trim(name)) between 2 and 80),
  description  text check (char_length(description) <= 500),
  price        numeric(10, 2) check (price is null or (price >= 0 and price <= 1000000)),  -- null: "Consultar precio"
  photo_path   text check (char_length(photo_path) <= 200),
  available    boolean not null default true,
  species_ids  smallint[] not null default '{}',
  sort         smallint not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.catalog_items is
  'Catálogo de un comercio (2.5, D85). Sin acceso directo: catalogo_de(), mi_catalogo(), guardar_producto().';

create index catalog_items_business_idx on public.catalog_items (business_id, sort, name);

create trigger catalog_items_updated_at
  before update on public.catalog_items
  for each row execute function public.set_updated_at();

alter table public.catalog_items enable row level security;
revoke all on public.catalog_items from anon, authenticated;

create table public.orders (
  id           uuid primary key default gen_random_uuid(),
  number       bigint generated always as identity,
  business_id  uuid not null references public.businesses (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  status       text not null default 'new'
               check (status in ('new', 'preparing', 'ready', 'delivered', 'cancelled')),
  note         text check (char_length(note) <= 300),
  total        numeric(12, 2) not null check (total >= 0),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.orders is
  'Pedidos (3.2, D85). Sin acceso directo: hacer_pedido(), mis_pedidos(), pedidos_del_negocio().';

create index orders_user_idx on public.orders (user_id, created_at desc);
create index orders_business_idx on public.orders (business_id, created_at desc);

create trigger orders_updated_at
  before update on public.orders
  for each row execute function public.set_updated_at();

alter table public.orders enable row level security;
revoke all on public.orders from anon, authenticated;

-- Cada renglón guarda el nombre y el precio del momento (el producto puede
-- cambiar o borrarse después).
create table public.order_items (
  id          bigint generated always as identity primary key,
  order_id    uuid not null references public.orders (id) on delete cascade,
  item_id     uuid references public.catalog_items (id) on delete set null,
  name        text not null,
  unit_price  numeric(10, 2) not null,
  qty         smallint not null check (qty between 1 and 99)
);

create index order_items_order_idx on public.order_items (order_id);

alter table public.order_items enable row level security;
revoke all on public.order_items from anon, authenticated;

-- ---------------------------------------------------------------------
-- Catálogo
-- ---------------------------------------------------------------------

-- Lo que se muestra al público: solo si el módulo está activo.
create function public.catalogo_de(p_negocio uuid)
returns table (id uuid, name text, description text, price numeric, photo_path text,
               species_ids smallint[])
language sql stable security definer set search_path = ''
as $$
  select i.id, i.name, i.description, i.price, i.photo_path, i.species_ids
  from public.catalog_items i
  where i.business_id = p_negocio and i.available
    and public.modulo_activo(p_negocio, 'catalogo')
  order by i.sort, i.name
  limit 300;
$$;

-- El dueño ve todo (también lo no disponible), aunque el módulo esté apagado.
create function public.mi_catalogo(p_negocio uuid)
returns table (id uuid, name text, description text, price numeric, photo_path text,
               species_ids smallint[], available boolean, sort smallint)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select i.id, i.name, i.description, i.price, i.photo_path, i.species_ids, i.available, i.sort
  from public.catalog_items i
  where i.business_id = p_negocio
  order by i.sort, i.name;
end;
$$;

-- Crea (sin `id`) o actualiza un producto. Hace falta el plan Plus y que el
-- tipo admita el catálogo (se puede cargar antes de prenderlo).
create function public.guardar_producto(p_negocio uuid, p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  foto text := nullif(p ->> 'photo_path', '');
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
  if foto is not null and foto !~ ('^' || p_negocio::text || '/catalogo/[A-Za-z0-9._-]+$') then
    raise exception 'Foto inválida' using errcode = '22023';
  end if;
  if id_ is null then
    if (select count(*) from public.catalog_items where business_id = p_negocio) >= 200 then
      raise exception 'Máximo 200 productos' using errcode = '54000';
    end if;
    insert into public.catalog_items (business_id, name, description, price, photo_path, available,
                                      species_ids, sort)
    values (p_negocio, trim(p ->> 'name'), nullif(trim(p ->> 'description'), ''),
            (p ->> 'price')::numeric, foto, coalesce((p ->> 'available')::boolean, true),
            coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
            coalesce((p ->> 'sort')::smallint, 0))
    returning id into id_;
  else
    update public.catalog_items set
      name = trim(p ->> 'name'), description = nullif(trim(p ->> 'description'), ''),
      price = (p ->> 'price')::numeric, photo_path = foto,
      available = coalesce((p ->> 'available')::boolean, true),
      species_ids = coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
      sort = coalesce((p ->> 'sort')::smallint, sort)
    where id = id_ and business_id = p_negocio;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  end if;
  return id_;
end;
$$;

create function public.borrar_producto(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.catalog_items i
  where i.id = p_id and public.soy_duenio_de(i.business_id);
  if not found then raise exception 'No es tuyo' using errcode = '42501'; end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Pedidos
-- ---------------------------------------------------------------------

-- p_items: [{"id": "<producto>", "qty": 2}, ...]. Los precios y el total los
-- pone la base (nunca la app).
create function public.hacer_pedido(p_negocio uuid, p_items jsonb, p_nota text default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  id_ uuid;
  pedidos integer;
  renglones integer;
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

  insert into public.orders (business_id, user_id, note, total)
  values (p_negocio, yo, nullif(trim(p_nota), ''), 0)
  returning id into id_;
  insert into public.order_items (order_id, item_id, name, unit_price, qty)
  select id_, i.id, i.name, i.price, (e ->> 'qty')::smallint
  from jsonb_array_elements(p_items) e
  join public.catalog_items i on i.id = (e ->> 'id')::uuid;
  update public.orders o
     set total = (select sum(r.unit_price * r.qty) from public.order_items r where r.order_id = id_)
   where o.id = id_;
  return id_;
end;
$$;

-- Los renglones de un pedido, como JSON (para las dos listas).
create function public.renglones_pedido(p_pedido uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object('name', r.name, 'unit_price', r.unit_price, 'qty', r.qty)
                            order by r.id), '[]'::jsonb)
  from public.order_items r where r.order_id = p_pedido;
$$;

create function public.mis_pedidos()
returns table (id uuid, number bigint, business_id uuid, business_name text, status text,
               note text, total numeric, created_at timestamptz, updated_at timestamptz, items jsonb)
language sql stable security definer set search_path = ''
as $$
  select o.id, o.number, o.business_id, b.name, o.status, o.note, o.total, o.created_at, o.updated_at,
         public.renglones_pedido(o.id)
  from public.orders o join public.businesses b on b.id = o.business_id
  where o.user_id = (select auth.uid())
  order by o.created_at desc
  limit 100;
$$;

-- Para el comercio: los abiertos primero. De quien pide, solo el primer nombre.
create function public.pedidos_del_negocio(p_negocio uuid)
returns table (id uuid, number bigint, cliente text, status text, note text, total numeric,
               created_at timestamptz, updated_at timestamptz, items jsonb)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select o.id, o.number, split_part(coalesce(p.display_name, ''), ' ', 1), o.status, o.note, o.total,
         o.created_at, o.updated_at, public.renglones_pedido(o.id)
  from public.orders o left join public.profiles p on p.id = o.user_id
  where o.business_id = p_negocio
  order by o.status in ('delivered', 'cancelled'), o.created_at desc
  limit 200;
end;
$$;

-- El comercio avanza el pedido de a un paso o lo cancela (antes de
-- entregarlo). Quien pidió solo puede cancelarlo mientras está "nuevo".
create function public.cambiar_estado_pedido(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  pedido record;
begin
  select o.status, o.user_id, o.business_id into pedido from public.orders o where o.id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if public.soy_duenio_de(pedido.business_id) then
    if not ((pedido.status, p_estado) in (('new', 'preparing'), ('preparing', 'ready'), ('ready', 'delivered'))
            or (p_estado = 'cancelled' and pedido.status not in ('delivered', 'cancelled'))) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
  elsif pedido.user_id = yo then
    if not (p_estado = 'cancelled' and pedido.status = 'new') then
      raise exception 'Solo podés cancelarlo mientras es nuevo' using errcode = '42501';
    end if;
  else
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  update public.orders set status = p_estado where id = p_id;
end;
$$;

-- Lo que el panel del comercio necesita contar.
create function public.pedidos_nuevos(p_negocio uuid)
returns integer
language sql stable security definer set search_path = ''
as $$
  select case when public.soy_duenio_de(p_negocio)
    then (select count(*)::int from public.orders where business_id = p_negocio and status = 'new')
    else 0 end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'mi_catalogo(uuid)', 'guardar_producto(uuid, jsonb)', 'borrar_producto(uuid)',
    'hacer_pedido(uuid, jsonb, text)', 'mis_pedidos()', 'pedidos_del_negocio(uuid)',
    'cambiar_estado_pedido(uuid, text)', 'pedidos_nuevos(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

revoke all on function public.renglones_pedido(uuid) from public, anon, authenticated;
revoke all on function public.catalogo_de(uuid) from public;
grant execute on function public.catalogo_de(uuid) to anon, authenticated;
