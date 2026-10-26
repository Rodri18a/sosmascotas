-- Etapa 3.1 (D104): agenda de turnos (03 §12, 06 «Módulos»).
--  · El comercio (plan Plus, tipo que admite agenda, módulo prendido) define
--    la duración de cada turno, cuántos atiende a la vez, con cuánta
--    anticipación y hasta cuántos días adelante se reserva, el horario (si no,
--    el del comercio), qué servicios se reservan y los días que no atiende.
--  · Los horarios libres los calcula la base (horarios_libres(), también
--    para visitantes); reservar_turno() vuelve a comprobarlo con un candado
--    por comercio, así dos personas no se llevan el mismo horario.
--  · Estados: pendiente → confirmado / rechazado; confirmado → atendido o
--    cancelado. Quien reservó cancela hasta 2 horas antes.
--  · El comercio ve el primer nombre, la mascota y la especie, nunca un
--    contacto (regla 7). Nada se lee directo: todo por funciones.
--  · Avisos (Edge Function booking-alert): push a la otra parte en cada cambio
--    (avisar_turno(), una vez por turno y estado) y recordatorio el día
--    anterior a las 18:00 (pg_cron + pg_net, turnos_para_recordar()).
--  · En vivo: Broadcast desde la base, como los pedidos (D100).

create table public.agenda_settings (
  business_id  uuid primary key references public.businesses (id) on delete cascade,
  slot_min     smallint not null default 30 check (slot_min between 10 and 240),
  capacity     smallint not null default 1 check (capacity between 1 and 10),
  notice_min   integer not null default 120 check (notice_min between 0 and 10080),
  days_ahead   smallint not null default 30 check (days_ahead between 1 and 90),
  hours        jsonb check (hours is null or public.horario_valido(hours)),  -- null: el horario del comercio
  service_ids  uuid[],                                                      -- null: todos los disponibles
  updated_at   timestamptz not null default now()
);

comment on table public.agenda_settings is
  'Configuración de la agenda de turnos (3.1, D104). Sin acceso directo: mi_agenda(), guardar_agenda().';

create trigger agenda_settings_updated_at
  before update on public.agenda_settings
  for each row execute function public.set_updated_at();

create table public.agenda_blocks (
  business_id uuid not null references public.businesses (id) on delete cascade,
  day         date not null,
  note        text check (char_length(note) <= 80),
  primary key (business_id, day)
);

comment on table public.agenda_blocks is 'Días sin turnos (feriados, vacaciones) (3.1, D104).';

