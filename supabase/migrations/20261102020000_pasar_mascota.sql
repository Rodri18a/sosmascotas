-- Plan de mejoras 2.2a (D132): pasar una mascota a otra persona con todo su
-- historial (libreta, historial de vida, recordatorios y chapita QR).
-- El dueño genera un código de 10 letras que vence a los 7 días; quien lo
-- recibe lo escribe en la app y acepta. Se usa una sola vez. No se puede
-- pasar una mascota con un SOS abierto. Todo pasa por funciones: la tabla no
-- se escribe directo.

create table public.pet_transfers (
  id            uuid primary key default gen_random_uuid(),
  pet_id        uuid not null references public.pets (id) on delete cascade,
  from_user     uuid not null references auth.users (id) on delete cascade,
  code          text not null unique check (code ~ '^[A-HJ-NP-Z2-9]{10}$'),
  expires_at    timestamptz not null default now() + interval '7 days',
  accepted_by   uuid references auth.users (id) on delete set null,
  accepted_at   timestamptz,
  cancelled_at  timestamptz,
  created_at    timestamptz not null default now()
);

comment on table public.pet_transfers is
  'Códigos para pasar una mascota a otra persona (D132). Solo por funciones.';

create index pet_transfers_pet_idx on public.pet_transfers (pet_id);

alter table public.pet_transfers enable row level security;

-- Quien la pasa ve sus códigos (para mostrar el abierto y poder cancelarlo).
create policy "ver_mis_transferencias" on public.pet_transfers for select to authenticated
  using (from_user = (select auth.uid()));

revoke all on public.pet_transfers from anon;
revoke insert, update, delete on public.pet_transfers from authenticated;

-- El dueño de una mascota no cambia, salvo dentro de aceptar_transferencia().
create or replace function public.pets_dueno_fijo()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if new.owner_id is distinct from old.owner_id
     and coalesce(current_setting('app.transferir_mascota', true), '') <> old.id::text then
    raise exception 'La mascota no cambia de dueño' using errcode = '42501';
  end if;
  return new;
end;
$$;

create function public.tiene_sos_abierto(p_pet uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.sos_reports
                 where pet_id = p_pet and status in ('active', 'hidden'));
$$;

revoke all on function public.tiene_sos_abierto(uuid) from public, anon, authenticated;

-- Crea (o renueva) el código para pasar [p_pet]. Solo su dueño.
create function public.crear_transferencia(p_pet uuid)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  codigo text;
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = yo) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  if public.tiene_sos_abierto(p_pet) then
    raise exception 'Tiene un SOS abierto' using errcode = '22023';
  end if;
  -- Un solo código abierto por mascota: el anterior queda cancelado.
  update public.pet_transfers set cancelled_at = now()
   where pet_id = p_pet and accepted_at is null and cancelled_at is null;
  loop
    -- 10 letras y números sin los que se confunden (0/O, 1/I), al azar fuerte.
    codigo := (select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
                                        1 + (get_byte(b, i) % 32), 1), '')
               from (select extensions.gen_random_bytes(10) as b) x,
                    generate_series(0, 9) as i);
    begin
      insert into public.pet_transfers (pet_id, from_user, code) values (p_pet, yo, codigo);
      return codigo;
    exception when unique_violation then
      -- Se prueba otro.
    end;
  end loop;
end;
$$;

-- Lo que ve quien recibe el código antes de aceptar: nombre, especie y foto.
-- Nunca datos del dueño.
create function public.ver_transferencia(p_code text)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object('pet_id', p.id, 'name', p.name, 'species_id', p.species_id,
                            'photo_path', p.photo_path, 'expires_at', t.expires_at)
  from public.pet_transfers t
  join public.pets p on p.id = t.pet_id
  where t.code = upper(trim(p_code))
    and t.accepted_at is null and t.cancelled_at is null and t.expires_at > now()
    and t.from_user <> (select auth.uid());
$$;

-- Acepta: la mascota pasa a mi cuenta con todo (libreta, historial de vida,
-- recordatorios, chapita QR). Devuelve el id de la mascota.
create function public.aceptar_transferencia(p_code text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  t public.pet_transfers;
begin
  select * into t from public.pet_transfers
   where code = upper(trim(p_code)) for update;
  if not found or t.accepted_at is not null or t.cancelled_at is not null
     or t.expires_at <= now() then
    raise exception 'El código no es válido o venció' using errcode = '22023';
  end if;
  if t.from_user = yo then
    raise exception 'Ya es tu mascota' using errcode = '22023';
  end if;
  if not exists (select 1 from public.pets where id = t.pet_id and owner_id = t.from_user) then
    raise exception 'La mascota ya no es de quien la pasa' using errcode = '22023';
  end if;
  if public.tiene_sos_abierto(t.pet_id) then
    raise exception 'Tiene un SOS abierto' using errcode = '22023';
  end if;
  perform set_config('app.transferir_mascota', t.pet_id::text, true);
  update public.pets set owner_id = yo where id = t.pet_id;
  perform set_config('app.transferir_mascota', '', true);
  update public.qr_tags set owner_id = yo where pet_id = t.pet_id;
  update public.pet_transfers set accepted_by = yo, accepted_at = now() where id = t.id;
  return t.pet_id;
end;
$$;

-- El dueño cancela el código abierto de [p_pet].
create function public.cancelar_transferencia(p_pet uuid)
returns void
language sql security definer set search_path = ''
as $$
  update public.pet_transfers set cancelled_at = now()
   where pet_id = p_pet and from_user = (select auth.uid())
     and accepted_at is null and cancelled_at is null;
$$;

revoke all on function public.crear_transferencia(uuid) from public, anon;
revoke all on function public.ver_transferencia(text) from public, anon;
revoke all on function public.aceptar_transferencia(text) from public, anon;
revoke all on function public.cancelar_transferencia(uuid) from public, anon;
grant execute on function public.crear_transferencia(uuid) to authenticated;
grant execute on function public.ver_transferencia(text) to authenticated;
grant execute on function public.aceptar_transferencia(text) to authenticated;
grant execute on function public.cancelar_transferencia(uuid) to authenticated;

-- Funcionalidad gradual (D64): prendida para todos (es gratis).
insert into public.feature_flags (key, description, stage)
values ('pasar_mascota', 'Pasar una mascota a otra persona con su historial (plan de mejoras 2.2, D132)', 'todos')
on conflict (key) do nothing;
