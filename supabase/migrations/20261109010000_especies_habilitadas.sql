-- Primera versión solo para perros y gatos (D149).
-- Las demás especies y sus razas quedan en la base, apagadas: para sumar una
-- en el futuro alcanza con `update public.species set enabled = true where slug = '…'`.

alter table public.species
  add column enabled boolean not null default false;

update public.species set enabled = slug in ('dog', 'cat');

comment on column public.species.enabled is
  'La app solo ofrece las especies habilitadas (D149: la primera versión es para perros y gatos).';

-- Los grupos de la comunidad de especies apagadas no se muestran.
update public.community_groups g
set status = 'hidden'
from public.species s
where s.id = g.species_id and not s.enabled and g.status = 'active';

-- RLS: sin cambios. `species` ya tiene RLS y solo la política de lectura
-- "especies_visibles" (anon y authenticated); nadie puede escribirla desde la API.
