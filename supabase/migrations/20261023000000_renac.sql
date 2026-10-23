-- Paso 1.5.2b: estado RENAC de la mascota (D96).
-- Lo declara el dueño (06 · RENAC): la app no lo certifica ni consulta el
-- RENAC; solo enlaza a la consulta pública oficial. Nulo = no respondió.
-- No cambia el acceso: `pets` sigue con sus políticas (dueño y hogar, D69).

alter table public.pets
  add column renac_status text
    check (renac_status in ('registered', 'not_registered', 'unknown'));

comment on column public.pets.renac_status is
  'Estado RENAC declarado por el dueño: registered, not_registered, unknown (nulo: sin responder).';
