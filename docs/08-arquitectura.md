# 08 · Arquitectura

## Visión general

```
📱 App Flutter (PWA · Android · iPhone) ─┐
🛠️ Portal admin (Flutter Web) ───────────┼──► 🟢 Supabase
💼 Portal empresas (Flutter Web) ────────┤      ├─ Postgres + PostGIS (datos, búsquedas por cercanía)
🌐 Web pública QR / reportes (liviana) ──┘      ├─ Auth (Google, correo, Apple)
                                                ├─ Storage (fotos)
                                                ├─ Realtime (chat)
                                                └─ Edge Functions (contacto inverso, avisos, QR, reportes)
                                                        │
                                                        └──► 🔔 Firebase Cloud Messaging (push)
🗺️ Mapas: Google Maps nativo (Android/iPhone) · MapLibre + OpenStreetMap (web)
⏰ Recordatorios: notificaciones locales del celular
```

## Stack

| Capa | Tecnología |
|---|---|
| App y portales | **Flutter** (Dart). Gestión de estado y librerías a definir en el paso de base técnica |
| Base de datos | Supabase Postgres + **PostGIS** |
| Autenticación | Supabase Auth: Google, correo con enlace mágico, Apple (Fase 1) |
| Archivos | Supabase Storage, con fotos comprimidas en el cliente |
| Tiempo real | Supabase Realtime (chat, estado de turnos y pedidos) |
| Lógica de servidor | Supabase Edge Functions (TypeScript) |
| Push | Firebase Cloud Messaging |
| Recordatorios | Notificaciones locales (`flutter_local_notifications` o similar) |
| Mapa móvil | `google_maps_flutter` (mapa nativo) |
| Mapa web | `flutter_map` / MapLibre con teselas de OpenStreetMap a través de un proveedor con plan gratis |
| Hosting web | Cloudflare Pages o Vercel (verificar condiciones de uso comercial) |
| Pagos (Fase 4) | Mercado Pago |
| Suscripciones de usuarios (Fase 2) | Compras dentro de la app (Google Play / App Store) |

## Estructura del repositorio

```
sosmascotas/
├── CLAUDE.md
├── docs/
├── reference/
├── pubspec.yaml          # Espacio de trabajo de Dart (un solo `flutter pub get` en la raíz)
├── analysis_options.yaml # Reglas de estilo compartidas
├── app/                  # Flutter: app de usuarios + modo comercio (móvil y PWA)
├── admin/                # Flutter Web: portal de administración (Fase 1)
├── packages/
│   └── core/             # Modelos, servicios de Supabase, capa de mapa, i18n compartidos
├── web-publica/          # Página liviana del QR y de los reportes
└── supabase/
    ├── migrations/       # Esquema SQL y políticas RLS
    ├── functions/        # Edge Functions
    └── seed/             # Especies, razas, datos de prueba
```

## Reglas de costo del mapa (obligatorias)

**Dibujar el mapa:**
- En **Android/iPhone**, el mapa nativo de Google **no tiene costo** por carga, y mover o hacer zoom no genera cargas nuevas. *Verificar la política vigente de Google antes de arrancar.*
- En **web**, Google cobra cada carga. Por eso en web se usa **MapLibre/OpenStreetMap**. No usar los servidores de teselas de OpenStreetMap directamente en producción: usar un proveedor con plan gratis.
- El mapa va detrás de una **capa propia** (`MapView` en `packages/core`) para poder cambiar de proveedor sin tocar las pantallas.

**Los datos encima del mapa (pines) salen de Supabase, no de Google:**
1. Traer **solo los pines de la zona visible** (consulta PostGIS por rectángulo o radio).
2. Datos mínimos por pin (id, tipo, estado, lat, lng). El detalle se trae al tocarlo.
3. **Agrupar pines** (clusters) cuando hay muchos.
4. **Caché** de lo ya cargado. Volver a consultar solo si el mapa se movió bastante.
5. Crear el mapa **una sola vez por sesión** y reutilizarlo.

**Prohibido (porque cobra):**
- ❌ Places API, Geocoding API, Directions API.
- La ubicación se marca **tocando el mapa**.
- "Cómo llegar" = **enlace que abre Google Maps**.

**Control:** alerta de presupuesto y tope diario de cuota en Google Cloud. Si se llega al tope, mostrar la **lista** en lugar del mapa.

## Web pública (`web-publica/`)

Páginas livianas en **HTML + JavaScript sin frameworks** (cargan rápido en cualquier celular, sin instalar nada):