create table public.bookings (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references public.businesses (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  pet_id       uuid not null references public.pets (id) on delete cascade,
  service_id   uuid references public.business_services (id) on delete set null,
  service_name text check (char_length(service_name) <= 80),
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  status       text not null default 'pending'
               check (status in ('pending', 'confirmed', 'rejected', 'cancelled', 'done')),
  cancelled_by text check (cancelled_by in ('cliente', 'negocio')),
  note         text check (char_length(note) <= 300),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  check (ends_at > starts_at)
);

comment on table public.bookings is
  'Turnos (3.1, D104). Sin acceso directo: reservar_turno(), mis_turnos(), turnos_del_negocio().';

create index bookings_business_idx on public.bookings (business_id, starts_at);
create index bookings_user_idx on public.bookings (user_id, starts_at);

create trigger bookings_updated_at
  before update on public.bookings
  for each row execute function public.set_updated_at();

create table public.booking_notifications (
  booking_id  uuid not null references public.bookings (id) on delete cascade,
  kind        text not null,     -- un estado, o 'reminder'
  notified_at timestamptz not null default now(),
  primary key (booking_id, kind)
);

comment on table public.booking_notifications is 'Avisos push ya mandados por turno (3.1, D104). Solo service_role.';

alter table public.agenda_settings enable row level security;
alter table public.agenda_blocks enable row level security;
alter table public.bookings enable row level security;
alter table public.booking_notifications enable row level security;
revoke all on public.agenda_settings, public.agenda_blocks, public.bookings, public.booking_notifications
  from anon, authenticated;

-- ---------------------------------------------------------------------
-- Horarios libres
-- ---------------------------------------------------------------------

-- Duración del turno de [p_servicio] en ese comercio, o null si no se puede
-- reservar (no es del comercio, no está disponible o no está en la agenda).
create function public.duracion_turno(p_negocio uuid, p_servicio uuid)
returns integer
language sql stable security definer set search_path = ''
as $$
  select case
    when p_servicio is null then c.slot_min
    else (select coalesce(s.duration_min, c.slot_min) from public.business_services s
          where s.id = p_servicio and s.business_id = p_negocio and s.available
            and (c.service_ids is null or s.id = any (c.service_ids)))
  end
  from public.agenda_settings c where c.business_id = p_negocio;
$$;

create function public.horarios_libres(p_negocio uuid, p_dia date, p_servicio uuid default null)
returns table (inicio timestamptz, fin timestamptz)
language plpgsql stable security definer set search_path = ''
as $$
declare
  c public.agenda_settings;
  b record;
  dur integer;
  franjas jsonb;
  hoy date := public.dia_uy(now());
begin
  if not public.modulo_activo(p_negocio, 'agenda') then return; end if;
  select * into c from public.agenda_settings where business_id = p_negocio;
  if not found then return; end if;
  if p_dia < hoy or p_dia > hoy + c.days_ahead then return; end if;
  if exists (select 1 from public.agenda_blocks k where k.business_id = p_negocio and k.day = p_dia) then return; end if;
  dur := public.duracion_turno(p_negocio, p_servicio);
  if dur is null then return; end if;
  select x.hours, x.is_24h into b from public.businesses x where x.id = p_negocio;
  franjas := case
    when c.hours is not null then c.hours
    when b.is_24h then jsonb_build_object(
      (array['mon','tue','wed','thu','fri','sat','sun'])[extract(isodow from p_dia)::int], '[["00:00","24:00"]]'::jsonb)
    else b.hours
  end -> (array['mon','tue','wed','thu','fri','sat','sun'])[extract(isodow from p_dia)::int];
  if franjas is null then return; end if;

  return query
  with f as (
    select (p_dia + (x ->> 0)::time) at time zone 'America/Montevideo' as desde,
           (p_dia + (x ->> 1)::time) at time zone 'America/Montevideo' as hasta
    from jsonb_array_elements(franjas) x
  ),
  t as (
    select g as ini, g + make_interval(mins => dur) as fi
    from f, generate_series(f.desde, f.hasta - make_interval(mins => dur), make_interval(mins => c.slot_min)) g
  )
  select t.ini, t.fi from t
  where t.ini >= now() + make_interval(mins => c.notice_min)
    and (select count(*) from public.bookings k
         where k.business_id = p_negocio and k.status in ('pending', 'confirmed')
           and k.starts_at < t.fi and k.ends_at > t.ini) < c.capacity
  order by t.ini;
end;
$$;

-- Lo que se puede reservar en el comercio (también para visitantes).
create function public.condiciones_agenda(p_negocio uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  c public.agenda_settings;
begin
  if not public.modulo_activo(p_negocio, 'agenda') then return null; end if;
  select * into c from public.agenda_settings where business_id = p_negocio;
  if not found then return null; end if;
  return jsonb_build_object(
    'slot_min', c.slot_min,
    'days_ahead', c.days_ahead,
    'notice_min', c.notice_min,
    'bloqueados', coalesce((select jsonb_agg(k.day order by k.day) from public.agenda_blocks k
                            where k.business_id = p_negocio and k.day >= public.dia_uy(now())), '[]'),
    'servicios', coalesce((
      select jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name, 'duration_min', coalesce(s.duration_min, c.slot_min),
                                          'price', s.price, 'price_from', s.price_from) order by s.sort, s.name)
      from public.business_services s
      where s.business_id = p_negocio and s.available
        and (c.service_ids is null or s.id = any (c.service_ids))), '[]')
  );
end;
$$;

