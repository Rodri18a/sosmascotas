-- Etapa 2.11, parte 2 (D113): descuentos en comercios adheridos para Pro.
-- Un comercio VERIFICADO (de cualquier rubro menos refugio) carga hasta 5
-- descuentos ("10 % en baños", "Envío gratis"). Gratis para el comercio: le
-- trae clientes; para la persona es una razón para pasar a Pro.
-- Cualquiera ve los descuentos de su zona (así sabe qué gana con Pro); el
-- código lo pide solo quien tiene Pro o Familia. El código sirve siempre (es
-- un descuento fijo, no de una vez), pero se canjea una vez por día, y al
-- canjearlo la base vuelve a mirar que la persona siga con el plan.
-- El comercio no ve quién es hasta que llega con el código (primer nombre).

create table public.pro_discounts (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  title        text not null check (char_length(trim(title)) between 1 and 80),
  description  text check (char_length(description) <= 300),
  valid_until  date,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index pro_discounts_business_idx on public.pro_discounts (business_id);

create trigger pro_discounts_updated_at
  before update on public.pro_discounts
  for each row execute function public.set_updated_at();

create table public.pro_discount_codes (
  id           uuid primary key default gen_random_uuid(),
  discount_id  uuid not null references public.pro_discounts (id) on delete cascade,
  user_id      uuid not null references auth.users (id) on delete cascade,
  code         text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{6}$'),
  created_at   timestamptz not null default now(),
  unique (discount_id, user_id)
);

create table public.pro_discount_uses (
  id        bigint generated always as identity primary key,
  code_id   uuid not null references public.pro_discount_codes (id) on delete cascade,
  used_on   date not null default public.dia_uy(now()),
  used_at   timestamptz not null default now(),
  unique (code_id, used_on)
);

create index pro_discount_codes_user_idx on public.pro_discount_codes (user_id);

comment on table public.pro_discounts is 'Descuentos para Pro de los comercios adheridos (D113). Sin acceso directo.';
comment on table public.pro_discount_codes is 'Código de cada persona Pro para un descuento (D113). Sin acceso directo.';
comment on table public.pro_discount_uses is 'Cada canje (uno por día y código, D113). Sin acceso directo.';

alter table public.pro_discounts enable row level security;
alter table public.pro_discount_codes enable row level security;
alter table public.pro_discount_uses enable row level security;
-- Sin políticas: todo por las funciones de abajo.
revoke all on public.pro_discounts, public.pro_discount_codes, public.pro_discount_uses
  from anon, authenticated;

-- ¿El negocio (mío) puede ofrecer descuentos? Verificado, activo y no refugio.
create function public.puede_dar_descuento(p_business uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.businesses
    where id = p_business and owner_id = (select auth.uid()) and status = 'active'
      and verification = 'verified' and business_type <> 'shelter');
$$;

revoke all on function public.puede_dar_descuento(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Comercio
-- ---------------------------------------------------------------------
create function public.mis_descuentos_pro(p_business uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'puede', public.puede_dar_descuento(p_business),
    'descuentos', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', d.id, 'title', d.title, 'description', d.description,
        'valid_until', d.valid_until, 'active', d.active,
        'pedidos', (select count(*) from public.pro_discount_codes c where c.discount_id = d.id),
        'usados', (select count(*) from public.pro_discount_uses u
                   join public.pro_discount_codes c on c.id = u.code_id where c.discount_id = d.id)
      ) order by d.active desc, d.created_at desc)
      from public.pro_discounts d
      where d.business_id = p_business
    ), '[]'::jsonb));
end;
$$;

-- Crea (sin `id`) o actualiza. Hasta 5 activos por comercio.
create function public.guardar_descuento_pro(p_business uuid, p jsonb)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  activo boolean := coalesce((p ->> 'active')::boolean, true);
begin
  if not public.puede_dar_descuento(p_business) then
    raise exception 'solo_verificados' using errcode = '42501';
  end if;
  if activo and (select count(*) from public.pro_discounts
                 where business_id = p_business and active and id is distinct from id_) >= 5 then
    raise exception 'demasiados_descuentos' using errcode = '54000';
  end if;
  if id_ is null then
    insert into public.pro_discounts (business_id, title, description, valid_until, active)
    values (p_business, trim(p ->> 'title'), nullif(trim(p ->> 'description'), ''),
            nullif(p ->> 'valid_until', '')::date, activo)
    returning id into id_;
  else
    update public.pro_discounts
       set title = trim(p ->> 'title'), description = nullif(trim(p ->> 'description'), ''),
           valid_until = nullif(p ->> 'valid_until', '')::date, active = activo
     where id = id_ and business_id = p_business;
    if not found then
      raise exception 'No es un descuento de tu negocio' using errcode = '42501';
    end if;
  end if;
  return id_;
