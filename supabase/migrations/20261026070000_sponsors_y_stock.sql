-- Paso 2.9 (D105): sponsors de chapitas y stock en las veterinarias.
-- Un sponsor (una marca o un comercio) paga un lote: su logo va en el reverso
-- de la chapita y, en la página del QR, chico y abajo (06-reglas-negocio).
-- La administración le arma el reporte de su lote: activadas, escaneos y
-- reencuentros, sin ningún dato de las familias.
-- Stock: la administración le pasa chapitas en blanco de un lote a una
-- veterinaria verificada; el dueño la activa en el local (como cualquier
-- chapita) o la veterinaria la entrega desde su stock para un pedido.
-- La venta de diseños personalizados queda para después de formalizar (P16).
-- Tablas sin acceso directo: todo por funciones, cada una con su permiso.

-- ---------------------------------------------------------------------
-- Sponsors
-- ---------------------------------------------------------------------
create table public.sponsors (
  id           uuid primary key default gen_random_uuid(),
  name         text not null check (char_length(trim(name)) between 1 and 80),
  logo_path    text check (char_length(logo_path) <= 200),
  business_id  uuid references public.businesses (id) on delete set null,
  notes        text check (char_length(notes) <= 500),  -- privado: contacto, acuerdo
  active       boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.sponsors is 'Sponsors de lotes de chapitas. Solo la administración, por funciones.';

alter table public.sponsors enable row level security;
-- Sin políticas: solo las funciones de abajo.
revoke all on public.sponsors from anon, authenticated;

create trigger sponsors_updated_at
  before update on public.sponsors
  for each row execute function public.set_updated_at();

-- El lote apuntaba a un comercio (1.8b.1); ahora apunta al sponsor (que puede
-- ser un comercio o no). Nunca se cargó ninguno.
alter table public.qr_batches drop constraint qr_batches_sponsor_id_fkey;
update public.qr_batches set sponsor_id = null where sponsor_id is not null;
alter table public.qr_batches
  add constraint qr_batches_sponsor_fk foreign key (sponsor_id)
  references public.sponsors (id) on delete set null;

-- Logos: públicos (la página del QR los muestra), solo los sube la administración.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('sponsor-logos', 'sponsor-logos', true, 524288, array['image/png', 'image/jpeg', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "admin_sube_logos" on storage.objects for insert to authenticated
  with check (bucket_id = 'sponsor-logos' and public.es_admin());
create policy "admin_cambia_logos" on storage.objects for update to authenticated
  using (bucket_id = 'sponsor-logos' and public.es_admin());
create policy "admin_borra_logos" on storage.objects for delete to authenticated
  using (bucket_id = 'sponsor-logos' and public.es_admin());

-- ---------------------------------------------------------------------
-- Stock en veterinarias
-- ---------------------------------------------------------------------
alter table public.qr_tags
  add column stock_business_id uuid references public.businesses (id) on delete set null,
  add column stock_at timestamptz;

comment on column public.qr_tags.stock_business_id is
  'Chapita física en blanco que tiene una veterinaria para activar en el local.';

create index qr_tags_stock_idx on public.qr_tags (stock_business_id)
  where stock_business_id is not null;

-- Una chapita libre: física, sin activar, sin stock y sin reservar en un pedido.
create function public.chapita_libre(p_tag uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.qr_tags t
    where t.id = p_tag and t.kind = 'physical' and t.active
      and t.pet_id is null and t.activated_at is null and t.stock_business_id is null
      and not exists (select 1 from public.tag_orders o where o.tag_id = t.id));
$$;

revoke all on function public.chapita_libre(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Resultados de un lote (los mismos para el portal y para el sponsor)
-- ---------------------------------------------------------------------
-- Reencuentro: un SOS de "se perdió" de una mascota con una chapita del lote,
-- publicado después de activarla y marcado "¡Apareció!".
create function public.resultados_lote(p_lote uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'activadas', (select count(*) from public.qr_tags t
                  where t.batch_id = p_lote and t.activated_at is not null),
    'escaneos', (select count(*) from public.qr_scans s
                 join public.qr_tags t on t.id = s.qr_id
                 where t.batch_id = p_lote),
    'reencuentros', (select count(distinct r.id) from public.sos_reports r
                     join public.qr_tags t on t.pet_id = r.pet_id
                     where t.batch_id = p_lote and t.activated_at is not null
                       and r.kind = 'lost' and r.status = 'resolved'
                       and r.created_at >= t.activated_at),
    'en_stock', (select count(*) from public.qr_tags t
                 where t.batch_id = p_lote and t.stock_business_id is not null
                   and t.activated_at is null and t.active));
$$;

revoke all on function public.resultados_lote(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Administración: sponsors
-- ---------------------------------------------------------------------
create function public.admin_sponsors()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', s.id, 'name', s.name, 'logo_path', s.logo_path, 'business_id', s.business_id,
      'business_name', b.name, 'notes', s.notes, 'active', s.active, 'created_at', s.created_at,
      'lotes', (select count(*) from public.qr_batches q where q.sponsor_id = s.id),
      'chapitas', (select coalesce(sum(q.quantity), 0) from public.qr_batches q
                   where q.sponsor_id = s.id)
    ) order by s.active desc, s.name)
    from public.sponsors s
    left join public.businesses b on b.id = s.business_id
  ), '[]'::jsonb);
end;
$$;

-- Crea (sin `id`) o actualiza. Devuelve el id.
create function public.admin_guardar_sponsor(p jsonb)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  id_ uuid := nullif(p ->> 'id', '')::uuid;
  logo text := nullif(trim(p ->> 'logo_path'), '');
begin
  perform public.exigir_admin();
  if logo is not null and logo !~ '^[A-Za-z0-9_-]+\.(png|jpe?g|webp)$' then
    raise exception 'logo_invalido' using errcode = '22023';
  end if;
  if id_ is null then
    insert into public.sponsors (name, logo_path, business_id, notes, active)
    values (trim(p ->> 'name'), logo, nullif(p ->> 'business_id', '')::uuid,
            nullif(trim(p ->> 'notes'), ''), coalesce((p ->> 'active')::boolean, true))
    returning id into id_;
  else
    update public.sponsors
       set name = trim(p ->> 'name'), logo_path = logo,
           business_id = nullif(p ->> 'business_id', '')::uuid,
           notes = nullif(trim(p ->> 'notes'), ''),
           active = coalesce((p ->> 'active')::boolean, active)
     where id = id_;
    if not found then
      raise exception 'No existe ese sponsor' using errcode = 'P0002';
    end if;
  end if;
  perform public.registrar_accion('guardar_sponsor', 'sponsor', id_::text,
                                  jsonb_build_object('name', p ->> 'name'));
  return id_;
end;
$$;

-- Le pone (o le quita, con null) el sponsor a un lote.
create function public.admin_sponsor_lote(p_lote uuid, p_sponsor uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  update public.qr_batches set sponsor_id = p_sponsor where id = p_lote;
  if not found then
    raise exception 'No existe ese lote' using errcode = 'P0002';
  end if;
  perform public.registrar_accion('sponsor_lote', 'qr_batch', p_lote::text,
                                  jsonb_build_object('sponsor', p_sponsor));
end;
$$;

-- El reporte para mandarle al sponsor: sus lotes con los resultados.
create function public.admin_reporte_sponsor(p_sponsor uuid)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  s public.sponsors;
  lotes jsonb;
begin
  perform public.exigir_admin();
  select * into s from public.sponsors where id = p_sponsor;
  if not found then
    raise exception 'No existe ese sponsor' using errcode = 'P0002';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', b.id, 'created_at', b.created_at, 'quantity', b.quantity,
           'material', b.material) || public.resultados_lote(b.id)
         order by b.created_at), '[]'::jsonb)
    into lotes
  from public.qr_batches b
  where b.sponsor_id = p_sponsor;
  perform public.registrar_accion('reporte_sponsor', 'sponsor', p_sponsor::text, '{}'::jsonb);
  return jsonb_build_object('name', s.name, 'logo_path', s.logo_path,
                            'generated_at', now(), 'lotes', lotes);
