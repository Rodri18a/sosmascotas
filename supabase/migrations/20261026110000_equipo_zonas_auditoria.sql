-- Paso 3.6 (D109): roles del equipo, zonas y auditoría en el portal.
--  · Roles: además de `admin`, `moderator` (moderación y denuncias) y `sales`
--    (lugares, prospectos, propuestas y casos de éxito). `es_admin()` sigue
--    siendo solo `admin`: todo lo demás del portal no cambia.
--  · Las funciones de cada área pasan de `exigir_admin()` a
--    `exigir_equipo(<roles>)`; se reescriben en el lugar con
--    pg_get_functiondef (mismo cuerpo, solo cambia esa llamada) y la
--    migración falla si alguna no tenía la llamada esperada.
--  · Equipo: la administración da o quita roles por correo; nadie se cambia
--    el suyo y siempre queda al menos un admin.
--  · Zonas: lista con sus números, alta con un rectángulo (sin geocodificar)
--    y prender o apagar.
--  · Auditoría: el registro `admin_actions` (que ya llena cada acción) se ve
--    en el portal, con quién, qué y cuándo.

alter type public.user_role add value if not exists 'moderator';
alter type public.user_role add value if not exists 'sales';

-- `role::text`: los valores nuevos del enum no se pueden usar como literales
-- en la misma transacción en que se agregan.
create function public.mi_rol_equipo()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select case when role::text in ('admin', 'moderator', 'sales') then role::text end
  from public.profiles where id = (select auth.uid());
$$;

create function public.es_equipo(p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(public.mi_rol_equipo() = any (p_roles || array['admin']), false);
$$;

-- Como exigir_admin(), pero también para los roles indicados (admin siempre).
create function public.exigir_equipo(p_roles text[])
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.es_equipo(p_roles) then
    raise exception 'Solo para el equipo' using errcode = '42501';
  end if;
  return (select auth.uid());
end;
$$;

revoke all on function public.mi_rol_equipo() from public, anon;
grant execute on function public.mi_rol_equipo() to authenticated;
revoke all on function public.es_equipo(text[]) from public, anon, authenticated;
revoke all on function public.exigir_equipo(text[]) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Abrir cada área a su rol
-- ---------------------------------------------------------------------
do $$
declare
  areas jsonb := jsonb_build_object(
    'moderator', jsonb_build_array(
      'admin_moderacion', 'admin_moderar', 'admin_sancionar', 'admin_historial_usuario',
      'admin_levantar_sancion', 'admin_denuncias', 'admin_estado_denuncia'),
    'sales', jsonb_build_array(
      'admin_lugares', 'admin_guardar_lugar', 'admin_sin_reclamar', 'admin_propuesta',
      'admin_registrar_propuesta', 'admin_casos', 'admin_guardar_caso', 'admin_borrar_caso'));
  rol text;
  nombre text;
  f record;
  def text;
  nueva text;
begin
  for rol in select jsonb_object_keys(areas) loop
    for nombre in select jsonb_array_elements_text(areas -> rol) loop
      for f in select p.oid from pg_proc p
               join pg_namespace n on n.oid = p.pronamespace
               where n.nspname = 'public' and p.proname = nombre loop
        def := pg_get_functiondef(f.oid);
        nueva := replace(def, 'public.exigir_admin()',
                         format('public.exigir_equipo(array[%L])', rol));
        if nueva = def then
          raise exception 'La función % no llama a exigir_admin()', nombre;
        end if;
        execute nueva;
      end loop;
      if not found then
        raise exception 'No existe la función %', nombre;
      end if;
    end loop;
  end loop;
end $$;

-- Prospectos (mini CRM): también para ventas.
drop policy "admin_prospectos" on public.prospects;
create policy "equipo_prospectos" on public.prospects for all to authenticated
  using (public.es_equipo(array['sales'])) with check (public.es_equipo(array['sales']));

-- ---------------------------------------------------------------------
-- Equipo
-- ---------------------------------------------------------------------
create function public.admin_equipo()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'user_id', p.id, 'email', u.email, 'nombre', p.display_name, 'rol', p.role::text,
      'yo', p.id = (select auth.uid()),
      'ultima_accion', (select max(a.created_at) from public.admin_actions a where a.admin_id = p.id)
    ) order by p.role::text, u.email)
    from public.profiles p
    join auth.users u on u.id = p.id
    where p.role::text in ('admin', 'moderator', 'sales')
  ), '[]'::jsonb);
end;
$$;

