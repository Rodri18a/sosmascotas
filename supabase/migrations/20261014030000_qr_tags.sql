-- Paso 0.4.1: chapitas QR. Cada mascota recibe un código digital al crearse.
-- La página pública del QR (sosmascotas.uy/m/<código>) se arma con
-- public_pet_page(), que devuelve solo datos pensados para quien la encuentra.

create type public.qr_kind as enum ('digital', 'physical');

create table public.qr_tags (
  id           uuid primary key default gen_random_uuid(),
  code         text not null unique check (code ~ '^[2-9A-HJ-NP-Z]{8}$'),
  pet_id       uuid references public.pets (id) on delete set null,
  owner_id     uuid references auth.users (id) on delete cascade,
  kind         public.qr_kind not null default 'digital',
  batch_id     uuid,                                 -- lotes de chapitas físicas (Fase 1)
  active       boolean not null default true,
  activated_at timestamptz,
  public_note  text check (char_length(public_note) <= 200),  -- "Toma medicación", "Es alérgico a…"
  created_at   timestamptz not null default now()
);

comment on table public.qr_tags is 'Códigos QR de las mascotas. El dueño ve y edita los suyos; lo público sale de public_pet_page().';

create index qr_tags_pet_idx on public.qr_tags (pet_id) where pet_id is not null;
-- Una sola chapita digital activa por mascota.
create unique index qr_tags_un_digital_activo on public.qr_tags (pet_id)
  where kind = 'digital' and active;

alter table public.qr_tags enable row level security;

create policy "ver_mis_qr" on public.qr_tags for select to authenticated
  using (owner_id = (select auth.uid()));
create policy "editar_mis_qr" on public.qr_tags for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

revoke all on public.qr_tags from anon;
revoke insert, update, delete, truncate on public.qr_tags from authenticated;
-- Desde la app solo se puede activar/desactivar y cambiar la nota pública.
grant update (active, public_note) on public.qr_tags to authenticated;

-- Código de 8 caracteres sin los que se confunden (0/O, 1/I/L): 31^8 ≈ 8,5 × 10^11.
create function public.generar_codigo_qr()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  alfabeto constant text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  bytes bytea;
  codigo text;
begin
  loop
    bytes := extensions.gen_random_bytes(8);
    codigo := '';
    for i in 0..7 loop
      codigo := codigo || substr(alfabeto, (get_byte(bytes, i) % 31) + 1, 1);
    end loop;
    exit when not exists (select 1 from public.qr_tags where code = codigo);
  end loop;
  return codigo;
end;
$$;

revoke execute on function public.generar_codigo_qr() from public, anon, authenticated;

-- Al crear una mascota, se crea su QR digital.
create function public.crear_qr_de_mascota()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.qr_tags (code, pet_id, owner_id, kind, activated_at)
  values (public.generar_codigo_qr(), new.id, new.owner_id, 'digital', now());
  return new;
end;
$$;

revoke execute on function public.crear_qr_de_mascota() from public, anon, authenticated;

create trigger pets_crear_qr
  after insert on public.pets
  for each row execute function public.crear_qr_de_mascota();

-- Mascotas que ya existían.
insert into public.qr_tags (code, pet_id, owner_id, kind, activated_at)
select public.generar_codigo_qr(), p.id, p.owner_id, 'digital', now()
from public.pets p
where not exists (select 1 from public.qr_tags q where q.pet_id = p.id and q.kind = 'digital' and q.active);

-- Regenerar: desactiva el QR digital actual y crea uno nuevo (por ejemplo, si
-- el código circuló donde no debía). Solo el dueño de la mascota.
create function public.regenerar_qr(p_pet_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  nuevo text;
begin
  if not exists (
    select 1 from public.pets where id = p_pet_id and owner_id = (select auth.uid())
  ) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;

  update public.qr_tags set active = false
  where pet_id = p_pet_id and kind = 'digital' and active;

  nuevo := public.generar_codigo_qr();
  insert into public.qr_tags (code, pet_id, owner_id, kind, activated_at)
  values (nuevo, p_pet_id, (select auth.uid()), 'digital', now());
  return nuevo;
end;
$$;

revoke execute on function public.regenerar_qr(uuid) from public, anon;
grant execute on function public.regenerar_qr(uuid) to authenticated;

-- =====================================================================
-- PÁGINA PÚBLICA DEL QR: lo mínimo para ayudar a quien la encuentra.
-- Nunca devuelve teléfonos, el número de microchip ni datos del dueño.
-- =====================================================================
create function public.public_pet_page(p_code text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  tag public.qr_tags;
  mascota record;
begin
  select * into tag from public.qr_tags where code = upper(trim(p_code));
  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;
  if tag.pet_id is null then
    return jsonb_build_object('status', 'unactivated');  -- chapita física sin vincular (Fase 1)
  end if;
  if not tag.active then
    return jsonb_build_object('status', 'inactive');
  end if;

  select p.name, p.color, p.marks, p.photo_path, p.sex,
         (p.microchip is not null) as has_microchip,
         s.name as species, s.icon as species_icon,
         coalesce(b.name, p.breed_other) as breed
    into mascota
  from public.pets p
  join public.species s on s.id = p.species_id
  left join public.breeds b on b.id = p.breed_id
  where p.id = tag.pet_id;

  return jsonb_build_object(
    'status', 'active',
    'code', tag.code,
    'pet', jsonb_build_object(
      'name', mascota.name,
      'species', mascota.species,
      'species_icon', mascota.species_icon,
      'breed', mascota.breed,
      'sex', mascota.sex,
      'color', mascota.color,
      'marks', mascota.marks,
      'photo_path', mascota.photo_path,
      'has_microchip', mascota.has_microchip,
      'public_note', tag.public_note
    ),
    'lost', false  -- Se completa en 0.5.6 ("Estoy perdido 🆘" si hay un SOS activo).
  );
end;
$$;

revoke execute on function public.public_pet_page(text) from public;
grant execute on function public.public_pet_page(text) to anon, authenticated;