end;
$$;

-- Lotes con sus resultados y su sponsor (reemplaza el de 1.8b.1).
create or replace function public.admin_lotes()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', b.id,
      'quantity', b.quantity,
      'producer', b.producer,
      'material', b.material,
      'unit_cost', b.unit_cost,
      'note', b.note,
      'created_at', b.created_at,
      'sponsor_id', b.sponsor_id,
      'sponsor_name', s.name
    ) || public.resultados_lote(b.id) order by b.created_at desc)
    from public.qr_batches b
    left join public.sponsors s on s.id = b.sponsor_id
  ), '[]'::jsonb);
end;
$$;

-- ---------------------------------------------------------------------
-- Administración: stock
-- ---------------------------------------------------------------------
-- Pasa [p_cantidad] chapitas libres del lote a una veterinaria verificada.
-- Devuelve los códigos, para entregarle justo esas.
create function public.admin_asignar_stock(p_lote uuid, p_business uuid, p_cantidad int)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  codigos jsonb;
begin
  perform public.exigir_admin();
  if p_cantidad is null or p_cantidad not between 1 and 200 then
    raise exception 'La cantidad va de 1 a 200' using errcode = '22023';
  end if;
  if not exists (select 1 from public.businesses
                 where id = p_business and business_type = 'vet'
                   and verification = 'verified' and status = 'active') then
    raise exception 'solo_verificadas' using errcode = 'P0001';
  end if;

  with elegidas as (
    select t.id from public.qr_tags t
    where t.batch_id = p_lote and public.chapita_libre(t.id)
    order by t.created_at, t.code
    limit p_cantidad
    for update skip locked
  )
  update public.qr_tags t
     set stock_business_id = p_business, stock_at = now()
    from elegidas e
   where t.id = e.id;

  select coalesce(jsonb_agg(t.code order by t.code), '[]'::jsonb) into codigos
  from public.qr_tags t
  where t.batch_id = p_lote and t.stock_business_id = p_business
    and t.stock_at = now() and t.activated_at is null;

  if jsonb_array_length(codigos) < p_cantidad then
    raise exception 'no_alcanzan' using errcode = 'P0001';
  end if;
  perform public.registrar_accion('asignar_stock', 'business', p_business::text,
                                  jsonb_build_object('lote', p_lote, 'cantidad', p_cantidad));
  return codigos;
