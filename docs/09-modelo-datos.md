# 09 · Modelo de datos (Supabase / Postgres + PostGIS)

Propuesta inicial. Se ajusta al implementar cada fase. **RLS activado en todas las tablas.** Las ubicaciones usan `geography(Point)` de PostGIS. Todas las tablas tienen `created_at` y `updated_at`.

## Cuentas y zonas

| Tabla | Campos clave | Fase |
|---|---|---|
| `zones` | id, slug, name, country, timezone, currency, area (multipolígono), active — ✅ creada en 0.1.7 (Pando) | 0 |
| `profiles` | id (auth), display_name, avatar_path, role (`user`, `admin`), zone_id, plan (`free`, `pro`, `family`), prefs (idioma, color, letra), approx_location (centro de una celda de ~500 m, **privada**), approx_location_source (`gps`, `mapa`), approx_location_at, alert_radius_km (1–20, por defecto 5), terms_version, terms_accepted_at, created_at, updated_at — ✅ 0.2.1 / zona ✅ 0.6.2. Cada uno ve y edita solo el suyo; `role` y `plan` no se editan desde la app. La zona solo se cambia con `guardar_zona_aproximada()` (redondea con `celda_zona()`, igual que `zonaAproximada()` en `packages/core`) y `borrar_zona_aproximada()` (D56) | 0 |
| `private_contacts` | user_id, phone, whatsapp, show_whatsapp_direct (bool, por defecto `false`) — **solo accesible desde Edge Functions** (✅ 0.2.1: RLS sin políticas). Cuando el dueño cargue su teléfono, será con una función del servidor | 0 |
| `push_tokens` | token (clave), user_id, platform, created_at, last_seen_at. Se guarda solo con `guardar_push_token()` (pasa el token a la cuenta actual, máximo 10 por persona); cada uno ve y borra los suyos — ✅ 0.6.1 | 0 |

## Mascotas y hogar

| Tabla | Campos clave | Fase |
|---|---|---|
| `species` | id, slug, name, icon, sort — ✅ 0.3.1 (10 especies) | 0 |
| `breeds` | id, species_id, name, sort — ✅ 0.3.1 (~60 razas; si no está, `pets.breed_other`) | 0 |
| `pets` | id, household_id (Fase 1), owner_id, name, species_id, breed_id (de la misma especie: FK compuesta), breed_other, sex, color, marks, birth, photo_path, microchip (15 dígitos), renac_status (`registered`, `not_registered`, `unknown`, Fase 1), neutered, notes, vet_business_id (Fase 1) — ✅ 0.3.2. Privada: cada dueño ve solo las suyas. Fotos en el bucket público `pet-photos/<user_id>/` (nombres al azar) | 0 |
| `qr_tags` | id, code (8 caracteres sin ambiguos, único), pet_id (**nullable** hasta activarse), owner_id, kind (`digital`, `physical`), batch_id, active, activated_at, public_note (lo que el dueño elige mostrar, ≤ 200) — ✅ 0.4.1. Se crea solo al crear la mascota; `regenerar_qr()`; lo público sale de `public_pet_page()` (sin teléfono, sin número de chip) | 0 (digital) / 1 (física) |
| `qr_batches` | id, quantity, producer, material, sponsor_id (opcional), unit_cost, created_at | 1 |
| `qr_pickups` | id, order_id o tag_id, business_id (veterinaria punto de retiro), status (`sent`, `ready`, `delivered`), delivered_at | 1 |
| `qr_scans` | id, qr_id, owner_id, pet_id, shared_location, shared_at, created_at — ✅ 0.4.5. `registrar_escaneo()` (tope 60/h por QR) y `compartir_ubicacion_escaneo()` (una vez, dentro de 30 min); solo el dueño los ve (`qr_scans_app`) | 0 |
| `households` | id, owner_id, plan_status, trial_until | 1 |
| `household_members` | household_id, user_id, role (`owner`, `member`, `temp_caregiver`), access_until | 1 |
| `health_records` | id, pet_id, kind (`vaccine`, `deworming`, `checkup`, `allergy`, `other`), name, date, next_date, notes | 1 |
| `reminders` | id, pet_id, kind (`medication`, `food`, `vaccine`, `checkup`), title, dose, schedule (rrule), start, end, assigned_to | 1 |
| `reminder_logs` | id, reminder_id, done_by, done_at | 1 |
| `household_tasks` | id, household_id, pet_id, kind (`walk`, `food`, …), assigned_to, date, done_by, done_at | 1 |

