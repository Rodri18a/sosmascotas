-- 3.5 (D117): ajustes del equipo de la empresa.
--  · El equipo es del **plan Plus**, con hasta **5** personas además del
--    dueño. Si el comercio deja el Plus, el equipo se conserva pero no entra
--    (ni ve el negocio en «Mis negocios») hasta que vuelva.
--  · Avisos push: lo que hace un empleado (preparar un pedido, confirmar un
--    turno, aceptar un paseo) le avisa a quien pidió, igual que si lo hiciera
--    el dueño; y lo que pide una persona le llega al dueño y a todo el equipo
--    (menos a quien lo hizo).
--  · El chat del comercio sigue con el dueño.

-- Dueño y equipo de un negocio (el equipo, solo con Plus). Uso interno.
create function public.personas_del_negocio(p_business uuid)
returns setof uuid
language sql stable security definer set search_path = ''
as $$
  select b.owner_id from public.businesses b where b.id = p_business and b.owner_id is not null
  union
  select t.user_id from public.business_team t join public.businesses b on b.id = t.business_id
  where t.business_id = p_business and b.plan = 'plus';
$$;

revoke all on function public.personas_del_negocio(uuid) from public, anon, authenticated;

-- Atiendo este negocio: el dueño o alguien de su equipo (con Plus).
create or replace function public.soy_duenio_de(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select public.soy_titular_de(p_business)
      or exists (select 1 from public.business_team t join public.businesses b on b.id = t.business_id
                 where t.business_id = p_business and t.user_id = (select auth.uid()) and b.plan = 'plus');
$$;

-- Mis negocios: los míos y los de los equipos en los que estoy (con Plus).
create or replace function public.mis_negocios()
returns table (
  id uuid, business_type text, kind text, name text, description text, address text,
  lat double precision, lng double precision, phone text, whatsapp text, web text,
  instagram text, facebook text, promo text, coverage text, hours jsonb, special_days jsonb,
  is_24h boolean, emergencies boolean, species_ids smallint[], verification text,
  renac_operator boolean, plan text, status text, rut text, founder_until date,
  renac_requested_at timestamptz, verification_requested_at timestamptz, verified boolean,
  is_sample boolean, rol text
)
language sql stable security definer set search_path = ''
as $$
  select b.id, b.business_type, b.kind, b.name, b.description, b.address,
         extensions.st_y(b.location::extensions.geometry), extensions.st_x(b.location::extensions.geometry),
         b.phone, b.whatsapp, b.web, b.instagram, b.facebook, b.promo, b.coverage, b.hours,
         b.special_days, b.is_24h, b.emergencies, b.species_ids, b.verification,
         b.renac_operator, b.plan, b.status,
         case when b.owner_id = (select auth.uid()) then b.rut end,
         b.founder_until, b.renac_requested_at,
         b.verification_requested_at, b.verification = 'verified', b.is_sample,
         case when b.owner_id = (select auth.uid()) then 'owner' else 'employee' end
  from public.businesses b
  where b.owner_id = (select auth.uid())
     or (b.plan = 'plus' and exists (select 1 from public.business_team t
                                     where t.business_id = b.id and t.user_id = (select auth.uid())))
  order by (b.owner_id <> (select auth.uid())), b.created_at;
$$;

create or replace function public.invitar_al_equipo(p_negocio uuid)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  codigo text;
  letras constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
begin
  if not public.soy_titular_de(p_negocio) then
    raise exception 'Solo el dueño arma el equipo' using errcode = '42501';
  end if;
  if (select plan from public.businesses where id = p_negocio) <> 'plus' then
    raise exception 'El equipo es del plan Plus' using errcode = '42501';
  end if;
  if (select count(*) from public.business_team where business_id = p_negocio) >= 5 then
    raise exception 'Máximo 5 personas por equipo' using errcode = '54000';
  end if;
  if (select count(*) from public.business_team_invites
      where business_id = p_negocio and used_at is null and expires_at > now()) >= 5 then
    raise exception 'Demasiadas invitaciones abiertas' using errcode = '54000';
  end if;
  loop
    codigo := (select string_agg(substr(letras, 1 + floor(random() * length(letras))::int, 1), '')
               from generate_series(1, 8));
    exit when not exists (select 1 from public.business_team_invites where code = codigo);
  end loop;
  insert into public.business_team_invites (code, business_id, created_by)
  values (codigo, p_negocio, (select auth.uid()));
  return codigo;
end;
$$;

create or replace function public.unirme_al_equipo(p_codigo text)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  inv public.business_team_invites;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select * into inv from public.business_team_invites
  where code = upper(trim(p_codigo)) and used_at is null and expires_at > now()
  for update;
  if not found then raise exception 'Código inválido o vencido' using errcode = 'P0002'; end if;
  if exists (select 1 from public.businesses where id = inv.business_id and owner_id = yo) then
    raise exception 'Ya sos el dueño' using errcode = '22023';
  end if;
  if (select plan from public.businesses where id = inv.business_id) <> 'plus' then
    raise exception 'El equipo es del plan Plus' using errcode = '42501';
  end if;
  if (select count(*) from public.business_team where business_id = inv.business_id) >= 5 then
    raise exception 'Máximo 5 personas por equipo' using errcode = '54000';
  end if;
  insert into public.business_team (business_id, user_id, added_by)
  values (inv.business_id, yo, inv.created_by)
  on conflict do nothing;
  update public.business_team_invites set used_by = yo, used_at = now() where code = inv.code;
  return inv.business_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Avisos: el comercio es el dueño o su equipo
-- ---------------------------------------------------------------------
-- Vigente en 20261026010000_pedidos_avisos.sql.
create or replace function public.avisar_pedido(p_pedido uuid, p_actor uuid)
returns table (destino text, numero bigint, estado text, negocio text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  o record;
  receptores uuid[];
  para text;
  del_negocio boolean;
begin
  select x.status, x.number, x.user_id, x.cancelled_by, x.business_id, b.name into o
  from public.orders x join public.businesses b on b.id = x.business_id
  where x.id = p_pedido;
  if not found then return; end if;
  del_negocio := p_actor in (select public.personas_del_negocio(o.business_id));
  if p_actor = o.user_id
     and (o.status = 'new' or (o.status = 'cancelled' and o.cancelled_by = 'cliente')) then
    receptores := array(select public.personas_del_negocio(o.business_id));
    para := 'negocio';
  elsif del_negocio
     and (o.status in ('preparing', 'ready', 'delivered')
          or (o.status = 'cancelled' and o.cancelled_by = 'negocio')) then
    receptores := array[o.user_id];
    para := 'cliente';
  end if;
  -- Sin dueño, o un pedido al propio comercio: no hay a quién avisar.
  receptores := array_remove(receptores, p_actor);
  if coalesce(cardinality(receptores), 0) = 0 then return; end if;
  insert into public.order_notifications (order_id, status) values (p_pedido, o.status)
    on conflict do nothing;
  if not found then return; end if;
  return query
  select para, o.number, o.status, o.name,
         array(select t.token from public.push_tokens t where t.user_id = any (receptores));
end;
$$;

-- Vigente en 20261026060000_agenda_turnos.sql.
create or replace function public.avisar_turno(p_turno uuid, p_actor uuid)
returns table (destino text, estado text, negocio text, inicio timestamptz, servicio text, mascota text, tokens text[])
language plpgsql security definer set search_path = ''
as $$
declare
  k record;
  receptores uuid[];
  para text;
  del_negocio boolean;
begin
  select x.status, x.user_id, x.cancelled_by, x.starts_at, x.service_name, x.business_id, b.name, p.name as mascota into k
  from public.bookings x join public.businesses b on b.id = x.business_id join public.pets p on p.id = x.pet_id
  where x.id = p_turno;
  if not found then return; end if;
  del_negocio := p_actor in (select public.personas_del_negocio(k.business_id));
  if p_actor = k.user_id and (k.status = 'pending' or (k.status = 'cancelled' and k.cancelled_by = 'cliente')) then
    receptores := array(select public.personas_del_negocio(k.business_id));
    para := 'negocio';
  elsif del_negocio
        and (k.status in ('confirmed', 'rejected') or (k.status = 'cancelled' and k.cancelled_by = 'negocio')) then
    receptores := array[k.user_id];
    para := 'cliente';
  end if;
  receptores := array_remove(receptores, p_actor);
  if coalesce(cardinality(receptores), 0) = 0 then return; end if;
  insert into public.booking_notifications (booking_id, kind) values (p_turno, k.status) on conflict do nothing;
  if not found then return; end if;
  return query
  select para, k.status, k.name, k.starts_at, k.service_name, k.mascota,
         array(select t.token from public.push_tokens t where t.user_id = any (receptores));
end;
$$;

-- Vigente en 20261028000000_contrataciones.sql.
create or replace function public.avisar_cuidado(p_pedido uuid, p_actor uuid)
returns table (destino text, estado text, tipo text, negocio text, desde date, hasta date, mascotas text, tokens text[])
language plpgsql security definer set search_path = ''
as $$
declare
  r record;
  receptores uuid[];
  para text;
  del_negocio boolean;
begin
  select x.status, x.user_id, x.cancelled_by, x.kind, x.start_day, x.end_day, x.pet_ids, x.business_id, b.name into r
  from public.care_requests x join public.businesses b on b.id = x.business_id
  where x.id = p_pedido;
  if not found then return; end if;
  del_negocio := p_actor in (select public.personas_del_negocio(r.business_id));
  if p_actor = r.user_id and (r.status = 'pending' or (r.status = 'cancelled' and r.cancelled_by = 'cliente')) then
    receptores := array(select public.personas_del_negocio(r.business_id));
    para := 'negocio';
  elsif del_negocio
        and (r.status in ('accepted', 'rejected') or (r.status = 'cancelled' and r.cancelled_by = 'negocio')) then
    receptores := array[r.user_id];
    para := 'cliente';
  end if;
  receptores := array_remove(receptores, p_actor);
  if coalesce(cardinality(receptores), 0) = 0 then return; end if;
  insert into public.care_notifications (request_id, kind) values (p_pedido, r.status) on conflict do nothing;
  if not found then return; end if;
  return query
  select para, r.status, r.kind, r.name, r.start_day, r.end_day,
         (select string_agg(p.name, ', ') from public.pets p where p.id = any (r.pet_ids)),
         array(select t.token from public.push_tokens t where t.user_id = any (receptores));
end;
$$;