end;
$$;

-- Una chapita del stock que la veterinaria devolvió (o se perdió) vuelve a quedar libre.
create function public.admin_quitar_stock(p_code text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  tag uuid;
begin
  perform public.exigir_admin();
  update public.qr_tags
     set stock_business_id = null, stock_at = null
   where code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
     and kind = 'physical' and stock_business_id is not null and activated_at is null
  returning id into tag;
  if tag is null then
    raise exception 'chapita_no_disponible' using errcode = 'P0001';
  end if;
  perform public.registrar_accion('quitar_stock', 'qr_tag', tag::text,
                                  jsonb_build_object('code', p_code));
end;
$$;

-- Stock por veterinaria: cuántas le pasaron, cuántas le quedan y cuántas se activaron.
create function public.admin_stock()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.exigir_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'business_id', b.id, 'business_name', b.name, 'address', b.address,
      'recibidas', x.recibidas, 'disponibles', x.disponibles, 'activadas', x.activadas,
      'ultima', x.ultima
    ) order by x.disponibles, b.name)
    from (
      select t.stock_business_id as id,
             count(*) as recibidas,
             count(*) filter (where t.activated_at is null and t.active) as disponibles,
             count(*) filter (where t.activated_at is not null) as activadas,
             max(t.stock_at) as ultima
      from public.qr_tags t
      where t.stock_business_id is not null
      group by t.stock_business_id
    ) x
    join public.businesses b on b.id = x.id
  ), '[]'::jsonb);
end;
$$;

