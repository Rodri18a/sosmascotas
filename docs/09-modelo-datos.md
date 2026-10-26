# 09 · Modelo de datos (Supabase / Postgres + PostGIS)

Propuesta inicial. Se ajusta al implementar cada fase. **RLS activado en todas las tablas.** Las ubicaciones usan `geography(Point)` de PostGIS. Todas las tablas tienen `created_at` y `updated_at`.

## Cuentas y zonas

| Tabla | Campos clave | Fase |
|---|---|---|
| `zones` | id, slug, name, country, timezone, currency, area (multipolígono), active — ✅ creada en 0.1.7 (Pando) | 0 |
| `profiles` | id (auth), display_name, avatar_path, role (`user`, `admin`), zone_id, plan (`free`, `pro`, `family`), prefs (idioma, color, letra), approx_location (centro de una celda de ~500 m, **privada**), approx_location_source (`gps`, `mapa`), approx_location_at, alert_radius_km (1–20, por defecto 5), terms_version, terms_accepted_at, created_at, updated_at — ✅ 0.2.1 / zona ✅ 0.6.2. Cada uno ve y edita solo el suyo; `role` y `plan` no se editan desde la app. La zona solo se cambia con `guardar_zona_aproximada()` (redondea con `celda_zona()`, igual que `zonaAproximada()` en `packages/core`) y `borrar_zona_aproximada()` (D56) | 0 |
| `private_contacts` | user_id, phone, whatsapp, show_whatsapp_direct (bool, por defecto `false`) — **solo accesible desde Edge Functions** (✅ 0.2.1: RLS sin políticas). Cuando el dueño cargue su teléfono, será con una función del servidor | 0 |
| `push_tokens` | token (clave), user_id, platform, created_at, last_seen_at. Se guarda solo con `guardar_push_token()` (pasa el token a la cuenta actual, máximo 10 por persona); cada uno ve y borra los suyos — ✅ 0.6.1 | 0 |
| `feature_flags` | key (`^[a-z][a-z0-9_]{2,40}$`), description, stage (`borrador`, `interna`, `beta`, `gradual`, `todos`), killed (apagado de emergencia), rollout_percent, zone_ids[], plans[], roles[], platforms[], min_app_version, allow_anonymous, starts_at, ends_at, updated_by, created_at, updated_at — ✅ 0.8.0b (D64). **Sin acceso desde la app** (RLS sin políticas); se consulta con `funcionalidad_activa()` / `mis_funcionalidades()` (`15-funcionalidades-graduales.md` §5). Porcentaje estable: `cubeta_funcionalidad()` = primeros 8 hex de `md5(clave:id)` mod 100. Primera marca: `temas_pro` (beta) | 0 |
| `feature_flag_users` | flag_key, user_id, enabled (`false` = excluida), created_at — ✅ 0.8.0b. Sin acceso desde la app | 0 |
| `feature_flag_audit` | id, flag_key, tabla, changed_by, before, after, created_at — ✅ 0.8.0b. Lo escribe un trigger en cada cambio de las dos tablas anteriores; sin acceso desde la app | 0 |

## Mascotas y hogar

