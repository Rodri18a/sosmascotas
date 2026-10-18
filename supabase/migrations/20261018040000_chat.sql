-- Paso 1.4.1: chat interno (D10, D73). Es la vía principal de contacto y no
-- expone teléfonos. Hoy se abre desde un SOS (quien vio o encontró la
-- mascota le escribe a quien publicó); los chats con comercios llegan con la
-- etapa 1.3. Quien publicó el SOS aparece como "Familia de <nombre>" (la app
-- no muestra su nombre de cuenta) y decide si responde o bloquea, igual que en
-- el contacto inverso.

create table public.conversations (
  id               uuid primary key default gen_random_uuid(),
  kind             text not null check (kind in ('sos', 'qr', 'business', 'user')),
  context_id       uuid,                                -- sos_reports.id, owner_alerts.id…
  created_by       uuid references auth.users (id) on delete set null,
  created_at       timestamptz not null default now(),
  last_message_at  timestamptz not null default now()
);

comment on table public.conversations is
  'Conversaciones del chat interno. Se crean solo con funciones (iniciar_chat_*).';

create unique index conversations_unica_por_contexto
  on public.conversations (kind, context_id, created_by) where context_id is not null;

create table public.conversation_members (
  conversation_id  uuid not null references public.conversations (id) on delete cascade,
  user_id          uuid not null references auth.users (id) on delete cascade,
  last_read_at     timestamptz,
  blocked          boolean not null default false,    -- yo bloqueé esta conversación
  joined_at        timestamptz not null default now(),
  primary key (conversation_id, user_id)
);

create index conversation_members_user_idx on public.conversation_members (user_id);

create table public.messages (
  id               uuid primary key default gen_random_uuid(),
  conversation_id  uuid not null references public.conversations (id) on delete cascade,
  sender_id        uuid default auth.uid() references auth.users (id) on delete set null,
  body             text check (char_length(trim(body)) between 1 and 2000),
  attachment_path  text check (char_length(attachment_path) <= 200),
  lat              double precision check (lat between -90 and 90),
  lng              double precision check (lng between -180 and 180),
  created_at       timestamptz not null default now(),
  check (body is not null or attachment_path is not null or lat is not null),
  check ((lat is null) = (lng is null))
);

create index messages_conversation_idx on public.messages (conversation_id, created_at desc);

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
create function public.es_miembro_chat(p_conversation uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.conversation_members
    where conversation_id = p_conversation and user_id = (select auth.uid())
  );
$$;

-- Una conversación bloqueada por cualquiera de los dos no recibe mensajes.
create function public.chat_bloqueado(p_conversation uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.conversation_members
    where conversation_id = p_conversation and blocked
  );
$$;

revoke all on function public.es_miembro_chat(uuid) from public, anon;
revoke all on function public.chat_bloqueado(uuid) from public, anon;
grant execute on function public.es_miembro_chat(uuid) to authenticated;
grant execute on function public.chat_bloqueado(uuid) to authenticated;

alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;

create policy "ver_mis_conversaciones" on public.conversations for select to authenticated
  using (public.es_miembro_chat(id));

create policy "ver_participantes" on public.conversation_members for select to authenticated
  using (public.es_miembro_chat(conversation_id));
-- Solo mi fila y solo "leído hasta" y "bloqueado" (ver los grants de abajo).
create policy "cambiar_lo_mio" on public.conversation_members for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "ver_mensajes" on public.messages for select to authenticated
  using (public.es_miembro_chat(conversation_id));
create policy "escribir_mensajes" on public.messages for insert to authenticated
  with check (sender_id = (select auth.uid())
              and public.es_miembro_chat(conversation_id)
              and not public.chat_bloqueado(conversation_id));

revoke all on public.conversations, public.conversation_members, public.messages from anon;
revoke insert, update, delete on public.conversations from authenticated;
revoke insert, update, delete on public.conversation_members from authenticated;
grant update (last_read_at, blocked) on public.conversation_members to authenticated;
revoke update, delete on public.messages from authenticated;

-- Límite anti-abuso: 30 mensajes por minuto por persona; la hora es la del
-- servidor; cada mensaje mueve la conversación arriba de la lista.
create function public.messages_antes()
returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  new.created_at := now();
  if (select count(*) from public.messages
      where sender_id = new.sender_id and created_at > now() - interval '1 minute') >= 30 then
    raise exception 'Demasiados mensajes seguidos' using errcode = '54000';
  end if;
  update public.conversations set last_message_at = now() where id = new.conversation_id;
  return new;
