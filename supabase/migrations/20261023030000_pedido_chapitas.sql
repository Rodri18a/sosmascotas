-- Paso 1.8b.4: pedido de chapita con retiro en la veterinaria (D98).
-- El dueño la pide para una mascota y elige una veterinaria verificada que
-- aceptó ser punto de retiro. La administración le asigna un código libre de
-- un lote y la manda; la veterinaria marca que llegó y que la entregó, y en
-- ese momento la chapita queda vinculada a la mascota (sin escanearla).
-- Sin cargo por ahora: no se cobra antes de formalizar (1.9.0, P16).
-- Tabla sin acceso directo: todo por funciones, cada una con su permiso.

alter table public.businesses
  add column tag_pickup boolean not null default false;

comment on column public.businesses.tag_pickup is
  'La veterinaria aceptó ser punto de retiro de chapitas (solo verificadas).';

create table public.tag_orders (
  id           uuid primary key default gen_random_uuid(),
  number       bigint generated always as identity unique,
  pet_id       uuid not null references public.pets (id) on delete cascade,
  owner_id     uuid not null references auth.users (id) on delete cascade,
  business_id  uuid not null references public.businesses (id) on delete cascade,
  engraving    text not null check (char_length(engraving) between 1 and 20),
  status       text not null default 'new'
               check (status in ('new', 'sent', 'ready', 'delivered', 'cancelled')),
  tag_id       uuid unique references public.qr_tags (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.tag_orders is
  'Pedidos de chapitas físicas con retiro en una veterinaria. Sin acceso directo.';

-- Un pedido abierto por mascota.
create unique index tag_orders_uno_abierto on public.tag_orders (pet_id)
  where status in ('new', 'sent', 'ready');
create index tag_orders_negocio_idx on public.tag_orders (business_id, created_at);
create index tag_orders_dueno_idx on public.tag_orders (owner_id, created_at);

alter table public.tag_orders enable row level security;
-- Sin políticas: desde la app no se lee ni se escribe directo.
revoke all on public.tag_orders from anon, authenticated;

create trigger tag_orders_updated_at
  before update on public.tag_orders
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------
-- Dueño
-- ---------------------------------------------------------------------

-- Veterinarias verificadas que son punto de retiro, las más cercanas primero.
create function public.puntos_de_retiro(p_lat double precision, p_lng double precision)
returns table (id uuid, name text, address text, lat double precision, lng double precision)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.name, b.address,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry)
  from public.businesses b
  where b.status = 'active' and b.tag_pickup and b.business_type = 'vet'
    and b.verification = 'verified' and b.location is not null
  order by b.location operator(extensions.<->)
           extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography
  limit 20;
$$;

create function public.pedir_chapita(p_pet uuid, p_business uuid, p_texto text default null)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  mascota public.pets;
  texto text;
  pedido uuid;
begin
  if yo is null then
    raise exception 'Hace falta una cuenta' using errcode = '42501';
  end if;
  select * into mascota from public.pets where id = p_pet and owner_id = yo;
  if not found then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  if not exists (select 1 from public.businesses b
                 where b.id = p_business and b.status = 'active' and b.tag_pickup
                   and b.business_type = 'vet' and b.verification = 'verified') then
    raise exception 'no_es_punto_de_retiro' using errcode = 'P0001';
  end if;
  if (select count(*) from public.tag_orders
      where owner_id = yo and status in ('new', 'sent', 'ready')) >= 3 then
    raise exception 'demasiados_pedidos' using errcode = '54000';
  end if;
  texto := left(trim(coalesce(nullif(trim(p_texto), ''), mascota.name)), 20);

  -- Si ya hay uno abierto para la mascota, el índice único da 23505.
  insert into public.tag_orders (pet_id, owner_id, business_id, engraving)
  values (p_pet, yo, p_business, texto)
  returning id into pedido;
  return pedido;
end;
$$;

create function public.mis_pedidos_chapita()
returns table (id uuid, number bigint, pet_id uuid, pet_name text, business_id uuid,
               business_name text, business_address text, engraving text, status text,
               code text, created_at timestamptz, updated_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select o.id, o.number, o.pet_id, p.name, o.business_id, b.name, b.address, o.engraving,
         o.status, case when o.status = 'delivered' then t.code end, o.created_at, o.updated_at
  from public.tag_orders o
  join public.pets p on p.id = o.pet_id
  join public.businesses b on b.id = o.business_id
  left join public.qr_tags t on t.id = o.tag_id
  where o.owner_id = (select auth.uid())
  order by o.status in ('delivered', 'cancelled'), o.created_at desc
  limit 50;
$$;

-- Solo mientras nadie lo preparó.
create function public.cancelar_pedido_chapita(p_id uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  update public.tag_orders set status = 'cancelled'
   where id = p_id and owner_id = (select auth.uid()) and status = 'new';
  if not found then
    raise exception 'no_se_puede_cancelar' using errcode = 'P0001';
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Veterinaria (dueño del comercio)
-- ---------------------------------------------------------------------

create function public.prender_punto_retiro(p_business uuid, p_prender boolean)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_prender and not exists (select 1 from public.businesses
                               where id = p_business and business_type = 'vet'
                                 and verification = 'verified' and status = 'active') then
    raise exception 'solo_verificadas' using errcode = 'P0001';
  end if;
  update public.businesses set tag_pickup = coalesce(p_prender, false) where id = p_business;
end;
$$;

-- Si es punto de retiro y sus pedidos: solo el primer nombre de quien pide,
-- el nombre de la mascota y el texto a grabar (nada de contacto).
create function public.pedidos_chapita_del_negocio(p_business uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  b public.businesses;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select * into b from public.businesses where id = p_business;
  return jsonb_build_object(
    'punto_retiro', b.tag_pickup,
    'puede_ser', b.business_type = 'vet' and b.verification = 'verified',
    'pedidos', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'id', o.id, 'number', o.number,
               'cliente', split_part(coalesce(pr.display_name, ''), ' ', 1),
               'pet_name', p.name, 'engraving', o.engraving, 'status', o.status,
               'code', t.code, 'created_at', o.created_at, 'updated_at', o.updated_at)
             order by o.status = 'delivered', o.created_at desc), '[]'::jsonb)
      from public.tag_orders o
      join public.pets p on p.id = o.pet_id
      left join public.profiles pr on pr.id = o.owner_id
      left join public.qr_tags t on t.id = o.tag_id
      where o.business_id = p_business
        and (o.status in ('new', 'sent', 'ready')
             or (o.status = 'delivered' and o.updated_at > now() - interval '30 days'))));
