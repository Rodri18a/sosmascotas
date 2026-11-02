-- Plan de mejoras 3.1 (D136): promociones de los comercios en el muro.
-- Los comercios Destacado (1 vigente) y Plus (2 vigentes) publican una
-- promoción con título, texto, una foto de su ficha y fecha de fin (hasta
-- 30 días). En Inicio se intercalan, marcadas «Promocionado», las de los
-- comercios a 15 km o menos, rotando. Si el comercio vuelve al plan básico,
-- dejan de verse solas (no se borran). Se reportan como el resto: con 3
-- reportes se ocultan y pasan a Moderación. Nunca en SOS ni en el QR.

create table public.promotions (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  title        text not null check (char_length(trim(title)) between 3 and 60),
  body         text not null check (char_length(trim(body)) between 3 and 200),
  -- Una de las fotos de la ficha (business_photos.path), o ninguna.
  photo_path   text check (char_length(photo_path) <= 200),
  ends_at      timestamptz not null,
  status       text not null default 'active' check (status in ('active', 'ended', 'hidden')),
  created_by   uuid default auth.uid() references auth.users (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  check (ends_at > created_at and ends_at <= created_at + interval '31 days')
);

comment on table public.promotions is
  'Promociones de comercios Destacado y Plus en el muro (D136). Solo por funciones.';

create index promotions_business_idx on public.promotions (business_id, status);

alter table public.promotions enable row level security;
-- Sin políticas: se lee y se escribe con las funciones de abajo.
revoke all on public.promotions from anon, authenticated;

create trigger promotions_updated_at
  before update on public.promotions
  for each row execute function public.set_updated_at();

-- Cuántas promociones vigentes permite el plan.
create function public.promos_del_plan(p_plan text)
returns integer
language sql immutable set search_path = ''
as $$
  select case p_plan when 'featured' then 1 when 'plus' then 2 else 0 end;
$$;

-- Las promociones de mi negocio (para el panel), vigentes primero.
create function public.mis_promociones(p_negocio uuid)
returns table (id uuid, title text, body text, photo_path text, ends_at timestamptz,
               status text, vigente boolean, created_at timestamptz)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select p.id, p.title, p.body, p.photo_path, p.ends_at, p.status,
         p.status = 'active' and p.ends_at > now(), p.created_at
  from public.promotions p
  where p.business_id = p_negocio
  order by (p.status = 'active' and p.ends_at > now()) desc, p.created_at desc
  limit 20;
end;
$$;

-- Crea o edita una promoción (titular o equipo). p: {id?, business_id,
-- title, body, photo_path?, dias (1..30)}.
create function public.guardar_promocion(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  negocio uuid := (p ->> 'business_id')::uuid;
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  plan_ text;
  dias integer := coalesce((p ->> 'dias')::integer, 30);
  foto text := nullif(p ->> 'photo_path', '');
begin
  if not public.soy_duenio_de(negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select b.plan::text into plan_ from public.businesses b where b.id = negocio and b.status = 'active';
  if public.promos_del_plan(plan_) = 0 then
    raise exception 'Las promociones son de Destacado y Plus' using errcode = '42501';
  end if;
  if dias < 1 or dias > 30 then
    raise exception 'De 1 a 30 días' using errcode = '22023';
  end if;
  if foto is not null and not exists (select 1 from public.business_photos
                                      where business_id = negocio and path = foto) then
    raise exception 'La foto tiene que ser de la ficha' using errcode = '22023';
  end if;
  if id_ is null then
    if (select count(*) from public.promotions
        where business_id = negocio and status = 'active' and ends_at > now())
       >= public.promos_del_plan(plan_) then
      raise exception 'Llegaste al máximo de promociones de tu plan' using errcode = '54000';
    end if;
    insert into public.promotions (business_id, title, body, photo_path, ends_at)
    values (negocio, trim(p ->> 'title'), trim(p ->> 'body'), foto, now() + make_interval(days => dias))
    returning id into id_;
  else
    -- Editar no extiende más allá de 30 días desde que se creó.
    update public.promotions
       set title = trim(p ->> 'title'), body = trim(p ->> 'body'), photo_path = foto,
           ends_at = least(now() + make_interval(days => dias), created_at + interval '30 days')
     where id = id_ and business_id = negocio and status = 'active';
    if not found then
      raise exception 'No existe o ya terminó' using errcode = 'P0002';
    end if;
  end if;
  return id_;
end;
$$;

-- La termina antes de tiempo.
create function public.terminar_promocion(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  update public.promotions set status = 'ended'
   where id = p_id and status = 'active'
     and public.soy_duenio_de(business_id);
  if not found then
    raise exception 'No existe o no es tuya' using errcode = '42501';
  end if;
end;
$$;

-- Para el muro: hasta [p_limite] promociones vigentes de comercios Destacado
-- o Plus a [p_km] o menos del punto, en un orden que rota cada hora.
create function public.promociones_cerca(p_lat double precision, p_lng double precision,
                                         p_km double precision default 15, p_limite integer default 3)
returns table (id uuid, business_id uuid, negocio text, title text, body text, photo_path text)
language sql stable security definer set search_path = ''
as $$
  select p.id, b.id, b.name, p.title, p.body, p.photo_path
  from public.promotions p
  join public.businesses b on b.id = p.business_id
  where p.status = 'active' and p.ends_at > now()
    and b.status = 'active' and b.plan::text in ('featured', 'plus')
    and b.location is not null
    and extensions.st_dwithin(
          b.location,
          extensions.st_point(p_lng, p_lat)::extensions.geography,
          least(greatest(p_km, 1), 50) * 1000)
  -- Rota: el orden cambia cada hora, igual para todos.
  order by md5(p.id::text || to_char(now(), 'YYYYMMDDHH24'))
  limit least(greatest(p_limite, 1), 5);
$$;

revoke all on function public.promos_del_plan(text) from public, anon, authenticated;
revoke all on function public.mis_promociones(uuid) from public, anon;
revoke all on function public.guardar_promocion(jsonb) from public, anon;
revoke all on function public.terminar_promocion(uuid) from public, anon;
revoke all on function public.promociones_cerca(double precision, double precision, double precision, integer) from public;
grant execute on function public.mis_promociones(uuid) to authenticated;
grant execute on function public.guardar_promocion(jsonb) to authenticated;
grant execute on function public.terminar_promocion(uuid) to authenticated;
grant execute on function public.promociones_cerca(double precision, double precision, double precision, integer) to anon, authenticated;

-- ---------------------------------------------------------------------
-- Reportes y moderación: como la comunidad, con 3 reportes se oculta.
-- ---------------------------------------------------------------------
alter table public.flags drop constraint flags_target_type_check;
alter table public.flags add constraint flags_target_type_check
  check (target_type in ('sos', 'message', 'review', 'post', 'comment', 'promo'));

create or replace function public.ocultar_con_tres_reportes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.target_type in ('sos', 'review', 'post', 'comment', 'promo') and (
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
    elsif new.target_type = 'promo' then
      update public.promotions set status = 'hidden'
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
  union all
  -- Promociones del muro (D136): el autor es el titular del comercio.
  select 'promo'::text, pr.id, b.owner_id, b.name,
         concat(pr.title, ' · ', pr.body),
         pr.status,
         (select count(*)::int from public.flags f where f.target_type = 'promo' and f.target_id = pr.id),
         array(select f.reason from public.flags f where f.target_type = 'promo' and f.target_id = pr.id and f.reason is not null),
         (select max(f.created_at) from public.flags f where f.target_type = 'promo' and f.target_id = pr.id)
  from public.promotions pr
  join public.businesses b on b.id = pr.business_id
  where (pr.status = 'hidden'
         or exists (select 1 from public.flags f where f.target_type = 'promo' and f.target_id = pr.id))
    and public.ve_zona(b.zone_id)
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
    when 'promo' then (select b.zone_id from public.promotions x
                       join public.businesses b on b.id = x.business_id where x.id = p_id)
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
  elsif p_tipo = 'promo' and p_accion = 'aprobar' then
    update public.promotions set status = 'active' where id = p_id and status = 'hidden';
    delete from public.flags where target_type = 'promo' and target_id = p_id;
  elsif p_tipo = 'promo' and p_accion = 'eliminar' then
    update public.promotions set status = 'ended' where id = p_id;
  else
    raise exception 'Acción inválida' using errcode = '22023';
  end if;
  perform public.registrar_accion('moderar_' || p_accion, p_tipo, p_id::text,
                                  jsonb_build_object('motivo', p_motivo));
end;
$$;

-- ---------------------------------------------------------------------
-- Estadísticas: vistas y toques de la promoción cuentan para el comercio.
-- ---------------------------------------------------------------------
create or replace function public.contar_eventos_comercio(p_desde timestamptz, p_hasta timestamptz, p_business uuid default null)
returns table (business_id uuid, day date, metric text, value integer)
language sql stable security definer set search_path = ''
as $$
  select e.business_id, public.dia_uy(e.created_at),
         case when e.name = 'place_click'
              then 'place_click:' || coalesce(nullif(regexp_replace(lower(e.props ->> 'tipo'), '[^a-z0-9_]', '', 'g'), ''), 'otro')
              else e.name end,
         count(*)::integer
  from public.events e
  where e.business_id is not null
    and (p_business is null or e.business_id = p_business)
    and e.created_at >= p_desde and e.created_at < p_hasta
    and e.name in ('place_open', 'place_click', 'favorite_add', 'place_visit', 'chat_start',
                   'catalog_open', 'catalog_ask', 'service_ask', 'business_page_open',
                   'order_create', 'review_create', 'promo_view', 'promo_click')
  group by 1, 2, 3
  union all
  select e.business_id, public.dia_uy(e.created_at), 'place_open_people', count(distinct e.anon_id)::integer
  from public.events e
  where e.business_id is not null
    and (p_business is null or e.business_id = p_business)
    and e.created_at >= p_desde and e.created_at < p_hasta
    and e.name = 'place_open'
  group by 1, 2;
$$;

-- Funcionalidad gradual (D64): prendida para todos.
insert into public.feature_flags (key, description, stage)
values ('promociones', 'Promociones de comercios Destacado y Plus en el muro (plan de mejoras 3.1, D136)', 'todos')
on conflict (key) do nothing;
