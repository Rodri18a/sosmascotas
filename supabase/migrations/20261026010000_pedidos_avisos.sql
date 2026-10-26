-- Etapa 3.2 (D100): aviso push en cada cambio de estado del pedido y estado
-- en vivo. Detrás de `catalogo`, como el resto de los pedidos.
--  · Push: la app llama a la Edge Function `order-status-alert` después de
--    pedir o de cambiar el estado; la función pregunta acá a quién avisar
--    (avisar_pedido(), solo service_role). Avisa a la otra parte: el pedido
--    nuevo y la cancelación de quien pidió, al comercio; preparando, listo,
--    entregado y la cancelación del comercio, a quien pidió. Una sola vez por
--    pedido y estado (order_notifications), aunque la app reintente.
--  · En vivo: cada cambio de estado se difunde por Realtime (Broadcast desde
--    la base, canales privados) solo con el id y el estado; la app vuelve a
--    pedir la lista con las funciones de siempre. Las tablas siguen sin
--    acceso directo.

-- Quién canceló, para saber a quién avisar.
alter table public.orders
  add column cancelled_by text check (cancelled_by in ('cliente', 'negocio'));

create table public.order_notifications (
  order_id     uuid not null references public.orders (id) on delete cascade,
  status       text not null,
  notified_at  timestamptz not null default now(),
  primary key (order_id, status)
);

comment on table public.order_notifications is
  'Avisos push ya mandados por pedido y estado (3.2, D100). Solo service_role, vía avisar_pedido().';

alter table public.order_notifications enable row level security;
revoke all on public.order_notifications from anon, authenticated;

-- Igual que antes, pero anota quién canceló.
create or replace function public.cambiar_estado_pedido(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  pedido record;
  quien text;
begin
  select o.status, o.user_id, o.business_id into pedido from public.orders o where o.id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if public.soy_duenio_de(pedido.business_id) then
    if not ((pedido.status, p_estado) in (('new', 'preparing'), ('preparing', 'ready'), ('ready', 'delivered'))
            or (p_estado = 'cancelled' and pedido.status not in ('delivered', 'cancelled'))) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
    quien := 'negocio';
  elsif pedido.user_id = yo then
    if not (p_estado = 'cancelled' and pedido.status = 'new') then
      raise exception 'Solo podés cancelarlo mientras es nuevo' using errcode = '42501';
    end if;
    quien := 'cliente';
  else
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  update public.orders
     set status = p_estado,
         cancelled_by = case when p_estado = 'cancelled' then quien end
   where id = p_id;
end;
$$;

-- A quién avisar del estado actual del pedido. p_actor es quien hizo el
-- cambio (la Edge Function lo saca de la sesión). No devuelve nada si el
-- actor no es quien hizo ese cambio o si ya se avisó.
create function public.avisar_pedido(p_pedido uuid, p_actor uuid)
returns table (destino text, numero bigint, estado text, negocio text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  o record;
  receptor uuid;
  para text;
begin
  select x.status, x.number, x.user_id, x.cancelled_by, b.owner_id, b.name into o
  from public.orders x join public.businesses b on b.id = x.business_id
  where x.id = p_pedido;
  if not found then return; end if;
  if p_actor = o.user_id
     and (o.status = 'new' or (o.status = 'cancelled' and o.cancelled_by = 'cliente')) then
    receptor := o.owner_id;
    para := 'negocio';
  elsif p_actor = o.owner_id
     and (o.status in ('preparing', 'ready', 'delivered')
          or (o.status = 'cancelled' and o.cancelled_by = 'negocio')) then
    receptor := o.user_id;
    para := 'cliente';
  end if;
  -- Sin dueño, o un pedido al propio comercio: no hay a quién avisar.
  if receptor is null or receptor = p_actor then return; end if;
  insert into public.order_notifications (order_id, status) values (p_pedido, o.status)
    on conflict do nothing;
  if not found then return; end if;
  return query
  select para, o.number, o.status, o.name,
         array(select t.token from public.push_tokens t where t.user_id = receptor);
end;
$$;

revoke execute on function public.avisar_pedido(uuid, uuid) from public, anon, authenticated;
grant execute on function public.avisar_pedido(uuid, uuid) to service_role;

-- ---------------------------------------------------------------------
-- En vivo
-- ---------------------------------------------------------------------

-- Canales: `pedidos:cliente:<usuario>` (Mis pedidos) y
-- `pedidos:negocio:<comercio>` (modo comercio → Pedidos).
create function public.puedo_escuchar_pedidos(p_canal text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when p_canal = 'pedidos:cliente:' || (select auth.uid())::text then true
    when p_canal ~ '^pedidos:negocio:[0-9a-f-]{36}$'
      then public.soy_duenio_de(substr(p_canal, 17)::uuid)
    else false
  end;
$$;

revoke all on function public.puedo_escuchar_pedidos(text) from public, anon;
grant execute on function public.puedo_escuchar_pedidos(text) to authenticated;

-- Solo escuchar (sin política de insert: nadie difunde desde la app).
create policy "pedidos en vivo: cada uno los suyos"
  on realtime.messages for select to authenticated
  using (realtime.messages.extension = 'broadcast'
         and public.puedo_escuchar_pedidos((select realtime.topic())));

create function public.difundir_pedido()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  carga jsonb := jsonb_build_object('id', new.id, 'status', new.status);
begin
  -- Si Realtime falla, el pedido se guarda igual (la lista se actualiza al
  -- volver a abrirla).
  begin
    perform realtime.send(carga, 'pedido', 'pedidos:cliente:' || new.user_id::text, true);
    perform realtime.send(carga, 'pedido', 'pedidos:negocio:' || new.business_id::text, true);
  exception when others then
    raise warning 'No se pudo difundir el pedido %: %', new.id, sqlerrm;
  end;
  return null;
end;
$$;

revoke all on function public.difundir_pedido() from public, anon, authenticated;

create trigger orders_difundir
  after insert or update of status on public.orders
  for each row execute function public.difundir_pedido();