| Ruta | Archivo | Qué muestra |
|---|---|---|
| `/m/<código>` | `m.html` + `assets/qr.js` | Página del QR: foto, nombre, especie/raza, señas, nota del dueño, si tiene chip, "Estoy perdido 🆘" y **"Avisar a mi familia"** (contacto inverso) |
| `/s/<id>` | `s.html` + `assets/sos.js` | Página pública de un SOS para compartir: fotos, datos, zona aproximada (enlace a Google Maps) y "Avisar a su familia" (mismo formulario que el QR, `assets/aviso.js`) |
| `/n/<id>` | `n.html` + `assets/negocio.js` | Página pública de un comercio **Plus** (2.10b, D90): fotos, rubro, insignias, "abierto ahora", promoción, contactos públicos, "Cómo llegar", servicios y productos con "Consultar" por WhatsApp, y horario. Datos con `pagina_comercio()`; registra `business_page_open`. La vista previa al compartir es genérica (sin el nombre del comercio) hasta tener dominio propio, P25 |

- Datos: funciones RPC públicas (`public_pet_page`) que devuelven solo lo pensado para quien encuentra a la mascota.
- Seguridad: todo el texto se inserta con `textContent` (nunca HTML), CSP estricta, `_headers` con `X-Frame-Options: DENY`.
- Hosting: Cloudflare Pages (`_redirects` reescribe `/m/*` y `/s/*`). Local: `python3 web-publica/servir.py` → `http://localhost:3002`.
- Configuración en `web-publica/config.js` (ignorado por git; copiar de `config.example.js`).

## Edge Functions

| Función | Para qué | Paso |
|---|---|---|
| `delete-account` | Borrar mi cuenta (valida la sesión y borra solo esa cuenta) | 0.2.6 ✅ |
| `sos-zone-alert` | ✅ Al publicar un SOS, la app la llama y se avisa por push a quienes están cerca (`difundir_sos()`: hasta el radio de cada persona, máx. 3 avisos por día, una sola vez por SOS). Valida la sesión y que el SOS sea de quien llama. Envía por FCM HTTP v1 (`_shared/fcm.ts`, secreto `FIREBASE_SERVICE_ACCOUNT`) y borra los tokens vencidos. Sin el secreto responde 503 sin marcar nada (la app reintenta al abrir) | 0.6.3 |
| `qr-scan-alert` | La llama la página pública del QR después de `registrar_escaneo()`: push al dueño "📍 Escanearon el QR de…" (abre `/mascotas/<id>/qr`). Sin sesión; solo acepta el id de un escaneo de menos de 5 min, una push por escaneo y como mucho una por QR cada 10 min (`aviso_escaneo()`). Responde siempre igual | 0.6.4 ✅ |
| `order-status-alert` | Pedidos (3.2, D100): la app la llama después de pedir o de cambiar el estado; push a la otra parte según `avisar_pedido()` (una por pedido y estado). Valida la sesión. Registra `order_push` | 3.2 |
| `care-alert` | Paseos y estadías (3.3, D115): la app la llama después de pedir, responder o cambiar el estado; push a la otra parte según `avisar_cuidado()` (una por pedido y estado; abre `/cuidados` o `/negocio?seccion=agenda`) | 3.3 ✅ |
| `owner-alert` | Contacto inverso: aviso al dueño desde el QR o un SOS, con push "💬 …te dejó un mensaje" (abre `/avisos`; si la push no sale, el aviso queda igual en la bandeja). Con sesión (desde la app) no pide anti-bots; sin sesión, Turnstile (secreto `TURNSTILE_SECRET`; en dev, la clave de prueba de Cloudflare), límites 5/h por dispositivo y 10/h por destino, remitentes bloqueados | 0.4.4 ✅ |

### Comercios cargados a mano (Fase 0)

Hasta el panel de administración, las veterinarias se cargan desde una planilla: `investigacion/veterinarias.csv` → `python -I -X utf8 supabase/cargar_comercios.py investigacion/veterinarias.csv [--aplicar]` (sin `--aplicar` solo valida). Las coordenadas van en la planilla (copiadas de Google Maps), sin geocodificación. Las de ejemplo para desarrollo están en `supabase/seeds/veterinarias_ejemplo.csv` (`--ejemplo`) y se borran al cargar las reales. El mapa las trae con `comercios_en_zona()` (zona visible).

El directorio de la pestaña Ayuda se carga igual: `investigacion/ayuda.csv` → `supabase/cargar_ayuda.py` (ejemplos en `supabase/seeds/ayuda_ejemplo.csv`, `--ejemplo`).

