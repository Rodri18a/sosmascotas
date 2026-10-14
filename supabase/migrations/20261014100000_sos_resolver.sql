-- Paso 0.5.6: "¡Apareció!" (resolver) y archivar un SOS; la página del QR muestra
-- "Estoy perdido 🆘" mientras la mascota tenga un SOS de pérdida activo.

-- El autor cambia el estado de su reporte: 'resolved' (¡apareció!) o 'archived'.
create function public.cerrar_sos(p_id uuid, p_estado text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if p_estado not in ('resolved', 'archived') then
    raise exception 'estado_invalido' using errcode = '22023';
  end if;
  update public.sos_reports
  set status = p_estado::public.sos_status,
      resolved_at = case when p_estado = 'resolved' then now() end,
      last_activity_at = now()
  where id = p_id and user_id = yo and status in ('active', 'hidden');
  if not found then
    raise exception 'No es tu reporte o ya está cerrado' using errcode = '42501';
  end if;
  if p_estado = 'resolved' then
    insert into public.events (name, anon_id, user_id, target_id)
    values ('sos_resolve', gen_random_uuid(), yo, p_id::text);
  end if;
end;
$$;

revoke execute on function public.cerrar_sos(uuid, text) from public, anon;
grant execute on function public.cerrar_sos(uuid, text) to authenticated;

-- public_pet_page(): `lost` es verdadero si la mascota tiene un SOS de pérdida activo,
-- y en ese caso se incluye su id para enlazar al reporte.
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
  if tag.pet_id is null then
    return jsonb_build_object('status', 'unactivated');
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
      'public_note', tag.public_note
    ),
    'lost', sos_activo is not null,
    'sos_id', sos_activo
  );
end;
$$;
