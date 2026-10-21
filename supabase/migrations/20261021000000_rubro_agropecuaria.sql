-- Paso 2.8e (D89): rubro Agropecuaria / agroveterinaria (`agro`).
--  · Nuevo valor en los rubros de los lugares, de las marcas sin reclamar y
--    del mini CRM.
--  · Admite el catálogo y los pedidos como el pet shop (activo solo con el
--    plan Plus, como todos los módulos: 06).
--  · En el mapa aparece también al filtrar "Pet shop" (se resuelve en la app,
--    sobre lo ya traído).

alter table public.businesses drop constraint businesses_business_type_check;
alter table public.businesses add constraint businesses_business_type_check
  check (business_type in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                           'hotel', 'trainer', 'pet_friendly', 'shelter', 'agro'));

alter table public.place_marks drop constraint place_marks_category_check;
alter table public.place_marks add constraint place_marks_category_check
  check (category in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                      'hotel', 'trainer', 'pet_friendly', 'shelter', 'agro'));

alter table public.prospects drop constraint prospects_business_type_check;
alter table public.prospects add constraint prospects_business_type_check
  check (business_type in ('vet', 'petshop', 'pharmacy', 'grooming', 'walker',
                           'hotel', 'trainer', 'pet_friendly', 'shelter', 'agro'));

-- ¿El tipo de negocio admite el módulo? (misma tabla que moduloAdmitido()).
create or replace function public.modulo_admitido(p_tipo text, p_modalidad text, p_modulo text)
returns boolean
language sql immutable set search_path = ''
as $$
  select case
    when p_modalidad = 'online' then p_modulo = 'catalogo'
    when p_modalidad = 'domicilio' then p_modulo = 'agenda'
    when p_tipo = 'vet' then true
    when p_tipo in ('petshop', 'pharmacy', 'agro') then p_modulo = 'catalogo'
    when p_tipo in ('grooming', 'hotel', 'walker', 'trainer') then p_modulo = 'agenda'
    else false
  end;
$$;