| Tabla | Campos clave | Fase |
|---|---|---|
| `species` | id, slug, name, icon, sort — ✅ 0.3.1 (10 especies) | 0 |
| `breeds` | id, species_id, name, sort — ✅ 0.3.1 (~60 razas; si no está, `pets.breed_other`) | 0 |
| `pets` | id, household_id (Fase 1), owner_id, name, species_id, breed_id (de la misma especie: FK compuesta), breed_other, sex, color, marks, birth, photo_path, microchip (15 dígitos), renac_status (`registered`, `not_registered`, `unknown`, nulo sin responder; declarado por el dueño, ✅ 1.5.2b, D96), neutered, notes, vet_business_id (Fase 1) — ✅ 0.3.2. Privada: cada dueño ve solo las suyas. Fotos en el bucket público `pet-photos/<user_id>/` (nombres al azar) | 0 |
| `qr_tags` | id, code (8 caracteres sin ambiguos, único), pet_id (**nullable** hasta activarse), owner_id, kind (`digital`, `physical`), batch_id, active, activated_at, public_note (lo que el dueño elige mostrar, ≤ 200) — ✅ 0.4.1. Se crea solo al crear la mascota; `regenerar_qr()`; lo público sale de `public_pet_page()` (sin teléfono, sin número de chip) | 0 (digital) / 1 (física) |
| `qr_batches` | id, quantity (1–500), producer, material, sponsor_id (opcional, Fase 2), unit_cost, note, created_by, created_at — ✅ 1.8b.1 (D95). Sin acceso directo: `admin_crear_lote()`, `admin_lotes()` (activadas y escaneos), `admin_codigos_lote()`; las chapitas son filas de `qr_tags` con `kind = physical` y sin mascota hasta `activar_chapita()` | 1 |
| `tag_orders` | id, number, pet_id, owner_id, business_id, engraving (1–20), status (`new`, `sent`, `ready`, `delivered`, `cancelled`), tag_id (código asignado), created_at, updated_at — ✅ 1.8b.4 (D98). Sin acceso directo; uno abierto por mascota. Funciones: `puntos_de_retiro()`, `pedir_chapita()`, `mis_pedidos_chapita()`, `cancelar_pedido_chapita()`; del comercio `prender_punto_retiro()` (solo verificadas), `pedidos_chapita_del_negocio()`, `negocio_avanzar_pedido_chapita()` (al entregar vincula la chapita); de administración `admin_pedidos_chapita()`, `admin_enviar_pedido_chapita()`, `admin_cancelar_pedido_chapita()`. `businesses.tag_pickup` marca los puntos de retiro | 1 |
| `qr_pickups` | id, order_id o tag_id, business_id (veterinaria punto de retiro), status (`sent`, `ready`, `delivered`), delivered_at | 1 |
| `qr_scans` | id, qr_id, owner_id, pet_id, shared_location, shared_at, created_at — ✅ 0.4.5. `registrar_escaneo()` (tope 60/h por QR) y `compartir_ubicacion_escaneo()` (una vez, dentro de 30 min); solo el dueño los ve (`qr_scans_app`). `notified_at` (0.6.4): la push al dueño la decide `aviso_escaneo()`, solo para la Edge Function `qr-scan-alert` | 0 |
| `households` | id, owner_id (único: un hogar por dueño), name, created_at. `plan_status`/`trial_until` se suman con el cobro (Fase 2) | 1 |
| `household_members` | household_id, user_id, role (`member`, `temp_caregiver`; el dueño es `households.owner_id`), access_until, joined_at. Se entra solo con `unirme_al_hogar()`; el dueño saca y cada uno se puede ir (D69) |
| `household_member_pets` | household_id, user_id, pet_id: qué mascotas cuida cada cuidador temporal; se cargan solo al unirse (D72) |
| `household_invites` | id, household_id, code (10 letras/números sin 0/O/1/I), role, access_days, pet_ids (cuidador temporal), expires_at (7 días), used_by, used_at. Una sola vez; máx. 10 abiertas. Funciones: `invitar_al_hogar()`, `unirme_al_hogar()`, `integrantes_de_mis_hogares()` (solo el nombre visible, nunca el correo), `puedo_cuidar(pet)` que usan las políticas de `pets`, `health_records`, `reminders`, `reminder_logs`, `qr_tags`, `qr_scans` y `owner_alerts`; `tokens_de_cuidadores()` para las push | 1 |
| `health_records` | id, pet_id, kind (`vaccine`, `deworming`, `checkup`, `allergy`, `other`), name, date (sin fecha en las alergias), next_date (≥ date), notes. RLS: solo el dueño de la mascota (D66) | 1 |
| `reminders` | id, pet_id, kind (`medication`, `food`, `vaccine`, `checkup`), title, dose, schedule (JSON propio: `cada_horas` / `diaria` / `semanal` / `una_vez`, D67), starts_at, ends_on, active. `assigned_to` se suma con el hogar compartido (1.6). RLS: solo el dueño de la mascota | 1 |
| `reminder_logs` | id, reminder_id, due_at (la toma marcada; única por recordatorio, evita la dosis doble), done_by, done_at. Sin edición: se borra para deshacer. RLS: solo el dueño de la mascota (D67) | 1 |
| `household_tasks` | id, pet_id, kind (`walk`, `food`, `bath`, `vet`, `other`), note, day, assigned_to (solo a quien puede cuidar a la mascota), created_by, done_by (siempre quien marca; trigger), done_at (hora del servidor). RLS con `puedo_cuidar()` (D71) | 1 |

