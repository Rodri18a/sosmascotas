-- Etapa 2.0: adopción responsable (D79), según 03 §11, 06 "Adopción
-- responsable" y 09. Siempre gratis y nunca venta: los refugios verificados
-- pueden indicar un aporte transparente; los particulares no piden dinero,
-- tienen como máximo 2 publicaciones activas y, con 2 camadas en 12 meses,
-- pasan a revisión. Adoptantes: como máximo 3 solicitudes activas. Notas
-- privadas por publicador (sin listas negras compartidas, Ley 18.331).
-- Proceso: Me interesa → Cuestionario → Entrevista → Visita → Compromiso →
-- Adoptado (al aceptar el compromiso la mascota pasa al adoptante con sus
-- recordatorios) → seguimiento a los 7, 30 y 90 días.

-- ---------------------------------------------------------------------
-- Perfil de adoptante (se completa una vez y se reutiliza)
-- ---------------------------------------------------------------------
create table public.adopter_profiles (
  user_id           uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  housing           text check (housing in ('casa', 'apartamento', 'otro')),
  has_yard          boolean,
  hours_alone       smallint check (hours_alone between 0 and 24),
  experience        text check (experience in ('ninguna', 'alguna', 'mucha')),
  other_pets        boolean,
  kids              boolean,
  household_agrees  boolean,
  updated_at        timestamptz not null default now()
);

create trigger adopter_profiles_updated_at
  before update on public.adopter_profiles
  for each row execute function public.set_updated_at();

alter table public.adopter_profiles enable row level security;
create policy "mi_perfil_de_adoptante" on public.adopter_profiles for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
revoke all on public.adopter_profiles from anon;

-- ---------------------------------------------------------------------
-- Publicaciones y animales
-- ---------------------------------------------------------------------
create table public.adoptions (
  id                   uuid primary key default gen_random_uuid(),
  publisher_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  publisher_kind       text not null check (publisher_kind in ('shelter', 'individual')),
  shelter_id           uuid references public.businesses (id) on delete set null,
  is_litter            boolean not null default false,
  description          text check (char_length(description) <= 2000),
  requirements         text check (char_length(requirements) <= 1000),
  contribution_amount  integer check (contribution_amount between 1 and 100000),
  contribution_covers  text check (char_length(contribution_covers) <= 200),
  zone_id              smallint references public.zones (id),
  status               text not null default 'active'
                       check (status in ('active', 'paused', 'adopted', 'hidden', 'review')),
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  -- Nunca venta: el aporte es solo de refugios y ONG (06).
  check (publisher_kind = 'shelter' or (contribution_amount is null and contribution_covers is null))
);

create index adoptions_status_idx on public.adoptions (status, created_at desc);
create index adoptions_publisher_idx on public.adoptions (publisher_id, created_at desc);

create trigger adoptions_updated_at
  before update on public.adoptions
  for each row execute function public.set_updated_at();

create table public.adoption_animals (
  id              uuid primary key default gen_random_uuid(),
  adoption_id     uuid not null references public.adoptions (id) on delete cascade,
  name            text check (char_length(trim(name)) between 1 and 40),
  species_id      smallint not null references public.species (id),
  breed_id        integer,
  age_months      smallint check (age_months between 0 and 360),
  size            text check (size in ('chico', 'mediano', 'grande')),
  energy          text check (energy in ('baja', 'media', 'alta')),
  sex             public.pet_sex not null default 'unknown',
  neutered        boolean,
  vaccinated      boolean,
  microchip       boolean,
  good_with_kids  boolean,
  good_with_dogs  boolean,
  good_with_cats  boolean,
  needs_yard      boolean not null default false,
  special_needs   text check (char_length(special_needs) <= 500),
  photos          text[] not null default '{}' check (cardinality(photos) between 1 and 8),
  adopted_pet_id  uuid references public.pets (id) on delete set null,
  foreign key (species_id, breed_id) references public.breeds (species_id, id)
);

create index adoption_animals_adoption_idx on public.adoption_animals (adoption_id);

