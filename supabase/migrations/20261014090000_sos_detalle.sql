-- Paso 0.5.5: detalle público de un SOS y WhatsApp directo opcional.

-- WhatsApp directo: desactivado por defecto (regla 7). Si el autor lo activa en un
-- reporte, ese reporte muestra su WhatsApp (guardado en private_contacts).
alter table public.sos_reports add column show_whatsapp boolean not null default false;

-- El dueño guarda su WhatsApp (solo se usa si activa "mostrar WhatsApp" en un SOS).
create function public.guardar_mi_whatsapp(p_whatsapp text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  limpio text := nullif(trim(p_whatsapp), '');
begin
  if yo is null then
    raise exception 'Hace falta una cuenta' using errcode = '42501';
  end if;
  insert into public.private_contacts (user_id, whatsapp)
  values (yo, limpio)
  on conflict (user_id) do update set whatsapp = excluded.whatsapp, updated_at = now();
end;
$$;

revoke execute on function public.guardar_mi_whatsapp(text) from public, anon;
grant execute on function public.guardar_mi_whatsapp(text) to authenticated;

-- crear_sos() ahora también recibe show_whatsapp.
create or replace function public.activar_whatsapp_en_sos(p_sos_id uuid, p_activo boolean)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  update public.sos_reports set show_whatsapp = coalesce(p_activo, false)
  where id = p_sos_id and user_id = (select auth.uid());
  if not found then
    raise exception 'No es tu reporte' using errcode = '42501';
  end if;
end;
$$;

revoke execute on function public.activar_whatsapp_en_sos(uuid, boolean) from public, anon;
grant execute on function public.activar_whatsapp_en_sos(uuid, boolean) to authenticated;

-- Detalle público: nunca la ubicación exacta ni el autor. Si quien pide es el
-- autor, se indica `mine` (para mostrarle sus acciones: "¡Apareció!", etc.).
create function public.sos_publico(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  r record;
begin
  select rep.*, s.name as species, s.icon as species_icon, coalesce(b.name, rep.breed_other) as breed,
         extensions.st_y(rep.public_location::extensions.geometry) as public_lat,
         extensions.st_x(rep.public_location::extensions.geometry) as public_lng
    into r
  from public.sos_reports rep
  join public.species s on s.id = rep.species_id
  left join public.breeds b on b.id = rep.breed_id
  where rep.id = p_id;

  if not found or (r.status = 'hidden' and r.user_id is distinct from (select auth.uid())) then
    return jsonb_build_object('status', 'not_found');
  end if;

  return jsonb_build_object(
    'status', r.status,
    'id', r.id,
    'kind', r.kind,
    'name', r.name,
    'species', r.species,
    'species_icon', r.species_icon,
    'breed', r.breed,
    'sex', r.sex,
    'color', r.color,
    'marks', r.marks,
    'description', r.description,
    'reward', r.reward,
    'has_microchip', r.has_microchip,
    'happened_at', r.happened_at,
    'created_at', r.created_at,
    'lat', r.public_lat,
    'lng', r.public_lng,
    'photos', (select coalesce(jsonb_agg(f.path order by f.sort), '[]'::jsonb)
               from public.sos_photos f where f.report_id = r.id),
    'whatsapp', case when r.show_whatsapp and r.status = 'active'
                     then (select c.whatsapp from public.private_contacts c where c.user_id = r.user_id)
                end,
    'show_whatsapp', r.show_whatsapp,
    'mine', r.user_id = (select auth.uid())
  );
end;
$$;

revoke execute on function public.sos_publico(uuid) from public;
grant execute on function public.sos_publico(uuid) to anon, authenticated;