-- Al mandar un pedido, la chapita no puede estar en el stock de una veterinaria.
create or replace function public.admin_enviar_pedido_chapita(p_id uuid, p_code text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  tag uuid;
begin
  perform public.exigir_admin();
  select t.id into tag from public.qr_tags t
  where t.code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
    and public.chapita_libre(t.id)
  for update;
  if not found then
    raise exception 'chapita_no_disponible' using errcode = 'P0001';
  end if;
  update public.tag_orders set tag_id = tag, status = 'sent'
   where id = p_id and status = 'new';
  if not found then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  perform public.registrar_accion('enviar_chapita', 'tag_order', p_id::text,
                                  jsonb_build_object('code', p_code));
end;
$$;

-- ---------------------------------------------------------------------
-- Veterinaria
-- ---------------------------------------------------------------------
-- Lo de 1.8b.4 más su stock (disponibles y activadas).
create or replace function public.pedidos_chapita_del_negocio(p_business uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  b public.businesses;
begin
  if not public.soy_duenio_de(p_business) then
    raise exception 'No es tu negocio' using errcode = '42501';
  end if;
  select * into b from public.businesses where id = p_business;
  return jsonb_build_object(
    'punto_retiro', b.tag_pickup,
    'puede_ser', b.business_type = 'vet' and b.verification = 'verified',
    'stock', (
      select jsonb_build_object(
               'disponibles', count(*) filter (where t.activated_at is null and t.active),
               'activadas', count(*) filter (where t.activated_at is not null))
      from public.qr_tags t
      where t.stock_business_id = p_business),
    'pedidos', (
      select coalesce(jsonb_agg(jsonb_build_object(
               'id', o.id, 'number', o.number,
               'cliente', split_part(coalesce(pr.display_name, ''), ' ', 1),
               'pet_name', p.name, 'engraving', o.engraving, 'status', o.status,
               'code', t.code, 'created_at', o.created_at, 'updated_at', o.updated_at)
             order by o.status = 'delivered', o.created_at desc), '[]'::jsonb)
      from public.tag_orders o
      join public.pets p on p.id = o.pet_id
      left join public.profiles pr on pr.id = o.owner_id
      left join public.qr_tags t on t.id = o.tag_id
      where o.business_id = p_business
        and (o.status in ('new', 'sent', 'ready')
             or (o.status = 'delivered' and o.updated_at > now() - interval '30 days'))));
end;
$$;

-- Un pedido nuevo que la veterinaria entrega con una chapita de su stock:
-- queda vinculada a la mascota en ese momento (sin pasar por la administración).
create function public.negocio_entregar_de_stock(p_id uuid, p_code text)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  o public.tag_orders;
  tag uuid;
begin
  select * into o from public.tag_orders where id = p_id for update;
  if not found or not public.soy_duenio_de(o.business_id) then
    raise exception 'No es un pedido de tu negocio' using errcode = '42501';
  end if;
  if o.status <> 'new' then
    raise exception 'estado_invalido' using errcode = 'P0001';
  end if;
  update public.qr_tags t
     set pet_id = o.pet_id, owner_id = o.owner_id, activated_at = now()
   where t.code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
     and t.kind = 'physical' and t.active and t.pet_id is null and t.activated_at is null
     and t.stock_business_id = o.business_id
     and not exists (select 1 from public.tag_orders x where x.tag_id = t.id)
  returning t.id into tag;
  if tag is null then
    raise exception 'no_esta_en_tu_stock' using errcode = 'P0001';
  end if;
  update public.tag_orders set tag_id = tag, status = 'delivered' where id = p_id;
end;
$$;

-- ---------------------------------------------------------------------
-- Página pública: el sponsor del lote, chico y abajo (solo nombre y logo)
-- ---------------------------------------------------------------------
create or replace function public.public_pet_page(p_code text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  tag public.qr_tags;
  mascota record;
  sos_activo uuid;
  sponsor jsonb;
begin
  select * into tag from public.qr_tags where code = upper(trim(p_code));
  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;

  select jsonb_build_object('name', s.name, 'logo_path', s.logo_path) into sponsor
  from public.qr_batches b
  join public.sponsors s on s.id = b.sponsor_id and s.active
  where b.id = tag.batch_id;

  if tag.pet_id is null and tag.activated_at is null and tag.active then
    return jsonb_strip_nulls(jsonb_build_object('status', 'unactivated', 'code', tag.code,
                                                'sponsor', sponsor));
  end if;
  if tag.pet_id is null or not tag.active then
    return jsonb_build_object('status', 'inactive', 'kind', tag.kind);
  end if;

  select p.name, p.color, p.marks, p.photo_path, p.sex,
         (p.microchip is not null) as has_microchip,
         s.name as species, s.icon as species_icon,
         coalesce(b.name, p.breed_other) as breed
    into mascota
  from public.pets p
  join public.species s on s.id = p.species_id
  left join public.breeds b on b.id = p.breed_id
  where p.id = tag.pet_id;

  select r.id into sos_activo
  from public.sos_reports r
  where r.pet_id = tag.pet_id and r.kind = 'lost' and r.status = 'active'
  order by r.created_at desc
  limit 1;

  return jsonb_build_object(
    'status', 'active',
    'code', tag.code,
    'pet', jsonb_build_object(
      'name', mascota.name,
      'species', mascota.species,
      'species_icon', mascota.species_icon,
      'breed', mascota.breed,
      'sex', mascota.sex,
      'color', mascota.color,
      'marks', mascota.marks,
      'photo_path', mascota.photo_path,
      'has_microchip', mascota.has_microchip,
      -- La nota la escribe el dueño en el QR digital: vale para todas sus chapitas.
      'public_note', coalesce(tag.public_note, (
        select q.public_note from public.qr_tags q
        where q.pet_id = tag.pet_id and q.kind = 'digital' and q.active
        limit 1))
    ),
    'lost', sos_activo is not null,
    'sos_id', sos_activo
  ) || case when sponsor is null then '{}'::jsonb
            else jsonb_build_object('sponsor', sponsor) end;
end;
$$;

-- ---------------------------------------------------------------------
-- Permisos
-- ---------------------------------------------------------------------
do $$
declare
  f text;
begin
  foreach f in array array[
    'admin_sponsors()', 'admin_guardar_sponsor(jsonb)', 'admin_sponsor_lote(uuid, uuid)',
    'admin_reporte_sponsor(uuid)', 'admin_asignar_stock(uuid, uuid, int)',
    'admin_quitar_stock(text)', 'admin_stock()', 'negocio_entregar_de_stock(uuid, text)'
  ] loop
    execute format('revoke all on function public.%s from public, anon', f);
    execute format('grant execute on function public.%s to authenticated', f);
  end loop;
end $$;