-- Fotos: bucket público, cada uno en su carpeta.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('adoption-photos', 'adoption-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public, file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_de_adopcion" on storage.objects for insert to authenticated
  with check (bucket_id = 'adoption-photos'
              and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "borrar_fotos_de_adopcion" on storage.objects for delete to authenticated
  using (bucket_id = 'adoption-photos' and owner_id = (select auth.uid())::text);

-- ---------------------------------------------------------------------
-- Solicitudes, notas privadas, compromiso y seguimiento
-- ---------------------------------------------------------------------
create table public.adoption_requests (
  id                  uuid primary key default gen_random_uuid(),
  adoption_animal_id  uuid not null references public.adoption_animals (id) on delete cascade,
  adopter_id          uuid not null default auth.uid() references auth.users (id) on delete cascade,
  stage               text not null default 'interest'
                      check (stage in ('interest', 'questionnaire', 'interview', 'visit', 'agreement',
                                       'adopted', 'rejected', 'withdrawn')),
  message             text check (char_length(message) <= 1000),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (adoption_animal_id, adopter_id)
);

create index adoption_requests_adopter_idx on public.adoption_requests (adopter_id, stage);

create trigger adoption_requests_updated_at
  before update on public.adoption_requests
  for each row execute function public.set_updated_at();

create table public.adoption_request_notes (
  request_id    uuid primary key references public.adoption_requests (id) on delete cascade,
  publisher_id  uuid not null default auth.uid() references auth.users (id) on delete cascade,
  notes         text check (char_length(notes) <= 4000),
  updated_at    timestamptz not null default now()
);

create table public.adoption_commitments (
  request_id       uuid primary key references public.adoption_requests (id) on delete cascade,
  accepted_at      timestamptz not null default now(),
  text_version     text not null check (char_length(text_version) <= 40),
  neuter_deadline  date
);

create table public.adoption_followups (
  id           uuid primary key default gen_random_uuid(),
  request_id   uuid not null references public.adoption_requests (id) on delete cascade,
  day          smallint not null check (day in (7, 30, 90)),
  due_on       date not null,
  photo_path   text check (char_length(photo_path) <= 200),
  answer       text check (char_length(answer) <= 1000),
  answered_at  timestamptz,
  unique (request_id, day)
);

-- Sin acceso directo a publicaciones, solicitudes, compromisos ni
-- seguimientos: todo con las funciones de abajo (reglas y límites de 06).
alter table public.adoptions enable row level security;
alter table public.adoption_animals enable row level security;
alter table public.adoption_requests enable row level security;
alter table public.adoption_request_notes enable row level security;
alter table public.adoption_commitments enable row level security;
alter table public.adoption_followups enable row level security;
revoke all on public.adoptions, public.adoption_animals, public.adoption_requests,
  public.adoption_request_notes, public.adoption_commitments, public.adoption_followups
  from anon, authenticated;

-- ---------------------------------------------------------------------
-- Publicar
-- ---------------------------------------------------------------------
-- [p]: description, requirements, contribution_amount, contribution_covers,
-- shelter_id (si publica un refugio verificado). [p_animales]: lista de
-- animales (más de uno = camada, hasta 8).
create function public.publicar_adopcion(p jsonb, p_animales jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  refugio uuid := nullif(p ->> 'shelter_id', '')::uuid;
  tipo text;
  camada boolean := jsonb_array_length(p_animales) > 1;
  estado text := 'active';
  id_ uuid;
  a jsonb;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if jsonb_typeof(p_animales) <> 'array' or jsonb_array_length(p_animales) not between 1 and 8 then
    raise exception 'Entre 1 y 8 animales' using errcode = '22023';
  end if;
  if refugio is not null then
    if not exists (select 1 from public.businesses
                   where id = refugio and owner_id = yo and business_type = 'shelter'
                     and verification = 'verified') then
      raise exception 'Solo refugios verificados de tu cuenta' using errcode = '42501';
    end if;
    tipo := 'shelter';
  else
    tipo := 'individual';
    if (p ? 'contribution_amount' and p ->> 'contribution_amount' is not null)
       or (p ? 'contribution_covers' and p ->> 'contribution_covers' is not null) then
      raise exception 'Los particulares no pueden pedir dinero' using errcode = '22023';
    end if;
    if (select count(*) from public.adoptions
        where publisher_id = yo and publisher_kind = 'individual'
          and status in ('active', 'paused', 'review')) >= 2 then
      raise exception 'Máximo 2 publicaciones activas' using errcode = '54000';
    end if;
    -- Segunda camada en 12 meses: revisión del administrador (06).
    if camada and (select count(*) from public.adoptions
                   where publisher_id = yo and is_litter
                     and created_at > now() - interval '12 months') >= 1 then
      estado := 'review';
    end if;
  end if;
  insert into public.adoptions (publisher_id, publisher_kind, shelter_id, is_litter, description,
                                requirements, contribution_amount, contribution_covers, zone_id, status)
  values (yo, tipo, refugio, camada, nullif(p ->> 'description', ''), nullif(p ->> 'requirements', ''),
          case when tipo = 'shelter' then (p ->> 'contribution_amount')::integer end,
          case when tipo = 'shelter' then nullif(p ->> 'contribution_covers', '') end,
          (select id from public.zones where slug = 'pando'), estado)
  returning id into id_;
  for a in select * from jsonb_array_elements(p_animales) loop
    if exists (select 1 from jsonb_array_elements_text(coalesce(a -> 'photos', '[]')) f
               where f !~ ('^' || yo::text || '/[A-Za-z0-9._-]+$')) then
      raise exception 'Fotos inválidas' using errcode = '22023';
    end if;
    insert into public.adoption_animals (
      adoption_id, name, species_id, breed_id, age_months, size, energy, sex, neutered,
      vaccinated, microchip, good_with_kids, good_with_dogs, good_with_cats, needs_yard,
      special_needs, photos
    ) values (
      id_, nullif(a ->> 'name', ''), (a ->> 'species_id')::smallint, (a ->> 'breed_id')::integer,
      (a ->> 'age_months')::smallint, a ->> 'size', a ->> 'energy',
      coalesce((a ->> 'sex')::public.pet_sex, 'unknown'),
      (a ->> 'neutered')::boolean, (a ->> 'vaccinated')::boolean, (a ->> 'microchip')::boolean,
      (a ->> 'good_with_kids')::boolean, (a ->> 'good_with_dogs')::boolean,
      (a ->> 'good_with_cats')::boolean, coalesce((a ->> 'needs_yard')::boolean, false),
      nullif(a ->> 'special_needs', ''),
      array(select jsonb_array_elements_text(coalesce(a -> 'photos', '[]')))
    );
  end loop;
  return id_;
end;
$$;

-- Cambiar el estado de una publicación propia (pausar, reactivar, ocultar).
create function public.estado_adopcion(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if p_estado not in ('active', 'paused', 'hidden') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  update public.adoptions set status = p_estado
   where id = p_id and publisher_id = (select auth.uid()) and status <> 'review';
  if not found then raise exception 'No es tuya o está en revisión' using errcode = '42501'; end if;
end;
$$;

-- Animales en adopción (activos). Sin datos de quien publica, salvo el
-- nombre del refugio verificado.
create function public.adopciones_disponibles(p_especie smallint default null)
returns table (
  animal_id uuid, adoption_id uuid, name text, species_id smallint, breed text, age_months smallint,
  size text, energy text, sex text, neutered boolean, vaccinated boolean, microchip boolean,
  good_with_kids boolean, good_with_dogs boolean, good_with_cats boolean, needs_yard boolean,
  special_needs text, photos text[], description text, requirements text, contribution_amount integer,
  contribution_covers text, publisher_kind text, shelter_name text, is_litter boolean,
  mine boolean, created_at timestamptz
)
language sql stable security definer set search_path = ''
as $$
  select an.id, ad.id, an.name, an.species_id, coalesce(b.name, ''), an.age_months, an.size, an.energy,
         an.sex::text, an.neutered, an.vaccinated, an.microchip, an.good_with_kids, an.good_with_dogs,
         an.good_with_cats, an.needs_yard, an.special_needs, an.photos, ad.description, ad.requirements,
         ad.contribution_amount, ad.contribution_covers, ad.publisher_kind, s.name, ad.is_litter,
         ad.publisher_id = (select auth.uid()), ad.created_at
  from public.adoption_animals an
  join public.adoptions ad on ad.id = an.adoption_id
  left join public.breeds b on b.species_id = an.species_id and b.id = an.breed_id
  left join public.businesses s on s.id = ad.shelter_id
  where ad.status = 'active' and an.adopted_pet_id is null
    and (p_especie is null or an.species_id = p_especie)
  order by ad.created_at desc
  limit 200;
$$;

-- ---------------------------------------------------------------------
-- Solicitudes
-- ---------------------------------------------------------------------
create function public.me_interesa(p_animal uuid, p_mensaje text default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  publicador uuid;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  select ad.publisher_id into publicador
  from public.adoption_animals an join public.adoptions ad on ad.id = an.adoption_id
  where an.id = p_animal and ad.status = 'active' and an.adopted_pet_id is null;
  if publicador is null then raise exception 'No está disponible' using errcode = 'P0002'; end if;
  if publicador = yo then raise exception 'Es tu publicación' using errcode = '22023'; end if;
  if (select count(*) from public.adoption_requests
      where adopter_id = yo and stage not in ('adopted', 'rejected', 'withdrawn')) >= 3 then
    raise exception 'Máximo 3 solicitudes activas' using errcode = '54000';
  end if;
  insert into public.adoption_requests (adoption_animal_id, adopter_id, message)
  values (p_animal, yo, nullif(trim(p_mensaje), ''))
  on conflict (adoption_animal_id, adopter_id) do update
    set stage = case when public.adoption_requests.stage = 'withdrawn' then 'interest'
                     else public.adoption_requests.stage end
  returning id into id_;
  return id_;
end;
$$;

-- Mis solicitudes (como adoptante).
create function public.mis_solicitudes_adopcion()
returns table (id uuid, animal_id uuid, name text, species_id smallint, photos text[], stage text,
               updated_at timestamptz, compromiso_aceptado boolean)
language sql stable security definer set search_path = ''
as $$
  select r.id, an.id, an.name, an.species_id, an.photos, r.stage, r.updated_at,
         exists (select 1 from public.adoption_commitments c where c.request_id = r.id)
  from public.adoption_requests r
  join public.adoption_animals an on an.id = r.adoption_animal_id
  where r.adopter_id = (select auth.uid())
  order by r.updated_at desc;
$$;

-- Solicitudes de mis publicaciones (como publicador), con el perfil de
-- adoptante (para la compatibilidad), el nombre visible y mi nota privada.
create function public.solicitudes_recibidas()
returns table (id uuid, animal_id uuid, animal text, stage text, message text, adoptante text,
               perfil jsonb, nota text, created_at timestamptz,
               seguimiento jsonb)
language sql stable security definer set search_path = ''
as $$
  select r.id, an.id, an.name, r.stage, r.message, coalesce(p.display_name, ''),
         (select to_jsonb(ap) - 'user_id' from public.adopter_profiles ap where ap.user_id = r.adopter_id),
         n.notes, r.created_at,
         (select coalesce(jsonb_agg(jsonb_build_object('day', f.day, 'answer', f.answer,
                                                       'photo', f.photo_path, 'answered_at', f.answered_at)
                                    order by f.day), '[]')
          from public.adoption_followups f where f.request_id = r.id)
  from public.adoption_requests r
  join public.adoption_animals an on an.id = r.adoption_animal_id
  join public.adoptions ad on ad.id = an.adoption_id
  left join public.profiles p on p.id = r.adopter_id
  left join public.adoption_request_notes n on n.request_id = r.id
  where ad.publisher_id = (select auth.uid())
  order by r.updated_at desc;
$$;

-- El publicador avanza o rechaza; el adoptante puede retirarse.
create function public.avanzar_solicitud(p_id uuid, p_etapa text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r record;
begin
  select req.*, ad.publisher_id into r
  from public.adoption_requests req
  join public.adoption_animals an on an.id = req.adoption_animal_id
  join public.adoptions ad on ad.id = an.adoption_id
  where req.id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if r.stage in ('adopted', 'rejected', 'withdrawn') then
    raise exception 'La solicitud ya terminó' using errcode = '22023';
  end if;
  if p_etapa = 'withdrawn' then
    if r.adopter_id <> yo then raise exception 'No es tu solicitud' using errcode = '42501'; end if;
  elsif p_etapa in ('questionnaire', 'interview', 'visit', 'agreement', 'rejected') then
    if r.publisher_id <> yo then raise exception 'No es tu publicación' using errcode = '42501'; end if;
  else
    -- "adopted" solo se llega aceptando el compromiso.
    raise exception 'Etapa inválida' using errcode = '22023';
  end if;
  update public.adoption_requests set stage = p_etapa where id = p_id;
end;
$$;

create function public.nota_de_solicitud(p_id uuid, p_nota text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if not exists (select 1 from public.adoption_requests req
                 join public.adoption_animals an on an.id = req.adoption_animal_id
                 join public.adoptions ad on ad.id = an.adoption_id
                 where req.id = p_id and ad.publisher_id = yo) then
    raise exception 'No es tu publicación' using errcode = '42501';
  end if;
  insert into public.adoption_request_notes (request_id, publisher_id, notes)
  values (p_id, yo, nullif(trim(p_nota), ''))
  on conflict (request_id) do update set notes = excluded.notes, updated_at = now();
end;
$$;

-- El adoptante acepta el compromiso: queda registrado, la mascota pasa a su
-- cuenta con sus datos, se crean los recordatorios (castración con fecha
-- límite si no está castrada, vacunas y microchip si faltan) y el
-- seguimiento a los 7, 30 y 90 días.
create function public.aceptar_compromiso(p_id uuid, p_version text, p_meses_castracion smallint default 6)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r record;
  mascota uuid;
  limite date;
  manana timestamptz := date_trunc('day', now()) + interval '1 day 10 hours';
begin
  select req.stage, req.adopter_id, req.adoption_animal_id, an.name, an.species_id, an.breed_id,
         an.sex, an.neutered, an.vaccinated, an.microchip, ad.id as adopcion
    into r
  from public.adoption_requests req
  join public.adoption_animals an on an.id = req.adoption_animal_id
  join public.adoptions ad on ad.id = an.adoption_id
  where req.id = p_id;
  if not found or r.adopter_id <> yo then
    raise exception 'No es tu solicitud' using errcode = '42501';
  end if;
  if r.stage <> 'agreement' then
    raise exception 'Todavía no está en la etapa de compromiso' using errcode = '22023';
  end if;
  limite := case when coalesce(r.neutered, false) then null
                 else (now() + make_interval(months => greatest(1, least(p_meses_castracion, 12))))::date end;
  insert into public.adoption_commitments (request_id, text_version, neuter_deadline)
  values (p_id, p_version, limite);
  insert into public.pets (owner_id, name, species_id, breed_id, sex, neutered)
  values (yo, coalesce(r.name, 'Mi mascota'), r.species_id, r.breed_id, r.sex, r.neutered)
  returning id into mascota;
  update public.adoption_animals set adopted_pet_id = mascota where id = r.adoption_animal_id;
  update public.adoption_requests set stage = 'adopted' where id = p_id;
  -- Los demás interesados en este animal quedan rechazados.
  update public.adoption_requests set stage = 'rejected'
   where adoption_animal_id = r.adoption_animal_id and id <> p_id
     and stage not in ('adopted', 'rejected', 'withdrawn');
  -- Si ya no queda ningún animal de la publicación, queda adoptada.
  if not exists (select 1 from public.adoption_animals
                 where adoption_id = r.adopcion and adopted_pet_id is null) then
    update public.adoptions set status = 'adopted' where id = r.adopcion;
  end if;
  if limite is not null then
    insert into public.reminders (pet_id, kind, title, schedule, starts_at)
    values (mascota, 'checkup', 'Castración (compromiso de adopción)', '{"tipo": "una_vez"}',
            (limite - 14)::timestamptz + interval '10 hours');
  end if;
  if not coalesce(r.vaccinated, false) then
    insert into public.reminders (pet_id, kind, title, schedule, starts_at)
    values (mascota, 'vaccine', 'Poner las vacunas al día', '{"tipo": "una_vez"}', manana + interval '6 days');
  end if;
  if not coalesce(r.microchip, false) then
    insert into public.reminders (pet_id, kind, title, schedule, starts_at)
    values (mascota, 'checkup', 'Microchip y registro en el RENAC', '{"tipo": "una_vez"}', manana + interval '13 days');
  end if;
  insert into public.adoption_followups (request_id, day, due_on)
  select p_id, d, (now() + make_interval(days => d))::date from unnest(array[7, 30, 90]) d;
  return mascota;
end;
$$;

-- Seguimiento: el adoptante ve los suyos y responde (foto opcional).
create function public.mis_seguimientos()
returns table (id uuid, request_id uuid, day smallint, due_on date, answered boolean, animal text, pet_id uuid)
language sql stable security definer set search_path = ''
as $$
  select f.id, f.request_id, f.day, f.due_on, f.answered_at is not null, an.name, an.adopted_pet_id
  from public.adoption_followups f
  join public.adoption_requests r on r.id = f.request_id
  join public.adoption_animals an on an.id = r.adoption_animal_id
  where r.adopter_id = (select auth.uid())
  order by f.due_on;
$$;

create function public.responder_seguimiento(p_id uuid, p_respuesta text, p_foto text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if p_foto is not null and p_foto !~ ('^' || yo::text || '/[A-Za-z0-9._-]+$') then
    raise exception 'Foto inválida' using errcode = '22023';
  end if;
  update public.adoption_followups f
     set answer = nullif(trim(p_respuesta), ''), photo_path = p_foto, answered_at = now()
    from public.adoption_requests r
   where f.id = p_id and r.id = f.request_id and r.adopter_id = yo and f.due_on <= current_date + 1;
  if not found then raise exception 'Todavía no o no es tuyo' using errcode = '42501'; end if;
end;
$$;

-- Portal: publicaciones en revisión (camadas repetidas de particulares).
create function public.admin_adopciones_en_revision()
returns table (id uuid, publicador text, animales integer, camadas_12m integer, created_at timestamptz)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select ad.id, p.display_name,
         (select count(*)::int from public.adoption_animals an where an.adoption_id = ad.id),
         (select count(*)::int from public.adoptions x where x.publisher_id = ad.publisher_id and x.is_litter
            and x.created_at > now() - interval '12 months'),
         ad.created_at
  from public.adoptions ad left join public.profiles p on p.id = ad.publisher_id
  where ad.status = 'review'
  order by ad.created_at;
end;
$$;

create function public.admin_revisar_adopcion(p_id uuid, p_aprobar boolean)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  update public.adoptions set status = case when p_aprobar then 'active' else 'hidden' end
   where id = p_id and status = 'review';
  perform public.registrar_accion('revisar_adopcion', 'adoption', p_id::text,
                                  jsonb_build_object('aprobado', p_aprobar));
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'publicar_adopcion(jsonb, jsonb)', 'estado_adopcion(uuid, text)', 'me_interesa(uuid, text)',
    'mis_solicitudes_adopcion()', 'solicitudes_recibidas()', 'avanzar_solicitud(uuid, text)',
    'nota_de_solicitud(uuid, text)', 'aceptar_compromiso(uuid, text, smallint)',
    'mis_seguimientos()', 'responder_seguimiento(uuid, text, text)',
    'admin_adopciones_en_revision()', 'admin_revisar_adopcion(uuid, boolean)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

revoke all on function public.adopciones_disponibles(smallint) from public;
grant execute on function public.adopciones_disponibles(smallint) to anon, authenticated;
