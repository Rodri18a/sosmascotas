-- Etapa 2.7 (D80): eventos y denuncias de maltrato (03 §11b). Los lugares que
-- aceptan mascotas ya son un rubro del mapa (D75).
--  · Eventos (jornadas de castración, ferias de adopción, encuentros): los
--    publican comercios o refugios **verificados** (o la administración) y
--    aparecen en el mapa y en Ayuda mientras no terminaron.
--  · Denuncias de maltrato: con fotos y ubicación opcional; solo las ven
--    quien denuncia y la administración. La app no reemplaza la denuncia
--    oficial (INBA, 911 si hay una persona en riesgo).

create table public.events_calendar (
  id           uuid primary key default gen_random_uuid(),
  organizer_id uuid default auth.uid() references auth.users (id) on delete set null,
  business_id  uuid references public.businesses (id) on delete cascade,
  kind         text not null check (kind in ('castracion', 'adopcion', 'encuentro', 'otro')),
  title        text not null check (char_length(trim(title)) between 3 and 80),
  description  text check (char_length(description) <= 1000),
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  location     extensions.geography(point, 4326) not null,
  address      text check (char_length(address) <= 120),
  link         text check (link ~ '^https://' and char_length(link) <= 300),
  zone_id      smallint references public.zones (id),
  status       text not null default 'active' check (status in ('active', 'cancelled', 'hidden')),
  created_at   timestamptz not null default now(),
  check (ends_at > starts_at and ends_at <= starts_at + interval '14 days')
);

comment on table public.events_calendar is
  'Eventos del mapa (castración, adopción, encuentros). Los publican comercios verificados (D80).';

create index events_calendar_location_idx on public.events_calendar using gist (location);
create index events_calendar_fecha_idx on public.events_calendar (ends_at) where status = 'active';

alter table public.events_calendar enable row level security;
revoke all on public.events_calendar from anon, authenticated;

