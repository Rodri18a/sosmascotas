-- 2.6b: una mascota que dejó de compartirse con la veterinaria vuelve a
-- poder recibir sus propuestas (solo se excluyen los socios actuales).
create or replace function public.enviar_propuesta_veterinaria(p_business uuid, p_mensaje text,
                                                     p_especie smallint default null,
                                                     p_radio_km smallint default 2)
returns integer
language plpgsql security definer set search_path = ''
as $$
declare
  punto extensions.geography;
  id_ uuid;
  n integer;
begin
  if not public.soy_duenio_de(p_business) or not public.modulo_activo(p_business, 'socios') then
    raise exception 'Solo con el plan Plus y el módulo Socios activo' using errcode = '42501';
  end if;
  if (select count(*) from public.vet_proposals
      where business_id = p_business and created_at > now() - interval '7 days') >= 2 then
    raise exception 'Como máximo 2 propuestas por semana' using errcode = '54000';
  end if;
  select location into punto from public.businesses where id = p_business;
  insert into public.vet_proposals (business_id, message, species_id, radius_km)
  values (p_business, trim(p_mensaje), p_especie, least(greatest(p_radio_km, 1), 10))
  returning id into id_;
  insert into public.vet_proposal_deliveries (proposal_id, pet_id)
  select id_, p.id
  from public.vet_search_consents c
  join public.pets p on p.id = c.pet_id
  join public.profiles pr on pr.id = c.owner_id
  where c.revoked_at is null and pr.approx_location is not null
    and (p_especie is null or p.species_id = p_especie)
    and extensions.st_dwithin(pr.approx_location, punto, least(greatest(p_radio_km, 1), 10) * 1000)
    and not exists (select 1 from public.pet_vet_shares s where s.pet_id = p.id and s.business_id = p_business
                    and s.revoked_at is null)
    and (select count(*) from public.vet_proposal_deliveries d
         where d.pet_id = p.id and d.created_at > date_trunc('month', now())) < 3;
  get diagnostics n = row_count;
  return n;
end;
$$;