## SOS

| Tabla | Campos clave | Fase |
|---|---|---|
| `sos_reports` | id, kind (`lost`, `found`), user_id, pet_id (opcional, propia), species_id, breed_id, breed_other, name, sex, color, marks, description, reward, has_microchip, exact_location (**privada**), public_location (desplazada 150–200 m al azar), zone_id, happened_at, status (`active`, `resolved`, `archived`, `hidden`), created_at, last_activity_at, resolved_at — ✅ 0.5.1. **Sin acceso directo**: se publica con `crear_sos()` (≥ 1 foto propia, máx. 3/día) y se lee con funciones (`mis_sos()`, y las públicas de 0.5.4–0.5.5) | 0 |
| `sos_zone_alerts` | sos_id, user_id, created_at — ✅ 0.6.3. A quién se le avisó por zona de cada SOS (tope diario y no repetir). Sin acceso desde la app: lo escribe `difundir_sos()`, que solo usa la Edge Function `sos-zone-alert`. `sos_reports.zone_alerted_at` marca que el SOS ya se difundió | 0 |
| `sos_photos` | id, report_id, path, sort — ✅ 0.5.1 (bucket `sos-photos`, carpeta por usuario) | 0 |
| `owner_alerts` | id, target_type (`sos`, `qr`), target_id, owner_id, pet_id, from_user_id (nullable), sender_name, sender_contact (**privada**, solo la ve el dueño), message, photo_path, location (si quien avisa la compartió), device_hash (SHA-256 de IP + navegador), status (`new`, `seen`, `replied`, `scam_reported`), created_at — ✅ 0.4.4. Solo la crea la Edge Function `owner-alert`; el dueño lee (vista `owner_alerts_app`) y cambia el estado | 0 |
| `blocked_senders` | owner_id, device_hash — se llena al marcar un aviso como estafa; solo la usa `owner-alert` (descarta en silencio) — ✅ 0.4.4 | 0 |
| `sos_followers` | report_id, user_id | 1 |
| `help_directory` | id, zone_id, kind (`refugio`, `protectora`, `grupo`, `organismo`), name, description, phone, whatsapp, link (https), sort, status, is_sample — ✅ 0.7.3 (D61). Público: política de lectura de los activos; nadie escribe desde la app (se carga con `supabase/cargar_ayuda.py`). El 911 va fijo en la app | 0 |

## Empresas y lugares

