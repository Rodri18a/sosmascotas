-- Etapa 1.3: comercios con cuenta (D77), opción C de 06-reglas-negocio.md.
--  · 1.3.1 businesses ampliada (dueño, plan, RUT privado, Facebook, promo,
--    cobertura, Socio Fundador), fotos y contactos privados.
--  · 1.3.2 place_marks: cualquier usuario marca un lugar (solo el rubro,
--    sin nombre); a menos de 30 m y del mismo rubro se suman.
--  · 1.3.3 alta de negocio: aparece al instante como "no verificado".
--  · 1.3.4 reclamar un lugar (sin dueño o marcado) + verificación con RUT;
--    si ya tiene dueño, se abre una disputa. Lo resuelve el administrador.
--  · 1.3.6 panel del comercio con los contadores de `events`.

alter table public.businesses
  add column owner_id uuid references auth.users (id) on delete set null,
  add column plan text not null default 'basic' check (plan in ('basic', 'featured', 'plus')),
  add column rut text check (rut ~ '^[0-9]{12}$'),                      -- privado
  add column facebook text check (facebook ~ '^[A-Za-z0-9.\-]{1,60}$'),
  add column promo text check (char_length(promo) <= 200),
  add column coverage text check (char_length(coverage) <= 120),        -- sin local: dónde trabaja
  add column founder_until date,
  add column renac_requested_at timestamptz,
  add column verification_requested_at timestamptz;

create index businesses_owner_idx on public.businesses (owner_id) where owner_id is not null;

-- ---------------------------------------------------------------------
-- Fotos (públicas: son de la ficha) y contactos privados (solo el dueño y
-- la administración)
-- ---------------------------------------------------------------------
create table public.business_photos (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  path         text not null check (char_length(path) <= 200),
  sort         smallint not null default 0,
  created_at   timestamptz not null default now()
);

create index business_photos_business_idx on public.business_photos (business_id, sort);

