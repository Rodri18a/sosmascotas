-- Plan de mejoras 2.4 (D135): respuestas de profesionales en las Preguntas.
-- Quien es titular o parte del equipo de una veterinaria verificada marca su
-- propia respuesta como «Respuesta de profesional · <veterinaria>». Se ve el
-- nombre del negocio (público); de la persona, solo el primer nombre.

alter table public.community_comments
  add column professional_business_id uuid references public.businesses (id) on delete set null;

-- Veterinarias verificadas que atiendo (titular o equipo): con cuál puedo
-- firmar una respuesta.
create function public.puedo_responder_como(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.businesses b
                 where b.id = p_business and b.business_type = 'vet'
                   and b.verification = 'verified' and b.status = 'active')
     and public.soy_duenio_de(p_business);
$$;

create function public.mis_veterinarias_verificadas()
returns table (id uuid, name text)
language sql stable security definer set search_path = ''
as $$
  select b.id, b.name from public.businesses b
  where b.business_type = 'vet' and b.verification = 'verified' and b.status = 'active'
    and public.soy_duenio_de(b.id)
  order by b.name;
$$;

-- Marca (o desmarca, con null) mi respuesta a una pregunta como profesional.
create function public.marcar_profesional(p_comentario uuid, p_negocio uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.community_comments c
                 join public.community_posts p on p.id = c.post_id
                 where c.id = p_comentario and c.status = 'active'
                   and c.author_id = (select auth.uid()) and p.kind = 'question') then
    raise exception 'Solo tu respuesta a una pregunta' using errcode = '42501';
  end if;
  if p_negocio is not null and not public.puedo_responder_como(p_negocio) then
    raise exception 'No sos de una veterinaria verificada' using errcode = '42501';
  end if;
  update public.community_comments set professional_business_id = p_negocio where id = p_comentario;
end;
$$;

-- La publicación suma, en cada comentario, la veterinaria que la firma.
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
               'es_mio', c.author_id = (select auth.uid()), 'created_at', c.created_at,
               'profesional', pb.name)
             order by c.created_at)
      from public.community_comments c
      left join public.businesses pb
        on pb.id = c.professional_business_id and pb.verification = 'verified' and pb.status = 'active'
      where c.post_id = p.id and c.status = 'active'), '[]'))
  from public.community_posts p
  join public.community_groups g on g.id = p.group_id and g.status = 'active'
  where p.id = p_id and p.status = 'active';
$$;

-- La lista de preguntas dice cuáles tienen una respuesta profesional.
drop function public.preguntas(text, text, timestamptz);
create function public.preguntas(p_tema text default null, p_buscar text default null,
                                 p_antes timestamptz default null)
returns table (id uuid, topic text, body text, autor text, es_mio boolean, respuestas integer,
               resuelta boolean, con_profesional boolean, group_name text, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select p.id, p.topic, p.body, public.primer_nombre(p.author_id),
         p.author_id = (select auth.uid()),
         (select count(*)::int from public.community_comments c where c.post_id = p.id and c.status = 'active'),
         p.solved_comment_id is not null,
         exists (select 1 from public.community_comments c
                 join public.businesses b on b.id = c.professional_business_id
                 where c.post_id = p.id and c.status = 'active'
                   and b.verification = 'verified' and b.status = 'active'),
         g.name, p.created_at
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

revoke all on function public.puedo_responder_como(uuid) from public, anon, authenticated;
revoke all on function public.mis_veterinarias_verificadas() from public, anon;
revoke all on function public.marcar_profesional(uuid, uuid) from public, anon;
revoke all on function public.preguntas(text, text, timestamptz) from public;
grant execute on function public.mis_veterinarias_verificadas() to authenticated;
grant execute on function public.marcar_profesional(uuid, uuid) to authenticated;
grant execute on function public.preguntas(text, text, timestamptz) to anon, authenticated;
