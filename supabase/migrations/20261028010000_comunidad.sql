-- Etapa 3.4 (D116): comunidad por raza y especie (03 §13, 06 «Comunidad»).
--  · Grupos por especie y por tema (los crea la administración; los de
--    especie y algunos temas vienen de entrada) y por raza: se crean solos
--    cuando alguien con una mascota de esa raza se une (nombre de `breeds`;
--    no para "Mestizo"), así no hay grupos vacíos ni nombres inventados.
--  · Publicaciones (pregunta, consejo, experiencia) con hasta 4 fotos (bucket
--    público `community-photos`, la app les borra el EXIF, D28) y comentarios.
--    Se lee sin cuenta; publicar y comentar piden ser parte del grupo.
--  · Seguridad: sin ubicación, sin listados de mascotas ni de personas; de
--    quien escribe solo se ve el primer nombre. La base rechaza textos de
--    venta o cruza de animales (06). Se reporta con `flags` (post, comment):
--    con 3 reportes se oculta solo y entra en la moderación del portal.
--  · Saludo previo al chat: se saluda a quien escribió una publicación o un
--    comentario (sin ver su id); si acepta, se abre un chat entre personas
--    (kind 'user'). Un rechazo frena nuevos saludos a esa persona por 30 días.

-- ---------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------
create table public.community_groups (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null check (kind in ('species', 'breed', 'topic')),
  name        text not null check (char_length(trim(name)) between 3 and 60),
  description text check (char_length(description) <= 300),
  icon        text check (char_length(icon) <= 8),
  species_id  smallint references public.species (id),
  breed_id    integer,
  sort        smallint not null default 100,
  status      text not null default 'active' check (status in ('active', 'hidden')),
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now(),
  foreign key (species_id, breed_id) references public.breeds (species_id, id),
  check ((kind = 'breed') = (breed_id is not null)),
  check (kind <> 'species' or species_id is not null)
);

create unique index community_groups_raza on public.community_groups (breed_id) where kind = 'breed';
create unique index community_groups_nombre on public.community_groups (lower(name));

comment on table public.community_groups is
  'Grupos de la comunidad (3.4, D116). Sin acceso directo: grupos(), grupo_de_raza(), admin_guardar_grupo().';

