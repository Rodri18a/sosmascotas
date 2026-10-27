-- Etapa 3.3 (D115): contratar paseadores, hoteles y cuidadores (03 §12).
--  · Lo ofrecen los paseadores (walker) y los hoteles y guarderías (hotel)
--    con el módulo Agenda activo (plan Plus, 06 «Módulos»): no es un módulo
--    nuevo. El prestador elige qué ofrece (paseo, guardería de día, estadía,
--    visitas a domicilio), cuántas mascotas recibe por día (guardería y
--    estadía), hasta cuántos días adelante y cuántos días seguidos como máximo.
--  · La persona pide: qué servicio, desde y hasta qué día, en qué momento del
--    día (opcional), qué mascotas (hasta 5) y una nota. El prestador acepta o
--    rechaza; **aceptar abre el chat** (el mismo de la ficha) y ahí se acuerdan
--    la dirección, el precio y el pago (directo entre las partes hasta la Fase 4).
--  · El lugar (guardería y estadía) lo calcula la base: pedir_cuidado() no
--    deja pedir días completos y responder_cuidado() lo vuelve a mirar con un
--    candado por prestador.
--  · Estados: pendiente → aceptado / rechazado; aceptado → terminado (desde
--    el primer día) o cancelado. Quien pidió cancela hasta el día anterior.
--  · El prestador ve el primer nombre, las mascotas (nombre y especie) y la
--    nota, nunca un contacto (regla 7). Nada se lee directo: todo por funciones.
--  · Avisos (Edge Function care-alert) y en vivo con Broadcast, como los
--    turnos (D104).

create table public.care_settings (
  business_id uuid primary key references public.businesses (id) on delete cascade,
  kinds       text[] not null default '{}'
              check (kinds <@ array['walk', 'daycare', 'boarding', 'home_visit']),
  capacity    smallint not null default 5 check (capacity between 1 and 50),
  days_ahead  smallint not null default 60 check (days_ahead between 7 and 180),
  max_days    smallint not null default 15 check (max_days between 1 and 60),
  conditions  text check (char_length(conditions) <= 300),
  updated_at  timestamptz not null default now()
);

comment on table public.care_settings is
  'Qué ofrece el paseador, hotel o cuidador (3.3, D115). Sin acceso directo: mis_ajustes_cuidados(), guardar_cuidados().';

create trigger care_settings_updated_at
  before update on public.care_settings
  for each row execute function public.set_updated_at();

