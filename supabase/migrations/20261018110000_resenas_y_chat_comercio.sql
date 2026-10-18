-- 1.4.3 (resto) chat con comercios y etapa 1.7 reseñas (D78).
--  · Chat desde la ficha de un lugar con dueño: la persona ve el nombre del
--    negocio y el comercio ve el nombre visible de la persona.
--  · Reseñas de 1 a 5 estrellas + comentario, solo con contacto real con el
--    comercio (06): un chat con él, haber tocado uno de sus contactos o
--    "Fui" (lo declara la persona). Una por persona y comercio, editable. El
--    comercio responde una vez y en público, no las puede borrar (sí
--    reportar). Con 3 reportes de personas distintas se ocultan hasta que
--    las revise la administración.

-- ---------------------------------------------------------------------
-- Chat con un comercio
-- ---------------------------------------------------------------------
create function public.iniciar_chat_negocio(p_business uuid)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  dueno uuid;
  conv uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select owner_id into dueno from public.businesses where id = p_business and status = 'active';
  if dueno is null then
    raise exception 'Este lugar todavía no tiene a nadie a cargo' using errcode = 'P0002';
  end if;
  if dueno = yo then
    raise exception 'Es tu negocio' using errcode = '22023';
  end if;
  select id into conv from public.conversations
    where kind = 'business' and context_id = p_business and created_by = yo;
  if conv is not null then
    return conv;
  end if;
  if (select count(*) from public.conversations
      where created_by = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados chats nuevos hoy' using errcode = '54000';
  end if;
  insert into public.conversations (kind, context_id, created_by)
    values ('business', p_business, yo) returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
    values (conv, yo, now()), (conv, dueno, null);
  return conv;
end;
$$;

revoke all on function public.iniciar_chat_negocio(uuid) from public, anon;
grant execute on function public.iniciar_chat_negocio(uuid) to authenticated;

-- La lista suma el nombre del negocio (para quien le escribe) y si yo soy el
-- comercio de esa conversación.
drop function public.mis_conversaciones();
create function public.mis_conversaciones()
returns table (
  id uuid, kind text, context_id uuid, last_message_at timestamptz,
  otro_id uuid, otro_nombre text, soy_autor boolean,
  sos_kind text, sos_nombre text, negocio_nombre text,
  ultimo_mensaje text, sin_leer integer, bloqueada boolean, bloqueada_por_mi boolean
)
language sql stable security definer set search_path = ''
as $$
  select c.id, c.kind, c.context_id, c.last_message_at,
         otro.user_id,
         case when s.user_id = otro.user_id or b.owner_id = otro.user_id then null
              else p.display_name end,
         coalesce(s.user_id, b.owner_id) = (select auth.uid()),
         s.kind::text, s.name, b.name,
         (select coalesce(m.body, case when m.attachment_path is not null then '📷' else '📍' end)
            from public.messages m where m.conversation_id = c.id
            order by m.created_at desc limit 1),
         (select count(*)::int from public.messages m
            where m.conversation_id = c.id and m.sender_id <> (select auth.uid())
              and (yo.last_read_at is null or m.created_at > yo.last_read_at)),
         exists (select 1 from public.conversation_members x
                 where x.conversation_id = c.id and x.blocked),
         yo.blocked
  from public.conversations c
  join public.conversation_members yo
    on yo.conversation_id = c.id and yo.user_id = (select auth.uid())
  left join public.conversation_members otro
    on otro.conversation_id = c.id and otro.user_id <> (select auth.uid())
  left join public.profiles p on p.id = otro.user_id
  left join public.sos_reports s on c.kind = 'sos' and s.id = c.context_id
  left join public.businesses b on c.kind = 'business' and b.id = c.context_id
  order by c.last_message_at desc;
$$;

revoke all on function public.mis_conversaciones() from public, anon;
grant execute on function public.mis_conversaciones() to authenticated;

-- ---------------------------------------------------------------------
-- Reseñas
-- ---------------------------------------------------------------------
create table public.reviews (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  rating       smallint not null check (rating between 1 and 5),
  comment      text check (char_length(trim(comment)) between 1 and 1000),
  reply        text check (char_length(trim(reply)) between 1 and 1000),
  reply_at     timestamptz,
  status       text not null default 'active' check (status in ('active', 'hidden')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (business_id, user_id)
);

create index reviews_business_idx on public.reviews (business_id, created_at desc) where status = 'active';

create trigger reviews_updated_at
  before update on public.reviews
  for each row execute function public.set_updated_at();

alter table public.reviews enable row level security;
-- Sin acceso directo: todo con las funciones de abajo.
revoke all on public.reviews from anon, authenticated;

-- ¿Tuvo [p_user] un contacto real con [p_business]?
create function public.tuvo_contacto(p_user uuid, p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.user_places u
                 where u.user_id = p_user and u.business_id = p_business and u.visited_at is not null)
      or exists (select 1 from public.events e
                 where e.user_id = p_user and e.business_id = p_business and e.name = 'place_click')
      or exists (select 1 from public.conversations c
                 join public.messages m on m.conversation_id = c.id and m.sender_id = p_user
                 where c.kind = 'business' and c.context_id = p_business);
$$;

revoke all on function public.tuvo_contacto(uuid, uuid) from public, anon, authenticated;

-- ¿Puedo reseñar este lugar? (para mostrar el botón)
create function public.puedo_resenar(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select (select auth.uid()) is not null
     and not exists (select 1 from public.businesses where id = p_business and owner_id = (select auth.uid()))
     and public.tuvo_contacto((select auth.uid()), p_business);
$$;

-- Escribir o editar mi reseña.
create function public.guardar_resena(p_business uuid, p_estrellas smallint, p_comentario text default null)
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
  if exists (select 1 from public.businesses where id = p_business and owner_id = yo) then
    raise exception 'No podés reseñar tu propio negocio' using errcode = '22023';
  end if;
  if not public.tuvo_contacto(yo, p_business) then
    raise exception 'Hace falta un contacto real con el comercio' using errcode = '42501';
  end if;
  insert into public.reviews (business_id, user_id, rating, comment)
  values (p_business, yo, p_estrellas, nullif(trim(p_comentario), ''))
  on conflict (business_id, user_id) do update
    set rating = excluded.rating, comment = excluded.comment
  returning id into id_;
  return id_;
end;
$$;

-- El comercio responde una sola vez, en público.
create function public.responder_resena(p_review uuid, p_respuesta text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.reviews r
                 join public.businesses b on b.id = r.business_id
                 where r.id = p_review and b.owner_id = (select auth.uid())) then
    raise exception 'No es una reseña de tu negocio' using errcode = '42501';
  end if;
  update public.reviews set reply = nullif(trim(p_respuesta), ''), reply_at = now()
   where id = p_review and reply is null;
  if not found then
    raise exception 'Ya respondiste esta reseña' using errcode = '23505';
  end if;
end;
$$;

-- Reseñas públicas de un lugar: solo el nombre visible de quien escribió
-- (nunca su id), con el promedio. `mia` marca la propia.
create function public.resenas_de(p_business uuid)
returns table (id uuid, estrellas smallint, comentario text, respuesta text, respondida timestamptz,
               creada timestamptz, autor text, mia boolean)
language sql stable security definer set search_path = ''
as $$
  select r.id, r.rating, r.comment, r.reply, r.reply_at, r.created_at,
         coalesce(split_part(trim(p.display_name), ' ', 1), ''),
         r.user_id = (select auth.uid())
  from public.reviews r
  left join public.profiles p on p.id = r.user_id
  where r.business_id = p_business and r.status = 'active'
  order by r.created_at desc
  limit 100;
$$;

revoke all on function public.puedo_resenar(uuid) from public;
revoke all on function public.guardar_resena(uuid, smallint, text) from public, anon;
revoke all on function public.responder_resena(uuid, text) from public, anon;
revoke all on function public.resenas_de(uuid) from public;
grant execute on function public.puedo_resenar(uuid) to anon, authenticated;
grant execute on function public.guardar_resena(uuid, smallint, text) to authenticated;
grant execute on function public.responder_resena(uuid, text) to authenticated;
grant execute on function public.resenas_de(uuid) to anon, authenticated;

-- Reportes de reseñas (con 3 de personas distintas, se ocultan).
alter table public.flags drop constraint flags_target_type_check;
alter table public.flags add constraint flags_target_type_check
  check (target_type in ('sos', 'message', 'review'));

create or replace function public.ocultar_con_tres_reportes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.target_type in ('sos', 'review') and (
    select count(distinct reporter_id) from public.flags
    where target_type = new.target_type and target_id = new.target_id
  ) >= 3 then
    if new.target_type = 'sos' then
      update public.sos_reports set status = 'hidden'
      where id = new.target_id and status = 'active';
    else
      update public.reviews set status = 'hidden'
      where id = new.target_id and status = 'active';
    end if;
  end if;
  return new;
end;
$$;

-- Moderación: también reseñas (ocultas o reportadas).
create or replace function public.admin_moderacion()
returns table (
  target_type text, target_id uuid, autor_id uuid, autor_nombre text,
  texto text, estado text, reportes integer, motivos text[], ultimo_reporte timestamptz
)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query
  select 'sos'::text, s.id, s.user_id, p.display_name,
         concat_ws(' · ', s.kind::text, s.name, s.description),
         s.status::text,
         (select count(*)::int from public.flags f where f.target_type = 'sos' and f.target_id = s.id),
         array(select f.reason from public.flags f where f.target_type = 'sos' and f.target_id = s.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'sos' and f.target_id = s.id)
  from public.sos_reports s
  left join public.profiles p on p.id = s.user_id
  where s.status = 'hidden'
     or (s.status = 'active' and exists (select 1 from public.flags f
                                         where f.target_type = 'sos' and f.target_id = s.id))
  union all
  select 'message'::text, m.id, m.sender_id, p.display_name,
         coalesce(m.body, case when m.attachment_path is not null then '📷' else '📍' end),
         'reported'::text,
         (select count(*)::int from public.flags f where f.target_type = 'message' and f.target_id = m.id),
         array(select f.reason from public.flags f where f.target_type = 'message' and f.target_id = m.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'message' and f.target_id = m.id)
  from public.messages m
  left join public.profiles p on p.id = m.sender_id
  where exists (select 1 from public.flags f where f.target_type = 'message' and f.target_id = m.id)
    and not exists (select 1 from public.admin_actions x
                    where x.target_type = 'message' and x.target_id = m.id::text)
  union all
  select 'review'::text, r.id, r.user_id, p.display_name,
         concat(r.rating, '★ ', r.comment),
         r.status,
         (select count(*)::int from public.flags f where f.target_type = 'review' and f.target_id = r.id),
         array(select f.reason from public.flags f where f.target_type = 'review' and f.target_id = r.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'review' and f.target_id = r.id)
  from public.reviews r
  left join public.profiles p on p.id = r.user_id
  where r.status = 'hidden'
     or exists (select 1 from public.flags f where f.target_type = 'review' and f.target_id = r.id
                and not exists (select 1 from public.admin_actions x
                                where x.target_type = 'review' and x.target_id = r.id::text
                                  and x.created_at > f.created_at))
  order by 9 desc nulls last;
end;
$$;

create or replace function public.admin_moderar(p_tipo text, p_id uuid, p_accion text, p_motivo text default null)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  if p_tipo = 'sos' and p_accion = 'aprobar' then
    update public.sos_reports set status = 'active' where id = p_id and status = 'hidden';
    delete from public.flags where target_type = 'sos' and target_id = p_id;
  elsif p_tipo = 'sos' and p_accion = 'eliminar' then
    update public.sos_reports set status = 'archived' where id = p_id;
  elsif p_tipo = 'message' and p_accion = 'aprobar' then
    null;
  elsif p_tipo = 'message' and p_accion = 'eliminar' then
    delete from public.messages where id = p_id;
  elsif p_tipo = 'review' and p_accion = 'aprobar' then
    update public.reviews set status = 'active' where id = p_id;
    delete from public.flags where target_type = 'review' and target_id = p_id;
  elsif p_tipo = 'review' and p_accion = 'eliminar' then
    delete from public.reviews where id = p_id;
  else
    raise exception 'Acción inválida' using errcode = '22023';
  end if;
  perform public.registrar_accion('moderar_' || p_accion, p_tipo, p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- El panel del comercio suma su reputación (05: promedio de reseñas).
create or replace function public.panel_negocio(p_id uuid, p_dias integer default 30)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
  antes timestamptz := desde - make_interval(days => greatest(1, least(p_dias, 365)));
begin
  if not (public.soy_duenio_de(p_id) or public.es_admin()) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'aperturas', (select count(*) from public.events where business_id = p_id and name = 'place_open' and created_at >= desde),
    'aperturas_antes', (select count(*) from public.events where business_id = p_id and name = 'place_open'
                        and created_at >= antes and created_at < desde),
    'clics', (select coalesce(jsonb_object_agg(tipo, n), '{}') from (
                select props ->> 'tipo' as tipo, count(*) n from public.events
                where business_id = p_id and name = 'place_click' and created_at >= desde
                group by 1) t),
    'favoritos', (select count(*) from public.user_places where business_id = p_id and favorite),
    'visitas', (select count(*) from public.events where business_id = p_id and name = 'place_visit' and created_at >= desde),
    'socios', (select count(*) from public.user_places where business_id = p_id and is_my_vet),
    'resenas', (select count(*) from public.reviews where business_id = p_id and status = 'active'),
    'promedio', (select round(avg(rating)::numeric, 1) from public.reviews where business_id = p_id and status = 'active'),
    'sin_responder', (select count(*) from public.reviews where business_id = p_id and status = 'active' and reply is null),
    'chats', (select count(*) from public.conversations where kind = 'business' and context_id = p_id and created_at >= desde),
    'desde', desde
  );
end;
$$;