end;
$$;

-- Canjea el código que trae la persona. Devuelve el descuento y su primer
-- nombre. Falla si ya no tiene Pro o si ya lo usó hoy.
create function public.canjear_descuento_pro(p_business uuid, p_code text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  c public.pro_discount_codes;
  d public.pro_discounts;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select cl.* into c
  from public.pro_discount_codes cl
  join public.pro_discounts dc on dc.id = cl.discount_id
  where cl.code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
    and dc.business_id = p_business;
  if not found then
    raise exception 'codigo_inexistente' using errcode = 'P0001';
  end if;
  select * into d from public.pro_discounts where id = c.discount_id;
  if not d.active or (d.valid_until is not null and d.valid_until < public.dia_uy(now())) then
    raise exception 'descuento_vencido' using errcode = 'P0001';
  end if;
  if not public.es_pro(c.user_id) then
    raise exception 'sin_pro' using errcode = 'P0001';
  end if;
  begin
    insert into public.pro_discount_uses (code_id) values (c.id);
  exception when unique_violation then
    raise exception 'usado_hoy' using errcode = 'P0001';
  end;
  return jsonb_build_object(
    'title', d.title,
    'cliente', (select split_part(coalesce(nullif(trim(display_name), ''), ''), ' ', 1)
                from public.profiles where id = c.user_id));
end;
$$;

-- ---------------------------------------------------------------------
-- La persona
-- ---------------------------------------------------------------------
-- Descuentos vigentes de mi zona (o de un comercio), con mi código si lo pedí.
-- `pro`: si puedo pedir códigos. Sin sesión, sin códigos.
create function public.descuentos_pro(p_business uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  zona smallint := (select zone_id from public.profiles where id = yo);
begin
  return jsonb_build_object(
    'pro', yo is not null and public.es_pro(yo),
    'descuentos', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', d.id, 'title', d.title, 'description', d.description, 'valid_until', d.valid_until,
        'business_id', b.id, 'business_name', b.name, 'business_type', b.business_type,
        'address', b.address, 'code', c.code
      ) order by c.code is null, b.name)
      from public.pro_discounts d
      join public.businesses b on b.id = d.business_id
      left join public.pro_discount_codes c on c.discount_id = d.id and c.user_id = yo
      where d.active and (d.valid_until is null or d.valid_until >= public.dia_uy(now()))
        and b.status = 'active' and b.verification = 'verified'
        and (case when p_business is not null then b.id = p_business
                  else zona is null or b.zone_id is null or b.zone_id = zona end)
    ), '[]'::jsonb));
end;
$$;

-- Pide el código de un descuento (o devuelve el que ya tenía). Solo con Pro.
create function public.pedir_descuento_pro(p_discount uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  codigo text;
begin
  if yo is null or not public.es_pro(yo) then
    raise exception 'sin_pro' using errcode = '42501';
  end if;
  if not exists (select 1 from public.pro_discounts d
                 join public.businesses b on b.id = d.business_id
                 where d.id = p_discount and d.active
                   and (d.valid_until is null or d.valid_until >= public.dia_uy(now()))
                   and b.status = 'active' and b.verification = 'verified') then
    raise exception 'descuento_no_disponible' using errcode = 'P0001';
  end if;
  select code into codigo from public.pro_discount_codes where discount_id = p_discount and user_id = yo;
  if codigo is not null then
    return codigo;
  end if;
  loop
    -- 6 letras y números sin los que se confunden (0/O, 1/I).
    codigo := (select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
                                        1 + floor(random() * 32)::int, 1), '')
               from generate_series(1, 6));
    begin
      insert into public.pro_discount_codes (discount_id, user_id, code)
      values (p_discount, yo, codigo);
      return codigo;
    exception when unique_violation then
      select code into codigo from public.pro_discount_codes
       where discount_id = p_discount and user_id = yo;
      if codigo is not null then
        return codigo;
      end if;
    end;
  end loop;
end;
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array[
    'mis_descuentos_pro(uuid)', 'guardar_descuento_pro(uuid, jsonb)',
    'canjear_descuento_pro(uuid, text)', 'pedir_descuento_pro(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

-- La lista la ven también los visitantes (sin códigos).
revoke all on function public.descuentos_pro(uuid) from public;
grant execute on function public.descuentos_pro(uuid) to anon, authenticated;
