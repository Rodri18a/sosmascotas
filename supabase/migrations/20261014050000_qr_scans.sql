-- Paso 0.4.5: escaneos del QR. Cada vez que alguien abre la página del QR se
-- registra un escaneo; quien escanea puede compartir su ubicación con la familia.
-- El dueño ve sus escaneos; nadie más.

create table public.qr_scans (
  id              uuid primary key default gen_random_uuid(),
  qr_id           uuid not null references public.qr_tags (id) on delete cascade,
  owner_id        uuid not null references auth.users (id) on delete cascade,
  pet_id          uuid references public.pets (id) on delete set null,
  shared_location extensions.geography(point, 4326),   -- solo si quien escanea la compartió
  shared_at       timestamptz,
  created_at      timestamptz not null default now()
);

comment on table public.qr_scans is 'Escaneos de los QR. Solo los ve el dueño.';

create index qr_scans_owner_idx on public.qr_scans (owner_id, created_at desc);
create index qr_scans_qr_idx on public.qr_scans (qr_id, created_at);

alter table public.qr_scans enable row level security;

create policy "ver_mis_escaneos" on public.qr_scans for select to authenticated
  using (owner_id = (select auth.uid()));
create policy "borrar_mis_escaneos" on public.qr_scans for delete to authenticated
  using (owner_id = (select auth.uid()));

revoke all on public.qr_scans from anon;
revoke insert, update, truncate on public.qr_scans from authenticated;

create view public.qr_scans_app
with (security_invoker = true) as
select s.id, s.qr_id, s.pet_id, s.created_at, s.shared_at,
       extensions.st_y(s.shared_location::extensions.geometry) as lat,
       extensions.st_x(s.shared_location::extensions.geometry) as lng
from public.qr_scans s;

grant select on public.qr_scans_app to authenticated;
revoke all on public.qr_scans_app from anon;

-- Registra un escaneo y devuelve su id (para compartir la ubicación después).
-- Tope: 60 escaneos por hora por QR (evita que alguien infle la cuenta a propósito).
create function public.registrar_escaneo(p_code text)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  tag public.qr_tags;
  nuevo uuid;
begin
  select * into tag from public.qr_tags
  where code = upper(trim(p_code)) and active and pet_id is not null;
  if not found then
    return null;
  end if;
  if (select count(*) from public.qr_scans
      where qr_id = tag.id and created_at > now() - interval '1 hour') >= 60 then
    return null;
  end if;

  insert into public.qr_scans (qr_id, owner_id, pet_id)
  values (tag.id, tag.owner_id, tag.pet_id)
  returning id into nuevo;

  insert into public.events (name, anon_id, target_id)
  values ('qr_scan', gen_random_uuid(), tag.id::text);
  return nuevo;
end;
$$;

revoke execute on function public.registrar_escaneo(text) from public;
grant execute on function public.registrar_escaneo(text) to anon, authenticated;

-- Quien escaneó comparte su ubicación (una sola vez y dentro de los 30 minutos).
create function public.compartir_ubicacion_escaneo(p_scan_id uuid, p_lat double precision, p_lng double precision)
returns boolean
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if p_lat is null or p_lng is null or abs(p_lat) > 90 or abs(p_lng) > 180 then
    return false;
  end if;
  update public.qr_scans
  set shared_location = extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography,
      shared_at = now()
  where id = p_scan_id
    and shared_location is null
    and created_at > now() - interval '30 minutes';
  return found;
end;
$$;

revoke execute on function public.compartir_ubicacion_escaneo(uuid, double precision, double precision) from public;
grant execute on function public.compartir_ubicacion_escaneo(uuid, double precision, double precision) to anon, authenticated;