Se despliegan con `supabase functions deploy <nombre> --use-api` y se prueban en `supabase/tests/rls_test.py`. Las partes sin red (textos, firma de FCM) tienen pruebas de Deno: `npx deno test --allow-env supabase/functions/`.

## Notificaciones

| Tipo | Mecanismo | Ejemplo |
|---|---|---|
| Avisos de SOS por zona | Edge Function + PostGIS + FCM | "Se perdió un perro a 1,2 km tuyo" |
| Escaneo de QR | Edge Function + FCM | "Escanearon el QR de Toby cerca de…" |
| Novedades de búsquedas que sigo | Edge Function `sos-follow-alert` + FCM (D74) | "¡Luna volvió a casa!" |
| Chat, turnos | Realtime + FCM | |
| Paseos y estadías (D115) | Edge Function `care-alert` + FCM; estado en vivo con Broadcast en `cuidados:cliente:<usuario>` y `cuidados:negocio:<comercio>` | "✅ Hotel Canino aceptó: estadía para Luna, del 24/12 al 26/12" |
| Pedidos (D100) | Edge Function `order-status-alert` + FCM; estado en vivo con Broadcast desde la base (canales privados) | "✅ ¡Tu pedido #7 está listo!" / "🛍️ Pedido nuevo #12" |
| Recordatorios de medicación, comida y vacunas | **Locales** (sin servidor). En la web, solo con la app abierta (D67) | "Antibiótico para Toby" |
| Recordatorios del hogar compartido | Locales + sincronización por Realtime / FCM | "Ana ya le dio la pastilla" |

- Las push usan el **token del dispositivo** (`push_tokens`), nunca el teléfono.
- Web (PWA): `app/web/firebase-messaging-sw.js` muestra cada push como notificación del sistema y al tocarla abre `data.ruta` (por ejemplo `/sos/<id>`). Los mensajes se mandan con `notification: {title, body}` y `data: {ruta}` (D55).
- Para los avisos por zona se guarda una **ubicación aproximada** del usuario (no exacta), actualizada al abrir la app: el centro de una celda de ~500 m, calculado en el teléfono y otra vez en la base (D56). El permiso de ubicación se pide recién al activar los avisos, después de explicar para qué es; se puede borrar desde Ajustes.

## Contacto inverso

> Redirigir a `wa.me/<número>` expone el número a quien contacta. Por eso el flujo es **inverso**: el que contacta deja sus datos y el dueño decide.

1. Quien vio o encontró al animal envía el formulario "Avisar al dueño" a la Edge Function `owner-alert` (id del reporte o código QR, mensaje, nombre, contacto, foto y ubicación opcionales, token anti-bots).
2. La función valida el token anti-bots y los límites de uso, guarda el aviso en `owner_alerts` (el contacto del remitente en una columna privada) y registra el evento.
3. Notifica al dueño por **push (FCM)** y por **email** de respaldo. El email sale por el SMTP configurado en Supabase con un proveedor con plan gratis (a elegir).
4. El dueño ve el aviso en su bandeja y el contacto del remitente, y responde por su cuenta.
5. El número del dueño (`private_contacts`) **no lo lee ninguna función de contacto**. Solo se usa si el dueño activa el WhatsApp directo opcional.

## Métricas desde el día 1

Tabla `events` (append-only), escrita por el cliente con `ref.read(metricasProvider).track(Eventos.x)` y, en las acciones sensibles, por las Edge Functions. Los nombres están en `packages/core` (`Eventos`). `track()` no espera ni falla: sin internet, el evento se pierde sin afectar a la persona.