| Tabla | Campos clave | Fase |
|---|---|---|
| `business_services` | **2.10a (D90):** id, business_id, name, description, price (null = "Consultar precio"), price_from ("desde"), duration_min (5 a 1440), species_ids[], available, sort. Sin acceso directo: `servicios_de()` (público, solo plan Plus y comercio activo), `mis_servicios()`, `guardar_servicio()` (solo Plus, máx. 50), `borrar_servicio()` | 2 |
| `businesses` | **Fase 0 (✅ 0.7.1, D59):** id, business_type (`vet`), name, description, address, location, zone_id, phone, whatsapp, web, instagram, hours (json por día, validado por `horario_valido()`), is_24h, emergencies, species_ids[], verification, status, is_sample (ejemplos de dev). Sin acceso directo: se lee con `comercios_en_zona()` (zona visible, solo activos y campos públicos) y se carga con `supabase/cargar_comercios.py`. **1.2 (D75) suma:** business_type con 9 rubros (`vet`, `petshop`, `pharmacy`, `grooming`, `walker`, `hotel`, `trainer`, `pet_friendly`, `shelter`; **2.8e, D89:** `agro`), kind (`local`, `online`, `domicilio`; sin local, location puede faltar), special_days (feriados), renac_operator; funciones `lugares_en_zona()` y `lugares_sin_local()`. **Fase 1 agrega:** owner_id, kind (`local`, `online`, `domicilio`), business_type, name, description, address, location, coverage_area, zone_id, hours (json por día), is_24h, species_ids[], plan (`basic`, `featured`, `plus`), verification (`unverified`, `pending`, `verified`), rut, renac_operator (bool, verificado por admin), founder_until, promo, web, instagram, facebook, status (`active`, `hidden`) | 0 (mínima) / 1 Búsqueda: `buscar_lugares(texto, rubro, lat, lng)` (lectura para todos, por nombre sin tildes o rubro, 25 km o la zona para los sin local, hasta 30; ✅ 1.8.7, D97) |
| `business_contacts_private` | business_id, phone, whatsapp, email (solo el dueño y la administración) (D77) |
| `business_claims` | id, business_id, user_id, rut, note, kind (`claim`, `dispute`), status (`pending`, `approved`, `rejected`), resolved_at, resolved_by. Se crean con `reclamar_negocio()` y se resuelven en el portal (D77) | 1 |
| `business_photos` | id, business_id, path, sort (bucket público `business-photos`, carpeta del negocio; 3 en Básico, 20 en planes pagos) (D77) | 1 |
| `place_marks` | id, user_id, category, location, google_link (solo de Google Maps), business_id (cuando se da de alta el negocio). Se crean con `marcar_lugar()`; el mapa ve grupos de 30 m sin saber quién marcó (D77) | 1 Tracción en el portal: `admin_sin_reclamar()` (personas que marcaron y aperturas `unclaimed_open` por grupo; ✅ 1.8.5, D99) |
| `claims` | id, business_id o place_mark_id, user_id, rut, evidence_path, status | 1 |
| `business_modules` | business_id, module (`catalog`, `agenda`, `members`), enabled | 2 |
| `user_places` | user_id, business_id, favorite, visited_at, is_my_vet (una por persona, solo veterinarias; trigger), updated_at. Privada (D75) | 1 |
| `reviews` | id, business_id, user_id, rating (1–5), comment, reply (una vez), reply_at, status (`active`, `hidden` con 3 reportes). Única por persona y comercio. Sin acceso directo: `guardar_resena()` (con contacto real), `responder_resena()`, `resenas_de()` (D78) | 1 |
| `promotions` | id, business_id, title, body, starts_at, ends_at, species_ids[], code | 2 |
| `pet_friendly_places` | se modelan como `businesses` con business_type `pet_friendly` | 2 |

## Chat

| Tabla | Campos clave | Fase |
|---|---|---|
| `sos_follows` | sos_id, user_id, created_at, notified_at. Cada uno ve solo lo que sigue; nadie ve quién más sigue un reporte; se escribe con `seguir_sos()` (D74) |
| `conversations` | id, kind (`sos`, `qr`, `business`, `user`), context_id, created_by, last_message_at. Se crean solo con funciones (`iniciar_chat_sos()`; una por persona y contexto; 10 nuevas por día) (D73) | 1 |
| `conversation_members` | conversation_id, user_id, last_read_at, blocked (cada uno edita solo esas dos columnas de su fila; si alguien bloquea, nadie escribe) | 1 |
| `messages` | id, conversation_id, sender_id, body, attachment_path (bucket privado `chat-photos`), lat/lng (si se comparte), created_at (del servidor). Sin edición ni borrado; 30 por minuto; Realtime. Lista con `mis_conversaciones()` | 1 |

