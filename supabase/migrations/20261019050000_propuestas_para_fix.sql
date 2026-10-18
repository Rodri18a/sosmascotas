-- 2.6b: en propuestas_para(), `status` chocaba con la columna de salida del
-- mismo nombre; se califica con el alias de la tabla.
create or replace function public.propuestas_para(p_pet uuid)
returns table (proposal_id uuid, business_id uuid, negocio text, message text, status text, created_at timestamptz)
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = (select auth.uid())) then
    raise exception 'Solo el dueño' using errcode = '42501';
  end if;
  update public.vet_proposal_deliveries d set status = 'seen'
   where d.pet_id = p_pet and d.status = 'sent';
  return query
  select d.proposal_id, v.business_id, b.name, v.message, d.status, d.created_at
  from public.vet_proposal_deliveries d
  join public.vet_proposals v on v.id = d.proposal_id
  join public.businesses b on b.id = v.business_id
  where d.pet_id = p_pet
  order by d.created_at desc;
end;
$$;
