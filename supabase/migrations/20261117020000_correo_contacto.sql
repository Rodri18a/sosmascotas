-- Correo de soporte: contacto@huellamy.com (D163). Es la casilla que se creó
-- en Hostinger; no hay soporte@ (la API no crea reenvíos). Solo datos: la
-- tabla app_settings y sus políticas no cambian.
update public.app_settings
   set value = 'contacto@huellamy.com', updated_at = now()
 where key = 'support_email';
