-- D156: Huellamy (app.huellamy.com) y Huellamy Comercios (comercios.huellamy.com)
-- viven en direcciones distintas y cada una guarda su propio token de push.
-- Se anota de qué app es cada dispositivo para que los avisos no lleguen dos
-- veces: lo del negocio va a Comercios y lo demás a Huellamy
-- (supabase/functions/_shared/fcm.ts, elegirDispositivos).
-- Los dispositivos que ya estaban quedan como de Huellamy.

alter table public.push_tokens
  add column app text not null default 'personas'
    check (app in ('personas', 'comercios'));

-- La función pasa a recibir la app. Se borra la versión de dos parámetros
-- para que no haya dos con el mismo nombre; las compilaciones viejas que la
-- llamen sin p_app siguen funcionando por el valor por defecto.
drop function public.guardar_push_token(text, text);

-- Guarda (o renueva) el token de este dispositivo para quien tiene la sesión.
-- Si el dispositivo lo usaba otra cuenta (celular compartido), el token pasa a
-- la cuenta actual: la anterior deja de recibir avisos en ese dispositivo.
-- Se guardan como máximo 10 dispositivos por persona (los más recientes).
create function public.guardar_push_token(
  p_token text,
  p_platform text,
  p_app text default 'personas'
)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
begin
  if yo is null then
    raise exception 'Hace falta una sesión' using errcode = '42501';
  end if;
  insert into public.push_tokens (token, user_id, platform, app)
  values (p_token, yo, p_platform, p_app)
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        app = excluded.app,
        last_seen_at = now();

  delete from public.push_tokens
  where user_id = yo
    and token not in (
      select token from public.push_tokens
      where user_id = yo
      order by last_seen_at desc
      limit 10
    );
end;
$$;

revoke execute on function public.guardar_push_token(text, text, text) from public, anon;
grant execute on function public.guardar_push_token(text, text, text) to authenticated;
