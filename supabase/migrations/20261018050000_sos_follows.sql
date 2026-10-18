-- Paso 1.4.5: seguir un SOS y enterarse cuando aparece (D74). Cualquiera con
-- cuenta puede seguir un SOS activo ajeno ("Seguir este reporte"); quien abre
-- un chat desde el SOS lo sigue solo. Cuando el autor marca "¡Apareció!", la
-- app llama a la Edge Function `sos-follow-alert`, que avisa por push a los
-- seguidores una sola vez. Nadie ve quién más sigue un reporte.

create table public.sos_follows (
  sos_id       uuid not null references public.sos_reports (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at   timestamptz not null default now(),
  notified_at  timestamptz,
  primary key (sos_id, user_id)
);

create index sos_follows_user_idx on public.sos_follows (user_id, created_at desc);

alter table public.sos_follows enable row level security;

create policy "ver_lo_que_sigo" on public.sos_follows for select to authenticated
  using (user_id = (select auth.uid()));
create policy "dejar_de_seguir" on public.sos_follows for delete to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.sos_follows from anon;
revoke insert, update on public.sos_follows from authenticated;

-- Seguir (true) o dejar de seguir (false) un SOS activo que no es mío.
create function public.seguir_sos(p_sos uuid, p_seguir boolean default true)
returns boolean
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  autor uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  if not p_seguir then
    delete from public.sos_follows where sos_id = p_sos and user_id = yo;
    return false;
  end if;
  select user_id into autor from public.sos_reports where id = p_sos and status = 'active';
  if autor is null then
    raise exception 'El reporte no está activo' using errcode = 'P0002';
  end if;
  if autor = yo then
    raise exception 'Es tu propio reporte' using errcode = '22023';
  end if;
  insert into public.sos_follows (sos_id, user_id) values (p_sos, yo)
    on conflict do nothing;
  return true;
end;
$$;

revoke all on function public.seguir_sos(uuid, boolean) from public, anon;
grant execute on function public.seguir_sos(uuid, boolean) to authenticated;

-- Para la Edge Function: si el SOS es de [p_autor] y ya está resuelto,
-- marca a los seguidores como avisados y devuelve sus dispositivos (una sola
-- vez por seguidor).
create function public.avisar_seguidores_sos(p_sos uuid, p_autor uuid)
returns table (nombre text, tokens text[])
language plpgsql volatile security definer set search_path = ''
as $$
declare
  reporte record;
  avisados uuid[];
begin
  select r.name, r.user_id, r.status into reporte
  from public.sos_reports r where r.id = p_sos;
  if reporte.user_id is distinct from p_autor or reporte.status <> 'resolved' then
    return;
  end if;
  with marcados as (
    update public.sos_follows f set notified_at = now()
    where f.sos_id = p_sos and f.notified_at is null
    returning f.user_id
  )
  select array_agg(user_id) into avisados from marcados;
  return query
  select reporte.name,
         array(select t.token from public.push_tokens t
               where t.user_id = any (coalesce(avisados, '{}')));
end;
$$;

revoke execute on function public.avisar_seguidores_sos(uuid, uuid) from public, anon, authenticated;
grant execute on function public.avisar_seguidores_sos(uuid, uuid) to service_role;

-- Quien abre un chat desde un SOS lo sigue solo (se puede dejar de seguir).
create or replace function public.iniciar_chat_sos(p_sos uuid)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  autor uuid;
  conv uuid;
begin
  if yo is null then raise exception 'Hace falta una sesión' using errcode = '42501'; end if;
  select user_id into autor from public.sos_reports
    where id = p_sos and status = 'active';
  if autor is null then
    raise exception 'El reporte no está activo' using errcode = 'P0002';
  end if;
  if autor = yo then
    raise exception 'Es tu propio reporte' using errcode = '22023';
  end if;
  insert into public.sos_follows (sos_id, user_id) values (p_sos, yo)
    on conflict do nothing;
  select id into conv from public.conversations
    where kind = 'sos' and context_id = p_sos and created_by = yo;
  if conv is not null then
    return conv;
  end if;
  if (select count(*) from public.conversations
      where created_by = yo and created_at > now() - interval '1 day') >= 10 then
    raise exception 'Demasiados chats nuevos hoy' using errcode = '54000';
  end if;
  insert into public.conversations (kind, context_id, created_by)
    values ('sos', p_sos, yo) returning id into conv;
  insert into public.conversation_members (conversation_id, user_id, last_read_at)
    values (conv, yo, now()), (conv, autor, null);
  return conv;
end;
$$;
