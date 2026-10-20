-- Etapa 2.8 (D83): Noticias con contenido patrocinado (03 §10, 05 §8).
--  · Las carga la administración desde el portal (no hay escritura directa).
--  · Se filtran por especie (06: coincide si la lista incluye la de la
--    mascota; una noticia sin especies es para todas).
--  · Las patrocinadas llevan la etiqueta "Promocionado" y el nombre de la
--    marca; nunca se mezclan sin avisar.

create table public.news (
  id            uuid primary key default gen_random_uuid(),
  title         text not null check (char_length(trim(title)) between 3 and 120),
  body          text not null check (char_length(trim(body)) between 10 and 4000),
  source        text check (char_length(source) <= 80),
  link          text check (link ~ '^https://' and char_length(link) <= 300),
  species_ids   smallint[] not null default '{}',
  sponsored     boolean not null default false,
  sponsor_name  text check (char_length(sponsor_name) <= 80),
  zone_id       smallint references public.zones (id),
  status        text not null default 'draft' check (status in ('draft', 'published', 'hidden')),
  published_at  timestamptz not null default now(),
  created_by    uuid default auth.uid() references auth.users (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (not sponsored or sponsor_name is not null)
);

comment on table public.news is
  'Noticias de la app (2.8, D83). Las carga la administración; las patrocinadas dicen "Promocionado".';

create index news_publicadas_idx on public.news (published_at desc) where status = 'published';

create trigger news_updated_at
  before update on public.news
  for each row execute function public.set_updated_at();

alter table public.news enable row level security;
revoke all on public.news from anon, authenticated;

-- Noticias publicadas (visitantes incluidos), filtradas por especie.
create function public.noticias(p_especies smallint[] default null)
returns table (id uuid, title text, body text, source text, link text, species_ids smallint[],
               sponsored boolean, sponsor_name text, published_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select n.id, n.title, n.body, n.source, n.link, n.species_ids, n.sponsored, n.sponsor_name, n.published_at
  from public.news n
  where n.status = 'published' and n.published_at <= now()
    and (p_especies is null or cardinality(p_especies) = 0
         or cardinality(n.species_ids) = 0 or n.species_ids && p_especies)
  order by n.published_at desc
  limit 60;
$$;

create function public.admin_noticias()
returns setof public.news
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query select * from public.news order by created_at desc limit 200;
end;
$$;

create function public.admin_guardar_noticia(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  especies smallint[] := coalesce(array(select jsonb_array_elements_text(coalesce(p -> 'species_ids', '[]'))::smallint), '{}');
begin
  perform public.exigir_admin();
  if coalesce(p ->> 'status', 'draft') not in ('draft', 'published', 'hidden') then
    raise exception 'Estado inválido' using errcode = '22023';
  end if;
  if id_ is null then
    insert into public.news (title, body, source, link, species_ids, sponsored, sponsor_name, zone_id,
                             status, published_at)
    values (p ->> 'title', p ->> 'body', nullif(p ->> 'source', ''), nullif(p ->> 'link', ''), especies,
            coalesce((p ->> 'sponsored')::boolean, false), nullif(p ->> 'sponsor_name', ''),
            (select id from public.zones where slug = 'pando'),
            coalesce(p ->> 'status', 'draft'), coalesce((p ->> 'published_at')::timestamptz, now()))
    returning id into id_;
    perform public.registrar_accion('crear_noticia', 'news', id_::text, jsonb_build_object('titulo', p ->> 'title'));
  else
    update public.news set
      title = p ->> 'title', body = p ->> 'body', source = nullif(p ->> 'source', ''),
      link = nullif(p ->> 'link', ''), species_ids = especies,
      sponsored = coalesce((p ->> 'sponsored')::boolean, false), sponsor_name = nullif(p ->> 'sponsor_name', ''),
      status = coalesce(p ->> 'status', status),
      published_at = coalesce((p ->> 'published_at')::timestamptz, published_at)
    where id = id_;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
    perform public.registrar_accion('editar_noticia', 'news', id_::text, jsonb_build_object('estado', p ->> 'status'));
  end if;
  return id_;
end;
$$;

revoke all on function public.noticias(smallint[]) from public;
grant execute on function public.noticias(smallint[]) to anon, authenticated;
revoke all on function public.admin_noticias() from public, anon;
grant execute on function public.admin_noticias() to authenticated;
revoke all on function public.admin_guardar_noticia(jsonb) from public, anon;
grant execute on function public.admin_guardar_noticia(jsonb) to authenticated;
