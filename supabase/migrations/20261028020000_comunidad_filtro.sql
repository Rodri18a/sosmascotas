-- 3.4 (D116): arreglo del filtro de venta y cruza.
--  · «venta de gatitos» no se detectaba (la raíz va sin fin de palabra).
--  · «montaña» se tomaba como «monta» (la ñ cuenta como letra).
--  · «cruza» sola ya no: «mestizo, cruza de labrador» describe una mezcla;
--    sí los verbos (cruzar, cruzarla, cruzo…) y «para cruza» / «busco cruza».
create or replace function public.texto_prohibido_comunidad(p_texto text)
returns boolean
language sql immutable set search_path = ''
as $$
  -- «cruza» sola no: «mestizo, cruza de labrador» describe una mezcla.
  select translate(lower(coalesce(p_texto, '')), 'áéíóúü', 'aeiouu') ~
    ('(^|[^a-zñ])((vendo|vendemos|se venden?|cruzar(la|lo|las|los)?|cruzo|cruzamos|para cruza|busco cruza'
     || '|monta|servicio de monta|padrillo|semental|busco novi[oa])([^a-zñ]|$)'
     || '|venta de (cachorr|gatit|perr|gat|mascot|conej|pajar))');
$$;
