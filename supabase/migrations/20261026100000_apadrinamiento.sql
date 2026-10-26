-- Paso 3.4b, parte 3 (D108): apadrinamiento de refugios y ferias.
-- Un comercio verificado (que no sea un refugio) se ofrece a apadrinar a un
-- refugio verificado de su zona, o a una feria o evento de ese refugio, y dice
-- qué aporta ("Alimento para 20 perros por mes"). El refugio acepta o no; si
-- acepta, su ficha (o el evento) muestra "Apadrinado por …". Cualquiera de los
-- dos lo puede terminar. Sin dinero de por medio en la app.

create table public.shelter_sponsorships (
  id           uuid primary key default gen_random_uuid(),
  sponsor_id   uuid not null references public.businesses (id) on delete cascade,
  shelter_id   uuid not null references public.businesses (id) on delete cascade,
  event_id     uuid references public.events_calendar (id) on delete cascade,
  contribution text not null check (char_length(trim(contribution)) between 3 and 200),
  status       text not null default 'pending'
               check (status in ('pending', 'active', 'declined', 'ended')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  check (sponsor_id <> shelter_id)
);

comment on table public.shelter_sponsorships is
  'Comercios que apadrinan refugios o sus eventos. Sin acceso directo.';

-- Uno abierto (pendiente o activo) por comercio, refugio y evento.
create unique index shelter_sponsorships_uno_abierto
  on public.shelter_sponsorships (sponsor_id, shelter_id, coalesce(event_id, '00000000-0000-0000-0000-000000000000'))
  where status in ('pending', 'active');
create index shelter_sponsorships_shelter_idx on public.shelter_sponsorships (shelter_id, status);

create trigger shelter_sponsorships_updated_at
  before update on public.shelter_sponsorships
  for each row execute function public.set_updated_at();

alter table public.shelter_sponsorships enable row level security;
-- Sin políticas: todo por las funciones de abajo.
revoke all on public.shelter_sponsorships from anon, authenticated;

-- ---------------------------------------------------------------------
-- Comercio y refugio (una sola pantalla en el modo comercio)
-- ---------------------------------------------------------------------
-- Si es refugio: los ofrecimientos que recibió. Si es un comercio verificado:
-- los que hizo y los refugios verificados de su zona con sus próximos eventos.
create function public.apadrinamientos_del_negocio(p_business uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  b public.businesses;
  es_refugio boolean;
  puede boolean;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select * into b from public.businesses where id = p_business;
  es_refugio := b.business_type = 'shelter';
  puede := not es_refugio and b.verification = 'verified' and b.status = 'active';
  return jsonb_build_object(
    'es_refugio', es_refugio,
    'puede_ofrecer', puede,
    'recibidos', case when es_refugio then coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'status', s.status, 'contribution', s.contribution, 'created_at', s.created_at,
        'otro', sp.name, 'evento', e.title
      ) order by s.status <> 'pending', s.created_at desc)
      from public.shelter_sponsorships s
      join public.businesses sp on sp.id = s.sponsor_id
      left join public.events_calendar e on e.id = s.event_id
      where s.shelter_id = p_business
        and (s.status in ('pending', 'active') or s.updated_at > now() - interval '60 days')
    ), '[]'::jsonb) else '[]'::jsonb end,
    'ofrecidos', case when not es_refugio then coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', s.id, 'status', s.status, 'contribution', s.contribution, 'created_at', s.created_at,
        'otro', r.name, 'evento', e.title
      ) order by s.status not in ('pending', 'active'), s.created_at desc)
      from public.shelter_sponsorships s
      join public.businesses r on r.id = s.shelter_id
      left join public.events_calendar e on e.id = s.event_id
      where s.sponsor_id = p_business
        and (s.status in ('pending', 'active') or s.updated_at > now() - interval '60 days')
    ), '[]'::jsonb) else '[]'::jsonb end,
    'refugios', case when puede then coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', r.id, 'name', r.name, 'address', r.address,
        'eventos', coalesce((
          select jsonb_agg(jsonb_build_object('id', e.id, 'title', e.title, 'starts_at', e.starts_at)
                           order by e.starts_at)
          from public.events_calendar e
          where e.business_id = r.id and e.status = 'active' and e.ends_at > now()
        ), '[]'::jsonb)
      ) order by r.name)
      from public.businesses r
      where r.business_type = 'shelter' and r.verification = 'verified' and r.status = 'active'
        and (b.zone_id is null or r.zone_id is null or r.zone_id = b.zone_id)
    ), '[]'::jsonb) else '[]'::jsonb end);
