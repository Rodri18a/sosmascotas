-- Sin recompensa en los SOS (D119): la app es una red de apoyo entre vecinos,
-- y una recompensa a la vista atrae estafas ("la tengo, pasame la plata").
-- La columna queda (no se rompe nada), pero siempre vacía: se borran las que
-- había y un trigger la vacía aunque la mande una versión vieja de la app.

update public.sos_reports set reward = null where reward is not null;

create function public.sos_sin_recompensa()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.reward := null;
  return new;
end;
$$;

revoke all on function public.sos_sin_recompensa() from public, anon, authenticated;

create trigger sos_reports_sin_recompensa
  before insert or update of reward on public.sos_reports
  for each row execute function public.sos_sin_recompensa();
