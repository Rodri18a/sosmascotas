-- Paso 0.5.1: reportes SOS (mascotas perdidas y encontradas), fotos y reportes de
-- contenido. Privacidad: la ubicación exacta queda guardada pero nunca sale a
-- otros usuarios; lo público usa un punto desplazado al azar 150–200 m.
-- Nadie lee la tabla directo: todo pasa por funciones que devuelven lo justo.

create type public.sos_kind as enum ('lost', 'found');
create type public.sos_status as enum ('active', 'resolved', 'archived', 'hidden');

create table public.sos_reports (
  id               uuid primary key default gen_random_uuid(),
  kind             public.sos_kind not null,
  user_id          uuid not null references auth.users (id) on delete cascade,
  pet_id           uuid references public.pets (id) on delete set null,
  species_id       smallint not null references public.species (id),
  breed_id         integer,
  breed_other      text check (char_length(breed_other) <= 60),
  name             text check (char_length(name) <= 40),
  sex              public.pet_sex not null default 'unknown',
  color            text check (char_length(color) <= 60),
  marks            text check (char_length(marks) <= 300),
  description      text check (char_length(description) <= 1000),
  reward           text check (char_length(reward) <= 100),
  has_microchip    boolean not null default false,
  exact_location   extensions.geography(point, 4326) not null,   -- PRIVADA
  public_location  extensions.geography(point, 4326) not null,   -- aproximada
  zone_id          smallint references public.zones (id),
  happened_at      timestamptz not null default now(),           -- cuándo se perdió / se vio
  status           public.sos_status not null default 'active',
  created_at       timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  resolved_at      timestamptz,
  foreign key (species_id, breed_id) references public.breeds (species_id, id)
);

comment on table public.sos_reports is 'Reportes SOS. Sin acceso directo: se usan las funciones sos_*.';
comment on column public.sos_reports.exact_location is 'Privada: solo la ve el autor (mis_sos).';

create index sos_public_location_idx on public.sos_reports using gist (public_location);
create index sos_status_idx on public.sos_reports (status, created_at desc);
create index sos_user_idx on public.sos_reports (user_id, created_at desc);
create index sos_pet_idx on public.sos_reports (pet_id) where pet_id is not null;

alter table public.sos_reports enable row level security;
-- Sin políticas a propósito: nadie lee ni escribe directo desde la app.
revoke all on public.sos_reports from anon, authenticated;

create table public.sos_photos (
  id         uuid primary key default gen_random_uuid(),
  report_id  uuid not null references public.sos_reports (id) on delete cascade,
  path       text not null check (char_length(path) <= 200),
  sort       smallint not null default 0
);

create index sos_photos_report_idx on public.sos_photos (report_id, sort);

alter table public.sos_photos enable row level security;
revoke all on public.sos_photos from anon, authenticated;

