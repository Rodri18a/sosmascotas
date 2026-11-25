-- Ejemplos para ver en el mapa (SOLO DEV): un pin de cada tipo alrededor del
-- centro de Pando. Se puede correr las veces que haga falta: borra los
-- ejemplos anteriores y los vuelve a crear (las fechas quedan relativas a hoy).
-- Los comercios tienen id fijo y se actualizan sin borrarse, así no se pierden
-- los favoritos, "fui" ni reseñas que se les hayan hecho al probar.
--
--   set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
--   supabase db query --linked -f supabase/seeds/mapa_ejemplo.sql
--
-- Qué agrega (además de los comercios de ejemplo de cargar_comercios.py):
--  · un usuario de ejemplo sin login (dueño de los SOS y de las marcas);
--  · perros y gatos perdidos y encontrados (lupa roja / verde);
--  · eventos: castración, adopción y encuentro (calendario verde);
--  · lugares marcados sin reclamar de varios rubros (grises con su ícono);
--  · paseador y adiestrador con local (para ver sus íconos) y una veterinaria
--    verificada con plan Plus y urgencias 24 h.

begin;

-- Usuario de ejemplo (sin contraseña: no se puede entrar con él).
-- Los textos de Auth van vacíos y no NULL: con NULL, la API de Auth falla
-- (500) al listar las cuentas.
insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at,
                        confirmation_token, recovery_token, email_change_token_new, email_change,
                        email_change_token_current, phone_change, phone_change_token, reauthentication_token)
values ('00000000-0000-4000-a000-00000000e1e1', '00000000-0000-0000-0000-000000000000',
        'authenticated', 'authenticated', 'ejemplo-mapa@sosmascota.test',
        '{"full_name": "Ejemplo del mapa"}', now(), now(), '', '', '', '', '', '', '', '')
on conflict (id) do nothing;

-- Limpieza de la corrida anterior.
delete from public.sos_reports where user_id = '00000000-0000-4000-a000-00000000e1e1';
delete from public.place_marks where user_id = '00000000-0000-4000-a000-00000000e1e1';
delete from public.events_calendar where description like 'Ejemplo del mapa%';
-- Comercios: solo los de corridas viejas (sin id fijo); los demás se actualizan abajo.
delete from public.businesses where is_sample and description like 'Ejemplo del mapa%'
  and id::text not like '00000000-0000-4000-a000-000000e0%';

-- SOS: la ubicación pública es la exacta corrida unos 170 m (como en la app).
insert into public.sos_reports (kind, user_id, species_id, name, sex, color, description,
                                exact_location, public_location, zone_id, happened_at)
select s.kind::public.sos_kind, '00000000-0000-4000-a000-00000000e1e1', s.especie, s.nombre,
       s.sexo::public.pet_sex, s.color, 'Ejemplo del mapa (solo dev). ' || s.texto,
       extensions.st_setsrid(extensions.st_makepoint(s.lng, s.lat), 4326)::extensions.geography,
       extensions.st_setsrid(extensions.st_makepoint(s.lng + 0.0012, s.lat + 0.0010), 4326)::extensions.geography,
       (select id from public.zones where slug = 'pando'), now() - s.hace
from (values
  ('lost',  1::smallint, 'Firulais', 'male',    'Marrón con manchas blancas', 'Se escapó por el portón. Tiene collar rojo.',  -34.7128, -55.9622, interval '5 hours'),
  ('lost',  2::smallint, 'Mishi',    'female',  'Gris atigrado',              'Salió al patio y no volvió. Es miedosa.',      -34.7230, -55.9530, interval '2 days'),
  ('found', 1::smallint, null,       'unknown', 'Negro, mediano',             'Anda por la plaza, es mansito. Sin chapita.',  -34.7185, -55.9640, interval '3 hours'),
  ('found', 2::smallint, null,       'unknown', 'Blanco y naranja',           'Gatito joven en la puerta de casa.',           -34.7105, -55.9545, interval '1 day')
) as s(kind, especie, nombre, sexo, color, texto, lat, lng, hace);

-- Eventos (no terminaron, para que se vean).
insert into public.events_calendar (organizer_id, kind, title, description, starts_at, ends_at,
                                    location, address, zone_id)