end;
$$;

create function public.ofrecer_apadrinamiento(
  p_business uuid,
  p_refugio uuid,
  p_aporte text,
  p_evento uuid default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  id_ uuid;
begin
  if not exists (select 1 from public.businesses
                 where id = p_business and owner_id = (select auth.uid())
                   and business_type <> 'shelter' and verification = 'verified' and status = 'active') then
    raise exception 'solo_comercios_verificados' using errcode = '42501';
  end if;
  if not exists (select 1 from public.businesses
                 where id = p_refugio and business_type = 'shelter'
                   and verification = 'verified' and status = 'active') then
    raise exception 'refugio_no_disponible' using errcode = 'P0001';
  end if;
  if p_evento is not null and not exists (
    select 1 from public.events_calendar
    where id = p_evento and business_id = p_refugio and status = 'active' and ends_at > now()) then
    raise exception 'evento_no_disponible' using errcode = 'P0001';
  end if;
  if (select count(*) from public.shelter_sponsorships
      where sponsor_id = p_business and created_at > now() - interval '1 day') >= 10 then
    raise exception 'demasiados' using errcode = '54000';
  end if;
  -- Si ya hay uno abierto para lo mismo, el índice único da 23505.
  insert into public.shelter_sponsorships (sponsor_id, shelter_id, event_id, contribution)
  values (p_business, p_refugio, p_evento, trim(p_aporte))
  returning id into id_;
  return id_;
end;
$$;

-- El refugio acepta o no un ofrecimiento pendiente.
create function public.responder_apadrinamiento(p_id uuid, p_aceptar boolean)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  s public.shelter_sponsorships;
begin
  select * into s from public.shelter_sponsorships where id = p_id for update;
  if not found or not public.soy_duenio_de(s.shelter_id) then
    raise exception 'No es un ofrecimiento para tu refugio' using errcode = '42501';
  end if;
  if s.status <> 'pending' then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.shelter_sponsorships
     set status = case when coalesce(p_aceptar, false) then 'active' else 'declined' end
   where id = p_id;
end;
$$;

-- Cualquiera de los dos termina uno activo (o el comercio retira uno pendiente).
create function public.terminar_apadrinamiento(p_id uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  s public.shelter_sponsorships;
begin
  select * into s from public.shelter_sponsorships where id = p_id for update;
  if not found or not (public.soy_duenio_de(s.shelter_id) or public.soy_duenio_de(s.sponsor_id)) then
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  if not (s.status = 'active' or (s.status = 'pending' and public.soy_duenio_de(s.sponsor_id))) then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.shelter_sponsorships set status = 'ended' where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Público: quiénes apadrinan un refugio o un evento (solo nombre y aporte)
-- ---------------------------------------------------------------------
create function public.padrinos(p_business uuid default null, p_evento uuid default null)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object('name', sp.name, 'contribution', s.contribution,
                                               'business_id', sp.id)
                            order by s.created_at), '[]'::jsonb)
  from public.shelter_sponsorships s
  join public.businesses sp on sp.id = s.sponsor_id and sp.status = 'active'
  where s.status = 'active'
    and ((p_evento is not null and s.event_id = p_evento)
         or (p_evento is null and p_business is not null and s.shelter_id = p_business
             and s.event_id is null));
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke all on function public.padrinos(uuid, uuid) from public;
grant execute on function public.padrinos(uuid, uuid) to anon, authenticated;

do $$
declare
  f text;
begin
  foreach f in array array[
    'apadrinamientos_del_negocio(uuid)', 'ofrecer_apadrinamiento(uuid, uuid, text, uuid)',
    'responder_apadrinamiento(uuid, boolean)', 'terminar_apadrinamiento(uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
