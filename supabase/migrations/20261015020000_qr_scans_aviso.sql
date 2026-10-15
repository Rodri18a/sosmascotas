-- Paso 0.6.4: push al dueño cuando escanean el QR de su mascota.
-- La página pública llama a la Edge Function `qr-scan-alert` con el id del
-- escaneo que acaba de registrar; la función usa aviso_escaneo() para saber a
-- quién avisar. Como cualquiera puede escanear, como mucho una push por QR
-- cada 10 minutos (D58).

alter table public.qr_scans add column notified_at timestamptz;

create index qr_scans_notified_idx on public.qr_scans (qr_id, notified_at desc)
  where notified_at is not null;

-- Marca el escaneo como avisado y devuelve el dueño, el nombre de la mascota y
-- sus dispositivos. No devuelve nada si el escaneo no existe, tiene más de 5
-- minutos, ya avisó o ese QR ya avisó en los últimos 10 minutos.
create function public.aviso_escaneo(p_scan uuid)
returns table (owner_id uuid, pet_id uuid, pet_name text, tokens text[])
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  escaneo record;
begin
  update public.qr_scans s
     set notified_at = now()
   where s.id = p_scan
     and s.notified_at is null
     and s.created_at > now() - interval '5 minutes'
     and not exists (
       select 1 from public.qr_scans o
        where o.qr_id = s.qr_id
          and o.notified_at > now() - interval '10 minutes'
     )
  returning s.owner_id, s.pet_id into escaneo;
  if escaneo.owner_id is null then
    return;
  end if;

  return query
  select escaneo.owner_id,
         escaneo.pet_id,
         (select p.name from public.pets p where p.id = escaneo.pet_id),
         array(select t.token from public.push_tokens t where t.user_id = escaneo.owner_id);
end;
$$;

revoke execute on function public.aviso_escaneo(uuid) from public, anon, authenticated;
grant execute on function public.aviso_escaneo(uuid) to service_role;
