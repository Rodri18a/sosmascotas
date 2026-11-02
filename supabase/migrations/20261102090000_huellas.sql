-- Plan de mejoras 3.3 (D138): «Tus huellas». Insignias que se ganan solas por
-- cuidar y ayudar, y un contador de ayudas. Cada persona ve solo las suyas:
-- no hay rankings ni comparación, y nadie más las ve. Sin tablas nuevas: se
-- calcula con lo que ya existe. Nunca se gana por mirar publicidad (24 §4).
create function public.mis_huellas()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  avisos integer;
  respuestas integer;
  compartidos integer;
begin
  if yo is null then
    raise exception 'Hace falta una sesión' using errcode = '42501';
  end if;
  -- Avisos que mandé a dueños (sin los marcados como estafa).
  select count(*) into avisos from public.owner_alerts
   where from_user_id = yo and status <> 'scam_reported';
  select count(*) into respuestas from public.community_comments
   where author_id = yo and status = 'active';
  select count(*) into compartidos from public.events
   where user_id = yo and name in ('sos_share', 'sos_poster');
  return jsonb_build_object(
    'ayudas', avisos + respuestas + compartidos,
    'insignias', jsonb_build_object(
      -- Nombre, zona y una mascota con foto.
      'perfil', exists (select 1 from public.profiles p
                        where p.id = yo and p.display_name is not null and p.zone_id is not null)
                and exists (select 1 from public.pets where owner_id = yo and photo_path is not null),
      -- Al menos un registro en la libreta y ninguna próxima fecha vencida.
      'libreta', exists (select 1 from public.health_records h
                         join public.pets p on p.id = h.pet_id where p.owner_id = yo)
                 and not exists (select 1 from public.health_records h
                                 join public.pets p on p.id = h.pet_id
                                 where p.owner_id = yo and h.next_date < current_date),
      -- Una chapita física vinculada a una mascota.
      'chapita', exists (select 1 from public.qr_tags
                         where owner_id = yo and kind = 'physical' and pet_id is not null and active),
      'difusor', compartidos > 0,
      -- A alguien le sirvió una respuesta mía.
      'respuesta', exists (select 1 from public.community_posts q
                           join public.community_comments c on c.id = q.solved_comment_id
                           where c.author_id = yo),
      -- Avisé a una familia y la mascota volvió (SOS resuelto o el dueño respondió al aviso del QR).
      'reencuentro', exists (select 1 from public.owner_alerts a
                             left join public.sos_reports s on a.target_type = 'sos' and s.id = a.target_id
                             where a.from_user_id = yo
                               and ((a.target_type = 'sos' and s.status = 'resolved')
                                    or (a.target_type = 'qr' and a.status = 'replied')))));
end;
$$;

revoke all on function public.mis_huellas() from public, anon;
grant execute on function public.mis_huellas() to authenticated;

-- Funcionalidad gradual (D64): prendida para todos.
insert into public.feature_flags (key, description, stage)
values ('huellas', '«Tus huellas»: insignias por cuidar y ayudar, sin rankings (plan de mejoras 3.3, D138)', 'todos')
on conflict (key) do nothing;