## Comercio: catálogo, agenda, pedidos, socios

| Tabla | Campos clave | Fase |
|---|---|---|
| `catalog_items` | id, business_id, name, description, price (vacío = "Consultar precio", no se puede pedir), photo_path (`<negocio>/catalogo/…` en `business-photos`), available, species_ids[], sort. Sin acceso directo: `catalogo_de()` (también visitantes, solo con el módulo activo), `mi_catalogo()`, `guardar_producto()` (plan Plus, hasta 200), `borrar_producto()` (D85) | 2 |
| `agenda_settings` | business_id, slot_min, capacity, notice_min, days_ahead, hours (null: el de la ficha), service_ids (null: todos) — ✅ 3.1 (D104), antes `agenda_config`. Sin acceso directo: `mi_agenda()`, `guardar_agenda()` (Plus), `condiciones_agenda()` (también visitantes) | 3 |
| `agenda_blocks` | business_id, day, note — ✅ 3.1 (D104): días sin turnos, con `bloquear_dia()` (hasta 60) | 3 |
| `bookings` | id, business_id, user_id, pet_id, service_id, service_name, starts_at, ends_at, status (`pending`, `confirmed`, `rejected`, `cancelled`, `done`), cancelled_by, note — ✅ 3.1 (D104). Sin acceso directo: `horarios_libres()`, `reservar_turno()`, `mis_turnos()`, `turnos_del_negocio()` (primer nombre, mascota y especie), `cambiar_estado_turno()`, `turnos_pendientes()`; disparador `bookings_difundir` (Realtime) | 3 |
| `booking_notifications` | booking_id, kind (un estado o `reminder`) — ✅ 3.1 (D104): avisos ya mandados; solo `service_role` vía `avisar_turno()` y `turnos_para_recordar()` | 3 |
| `orders` / `order_items` | `orders`: number, business_id, user_id, status (`new`, `preparing`, `ready`, `delivered`, `cancelled`), note, total (lo calcula la base). `order_items`: nombre y precio del momento, qty 1–99. Sin acceso directo: `hacer_pedido()` (con sesión, hasta 30 productos y 10 pedidos por día), `mis_pedidos()`, `pedidos_del_negocio()` (solo el primer nombre de quien pide), `cambiar_estado_pedido()` (el comercio de a un paso o cancela; quien pide cancela mientras es nuevo), `pedidos_nuevos()` (D85). Desde D92 `orders` también guarda `payment_method`, `delivery` (`pickup`, `shipping`) y `shipping_cost` (incluido en el total, lo calcula la base); no guarda la dirección. Desde D100: `cancelled_by` (`cliente`, `negocio`), la tabla `order_notifications` (order_id + status, solo `service_role` vía `avisar_pedido()`, para no repetir la push) y el disparador `orders_difundir` que manda el id y el estado por Realtime a `pedidos:cliente:<usuario>` y `pedidos:negocio:<comercio>` (política en `realtime.messages` con `puedo_escuchar_pedidos()`) | 3 (adelantado, D85) |
| `order_settings` | business_id (uno por comercio), payment_methods (`cash`, `transfer`, `card`, `mercadopago`), pickup, shipping, shipping_cost (vacío o 0: gratis), free_shipping_from; retiro o envío, al menos uno. Sin acceso directo: `condiciones_pedido()` (también visitantes), `guardar_condiciones_pedido()` (dueño con Plus) (D92) | 2 (D92) |
| `business_modules` | business_id, module (`catalogo`, `agenda`, `socios`), enabled. Activo solo con plan Plus y si el tipo lo admite (`modulo_activo()`); se cambia con `prender_modulo()` (D81) | 2 |
| `pet_vet_shares` | pet_id, business_id, shared_by, consent_at, revoked_at. El dueño comparte con `compartir_con_veterinaria()`; la veterinaria ve `mis_socios()` y usa `recordar_a_socio()` (D81; antes `vet_members`) | 2 |
| `vet_search_consents` | pet_id, owner_id, scope (`vet`), consent_at, revoked_at, snoozed_until. `busco_veterinaria()`, `ahora_no_busco_veterinaria()`, `estado_busco_veterinaria()` (D81; antes `offer_consents`) | 2 |
| `vet_proposals` | id, business_id, message, species_id, radius_km. `demanda_de_veterinaria()` (solo grupos de 5 o más), `enviar_propuesta_veterinaria()`, `resultados_propuestas()` (D81; antes `business_offers`) | 2 |
| `vet_proposal_deliveries` | proposal_id, pet_id, status (`sent`, `seen`, `accepted`, `declined`), answered_at. `propuestas_para()`, `responder_propuesta()` (D81; antes `offer_deliveries`). Ninguna de estas tablas se lee directo | 2 |

