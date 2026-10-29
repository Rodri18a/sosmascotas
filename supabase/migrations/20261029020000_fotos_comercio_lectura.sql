-- Arreglo: «Mi negocio» quedaba cargando y terminaba en «No pudimos conectarnos».
-- La política de lectura de business_photos (18/10) consultaba public.businesses
-- directamente, pero anon y authenticated no tienen permiso sobre esa tabla
-- (se lee solo por funciones, 15/10): toda lectura de fotos daba
-- «permission denied for table businesses». Se cambia por una función
-- security definer que solo dice si el comercio está activo.

create function public.comercio_activo(p_business uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.businesses
                 where id = p_business and status = 'active');
$$;

revoke all on function public.comercio_activo(uuid) from public;
grant execute on function public.comercio_activo(uuid) to anon, authenticated;

drop policy "ver_fotos_de_comercios" on public.business_photos;

create policy "ver_fotos_de_comercios" on public.business_photos for select
  to anon, authenticated
  using (public.comercio_activo(business_id)
         or public.soy_duenio_de(business_id) or public.es_admin());
