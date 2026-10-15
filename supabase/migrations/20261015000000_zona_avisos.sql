-- Paso 0.6.2: zona aproximada de cada persona para los avisos de SOS cercanos.
-- Nunca se guarda la ubicación exacta: el punto se lleva al centro de una
-- cuadrícula de ~500 m (D56). La app redondea igual antes de enviarlo
-- (packages/core: zonaAproximada), así que el punto exacto no sale del teléfono.

alter table public.profiles
  add column approx_location        extensions.geography(point, 4326),
  add column approx_location_source text check (approx_location_source in ('gps', 'mapa')),
  add column approx_location_at     timestamptz,
  add constraint profiles_zona_completa check (
    (approx_location is null) = (approx_location_source is null)
    and (approx_location is null) = (approx_location_at is null)
  );

comment on column public.profiles.approx_location is
  'Centro de la celda de ~500 m donde está la persona (nunca el punto exacto). Solo para avisos por zona.';

-- Para buscar a quién avisar de un SOS (paso 0.6.3).
create index profiles_approx_location on public.profiles using gist (approx_location)
  where approx_location is not null;

-- La app no puede escribir estas columnas directamente: el grant de update de
-- profiles es por columnas y no las incluye. Se usan las funciones de abajo.

-- Centro de la celda de ~500 m que contiene el punto. Filas de 0,0045° de
-- latitud (~500 m); el ancho en longitud se ajusta según la latitud de la fila
-- para que la celda mida ~500 m también de este a oeste.
-- Misma cuenta que zonaAproximada() en packages/core/lib/src/mapa/zona.dart.
create function public.celda_zona(p_lat double precision, p_lng double precision)
returns extensions.geography
language sql
immutable
set search_path = ''
as $$
  with fila as (
    select (floor(p_lat / 0.0045) + 0.5) * 0.0045 as lat
  ), paso as (
    select lat, 0.0045 / cos(radians(lat)) as lng from fila
  )
  select extensions.st_setsrid(
    extensions.st_makepoint(
      round(((floor(p_lng / paso.lng) + 0.5) * paso.lng)::numeric, 6)::double precision,
      round(paso.lat::numeric, 6)::double precision
    ), 4326)::extensions.geography
  from paso;
$$;

revoke execute on function public.celda_zona(double precision, double precision) from public, anon, authenticated;

-- Guarda la zona de quien tiene la sesión, desde el GPS o marcada en el mapa.
create function public.guardar_zona_aproximada(p_lat double precision, p_lng double precision, p_origen text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if yo is null then
    raise exception 'Hace falta una sesión' using errcode = '42501';
  end if;
  if p_lat is null or p_lng is null
     or p_lat not between -85 and 85 or p_lng not between -180 and 180 then
    raise exception 'Coordenadas inválidas' using errcode = '22023';
  end if;
  if p_origen is null or p_origen not in ('gps', 'mapa') then
    raise exception 'Origen inválido' using errcode = '22023';
  end if;
  update public.profiles
     set approx_location = public.celda_zona(p_lat, p_lng),
         approx_location_source = p_origen,
         approx_location_at = now()
   where id = yo;
end;
$$;

-- Deja de usar la zona (no se reciben avisos por cercanía).
create function public.borrar_zona_aproximada()
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'Hace falta una sesión' using errcode = '42501';
  end if;
  update public.profiles
     set approx_location = null, approx_location_source = null, approx_location_at = null
   where id = (select auth.uid());
end;
$$;

revoke execute on function public.guardar_zona_aproximada(double precision, double precision, text) from public, anon;

grant execute on function public.guardar_zona_aproximada(double precision, double precision, text) to authenticated;

revoke execute on function public.borrar_zona_aproximada() from public, anon;

grant execute on function public.borrar_zona_aproximada() to authenticated;