select null, e.kind, e.titulo, 'Ejemplo del mapa (solo dev). ' || e.texto,
       date_trunc('day', now()) + e.empieza, date_trunc('day', now()) + e.empieza + e.dura,
       extensions.st_setsrid(extensions.st_makepoint(e.lng, e.lat), 4326)::extensions.geography,
       e.direccion, (select id from public.zones where slug = 'pando')
from (values
  ('castracion', 'Jornada de castración gratuita', 'Perros y gatos, con inscripción previa.', interval '2 days 9 hours', interval '7 hours', -34.7160, -55.9555, 'Plaza de ejemplo'),
  ('adopcion',   'Feria de adopción',              'Cachorros y adultos buscando familia.',   interval '4 days 10 hours', interval '6 hours', -34.7200, -55.9600, 'Parque de ejemplo'),
  ('encuentro',  'Caminata con mascotas',          'Encuentro abierto, traé agua y bolsitas.', interval '1 day 17 hours', interval '2 hours', -34.7140, -55.9500, 'Rambla de ejemplo')
) as e(kind, titulo, texto, empieza, dura, lat, lng, direccion);

-- Lugares marcados por usuarios que nadie reclamó (grises con el ícono del rubro).
insert into public.place_marks (user_id, category, location)
select '00000000-0000-4000-a000-00000000e1e1', m.rubro,
       extensions.st_setsrid(extensions.st_makepoint(m.lng, m.lat), 4326)::extensions.geography
from (values
  ('vet',          -34.7250, -55.9620),
  ('petshop',      -34.7095, -55.9600),
  ('pharmacy',     -34.7210, -55.9480),
  ('grooming',     -34.7120, -55.9480),
  ('pet_friendly', -34.7265, -55.9560),
  ('shelter',      -34.7080, -55.9650)
) as m(rubro, lat, lng);

-- Comercios con local que faltaban para ver todos los íconos.
insert into public.businesses (id, business_type, kind, name, description, address, location, zone_id,
                               phone, hours, is_24h, emergencies, species_ids, verification, plan, is_sample)
select c.id::uuid, c.rubro, 'local', c.nombre, 'Ejemplo del mapa (solo dev). No es un comercio real.', c.direccion,
       extensions.st_setsrid(extensions.st_makepoint(c.lng, c.lat), 4326)::extensions.geography,
       (select id from public.zones where slug = 'pando'), c.telefono, c.horario::jsonb, c.h24, c.urgencias,
       '{}', c.verificacion, c.plan, true
from (values
  ('00000000-0000-4000-a000-000000e00001', 'walker',  'Paseos Ejemplo',                 'Calle de ejemplo 300', -34.7150, -55.9660, '099000011', '{"mon": [["08:00", "18:00"]], "tue": [["08:00", "18:00"]], "wed": [["08:00", "18:00"]], "thu": [["08:00", "18:00"]], "fri": [["08:00", "18:00"]]}', false, false, 'unverified', 'basic'),
  ('00000000-0000-4000-a000-000000e00002', 'trainer', 'Adiestramiento Ejemplo',         'Calle de ejemplo 400', -34.7235, -55.9590, '099000012', '{"sat": [["09:00", "13:00"]], "sun": [["09:00", "13:00"]]}', false, false, 'unverified', 'basic'),
  ('00000000-0000-4000-a000-000000e00003', 'agro',    'Agropecuaria Ejemplo',           'Ruta de ejemplo 8 km 38', -34.7055, -55.9520, '099000014', '{"mon": [["08:00", "18:00"]], "tue": [["08:00", "18:00"]], "wed": [["08:00", "18:00"]], "thu": [["08:00", "18:00"]], "fri": [["08:00", "18:00"]], "sat": [["08:00", "12:00"]]}', false, false, 'unverified', 'basic'),
  ('00000000-0000-4000-a000-000000e00004', 'vet',     'Veterinaria Ejemplo Plus 24 h',  'Avenida de ejemplo 50', -34.7190, -55.9510, '099000013', '{}', true, true, 'verified', 'plus')
) as c(id, rubro, nombre, direccion, lat, lng, telefono, horario, h24, urgencias, verificacion, plan)
on conflict (id) do update
  set business_type = excluded.business_type, name = excluded.name, description = excluded.description,
      address = excluded.address, location = excluded.location, phone = excluded.phone,
      hours = excluded.hours, is_24h = excluded.is_24h, emergencies = excluded.emergencies,
      verification = excluded.verification, plan = excluded.plan, status = 'active';

commit;