end;
$$;

create trigger messages_antes
  before insert on public.messages
  for each row execute function public.messages_antes();

-- ---------------------------------------------------------------------
-- Abrir un chat desde un SOS
-- ---------------------------------------------------------------------
create function public.iniciar_chat_sos(p_sos uuid)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  autor uuid;
  conv uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select user_id into autor from public.sos_reports
    where id = p_sos and status = 'active';
  if autor is null then
    raise exception 'El reporte no está activo' using errcode = 'P0002';
  end if;
  if autor = yo then
    raise exception 'Es tu propio reporte' using errcode = '22023';
  end if;
  select id into conv from public.conversations
    where kind = 'sos' and context_id = p_sos and created_by = yo;
  if conv is not null then
    return conv;
  end if;
  -- Hasta 10 chats nuevos por día por persona.
  if (select count(*) from public.conversations
      where created_by = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados chats nuevos hoy' using errcode = '54000';
  end if;
  insert into public.conversations (kind, context_id, created_by)
    values ('sos', p_sos, yo) returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
    values (conv, yo, now()), (conv, autor, null);
  return conv;
end;
$$;

-- Mis conversaciones con lo necesario para la lista. Del otro lado se da su
-- nombre visible solo si NO es quien publicó el SOS (a quien publicó lo
-- nombra la app como "Familia de <mascota>").
create function public.mis_conversaciones()
returns table (
  id uuid, kind text, context_id uuid, last_message_at timestamptz,
  otro_id uuid, otro_nombre text, soy_autor boolean,
  sos_kind text, sos_nombre text,
  ultimo_mensaje text, sin_leer integer, bloqueada boolean, bloqueada_por_mi boolean
)
language sql stable security definer set search_path = ''
as $$
  select c.id, c.kind, c.context_id, c.last_message_at,
         otro.user_id,
         case when s.user_id = otro.user_id then null else p.display_name end,
         s.user_id = (select auth.uid()),
         s.kind::text, s.name,
         (select coalesce(m.body, case when m.attachment_path is not null then '📷' else '📍' end)
            from public.messages m where m.conversation_id = c.id
            order by m.created_at desc limit 1),
         (select count(*)::int from public.messages m
            where m.conversation_id = c.id and m.sender_id <> (select auth.uid())
              and (yo.last_read_at is null or m.created_at > yo.last_read_at)),
         exists (select 1 from public.conversation_members b
                 where b.conversation_id = c.id and b.blocked),
         yo.blocked
  from public.conversations c
  join public.conversation_members yo
    on yo.conversation_id = c.id and yo.user_id = (select auth.uid())
  left join public.conversation_members otro
    on otro.conversation_id = c.id and otro.user_id <> (select auth.uid())
  left join public.profiles p on p.id = otro.user_id
  left join public.sos_reports s on c.kind = 'sos' and s.id = c.context_id
  order by c.last_message_at desc;
$$;

revoke all on function public.iniciar_chat_sos(uuid) from public, anon;
revoke all on function public.mis_conversaciones() from public, anon;
grant execute on function public.iniciar_chat_sos(uuid) to authenticated;
grant execute on function public.mis_conversaciones() to authenticated;

-- ---------------------------------------------------------------------
-- Fotos del chat: bucket privado; cada uno sube en su carpeta
-- (<usuario>/<conversación>/<archivo>) y las leen los de esa conversación.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('chat-photos', 'chat-photos', false, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_del_chat" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'chat-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and public.es_miembro_chat(((storage.foldername(name))[2])::uuid)
  );

create policy "ver_fotos_del_chat" on storage.objects for select to authenticated
  using (
    bucket_id = 'chat-photos'
    and public.es_miembro_chat(((storage.foldername(name))[2])::uuid)
  );

-- Reportes de mensajes (moderación, 1.4.4): se suma el tipo al de `flags`.
alter table public.flags drop constraint flags_target_type_check;
alter table public.flags add constraint flags_target_type_check
  check (target_type in ('sos', 'message'));

-- Realtime: los mensajes nuevos llegan al instante (respeta la RLS).
alter publication supabase_realtime add table public.messages;
