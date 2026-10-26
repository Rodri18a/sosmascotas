-- Etapa 2.4 (D102): generador de propuestas y casos de éxito (05 §5 y §6).
--  · admin_propuesta(): los números para llevarle a un comercio en una visita
--    (audiencia de su zona por especie, búsquedas de su rubro, cuántos hay en
--    el mapa, su propia tracción y casos de éxito del rubro). Solo
--    administración; cada propuesta queda en admin_actions.
--  · success_stories: testimonios con números para vender. Solo
--    administración. Para publicarlo hace falta el permiso de la empresa.
--  · Grupos de menos de 5 se devuelven como null ("menos de 5"), igual que
--    "Busco veterinaria" (D81): con pocos casos se podría adivinar quién es.

create table public.success_stories (
  id            uuid primary key default gen_random_uuid(),
  business_id   uuid references public.businesses (id) on delete set null,
  business_name text not null check (char_length(trim(business_name)) between 2 and 80),
  business_type text not null check (business_type ~ '^[a-z_]{2,20}$'),
  zone_id       smallint references public.zones (id),
  quote         text not null check (char_length(trim(quote)) between 10 and 600),
  author        text check (char_length(author) <= 80),          -- "Laura, dueña"
  numbers       text check (char_length(numbers) <= 300),        -- "De 40 a 140 aperturas por mes"
  consent       boolean not null default false,                  -- la empresa autorizó usarlo
  status        text not null default 'draft' check (status in ('draft', 'published')),
  created_by    uuid default auth.uid() references auth.users (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  check (status = 'draft' or consent)
);

comment on table public.success_stories is
  'Casos de éxito para ventas (2.4, D102). Solo administración; publicado solo con el permiso de la empresa.';

create trigger success_stories_updated_at
  before update on public.success_stories
  for each row execute function public.set_updated_at();

alter table public.success_stories enable row level security;
revoke all on public.success_stories from anon, authenticated;

-- Grupos chicos: null en lugar del número.
create function public.al_menos_5(p bigint)
returns bigint
language sql immutable set search_path = ''
as $$ select case when p >= 5 then p end; $$;

create function public.admin_casos()
returns setof public.success_stories
language plpgsql stable security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return query select * from public.success_stories order by status desc, updated_at desc;
end;
$$;

create function public.admin_guardar_caso(p jsonb)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  caso_id uuid := nullif(p ->> 'id', '')::uuid;
begin
  perform public.exigir_admin();
  if caso_id is null then
    insert into public.success_stories (business_id, business_name, business_type, zone_id, quote,
                                        author, numbers, consent, status)
    values (nullif(p ->> 'business_id', '')::uuid, p ->> 'business_name', p ->> 'business_type',
            nullif(p ->> 'zone_id', '')::smallint, p ->> 'quote', nullif(trim(p ->> 'author'), ''),
            nullif(trim(p ->> 'numbers'), ''), coalesce((p ->> 'consent')::boolean, false),
            coalesce(p ->> 'status', 'draft'))
    returning id into caso_id;
  else
    update public.success_stories
       set business_id = nullif(p ->> 'business_id', '')::uuid,
           business_name = p ->> 'business_name',
           business_type = p ->> 'business_type',
           zone_id = nullif(p ->> 'zone_id', '')::smallint,
           quote = p ->> 'quote',
           author = nullif(trim(p ->> 'author'), ''),
           numbers = nullif(trim(p ->> 'numbers'), ''),
           consent = coalesce((p ->> 'consent')::boolean, false),
           status = coalesce(p ->> 'status', 'draft')
     where id = caso_id;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  end if;
  perform public.registrar_accion('guardar_caso', 'success_story', caso_id::text,
                                  jsonb_build_object('status', coalesce(p ->> 'status', 'draft')));
  return caso_id;
end;
$$;

create function public.admin_borrar_caso(p_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  delete from public.success_stories where id = p_id;
  perform public.registrar_accion('borrar_caso', 'success_story', p_id::text);
end;
$$;

-- Los datos de la propuesta. Con [p_negocio], la zona y el rubro salen del
-- comercio (si no se pasan) y se suma su tracción de los últimos [p_dias].
create function public.admin_propuesta(
  p_rubro   text default null,
  p_zona    smallint default null,
  p_negocio uuid default null,
  p_dias    integer default 30
)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  dias  integer := greatest(1, least(p_dias, 365));
  desde timestamptz := now() - make_interval(days => greatest(1, least(p_dias, 365)));
  b     record;
  rubro text := p_rubro;
  zona  smallint := p_zona;
  negocio jsonb;
begin
  perform public.exigir_admin();
  if p_negocio is not null then
    select x.id, x.name, x.business_type, x.zone_id, x.plan, x.owner_id is not null as con_duenio
      into b from public.businesses x where x.id = p_negocio;
    if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
    rubro := coalesce(rubro, b.business_type);
    zona := coalesce(zona, b.zone_id);
    negocio := jsonb_build_object(
      'nombre', b.name,
      'plan', b.plan,
      'con_duenio', b.con_duenio,
      'aperturas', (select coalesce(sum(s.value), 0) from public.daily_stats s
                    where s.business_id = p_negocio and s.metric = 'place_open' and s.day >= public.dia_uy(desde)),
      'personas', (select coalesce(sum(s.value), 0) from public.daily_stats s
                   where s.business_id = p_negocio and s.metric = 'place_open_people' and s.day >= public.dia_uy(desde)),
      'contactos', (select coalesce(sum(s.value), 0) from public.daily_stats s
                    where s.business_id = p_negocio and public.es_contacto(s.metric) and s.day >= public.dia_uy(desde)),
      'favoritos', (select count(*) from public.user_places u where u.business_id = p_negocio and u.favorite)
    );
  end if;
  if rubro is null then raise exception 'Falta el rubro' using errcode = '22023'; end if;

  return jsonb_build_object(
    'rubro', rubro,
    'dias', dias,
    'zona', (select z.name from public.zones z where z.id = zona),
    'audiencia', jsonb_build_object(
      'usuarios', public.al_menos_5((select count(*) from public.profiles pr
                                     where zona is null or pr.zone_id = zona)),
      'activos', public.al_menos_5((select count(distinct e.user_id) from public.events e
                                    where e.name = 'app_open' and e.created_at >= desde and e.user_id is not null
                                      and (zona is null or e.zone_id = zona))),
      'mascotas', coalesce((
        select jsonb_agg(jsonb_build_object('especie', s.name, 'cantidad', public.al_menos_5(t.n))
                         order by t.n desc)
        from (select pe.species_id, count(*) n
              from public.pets pe join public.profiles pr on pr.id = pe.owner_id
              where zona is null or pr.zone_id = zona
              group by 1) t
        join public.species s on s.id = t.species_id), '[]')
    ),
    'demanda', (
      select jsonb_build_object('busquedas', count(*),
                                'sin_resultados', count(*) filter (where (e.props ->> 'resultados')::int = 0))
      from public.events e
      where e.name = 'search' and e.created_at >= desde and e.props ->> 'rubro' = rubro
        and (zona is null or e.zone_id = zona)
    ),
    'oferta', (
      select jsonb_build_object('lugares', count(*),
                                'verificados', count(*) filter (where x.verification = 'verified'),
                                'pagos', count(*) filter (where x.plan <> 'basic'))
      from public.businesses x
      where x.status = 'active' and not x.is_sample and x.business_type = rubro
        and (zona is null or x.zone_id = zona)
    ),
    -- Lo que hace el rubro en la app (cuánto se abren las fichas de ese tipo).
    'rubro_aperturas', (
      select coalesce(sum(s.value), 0) from public.daily_stats s join public.businesses x on x.id = s.business_id
      where s.metric = 'place_open' and s.day >= public.dia_uy(desde) and x.business_type = rubro
        and (zona is null or s.zone_id = zona)
    ),
    'negocio', negocio,
    'casos', coalesce((
      select jsonb_agg(jsonb_build_object('comercio', c.business_name, 'cita', c.quote,
                                          'autor', c.author, 'numeros', c.numbers))
      from (select * from public.success_stories c
            where c.status = 'published' and c.business_type = rubro
            order by (c.zone_id is not distinct from zona) desc, c.updated_at desc
            limit 2) c), '[]')
  );
end;
$$;

-- Que quede quién armó propuestas para quién (no es una lectura cualquiera).
create function public.admin_registrar_propuesta(p_rubro text, p_negocio uuid default null)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform public.exigir_admin();
  perform public.registrar_accion('propuesta', 'business', coalesce(p_negocio::text, p_rubro),
                                  jsonb_build_object('rubro', p_rubro));
end;
$$;

revoke all on function public.al_menos_5(bigint) from public, anon, authenticated;
revoke all on function public.admin_casos() from public, anon;
revoke all on function public.admin_guardar_caso(jsonb) from public, anon;
revoke all on function public.admin_borrar_caso(uuid) from public, anon;
revoke all on function public.admin_propuesta(text, smallint, uuid, integer) from public, anon;
revoke all on function public.admin_registrar_propuesta(text, uuid) from public, anon;
grant execute on function public.admin_casos() to authenticated;
grant execute on function public.admin_guardar_caso(jsonb) to authenticated;
grant execute on function public.admin_borrar_caso(uuid) to authenticated;
grant execute on function public.admin_propuesta(text, smallint, uuid, integer) to authenticated;
grant execute on function public.admin_registrar_propuesta(text, uuid) to authenticated;