-- =====================================================================
-- FOTOS: bucket público de lectura, carpeta por usuario (como pet-photos).
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('sos-photos', 'sos-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_de_mis_sos" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'sos-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "borrar_fotos_de_mis_sos" on storage.objects for delete to authenticated
  using (bucket_id = 'sos-photos' and owner_id = (select auth.uid())::text);

-- =====================================================================
-- PUBLICAR: crear_sos() valida todo y guarda reporte + fotos de una vez.
-- =====================================================================

-- Punto aproximado: se desplaza al azar entre 150 y 200 m en cualquier dirección.
create function public.ubicacion_aproximada(exacta extensions.geography)
returns extensions.geography
language sql
volatile
set search_path = ''
as $$
  select extensions.st_project(exacta, 150 + random() * 50, radians(random() * 360));
$$;

revoke execute on function public.ubicacion_aproximada(extensions.geography) from public, anon, authenticated;

create function public.crear_sos(p jsonb)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  punto extensions.geography;
  fotos text[];
  nuevo uuid;
  i int;
begin
  if yo is null then
    raise exception 'Hace falta una cuenta' using errcode = '42501';
  end if;

  -- Límite: 3 reportes por día por usuario.
  if (select count(*) from public.sos_reports
      where user_id = yo and created_at > now() - interval '24 hours') >= 3 then
    raise exception 'limite_diario' using errcode = 'P0001';
  end if;

  if (p ->> 'kind') not in ('lost', 'found') then
    raise exception 'tipo_invalido' using errcode = '22023';
  end if;
  if (p ->> 'lat') is null or (p ->> 'lng') is null
     or abs((p ->> 'lat')::double precision) > 90 or abs((p ->> 'lng')::double precision) > 180 then
    raise exception 'ubicacion_invalida' using errcode = '22023';
  end if;
  punto := extensions.st_setsrid(
    extensions.st_makepoint((p ->> 'lng')::double precision, (p ->> 'lat')::double precision), 4326
  )::extensions.geography;

  -- Al menos una foto, todas dentro de la carpeta del usuario.
  select coalesce(array_agg(value), '{}') into fotos
  from jsonb_array_elements_text(coalesce(p -> 'photos', '[]'::jsonb));
  if array_length(fotos, 1) is null or array_length(fotos, 1) > 5 then
    raise exception 'fotos_invalidas' using errcode = '22023';
  end if;
  for i in 1..array_length(fotos, 1) loop
    if split_part(fotos[i], '/', 1) <> yo::text then
      raise exception 'fotos_invalidas' using errcode = '22023';
    end if;
  end loop;

  -- Si dice que es una mascota propia, tiene que ser suya.
  if (p ->> 'pet_id') is not null and not exists (
    select 1 from public.pets where id = (p ->> 'pet_id')::uuid and owner_id = yo
  ) then
    raise exception 'mascota_ajena' using errcode = '42501';
  end if;

  insert into public.sos_reports (
    kind, user_id, pet_id, species_id, breed_id, breed_other, name, sex, color,
    marks, description, reward, has_microchip, exact_location, public_location,
    zone_id, happened_at
  ) values (
    (p ->> 'kind')::public.sos_kind,
    yo,
    (p ->> 'pet_id')::uuid,
    (p ->> 'species_id')::smallint,
    (p ->> 'breed_id')::integer,
    nullif(trim(p ->> 'breed_other'), ''),
    nullif(trim(p ->> 'name'), ''),
    coalesce((p ->> 'sex')::public.pet_sex, 'unknown'),
    nullif(trim(p ->> 'color'), ''),
    nullif(trim(p ->> 'marks'), ''),
    nullif(trim(p ->> 'description'), ''),
    nullif(trim(p ->> 'reward'), ''),
    coalesce((p ->> 'has_microchip')::boolean, false),
    punto,
    public.ubicacion_aproximada(punto),
    (select id from public.zones where active and extensions.st_covers(area, punto) limit 1),
    least(coalesce((p ->> 'happened_at')::timestamptz, now()), now())
  )
  returning id into nuevo;

  insert into public.sos_photos (report_id, path, sort)
  select nuevo, f, ord - 1 from unnest(fotos) with ordinality as t (f, ord);

  insert into public.events (name, anon_id, user_id, target_id, props)
  values ('sos_create', gen_random_uuid(), yo, nuevo::text, jsonb_build_object('kind', p ->> 'kind'));
  return nuevo;
end;
$$;

revoke execute on function public.crear_sos(jsonb) from public, anon;
grant execute on function public.crear_sos(jsonb) to authenticated;

-- =====================================================================
-- REPORTES DE CONTENIDO (moderación): con 3 personas distintas, se oculta.
-- =====================================================================
create table public.flags (
  id          uuid primary key default gen_random_uuid(),
  target_type text not null check (target_type in ('sos')),
  target_id   uuid not null,
  reporter_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  reason      text check (char_length(reason) <= 300),
  created_at  timestamptz not null default now(),
  unique (target_type, target_id, reporter_id)   -- cada persona reporta una vez
);

alter table public.flags enable row level security;

create policy "reportar_contenido" on public.flags for insert to authenticated
  with check (reporter_id = (select auth.uid()));
create policy "ver_mis_reportes" on public.flags for select to authenticated
  using (reporter_id = (select auth.uid()));

revoke all on public.flags from anon;
revoke update, delete, truncate on public.flags from authenticated;

create function public.ocultar_con_tres_reportes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.target_type = 'sos' and (
    select count(distinct reporter_id) from public.flags
    where target_type = 'sos' and target_id = new.target_id
  ) >= 3 then
    update public.sos_reports set status = 'hidden'
    where id = new.target_id and status = 'active';
  end if;
  return new;
end;
$$;

revoke execute on function public.ocultar_con_tres_reportes() from public, anon, authenticated;

create trigger flags_ocultar
  after insert on public.flags
  for each row execute function public.ocultar_con_tres_reportes();

-- =====================================================================
-- MIS REPORTES: el autor ve los suyos, con la ubicación exacta.
-- =====================================================================
create function public.mis_sos()
returns table (
  id uuid, kind public.sos_kind, pet_id uuid, species_id smallint, name text,
  status public.sos_status, lat double precision, lng double precision,
  public_lat double precision, public_lng double precision,
  created_at timestamptz, happened_at timestamptz, photos text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.kind, r.pet_id, r.species_id, r.name, r.status,
         extensions.st_y(r.exact_location::extensions.geometry),
         extensions.st_x(r.exact_location::extensions.geometry),
         extensions.st_y(r.public_location::extensions.geometry),
         extensions.st_x(r.public_location::extensions.geometry),
         r.created_at, r.happened_at,
         array(select f.path from public.sos_photos f where f.report_id = r.id order by f.sort)
  from public.sos_reports r
  where r.user_id = (select auth.uid())
  order by r.created_at desc;
$$;

revoke execute on function public.mis_sos() from public, anon;
grant execute on function public.mis_sos() to authenticated;