## SOS

| Tabla | Campos clave | Fase |
|---|---|---|
| `sos_reports` | id, kind (`lost`, `found`), user_id, pet_id (opcional, propia), species_id, breed_id, breed_other, name, sex, color, marks, description, reward, has_microchip, exact_location (**privada**), public_location (desplazada 150–200 m al azar), zone_id, happened_at, status (`active`, `resolved`, `archived`, `hidden`), created_at, last_activity_at, resolved_at — ✅ 0.5.1. **Sin acceso directo**: se publica con `crear_sos()` (≥ 1 foto propia, máx. 3/día) y se lee con funciones (`mis_sos()`, y las públicas de 0.5.4–0.5.5) | 0 |
| `sos_photos` | id, report_id, path, sort — ✅ 0.5.1 (bucket `sos-photos`, carpeta por usuario) | 0 |
| `owner_alerts` | id, target_type (`sos`, `qr`), target_id, owner_id, pet_id, from_user_id (nullable), sender_name, sender_contact (**privada**, solo la ve el dueño), message, photo_path, location (si quien avisa la compartió), device_hash (SHA-256 de IP + navegador), status (`new`, `seen`, `replied`, `scam_reported`), created_at — ✅ 0.4.4. Solo la crea la Edge Function `owner-alert`; el dueño lee (vista `owner_alerts_app`) y cambia el estado | 0 |
| `blocked_senders` | owner_id, device_hash — se llena al marcar un aviso como estafa; solo la usa `owner-alert` (descarta en silencio) — ✅ 0.4.4 | 0 |
| `sos_followers` | report_id, user_id | 1 |
| `help_directory` | id, zone_id, name, kind (refugio, protectora, grupo, emergencia), contact, link | 0 |

## Empresas y lugares

| Tabla | Campos clave | Fase |
|---|---|---|
| `businesses` | id, owner_id, kind (`local`, `online`, `domicilio`), business_type, name, description, address, location, coverage_area, zone_id, hours (json por día), is_24h, species_ids[], plan (`basic`, `featured`, `plus`), verification (`unverified`, `pending`, `verified`), rut, renac_operator (bool, verificado por admin), founder_until, promo, web, instagram, facebook, status (`active`, `hidden`) | 0 (mínima) / 1 |
| `business_contacts_private` | business_id, whatsapp, phone | 1 |
| `business_photos` | id, business_id, path, order | 1 |
| `place_marks` | id, user_id, category, location, google_link, business_id (cuando se reclama) | 1 |
| `claims` | id, business_id o place_mark_id, user_id, rut, evidence_path, status | 1 |
| `business_modules` | business_id, module (`catalog`, `agenda`, `members`), enabled | 2 |
| `user_places` | user_id, business_id, favorite, visited, is_my_vet | 1 |
| `reviews` | id, business_id, user_id, rating, comment, reply, reply_at, status | 1 |
| `promotions` | id, business_id, title, body, starts_at, ends_at, species_ids[], code | 2 |
| `pet_friendly_places` | se modelan como `businesses` con business_type `pet_friendly` | 2 |

## Chat

| Tabla | Campos clave | Fase |
|---|---|---|
| `conversations` | id, kind (`sos`, `business`, `user`), context_id, created_by | 1 |
| `conversation_members` | conversation_id, user_id, last_read_at, blocked | 1 |
| `messages` | id, conversation_id, sender_id, body, attachment_path, location, created_at | 1 |

## Comercio: catálogo, agenda, pedidos, socios

| Tabla | Campos clave | Fase |
|---|---|---|
| `catalog_items` | id, business_id, name, description, price, photo_path, available, species_ids[] | 2 |
| `agenda_config` | business_id, days[], from_time, to_time, slot_minutes, services[] | 3 |
| `bookings` | id, business_id, user_id, pet_id, date, time, service, status (`pending`, `confirmed`, `rejected`, `cancelled`, `done`) | 3 |
| `orders` / `order_items` | cliente, negocio, estado (`new`, `preparing`, `ready`, `delivered`), total, ítems | 3 |
| `vet_members` | business_id, pet_id, since | 2 |
| `offer_consents` | pet_id, user_id, scope (`vet`, luego otros rubros), granted_at, revoked_at, last_prompt_at, snoozed_until | 2 |
| `business_offers` | id, business_id, title, body, target (zona, radio, especies), starts_at, ends_at | 2 |
| `offer_deliveries` | offer_id, pet_id, delivered_at, seen_at, status (`sent`, `seen`, `accepted`, `dismissed`) | 2 |

