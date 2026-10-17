-- Paso 1.6.2: lo que comparte el hogar (D69). Los integrantes vigentes del
-- hogar del dueño ven y editan sus mascotas, la libreta y los recordatorios,
-- marcan "ya se la di", ven el QR, los escaneos y los avisos (contacto
-- inverso) y reciben sus push. Solo el dueño borra la mascota, cambia el QR
-- y reporta un SOS (eso ya pasaba por owner_id y no cambia).

-- ¿Puedo cuidar esta mascota? (dueño o integrante vigente de su hogar).
-- El cuidador temporal (1.6.4) se suma en su migración.
create function public.puedo_cuidar(p_pet uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.pets p
    where p.id = p_pet
      and (p.owner_id = (select auth.uid()) or public.integra_hogar_de(p.owner_id))
  );
$$;

revoke all on function public.puedo_cuidar(uuid) from public, anon;
grant execute on function public.puedo_cuidar(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- pets: ver y editar (no crear a nombre de otro, no borrar, no cambiar de dueño)
-- ---------------------------------------------------------------------
drop policy "ver_mis_mascotas" on public.pets;
drop policy "editar_mis_mascotas" on public.pets;
create policy "ver_mis_mascotas" on public.pets for select to authenticated
  using (owner_id = (select auth.uid()) or public.integra_hogar_de(owner_id));
create policy "editar_mis_mascotas" on public.pets for update to authenticated
  using (owner_id = (select auth.uid()) or public.integra_hogar_de(owner_id))
  with check (owner_id = (select auth.uid()) or public.integra_hogar_de(owner_id));

create function public.pets_dueno_fijo()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if new.owner_id is distinct from old.owner_id then
    raise exception 'La mascota no cambia de dueño' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger pets_dueno_fijo
  before update on public.pets
  for each row execute function public.pets_dueno_fijo();

-- ---------------------------------------------------------------------
-- health_records y reminders: todo para quien puede cuidar
-- ---------------------------------------------------------------------
drop policy "ver_mi_libreta" on public.health_records;
drop policy "cargar_en_mi_libreta" on public.health_records;
drop policy "editar_mi_libreta" on public.health_records;
drop policy "borrar_de_mi_libreta" on public.health_records;
create policy "ver_mi_libreta" on public.health_records for select to authenticated
  using (public.puedo_cuidar(pet_id));
create policy "cargar_en_mi_libreta" on public.health_records for insert to authenticated
  with check (public.puedo_cuidar(pet_id));
create policy "editar_mi_libreta" on public.health_records for update to authenticated
  using (public.puedo_cuidar(pet_id)) with check (public.puedo_cuidar(pet_id));
create policy "borrar_de_mi_libreta" on public.health_records for delete to authenticated
  using (public.puedo_cuidar(pet_id));

drop policy "ver_mis_recordatorios" on public.reminders;
drop policy "crear_mis_recordatorios" on public.reminders;
drop policy "editar_mis_recordatorios" on public.reminders;
drop policy "borrar_mis_recordatorios" on public.reminders;
create policy "ver_mis_recordatorios" on public.reminders for select to authenticated
  using (public.puedo_cuidar(pet_id));
create policy "crear_mis_recordatorios" on public.reminders for insert to authenticated
  with check (public.puedo_cuidar(pet_id));
create policy "editar_mis_recordatorios" on public.reminders for update to authenticated
  using (public.puedo_cuidar(pet_id)) with check (public.puedo_cuidar(pet_id));
create policy "borrar_mis_recordatorios" on public.reminders for delete to authenticated
  using (public.puedo_cuidar(pet_id));

-- ---------------------------------------------------------------------
-- reminder_logs: "ya se la di" lo ve todo el hogar (evita la dosis doble)
-- ---------------------------------------------------------------------
create function public.puedo_cuidar_recordatorio(p_reminder uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.reminders r
    where r.id = p_reminder and public.puedo_cuidar(r.pet_id)
  );
$$;

revoke all on function public.puedo_cuidar_recordatorio(uuid) from public, anon;
grant execute on function public.puedo_cuidar_recordatorio(uuid) to authenticated;

drop policy "ver_mis_tomas" on public.reminder_logs;
drop policy "marcar_mis_tomas" on public.reminder_logs;
drop policy "desmarcar_mis_tomas" on public.reminder_logs;
create policy "ver_mis_tomas" on public.reminder_logs for select to authenticated
  using (public.puedo_cuidar_recordatorio(reminder_id));
create policy "marcar_mis_tomas" on public.reminder_logs for insert to authenticated
  with check (done_by = (select auth.uid()) and public.puedo_cuidar_recordatorio(reminder_id));
create policy "desmarcar_mis_tomas" on public.reminder_logs for delete to authenticated
  using (public.puedo_cuidar_recordatorio(reminder_id));

-- ---------------------------------------------------------------------
-- QR, escaneos y avisos: ver (cambiar el QR sigue siendo del dueño)
-- ---------------------------------------------------------------------
create policy "ver_qr_del_hogar" on public.qr_tags for select to authenticated
  using (pet_id is not null and public.puedo_cuidar(pet_id));
create policy "ver_escaneos_del_hogar" on public.qr_scans for select to authenticated
  using (pet_id is not null and public.puedo_cuidar(pet_id));
create policy "ver_avisos_del_hogar" on public.owner_alerts for select to authenticated
  using (pet_id is not null and public.puedo_cuidar(pet_id));
create policy "responder_avisos_del_hogar" on public.owner_alerts for update to authenticated
  using (pet_id is not null and public.puedo_cuidar(pet_id))
  with check (pet_id is not null and public.puedo_cuidar(pet_id));

-- ---------------------------------------------------------------------
-- Push: al dueño y a los integrantes vigentes de su hogar
-- ---------------------------------------------------------------------
create function public.tokens_de_cuidadores(p_owner uuid)
returns text[]
language sql stable security definer set search_path = ''
as $$
  select array(
    select t.token from public.push_tokens t
    where t.user_id = p_owner
       or t.user_id in (
         select m.user_id
         from public.households h
         join public.household_members m on m.household_id = h.id
         where h.owner_id = p_owner and m.role = 'member'
           and (m.access_until is null or m.access_until > now())
       )
  );
$$;

revoke execute on function public.tokens_de_cuidadores(uuid) from public, anon, authenticated;
grant execute on function public.tokens_de_cuidadores(uuid) to service_role;

create or replace function public.aviso_escaneo(p_scan uuid)
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
         public.tokens_de_cuidadores(escaneo.owner_id);
end;
$$;