create table public.care_requests (
  id              uuid primary key default gen_random_uuid(),
  business_id     uuid not null references public.businesses (id) on delete cascade,
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  pet_ids         uuid[] not null check (cardinality(pet_ids) between 1 and 5),
  kind            text not null check (kind in ('walk', 'daycare', 'boarding', 'home_visit')),
  start_day       date not null,
  end_day         date not null,
  time_slot       text check (time_slot in ('morning', 'afternoon', 'evening')),
  note            text check (char_length(note) <= 300),
  status          text not null default 'pending'
                  check (status in ('pending', 'accepted', 'rejected', 'cancelled', 'done')),
  cancelled_by    text check (cancelled_by in ('cliente', 'negocio')),
  conversation_id uuid references public.conversations (id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  check (end_day >= start_day)
);

comment on table public.care_requests is
  'Pedidos de paseo, guardería, estadía o visitas (3.3, D115). Sin acceso directo: pedir_cuidado(), mis_cuidados(), cuidados_del_negocio().';

create index care_requests_business_idx on public.care_requests (business_id, start_day);
create index care_requests_user_idx on public.care_requests (user_id, start_day);

create trigger care_requests_updated_at
  before update on public.care_requests
  for each row execute function public.set_updated_at();

create table public.care_notifications (
  request_id  uuid not null references public.care_requests (id) on delete cascade,
  kind        text not null,     -- un estado
  notified_at timestamptz not null default now(),
  primary key (request_id, kind)
);

comment on table public.care_notifications is 'Avisos push ya mandados por pedido de cuidado (3.3, D115). Solo service_role.';

alter table public.care_settings enable row level security;
alter table public.care_requests enable row level security;
alter table public.care_notifications enable row level security;
revoke all on public.care_settings, public.care_requests, public.care_notifications from anon, authenticated;

-- ---------------------------------------------------------------------
-- Quién ofrece y cuánto lugar queda
-- ---------------------------------------------------------------------

-- Paseador u hotel con la agenda activa y algo ofrecido.
create function public.ofrece_cuidados(p_negocio uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select public.modulo_activo(p_negocio, 'agenda')
     and exists (select 1 from public.businesses b where b.id = p_negocio and b.business_type in ('walker', 'hotel'))
     and exists (select 1 from public.care_settings c where c.business_id = p_negocio and cardinality(c.kinds) > 0);
$$;

-- Mascotas aceptadas por día (guardería y estadía) entre dos fechas, sin
-- contar el pedido [p_salvo].
create function public.ocupacion_cuidados(p_negocio uuid, p_desde date, p_hasta date, p_salvo uuid default null)
returns table (dia date, mascotas integer)
language sql stable security definer set search_path = ''
as $$
  select d::date, coalesce(sum(cardinality(r.pet_ids)), 0)::integer
  from generate_series(p_desde, p_hasta, interval '1 day') d
  left join public.care_requests r
    on r.business_id = p_negocio and r.status = 'accepted' and r.kind in ('daycare', 'boarding')
   and d::date between r.start_day and r.end_day
   and r.id is distinct from p_salvo
  group by d
  order by d;
$$;

-- Lo que se puede pedir (también para visitantes): null si no ofrece nada.
create function public.condiciones_cuidados(p_negocio uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  c public.care_settings;
  hoy date := public.dia_uy(now());
begin
  if not public.ofrece_cuidados(p_negocio) then return null; end if;
  select * into c from public.care_settings where business_id = p_negocio;
  return jsonb_build_object(
    'kinds', to_jsonb(c.kinds),
    'days_ahead', c.days_ahead,
    'max_days', c.max_days,
    'conditions', c.conditions,
    'completos', coalesce((select jsonb_agg(o.dia order by o.dia)
                           from public.ocupacion_cuidados(p_negocio, hoy, hoy + c.days_ahead) o
                           where o.mascotas >= c.capacity), '[]')
  );
end;
$$;

-- ---------------------------------------------------------------------
-- Pedir, responder y cambiar el estado
-- ---------------------------------------------------------------------
create function public.pedir_cuidado(
  p_negocio  uuid,
  p_tipo     text,
  p_desde    date,
  p_hasta    date,
  p_mascotas uuid[],
  p_franja   text default null,
  p_nota     text default null
)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  c public.care_settings;
  hoy date := public.dia_uy(now());
  n integer := cardinality(p_mascotas);
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if not public.ofrece_cuidados(p_negocio) then
    raise exception 'No toma pedidos de cuidado' using errcode = '42501';
  end if;
  select * into c from public.care_settings where business_id = p_negocio;
  if not (p_tipo = any (c.kinds)) then
    raise exception 'No ofrece ese servicio' using errcode = '22023';
  end if;
  if p_desde is null or p_hasta is null or p_desde < hoy or p_hasta < p_desde
     or p_desde > hoy + c.days_ahead or p_hasta - p_desde + 1 > c.max_days then
    raise exception 'Fechas fuera de lo que se puede pedir' using errcode = '22023';
  end if;
  if p_franja is not null and p_franja not in ('morning', 'afternoon', 'evening') then
    raise exception 'Momento del día inválido' using errcode = '22023';
  end if;
  if n is null or n not between 1 and 5
     or (select count(distinct m) from unnest(p_mascotas) m) <> n
     or exists (select 1 from unnest(p_mascotas) m where not public.puedo_cuidar(m)) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  if (select count(*) from public.care_requests where user_id = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados pedidos hoy' using errcode = '54000';
  end if;
  if (select count(*) from public.care_requests where user_id = yo and business_id = p_negocio
        and status in ('pending', 'accepted') and end_day >= hoy) >= 3 then
    raise exception 'Ya tenés 3 pedidos con este prestador' using errcode = '54000';
  end if;
  if p_tipo in ('daycare', 'boarding') and exists (
    select 1 from public.ocupacion_cuidados(p_negocio, p_desde, p_hasta) o where o.mascotas + n > c.capacity) then
    raise exception 'No hay lugar en esas fechas' using errcode = '22023';
  end if;
  insert into public.care_requests (business_id, user_id, pet_ids, kind, start_day, end_day, time_slot, note)
  values (p_negocio, yo, p_mascotas, p_tipo, p_desde, p_hasta, p_franja, nullif(left(trim(p_nota), 300), ''))
  returning id into id_;
  return id_;
end;
$$;

-- Aceptar abre (o reusa) el chat con quien pidió y devuelve su id; rechazar
-- devuelve null.
create function public.responder_cuidado(p_id uuid, p_aceptar boolean)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  r public.care_requests;
  c public.care_settings;
  dueno uuid;
  conv uuid;
begin
  select * into r from public.care_requests where id = p_id;
  if not found or not public.soy_duenio_de(r.business_id) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if r.status <> 'pending' then
    raise exception 'Cambio de estado inválido' using errcode = '22023';
  end if;
  if not coalesce(p_aceptar, false) then
    update public.care_requests set status = 'rejected' where id = p_id;
    return null;
  end if;
  if r.end_day < public.dia_uy(now()) then
    raise exception 'Esas fechas ya pasaron' using errcode = '22023';
  end if;
  -- Un pedido por vez en cada prestador: el lugar se vuelve a mirar con el candado.
  perform pg_advisory_xact_lock(hashtextextended('cuidados:' || r.business_id::text, 0));
  select * into c from public.care_settings where business_id = r.business_id;
  if r.kind in ('daycare', 'boarding') and exists (
    select 1 from public.ocupacion_cuidados(r.business_id, r.start_day, r.end_day, r.id) o
    where o.mascotas + cardinality(r.pet_ids) > coalesce(c.capacity, 0)) then
    raise exception 'No hay lugar en esas fechas' using errcode = '22023';
  end if;
  select owner_id into dueno from public.businesses where id = r.business_id;
  -- El mismo chat que si la persona le escribiera desde la ficha.
  select id into conv from public.conversations
  where kind = 'business' and context_id = r.business_id and created_by = r.user_id;
  if conv is null then
    insert into public.conversations (kind, context_id, created_by)
    values ('business', r.business_id, r.user_id) returning id into conv;
    insert into public.conversation_members (conversation_id, user_id, last_read_at)
    values (conv, r.user_id, null), (conv, dueno, now());
  end if;
  update public.care_requests set status = 'accepted', conversation_id = conv where id = p_id;
  return conv;
end;
$$;

create function public.cambiar_estado_cuidado(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  r public.care_requests;
  hoy date := public.dia_uy(now());
  quien text;
begin
  select * into r from public.care_requests where id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if public.soy_duenio_de(r.business_id) then
    if not ((r.status = 'accepted' and p_estado = 'cancelled')
            or (r.status = 'accepted' and p_estado = 'done' and r.start_day <= hoy)) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
    quien := 'negocio';
  elsif r.user_id = yo then
    if not (p_estado = 'cancelled' and r.status in ('pending', 'accepted')) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
    if r.status = 'accepted' and r.start_day <= hoy then
      raise exception 'Se cancela hasta el día anterior' using errcode = '22023';
    end if;
    quien := 'cliente';
  else
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  update public.care_requests
     set status = p_estado,
         cancelled_by = case when p_estado = 'cancelled' then quien end
   where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Listas
-- ---------------------------------------------------------------------
create function public.mis_cuidados()
returns table (id uuid, business_id uuid, business_name text, kind text, start_day date, end_day date,
               time_slot text, pets text[], status text, cancelled_by text, note text, conversation_id uuid)
language sql stable security definer set search_path = ''
as $$
  select r.id, r.business_id, b.name, r.kind, r.start_day, r.end_day, r.time_slot,
         array(select p.name from unnest(r.pet_ids) with ordinality m(id, i)
               join public.pets p on p.id = m.id order by m.i),
         r.status, r.cancelled_by, r.note,
         case when r.status in ('accepted', 'done') then r.conversation_id end
  from public.care_requests r
  join public.businesses b on b.id = r.business_id
  where r.user_id = (select auth.uid())
    and r.end_day > public.dia_uy(now()) - 30
  order by (r.end_day < public.dia_uy(now())), r.start_day;
$$;

create function public.cuidados_del_negocio(p_negocio uuid)
returns table (id uuid, cliente text, pets text[], kind text, start_day date, end_day date,
               time_slot text, status text, cancelled_by text, note text, conversation_id uuid)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select r.id, split_part(coalesce(pr.display_name, ''), ' ', 1),
         array(select p.name || coalesce(' (' || s.name || ')', '')
               from unnest(r.pet_ids) with ordinality m(id, i)
               join public.pets p on p.id = m.id
               left join public.species s on s.id = p.species_id
               order by m.i),
         r.kind, r.start_day, r.end_day, r.time_slot, r.status, r.cancelled_by, r.note,
         case when r.status in ('accepted', 'done') then r.conversation_id end
  from public.care_requests r
  left join public.profiles pr on pr.id = r.user_id
  where r.business_id = p_negocio
    and r.end_day >= public.dia_uy(now()) - 30
  order by (r.status <> 'pending'), r.start_day
  limit 300;
end;
$$;

create function public.cuidados_pendientes(p_negocio uuid)
returns integer
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return (select count(*) from public.care_requests
          where business_id = p_negocio and status = 'pending' and end_day >= public.dia_uy(now()));
end;
$$;

-- ---------------------------------------------------------------------
-- Configuración (el dueño, con Plus)
-- ---------------------------------------------------------------------
create function public.mis_ajustes_cuidados(p_negocio uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  c public.care_settings;
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select * into c from public.care_settings where business_id = p_negocio;
  return jsonb_build_object(
    'kinds', coalesce(to_jsonb(c.kinds), '[]'),
    'capacity', coalesce(c.capacity, 5),
    'days_ahead', coalesce(c.days_ahead, 60),
    'max_days', coalesce(c.max_days, 15),
    'conditions', c.conditions
  );
end;
$$;

create function public.guardar_cuidados(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if not exists (select 1 from public.businesses where id = p_negocio and plan = 'plus'
                 and business_type in ('walker', 'hotel')) then
    raise exception 'Es para paseadores y hoteles con plan Plus' using errcode = '42501';
  end if;
  insert into public.care_settings as c (business_id, kinds, capacity, days_ahead, max_days, conditions)
  values (p_negocio,
          case when jsonb_typeof(p -> 'kinds') = 'array'
               then array(select distinct jsonb_array_elements_text(p -> 'kinds')) else '{}' end,
          coalesce((p ->> 'capacity')::smallint, 5),
          coalesce((p ->> 'days_ahead')::smallint, 60),
          coalesce((p ->> 'max_days')::smallint, 15),
          nullif(left(trim(p ->> 'conditions'), 300), ''))
  on conflict (business_id) do update
     set kinds = excluded.kinds, capacity = excluded.capacity, days_ahead = excluded.days_ahead,
         max_days = excluded.max_days, conditions = excluded.conditions;
end;
$$;

-- ---------------------------------------------------------------------
-- Avisos
-- ---------------------------------------------------------------------

-- A quién avisar del estado actual del pedido (como avisar_turno(), D104).
create function public.avisar_cuidado(p_pedido uuid, p_actor uuid)
returns table (destino text, estado text, tipo text, negocio text, desde date, hasta date,
               mascotas text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  r record;
  receptor uuid;
  para text;
begin
  select x.status, x.user_id, x.cancelled_by, x.kind, x.start_day, x.end_day, x.pet_ids, b.owner_id, b.name into r
  from public.care_requests x join public.businesses b on b.id = x.business_id
  where x.id = p_pedido;
  if not found then return; end if;
  if p_actor = r.user_id and (r.status = 'pending' or (r.status = 'cancelled' and r.cancelled_by = 'cliente')) then
    receptor := r.owner_id;
    para := 'negocio';
  elsif p_actor = r.owner_id
        and (r.status in ('accepted', 'rejected') or (r.status = 'cancelled' and r.cancelled_by = 'negocio')) then
    receptor := r.user_id;
    para := 'cliente';
  end if;
  if receptor is null or receptor = p_actor then return; end if;
  insert into public.care_notifications (request_id, kind) values (p_pedido, r.status) on conflict do nothing;
  if not found then return; end if;
  return query
  select para, r.status, r.kind, r.name, r.start_day, r.end_day,
         (select string_agg(p.name, ', ') from public.pets p where p.id = any (r.pet_ids)),
         array(select t.token from public.push_tokens t where t.user_id = receptor);
end;
$$;

-- ---------------------------------------------------------------------
-- En vivo
-- ---------------------------------------------------------------------
create function public.puedo_escuchar_cuidados(p_canal text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when p_canal = 'cuidados:cliente:' || (select auth.uid())::text then true
    when p_canal ~ '^cuidados:negocio:[0-9a-f-]{36}$'
      then public.soy_duenio_de(substr(p_canal, 18)::uuid)
    else false
  end;
$$;

create policy "cuidados en vivo: cada uno los suyos"
  on realtime.messages for select to authenticated
  using (realtime.messages.extension = 'broadcast'
         and public.puedo_escuchar_cuidados((select realtime.topic())));

create function public.difundir_cuidado()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  carga jsonb := jsonb_build_object('id', new.id, 'status', new.status);
begin
  begin
    perform realtime.send(carga, 'cuidado', 'cuidados:cliente:' || new.user_id::text, true);
    perform realtime.send(carga, 'cuidado', 'cuidados:negocio:' || new.business_id::text, true);
  exception when others then
    raise warning 'No se pudo difundir el pedido de cuidado %: %', new.id, sqlerrm;
  end;
  return null;
end;
$$;

create trigger care_requests_difundir
  after insert or update of status on public.care_requests
  for each row execute function public.difundir_cuidado();

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke all on function public.ofrece_cuidados(uuid) from public, anon, authenticated;
revoke all on function public.ocupacion_cuidados(uuid, date, date, uuid) from public, anon, authenticated;
revoke all on function public.avisar_cuidado(uuid, uuid) from public, anon, authenticated;
revoke all on function public.difundir_cuidado() from public, anon, authenticated;
grant execute on function public.avisar_cuidado(uuid, uuid) to service_role;

revoke all on function public.condiciones_cuidados(uuid) from public;
grant execute on function public.condiciones_cuidados(uuid) to anon, authenticated;

revoke all on function public.pedir_cuidado(uuid, text, date, date, uuid[], text, text) from public, anon;
revoke all on function public.responder_cuidado(uuid, boolean) from public, anon;
revoke all on function public.cambiar_estado_cuidado(uuid, text) from public, anon;
revoke all on function public.mis_cuidados() from public, anon;
revoke all on function public.cuidados_del_negocio(uuid) from public, anon;
revoke all on function public.cuidados_pendientes(uuid) from public, anon;
revoke all on function public.mis_ajustes_cuidados(uuid) from public, anon;
revoke all on function public.guardar_cuidados(uuid, jsonb) from public, anon;
revoke all on function public.puedo_escuchar_cuidados(text) from public, anon;
grant execute on function public.pedir_cuidado(uuid, text, date, date, uuid[], text, text) to authenticated;
grant execute on function public.responder_cuidado(uuid, boolean) to authenticated;
grant execute on function public.cambiar_estado_cuidado(uuid, text) to authenticated;
grant execute on function public.mis_cuidados() to authenticated;
grant execute on function public.cuidados_del_negocio(uuid) to authenticated;
grant execute on function public.cuidados_pendientes(uuid) to authenticated;
grant execute on function public.mis_ajustes_cuidados(uuid) to authenticated;
grant execute on function public.guardar_cuidados(uuid, jsonb) to authenticated;
grant execute on function public.puedo_escuchar_cuidados(text) to authenticated;
