-- Plan de mejoras 2.3 (D134): Preguntas de la comunidad. Son publicaciones de
-- tipo `question` de los grupos (D116), con un tema y, si quien preguntó la
-- marca, la respuesta que le sirvió. Heredan todo lo de la comunidad: primer
-- nombre, filtro de venta y cruza, reportes y moderación. Se leen sin cuenta.

create extension if not exists unaccent schema extensions;

alter table public.community_posts
  add column topic text check (topic in ('travel', 'health', 'food', 'adoption', 'paperwork', 'other')),
  add column solved_comment_id uuid references public.community_comments (id) on delete set null,
  add constraint community_posts_tema_solo_preguntas check (topic is null or kind = 'question');

create index community_posts_preguntas_idx on public.community_posts (created_at desc)
  where kind = 'question' and status = 'active';

-- Para quien no sabe en qué grupo preguntar.
insert into public.community_groups (kind, name, icon, sort, description) values
  ('topic', 'Preguntas generales', '❓', 199, 'Cualquier duda sobre tu mascota: viajes, salud, alimentación, trámites…');

-- Sin tildes ni mayúsculas, para buscar.
create function public.texto_para_buscar(p_texto text)
returns text
language sql stable set search_path = ''
as $$
  select extensions.unaccent(lower(coalesce(p_texto, '')));
$$;

-- Preguntas de todos los grupos activos, de la más nueva a la más vieja.
-- [p_tema] filtra por tema y [p_buscar] busca en el texto (sin tildes).
create function public.preguntas(p_tema text default null, p_buscar text default null,
                                 p_antes timestamptz default null)
returns table (id uuid, topic text, body text, autor text, es_mio boolean, respuestas integer,
               resuelta boolean, group_name text, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select p.id, p.topic, p.body, public.primer_nombre(p.author_id),
         p.author_id = (select auth.uid()),
         (select count(*)::int from public.community_comments c where c.post_id = p.id and c.status = 'active'),
         p.solved_comment_id is not null, g.name, p.created_at
  from public.community_posts p
  join public.community_groups g on g.id = p.group_id and g.status = 'active'
  where p.kind = 'question' and p.status = 'active'
    and (p_tema is null or p.topic = p_tema)
    and (nullif(trim(p_buscar), '') is null
         or position(public.texto_para_buscar(trim(p_buscar)) in public.texto_para_buscar(p.body)) > 0)
    and (p_antes is null or p.created_at < p_antes)
  order by p.created_at desc
  limit 30;
$$;

-- Hace una pregunta: si no estoy en el grupo (por defecto «Preguntas
-- generales») me suma, y publica con los mismos controles de publicar().
create function public.preguntar(p_tema text, p_texto text, p_grupo uuid default null)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  grupo uuid := p_grupo;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if p_tema is null or p_tema not in ('travel', 'health', 'food', 'adoption', 'paperwork', 'other') then
    raise exception 'Tema no válido' using errcode = '22023';
  end if;
  if grupo is null then
    select g.id into grupo from public.community_groups g
     where g.kind = 'topic' and g.name = 'Preguntas generales' and g.status = 'active';
  end if;
  if not public.soy_de_grupo(grupo) then
    perform public.unirme_grupo(grupo, true);
  end if;
  id_ := public.publicar(grupo, 'question', p_texto, '{}');
  update public.community_posts set topic = p_tema where id = id_;
  return id_;
end;
$$;

-- Quien preguntó marca (o desmarca, con null) la respuesta que le sirvió.
create function public.marcar_respuesta(p_post uuid, p_comentario uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.community_posts
                 where id = p_post and kind = 'question' and status = 'active'
                   and author_id = (select auth.uid())) then
    raise exception 'Solo quien preguntó' using errcode = '42501';
  end if;
  if p_comentario is not null and not exists (
       select 1 from public.community_comments
        where id = p_comentario and post_id = p_post and status = 'active') then
    raise exception 'La respuesta no es de esta pregunta' using errcode = '22023';
  end if;
  update public.community_posts set solved_comment_id = p_comentario where id = p_post;
end;
$$;

-- La publicación suma el tema y la respuesta marcada.
create or replace function public.publicacion(p_id uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id, 'group_id', p.group_id, 'group_name', g.name, 'kind', p.kind, 'body', p.body,
    'photo_paths', to_jsonb(p.photo_paths), 'autor', public.primer_nombre(p.author_id),
    'es_mio', p.author_id = (select auth.uid()), 'created_at', p.created_at,
    'soy_miembro', public.soy_de_grupo(p.group_id),
    'topic', p.topic, 'solved_comment_id', p.solved_comment_id,
    'comentarios', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', c.id, 'body', c.body, 'autor', public.primer_nombre(c.author_id),
               'es_mio', c.author_id = (select auth.uid()), 'created_at', c.created_at)
             order by c.created_at)
      from public.community_comments c where c.post_id = p.id and c.status = 'active'), '[]'))
  from public.community_posts p
  join public.community_groups g on g.id = p.group_id and g.status = 'active'
  where p.id = p_id and p.status = 'active';
$$;

revoke all on function public.texto_para_buscar(text) from public, anon, authenticated;
revoke all on function public.preguntas(text, text, timestamptz) from public;
revoke all on function public.preguntar(text, text, uuid) from public, anon;
revoke all on function public.marcar_respuesta(uuid, uuid) from public, anon;
grant execute on function public.preguntas(text, text, timestamptz) to anon, authenticated;
grant execute on function public.preguntar(text, text, uuid) to authenticated;
grant execute on function public.marcar_respuesta(uuid, uuid) to authenticated;

-- Funcionalidad gradual (D64): prendida para todos.
insert into public.feature_flags (key, description, stage)
values ('preguntas', 'Preguntas de la comunidad con temas y buscador (plan de mejoras 2.3, D134)', 'todos')
on conflict (key) do nothing;
