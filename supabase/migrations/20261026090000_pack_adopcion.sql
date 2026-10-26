-- Paso 3.4b, parte 2 (D107): pack adopción.
-- Veterinarias, pet shops, agroveterinarias y peluquerías VERIFICADAS cargan
-- un beneficio para quien adopta por la app ("Primera consulta con 20 % de
-- descuento", "Kit de bienvenida"). Gratis para el comercio: atrae comercios y
-- ayuda a que la adopción salga bien. Quien adoptó por la app en los últimos
-- 180 días ve los beneficios de su zona y pide un código; lo muestra en el
-- local y el comercio lo marca como usado. El comercio no ve quién es hasta
-- que la persona llega con el código (solo el primer nombre y el animal).

create table public.adoption_perks (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  title        text not null check (char_length(trim(title)) between 1 and 80),
  description  text check (char_length(description) <= 300),
  valid_until  date,
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index adoption_perks_business_idx on public.adoption_perks (business_id);

create trigger adoption_perks_updated_at
  before update on public.adoption_perks
  for each row execute function public.set_updated_at();

create table public.adoption_perk_claims (
  id          uuid primary key default gen_random_uuid(),
  perk_id     uuid not null references public.adoption_perks (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  request_id  uuid references public.adoption_requests (id) on delete set null,
  code        text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{6}$'),
  created_at  timestamptz not null default now(),
  used_at     timestamptz,
  unique (perk_id, user_id)
);

create index adoption_perk_claims_user_idx on public.adoption_perk_claims (user_id);

comment on table public.adoption_perks is 'Beneficios del pack adopción. Sin acceso directo.';
comment on table public.adoption_perk_claims is 'Códigos pedidos por quien adoptó. Sin acceso directo.';

alter table public.adoption_perks enable row level security;
alter table public.adoption_perk_claims enable row level security;
-- Sin políticas: todo por las funciones de abajo.
revoke all on public.adoption_perks, public.adoption_perk_claims from anon, authenticated;

-- Rubros que pueden ofrecer un beneficio.
create function public.puede_dar_beneficio(p_business uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.businesses
    where id = p_business and owner_id = (select auth.uid()) and status = 'active'
      and verification = 'verified' and business_type in ('vet', 'petshop', 'agro', 'grooming'));
$$;

revoke all on function public.puede_dar_beneficio(uuid) from public, anon, authenticated;

-- La adopción por la app más reciente de los últimos 180 días (null si no hay).
create function public.mi_adopcion_reciente()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select r.id from public.adoption_requests r
  where r.adopter_id = (select auth.uid()) and r.stage = 'adopted'
    and r.updated_at > now() - interval '180 days'
  order by r.updated_at desc
  limit 1;
$$;

revoke all on function public.mi_adopcion_reciente() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Comercio
-- ---------------------------------------------------------------------
create function public.mis_beneficios_adopcion(p_business uuid)
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
    'puede', public.puede_dar_beneficio(p_business),
    'beneficios', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', p.id, 'title', p.title, 'description', p.description,
        'valid_until', p.valid_until, 'active', p.active,
        'pedidos', (select count(*) from public.adoption_perk_claims c where c.perk_id = p.id),
        'usados', (select count(*) from public.adoption_perk_claims c
                   where c.perk_id = p.id and c.used_at is not null)
      ) order by p.active desc, p.created_at desc)
      from public.adoption_perks p
      where p.business_id = p_business
    ), '[]'::jsonb));
end;
$$;

-- Crea (sin `id`) o actualiza. Hasta 5 activos por comercio.
create function public.guardar_beneficio_adopcion(p_business uuid, p jsonb)
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
  if not public.puede_dar_beneficio(p_business) then
    raise exception 'solo_verificados' using errcode = '42501';
  end if;
  if activo and (select count(*) from public.adoption_perks
                 where business_id = p_business and active and id is distinct from id_) >= 5 then
    raise exception 'demasiados_beneficios' using errcode = '54000';
  end if;
  if id_ is null then
    insert into public.adoption_perks (business_id, title, description, valid_until, active)
    values (p_business, trim(p ->> 'title'), nullif(trim(p ->> 'description'), ''),
            nullif(p ->> 'valid_until', '')::date, activo)
    returning id into id_;
  else
    update public.adoption_perks
       set title = trim(p ->> 'title'), description = nullif(trim(p ->> 'description'), ''),
           valid_until = nullif(p ->> 'valid_until', '')::date, active = activo
     where id = id_ and business_id = p_business;
    if not found then
      raise exception 'No es un beneficio de tu negocio' using errcode = '42501';
    end if;
  end if;
  return id_;
