-- Paso 0.7.2: las métricas de comercios (place_open, place_click) apuntan a
-- businesses. Si un comercio se borra, sus eventos quedan sin comercio (no se
-- pierden). Lo había anotado 0.1.7 ("FK a businesses cuando exista").
alter table public.events
  add constraint events_business_id_fkey
  foreign key (business_id) references public.businesses (id) on delete set null;
