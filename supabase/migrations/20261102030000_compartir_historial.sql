-- Plan de mejoras 2.2b (D133): compartir el historial de solo lectura con la
-- veterinaria o un cuidador, con un enlace que vence (1, 7 o 30 días) y que
-- el dueño puede cortar cuando quiera. La página de la web pública (h.html)
-- lee solo con historial_compartido(token): datos de la mascota, libreta e
-- historial de vida. Nunca el teléfono, el correo ni la dirección del dueño.
-- Los adjuntos no salen por acá (solo cuántos hay): firmarlos necesita una
-- Edge Function (pendiente).

create table public.pet_shares (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references public.pets (id) on delete cascade,
  created_by  uuid not null default auth.uid() references auth.users (id) on delete cascade,
  -- 128 bits al azar en base64url: imposible de adivinar.
  token       text not null unique check (token ~ '^[A-Za-z0-9_-]{22}$'),
  expires_at  timestamptz not null,
  revoked_at  timestamptz,
  views       integer not null default 0,
  created_at  timestamptz not null default now(),
  check (expires_at > created_at and expires_at <= created_at + interval '31 days')
);

comment on table public.pet_shares is
  'Enlaces de solo lectura al historial (D133). Se crean y cortan por funciones.';

create index pet_shares_pet_idx on public.pet_shares (pet_id);

alter table public.pet_shares enable row level security;

-- El dueño ve los enlaces de sus mascotas (para listarlos y cortarlos).
create policy "ver_mis_enlaces" on public.pet_shares for select to authenticated
  using (exists (select 1 from public.pets p
                 where p.id = pet_id and p.owner_id = (select auth.uid())));

revoke all on public.pet_shares from anon;
revoke insert, update, delete on public.pet_shares from authenticated;

-- Crea un enlace para [p_pet] que vence en [p_dias] (1, 7 o 30). Solo el
-- dueño; hasta 10 enlaces vigentes por mascota.
create function public.crear_enlace_historial(p_pet uuid, p_dias integer)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  token text;
begin
  if not exists (select 1 from public.pets where id = p_pet and owner_id = yo) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  if p_dias not in (1, 7, 30) then
    raise exception 'Duración no válida' using errcode = '22023';
  end if;
  if (select count(*) from public.pet_shares
      where pet_id = p_pet and revoked_at is null and expires_at > now()) >= 10 then
    raise exception 'Demasiados enlaces vigentes' using errcode = '22023';
  end if;
  token := translate(rtrim(encode(extensions.gen_random_bytes(16), 'base64'), '='), '+/', '-_');
  insert into public.pet_shares (pet_id, created_by, token, expires_at)
  values (p_pet, yo, token, now() + make_interval(days => p_dias));
  return token;
end;
$$;

-- El dueño corta un enlace.
create function public.cortar_enlace_historial(p_id uuid)
returns void
language sql security definer set search_path = ''
as $$
  update public.pet_shares s set revoked_at = now()
   where s.id = p_id and s.revoked_at is null
     and exists (select 1 from public.pets p
                 where p.id = s.pet_id and p.owner_id = (select auth.uid()));
$$;

-- Lo que ve la veterinaria con el enlace. `null` si no existe, venció o se cortó.
create function public.historial_compartido(p_token text)
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
                                          'notes', e.notes, 'files', cardinality(e.files))
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

revoke all on function public.crear_enlace_historial(uuid, integer) from public, anon;
revoke all on function public.cortar_enlace_historial(uuid) from public, anon;
revoke all on function public.historial_compartido(text) from public;
grant execute on function public.crear_enlace_historial(uuid, integer) to authenticated;
grant execute on function public.cortar_enlace_historial(uuid) to authenticated;
grant execute on function public.historial_compartido(text) to anon, authenticated;

-- Funcionalidad gradual (D64): prendida para todos (es gratis).
insert into public.feature_flags (key, description, stage)
values ('compartir_historial', 'Compartir el historial con un enlace que vence (plan de mejoras 2.2, D133)', 'todos')
on conflict (key) do nothing;
