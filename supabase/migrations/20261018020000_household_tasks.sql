-- Paso 1.6.3: tareas del hogar ("hoy pasea Juan") y registro de quién lo
-- hizo (D71). Por mascota y por día; las ve y las hace quien puede cuidar a
-- la mascota (dueño o integrante vigente de su hogar, D69).

create table public.household_tasks (
  id           uuid primary key default gen_random_uuid(),
  pet_id       uuid not null references public.pets (id) on delete cascade,
  kind         text not null check (kind in ('walk', 'food', 'bath', 'vet', 'other')),
  note         text check (char_length(trim(note)) between 1 and 80),
  day          date not null,
  assigned_to  uuid references auth.users (id) on delete set null,
  created_by   uuid default auth.uid() references auth.users (id) on delete set null,
  done_by      uuid references auth.users (id) on delete set null,
  done_at      timestamptz,
  created_at   timestamptz not null default now(),
  check ((done_by is null) = (done_at is null)),
  check (done_at is null or done_at <= now() + interval '5 minutes')
);

comment on table public.household_tasks is
  'Tareas del hogar por mascota y día, con quién la tiene asignada y quién la hizo (D71).';

create index household_tasks_pet_day_idx on public.household_tasks (pet_id, day);

-- ¿[p_user] puede cuidar a [p_pet]? (para asignar tareas solo a quien corresponde)
create function public.puede_cuidar_usuario(p_pet uuid, p_user uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.pets p
    where p.id = p_pet
      and (p.owner_id = p_user or exists (
        select 1 from public.households h
        join public.household_members m on m.household_id = h.id
        where h.owner_id = p.owner_id and m.user_id = p_user
          and (m.access_until is null or m.access_until > now())
      ))
  );
$$;

revoke all on function public.puede_cuidar_usuario(uuid, uuid) from public, anon;
grant execute on function public.puede_cuidar_usuario(uuid, uuid) to authenticated;

alter table public.household_tasks enable row level security;

create policy "ver_tareas" on public.household_tasks for select to authenticated
  using (public.puedo_cuidar(pet_id));
create policy "crear_tareas" on public.household_tasks for insert to authenticated
  with check (
    public.puedo_cuidar(pet_id)
    and created_by = (select auth.uid())
    and (assigned_to is null or public.puede_cuidar_usuario(pet_id, assigned_to))
  );
-- Al editar: reasignar (a quien puede cuidar) o marcar hecha.
create policy "editar_tareas" on public.household_tasks for update to authenticated
  using (public.puedo_cuidar(pet_id))
  with check (
    public.puedo_cuidar(pet_id)
    and (assigned_to is null or public.puede_cuidar_usuario(pet_id, assigned_to))
  );

-- "Hecho" siempre queda a nombre de quien lo marca, con la hora del servidor;
-- una marca ajena se puede deshacer pero no cambiar de nombre.
create function public.household_tasks_hecha()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if new.done_by is not null
     and (tg_op = 'INSERT' or new.done_by is distinct from old.done_by) then
    if new.done_by <> (select auth.uid()) then
      raise exception 'Solo podés marcar a tu nombre' using errcode = '42501';
    end if;
    new.done_at := now();
  end if;
  if new.done_by is null then
    new.done_at := null;
  end if;
  return new;
end;
$$;

create trigger household_tasks_hecha
  before insert or update on public.household_tasks
  for each row execute function public.household_tasks_hecha();
create policy "borrar_tareas" on public.household_tasks for delete to authenticated
  using (public.puedo_cuidar(pet_id));

revoke all on public.household_tasks from anon;
