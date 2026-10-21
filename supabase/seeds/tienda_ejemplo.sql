-- Pet shop de ejemplo con catálogo, pedidos y servicios (SOLO DEV, 2.5, 3.2 y
-- 2.10a). El dueño es la cuenta del dueño del proyecto, así puede probar los
-- dos lados: pedir
-- desde la ficha (mapa → "Ver catálogo") y atenderlo desde el modo comercio
-- (Ajustes → Mi negocio → Catálogo / Pedidos; Negocio → Tus servicios). Se
-- puede repetir: deja el catálogo y los servicios como al principio (los
-- pedidos hechos se conservan).
--
--   set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
--   supabase db query --linked -f supabase/seeds/tienda_ejemplo.sql

begin;

insert into public.businesses (id, owner_id, business_type, kind, name, description, address, location,
                               zone_id, phone, whatsapp, hours, species_ids, verification, plan, status)
values ('00000000-0000-4000-a000-0000000ca7a1',
        (select id from auth.users where email = 'rodrigo18a@gmail.com'),
        'petshop', 'local', 'Pet Shop Ejemplo (catálogo)',
        'Ejemplo para probar el catálogo y los pedidos (solo dev). No es un comercio real.',
        'Calle de ejemplo 500',
        extensions.st_setsrid(extensions.st_makepoint(-55.9570, -34.7180), 4326)::extensions.geography,
        (select id from public.zones where slug = 'pando'), '099000014', '099000014',
        '{"mon": [["09:00", "19:00"]], "tue": [["09:00", "19:00"]], "wed": [["09:00", "19:00"]],
          "thu": [["09:00", "19:00"]], "fri": [["09:00", "19:00"]], "sat": [["09:00", "13:00"]]}',
        '{1,2}', 'verified', 'plus', 'active')
on conflict (id) do update
  set owner_id = excluded.owner_id, plan = 'plus', verification = 'verified', status = 'active';

insert into public.business_modules (business_id, module, enabled)
values ('00000000-0000-4000-a000-0000000ca7a1', 'catalogo', true)
on conflict (business_id, module) do update set enabled = true, updated_at = now();

delete from public.catalog_items where business_id = '00000000-0000-4000-a000-0000000ca7a1';

insert into public.catalog_items (business_id, name, description, price, available, species_ids, sort)
select '00000000-0000-4000-a000-0000000ca7a1', p.nombre, p.descripcion, p.precio, p.disponible, p.especies, p.orden
from (values
  ('Alimento perro adulto 3 kg',    'Para perros adultos de todas las razas.',          890::numeric,  true,  '{1}'::smallint[], 1),
  ('Alimento perro cachorro 3 kg',  'Para cachorros hasta los 12 meses.',               960,           true,  '{1}',             2),
  ('Alimento gato adulto 1,5 kg',   'Con control de bolas de pelo.',                    720,           true,  '{2}',             3),
  ('Piedras sanitarias 4 kg',       'Aglomerantes, sin perfume.',                       390,           true,  '{2}',             4),
  ('Collar regulable',              'Talles S, M y L. Avisá el talle en la nota.',      250,           true,  '{1,2}',           5),
  ('Correa de 1,5 m',               null,                                               320,           true,  '{1}',             6),
  ('Pipeta antipulgas (perro 10–20 kg)', 'Una dosis. Consultá con tu veterinaria.',     450,           true,  '{1}',             7),
  ('Rascador para gatos',           'Ya no queda: vuelve la semana que viene.',         1800,          false, '{2}',             8),
  ('Cucha a medida',                'La hacemos a la medida de tu perro.',              null,          true,  '{1}',             9)
) as p(nombre, descripcion, precio, disponible, especies, orden);

delete from public.business_services where business_id = '00000000-0000-4000-a000-0000000ca7a1';

insert into public.business_services (business_id, name, description, price, price_from, duration_min,
                                      available, species_ids, sort)
select '00000000-0000-4000-a000-0000000ca7a1', s.nombre, s.descripcion, s.precio, s.desde, s.minutos,
       s.visible, s.especies, s.orden
from (values
  ('Baño y secado',     'Según el tamaño del perro.',            600::numeric, true,  90,   true,  '{1}'::smallint[], 1),
  ('Corte de uñas',     null,                                    150,          false, 15,   true,  '{1,2}',           2),
  ('Deslanado',         'Para razas de pelo doble.',             null,         false, 60,   true,  '{1}',             3),
  ('Baño para gatos',   'Lo estamos por ofrecer.',               700,          false, 60,   false, '{2}',             4)
) as s(nombre, descripcion, precio, desde, minutos, visible, especies, orden);

commit;
