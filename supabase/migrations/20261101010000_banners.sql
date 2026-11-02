-- 0.8.3e (D128): carrusel de banners arriba del Inicio.
--  · Los carga la administración desde el portal (no hay escritura directa).
--  · Cada uno tiene imagen, un título (también es el texto alternativo), a
--    dónde lleva (un enlace https o una noticia), fechas de inicio y fin y
--    un orden. Los de un comercio o una marca dicen "Promocionado".
--  · Más adelante entran acá las promos pagas de los comercios (etapa 3).

create table public.banners (
  id            uuid primary key default gen_random_uuid(),
  title         text not null check (char_length(trim(title)) between 3 and 80),
  image_path    text not null check (image_path ~ '^[a-z0-9-]+\.(png|jpg|webp)$'),
  link          text check (link ~ '^https://' and char_length(link) <= 300),
  news_id       uuid references public.news (id) on delete set null,
  sponsored     boolean not null default false,
  sponsor_name  text check (char_length(sponsor_name) <= 80),
  zone_id       smallint references public.zones (id),
  sort_order    smallint not null default 0,
  status        text not null default 'draft' check (status in ('draft', 'published', 'hidden')),
  starts_at     timestamptz not null default now(),
  ends_at       timestamptz,
  created_by    uuid default auth.uid() references auth.users (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (not sponsored or sponsor_name is not null),
  check (ends_at is null or ends_at > starts_at),
  check (link is null or news_id is null)
);

comment on table public.banners is
  'Banners del carrusel de Inicio (D128). Los carga la administración; los patrocinados dicen "Promocionado".';

create index banners_publicados_idx on public.banners (sort_order, starts_at desc) where status = 'published';

create trigger banners_updated_at
  before update on public.banners
  for each row execute function public.set_updated_at();

alter table public.banners enable row level security;
-- Sin políticas: solo las funciones de abajo.
revoke all on public.banners from anon, authenticated;

-- Imágenes: públicas (la app las muestra a cualquiera), solo las sube la administración.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('banners', 'banners', true, 1048576, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "admin_sube_banners" on storage.objects for insert to authenticated
  with check (bucket_id = 'banners' and public.es_admin());
create policy "admin_cambia_banners" on storage.objects for update to authenticated
  using (bucket_id = 'banners' and public.es_admin());
create policy "admin_borra_banners" on storage.objects for delete to authenticated
  using (bucket_id = 'banners' and public.es_admin());

-- Los que están en fecha (visitantes incluidos), en su orden. Una noticia
-- enlazada solo cuenta si sigue publicada.
create function public.banners()
returns table (id uuid, title text, image_path text, link text, news_id uuid,
               sponsored boolean, sponsor_name text)
language sql stable security definer set search_path = ''
as $$
  select b.id, b.title, b.image_path, b.link,
         (select n.id from public.news n where n.id = b.news_id and n.status = 'published'),
         b.sponsored, b.sponsor_name
  from public.banners b
  where b.status = 'published' and b.starts_at <= now()
    and (b.ends_at is null or b.ends_at > now())
  order by b.sort_order, b.starts_at desc
  limit 10;
$$;

create function public.admin_banners()
returns setof public.banners
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query select * from public.banners order by status = 'published' desc, sort_order, created_at desc limit 200;
end;
$$;

create function public.admin_guardar_banner(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
begin
  perform public.exigir_admin();
  if coalesce(p ->> 'status', 'draft') not in ('draft', 'published', 'hidden') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  if id_ is null then
    insert into public.banners (title, image_path, link, news_id, sponsored, sponsor_name, zone_id,
                                sort_order, status, starts_at, ends_at)
    values (p ->> 'title', p ->> 'image_path', nullif(p ->> 'link', ''), nullif(p ->> 'news_id', '')::uuid,
            coalesce((p ->> 'sponsored')::boolean, false), nullif(p ->> 'sponsor_name', ''),
            (select id from public.zones where slug = 'pando'),
            coalesce((p ->> 'sort_order')::smallint, 0), coalesce(p ->> 'status', 'draft'),
            coalesce((p ->> 'starts_at')::timestamptz, now()), nullif(p ->> 'ends_at', '')::timestamptz)
    returning id into id_;
    perform public.registrar_accion('crear_banner', 'banners', id_::text, jsonb_build_object('titulo', p ->> 'title'));
  else
    update public.banners set
      title = p ->> 'title', image_path = p ->> 'image_path', link = nullif(p ->> 'link', ''),
      news_id = nullif(p ->> 'news_id', '')::uuid,
      sponsored = coalesce((p ->> 'sponsored')::boolean, false), sponsor_name = nullif(p ->> 'sponsor_name', ''),
      sort_order = coalesce((p ->> 'sort_order')::smallint, sort_order),
      status = coalesce(p ->> 'status', status),
      starts_at = coalesce((p ->> 'starts_at')::timestamptz, starts_at),
      ends_at = nullif(p ->> 'ends_at', '')::timestamptz
    where id = id_;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
    perform public.registrar_accion('editar_banner', 'banners', id_::text, jsonb_build_object('estado', p ->> 'status'));
  end if;
  return id_;
end;
$$;

revoke all on function public.banners() from public;
grant execute on function public.banners() to anon, authenticated;
revoke all on function public.admin_banners() from public, anon;
grant execute on function public.admin_banners() to authenticated;
revoke all on function public.admin_guardar_banner(jsonb) from public, anon;
grant execute on function public.admin_guardar_banner(jsonb) to authenticated;