create function public.publicar_evento(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  negocio uuid := nullif(p ->> 'business_id', '')::uuid;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if not public.es_admin() and not exists (
    select 1 from public.businesses
    where id = negocio and owner_id = yo and verification = 'verified' and status = 'active'
  ) then
    raise exception 'Solo comercios o refugios verificados' using errcode = '42501';
  end if;
  if (select count(*) from public.events_calendar
      where organizer_id = yo and created_at > now() - interval '1 day') >= 5 then
    raise exception 'Demasiados eventos hoy' using errcode = '54000';
  end if;
  insert into public.events_calendar (organizer_id, business_id, kind, title, description, starts_at,
                                      ends_at, location, address, link, zone_id)
  values (yo, negocio, coalesce(p ->> 'kind', 'otro'), p ->> 'title', nullif(p ->> 'description', ''),
          (p ->> 'starts_at')::timestamptz, (p ->> 'ends_at')::timestamptz,
          extensions.st_setsrid(extensions.st_makepoint((p ->> 'lng')::double precision,
                                                        (p ->> 'lat')::double precision), 4326)::extensions.geography,
          nullif(p ->> 'address', ''), nullif(p ->> 'link', ''),
          (select id from public.zones where slug = 'pando'))
  returning id into id_;
  return id_;
end;
$$;

create function public.cancelar_evento(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  update public.events_calendar set status = 'cancelled'
   where id = p_id and (organizer_id = (select auth.uid()) or public.es_admin());
  if not found then raise exception 'No es tuyo' using errcode = '42501'; end if;
end;
$$;

-- Próximos eventos de la zona visible (los que no terminaron), con el
-- nombre del organizador (comercio) y si son míos.
create function public.eventos_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision
)
returns table (id uuid, kind text, title text, description text, starts_at timestamptz,
               ends_at timestamptz, lat double precision, lng double precision, address text,
               link text, organizador text, mine boolean)
language sql stable security definer set search_path = ''
as $$
  select e.id, e.kind, e.title, e.description, e.starts_at, e.ends_at,
         extensions.st_y(e.location::extensions.geometry), extensions.st_x(e.location::extensions.geometry),
         e.address, e.link, b.name, e.organizer_id = (select auth.uid())
  from public.events_calendar e
  left join public.businesses b on b.id = e.business_id
  where e.status = 'active' and e.ends_at > now()
    and e.location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by e.starts_at
  limit 100;
$$;

-- ---------------------------------------------------------------------
-- Denuncias de maltrato
-- ---------------------------------------------------------------------
create table public.abuse_reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null default auth.uid() references auth.users (id) on delete cascade,
  description  text not null check (char_length(trim(description)) between 10 and 2000),
  location     extensions.geography(point, 4326),        -- opcional y privada
  address      text check (char_length(address) <= 160),
  photos       text[] not null default '{}' check (cardinality(photos) <= 6),
  status       text not null default 'new' check (status in ('new', 'referred', 'closed')),
  admin_note   text check (char_length(admin_note) <= 1000),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create trigger abuse_reports_updated_at
  before update on public.abuse_reports
  for each row execute function public.set_updated_at();

alter table public.abuse_reports enable row level security;
revoke all on public.abuse_reports from anon, authenticated;

-- Fotos de denuncias: bucket PRIVADO; las ven quien denuncia y la administración.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('abuse-photos', 'abuse-photos', false, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public, file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_de_denuncia" on storage.objects for insert to authenticated
  with check (bucket_id = 'abuse-photos'
              and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "ver_fotos_de_denuncia" on storage.objects for select to authenticated
  using (bucket_id = 'abuse-photos'
         and ((storage.foldername(name))[1] = (select auth.uid())::text or public.es_admin()));

create function public.denunciar_maltrato(p_descripcion text, p_lat double precision default null,
                                          p_lng double precision default null, p_direccion text default null,
                                          p_fotos text[] default '{}')
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if (select count(*) from public.abuse_reports
      where reporter_id = yo and created_at > now() - interval '1 day') >= 3 then
    raise exception 'Demasiadas denuncias hoy' using errcode = '54000';
  end if;
  if exists (select 1 from unnest(coalesce(p_fotos, '{}')) f
             where f !~ ('^' || yo::text || '/[A-Za-z0-9._-]+$')) then
    raise exception 'Fotos inválidas' using errcode = '22023';
  end if;
  insert into public.abuse_reports (reporter_id, description, location, address, photos)
  values (yo, trim(p_descripcion),
          case when p_lat is not null and p_lng is not null then
            extensions.st_setsrid(extensions.st_makepoint(p_lng, p_lat), 4326)::extensions.geography end,
          nullif(trim(p_direccion), ''), coalesce(p_fotos, '{}'))
  returning id into id_;
  return id_;
end;
$$;

create function public.mis_denuncias()
returns table (id uuid, description text, status text, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select id, description, status, created_at from public.abuse_reports
  where reporter_id = (select auth.uid()) order by created_at desc;
$$;

create function public.admin_denuncias()
returns table (id uuid, reporter text, description text, lat double precision, lng double precision,
               address text, photos text[], status text, admin_note text, created_at timestamptz)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select a.id, p.display_name, a.description,
         extensions.st_y(a.location::extensions.geometry), extensions.st_x(a.location::extensions.geometry),
         a.address, a.photos, a.status, a.admin_note, a.created_at
  from public.abuse_reports a left join public.profiles p on p.id = a.reporter_id
  order by a.status = 'new' desc, a.created_at desc
  limit 200;
end;
$$;

create function public.admin_estado_denuncia(p_id uuid, p_estado text, p_nota text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_estado not in ('new', 'referred', 'closed') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  update public.abuse_reports set status = p_estado, admin_note = coalesce(p_nota, admin_note)
   where id = p_id;
  perform public.registrar_accion('denuncia_' || p_estado, 'abuse_report', p_id::text);
end;
$$;

do $$
declare
  f text;
begin
  foreach f in array array[
    'publicar_evento(jsonb)', 'cancelar_evento(uuid)',
    'denunciar_maltrato(text, double precision, double precision, text, text[])',
    'mis_denuncias()', 'admin_denuncias()', 'admin_estado_denuncia(uuid, text, text)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;

revoke all on function public.eventos_en_zona(double precision, double precision, double precision, double precision) from public;
grant execute on function public.eventos_en_zona(double precision, double precision, double precision, double precision) to anon, authenticated;
