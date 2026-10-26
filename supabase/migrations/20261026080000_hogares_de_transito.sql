-- Paso 3.4b, parte 1 (D106): hogares de tránsito.
-- Una persona se anota para cuidar por un tiempo a un animal hasta que se
-- adopte: qué especies y tamaños recibe, por cuánto tiempo, si tiene patio y
-- otros animales, y su barrio (lo escribe ella; nunca una dirección ni un
-- punto en el mapa). Solo los refugios y protectoras VERIFICADOS de la misma
-- zona ven la lista (primer nombre y barrio) y le piden que reciba a un
-- animal; el hogar acepta o no. Al aceptar se abre un chat con el refugio
-- (contacto inverso: el teléfono nunca se muestra). Así ningún particular
-- puede usar la lista para encontrar casas con animales.

-- ---------------------------------------------------------------------
-- Hogares
-- ---------------------------------------------------------------------
create table public.foster_homes (
  user_id       uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  species_ids   smallint[] not null check (cardinality(species_ids) between 1 and 10),
  sizes         text[] not null default '{chico,mediano,grande}'
                check (cardinality(sizes) between 1 and 3 and sizes <@ array['chico', 'mediano', 'grande']),
  max_days      smallint not null default 30 check (max_days between 1 and 365),
  has_yard      boolean not null default false,
  other_pets    boolean not null default false,
  neighborhood  text check (char_length(trim(neighborhood)) between 1 and 60),
  notes         text check (char_length(notes) <= 300),
  active        boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table public.foster_homes is
  'Hogares de tránsito. Cada persona ve y edita el suyo; los refugios verificados, por hogares_de_transito().';

create trigger foster_homes_updated_at
  before update on public.foster_homes
  for each row execute function public.set_updated_at();

alter table public.foster_homes enable row level security;
create policy "mi_hogar_de_transito" on public.foster_homes for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
revoke all on public.foster_homes from anon;

-- ---------------------------------------------------------------------
-- Pedidos de un refugio a un hogar
-- ---------------------------------------------------------------------
create table public.foster_requests (
  id                  uuid primary key default gen_random_uuid(),
  home_id             uuid not null references public.foster_homes (user_id) on delete cascade,
  shelter_id          uuid not null references public.businesses (id) on delete cascade,
  adoption_animal_id  uuid references public.adoption_animals (id) on delete set null,
  animal_name         text not null check (char_length(trim(animal_name)) between 1 and 40),
  species_id          smallint not null references public.species (id),
  size                text check (size in ('chico', 'mediano', 'grande')),
  days                smallint not null check (days between 1 and 365),
  message             text check (char_length(message) <= 500),
  status              text not null default 'new'
                      check (status in ('new', 'accepted', 'declined', 'cancelled', 'finished')),
  conversation_id     uuid references public.conversations (id) on delete set null,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

comment on table public.foster_requests is
  'Pedidos de refugios verificados a hogares de tránsito. Sin acceso directo.';

-- Un pedido sin responder por refugio y hogar.
create unique index foster_requests_uno_nuevo on public.foster_requests (home_id, shelter_id)
  where status = 'new';
create index foster_requests_shelter_idx on public.foster_requests (shelter_id, created_at desc);
create index foster_requests_animal_idx on public.foster_requests (adoption_animal_id)
  where status = 'accepted';

create trigger foster_requests_updated_at
  before update on public.foster_requests
  for each row execute function public.set_updated_at();

alter table public.foster_requests enable row level security;
-- Sin políticas: todo por las funciones de abajo.
revoke all on public.foster_requests from anon, authenticated;

-- El refugio verificado y activo de esta cuenta (si no, error).
create function public.exigir_refugio(p_business uuid)
returns public.businesses
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  b public.businesses;
begin
  select * into b from public.businesses
  where id = p_business and owner_id = (select auth.uid()) and business_type = 'shelter'
    and verification = 'verified' and status = 'active';
  if not found then
    raise exception 'solo_refugios_verificados' using errcode = '42501';
  end if;
  return b;
end;
$$;

revoke all on function public.exigir_refugio(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Refugio
-- ---------------------------------------------------------------------
-- Hogares activos de la zona del refugio: primer nombre, barrio y lo que
-- reciben. Si ya tiene un animal de un pedido aceptado, figura "con un animal".
create function public.hogares_de_transito(p_business uuid, p_especie smallint default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  refugio public.businesses := public.exigir_refugio(p_business);
begin
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', h.user_id,
      'nombre', split_part(coalesce(nullif(trim(pr.display_name), ''), '?'), ' ', 1),
      'barrio', h.neighborhood,
      'species_ids', h.species_ids,
      'sizes', h.sizes,
      'max_days', h.max_days,
      'has_yard', h.has_yard,
      'other_pets', h.other_pets,
      'notes', h.notes,
      'con_animal', exists (select 1 from public.foster_requests r
                            where r.home_id = h.user_id and r.status = 'accepted'),
      'pedido_abierto', exists (select 1 from public.foster_requests r
                                where r.home_id = h.user_id and r.shelter_id = p_business
                                  and r.status in ('new', 'accepted'))
    ) order by h.updated_at desc)
    from public.foster_homes h
    join public.profiles pr on pr.id = h.user_id
    where h.active and h.user_id <> refugio.owner_id
      and (refugio.zone_id is null or pr.zone_id is null or pr.zone_id = refugio.zone_id)
      and (p_especie is null or p_especie = any (h.species_ids))
      and not public.esta_bloqueado(h.user_id)
  ), '[]'::jsonb);