| Evento | Datos |
|---|---|
| `app_open` | plataforma, zona |
| `map_view` | zona, capas activas |
| `search` | rubro reconocido (`rubroDeBusqueda()`), zona (`zone_id`) y **cantidad de resultados**; el texto **solo** si no hubo resultados ni rubro, sin números ni `@` y cortado a 40 caracteres (D97). Uno por búsqueda terminada (1,5 s sin escribir), no por letra |
| `place_impression` | business_id (aparición en el mapa o la lista) |
| `help_click` | tipo (911, llamar, whatsapp, enlace) y kind de la entrada (pestaña Ayuda, sin datos de nadie) |
| `theme_change` | tema elegido (`cielo`, `faro`, `vecinos`, `pop`; plan Pro, D63) |
| `feature_exposure` | `key` de la funcionalidad y `variante` (`prendida`/`apagada`); una vez por sesión, marca y variante, solo cuando ya se sabe qué le tocó (D64) |
| `pwa_prompt` | `origen` (`ajustes`/`mapa`), `forma` (`aviso`/`iphone`) y `resultado` (`aceptada`/`rechazada`/`pasos`) (D65) |
| `pwa_installed` | la web se instaló mientras se ofrecía (aviso aceptado o menú del navegador) (D65) |
| `place_open` | business_id |
| `place_click` | business_id, tipo (whatsapp, llamar, cómo llegar, web, instagram) |
| `favorite_add` | business_id |
| `promo_view` / `promo_use` | promo_id |
| `sos_create` / `sos_resolve` / `sos_alert` | report_id |
| `qr_scan_push` | dispositivos avisados (push por escaneo del QR, sin datos de nadie) |
| `sos_zone_alert` | report_id, personas y dispositivos avisados, tipo (lo registra `sos-zone-alert`) |
| `qr_scan` / `qr_alert` | pet_id |
| `alert_reply` | el dueño respondió un aviso (marcado por él) |
| `content_flag` | target_type, motivo, target_id (reporte a moderación, solo la primera vez) |
| `alert_zone_set` / `alert_zone_clear` | — (guardó o borró su zona para avisos; **sin coordenadas**) |
| `signup` / `pet_create` | — |
| `health_record_create` | tipo del registro de la libreta (`vaccine`, `deworming`, `checkup`, `allergy`, `other`; D66) |
| `renac_status_set` / `renac_guide_open` / `renac_verify_click` | estado RENAC declarado (`registered`, `not_registered`, `unknown`), abrir la guía y tocar "Verificar en el RENAC", sin datos de la mascota (D96) |
| `household_invite` / `household_join` / `household_leave` | — (sin datos de nadie; D69) |
| `map_view` | vista elegida (`mapa`, `lista`, `sinLocal`; D75) |
| `event_publish` / `event_open` / `abuse_report` | tipo de evento o target_id; la denuncia sin datos (D80) |
| `module_toggle` / `vet_share` / `vet_remind` / `vet_search_opt_in` / `vet_search_snooze` / `vet_proposal_send` / `vet_proposal_answer` | socios y "Busco veterinaria", sin datos de la mascota ni del dueño (D81) |
| `news_open` / `news_link` | abrir una noticia y tocar "Leer más", con `patrocinada` (D83) |
| `banner_open` | tocar un banner del carrusel de Inicio, con `patrocinado` (D128) |
| `menu_open` / `pet_select` | se abre el menú ☰; se elige una mascota o "Todas" para filtrar (D88) |
| `menu_item_open` | se toca una opción del menú ☰ (`item`: `mapa`, `adopcion`, `pedidos`…), para ver qué se usa (plan de mejoras 1.2) |
| `tour_start` / `tour_finish` / `tour_skip` | recorrido guiado de una pantalla (D130): `screen`, si arrancó solo (`auto`) o con el botón ?, y en qué paso se saltó (`step`) |
| `more_info_open` | se toca «Ver más» en una explicación corta (`item`: cuál), para saber qué explicaciones hacen falta (plan de mejoras 1.4) |
| `pet_quick_action` | acceso directo desde la fila de una mascota en Mis mascotas (`action`: `qr`, `libreta`, `recordatorio`, `reportar`) (plan de mejoras 1.5) |
| `life_event_create` / `life_event_file_add` | se carga un acontecimiento del historial de vida (`kind`) o se le suma un adjunto (`type`: `photo`, `pdf`) (D131) |
| `tab_open` | se cambia de pestaña en la barra inferior, con `tab` (`noticias`, `sos`, `mapa`, `mascotas`, `ayuda`; D94) |
| `unclaimed_open` | se abre la hoja de un lugar sin reclamar; `target_id` = una marca del grupo, `tipo` = rubro (D99) |
| `tag_activate` / `tag_unlink` | el dueño activa una chapita física (con `origen`: `enlace` o `codigo`) o la desvincula (D95) |
| `tag_order_create` / `tag_order_cancel` / `tag_order_status` / `tag_pickup_toggle` | pedido de chapita con retiro: el dueño la pide o cancela; la veterinaria marca el estado nuevo (`ready`, `delivered`) o se hace punto de retiro (`prendido`), con `business_id` (D98) |
| `tag_stock_deliver` | la veterinaria entrega un pedido con una chapita de su stock, con `business_id` (2.9, D105) |
| `foster_home_save` / `foster_request_create` / `foster_request_answer` / `foster_request_close` | hogares de tránsito: la persona se anota (`activo`); el refugio pide o cierra (`estado`), con `business_id`; el hogar responde (`acepta`) (3.4b, D106) |
| `perk_save` / `perk_claim` / `perk_redeem` | pack adopción: el comercio carga un beneficio (`activo`), quien adoptó pide el código, el comercio lo canjea; con `business_id` (3.4b, D107) |
| `sponsorship_status` | apadrinamiento: el comercio ofrece (`pending`) o retira, el refugio acepta (`active`) o no (`declined`), cualquiera termina (`ended`); con `business_id` (3.4b, D108) |
| `news_reaction` | alguien reacciona a una noticia o novedad (D87; lo registra la base, con el tipo y si es noticia o comunidad) |
| `community_share` / `community_unshare` | el autor de un SOS resuelto comparte o quita el reencuentro en Comunidad (D86; compartir lo registra la base) |
| `catalog_open` / `catalog_ask` / `product_save` / `order_create` / `order_status` | catálogo y pedidos: abrir, consultar, cargar un producto, pedir (con las unidades) y cada cambio de estado; sin datos de quien pide (D85) |
| `order_push` | target_id del pedido, destino (`cliente`/`negocio`), estado y dispositivos avisados (lo registra `order-status-alert`; D100) |
| `service_ask` / `service_save` | servicios del comercio: consultar por uno desde la ficha y cargarlo o editarlo (D90) |
| `booking_create` / `booking_status` / `agenda_save` | business_id; con_servicio / estado y quién / duración y a la vez: turnos (D104). La Edge Function suma `booking_push` y `booking_reminder` |
| `team_invite` / `team_join` / `team_leave` | business_id; `team_leave` con quién (`yo` o `duenio`): equipo de la empresa (D117) |
| `plan_request` | business_id, plan: el comercio pidió un plan pago desde «Tu plan» (D103) |
| `business_page_share` / `business_page_open` | página pública del comercio: el comercio copia su enlace (app) y alguien la abre (web pública, sin cuenta) (D90) |
| `adoption_publish` / `adoption_interest` / `adoption_stage` / `adoption_commit` / `adoption_followup` | cantidad de animales, etapa o día del seguimiento; sin datos de nadie (D79) |
| `review_create` / `review_reply` | business_id; `review_create` con las estrellas (D78) |
| `place_mark` / `business_create` / `business_claim` / `verification_request` | rubro y modalidad o business_id (1.3, D77) |
| `place_visit` / `my_vet_set` | business_id ("fui" y "es mi veterinaria"; D75) |
| `sos_follow` / `sos_follow_push` | target_id del SOS; `sos_follow_push` con los dispositivos avisados (lo registra `sos-follow-alert`; D74) |
| `chat_start` / `chat_message` / `chat_block` | `chat_start` con el origen (`sos`); sin contenido de los mensajes (D73) |
| `task_create` / `task_done` | tipo de tarea (`walk`, `food`, `bath`, `vet`, `other`; D71) |
| `reminder_create` | tipo del recordatorio (`medication`, `food`, `vaccine`, `checkup`; D67) |
| `reminder_done` | tipo |