## Comunidad y contenido

| Tabla | Campos clave | Fase |
|---|---|---|
| `adoptions` | id, publisher_id, publisher_kind (`shelter`, `individual`), shelter_id (refugio verificado propio), is_litter, description, requirements, contribution_amount y contribution_covers (solo refugios), zone_id, status (`active`, `paused`, `adopted`, `hidden`, `review`). Sin acceso directo: `publicar_adopcion()`, `adopciones_disponibles()` (D79) | 2 |
| `adoption_animals` | id, adoption_id, name, species_id, breed_id, age, size, energy, neutered, vaccinated, microchip, good_with (niños, perros, gatos), special_needs, photos, adopted_pet_id | 2 |
| `adopter_profiles` | user_id, housing, has_yard, hours_alone, experience, other_pets, kids, household_agrees, updated_at | 2 |
| `adoption_requests` | id, adoption_animal_id, adopter_id, stage (`interest`, `questionnaire`, `interview`, `visit`, `agreement`, `adopted`, `rejected`, `withdrawn`), message. La compatibilidad se calcula en la app; las notas privadas van en `adoption_request_notes` (solo el publicador) (D79) | 2 |
| `adoption_commitments` | request_id, accepted_at, text_version, neuter_deadline | 2 |
| `adoption_followups` | request_id, day (7, 30, 90), photo_path, answer, answered_at | 2 |
| `foster_homes` | user_id, species_ids[], capacity, available, zone_id | 3 |
| `community_events` | id, organizer_id, title, kind, location, starts_at, ends_at | 2 |
| `abuse_reports` | id, user_id, description, location, photos, status | 2 |
| `news` | id, title, body, source, link (https), species_ids[] (vacío = todas), sponsored, sponsor_name (obligatorio si es patrocinada), zone_id, status (`draft`, `published`, `hidden`), published_at. Sin acceso directo: `noticias(p_especies)` (también visitantes), `admin_noticias()`, `admin_guardar_noticia()` (D83) | 2 |
| `community_updates` | id, kind (`reencuentro`, `adopcion`, `comercio`, `evento`), una sola referencia (sos_id / adoption_id / business_id / event_id, únicas, se borran con su origen), name, detail (tipo de SOS, rubro o tipo de evento), species_id, amount (días perdida o animales adoptados), starts_at, photo_path (`<bucket>/<ruta>` ya pública), zone_id, status (`visible`, `hidden`). Sin acceso directo: `novedades_comunidad()` y `resumen_comunidad()` (también visitantes), `compartir_reencuentro()` / `quitar_reencuentro()` / `reencuentro_compartido()` (autor del SOS), `admin_novedades()` y `admin_estado_novedad()`; disparadores en `adoptions`, `businesses` y `events_calendar` (D86). `novedades_comunidad()` también devuelve `origin_id` y las perdidas activas de los últimos 30 días (`kind = 'perdida'`, sin ubicación, D87) | 2 |
| `news_reactions` | id, news_id o update_id (uno solo; se borran con la noticia o la novedad), user_id, kind (`alegra`, `festejo`, `gracias`), created_at; una por persona y por noticia o novedad. Sin acceso directo: `reaccionar()` (con sesión; solo noticias publicadas o novedades visibles), `reacciones()` (totales y la mía; también visitantes) y `reacciones_de_mi_reencuentro()` (autor del SOS) (D87) | 2 |
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
| `subscriptions` | id, owner_type (`user`, `household`, `business`), owner_id, plan, status (`active`, `past_due`, `cancelled`, `expired`), period_start, period_end, provider (`manual`, `google_play`, `app_store`, `mercadopago`), founder, price, currency, notes — ✅ creada en 2.2 (D103) para comercios; una vigente por dueño; sin acceso directo (`admin_*`, `mi_plan()`) | 2 |
| `payments` | id, subscription_id, amount, currency, method (`transfer`, `payment_link`, `cash`, `other`), reference, months, paid_at, recorded_by — ✅ creada en 2.2 (D103): solo con `admin_registrar_pago()`; se conserva aunque se borre el comercio | 2 |
| `plan_changes` | business_id, plan_before, plan_after, changed_by, changed_at — ✅ creada en 2.2 (D103): la escribe un trigger en cada cambio de plan; da el antes/después de las estadísticas | 2 |
| `qr_orders` | id, user_id, pet_id, design (genérica, personalizada), paid_by (`user`, `sponsor`, `vet`), status (`ordered`, `paid`, `printed`, `sent`, `delivered`), delivery (`vet_pickup`, `shipping`), pickup_business_id, address | 1 (retiro) / 2 (venta) |

