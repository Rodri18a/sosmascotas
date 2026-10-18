-- Arreglo de 20261018070000: el disparador de cuentas bloqueadas leía columnas
-- que no existen en todas las tablas (owner_alerts no tiene user_id) y
-- fallaba. Ahora lee la columna de cada tabla desde el registro como JSON.
create or replace function public.frenar_bloqueados()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  fila jsonb := to_jsonb(new);
  quien uuid;
begin
  quien := nullif(case tg_table_name
    when 'sos_reports' then fila ->> 'user_id'
    when 'messages' then fila ->> 'sender_id'
    when 'conversations' then fila ->> 'created_by'
    when 'owner_alerts' then fila ->> 'from_user_id'
  end, '')::uuid;
  if quien is not null and public.esta_bloqueado(quien) then
    raise exception 'Cuenta bloqueada por moderación' using errcode = '42501';
  end if;
  return new;
end;
$$;