## Comunidad y contenido

| Tabla | Campos clave | Fase |
|---|---|---|
| `adoptions` | id, publisher_id, publisher_kind (`shelter`, `individual`), is_litter, description, requirements, contribution_amount, contribution_covers, zone_id, status (`active`, `paused`, `adopted`, `hidden`) | 2 |
| `adoption_animals` | id, adoption_id, name, species_id, breed_id, age, size, energy, neutered, vaccinated, microchip, good_with (niños, perros, gatos), special_needs, photos, adopted_pet_id | 2 |
| `adopter_profiles` | user_id, housing, has_yard, hours_alone, experience, other_pets, kids, household_agrees, updated_at | 2 |
| `adoption_requests` | id, adoption_animal_id, adopter_id, stage (`interest`, `questionnaire`, `interview`, `visit`, `adopted`, `rejected`, `withdrawn`), compatibility, private_notes (solo publicador) | 2 |
| `adoption_commitments` | request_id, accepted_at, text_version, neuter_deadline | 2 |
| `adoption_followups` | request_id, day (7, 30, 90), photo_path, answer, answered_at | 2 |
| `foster_homes` | user_id, species_ids[], capacity, available, zone_id | 3 |
| `community_events` | id, organizer_id, title, kind, location, starts_at, ends_at | 2 |
| `abuse_reports` | id, user_id, description, location, photos, status | 2 |
| `news` | id, title, source, body, species_ids[], sponsored, sponsor_id, zone_id, published_at | 2 |
| `groups` | id, name, kind (`breed`, `species`, `topic`), species_id, breed_id, zone_id (opcional) | 3 |
| `group_members` | group_id, user_id, role | 3 |
| `posts` / `comments` | id, group_id, author_id, body, photos (sin EXIF), status | 3 |
| `contact_requests` | id, from_user, to_user, context, status (`pending`, `accepted`, `rejected`) — saludo previo al chat | 3 |

## Moderación

| Tabla | Campos clave | Fase |
|---|---|---|
| `flags` | id, target_type (`sos` por ahora), target_id, reporter_id, reason, created_at (un usuario reporta una vez por contenido) — ✅ 0.5.1 | 0 |
| `moderation_actions` | id, target_type, target_id, admin_id, action, note | 1 |
| `user_sanctions` | user_id, kind (`warning`, `blocked`), until, reason | 1 |

Trigger: con 3 `flags` de usuarios distintos, el contenido pasa a `hidden`.

## Monetización

| Tabla | Campos clave | Fase |
|---|---|---|
| `subscriptions` | id, owner_type (`user`, `household`, `business`), owner_id, plan, status, period_start, period_end, provider (`manual`, `google_play`, `app_store`, `mercadopago`), founder | 2 |
| `payments` | id, subscription_id, amount, currency, method, reference, paid_at | 2 |
| `qr_orders` | id, user_id, pet_id, design (genérica, personalizada), paid_by (`user`, `sponsor`, `vet`), status (`ordered`, `paid`, `printed`, `sent`, `delivered`), delivery (`vet_pickup`, `shipping`), pickup_business_id, address | 1 (retiro) / 2 (venta) |

## Métricas y ventas

| Tabla | Campos clave | Fase |
|---|---|---|
| `events` | id, name, user_id (nullable), anon_id, zone_id, business_id, target_id, platform, props (json, ≤ 2 KB), created_at — ✅ creada en 0.1.7. La app solo inserta; nadie lee desde la app | **0** |
| `daily_stats` | date, zone_id, business_id, metric, value | 2 |
| `prospects` | id, name, business_type, zone_id, location, contact, stage (`prospect`, `contacted`, `demo`, `founder`, `paying`, `renewed`, `lost`), business_id, next_contact_at, owner_admin_id | 1 |
| `prospect_notes` | id, prospect_id, admin_id, note, created_at | 1 |
| `admin_audit_log` | id, admin_id, action, target, data, created_at | 3 |