-- ---------------------------------------------------------------------
-- Reservar y cambiar el estado
-- ---------------------------------------------------------------------
create function public.reservar_turno(
  p_negocio  uuid,
  p_mascota  uuid,
  p_inicio   timestamptz,
  p_servicio uuid default null,
  p_nota     text default null
)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  libre record;
  id_ uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if public.esta_bloqueado(yo) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  if not public.modulo_activo(p_negocio, 'agenda') then
    raise exception 'Este comercio no toma turnos' using errcode = '42501';
  end if;
  if not public.puedo_cuidar(p_mascota) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  if (select count(*) from public.bookings where user_id = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados turnos hoy' using errcode = '54000';
  end if;
  if (select count(*) from public.bookings where user_id = yo and business_id = p_negocio
        and status in ('pending', 'confirmed') and starts_at > now()) >= 3 then
    raise exception 'Ya tenés 3 turnos en este comercio' using errcode = '54000';
  end if;
  -- Un turno por vez en cada comercio: el horario se vuelve a mirar con el candado.
  perform pg_advisory_xact_lock(hashtextextended('agenda:' || p_negocio::text, 0));
  select h.inicio, h.fin into libre
  from public.horarios_libres(p_negocio, public.dia_uy(p_inicio), p_servicio) h
  where h.inicio = p_inicio;
  if not found then
    raise exception 'Ese horario ya no está libre' using errcode = '22023';
  end if;
  insert into public.bookings (business_id, user_id, pet_id, service_id, service_name, starts_at, ends_at, note)
  values (p_negocio, yo, p_mascota, p_servicio,
          (select s.name from public.business_services s where s.id = p_servicio),
          libre.inicio, libre.fin, nullif(left(trim(p_nota), 300), ''))
  returning id into id_;
  return id_;
end;
$$;

create function public.cambiar_estado_turno(p_id uuid, p_estado text)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  k record;
  quien text;
begin
  select x.status, x.user_id, x.business_id, x.starts_at into k from public.bookings x where x.id = p_id;
  if not found then raise exception 'No existe' using errcode = 'P0002'; end if;
  if public.soy_duenio_de(k.business_id) then
    if not ((k.status, p_estado) in (('pending', 'confirmed'), ('pending', 'rejected'), ('confirmed', 'cancelled'))
            or (k.status = 'confirmed' and p_estado = 'done' and k.starts_at <= now())) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
    quien := 'negocio';
  elsif k.user_id = yo then
    if not (p_estado = 'cancelled' and k.status in ('pending', 'confirmed')) then
      raise exception 'Cambio de estado inválido' using errcode = '22023';
    end if;
    if k.starts_at < now() + interval '2 hours' then
      raise exception 'Se cancela hasta 2 horas antes' using errcode = '22023';
    end if;
    quien := 'cliente';
  else
    raise exception 'No es tuyo' using errcode = '42501';
  end if;
  update public.bookings
     set status = p_estado,
         cancelled_by = case when p_estado = 'cancelled' then quien end
   where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Listas
-- ---------------------------------------------------------------------
create function public.mis_turnos()
returns table (id uuid, business_id uuid, business_name text, service_name text, pet_name text,
               starts_at timestamptz, ends_at timestamptz, status text, cancelled_by text, note text)
language sql stable security definer set search_path = ''
as $$
  select k.id, k.business_id, b.name, k.service_name, p.name, k.starts_at, k.ends_at, k.status, k.cancelled_by, k.note
  from public.bookings k
  join public.businesses b on b.id = k.business_id
  join public.pets p on p.id = k.pet_id
  where k.user_id = (select auth.uid())
    and (k.starts_at > now() - interval '30 days')
  order by (k.starts_at < now()), k.starts_at;
$$;

create function public.turnos_del_negocio(p_negocio uuid, p_desde date default null)
returns table (id uuid, cliente text, pet_name text, especie text, service_name text,
               starts_at timestamptz, ends_at timestamptz, status text, cancelled_by text, note text)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return query
  select k.id, split_part(coalesce(pr.display_name, ''), ' ', 1), p.name, s.name, k.service_name,
         k.starts_at, k.ends_at, k.status, k.cancelled_by, k.note
  from public.bookings k
  join public.pets p on p.id = k.pet_id
  left join public.species s on s.id = p.species_id
  left join public.profiles pr on pr.id = k.user_id
  where k.business_id = p_negocio
    and k.starts_at >= public.inicio_dia_uy(coalesce(p_desde, public.dia_uy(now())))
  order by k.starts_at
  limit 300;
end;
$$;

create function public.turnos_pendientes(p_negocio uuid)
returns integer
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  return (select count(*) from public.bookings
          where business_id = p_negocio and status = 'pending' and starts_at > now());
end;
$$;

-- ---------------------------------------------------------------------
-- Configuración (el dueño, con Plus)
-- ---------------------------------------------------------------------
create function public.mi_agenda(p_negocio uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  c public.agenda_settings;
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select * into c from public.agenda_settings where business_id = p_negocio;
  return jsonb_build_object(
    'configurada', found,
    'slot_min', coalesce(c.slot_min, 30),
    'capacity', coalesce(c.capacity, 1),
    'notice_min', coalesce(c.notice_min, 120),
    'days_ahead', coalesce(c.days_ahead, 30),
    'hours', c.hours,
    'service_ids', to_jsonb(c.service_ids),
    'bloqueados', coalesce((select jsonb_agg(jsonb_build_object('day', k.day, 'note', k.note) order by k.day)
                            from public.agenda_blocks k
                            where k.business_id = p_negocio and k.day >= public.dia_uy(now())), '[]')
  );
end;
$$;

create function public.guardar_agenda(p_negocio uuid, p jsonb)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if (select plan from public.businesses where id = p_negocio) <> 'plus' then
    raise exception 'La agenda es del plan Plus' using errcode = '42501';
  end if;
  insert into public.agenda_settings as c (business_id, slot_min, capacity, notice_min, days_ahead, hours, service_ids)
  values (p_negocio,
          coalesce((p ->> 'slot_min')::smallint, 30),
          coalesce((p ->> 'capacity')::smallint, 1),
          coalesce((p ->> 'notice_min')::integer, 120),
          coalesce((p ->> 'days_ahead')::smallint, 30),
          case when jsonb_typeof(p -> 'hours') = 'object' then p -> 'hours' end,
          case when jsonb_typeof(p -> 'service_ids') = 'array'
               then array(select jsonb_array_elements_text(p -> 'service_ids')::uuid) end)
  on conflict (business_id) do update
     set slot_min = excluded.slot_min, capacity = excluded.capacity, notice_min = excluded.notice_min,
         days_ahead = excluded.days_ahead, hours = excluded.hours, service_ids = excluded.service_ids;
  -- Solo servicios de este comercio.
  if exists (select 1 from public.agenda_settings c, unnest(c.service_ids) sid
             where c.business_id = p_negocio
               and not exists (select 1 from public.business_services s where s.id = sid and s.business_id = p_negocio)) then
    raise exception 'Hay servicios que no son de este comercio' using errcode = '22023';
  end if;
end;
$$;

create function public.bloquear_dia(p_negocio uuid, p_dia date, p_nota text default null, p_bloquear boolean default true)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.soy_duenio_de(p_negocio) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  if p_bloquear then
    if p_dia < public.dia_uy(now()) then raise exception 'Ese día ya pasó' using errcode = '22023'; end if;
    if (select count(*) from public.agenda_blocks where business_id = p_negocio and day >= public.dia_uy(now())) >= 60 then
      raise exception 'Máximo 60 días bloqueados' using errcode = '54000';
    end if;
    insert into public.agenda_blocks (business_id, day, note) values (p_negocio, p_dia, nullif(left(trim(p_nota), 80), ''))
      on conflict (business_id, day) do update set note = excluded.note;
  else
    delete from public.agenda_blocks where business_id = p_negocio and day = p_dia;
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- Avisos
-- ---------------------------------------------------------------------

-- A quién avisar del estado actual del turno (como avisar_pedido(), D100).
create function public.avisar_turno(p_turno uuid, p_actor uuid)
returns table (destino text, estado text, negocio text, inicio timestamptz, servicio text, mascota text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  k record;
  receptor uuid;
  para text;
begin
  select x.status, x.user_id, x.cancelled_by, x.starts_at, x.service_name, b.owner_id, b.name, p.name as mascota into k
  from public.bookings x join public.businesses b on b.id = x.business_id join public.pets p on p.id = x.pet_id
  where x.id = p_turno;
  if not found then return; end if;
  if p_actor = k.user_id and (k.status = 'pending' or (k.status = 'cancelled' and k.cancelled_by = 'cliente')) then
    receptor := k.owner_id;
    para := 'negocio';
  elsif p_actor = k.owner_id
        and (k.status in ('confirmed', 'rejected') or (k.status = 'cancelled' and k.cancelled_by = 'negocio')) then
    receptor := k.user_id;
    para := 'cliente';
  end if;
  if receptor is null or receptor = p_actor then return; end if;
  insert into public.booking_notifications (booking_id, kind) values (p_turno, k.status) on conflict do nothing;
  if not found then return; end if;
  return query
  select para, k.status, k.name, k.starts_at, k.service_name, k.mascota,
         array(select t.token from public.push_tokens t where t.user_id = receptor);
end;
$$;

-- Turnos confirmados de mañana (hora de Uruguay) todavía sin recordar.
create function public.turnos_para_recordar()
returns table (turno uuid, negocio text, inicio timestamptz, servicio text, mascota text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  manana date := public.dia_uy(now()) + 1;
begin
  return query
  with nuevos as (
    insert into public.booking_notifications (booking_id, kind)
    select k.id, 'reminder' from public.bookings k
    where k.status = 'confirmed' and public.dia_uy(k.starts_at) = manana
    on conflict do nothing
    returning booking_id
  )
  select k.id, b.name, k.starts_at, k.service_name, p.name,
         array(select t.token from public.push_tokens t where t.user_id = k.user_id)
  from nuevos n
  join public.bookings k on k.id = n.booking_id
  join public.businesses b on b.id = k.business_id
  join public.pets p on p.id = k.pet_id;
end;
$$;

-- Llama a booking-alert para los recordatorios (como pedir_reporte_mensual(), D101).
create function public.pedir_recordatorios_turnos()
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  url   text := (select decrypted_secret from vault.decrypted_secrets where name = 'project_url');
  clave text := (select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret');
begin
  if url is null or clave is null then
    raise warning 'Falta project_url o cron_secret en Vault: no se mandan los recordatorios de turnos';
    return;
  end if;
  perform net.http_post(
    url := url || '/functions/v1/booking-alert',
    headers := jsonb_build_object('Content-Type', 'application/json', 'x-cron-secret', clave),
    body := '{"recordatorios": true}'::jsonb,
    timeout_milliseconds := 60000
  );
end;
$$;

-- 18:00 de Uruguay.
select cron.schedule('recordar-turnos', '0 21 * * *', 'select public.pedir_recordatorios_turnos();');

-- ---------------------------------------------------------------------
-- En vivo
-- ---------------------------------------------------------------------
create function public.puedo_escuchar_turnos(p_canal text)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when p_canal = 'turnos:cliente:' || (select auth.uid())::text then true
    when p_canal ~ '^turnos:negocio:[0-9a-f-]{36}$'
      then public.soy_duenio_de(substr(p_canal, 16)::uuid)
    else false
  end;
$$;

create policy "turnos en vivo: cada uno los suyos"
  on realtime.messages for select to authenticated
  using (realtime.messages.extension = 'broadcast'
         and public.puedo_escuchar_turnos((select realtime.topic())));

create function public.difundir_turno()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  carga jsonb := jsonb_build_object('id', new.id, 'status', new.status);
begin
  begin
    perform realtime.send(carga, 'turno', 'turnos:cliente:' || new.user_id::text, true);
    perform realtime.send(carga, 'turno', 'turnos:negocio:' || new.business_id::text, true);
  exception when others then
    raise warning 'No se pudo difundir el turno %: %', new.id, sqlerrm;
  end;
  return null;
end;
$$;

create trigger bookings_difundir
  after insert or update of status on public.bookings
  for each row execute function public.difundir_turno();

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
revoke all on function public.duracion_turno(uuid, uuid) from public, anon, authenticated;
revoke all on function public.avisar_turno(uuid, uuid) from public, anon, authenticated;
revoke all on function public.turnos_para_recordar() from public, anon, authenticated;
revoke all on function public.pedir_recordatorios_turnos() from public, anon, authenticated;
revoke all on function public.difundir_turno() from public, anon, authenticated;
grant execute on function public.avisar_turno(uuid, uuid) to service_role;
grant execute on function public.turnos_para_recordar() to service_role;

revoke all on function public.horarios_libres(uuid, date, uuid) from public;
revoke all on function public.condiciones_agenda(uuid) from public;
grant execute on function public.horarios_libres(uuid, date, uuid) to anon, authenticated;
grant execute on function public.condiciones_agenda(uuid) to anon, authenticated;

revoke all on function public.reservar_turno(uuid, uuid, timestamptz, uuid, text) from public, anon;
revoke all on function public.cambiar_estado_turno(uuid, text) from public, anon;
revoke all on function public.mis_turnos() from public, anon;
revoke all on function public.turnos_del_negocio(uuid, date) from public, anon;
revoke all on function public.turnos_pendientes(uuid) from public, anon;
revoke all on function public.mi_agenda(uuid) from public, anon;
revoke all on function public.guardar_agenda(uuid, jsonb) from public, anon;
revoke all on function public.bloquear_dia(uuid, date, text, boolean) from public, anon;
revoke all on function public.puedo_escuchar_turnos(text) from public, anon;
grant execute on function public.reservar_turno(uuid, uuid, timestamptz, uuid, text) to authenticated;
grant execute on function public.cambiar_estado_turno(uuid, text) to authenticated;
grant execute on function public.mis_turnos() to authenticated;
grant execute on function public.turnos_del_negocio(uuid, date) to authenticated;
grant execute on function public.turnos_pendientes(uuid) to authenticated;
grant execute on function public.mi_agenda(uuid) to authenticated;
grant execute on function public.guardar_agenda(uuid, jsonb) to authenticated;
grant execute on function public.bloquear_dia(uuid, date, text, boolean) to authenticated;
grant execute on function public.puedo_escuchar_turnos(text) to authenticated;
