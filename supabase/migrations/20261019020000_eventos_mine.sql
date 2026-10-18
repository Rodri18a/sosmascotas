-- eventos_en_zona(): para un visitante, `mine` daba null en vez de false.
create or replace function public.eventos_en_zona(
  p_min_lat double precision, p_min_lng double precision,
  p_max_lat double precision, p_max_lng double precision
)
returns table (id uuid, kind text, title text, description text, starts_at timestamptz,
               ends_at timestamptz, lat double precision, lng double precision, address text,
               link text, organizador text, mine boolean)
language sql stable security definer set search_path = ''
as $$
  select e.id, e.kind, e.title, e.description, e.starts_at, e.ends_at,
         extensions.st_y(e.location::extensions.geometry), extensions.st_x(e.location::extensions.geometry),
         e.address, e.link, b.name, coalesce(e.organizer_id = (select auth.uid()), false)
  from public.events_calendar e
  left join public.businesses b on b.id = e.business_id
  where e.status = 'active' and e.ends_at > now()
    and e.location operator(extensions.&&)
        extensions.st_makeenvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326)::extensions.geography
  order by e.starts_at
  limit 100;
$$;
