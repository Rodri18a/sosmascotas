-- Paso 0.1.2: PostGIS para las consultas por zona del mapa (pines visibles, radio de avisos).
-- Se instala en el esquema "extensions", como recomienda Supabase.
create extension if not exists postgis with schema extensions;
