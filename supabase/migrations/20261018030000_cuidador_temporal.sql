-- Paso 1.6.4: cuidador temporal (D72). Acceso por X días (1 a 90) y solo a
-- las mascotas que elige el dueño al invitar (vacaciones, guardería). Puede lo
-- mismo que un integrante con esas mascotas (ficha, libreta, recordatorios,
-- tareas, avisos del QR y sus push) y nada con las demás. Al vencer, deja de
-- ver todo sin que nadie haga nada.

-- Qué mascotas cuida cada cuidador temporal.
create table public.household_member_pets (
  household_id  uuid not null,
  user_id       uuid not null,
  pet_id        uuid not null references public.pets (id) on delete cascade,
  primary key (household_id, user_id, pet_id),
  foreign key (household_id, user_id)
    references public.household_members (household_id, user_id) on delete cascade
);

create index household_member_pets_pet_idx on public.household_member_pets (pet_id);

alter table public.household_member_pets enable row level security;

-- Las ve quien es del hogar (para mostrar "cuida a Luna"); se cargan solo
-- con unirme_al_hogar(); se borran junto con el integrante.
create policy "ver_mascotas_del_cuidador" on public.household_member_pets
  for select to authenticated
  using (public.es_de_mi_hogar(household_id));

revoke all on public.household_member_pets from anon;
revoke insert, update, delete on public.household_member_pets from authenticated;

alter table public.household_invites add column pet_ids uuid[];
alter table public.household_invites add constraint invites_cuidador_con_mascotas
  check ((role = 'temp_caregiver') = (pet_ids is not null and cardinality(pet_ids) between 1 and 20));

-- ¿Puedo cuidar esta mascota? Ahora también como cuidador temporal vigente.
create or replace function public.puedo_cuidar(p_pet uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.pets p
    where p.id = p_pet
      and (p.owner_id = (select auth.uid())
           or public.integra_hogar_de(p.owner_id)
           or exists (
             select 1 from public.household_member_pets mp
             join public.household_members m
               on m.household_id = mp.household_id and m.user_id = mp.user_id
             where mp.pet_id = p.id and mp.user_id = (select auth.uid())
               and m.role = 'temp_caregiver' and m.access_until > now()
           ))
  );
$$;

create or replace function public.puede_cuidar_usuario(p_pet uuid, p_user uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.pets p
    where p.id = p_pet
      and (p.owner_id = p_user
           or exists (
             select 1 from public.households h
             join public.household_members m on m.household_id = h.id
             where h.owner_id = p.owner_id and m.user_id = p_user and m.role = 'member'
               and (m.access_until is null or m.access_until > now())
           )
           or exists (
             select 1 from public.household_member_pets mp
             join public.household_members m
               on m.household_id = mp.household_id and m.user_id = mp.user_id
             where mp.pet_id = p.id and mp.user_id = p_user
               and m.role = 'temp_caregiver' and m.access_until > now()
           ))
  );
$$;

-- pets: el cuidador ve y edita solo sus mascotas (usa puedo_cuidar).
drop policy "ver_mis_mascotas" on public.pets;
drop policy "editar_mis_mascotas" on public.pets;
create policy "ver_mis_mascotas" on public.pets for select to authenticated
  using (owner_id = (select auth.uid()) or public.puedo_cuidar(id));
create policy "editar_mis_mascotas" on public.pets for update to authenticated
  using (owner_id = (select auth.uid()) or public.puedo_cuidar(id))
  with check (owner_id = (select auth.uid()) or public.puedo_cuidar(id));

-- Push: además del hogar, los cuidadores vigentes de esa mascota.
drop function public.tokens_de_cuidadores(uuid);
create function public.tokens_de_cuidadores(p_owner uuid, p_pet uuid default null)
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
       or t.user_id in (
         select mp.user_id
         from public.household_member_pets mp
         join public.household_members m
           on m.household_id = mp.household_id and m.user_id = mp.user_id
         where p_pet is not null and mp.pet_id = p_pet
           and m.role = 'temp_caregiver' and m.access_until > now()
       )
  );