-- [p_rol]: admin, moderator, sales o user (sacarlo del equipo).
create function public.admin_poner_rol(p_email text, p_rol text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  quien uuid;
  antes text;
begin
  if p_rol not in ('admin', 'moderator', 'sales', 'user') then
    raise exception 'rol_invalido' using errcode = '22023';
  end if;
  select u.id into quien from auth.users u where lower(u.email) = lower(trim(p_email));
  if quien is null then
    raise exception 'sin_cuenta' using errcode = 'P0002';
  end if;
  if quien = yo then
    raise exception 'no_tu_propio_rol' using errcode = 'P0001';
  end if;
  select role::text into antes from public.profiles where id = quien;
  if antes = 'admin' and p_rol <> 'admin'
     and (select count(*) from public.profiles where role::text = 'admin') <= 1 then
    raise exception 'ultimo_admin' using errcode = 'P0001';
  end if;
  update public.profiles set role = p_rol::public.user_role where id = quien;
  perform public.registrar_accion('poner_rol', 'user', quien::text,
                                  jsonb_build_object('antes', antes, 'ahora', p_rol));
end;
$$;

-- ---------------------------------------------------------------------
-- Zonas
-- ---------------------------------------------------------------------
create function public.admin_zonas()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', z.id, 'slug', z.slug, 'name', z.name, 'country', z.country, 'timezone', z.timezone,
      'currency', z.currency, 'active', z.active, 'created_at', z.created_at,
      'usuarios', (select count(*) from public.profiles p where p.zone_id = z.id),
      'mascotas', (select count(*) from public.pets m
                   join public.profiles p on p.id = m.owner_id where p.zone_id = z.id),
      'lugares', (select count(*) from public.businesses b where b.zone_id = z.id and b.status = 'active'),
      'sos_activos', (select count(*) from public.sos_reports s where s.zone_id = z.id and s.status = 'active'),
      'lat_min', extensions.st_ymin(z.area::extensions.geometry),
      'lat_max', extensions.st_ymax(z.area::extensions.geometry),
      'lng_min', extensions.st_xmin(z.area::extensions.geometry),
      'lng_max', extensions.st_xmax(z.area::extensions.geometry)
    ) order by z.active desc, z.name)
    from public.zones z
  ), '[]'::jsonb);
end;
$$;

-- Crea (sin `id`) o actualiza una zona. El área es un rectángulo
-- (lat_min, lat_max, lng_min, lng_max): se dibuja a mano, sin geocodificar.
create function public.admin_guardar_zona(p jsonb)
returns smallint
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  id_ smallint := nullif(p ->> 'id', '')::smallint;
  nueva_area extensions.geography;
  lat1 double precision := (p ->> 'lat_min')::double precision;
  lat2 double precision := (p ->> 'lat_max')::double precision;
  lng1 double precision := (p ->> 'lng_min')::double precision;
  lng2 double precision := (p ->> 'lng_max')::double precision;
begin
  perform public.exigir_admin();
  if lat1 is not null or lat2 is not null or lng1 is not null or lng2 is not null then
    if lat1 is null or lat2 is null or lng1 is null or lng2 is null
       or lat1 >= lat2 or lng1 >= lng2
       or lat1 < -90 or lat2 > 90 or lng1 < -180 or lng2 > 180
       or (lat2 - lat1) > 5 or (lng2 - lng1) > 5 then
      raise exception 'area_invalida' using errcode = '22023';
    end if;
    nueva_area := extensions.st_multi(extensions.st_makeenvelope(lng1, lat1, lng2, lat2, 4326))::extensions.geography;
  end if;
  if id_ is null then
    if nueva_area is null then
      raise exception 'area_invalida' using errcode = '22023';
    end if;
    insert into public.zones (slug, name, country, timezone, currency, area, active)
    values (lower(trim(p ->> 'slug')), trim(p ->> 'name'), coalesce(nullif(p ->> 'country', ''), 'UY'),
            coalesce(nullif(p ->> 'timezone', ''), 'America/Montevideo'),
            coalesce(nullif(p ->> 'currency', ''), 'UYU'), nueva_area,
            coalesce((p ->> 'active')::boolean, false))
    returning id into id_;
  else
    update public.zones
       set name = coalesce(nullif(trim(p ->> 'name'), ''), name),
           active = coalesce((p ->> 'active')::boolean, active),
           area = coalesce(nueva_area, zones.area)
     where id = id_;
    if not found then
      raise exception 'No existe esa zona' using errcode = 'P0002';
    end if;
  end if;
  perform public.registrar_accion('guardar_zona', 'zone', id_::text,
                                  p - 'lat_min' - 'lat_max' - 'lng_min' - 'lng_max');
  return id_;
end;
$$;

-- ---------------------------------------------------------------------
-- Auditoría
-- ---------------------------------------------------------------------
create function public.admin_auditoria(
  p_dias int default 30,
  p_accion text default null,
  p_persona uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', a.id, 'created_at', a.created_at, 'action', a.action, 'target_type', a.target_type,
      'target_id', a.target_id, 'detail', a.detail, 'admin_id', a.admin_id,
      'quien', coalesce(u.email, p.display_name, '—'), 'rol', p.role::text
    ) order by a.created_at desc)
    from (
      select * from public.admin_actions x
      where x.created_at > now() - make_interval(days => least(greatest(coalesce(p_dias, 30), 1), 365))
        and (p_accion is null or x.action = p_accion)
        and (p_persona is null or x.admin_id = p_persona)
      order by x.created_at desc
      limit 500
    ) a
    left join public.profiles p on p.id = a.admin_id
    left join auth.users u on u.id = a.admin_id
  ), '[]'::jsonb);
end;
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array[
    'admin_equipo()', 'admin_poner_rol(text, text)', 'admin_zonas()',
    'admin_guardar_zona(jsonb)', 'admin_auditoria(int, text, uuid)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
