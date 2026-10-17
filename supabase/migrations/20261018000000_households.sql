-- Paso 1.6.1: hogar compartido (D69). Un hogar por dueño; hasta 5
-- integrantes además del dueño; se entra con un enlace de invitación que sirve
-- una sola vez y vence a los 7 días. Gratis en la Fase 1 (plan Familia en la
-- Fase 2). Lo que se comparte (mascotas, libreta, recordatorios, avisos) se
-- habilita en la migración siguiente (1.6.2).

create table public.households (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null unique default auth.uid() references auth.users (id) on delete cascade,
  name        text check (char_length(trim(name)) between 1 and 40),
  created_at  timestamptz not null default now()
);

comment on table public.households is 'Hogar compartido: un dueño y hasta 5 integrantes (D69).';

-- El dueño no está acá (es households.owner_id): solo los integrantes.
create table public.household_members (
  household_id  uuid not null references public.households (id) on delete cascade,
  user_id       uuid not null references auth.users (id) on delete cascade,
  role          text not null default 'member' check (role in ('member', 'temp_caregiver')),
  access_until  timestamptz,                    -- cuidador temporal (1.6.4)
  joined_at     timestamptz not null default now(),
  primary key (household_id, user_id)
);

create index household_members_user_idx on public.household_members (user_id);

create table public.household_invites (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references public.households (id) on delete cascade,
  code          text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{10}$'),
  role          text not null default 'member' check (role in ('member', 'temp_caregiver')),
  access_days   smallint check (access_days between 1 and 90),   -- cuidador temporal
  expires_at    timestamptz not null default now() + interval '7 days',
  created_at    timestamptz not null default now(),
  used_by       uuid references auth.users (id) on delete set null,
  used_at       timestamptz,
  check ((role = 'temp_caregiver') = (access_days is not null))
);

create index household_invites_household_idx on public.household_invites (household_id, created_at desc);

-- ---------------------------------------------------------------------
-- Funciones de permiso (security definer: leen sin pasar por la RLS y así
-- las políticas no se llaman entre sí en círculo).
-- ---------------------------------------------------------------------

-- ¿El usuario actual integra (vigente) el hogar de [p_owner]?
create function public.integra_hogar_de(p_owner uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1
    from public.households h
    join public.household_members m on m.household_id = h.id
    where h.owner_id = p_owner
      and m.user_id = (select auth.uid())
      and m.role = 'member'
      and (m.access_until is null or m.access_until > now())
  );
$$;

-- ¿El usuario actual es dueño o integrante de [p_household]?
create function public.es_de_mi_hogar(p_household uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.households h
    where h.id = p_household and h.owner_id = (select auth.uid())
  ) or exists (
    select 1 from public.household_members m
    where m.household_id = p_household and m.user_id = (select auth.uid())
      and (m.access_until is null or m.access_until > now())
  );
$$;

revoke all on function public.integra_hogar_de(uuid) from public, anon;
revoke all on function public.es_de_mi_hogar(uuid) from public, anon;
grant execute on function public.integra_hogar_de(uuid) to authenticated;
grant execute on function public.es_de_mi_hogar(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.household_invites enable row level security;

create policy "ver_mi_hogar" on public.households for select to authenticated
  using (public.es_de_mi_hogar(id));
create policy "crear_mi_hogar" on public.households for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy "renombrar_mi_hogar" on public.households for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "disolver_mi_hogar" on public.households for delete to authenticated
  using (owner_id = (select auth.uid()));

-- Se ven los integrantes de los hogares de los que soy parte. Se entra solo
-- con unirme_al_hogar(); el dueño saca a cualquiera y cada uno se puede ir.
create policy "ver_integrantes" on public.household_members for select to authenticated
  using (public.es_de_mi_hogar(household_id));
create policy "sacar_o_irme" on public.household_members for delete to authenticated
  using (user_id = (select auth.uid())
         or exists (select 1 from public.households h
                    where h.id = household_id and h.owner_id = (select auth.uid())));

-- Las invitaciones solo las maneja el dueño del hogar.
create policy "ver_mis_invitaciones" on public.household_invites for select to authenticated
  using (exists (select 1 from public.households h
                 where h.id = household_id and h.owner_id = (select auth.uid())));
create policy "borrar_mis_invitaciones" on public.household_invites for delete to authenticated
  using (exists (select 1 from public.households h
                 where h.id = household_id and h.owner_id = (select auth.uid())));

revoke all on public.households, public.household_members, public.household_invites from anon;
revoke insert, update on public.household_members from authenticated;
revoke insert, update on public.household_invites from authenticated;

-- ---------------------------------------------------------------------
-- Invitar y unirse
-- ---------------------------------------------------------------------

-- Crea (si hace falta) mi hogar y una invitación nueva. Devuelve el código.
create function public.invitar_al_hogar(p_rol text default 'member', p_dias smallint default null)
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
  insert into public.households (owner_id) values (yo)
    on conflict (owner_id) do nothing;
  select id into hogar from public.households where owner_id = yo;
  -- Tope de invitaciones abiertas, para que no se use para spam.
  if (select count(*) from public.household_invites
      where household_id = hogar and used_at is null and expires_at > now()) >= 10 then
    raise exception 'Demasiadas invitaciones abiertas' using errcode = '54000';
  end if;
  loop
    codigo := (select string_agg(substr(letras, 1 + floor(random() * length(letras))::int, 1), '')
               from generate_series(1, 10));
    begin
      insert into public.household_invites (household_id, code, role, access_days)
      values (hogar, codigo, p_rol, case when p_rol = 'temp_caregiver' then coalesce(p_dias, 7) end);
      exit;
    exception when unique_violation then
      -- otro código
    end;
  end loop;
  return codigo;
end;
$$;

-- Uso de un código de invitación. Devuelve el id del hogar.
create function public.unirme_al_hogar(p_codigo text)
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
  update public.household_invites set used_by = yo, used_at = now() where id = inv.id;
  return inv.household_id;
end;
$$;

-- Integrantes de los hogares de los que soy parte, con su nombre visible (los
-- perfiles no se leen entre usuarios: solo el nombre, nunca el correo).
create function public.integrantes_de_mis_hogares()
returns table (household_id uuid, user_id uuid, display_name text, role text,
               access_until timestamptz, es_dueno boolean)
language sql stable security definer set search_path = ''
as $$
  with mios as (
    select h.id, h.owner_id from public.households h
    where public.es_de_mi_hogar(h.id)
  )
  select m.id, m.owner_id, p.display_name, 'owner', null::timestamptz, true
  from mios m left join public.profiles p on p.id = m.owner_id
  union all
  select hm.household_id, hm.user_id, p.display_name, hm.role, hm.access_until, false
  from public.household_members hm
  join mios m on m.id = hm.household_id
  left join public.profiles p on p.id = hm.user_id
  where hm.access_until is null or hm.access_until > now();
$$;

revoke all on function public.invitar_al_hogar(text, smallint) from public, anon;
revoke all on function public.unirme_al_hogar(text) from public, anon;
revoke all on function public.integrantes_de_mis_hogares() from public, anon;
grant execute on function public.invitar_al_hogar(text, smallint) to authenticated;
grant execute on function public.unirme_al_hogar(text) to authenticated;
grant execute on function public.integrantes_de_mis_hogares() to authenticated;
