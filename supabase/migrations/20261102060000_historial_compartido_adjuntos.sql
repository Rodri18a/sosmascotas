-- D133: el historial compartido devuelve las rutas de los adjuntos de cada
-- acontecimiento. Solas no abren nada (el bucket es privado): la página pide
-- los enlaces firmados a la Edge Function historial-adjuntos con el token.
create or replace function public.historial_compartido(p_token text)
returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  s public.pet_shares;
  resultado jsonb;
begin
  select * into s from public.pet_shares
   where token = p_token and revoked_at is null and expires_at > now();
  if not found then
    return null;
  end if;
  update public.pet_shares set views = views + 1 where id = s.id;
  select jsonb_build_object(
    'expires_at', s.expires_at,
    'pet', jsonb_build_object(
      'name', p.name, 'species', sp.name, 'breed', coalesce(b.name, p.breed_other),
      'sex', p.sex, 'birth', p.birth, 'neutered', p.neutered,
      'microchip', p.microchip, 'photo_path', p.photo_path),
    'health', coalesce((
      select jsonb_agg(jsonb_build_object('kind', h.kind, 'name', h.name, 'date', h.date,
                                          'next_date', h.next_date, 'notes', h.notes)
                       order by h.kind, h.date desc nulls last)
      from public.health_records h where h.pet_id = p.id), '[]'::jsonb),
    'life', coalesce((
      select jsonb_agg(jsonb_build_object('kind', e.kind, 'title', e.title, 'date', e.date,
                                          'notes', e.notes, 'files', cardinality(e.files),
                                          'paths', to_jsonb(e.files))
                       order by e.date desc)
      from public.life_events e where e.pet_id = p.id), '[]'::jsonb))
  into resultado
  from public.pets p
  join public.species sp on sp.id = p.species_id
  left join public.breeds b on b.id = p.breed_id
  where p.id = s.pet_id;
  return resultado;
end;
$$;
