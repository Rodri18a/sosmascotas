-- Paso 0.5.3: las fotos de un SOS se guardan como "<bucket>/<user_id>/<archivo>",
-- para poder reusar la foto de la ficha de la mascota (pet-photos) al reportarla
-- perdida. Se reemplaza crear_sos() con la nueva validación.

create or replace function public.crear_sos(p jsonb)
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

  -- Al menos una foto (máx. 5), todas en una carpeta del usuario. Formato
  -- "<bucket>/<user_id>/<archivo>": puede ser una foto nueva (sos-photos) o la
  -- de la ficha de su mascota (pet-photos), para no pedirla de nuevo.
  select coalesce(array_agg(value), '{}') into fotos
  from jsonb_array_elements_text(coalesce(p -> 'photos', '[]'::jsonb));
  if array_length(fotos, 1) is null or array_length(fotos, 1) > 5 then
    raise exception 'fotos_invalidas' using errcode = '22023';
  end if;
  for i in 1..array_length(fotos, 1) loop
    if split_part(fotos[i], '/', 1) not in ('sos-photos', 'pet-photos')
       or split_part(fotos[i], '/', 2) <> yo::text
       or fotos[i] like '%..%' then
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