end;
$$;

-- [p_animal]: un animal de una publicación de este refugio (opcional); si no,
-- nombre, especie y tamaño a mano.
create function public.pedir_transito(
  p_business uuid,
  p_hogar uuid,
  p_dias smallint,
  p_animal uuid default null,
  p_nombre text default null,
  p_especie smallint default null,
  p_tamano text default null,
  p_mensaje text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  refugio public.businesses := public.exigir_refugio(p_business);
  hogar public.foster_homes;
  nombre text := nullif(trim(p_nombre), '');
  especie smallint := p_especie;
  tamano text := p_tamano;
  pedido uuid;
begin
  if p_animal is not null then
    select an.name, an.species_id, an.size into nombre, especie, tamano
    from public.adoption_animals an
    join public.adoptions ad on ad.id = an.adoption_id
    where an.id = p_animal and ad.shelter_id = p_business and an.adopted_pet_id is null;
    if not found then
      raise exception 'No es un animal de tu refugio' using errcode = '42501';
    end if;
    nombre := coalesce(nullif(trim(nombre), ''), nullif(trim(p_nombre), ''), 'Sin nombre');
  end if;
  if nombre is null or especie is null then
    raise exception 'Faltan el nombre y la especie' using errcode = '22023';
  end if;

  select h.* into hogar
  from public.foster_homes h
  join public.profiles pr on pr.id = h.user_id
  where h.user_id = p_hogar and h.active and h.user_id <> refugio.owner_id
    and (refugio.zone_id is null or pr.zone_id is null or pr.zone_id = refugio.zone_id);
  if not found then
    raise exception 'hogar_no_disponible' using errcode = 'P0001';
  end if;
  if not especie = any (hogar.species_ids) or (tamano is not null and not tamano = any (hogar.sizes)) then
    raise exception 'no_recibe_ese_animal' using errcode = 'P0001';
  end if;
  if p_dias is null or p_dias > hogar.max_days then
    raise exception 'mas_dias_que_el_maximo' using errcode = 'P0001';
  end if;
  -- Contra el uso en masa: 20 pedidos por día por refugio.
  if (select count(*) from public.foster_requests
      where shelter_id = p_business and created_at > now() - interval '1 day') >= 20 then
    raise exception 'demasiados_pedidos' using errcode = '54000';
  end if;

  -- Si ya hay uno sin responder para este hogar, el índice único da 23505.
  insert into public.foster_requests (home_id, shelter_id, adoption_animal_id, animal_name,
                                      species_id, size, days, message)
  values (p_hogar, p_business, p_animal, left(nombre, 40), especie, tamano, p_dias,
          nullif(trim(p_mensaje), ''))
  returning id into pedido;
  return pedido;
end;
$$;

-- Los pedidos del refugio, con el primer nombre del hogar y el chat si aceptó.
create function public.pedidos_transito_del_refugio(p_business uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_refugio(p_business);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', r.id, 'animal_name', r.animal_name, 'species_id', r.species_id, 'size', r.size,
      'days', r.days, 'status', r.status, 'created_at', r.created_at, 'updated_at', r.updated_at,
      'hogar', split_part(coalesce(nullif(trim(pr.display_name), ''), '?'), ' ', 1),
      'barrio', h.neighborhood,
      'conversation_id', case when r.status = 'accepted' then r.conversation_id end
    ) order by r.status not in ('new', 'accepted'), r.created_at desc)
    from public.foster_requests r
    join public.foster_homes h on h.user_id = r.home_id
    left join public.profiles pr on pr.id = r.home_id
    where r.shelter_id = p_business
      and (r.status in ('new', 'accepted') or r.updated_at > now() - interval '60 days')
  ), '[]'::jsonb);
end;
$$;