$$;

revoke execute on function public.tokens_de_cuidadores(uuid, uuid) from public, anon, authenticated;
grant execute on function public.tokens_de_cuidadores(uuid, uuid) to service_role;

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
         public.tokens_de_cuidadores(escaneo.owner_id, escaneo.pet_id);
end;
$$;

-- Invitar: ahora con las mascotas del cuidador temporal.
drop function public.invitar_al_hogar(text, smallint);
create function public.invitar_al_hogar(
  p_rol text default 'member',
  p_dias smallint default null,
  p_mascotas uuid[] default null
)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  hogar uuid;
  codigo text;
  letras constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if p_rol not in ('member', 'temp_caregiver') then
    raise exception 'Rol inválido' using errcode = '22023';
  end if;
  if p_rol = 'temp_caregiver' then
    if p_mascotas is null or cardinality(p_mascotas) = 0 then
      raise exception 'Elegí qué mascotas cuida' using errcode = '22023';
    end if;
    -- Solo mascotas propias.
    if exists (select 1 from unnest(p_mascotas) as x(id)
               where not exists (select 1 from public.pets p
                                 where p.id = x.id and p.owner_id = yo)) then
      raise exception 'Solo podés compartir tus mascotas' using errcode = '42501';
    end if;
  end if;
  insert into public.households (owner_id) values (yo)
    on conflict (owner_id) do nothing;
  select id into hogar from public.households where owner_id = yo;
  if (select count(*) from public.household_invites
      where household_id = hogar and used_at is null and expires_at > now()) >= 10 then
    raise exception 'Demasiadas invitaciones abiertas' using errcode = '54000';
  end if;
  loop
    codigo := (select string_agg(substr(letras, 1 + floor(random() * length(letras))::int, 1), '')
               from generate_series(1, 10));
    begin
      insert into public.household_invites (household_id, code, role, access_days, pet_ids)
      values (hogar, codigo, p_rol,
              case when p_rol = 'temp_caregiver' then coalesce(p_dias, 7) end,
              case when p_rol = 'temp_caregiver' then p_mascotas end);
      exit;
    exception when unique_violation then
      -- otro código
    end;
  end loop;
  return codigo;
end;
$$;

revoke all on function public.invitar_al_hogar(text, smallint, uuid[]) from public, anon;
grant execute on function public.invitar_al_hogar(text, smallint, uuid[]) to authenticated;

-- Unirse: el cuidador temporal queda con sus mascotas (las que sigan siendo
-- del dueño). Un integrante que acepta ser cuidador no pierde lo que tenía.
create or replace function public.unirme_al_hogar(p_codigo text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  inv public.household_invites%rowtype;
  dueno uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select * into inv from public.household_invites
    where code = upper(trim(p_codigo)) for update;
  if not found or inv.used_at is not null or inv.expires_at <= now() then
    raise exception 'La invitación no existe, ya se usó o venció' using errcode = 'P0002';
  end if;
  select owner_id into dueno from public.households where id = inv.household_id;
  if dueno = yo then
    raise exception 'Es tu propio hogar' using errcode = '22023';
  end if;
  if exists (select 1 from public.household_members
             where household_id = inv.household_id and user_id = yo) then
    raise exception 'Ya sos parte de este hogar' using errcode = '23505';
  end if;
  if (select count(*) from public.household_members where household_id = inv.household_id) >= 5 then
    raise exception 'El hogar ya tiene 5 integrantes' using errcode = '54000';
  end if;
  insert into public.household_members (household_id, user_id, role, access_until)
  values (inv.household_id, yo, inv.role,
          case when inv.access_days is not null then now() + make_interval(days => inv.access_days) end);
  if inv.role = 'temp_caregiver' then
    insert into public.household_member_pets (household_id, user_id, pet_id)
    select inv.household_id, yo, p.id
    from public.pets p
    where p.id = any (inv.pet_ids) and p.owner_id = dueno;
  end if;
  update public.household_invites set used_by = yo, used_at = now() where id = inv.id;
  return inv.household_id;
end;
$$;
