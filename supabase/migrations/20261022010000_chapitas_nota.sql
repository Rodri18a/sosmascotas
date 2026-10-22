-- 1.8b.3 (D95): la nota para quien la encuentre ("Toma medicación") se escribe
-- en el QR digital de la mascota; la página de una chapita física la muestra
-- también. Mismo public_pet_page() de 20261022000000_chapitas.sql con ese cambio.

create or replace function public.public_pet_page(p_code text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  tag public.qr_tags;
  mascota record;
  sos_activo uuid;
begin
  select * into tag from public.qr_tags where code = upper(trim(p_code));
  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;
  if tag.pet_id is null and tag.activated_at is null and tag.active then
    return jsonb_build_object('status', 'unactivated', 'code', tag.code);
  end if;
  if tag.pet_id is null or not tag.active then
    return jsonb_build_object('status', 'inactive', 'kind', tag.kind);
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

  select r.id into sos_activo
  from public.sos_reports r
  where r.pet_id = tag.pet_id and r.kind = 'lost' and r.status = 'active'
  order by r.created_at desc
  limit 1;

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
      -- La nota la escribe el dueño en el QR digital: vale para todas sus chapitas.
      'public_note', coalesce(tag.public_note, (
        select q.public_note from public.qr_tags q
        where q.pet_id = tag.pet_id and q.kind = 'digital' and q.active
        limit 1))
    ),
    'lost', sos_activo is not null,
    'sos_id', sos_activo
  );
end;
$$;