end;
$$;

-- "Llegó" (sent → ready) y "Entregada" (ready → delivered). Al entregarla,
-- la chapita queda vinculada a la mascota de quien la pidió.
create function public.negocio_avanzar_pedido_chapita(p_id uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  o public.tag_orders;
  nuevo text;
begin
  select * into o from public.tag_orders where id = p_id for update;
  if not found or not public.soy_duenio_de(o.business_id) then
    raise exception 'No es un pedido de tu negocio' using errcode = '42501';
  end if;
  nuevo := case o.status when 'sent' then 'ready' when 'ready' then 'delivered' end;
  if nuevo is null then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  if nuevo = 'delivered' then
    update public.qr_tags
       set pet_id = o.pet_id, owner_id = o.owner_id, activated_at = now()
     where id = o.tag_id and kind = 'physical' and active
       and pet_id is null and activated_at is null;
    if not found then
      raise exception 'chapita_usada' using errcode = 'P0001';
    end if;
  end if;
  update public.tag_orders set status = nuevo where id = p_id;
  return nuevo;
end;
$$;

-- ---------------------------------------------------------------------
-- Administración
-- ---------------------------------------------------------------------

create function public.admin_pedidos_chapita(p_estado text default null)
returns table (id uuid, number bigint, cliente text, pet_name text, business_name text,
               business_address text, engraving text, status text, code text,
               created_at timestamptz, updated_at timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select o.id, o.number, split_part(coalesce(pr.display_name, ''), ' ', 1), p.name, b.name,
         b.address, o.engraving, o.status, t.code, o.created_at, o.updated_at
  from public.tag_orders o
  join public.pets p on p.id = o.pet_id
  join public.businesses b on b.id = o.business_id
  left join public.profiles pr on pr.id = o.owner_id
  left join public.qr_tags t on t.id = o.tag_id
  where p_estado is null or o.status = p_estado
  order by o.status in ('delivered', 'cancelled'), o.created_at
  limit 300;
end;
$$;

-- Asigna un código libre (de un lote, sin activar ni reservado) y lo manda.
create function public.admin_enviar_pedido_chapita(p_id uuid, p_code text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  tag uuid;
begin
  perform public.exigir_admin();
  select t.id into tag from public.qr_tags t
  where t.code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
    and t.kind = 'physical' and t.active and t.pet_id is null and t.activated_at is null
    and not exists (select 1 from public.tag_orders x where x.tag_id = t.id)
  for update;
  if not found then
    raise exception 'chapita_no_disponible' using errcode = 'P0001';
  end if;
  update public.tag_orders set tag_id = tag, status = 'sent'
   where id = p_id and status = 'new';
  if not found then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  perform public.registrar_accion('enviar_chapita', 'tag_order', p_id::text,
                                  jsonb_build_object('code', p_code));
end;
$$;

create function public.admin_cancelar_pedido_chapita(p_id uuid, p_motivo text default null)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  -- La chapita reservada vuelve a quedar libre.
  update public.tag_orders set status = 'cancelled', tag_id = null
   where id = p_id and status in ('new', 'sent', 'ready');
  if not found then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  perform public.registrar_accion('cancelar_pedido_chapita', 'tag_order', p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke all on function public.puntos_de_retiro(double precision, double precision) from public;
grant execute on function public.puntos_de_retiro(double precision, double precision)
  to anon, authenticated;

do $$
declare
  f text;
begin
  foreach f in array array[
    'pedir_chapita(uuid, uuid, text)', 'mis_pedidos_chapita()', 'cancelar_pedido_chapita(uuid)',
    'prender_punto_retiro(uuid, boolean)', 'pedidos_chapita_del_negocio(uuid)',
    'negocio_avanzar_pedido_chapita(uuid)', 'admin_pedidos_chapita(text)',
    'admin_enviar_pedido_chapita(uuid, text)', 'admin_cancelar_pedido_chapita(uuid, text)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
