-- Noticias de ejemplo (SOLO DEV, 2.8). Se puede repetir: borra las de
-- ejemplo y las vuelve a crear.
--
--   set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
--   supabase db query --linked -f supabase/seeds/noticias_ejemplo.sql

begin;

delete from public.news where source = 'Ejemplo (solo dev)';

insert into public.news (title, body, source, species_ids, sponsored, sponsor_name, zone_id, status, published_at)
select n.titulo, n.cuerpo, 'Ejemplo (solo dev)', n.especies, n.patrocinada, n.marca,
       (select id from public.zones where slug = 'pando'), 'published', now() - n.hace
from (values
  ('Cuidados con el calor',
   'Con temperaturas altas, dejá siempre agua fresca y un lugar con sombra. Evitá los paseos en las horas de más calor y no dejes nunca a tu mascota dentro del auto.',
   '{}'::smallint[], false, null, interval '2 hours'),
  ('Gatos: cómo presentar un arenero nuevo',
   'Ponelo en un lugar tranquilo, lejos de la comida, y dejá el viejo unos días al lado. Si tenés más de un gato, la regla es un arenero por gato y uno extra.',
   '{2}'::smallint[], false, null, interval '1 day'),
  ('Alimento para cachorros: qué mirar en la etiqueta',
   'Buscá que diga "completo y balanceado" para cachorros y fijate el tamaño de la raza. Consultá siempre con tu veterinaria antes de cambiar el alimento.',
   '{1}'::smallint[], true, 'Marca de ejemplo', interval '2 days')
) as n(titulo, cuerpo, especies, patrocinada, marca, hace);

commit;
