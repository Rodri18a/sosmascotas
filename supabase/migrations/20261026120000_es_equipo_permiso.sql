-- Arreglo de 3.6 (D109): la política de `prospects` llama a es_equipo() con
-- los permisos de quien consulta, así que necesita poder ejecutarla. Solo dice
-- si la propia cuenta tiene alguno de esos roles (como es_admin()).
grant execute on function public.es_equipo(text[]) to authenticated;