-- El refugio cancela un pedido sin responder o da por terminado el tránsito.
create function public.cerrar_transito(p_id uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  r public.foster_requests;
  nuevo text;
begin
  select * into r from public.foster_requests where id = p_id for update;
  if not found then
    raise exception 'No existe ese pedido' using errcode = 'P0002';
  end if;
  perform public.exigir_refugio(r.shelter_id);
  nuevo := case r.status when 'new' then 'cancelled' when 'accepted' then 'finished' end;
  if nuevo is null then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.foster_requests set status = nuevo where id = p_id;
  return nuevo;
end;
$$;

-- ---------------------------------------------------------------------
-- Hogar
-- ---------------------------------------------------------------------
-- Los pedidos que me llegaron, con el nombre del refugio y la foto del animal.
create function public.mis_pedidos_transito()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', r.id, 'animal_name', r.animal_name, 'species_id', r.species_id, 'size', r.size,
    'days', r.days, 'message', r.message, 'status', r.status, 'created_at', r.created_at,
    'shelter_id', r.shelter_id, 'shelter_name', b.name,
    'photo', (select an.photos[1] from public.adoption_animals an where an.id = r.adoption_animal_id),
    'conversation_id', case when r.status = 'accepted' then r.conversation_id end
  ) order by r.status <> 'new', r.created_at desc), '[]'::jsonb)
  from public.foster_requests r
  join public.businesses b on b.id = r.shelter_id
  where r.home_id = (select auth.uid())
    and (r.status in ('new', 'accepted') or r.updated_at > now() - interval '60 days');
$$;

-- Aceptar abre (o reusa) el chat con el refugio; devuelve su id. Rechazar
-- devuelve null.
create function public.responder_transito(p_id uuid, p_aceptar boolean)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r public.foster_requests;
  dueno uuid;
  conv uuid;
begin
  select * into r from public.foster_requests where id = p_id and home_id = yo for update;
  if not found then
    raise exception 'No es un pedido para vos' using errcode = '42501';
  end if;
  if r.status <> 'new' then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  if not coalesce(p_aceptar, false) then
    update public.foster_requests set status = 'declined' where id = p_id;
    return null;
  end if;

  select owner_id into dueno from public.businesses where id = r.shelter_id and status = 'active';
  if dueno is null then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  -- El mismo chat que si el hogar le escribiera al refugio desde su ficha.
  select id into conv from public.conversations
  where kind = 'business' and context_id = r.shelter_id and created_by = yo;
  if conv is null then
    insert into public.conversations (kind, context_id, created_by)
    values ('business', r.shelter_id, yo) returning id into conv;
    insert into public.conversation_members (conversation_id, user_id, last_read_at)
    values (conv, yo, now()), (conv, dueno, null);
  end if;
  update public.foster_requests set status = 'accepted', conversation_id = conv where id = p_id;
  return conv;
end;
$$;

-- ---------------------------------------------------------------------
-- Adopciones: si el animal está en un hogar de tránsito (sin decir dónde)
-- ---------------------------------------------------------------------
drop function public.adopciones_disponibles(smallint);
create function public.adopciones_disponibles(p_especie smallint default null)
returns table (
  animal_id uuid, adoption_id uuid, name text, species_id smallint, breed text, age_months smallint,
  size text, energy text, sex text, neutered boolean, vaccinated boolean, microchip boolean,
  good_with_kids boolean, good_with_dogs boolean, good_with_cats boolean, needs_yard boolean,
  special_needs text, photos text[], description text, requirements text, contribution_amount integer,
  contribution_covers text, publisher_kind text, shelter_name text, is_litter boolean,
  mine boolean, created_at timestamptz, in_foster boolean
)
language sql stable security definer set search_path = ''
as $$
  select an.id, ad.id, an.name, an.species_id, coalesce(b.name, ''), an.age_months, an.size, an.energy,
         an.sex::text, an.neutered, an.vaccinated, an.microchip, an.good_with_kids, an.good_with_dogs,
         an.good_with_cats, an.needs_yard, an.special_needs, an.photos, ad.description, ad.requirements,
         ad.contribution_amount, ad.contribution_covers, ad.publisher_kind, s.name, ad.is_litter,
         ad.publisher_id = (select auth.uid()), ad.created_at,
         exists (select 1 from public.foster_requests f
                 where f.adoption_animal_id = an.id and f.status = 'accepted')
  from public.adoption_animals an
  join public.adoptions ad on ad.id = an.adoption_id
  left join public.breeds b on b.species_id = an.species_id and b.id = an.breed_id
  left join public.businesses s on s.id = ad.shelter_id
  where ad.status = 'active' and an.adopted_pet_id is null
    and (p_especie is null or an.species_id = p_especie)
  order by ad.created_at desc
  limit 200;
$$;

revoke all on function public.adopciones_disponibles(smallint) from public;
grant execute on function public.adopciones_disponibles(smallint) to anon, authenticated;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array[
    'hogares_de_transito(uuid, smallint)',
    'pedir_transito(uuid, uuid, smallint, uuid, text, smallint, text, text)',
    'pedidos_transito_del_refugio(uuid)', 'cerrar_transito(uuid)',
    'mis_pedidos_transito()', 'responder_transito(uuid, boolean)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
