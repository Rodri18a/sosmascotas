-- Etapa 1.2 (pasos 1.2.3 a 1.2.8): mapa integral (D75). Sin costo: los
-- pines siguen saliendo de Supabase por zona visible (regla de costo).
--  · Rubros (capas): veterinarias, petshops, farmacias, peluquerías,
--    paseadores, hoteles y guarderías, adiestradores, lugares que aceptan
--    mascotas y refugios.
--  · "Sin local": tiendas online y servicios a domicilio (sin pin).
--  · Días especiales (feriados) en el horario.
--  · Insignia "Operador RENAC" (la marca el administrador, 1.8.4).
--  · Favoritos, "fui" y "es mi veterinaria" (`user_places`).

alter table public.businesses drop constraint businesses_business_type_check;
alter table public.businesses add constraint businesses_business_type_check
  check (business_type in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                           'hotel', 'trainer', 'pet_friendly', 'shelter'));

alter table public.businesses
  add column kind text not null default 'local'
    check (kind in ('local', 'online', 'domicilio')),
  add column special_days jsonb not null default '{}'::jsonb,
  add column renac_operator boolean not null default false;

-- Sin local no hace falta un punto en el mapa; con local, sí.
alter table public.businesses alter column location drop not null;
alter table public.businesses add constraint businesses_local_con_ubicacion
  check (kind <> 'local' or location is not null);

-- Días especiales: {"2026-12-25": [], "2026-12-24": [["09:00","13:00"]]}
-- (lista vacía = cerrado ese día). Mismas franjas que `hours`.
create function public.dias_especiales_validos(d jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select jsonb_typeof(d) = 'object'
     and not exists (
       select 1 from jsonb_each(d) e
       where e.key !~ '^\d{4}-\d{2}-\d{2}$'
          or jsonb_typeof(e.value) <> 'array'
          or exists (
            select 1 from jsonb_array_elements(e.value) f
            where jsonb_typeof(f) <> 'array'
               or jsonb_array_length(f) <> 2
               or not (f ->> 0 ~ '^([01][0-9]|2[0-3]):[0-5][0-9]$')
               or not (f ->> 1 ~ '^([01][0-9]|2[0-4]):[0-5][0-9]$')
          )
     );
$$;

alter table public.businesses
  add constraint businesses_dias_especiales_validos check (public.dias_especiales_validos(special_days));

-- Lugares con local dentro del rectángulo visible, de los rubros pedidos
-- (todos si [p_tipos] es null). Reemplaza a comercios_en_zona(), que queda
-- para las versiones viejas de la app.
create function public.lugares_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision,
  p_tipos text[] default null
)
returns table (
  id uuid, business_type text, kind text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text,
  web text, instagram text, hours jsonb, special_days jsonb, is_24h boolean,
  emergencies boolean, species_ids smallint[], verified boolean,
  renac_operator boolean, is_sample boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.hours, b.special_days, b.is_24h,
         b.emergencies, b.species_ids, b.verification = 'verified',
         b.renac_operator, b.is_sample
  from public.businesses b
  where b.status = 'active'
    and b.kind = 'local'
    and (p_tipos is null or b.business_type = any (p_tipos))
    and b.location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by b.emergencies desc, b.is_24h desc, b.name
  limit 500;
$$;

-- "Sin local" (online y a domicilio) de una zona, sin ubicación.
create function public.lugares_sin_local(
  p_zona smallint default null,
  p_tipos text[] default null
)
returns table (
  id uuid, business_type text, kind text, name text, description text,
  phone text, whatsapp text, web text, instagram text, hours jsonb,
  special_days jsonb, is_24h boolean, species_ids smallint[], verified boolean,
  is_sample boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description,
         b.phone, b.whatsapp, b.web, b.instagram, b.hours, b.special_days,
         b.is_24h, b.species_ids, b.verification = 'verified', b.is_sample
  from public.businesses b
  where b.status = 'active'
    and b.kind <> 'local'
    and (p_tipos is null or b.business_type = any (p_tipos))
    and (p_zona is null or b.zone_id is null or b.zone_id = p_zona)
  order by b.verification = 'verified' desc, b.name
  limit 200;
$$;

revoke execute on function public.lugares_en_zona(double precision, double precision, double precision, double precision, text[]) from public;
revoke execute on function public.lugares_sin_local(smallint, text[]) from public;
grant execute on function public.lugares_en_zona(double precision, double precision, double precision, double precision, text[]) to anon, authenticated;
grant execute on function public.lugares_sin_local(smallint, text[]) to anon, authenticated;

-- ---------------------------------------------------------------------
-- user_places: favoritos, "fui" y "es mi veterinaria" (privados)
-- ---------------------------------------------------------------------
create table public.user_places (
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  business_id  uuid not null references public.businesses (id) on delete cascade,
  favorite     boolean not null default false,
  visited_at   timestamptz,                   -- "fui" (la última vez que lo marcó)
  is_my_vet    boolean not null default false,
  updated_at   timestamptz not null default now(),
  primary key (user_id, business_id)
);

comment on table public.user_places is
  'Lo de cada persona con un lugar: favorito, "fui" y "es mi veterinaria". Privado (D75).';

create index user_places_business_idx on public.user_places (business_id);

alter table public.user_places enable row level security;

create policy "ver_mis_lugares" on public.user_places for select to authenticated
  using (user_id = (select auth.uid()));
create policy "marcar_mis_lugares" on public.user_places for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy "cambiar_mis_lugares" on public.user_places for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "borrar_mis_lugares" on public.user_places for delete to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.user_places from anon;

-- "Es mi veterinaria" solo en veterinarias, y una sola por persona.
create function public.user_places_mi_veterinaria()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  new.updated_at := now();
  if new.is_my_vet then
    if (select business_type from public.businesses where id = new.business_id) <> 'vet' then
      raise exception 'Solo una veterinaria puede ser "mi veterinaria"' using errcode = '22023';
    end if;
    update public.user_places set is_my_vet = false
     where user_id = new.user_id and business_id <> new.business_id and is_my_vet;
  end if;
  return new;
end;
$$;

create trigger user_places_mi_veterinaria
  before insert or update on public.user_places
  for each row execute function public.user_places_mi_veterinaria();