## Métricas y ventas

| Tabla | Campos clave | Fase |
|---|---|---|
| `events` | id, name, user_id (nullable), anon_id, zone_id, business_id, target_id, platform, props (json, ≤ 2 KB), created_at — ✅ creada en 0.1.7. La app solo inserta; nadie lee desde la app | **0** |
| `daily_stats` | day, business_id, zone_id, metric, value — ✅ creada en 2.3 (D101): resumen diario (hora de Uruguay) de los eventos de cada comercio, lo escribe `resumir_estadisticas()` con pg_cron; sin acceso desde la app, se lee con `estadisticas_negocio()` | 2 |
| `monthly_reports` | business_id, month, totals, devices, created_at — ✅ creada en 2.3 (D101): un reporte mensual por comercio y mes (no se repite); solo `service_role` | 2 |
| `success_stories` | id, business_id, business_name, business_type, zone_id, quote, author, numbers, consent, status (`draft`, `published`) — ✅ creada en 2.4 (D102): casos de éxito para ventas; solo administración con `admin_casos()`, `admin_guardar_caso()`, `admin_borrar_caso()`; publicado solo con `consent` | 2 |
| `prospects` | id, name, business_type, zone_id, location, contact, stage (`prospect`, `contacted`, `demo`, `founder`, `paying`, `renewed`, `lost`), business_id, next_contact_at, owner_admin_id | 1 |
| `prospect_notes` | id, prospect_id, admin_id, note, created_at | 1 |
| `admin_audit_log` | id, admin_id, action, target, data, created_at | 3 |

## Eventos y denuncias (2.7, D80)

| Tabla | Campos clave | Fase |
|---|---|---|
| `events_calendar` | id, organizer_id, business_id (comercio verificado), kind (`castracion`, `adopcion`, `encuentro`, `otro`), title, description, starts_at, ends_at (máx. 14 días), location, address, link, zone_id, status. Sin acceso directo: `publicar_evento()`, `eventos_en_zona()`, `cancelar_evento()` | 2 |
| `abuse_reports` | id, reporter_id, description, location (opcional, privada), address, photos (bucket privado `abuse-photos`), status (`new`, `referred`, `closed`), admin_note. Solo quien denuncia y la administración | 2 |