create table public.business_contacts_private (
  business_id  uuid primary key references public.businesses (id) on delete cascade,
  phone        text check (phone ~ '^\+?[0-9 ]{6,20}$'),
  whatsapp     text check (whatsapp ~ '^\+?[0-9 ]{6,20}$'),
  email        text check (char_length(email) <= 120 and email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  updated_at   timestamptz not null default now()
);

create function public.soy_duenio_de(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.businesses
                 where id = p_business and owner_id = (select auth.uid()));
$$;

revoke all on function public.soy_duenio_de(uuid) from public, anon;
grant execute on function public.soy_duenio_de(uuid) to authenticated;

alter table public.business_photos enable row level security;
alter table public.business_contacts_private enable row level security;

create policy "ver_fotos_de_comercios" on public.business_photos for select
  to anon, authenticated
  using (exists (select 1 from public.businesses b where b.id = business_id and b.status = 'active')
         or public.soy_duenio_de(business_id) or public.es_admin());
create policy "subir_fotos_de_mi_comercio" on public.business_photos for insert to authenticated
  with check (public.soy_duenio_de(business_id));
create policy "ordenar_fotos_de_mi_comercio" on public.business_photos for update to authenticated
  using (public.soy_duenio_de(business_id)) with check (public.soy_duenio_de(business_id));
create policy "borrar_fotos_de_mi_comercio" on public.business_photos for delete to authenticated
  using (public.soy_duenio_de(business_id) or public.es_admin());

create policy "ver_mis_contactos_privados" on public.business_contacts_private for select to authenticated
  using (public.soy_duenio_de(business_id) or public.es_admin());
create policy "cargar_mis_contactos_privados" on public.business_contacts_private for insert to authenticated
  with check (public.soy_duenio_de(business_id));
create policy "cambiar_mis_contactos_privados" on public.business_contacts_private for update to authenticated
  using (public.soy_duenio_de(business_id)) with check (public.soy_duenio_de(business_id));

revoke all on public.business_contacts_private from anon;
revoke insert, update, delete on public.business_photos from anon;

-- Plan Básico: hasta 3 fotos (06); Destacado y Plus, galería (hasta 20).
create function public.business_photos_tope()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  tope int := case (select plan from public.businesses where id = new.business_id)
                when 'basic' then 3 else 20 end;
begin
  if (select count(*) from public.business_photos where business_id = new.business_id) >= tope then
    raise exception 'Llegaste al máximo de fotos de tu plan' using errcode = '54000';
  end if;
  return new;
end;
$$;

create trigger business_photos_tope before insert on public.business_photos
  for each row execute function public.business_photos_tope();

-- Bucket público de fotos de comercios: <business_id>/<archivo>, sube el dueño.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('business-photos', 'business-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_del_comercio" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'business-photos'
    and public.soy_duenio_de(((storage.foldername(name))[1])::uuid)
  );
create policy "borrar_fotos_del_comercio" on storage.objects for delete to authenticated
  using (
    bucket_id = 'business-photos'
    and public.soy_duenio_de(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------
-- 1.3.2 Lugares marcados por usuarios (sin nombre: solo el rubro)
-- ---------------------------------------------------------------------
create table public.place_marks (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  category     text not null check (category in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                                                 'hotel', 'trainer', 'pet_friendly', 'shelter')),
  location     extensions.geography(point, 4326) not null,
  google_link  text check (google_link ~ '^https://(www\.)?(google\.[a-z.]+/maps|maps\.app\.goo\.gl|goo\.gl/maps)/'
                           and char_length(google_link) <= 300),
  business_id  uuid references public.businesses (id) on delete set null,   -- cuando se reclama
  created_at   timestamptz not null default now()
);

create index place_marks_location_idx on public.place_marks using gist (location);

alter table public.place_marks enable row level security;
-- Cada uno ve y borra las suyas; el mapa ve los grupos con la función de abajo.
create policy "ver_mis_marcas" on public.place_marks for select to authenticated
  using (user_id = (select auth.uid()) or public.es_admin());
create policy "borrar_mis_marcas" on public.place_marks for delete to authenticated
  using (user_id = (select auth.uid()) and business_id is null);
revoke all on public.place_marks from anon;
revoke insert, update on public.place_marks from authenticated;

create function public.marcar_lugar(p_rubro text, p_lat double precision, p_lng double precision,
                                    p_link text default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  id_ uuid;
  punto extensions.geography := extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if (select count(*) from public.place_marks where user_id = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiadas marcas hoy' using errcode = '54000';
  end if;
  -- La misma persona no suma dos veces el mismo lugar.
  if exists (select 1 from public.place_marks
             where user_id = yo and category = p_rubro
               and extensions.st_dwithin(location, punto, 30)) then
    raise exception 'Ya marcaste este lugar' using errcode = '23505';
  end if;
  insert into public.place_marks (user_id, category, location, google_link)
  values (yo, p_rubro, punto, nullif(trim(p_link), ''))
  returning id into id_;
  return id_;
end;
$$;

-- Grupos de marcas sin reclamar de la zona visible: mismo rubro a menos de
-- 30 m se suman ("marcado por N usuarios"). Sin datos de quién marcó.
create function public.lugares_sin_reclamar_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision
)
returns table (grupo text, category text, lat double precision, lng double precision,
               marcas integer, google_link text)
language sql stable security definer set search_path = ''
as $$
  with visibles as (
    select m.*, extensions.st_clusterdbscan(m.location::extensions.geometry, eps := 0.0003, minpoints := 1)
             over (partition by m.category) as cl
    from public.place_marks m
    where m.business_id is null
      and m.location operator(extensions.&&)
          extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  )
  select v.category || ':' || min(v.id::text),
         v.category,
         avg(extensions.st_y(v.location::extensions.geometry)),
         avg(extensions.st_x(v.location::extensions.geometry)),
         count(distinct v.user_id)::int,
         max(v.google_link)
  from visibles v
  group by v.category, v.cl
  limit 300;
$$;

-- ---------------------------------------------------------------------
-- 1.3.3 Alta de negocio y 1.3.5 edición por su dueño
-- ---------------------------------------------------------------------
-- Columnas que el dueño puede tocar (nunca verificación, RENAC, plan,
-- Socio Fundador ni dueño).
create function public.datos_de_negocio_validos(p jsonb)
returns boolean
language sql immutable set search_path = ''
as $$
  select not exists (
    select 1 from jsonb_object_keys(p) k
    where k not in ('business_type', 'kind', 'name', 'description', 'address', 'lat', 'lng',
                    'phone', 'whatsapp', 'web', 'instagram', 'facebook', 'promo', 'coverage',
                    'hours', 'special_days', 'is_24h', 'emergencies', 'species_ids', 'status',
                    'marcas')
  );
$$;

create function public.alta_negocio(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  id_ uuid;
  punto extensions.geography;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if not public.datos_de_negocio_validos(p) then
    raise exception 'Datos no permitidos' using errcode = '22023';
  end if;
  if (select count(*) from public.businesses where owner_id = yo) >= 5 then
    raise exception 'Máximo 5 negocios por cuenta' using errcode = '54000';
  end if;
  if p ->> 'lat' is not null and p ->> 'lng' is not null then
    punto := extensions.st_setsrid(extensions.st_makepoint((p ->> 'lng')::double precision,
                                                           (p ->> 'lat')::double precision), 4326)::extensions.geography;
  end if;
  insert into public.businesses (
    owner_id, business_type, kind, name, description, address, location, zone_id,
    phone, whatsapp, web, instagram, facebook, coverage, hours, special_days, is_24h,
    emergencies, species_ids, verification, status
  ) values (
    yo, coalesce(p ->> 'business_type', 'vet'), coalesce(p ->> 'kind', 'local'),
    p ->> 'name', p ->> 'description', p ->> 'address', punto,
    (select id from public.zones where slug = 'pando'),
    nullif(p ->> 'phone', ''), nullif(p ->> 'whatsapp', ''), nullif(p ->> 'web', ''),
    nullif(p ->> 'instagram', ''), nullif(p ->> 'facebook', ''), nullif(p ->> 'coverage', ''),
    coalesce(p -> 'hours', '{}'), coalesce(p -> 'special_days', '{}'),
    coalesce((p ->> 'is_24h')::boolean, false), coalesce((p ->> 'emergencies')::boolean, false),
    coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}'),
    'unverified', 'active'
  ) returning id into id_;
  -- Si venía de marcas de usuarios (mismo rubro, a menos de 30 m), quedan absorbidas.
  if punto is not null then
    update public.place_marks m set business_id = id_
    where m.business_id is null and m.category = coalesce(p ->> 'business_type', 'vet')
      and extensions.st_dwithin(m.location, punto, 30);
  end if;
  return id_;
end;
$$;

create function public.editar_mi_negocio(p_id uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  punto extensions.geography;
begin
  if not public.soy_duenio_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not public.datos_de_negocio_validos(p) or (p ->> 'status') not in ('active', 'hidden') and p ? 'status' then
    raise exception 'Datos no permitidos' using errcode = '22023';
  end if;
  if p ? 'lat' and p ->> 'lat' is not null and p ->> 'lng' is not null then
    punto := extensions.st_setsrid(extensions.st_makepoint((p ->> 'lng')::double precision,
                                                           (p ->> 'lat')::double precision), 4326)::extensions.geography;
  end if;
  update public.businesses b set
    business_type = coalesce(p ->> 'business_type', b.business_type),
    kind = coalesce(p ->> 'kind', b.kind),
    name = coalesce(p ->> 'name', b.name),
    description = case when p ? 'description' then nullif(p ->> 'description', '') else b.description end,
    address = case when p ? 'address' then nullif(p ->> 'address', '') else b.address end,
    location = case when p ? 'lat' then punto else b.location end,
    phone = case when p ? 'phone' then nullif(p ->> 'phone', '') else b.phone end,
    whatsapp = case when p ? 'whatsapp' then nullif(p ->> 'whatsapp', '') else b.whatsapp end,
    web = case when p ? 'web' then nullif(p ->> 'web', '') else b.web end,
    instagram = case when p ? 'instagram' then nullif(p ->> 'instagram', '') else b.instagram end,
    facebook = case when p ? 'facebook' then nullif(p ->> 'facebook', '') else b.facebook end,
    -- La promoción es de los planes pagos (06).
    promo = case when p ? 'promo' and b.plan <> 'basic' then nullif(p ->> 'promo', '') else b.promo end,
    coverage = case when p ? 'coverage' then nullif(p ->> 'coverage', '') else b.coverage end,
    hours = coalesce(p -> 'hours', b.hours),
    special_days = coalesce(p -> 'special_days', b.special_days),
    is_24h = coalesce((p ->> 'is_24h')::boolean, b.is_24h),
    emergencies = coalesce((p ->> 'emergencies')::boolean, b.emergencies),
    species_ids = case when p ? 'species_ids'
                       then coalesce(array(select jsonb_array_elements_text(p -> 'species_ids')::smallint), '{}')
                       else b.species_ids end,
    status = coalesce(p ->> 'status', b.status)
  where b.id = p_id;
end;
$$;

-- Mis negocios, con todo lo que el dueño puede ver (incluido el RUT).
create function public.mis_negocios()
returns table (
  id uuid, business_type text, kind text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text, web text,
  instagram text, facebook text, promo text, coverage text, hours jsonb, special_days jsonb,
  is_24h boolean, emergencies boolean, species_ids smallint[], verification text,
  renac_operator boolean, plan text, status text, rut text, founder_until date,
  renac_requested_at timestamptz, verification_requested_at timestamptz, verified boolean,
  is_sample boolean
)
language sql stable security definer set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry), extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.facebook, b.promo, b.coverage, b.hours,
         b.special_days, b.is_24h, b.emergencies, b.species_ids, b.verification,
         b.renac_operator, b.plan, b.status, b.rut, b.founder_until, b.renac_requested_at,
         b.verification_requested_at, b.verification = 'verified', b.is_sample
  from public.businesses b
  where b.owner_id = (select auth.uid())
  order by b.created_at;
$$;

-- Pedir la insignia ✔️ (con el RUT) o la de Operador RENAC.
create function public.pedir_verificacion(p_id uuid, p_rut text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  update public.businesses
     set rut = regexp_replace(p_rut, '[^0-9]', '', 'g'),
         verification = case when verification = 'verified' then verification else 'pending' end,
         verification_requested_at = now()
   where id = p_id;
end;
$$;

create function public.pedir_insignia_renac(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if (select business_type from public.businesses where id = p_id) <> 'vet' then
    raise exception 'Solo para veterinarias' using errcode = '22023';
  end if;
  update public.businesses set renac_requested_at = now() where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- 1.3.4 Reclamos (y disputas)
-- ---------------------------------------------------------------------
create table public.business_claims (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  rut          text check (rut ~ '^[0-9]{12}$'),
  note         text check (char_length(note) <= 500),
  kind         text not null default 'claim' check (kind in ('claim', 'dispute')),
  status       text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at   timestamptz not null default now(),
  resolved_at  timestamptz,
  resolved_by  uuid references auth.users (id) on delete set null
);

create unique index business_claims_una_pendiente
  on public.business_claims (business_id, user_id) where status = 'pending';

alter table public.business_claims enable row level security;
create policy "ver_mis_reclamos" on public.business_claims for select to authenticated
  using (user_id = (select auth.uid()) or public.es_admin());
revoke all on public.business_claims from anon;
revoke insert, update, delete on public.business_claims from authenticated;

create function public.reclamar_negocio(p_business uuid, p_rut text, p_nota text default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  dueno uuid;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select owner_id into dueno from public.businesses where id = p_business and status = 'active';
  if not found then
    raise exception 'No existe' using errcode = 'P0002';
  end if;
  if dueno = yo then
    raise exception 'Ya es tuyo' using errcode = '22023';
  end if;
  insert into public.business_claims (business_id, user_id, rut, note, kind)
  values (p_business, yo, nullif(regexp_replace(coalesce(p_rut, ''), '[^0-9]', '', 'g'), ''),
          nullif(trim(p_nota), ''), case when dueno is null then 'claim' else 'dispute' end)
  returning id into id_;
  return id_;
end;
$$;

-- ---------------------------------------------------------------------
-- 1.3.6 Panel del comercio (su dueño)
-- ---------------------------------------------------------------------
create function public.panel_negocio(p_id uuid, p_dias integer default 30)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
  antes timestamptz := desde - make_interval(days => greatest(1, least(p_dias, 365)));
begin
  if not (public.soy_duenio_de(p_id) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'aperturas', (select count(*) from public.events where business_id = p_id and name = 'place_open' and created_at >= desde),
    'aperturas_antes', (select count(*) from public.events where business_id = p_id and name = 'place_open'
                        and created_at >= antes and created_at < desde),
    'clics', (select coalesce(jsonb_object_agg(tipo, n), '{}') from (
                select props ->> 'tipo' as tipo, count(*) n from public.events
                where business_id = p_id and name = 'place_click' and created_at >= desde
                group by 1) t),
    'favoritos', (select count(*) from public.user_places where business_id = p_id and favorite),
    'visitas', (select count(*) from public.events where business_id = p_id and name = 'place_visit' and created_at >= desde),
    'socios', (select count(*) from public.user_places where business_id = p_id and is_my_vet),
    'desde', desde
  );
end;
$$;

-- ---------------------------------------------------------------------
-- Portal: reclamos, verificaciones y RENAC pendientes
-- ---------------------------------------------------------------------
create function public.admin_pendientes_comercios()
returns table (
  tipo text, id uuid, business_id uuid, negocio text, rubro text, usuario_id uuid,
  usuario_nombre text, rut text, nota text, creado timestamptz, tiene_duenio boolean
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select c.kind, c.id, b.id, b.name, b.business_type, c.user_id, p.display_name, c.rut, c.note,
         c.created_at, b.owner_id is not null
  from public.business_claims c
  join public.businesses b on b.id = c.business_id
  left join public.profiles p on p.id = c.user_id
  where c.status = 'pending'
  union all
  select 'verification', b.id, b.id, b.name, b.business_type, b.owner_id, p.display_name, b.rut,
         null, b.verification_requested_at, true
  from public.businesses b left join public.profiles p on p.id = b.owner_id
  where b.verification = 'pending'
  union all
  select 'renac', b.id, b.id, b.name, b.business_type, b.owner_id, p.display_name, b.rut,
         null, b.renac_requested_at, true
  from public.businesses b left join public.profiles p on p.id = b.owner_id
  where b.renac_requested_at is not null and not b.renac_operator
  order by 10;
end;
$$;

-- Resolver: reclamo/disputa aprobado → pasa a ser el dueño (y el RUT queda
-- cargado); verificación → ✔️; RENAC → insignia. Rechazar deja todo como estaba.
create function public.admin_resolver_comercio(p_tipo text, p_id uuid, p_aprobar boolean, p_motivo text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  reclamo public.business_claims%rowtype;
begin
  if p_tipo in ('claim', 'dispute') then
    select * into reclamo from public.business_claims where id = p_id and status = 'pending' for update;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
    update public.business_claims
       set status = case when p_aprobar then 'approved' else 'rejected' end,
           resolved_at = now(), resolved_by = yo
     where id = p_id;
    if p_aprobar then
      update public.businesses
         set owner_id = reclamo.user_id,
             rut = coalesce(reclamo.rut, rut),
             verification = case when reclamo.rut is not null then 'verified' else verification end
       where id = reclamo.business_id;
      -- Los demás reclamos pendientes del mismo lugar quedan rechazados.
      update public.business_claims
         set status = 'rejected', resolved_at = now(), resolved_by = yo
       where business_id = reclamo.business_id and status = 'pending' and id <> p_id;
    end if;
  elsif p_tipo = 'verification' then
    update public.businesses
       set verification = case when p_aprobar then 'verified' else 'unverified' end
     where id = p_id;
  elsif p_tipo = 'renac' then
    update public.businesses
       set renac_operator = p_aprobar,
           renac_requested_at = case when p_aprobar then renac_requested_at else null end
     where id = p_id;
  else
    raise exception 'Tipo inválido' using errcode = '22023';
  end if;
  perform public.registrar_accion('resolver_' || p_tipo, p_tipo, p_id::text,
                                  jsonb_build_object('aprobado', p_aprobar, 'motivo', p_motivo));
end;
$$;

-- Socio Fundador (06): plan pago gratis hasta una fecha y precio congelado después.
create function public.admin_socio_fundador(p_business uuid, p_hasta date, p_plan text default 'featured')
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_plan not in ('featured', 'plus') then
    raise exception 'Plan inválido' using errcode = '22023';
  end if;
  update public.businesses
     set founder_until = p_hasta,
         plan = case when p_hasta is null then 'basic' else p_plan end
   where id = p_business;
  perform public.registrar_accion('socio_fundador', 'business', p_business::text,
                                  jsonb_build_object('hasta', p_hasta, 'plan', p_plan));
end;
$$;

-- ¿Este lugar tiene dueño? (para ofrecer "¿Es tu negocio? Reclamalo")
create function public.lugar_tiene_duenio(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select owner_id is not null from public.businesses where id = p_business;
$$;

revoke all on function public.marcar_lugar(text, double precision, double precision, text) from public, anon;
revoke all on function public.lugares_sin_reclamar_en_zona(double precision, double precision, double precision, double precision) from public;
revoke all on function public.alta_negocio(jsonb) from public, anon;
revoke all on function public.editar_mi_negocio(uuid, jsonb) from public, anon;
revoke all on function public.mis_negocios() from public, anon;
revoke all on function public.pedir_verificacion(uuid, text) from public, anon;
revoke all on function public.pedir_insignia_renac(uuid) from public, anon;
revoke all on function public.reclamar_negocio(uuid, text, text) from public, anon;
revoke all on function public.panel_negocio(uuid, integer) from public, anon;
revoke all on function public.admin_pendientes_comercios() from public, anon;
revoke all on function public.admin_resolver_comercio(text, uuid, boolean, text) from public, anon;
revoke all on function public.admin_socio_fundador(uuid, date, text) from public, anon;
revoke all on function public.lugar_tiene_duenio(uuid) from public;
grant execute on function public.marcar_lugar(text, double precision, double precision, text) to authenticated;
grant execute on function public.lugares_sin_reclamar_en_zona(double precision, double precision, double precision, double precision) to anon, authenticated;
grant execute on function public.alta_negocio(jsonb) to authenticated;
grant execute on function public.editar_mi_negocio(uuid, jsonb) to authenticated;
grant execute on function public.mis_negocios() to authenticated;
grant execute on function public.pedir_verificacion(uuid, text) to authenticated;
grant execute on function public.pedir_insignia_renac(uuid) to authenticated;
grant execute on function public.reclamar_negocio(uuid, text, text) to authenticated;
grant execute on function public.panel_negocio(uuid, integer) to authenticated;
grant execute on function public.admin_pendientes_comercios() to authenticated;
grant execute on function public.admin_resolver_comercio(text, uuid, boolean, text) to authenticated;
grant execute on function public.admin_socio_fundador(uuid, date, text) to authenticated;
grant execute on function public.lugar_tiene_duenio(uuid) to anon, authenticated;

-- ---------------------------------------------------------------------
-- El mapa suma lo público nuevo: Facebook, promoción (planes pagos), plan
-- (pin destacado), cobertura, si tiene dueño (para "¿Es tu negocio?") y las
-- fotos. Mismos filtros que antes.
-- ---------------------------------------------------------------------
drop function public.lugares_en_zona(double precision, double precision, double precision, double precision, text[]);
create function public.lugares_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision,
  p_tipos text[] default null
)
returns table (
  id uuid, business_type text, kind text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text,
  web text, instagram text, facebook text, promo text, plan text, coverage text,
  hours jsonb, special_days jsonb, is_24h boolean,
  emergencies boolean, species_ids smallint[], verified boolean,
  renac_operator boolean, is_sample boolean, has_owner boolean, photos text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry),
         extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.facebook,
         case when b.plan <> 'basic' then b.promo end, b.plan, b.coverage,
         b.hours, b.special_days, b.is_24h,
         b.emergencies, b.species_ids, b.verification = 'verified',
         b.renac_operator, b.is_sample, b.owner_id is not null,
         array(select f.path from public.business_photos f where f.business_id = b.id order by f.sort, f.created_at)
  from public.businesses b
  where b.status = 'active'
    and b.kind = 'local'
    and (p_tipos is null or b.business_type = any (p_tipos))
    and b.location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by b.plan <> 'basic' desc, b.emergencies desc, b.is_24h desc, b.name
  limit 500;
$$;

drop function public.lugares_sin_local(smallint, text[]);
create function public.lugares_sin_local(
  p_zona smallint default null,
  p_tipos text[] default null
)
returns table (
  id uuid, business_type text, kind text, name text, description text,
  phone text, whatsapp text, web text, instagram text, facebook text, promo text,
  plan text, coverage text, hours jsonb, special_days jsonb, is_24h boolean,
  species_ids smallint[], verified boolean, is_sample boolean, has_owner boolean,
  photos text[]
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description,
         b.phone, b.whatsapp, b.web, b.instagram, b.facebook,
         case when b.plan <> 'basic' then b.promo end, b.plan, b.coverage,
         b.hours, b.special_days, b.is_24h, b.species_ids, b.verification = 'verified',
         b.is_sample, b.owner_id is not null,
         array(select f.path from public.business_photos f where f.business_id = b.id order by f.sort, f.created_at)
  from public.businesses b
  where b.status = 'active'
    and b.kind <> 'local'
    and (p_tipos is null or b.business_type = any (p_tipos))
    and (p_zona is null or b.zone_id is null or b.zone_id = p_zona)
  order by b.plan <> 'basic' desc, b.verification = 'verified' desc, b.name
  limit 200;
$$;

revoke execute on function public.lugares_en_zona(double precision, double precision, double precision, double precision, text[]) from public;
revoke execute on function public.lugares_sin_local(smallint, text[]) from public;
grant execute on function public.lugares_en_zona(double precision, double precision, double precision, double precision, text[]) to anon, authenticated;
grant execute on function public.lugares_sin_local(smallint, text[]) to anon, authenticated;
