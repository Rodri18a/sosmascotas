-- Solo dev, una vez (D149): los datos de prueba de otras especies pasan a
-- perro o gato para no perder los casos. Sin raza, como estaban.
-- Una sola sentencia (`supabase db query` no acepta varias): corre entera o
-- no corre. Se puede repetir: si ya no hay nada de otras especies, no cambia nada.
with nuevas (pet_id, especie) as (
  values
    -- Pepe (tortuga) pasa a perro y Loki (conejo) a gato.
    ('e6f04918-cead-4f7f-9812-354c8e0277f5'::uuid, 1::smallint),
    ('52285708-fd42-4775-be98-5d9c41745404'::uuid, 2::smallint)
),
mascotas as (
  update public.pets p set species_id = n.especie, breed_id = null
  from nuevas n
  where p.id = n.pet_id and p.species_id <> n.especie
  returning p.id
),
sos as (
  -- Sus SOS siguen a la mascota.
  update public.sos_reports r set species_id = n.especie, breed_id = null
  from nuevas n
  where r.pet_id = n.pet_id and r.species_id <> n.especie
  returning r.id
),
comercios as (
  -- Los comercios atienden solo especies habilitadas.
  update public.businesses
  set species_ids = array(select e from unnest(species_ids) e where e in (1, 2))
  where species_ids && array[3, 4, 5, 6, 7, 8, 9, 10]::smallint[]
  returning id
)
select (select count(*) from mascotas) as mascotas_convertidas,
       (select count(*) from sos) as sos_convertidos,
       (select count(*) from comercios) as comercios_ajustados;
