-- Paseador de ejemplo para probar las contrataciones (SOLO DEV, 3.3, D115).
-- El dueño es la cuenta del dueño del proyecto: con otra cuenta se le pide un
-- paseo, guardería, estadía o visita desde la ficha (Comercios → "Paseos y
-- cuidados Ejemplo" → "Pedir"), y se atiende desde el modo comercio
-- (Agenda → Pedidos de cuidado). Plan Plus con el módulo Agenda prendido.
-- Se puede repetir: deja los ajustes como al principio (los pedidos hechos se
-- conservan).
--
--   set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
--   supabase db query --linked -f supabase/seeds/paseador_ejemplo.sql

begin;

insert into public.businesses (id, owner_id, business_type, kind, name, description, address, location,
                               zone_id, coverage, phone, whatsapp, hours, species_ids, verification, plan,
                               status)
values ('00000000-0000-4000-a000-0000000ca7a2',
        (select id from auth.users where email = 'rodrigo18a@gmail.com'),
        'walker', 'domicilio', 'Paseos y cuidados Ejemplo',
        'Ejemplo para probar paseos, guardería y estadías (solo dev). No es un servicio real.',
        null,
        extensions.st_setsrid(extensions.st_makepoint(-55.9590, -34.7170), 4326)::extensions.geography,
        (select id from public.zones where slug = 'pando'), 'Pando y alrededores', '099000015', '099000015',
        '{"mon": [["08:00", "18:00"]], "tue": [["08:00", "18:00"]], "wed": [["08:00", "18:00"]],
          "thu": [["08:00", "18:00"]], "fri": [["08:00", "18:00"]], "sat": [["09:00", "13:00"]]}',
        '{1,2}', 'verified', 'plus', 'active')
on conflict (id) do update
  set owner_id = excluded.owner_id, plan = 'plus', verification = 'verified', status = 'active';

insert into public.business_modules (business_id, module, enabled)
values ('00000000-0000-4000-a000-0000000ca7a2', 'agenda', true)
on conflict (business_id, module) do update set enabled = true, updated_at = now();

-- Ofrece todo: hasta 3 mascotas por día en guardería y estadía, pedidos hasta
-- 60 días adelante y estadías de hasta 15 días.
insert into public.care_settings (business_id, kinds, capacity, days_ahead, max_days, conditions)
values ('00000000-0000-4000-a000-0000000ca7a2', '{walk,daycare,boarding,home_visit}', 3, 60, 15,
        'Vacunas al día. Paseos de 45 minutos en grupos chicos.')
on conflict (business_id) do update
  set kinds = excluded.kinds, capacity = excluded.capacity, days_ahead = excluded.days_ahead,
      max_days = excluded.max_days, conditions = excluded.conditions;

commit;
