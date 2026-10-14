-- Paso 0.5.5: `mine` es false (no null) para visitantes sin sesión.

create or replace function public.sos_publico(p_id uuid)
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
    'mine', coalesce(r.user_id = (select auth.uid()), false)
  );
end;
$$;

