-- Etapa 2.8c (D87): reacciones en Noticias y perdidas activas en Comunidad.
--  · Reacciones fijas (❤️ me alegra, 🎉 qué bueno, 🙏 gracias), sin
--    comentarios: no hay texto libre que moderar ni por donde pasar datos.
--    Una por persona y por noticia o novedad; se puede cambiar o quitar.
--    Se muestran solo los totales (nunca quién reaccionó).
--  · Las mascotas perdidas que se siguen buscando aparecen en Comunidad
--    (ya eran públicas en el mapa y la lista, D84), sin ubicación, para
--    entrar al reporte y "Seguirlo" (D74). No llevan reacciones.

create table public.news_reactions (
  id          uuid primary key default gen_random_uuid(),
  news_id     uuid references public.news (id) on delete cascade,
  update_id   uuid references public.community_updates (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  kind        text not null check (kind in ('alegra', 'festejo', 'gracias')),
  created_at  timestamptz not null default now(),
  check (num_nonnulls(news_id, update_id) = 1),
  unique (news_id, user_id),
  unique (update_id, user_id)
);

comment on table public.news_reactions is
  'Reacciones a noticias y novedades de la comunidad (D87). Solo se muestran los totales.';

create index news_reactions_update_idx on public.news_reactions (update_id) where update_id is not null;

alter table public.news_reactions enable row level security;
-- Sin políticas a propósito: se usa con reaccionar() y reacciones().
revoke all on public.news_reactions from anon, authenticated;

-- Reaccionar (p_tipo) o quitar la reacción (p_tipo null) a una noticia
-- publicada o a una novedad visible.
create function public.reaccionar(p_id uuid, p_tipo text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  es_noticia boolean;
begin
  if yo is null then
    raise exception 'Hay que ingresar' using errcode = '42501';
  end if;
  if p_tipo is not null and p_tipo not in ('alegra', 'festejo', 'gracias') then
    raise exception 'Reacción inválida' using errcode = '22023';
  end if;
  if exists (select 1 from public.news where id = p_id and status = 'published') then
    es_noticia := true;
  elsif exists (select 1 from public.community_updates where id = p_id and status = 'visible') then
    es_noticia := false;
  else
    raise exception 'No existe' using errcode = 'P0002';
  end if;

  delete from public.news_reactions
  where user_id = yo and (news_id = p_id or update_id = p_id);
  if p_tipo is null then
    return;
  end if;
  insert into public.news_reactions (news_id, update_id, user_id, kind)
  values (case when es_noticia then p_id end, case when not es_noticia then p_id end, yo, p_tipo);
  insert into public.events (name, anon_id, user_id, target_id, props)
  values ('news_reaction', gen_random_uuid(), yo, p_id::text,
          jsonb_build_object('tipo', p_tipo, 'origen', case when es_noticia then 'noticia' else 'comunidad' end));
end;
$$;

-- Totales por noticia o novedad (hasta 100 de una vez) y la mía, si hay
-- sesión. Visitantes incluidos: solo números.
create function public.reacciones(p_ids uuid[])
returns table (id uuid, alegra integer, festejo integer, gracias integer, mia text)
language sql stable security definer set search_path = ''
as $$
  select coalesce(r.news_id, r.update_id),
         (count(*) filter (where r.kind = 'alegra'))::integer,
         (count(*) filter (where r.kind = 'festejo'))::integer,
         (count(*) filter (where r.kind = 'gracias'))::integer,
         max(r.kind) filter (where r.user_id = (select auth.uid()))
  from public.news_reactions r
  where coalesce(r.news_id, r.update_id) = any (p_ids[1:100])
  group by 1;
$$;

-- Cuántas personas reaccionaron al reencuentro que compartí (para el autor).
create function public.reacciones_de_mi_reencuentro(p_sos uuid)
returns integer
language sql stable security definer set search_path = ''
as $$
  select count(*)::integer
  from public.news_reactions x
  join public.community_updates u on u.id = x.update_id
  join public.sos_reports r on r.id = u.sos_id
  where u.sos_id = p_sos and r.user_id = (select auth.uid());
$$;

-- ---------------------------------------------------------------------
-- Novedades: ahora con el origen (para abrirlo) y las perdidas activas
-- ---------------------------------------------------------------------

drop function public.novedades_comunidad();

create function public.novedades_comunidad()
returns table (id uuid, kind text, origin_id uuid, name text, detail text, species_id smallint,
               amount smallint, starts_at timestamptz, photo_path text, created_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  (
    select u.id, u.kind, coalesce(u.sos_id, u.adoption_id, u.business_id, u.event_id),
           u.name, u.detail, u.species_id, u.amount, u.starts_at, u.photo_path, u.created_at
    from public.community_updates u
    left join public.sos_reports s on s.id = u.sos_id
    left join public.adoptions a on a.id = u.adoption_id
    left join public.businesses b on b.id = u.business_id
    left join public.events_calendar e on e.id = u.event_id
    where u.status = 'visible'
      and u.created_at > now() - interval '90 days'
      and (u.sos_id is null or s.status = 'resolved')
      and (u.adoption_id is null or a.status = 'adopted')
      and (u.business_id is null or (b.status = 'active' and b.verification = 'verified'))
      and (u.event_id is null or e.status = 'active')
    order by u.created_at desc
    limit 40
  )
  union all
  (
    -- Perdidas que se siguen buscando (últimos 30 días): sin ubicación.
    select r.id, 'perdida', r.id, r.name, null, r.species_id,
           least(greatest(extract(day from now() - r.happened_at), 0), 365)::smallint,
           null::timestamptz,
           (select ph.path from public.sos_photos ph where ph.report_id = r.id order by ph.sort limit 1),
           r.created_at
    from public.sos_reports r
    where r.kind = 'lost' and r.status = 'active' and r.created_at > now() - interval '30 days'
    order by r.created_at desc
    limit 10
  )
  order by 10 desc;
$$;

revoke all on function public.novedades_comunidad() from public;
grant execute on function public.novedades_comunidad() to anon, authenticated;
revoke all on function public.reaccionar(uuid, text) from public, anon;
grant execute on function public.reaccionar(uuid, text) to authenticated;
revoke all on function public.reacciones(uuid[]) from public;
grant execute on function public.reacciones(uuid[]) to anon, authenticated;
revoke all on function public.reacciones_de_mi_reencuentro(uuid) from public, anon;
grant execute on function public.reacciones_de_mi_reencuentro(uuid) to authenticated;