end;
$$;

-- Marca usado el código que trae la persona. Devuelve el beneficio, el primer
-- nombre de quien lo pidió y el animal que adoptó.
create function public.canjear_beneficio_adopcion(p_business uuid, p_code text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  c public.adoption_perk_claims;
  perk public.adoption_perks;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select cl.* into c
  from public.adoption_perk_claims cl
  join public.adoption_perks pk on pk.id = cl.perk_id
  where cl.code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
    and pk.business_id = p_business
  for update of cl;
  if not found then
    raise exception 'codigo_inexistente' using errcode = 'P0001';
  end if;
  if c.used_at is not null then
    raise exception 'codigo_usado' using errcode = 'P0001';
  end if;
  update public.adoption_perk_claims set used_at = now() where id = c.id;
  select * into perk from public.adoption_perks where id = c.perk_id;
  return jsonb_build_object(
    'title', perk.title,
    'cliente', (select split_part(coalesce(nullif(trim(display_name), ''), ''), ' ', 1)
                from public.profiles where id = c.user_id),
    'animal', (select an.name from public.adoption_requests r
               join public.adoption_animals an on an.id = r.adoption_animal_id
               where r.id = c.request_id));
end;
$$;

-- ---------------------------------------------------------------------
-- Quien adoptó
-- ---------------------------------------------------------------------
-- Beneficios vigentes de la zona, con mi código si ya lo pedí. Solo si adoptó
-- por la app en los últimos 180 días (si no, `puede` es falso y la lista vacía).
create function public.beneficios_adopcion()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  zona smallint;
begin
  if public.mi_adopcion_reciente() is null then
    return jsonb_build_object('puede', false, 'beneficios', '[]'::jsonb);
  end if;
  select zone_id into zona from public.profiles where id = yo;
  return jsonb_build_object('puede', true, 'beneficios', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', p.id, 'title', p.title, 'description', p.description, 'valid_until', p.valid_until,
      'business_id', b.id, 'business_name', b.name, 'business_type', b.business_type,
      'address', b.address,
      'code', c.code, 'used', c.used_at is not null
    ) order by c.code is null, b.name)
    from public.adoption_perks p
    join public.businesses b on b.id = p.business_id
    left join public.adoption_perk_claims c on c.perk_id = p.id and c.user_id = yo
    where p.active and (p.valid_until is null or p.valid_until >= current_date)
      and b.status = 'active' and b.verification = 'verified'
      and (zona is null or b.zone_id is null or b.zone_id = zona)
  ), '[]'::jsonb));
end;
$$;

-- Pide el código de un beneficio (o devuelve el que ya tenía).
create function public.pedir_beneficio_adopcion(p_perk uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  adopcion uuid := public.mi_adopcion_reciente();
  codigo text;
begin
  if adopcion is null then
    raise exception 'sin_adopcion' using errcode = '42501';
  end if;
  if not exists (select 1 from public.adoption_perks p
                 join public.businesses b on b.id = p.business_id
                 where p.id = p_perk and p.active
                   and (p.valid_until is null or p.valid_until >= current_date)
                   and b.status = 'active' and b.verification = 'verified') then
    raise exception 'beneficio_no_disponible' using errcode = 'P0001';
  end if;
  select code into codigo from public.adoption_perk_claims where perk_id = p_perk and user_id = yo;
  if codigo is not null then
    return codigo;
  end if;
  loop
    -- 6 letras y números sin los que se confunden (0/O, 1/I).
    codigo := (select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
                                        1 + floor(random() * 32)::int, 1), '')
               from generate_series(1, 6));
    begin
      insert into public.adoption_perk_claims (perk_id, user_id, request_id, code)
      values (p_perk, yo, adopcion, codigo);
      return codigo;
    exception when unique_violation then
      -- Si fue por el código, se prueba otro; si ya lo tenía, se devuelve.
      select code into codigo from public.adoption_perk_claims where perk_id = p_perk and user_id = yo;
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
    'mis_beneficios_adopcion(uuid)', 'guardar_beneficio_adopcion(uuid, jsonb)',
    'canjear_beneficio_adopcion(uuid, text)', 'beneficios_adopcion()',
    'pedir_beneficio_adopcion(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
