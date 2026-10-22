-- Etapa 1.8b (1.8b.1–1.8b.3, D95): chapitas físicas pre-codificadas.
-- La administración genera lotes de códigos sin mascota (kind = 'physical');
-- el productor imprime cada código en una chapita; el dueño la escanea y la
-- vincula a su mascota desde la app. Un código se activa UNA sola vez:
-- desvincularlo lo deja inactivo para siempre (si se pierde, nadie la reusa).

-- ---------------------------------------------------------------------
-- Lotes
-- ---------------------------------------------------------------------
create table public.qr_batches (
  id          uuid primary key default gen_random_uuid(),
  quantity    int not null check (quantity between 1 and 500),
  producer    text check (char_length(producer) <= 100),
  material    text check (char_length(material) <= 100),
  unit_cost   numeric(10, 2) check (unit_cost >= 0),
  sponsor_id  uuid references public.businesses (id) on delete set null,  -- Fase 2 (2.9)
  note        text check (char_length(note) <= 300),
  created_by  uuid references auth.users (id) on delete set null,
  created_at  timestamptz not null default now()
);

comment on table public.qr_batches is 'Lotes de chapitas físicas. Solo la administración, por funciones.';

alter table public.qr_batches enable row level security;
-- Sin políticas: solo las funciones de abajo (y el panel de Supabase).
revoke all on public.qr_batches from anon, authenticated;

alter table public.qr_tags
  add constraint qr_tags_batch_fk foreign key (batch_id)
  references public.qr_batches (id) on delete restrict;

create index qr_tags_batch_idx on public.qr_tags (batch_id) where batch_id is not null;

-- Crea un lote con sus códigos (sin mascota ni dueño hasta que se activen).
create function public.admin_crear_lote(
  p_cantidad int,
  p_productor text default null,
  p_material text default null,
  p_costo numeric default null,
  p_nota text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := public.exigir_admin();
  lote uuid;
begin
  if p_cantidad is null or p_cantidad not between 1 and 500 then
    raise exception 'La cantidad va de 1 a 500' using errcode = '22023';
  end if;

  insert into public.qr_batches (quantity, producer, material, unit_cost, note, created_by)
  values (p_cantidad, nullif(trim(p_productor), ''), nullif(trim(p_material), ''),
          p_costo, nullif(trim(p_nota), ''), yo)
  returning id into lote;

  -- De a uno: generar_codigo_qr() verifica que el código no exista, y eso
  -- solo ve los que ya se insertaron.
  for i in 1..p_cantidad loop
    insert into public.qr_tags (code, kind, batch_id, active)
    values (public.generar_codigo_qr(), 'physical', lote, true);
  end loop;

  perform public.registrar_accion('batch_create', 'qr_batch', lote::text,
                                  jsonb_build_object('cantidad', p_cantidad));
  return lote;
end;
$$;

-- Lotes con sus resultados (para el productor y, en la Fase 2, para el sponsor).
create function public.admin_lotes()
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
      'activadas', (select count(*) from public.qr_tags t
                    where t.batch_id = b.id and t.activated_at is not null),
      'escaneos', (select count(*) from public.qr_scans s
                   join public.qr_tags t on t.id = s.qr_id
                   where t.batch_id = b.id)
    ) order by b.created_at desc)
    from public.qr_batches b
  ), '[]'::jsonb);
end;
$$;

-- Los códigos de un lote, en orden, para exportar al productor.
create function public.admin_codigos_lote(p_lote uuid)
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
      'code', t.code,
      'activada', t.activated_at is not null
    ) order by t.created_at, t.code)
    from public.qr_tags t
    where t.batch_id = p_lote
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.admin_crear_lote(int, text, text, numeric, text) from public, anon;
revoke all on function public.admin_lotes() from public, anon;
revoke all on function public.admin_codigos_lote(uuid) from public, anon;
grant execute on function public.admin_crear_lote(int, text, text, numeric, text) to authenticated;
grant execute on function public.admin_lotes() to authenticated;
grant execute on function public.admin_codigos_lote(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- Activar y desvincular (dueño de la mascota)
-- ---------------------------------------------------------------------
-- Errores con mensaje fijo para que la app muestre el texto que corresponde:
-- chapita_inexistente, chapita_usada, limite_chapitas.
create function public.activar_chapita(p_code text, p_pet_id uuid)
returns uuid
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  yo uuid := (select auth.uid());
  tag public.qr_tags;
begin
  if yo is null then
    raise exception 'Hace falta una cuenta' using errcode = '42501';
  end if;
  if not exists (select 1 from public.pets where id = p_pet_id and owner_id = yo) then
    raise exception 'No es tu mascota' using errcode = '42501';
  end if;
  -- Tope contra intentos en masa: 20 activaciones por día por cuenta.
  if (select count(*) from public.qr_tags
      where owner_id = yo and kind = 'physical'
        and activated_at > now() - interval '1 day') >= 20 then
    raise exception 'limite_chapitas' using errcode = 'P0001';
  end if;

  select * into tag from public.qr_tags
  where code = upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'))
    and kind = 'physical'
  for update;
  if not found then
    raise exception 'chapita_inexistente' using errcode = 'P0001';
  end if;
  if tag.activated_at is not null or tag.pet_id is not null or not tag.active then
    raise exception 'chapita_usada' using errcode = 'P0001';
  end if;

  update public.qr_tags
     set pet_id = p_pet_id, owner_id = yo, activated_at = now()
   where id = tag.id;
  return tag.id;
end;
$$;

-- Deja la chapita inactiva para siempre (no vuelve a quedar "sin activar").
create function public.desvincular_chapita(p_tag uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  update public.qr_tags t
     set active = false
   where t.id = p_tag
     and t.kind = 'physical'
     and exists (select 1 from public.pets p
                 where p.id = t.pet_id and p.owner_id = (select auth.uid()));
  if not found then
    raise exception 'No es tu chapita' using errcode = '42501';
  end if;
end;
$$;

revoke all on function public.activar_chapita(text, uuid) from public, anon;
revoke all on function public.desvincular_chapita(uuid) from public, anon;
grant execute on function public.activar_chapita(text, uuid) to authenticated;
grant execute on function public.desvincular_chapita(uuid) to authenticated;

-- Desde la app, `active` se cambiaba a mano (grant de 0.4.1). Para las chapitas
-- físicas eso permitiría reactivar una desvinculada: solo por las funciones.
create function public.qr_fisica_sin_reactivar()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.kind = 'physical' and new.active and not old.active
     and (select auth.role()) = 'authenticated' then
    raise exception 'Una chapita desvinculada no se puede volver a usar' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger qr_tags_fisica_sin_reactivar
  before update of active on public.qr_tags
  for each row execute function public.qr_fisica_sin_reactivar();

-- ---------------------------------------------------------------------
-- Página pública: una chapita que ya se usó (mascota borrada o desvinculada)
-- no vuelve a figurar "sin activar". Se agrega `kind` para el texto.
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
begin
  select * into tag from public.qr_tags where code = upper(trim(p_code));
  if not found then
    return jsonb_build_object('status', 'not_found');
  end if;
  if tag.pet_id is null and tag.activated_at is null and tag.active then
    return jsonb_build_object('status', 'unactivated', 'code', tag.code);
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
      'public_note', tag.public_note
    ),
    'lost', sos_activo is not null,
    'sos_id', sos_activo
  );
end;
$$;