- Se guarda `user_id` solo para métricas internas (retención). A las empresas se les muestran **agregados**.
- Riesgo aceptado en la Fase 0: con la clave pública se pueden cargar eventos falsos (solo ensucia métricas). Si pasa: tope por instalación o registro vía Edge Function.
- Para no inflar costos: agrupar eventos de impresión en lotes y resumir por día en `daily_stats` (✅ 2.3, D101: pg_cron a las 03:15 de Uruguay; el día de hoy se cuenta en el momento).
- **Tareas programadas (D101):** pg_cron en la base (`cron.job`): `resumir-estadisticas` todas las noches, `vencer-planes` todos los días a las 03:30 (D103), `recordar-turnos` a las 18:00 (D104, llama a `booking-alert` con `cron_secret`) y `reporte-mensual` el día 1 a las 10:00, que llama a la Edge Function `monthly-report` con pg_net. La dirección del proyecto y la clave compartida van en **Vault** (`project_url`, `monthly_report_secret`) y la misma clave en el secreto `MONTHLY_REPORT_SECRET` de la función; nunca en el repositorio.

## Entornos

- **Desarrollo:** proyecto Supabase gratis + Firebase de desarrollo.
- **Producción:** proyecto Supabase aparte (Pro al tener usuarios reales).
- Variables por entorno con `--dart-define-from-file=config/<entorno>.json` (`APP_FLAVOR`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`). Los `.json` reales **nunca** van al repositorio; solo los `*.example.json`. La clase `AppEnv` (`packages/core`) los valida: producción sin Supabase no arranca.
- Los *flavors* nativos (otro `applicationId` para dev en el celular) se suman en el paso 1.1.1, al preparar las apps de las tiendas. En la Fase 0 (PWA) alcanza con la configuración por archivo.