create table public.community_members (
  group_id   uuid not null references public.community_groups (id) on delete cascade,
  user_id    uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create index community_members_user_idx on public.community_members (user_id);

create table public.community_posts (
  id          uuid primary key default gen_random_uuid(),
  group_id    uuid not null references public.community_groups (id) on delete cascade,
  author_id   uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind        text not null default 'question' check (kind in ('question', 'tip', 'story')),
  body        text not null check (char_length(trim(body)) between 1 and 2000),
  photo_paths text[] not null default '{}' check (cardinality(photo_paths) <= 4),
  status      text not null default 'active' check (status in ('active', 'hidden')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index community_posts_group_idx on public.community_posts (group_id, created_at desc) where status = 'active';
create index community_posts_author_idx on public.community_posts (author_id, created_at desc);

create trigger community_posts_updated_at
  before update on public.community_posts
  for each row execute function public.set_updated_at();

create table public.community_comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.community_posts (id) on delete cascade,
  author_id  uuid not null default auth.uid() references auth.users (id) on delete cascade,
  body       text not null check (char_length(trim(body)) between 1 and 1000),
  status     text not null default 'active' check (status in ('active', 'hidden')),
  created_at timestamptz not null default now()
);

create index community_comments_post_idx on public.community_comments (post_id, created_at);
create index community_comments_author_idx on public.community_comments (author_id, created_at desc);

create table public.community_greetings (
  id              uuid primary key default gen_random_uuid(),
  from_id         uuid not null references auth.users (id) on delete cascade,
  to_id           uuid not null references auth.users (id) on delete cascade,
  post_id         uuid references public.community_posts (id) on delete set null,
  message         text not null check (char_length(trim(message)) between 1 and 200),
  status          text not null default 'pending' check (status in ('pending', 'accepted', 'declined')),
  conversation_id uuid references public.conversations (id) on delete set null,
  created_at      timestamptz not null default now(),
  responded_at    timestamptz,
  check (from_id <> to_id)
);

create index community_greetings_to_idx on public.community_greetings (to_id, created_at desc);
create index community_greetings_from_idx on public.community_greetings (from_id, created_at desc);

comment on table public.community_greetings is
  'Saludo previo al chat entre personas (3.4, D116). Sin acceso directo: saludar(), mis_saludos(), responder_saludo().';

alter table public.community_groups enable row level security;
alter table public.community_members enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_comments enable row level security;
alter table public.community_greetings enable row level security;
revoke all on public.community_groups, public.community_members, public.community_posts,
              public.community_comments, public.community_greetings
  from anon, authenticated;

-- Grupos de entrada: uno por especie (menos «Otro») y algunos temas.
insert into public.community_groups (kind, name, icon, species_id, sort, description)
select 'species', g.nombre, s.icon, s.id, s.sort,
       'Preguntas, consejos y experiencias de quienes viven con ' || lower(g.nombre) || '.'
from (values ('dog', 'Perros'), ('cat', 'Gatos'), ('bird', 'Aves'), ('rabbit', 'Conejos'),
             ('rodent', 'Roedores'), ('turtle', 'Tortugas'), ('reptile', 'Reptiles'),
             ('fish', 'Peces'), ('horse', 'Caballos')) g(slug, nombre)
join public.species s on s.slug = g.slug;

insert into public.community_groups (kind, name, icon, sort, description) values
  ('topic', 'Adopción responsable', '🏡', 200, 'Para quienes adoptaron o están por adoptar: adaptación, primeros días y dudas.'),
  ('topic', 'Mascotas mayores', '🧓', 201, 'Cuidados, salud y calidad de vida de perros y gatos senior.'),
  ('topic', 'Cachorros y gatitos', '🍼', 202, 'Primeras vacunas, educación, alimentación y todo lo de los primeros meses.'),
  ('topic', 'Paseos y salidas', '🌳', 203, 'Lugares, rutinas y consejos para salir con tu mascota.');

-- ---------------------------------------------------------------------
-- Reglas de contenido
-- ---------------------------------------------------------------------

-- ¿El texto ofrece venta o cruza de animales? (06: prohibido en la comunidad).
create function public.texto_prohibido_comunidad(p_texto text)
returns boolean
language sql immutable set search_path = ''
as $$
  select translate(lower(coalesce(p_texto, '')), 'áéíóúü', 'aeiouu') ~
    ('(^|[^a-z])(vendo|vendemos|se vende[n]?|venta de (cachorr|gatit|perr|gat|mascot|conej|pajar)'
     || '|cruza(r|mos)?|para cruzar|servicio de monta|monta|padrillo|semental|busco novi[oa])([^a-z]|$)');
$$;

-- Primer nombre de una persona (lo único que se ve en la comunidad).
create function public.primer_nombre(p_user uuid)
returns text
language sql stable security definer set search_path = ''
as $$
  select nullif(split_part(trim(coalesce(display_name, '')), ' ', 1), '')
  from public.profiles where id = p_user;
$$;

create function public.soy_de_grupo(p_grupo uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.community_members
                 where group_id = p_grupo and user_id = (select auth.uid()));
$$;

-- ---------------------------------------------------------------------
-- Grupos
-- ---------------------------------------------------------------------
create function public.grupos(p_buscar text default null)
returns table (id uuid, kind text, name text, description text, icon text, species_id smallint,
               breed_id integer, miembros integer, publicaciones_semana integer, soy_miembro boolean)
language sql stable security definer set search_path = ''
as $$
  select g.id, g.kind, g.name, g.description, g.icon, g.species_id, g.breed_id,
         (select count(*)::int from public.community_members m where m.group_id = g.id),
         (select count(*)::int from public.community_posts p
          where p.group_id = g.id and p.status = 'active' and p.created_at > now() - interval '7 days'),
         exists (select 1 from public.community_members m
                 where m.group_id = g.id and m.user_id = (select auth.uid()))
  from public.community_groups g
  where g.status = 'active'
    and (p_buscar is null or g.name ilike '%' || replace(replace(trim(p_buscar), '%', ''), '_', '') || '%')
  order by g.sort, g.name
  limit 200;
$$;

-- El grupo de una raza de mis mascotas; si no existe, se crea (D116).
create function public.grupo_de_raza(p_raza integer)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r record;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select b.id, b.species_id, b.name, s.icon into r
  from public.breeds b join public.species s on s.id = b.species_id where b.id = p_raza;
  if not found or r.name ilike 'mestiz%' then
    raise exception 'No hay grupo para esa raza' using errcode = '22023';
  end if;
  if not exists (select 1 from public.pets p where p.breed_id = p_raza and public.puedo_cuidar(p.id)) then
    raise exception 'Ninguna de tus mascotas es de esa raza' using errcode = '42501';
  end if;
  select id into id_ from public.community_groups where kind = 'breed' and breed_id = p_raza;
  if id_ is null then
    insert into public.community_groups (kind, name, icon, species_id, breed_id, sort, description, created_by)
    values ('breed', left(r.name, 60), r.icon, r.species_id, p_raza, 150,
            'Para quienes tienen un ' || r.name || ': salud, carácter, cuidados y experiencias.', yo)
    on conflict do nothing
    returning id into id_;
    if id_ is null then
      select id into id_ from public.community_groups where kind = 'breed' and breed_id = p_raza;
    end if;
  end if;
  return id_;
end;
$$;

create function public.unirme_grupo(p_grupo uuid, p_unirme boolean default true)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if p_unirme then
    if not exists (select 1 from public.community_groups where id = p_grupo and status = 'active') then
      raise exception 'No existe' using errcode = 'P0002';
    end if;
    if (select count(*) from public.community_members where user_id = yo) >= 30 then
      raise exception 'Máximo 30 grupos' using errcode = '54000';
    end if;
    insert into public.community_members (group_id, user_id) values (p_grupo, yo) on conflict do nothing;
  else
    delete from public.community_members where group_id = p_grupo and user_id = yo;
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Publicaciones y comentarios
-- ---------------------------------------------------------------------
create function public.publicaciones_de(p_grupo uuid, p_antes timestamptz default null)
returns table (id uuid, kind text, body text, photo_paths text[], autor text, es_mio boolean,
               comentarios integer, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select p.id, p.kind, p.body, p.photo_paths, public.primer_nombre(p.author_id),
         p.author_id = (select auth.uid()),
         (select count(*)::int from public.community_comments c where c.post_id = p.id and c.status = 'active'),
         p.created_at
  from public.community_posts p
  join public.community_groups g on g.id = p.group_id and g.status = 'active'
  where p.group_id = p_grupo and p.status = 'active'
    and (p_antes is null or p.created_at < p_antes)
  order by p.created_at desc
  limit 30;
$$;

-- Una publicación con sus comentarios (null si no existe o está oculta).
create function public.publicacion(p_id uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id, 'group_id', p.group_id, 'group_name', g.name, 'kind', p.kind, 'body', p.body,
    'photo_paths', to_jsonb(p.photo_paths), 'autor', public.primer_nombre(p.author_id),
    'es_mio', p.author_id = (select auth.uid()), 'created_at', p.created_at,
    'soy_miembro', public.soy_de_grupo(p.group_id),
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

create function public.publicar(p_grupo uuid, p_tipo text, p_texto text, p_fotos text[] default '{}')
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
  if not public.soy_de_grupo(p_grupo) then
    raise exception 'Unite al grupo para publicar' using errcode = '42501';
  end if;
  if public.texto_prohibido_comunidad(p_texto) then
    raise exception 'prohibido: venta o cruza' using errcode = '22023';
  end if;
  if exists (select 1 from unnest(coalesce(p_fotos, '{}')) f
             where f !~ ('^' || yo::text || '/[A-Za-z0-9._-]{1,80}$')) then
    raise exception 'Fotos inválidas' using errcode = '22023';
  end if;
  if (select count(*) from public.community_posts where author_id = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiadas publicaciones hoy' using errcode = '54000';
  end if;
  insert into public.community_posts (group_id, author_id, kind, body, photo_paths)
  values (p_grupo, yo, coalesce(p_tipo, 'question'), trim(p_texto), coalesce(p_fotos, '{}'))
  returning id into id_;
  return id_;
end;
$$;

create function public.comentar(p_post uuid, p_texto text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  grupo uuid;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  select group_id into grupo from public.community_posts where id = p_post and status = 'active';
  if grupo is null then raise exception 'No existe' using errcode = 'P0002'; end if;
  if not public.soy_de_grupo(grupo) then
    raise exception 'Unite al grupo para comentar' using errcode = '42501';
  end if;
  if public.texto_prohibido_comunidad(p_texto) then
    raise exception 'prohibido: venta o cruza' using errcode = '22023';
  end if;
  if (select count(*) from public.community_comments where author_id = yo and created_at > now() - interval '1 day') >= 60 then
    raise exception 'Demasiados comentarios hoy' using errcode = '54000';
  end if;
  insert into public.community_comments (post_id, author_id, body) values (p_post, yo, trim(p_texto))
  returning id into id_;
  return id_;
end;
$$;

-- Quien escribió borra lo suyo.
create function public.borrar_de_comunidad(p_tipo text, p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if p_tipo = 'post' then
    delete from public.community_posts where id = p_id and author_id = yo;
  elsif p_tipo = 'comment' then
    delete from public.community_comments where id = p_id and author_id = yo;
  else
    raise exception 'Tipo inválido' using errcode = '22023';
  end if;
  if not found then raise exception 'No es tuyo' using errcode = '42501'; end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Saludo previo al chat
-- ---------------------------------------------------------------------
create function public.saludar(p_tipo text, p_id uuid, p_mensaje text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  otro uuid;
  post uuid;
  previo public.community_greetings;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if p_tipo = 'post' then
    select author_id, id into otro, post from public.community_posts where id = p_id and status = 'active';
  elsif p_tipo = 'comment' then
    select c.author_id, c.post_id into otro, post from public.community_comments c
    where c.id = p_id and c.status = 'active';
  end if;
  if otro is null then raise exception 'No existe' using errcode = 'P0002'; end if;
  if otro = yo then raise exception 'No te podés saludar' using errcode = '22023'; end if;
  if public.texto_prohibido_comunidad(p_mensaje) then
    raise exception 'prohibido: venta o cruza' using errcode = '22023';
  end if;
  select * into previo from public.community_greetings
  where from_id = yo and to_id = otro order by created_at desc limit 1;
  if found and previo.status in ('pending', 'accepted') then
    return previo.id;
  end if;
  if found and previo.status = 'declined' and previo.responded_at > now() - interval '30 days' then
    raise exception 'Esa persona no quiere chatear por ahora' using errcode = '22023';
  end if;
  if (select count(*) from public.community_greetings where from_id = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados saludos hoy' using errcode = '54000';
  end if;
  insert into public.community_greetings (from_id, to_id, post_id, message)
  values (yo, otro, post, trim(p_mensaje))
  returning id into id_;
  return id_;
end;
$$;

-- Los saludos que recibí (pendientes primero) y los que mandé.
create function public.mis_saludos()
returns table (id uuid, recibido boolean, persona text, message text, post_id uuid, post_texto text,
               status text, conversation_id uuid, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select s.id, s.to_id = (select auth.uid()),
         public.primer_nombre(case when s.to_id = (select auth.uid()) then s.from_id else s.to_id end),
         s.message, s.post_id, left(p.body, 80), s.status,
         case when s.status = 'accepted' then s.conversation_id end, s.created_at
  from public.community_greetings s
  left join public.community_posts p on p.id = s.post_id
  where (s.to_id = (select auth.uid()) or s.from_id = (select auth.uid()))
    and (s.status = 'pending' or s.created_at > now() - interval '60 days')
  order by (s.status <> 'pending'), s.created_at desc
  limit 100;
$$;

create function public.saludos_pendientes()
returns integer
language sql stable security definer set search_path = ''
as $$
  select count(*)::int from public.community_greetings
  where to_id = (select auth.uid()) and status = 'pending';
$$;

-- Aceptar abre un chat entre las dos personas y devuelve su id.
create function public.responder_saludo(p_id uuid, p_aceptar boolean)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  s public.community_greetings;
  conv uuid;
begin
  select * into s from public.community_greetings where id = p_id and to_id = yo for update;
  if not found then raise exception 'No es un saludo para vos' using errcode = '42501'; end if;
  if s.status <> 'pending' then raise exception 'Cambio de estado inválido' using errcode = '22023'; end if;
  if not coalesce(p_aceptar, false) then
    update public.community_greetings set status = 'declined', responded_at = now() where id = p_id;
    return null;
  end if;
  insert into public.conversations (kind, context_id, created_by)
  values ('user', s.id, s.from_id) returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
  values (conv, s.from_id, null), (conv, yo, now());
  insert into public.messages (conversation_id, sender_id, body) values (conv, s.from_id, s.message);
  update public.community_greetings
     set status = 'accepted', responded_at = now(), conversation_id = conv
   where id = p_id;
  return conv;
end;
$$;

-- En el chat entre personas se ve solo el primer nombre del otro (D116).
create or replace function public.mis_conversaciones()
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
              when c.kind = 'user' then public.primer_nombre(otro.user_id)
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

-- ---------------------------------------------------------------------
-- Fotos: bucket público, cada uno en su carpeta (<usuario>/<archivo>)
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('community-photos', 'community-photos', true, 2097152, array['image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public, file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "subir_fotos_de_comunidad" on storage.objects for insert to authenticated
  with check (bucket_id = 'community-photos'
              and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "borrar_fotos_de_comunidad" on storage.objects for delete to authenticated
  using (bucket_id = 'community-photos' and owner_id = (select auth.uid())::text);

-- ---------------------------------------------------------------------
-- Moderación: reportes, ocultamiento automático y el portal
-- ---------------------------------------------------------------------
alter table public.flags drop constraint flags_target_type_check;
alter table public.flags add constraint flags_target_type_check
  check (target_type in ('sos', 'message', 'review', 'post', 'comment'));

create or replace function public.ocultar_con_tres_reportes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.target_type in ('sos', 'review', 'post', 'comment') and (
    select count(distinct reporter_id) from public.flags
    where target_type = new.target_type and target_id = new.target_id
  ) >= 3 then
    if new.target_type = 'sos' then
      update public.sos_reports set status = 'hidden'
      where id = new.target_id and status = 'active';
    elsif new.target_type = 'review' then
      update public.reviews set status = 'hidden'
      where id = new.target_id and status = 'active';
    elsif new.target_type = 'post' then
      update public.community_posts set status = 'hidden'
      where id = new.target_id and status = 'active';
    else
      update public.community_comments set status = 'hidden'
      where id = new.target_id and status = 'active';
    end if;
  end if;
  return new;
end;
$$;

create or replace function public.admin_moderacion()
returns table (target_type text, target_id uuid, autor_id uuid, autor_nombre text, texto text,
               estado text, reportes integer, motivos text[], ultimo_reporte timestamptz)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  return query
  select 'sos'::text, s.id, s.user_id, p.display_name,
         concat_ws(' · ', s.kind::text, s.name, s.description),
         s.status::text,
         (select count(*)::int from public.flags f where f.target_type = 'sos' and f.target_id = s.id),
         array(select f.reason from public.flags f where f.target_type = 'sos' and f.target_id = s.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'sos' and f.target_id = s.id)
  from public.sos_reports s
  left join public.profiles p on p.id = s.user_id
  where (s.status = 'hidden'
         or (s.status = 'active' and exists (select 1 from public.flags f
                                             where f.target_type = 'sos' and f.target_id = s.id)))
    and public.ve_zona(s.zone_id)
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
    and public.ve_zona(p.zone_id)
  union all
  select 'review'::text, r.id, r.user_id, p.display_name,
         concat(r.rating, '★ ', r.comment),
         r.status,
         (select count(*)::int from public.flags f where f.target_type = 'review' and f.target_id = r.id),
         array(select f.reason from public.flags f where f.target_type = 'review' and f.target_id = r.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'review' and f.target_id = r.id)
  from public.reviews r
  left join public.profiles p on p.id = r.user_id
  join public.businesses b on b.id = r.business_id
  where (r.status = 'hidden'
         or exists (select 1 from public.flags f where f.target_type = 'review' and f.target_id = r.id
                    and not exists (select 1 from public.admin_actions x
                                    where x.target_type = 'review' and x.target_id = r.id::text
                                      and x.created_at > f.created_at)))
    and public.ve_zona(b.zone_id)
  union all
  select 'post'::text, c.id, c.author_id, p.display_name,
         concat(g.name, ' · ', c.body, case when cardinality(c.photo_paths) > 0
                                            then ' · 📷 ' || cardinality(c.photo_paths) end),
         c.status,
         (select count(*)::int from public.flags f where f.target_type = 'post' and f.target_id = c.id),
         array(select f.reason from public.flags f where f.target_type = 'post' and f.target_id = c.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'post' and f.target_id = c.id)
  from public.community_posts c
  join public.community_groups g on g.id = c.group_id
  left join public.profiles p on p.id = c.author_id
  where (c.status = 'hidden'
         or exists (select 1 from public.flags f where f.target_type = 'post' and f.target_id = c.id))
    and public.ve_zona(p.zone_id)
  union all
  select 'comment'::text, c.id, c.author_id, p.display_name, c.body, c.status,
         (select count(*)::int from public.flags f where f.target_type = 'comment' and f.target_id = c.id),
         array(select f.reason from public.flags f where f.target_type = 'comment' and f.target_id = c.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'comment' and f.target_id = c.id)
  from public.community_comments c
  left join public.profiles p on p.id = c.author_id
  where (c.status = 'hidden'
         or exists (select 1 from public.flags f where f.target_type = 'comment' and f.target_id = c.id))
    and public.ve_zona(p.zone_id)
  order by 9 desc nulls last;
end;
$$;

create or replace function public.admin_moderar(p_tipo text, p_id uuid, p_accion text, p_motivo text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  perform public.exigir_zona(case p_tipo
    when 'sos' then (select s.zone_id from public.sos_reports s where s.id = p_id)
    when 'message' then (select pr.zone_id from public.messages m
                         join public.profiles pr on pr.id = m.sender_id where m.id = p_id)
    when 'review' then (select b.zone_id from public.reviews r
                        join public.businesses b on b.id = r.business_id where r.id = p_id)
    when 'post' then (select pr.zone_id from public.community_posts c
                      join public.profiles pr on pr.id = c.author_id where c.id = p_id)
    when 'comment' then (select pr.zone_id from public.community_comments c
                         join public.profiles pr on pr.id = c.author_id where c.id = p_id)
  end);
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
  elsif p_tipo = 'post' and p_accion = 'aprobar' then
    update public.community_posts set status = 'active' where id = p_id;
    delete from public.flags where target_type = 'post' and target_id = p_id;
  elsif p_tipo = 'post' and p_accion = 'eliminar' then
    delete from public.community_posts where id = p_id;
  elsif p_tipo = 'comment' and p_accion = 'aprobar' then
    update public.community_comments set status = 'active' where id = p_id;
    delete from public.flags where target_type = 'comment' and target_id = p_id;
  elsif p_tipo = 'comment' and p_accion = 'eliminar' then
    delete from public.community_comments where id = p_id;
  else
    raise exception 'Acción inválida' using errcode = '22023';
  end if;
  perform public.registrar_accion('moderar_' || p_accion, p_tipo, p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- Grupos de especie y de tema: los crea y edita la administración.
create function public.admin_guardar_grupo(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := public.exigir_equipo(array['moderator']);
  id_ uuid := (p ->> 'id')::uuid;
begin
  if id_ is null then
    insert into public.community_groups (kind, name, description, icon, species_id, sort, created_by)
    values (coalesce(p ->> 'kind', 'topic'), trim(p ->> 'name'), nullif(trim(p ->> 'description'), ''),
            nullif(trim(p ->> 'icon'), ''), (p ->> 'species_id')::smallint,
            coalesce((p ->> 'sort')::smallint, 200), yo)
    returning id into id_;
  else
    update public.community_groups
       set name = coalesce(nullif(trim(p ->> 'name'), ''), name),
           description = case when p ? 'description' then nullif(trim(p ->> 'description'), '') else description end,
           icon = case when p ? 'icon' then nullif(trim(p ->> 'icon'), '') else icon end,
           status = coalesce(p ->> 'status', status),
           sort = coalesce((p ->> 'sort')::smallint, sort)
     where id = id_;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  end if;
  perform public.registrar_accion('guardar_grupo', 'community_group', id_::text, p);
  return id_;
end;
$$;

-- Todos los grupos, también los ocultos, para el portal.
create function public.admin_grupos()
returns table (id uuid, kind text, name text, description text, icon text, status text,
               miembros integer, publicaciones integer, ocultas integer)
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_equipo(array['moderator']);
  return query
  select g.id, g.kind, g.name, g.description, g.icon, g.status,
         (select count(*)::int from public.community_members m where m.group_id = g.id),
         (select count(*)::int from public.community_posts c where c.group_id = g.id),
         (select count(*)::int from public.community_posts c where c.group_id = g.id and c.status = 'hidden')
  from public.community_groups g
  order by g.sort, g.name;
end;
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke all on function public.texto_prohibido_comunidad(text) from public;
grant execute on function public.texto_prohibido_comunidad(text) to anon, authenticated;
revoke all on function public.primer_nombre(uuid) from public, anon, authenticated;
revoke all on function public.soy_de_grupo(uuid) from public, anon;
grant execute on function public.soy_de_grupo(uuid) to authenticated;

revoke all on function public.grupos(text) from public;
revoke all on function public.publicaciones_de(uuid, timestamptz) from public;
revoke all on function public.publicacion(uuid) from public;
grant execute on function public.grupos(text) to anon, authenticated;
grant execute on function public.publicaciones_de(uuid, timestamptz) to anon, authenticated;
grant execute on function public.publicacion(uuid) to anon, authenticated;

revoke all on function public.grupo_de_raza(integer) from public, anon;
revoke all on function public.unirme_grupo(uuid, boolean) from public, anon;
revoke all on function public.publicar(uuid, text, text, text[]) from public, anon;
revoke all on function public.comentar(uuid, text) from public, anon;
revoke all on function public.borrar_de_comunidad(text, uuid) from public, anon;
revoke all on function public.saludar(text, uuid, text) from public, anon;
revoke all on function public.mis_saludos() from public, anon;
revoke all on function public.saludos_pendientes() from public, anon;
revoke all on function public.responder_saludo(uuid, boolean) from public, anon;
revoke all on function public.admin_guardar_grupo(jsonb) from public, anon;
revoke all on function public.admin_grupos() from public, anon;
grant execute on function public.grupo_de_raza(integer) to authenticated;
grant execute on function public.unirme_grupo(uuid, boolean) to authenticated;
grant execute on function public.publicar(uuid, text, text, text[]) to authenticated;
grant execute on function public.comentar(uuid, text) to authenticated;
grant execute on function public.borrar_de_comunidad(text, uuid) to authenticated;
grant execute on function public.saludar(text, uuid, text) to authenticated;
grant execute on function public.mis_saludos() to authenticated;
grant execute on function public.saludos_pendientes() to authenticated;
grant execute on function public.responder_saludo(uuid, boolean) to authenticated;
grant execute on function public.admin_guardar_grupo(jsonb) to authenticated;
grant execute on function public.admin_grupos() to authenticated;
