-- Paso 0.3.1: especies y razas (datos de referencia). Las lee cualquiera; solo
-- el administrador las cambia. Si la raza no está, la mascota usa `breed_other`.

create table public.species (
  id    smallint generated always as identity primary key,
  slug  text not null unique check (slug ~ '^[a-z_]{2,30}$'),
  name  text not null,
  icon  text not null,
  sort  smallint not null default 100
);

create table public.breeds (
  id         integer generated always as identity primary key,
  species_id smallint not null references public.species (id) on delete cascade,
  name       text not null,
  sort       smallint not null default 100,
  unique (species_id, name),
  unique (species_id, id)  -- para validar que la raza sea de la especie (FK compuesta en pets)
);

create index breeds_species_idx on public.breeds (species_id, sort, name);

alter table public.species enable row level security;
alter table public.breeds enable row level security;

create policy "especies_visibles" on public.species for select to anon, authenticated using (true);
create policy "razas_visibles" on public.breeds for select to anon, authenticated using (true);

revoke insert, update, delete, truncate on public.species, public.breeds from anon, authenticated;

insert into public.species (slug, name, icon, sort) values
  ('dog', 'Perro', '🐶', 1),
  ('cat', 'Gato', '🐱', 2),
  ('bird', 'Ave', '🐦', 3),
  ('rabbit', 'Conejo', '🐰', 4),
  ('rodent', 'Roedor', '🐹', 5),
  ('turtle', 'Tortuga', '🐢', 6),
  ('reptile', 'Reptil', '🦎', 7),
  ('fish', 'Pez', '🐟', 8),
  ('horse', 'Caballo', '🐴', 9),
  ('other', 'Otro', '🐾', 99);

-- "Mestizo" primero: es lo más común en Uruguay.
insert into public.breeds (species_id, name, sort)
select s.id, r.name, r.sort
from public.species s
join (values
  ('dog', 'Mestizo', 1),
  ('dog', 'Cimarrón uruguayo', 2),
  ('dog', 'Labrador', 10), ('dog', 'Golden retriever', 10), ('dog', 'Ovejero alemán', 10),
  ('dog', 'Caniche', 10), ('dog', 'Beagle', 10), ('dog', 'Bulldog francés', 10),
  ('dog', 'Bulldog inglés', 10), ('dog', 'Bóxer', 10), ('dog', 'Rottweiler', 10),
  ('dog', 'Pitbull', 10), ('dog', 'Dogo argentino', 10), ('dog', 'Yorkshire terrier', 10),
  ('dog', 'Chihuahua', 10), ('dog', 'Shih tzu', 10), ('dog', 'Border collie', 10),
  ('dog', 'Cocker spaniel', 10), ('dog', 'Salchicha (dachshund)', 10), ('dog', 'Schnauzer', 10),
  ('dog', 'Pug', 10), ('dog', 'Husky siberiano', 10), ('dog', 'Pastor belga', 10),
  ('dog', 'Maltés', 10), ('dog', 'Pekinés', 10), ('dog', 'Jack Russell terrier', 10),
  ('dog', 'Dóberman', 10), ('dog', 'Galgo', 10), ('dog', 'Fox terrier', 10),
  ('dog', 'Bichón frisé', 10), ('dog', 'Pomerania', 10), ('dog', 'Gran danés', 10),
  ('dog', 'Shar pei', 10), ('dog', 'Akita', 10), ('dog', 'Chow chow', 10),
  ('dog', 'Pastor australiano', 10), ('dog', 'Weimaraner', 10), ('dog', 'Boston terrier', 10),
  ('cat', 'Mestizo', 1),
  ('cat', 'Siamés', 10), ('cat', 'Persa', 10), ('cat', 'Angora', 10), ('cat', 'Maine coon', 10),
  ('cat', 'Bengalí', 10), ('cat', 'Británico de pelo corto', 10), ('cat', 'Ragdoll', 10),
  ('cat', 'Esfinge', 10), ('cat', 'Azul ruso', 10), ('cat', 'Sagrado de Birmania', 10),
  ('bird', 'Canario', 10), ('bird', 'Periquito', 10), ('bird', 'Cotorra', 10),
  ('bird', 'Cacatúa / ninfa', 10), ('bird', 'Loro', 10),
  ('rodent', 'Hámster', 10), ('rodent', 'Cobayo', 10), ('rodent', 'Chinchilla', 10),
  ('rodent', 'Rata', 10), ('rodent', 'Jerbo', 10)
) as r (slug, name, sort) on r.slug = s.slug;
