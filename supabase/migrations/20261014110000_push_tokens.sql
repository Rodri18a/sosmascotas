-- Paso 0.6.1: tokens de push (Firebase Cloud Messaging) por dispositivo.
-- Las push usan el token del dispositivo, nunca el teléfono (docs/08-arquitectura.md).

create table public.push_tokens (
  token        text primary key check (char_length(token) between 20 and 4096),
  user_id      uuid not null references auth.users (id) on delete cascade,
  platform     text not null check (platform in ('web', 'android', 'ios')),
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

create index push_tokens_user_id on public.push_tokens (user_id);

alter table public.push_tokens enable row level security;

-- Cada persona ve y borra solo los tokens de sus dispositivos. Se guardan con
-- guardar_push_token(): no hay insert ni update directos.
create policy "ver_mis_tokens" on public.push_tokens for select to authenticated
  using (user_id = (select auth.uid()));
create policy "borrar_mis_tokens" on public.push_tokens for delete to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.push_tokens from anon;
revoke insert, update, truncate on public.push_tokens from authenticated;

-- Guarda (o renueva) el token de este dispositivo para quien tiene la sesión.
-- Si el dispositivo lo usaba otra cuenta (celular compartido), el token pasa a
-- la cuenta actual: la anterior deja de recibir avisos en ese dispositivo.
-- Se guardan como máximo 10 dispositivos por persona (los más recientes).
create function public.guardar_push_token(p_token text, p_platform text)
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
  insert into public.push_tokens (token, user_id, platform)
  values (p_token, yo, p_platform)
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
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

revoke execute on function public.guardar_push_token(text, text) from public, anon;
grant execute on function public.guardar_push_token(text, text) to authenticated;
