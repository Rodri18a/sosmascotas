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

## Edge Functions

| Función | Para qué | Paso |
|---|---|---|
| `delete-account` | Borrar mi cuenta (valida la sesión y borra solo esa cuenta) | 0.2.6 ✅ |
| `owner-alert` | Contacto inverso: aviso al dueño desde el QR o un SOS | 0.4.4 |

Se despliegan con `supabase functions deploy <nombre> --use-api` y se prueban en `supabase/tests/rls_test.py`.

## Notificaciones

| Tipo | Mecanismo | Ejemplo |
|---|---|---|
| Avisos de SOS por zona | Edge Function + PostGIS + FCM | "Se perdió un perro a 1,2 km tuyo" |
| Escaneo de QR | Edge Function + FCM | "Escanearon el QR de Toby cerca de…" |
| Novedades de búsquedas que sigo | Edge Function + FCM | "¡Apareció Luna!" |
| Chat, turnos, pedidos | Realtime + FCM | |
| Recordatorios de medicación, comida y vacunas | **Locales** (sin servidor) | "Pastilla de Toby (8:00)" |
| Recordatorios del hogar compartido | Locales + sincronización por Realtime / FCM | "Ana ya le dio la pastilla" |

- Las push usan el **token del dispositivo** (`push_tokens`), nunca el teléfono.
- Para los avisos por zona se guarda una **ubicación aproximada** del usuario (no exacta), actualizada al abrir la app.

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
| `search` | rubro, especie, zona, **cantidad de resultados** |
| `place_impression` | business_id (aparición en el mapa o la lista) |
| `place_open` | business_id |
| `place_click` | business_id, tipo (whatsapp, llamar, cómo llegar, web, instagram) |
| `favorite_add` | business_id |
| `promo_view` / `promo_use` | promo_id |
| `sos_create` / `sos_resolve` / `sos_alert` | report_id |
| `qr_scan` / `qr_alert` | pet_id |
| `alert_reply` | el dueño respondió un aviso (marcado por él) |
| `signup` / `pet_create` | — |
| `reminder_done` | tipo |

- Se guarda `user_id` solo para métricas internas (retención). A las empresas se les muestran **agregados**.
- Riesgo aceptado en la Fase 0: con la clave pública se pueden cargar eventos falsos (solo ensucia métricas). Si pasa: tope por instalación o registro vía Edge Function.
- Para no inflar costos: agrupar eventos de impresión en lotes y, más adelante, resumir por día en una tabla `daily_stats`.

## Entornos

- **Desarrollo:** proyecto Supabase gratis + Firebase de desarrollo.
- **Producción:** proyecto Supabase aparte (Pro al tener usuarios reales).
- Variables por entorno con `--dart-define-from-file=config/<entorno>.json` (`APP_FLAVOR`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`). Los `.json` reales **nunca** van al repositorio; solo los `*.example.json`. La clase `AppEnv` (`packages/core`) los valida: producción sin Supabase no arranca.
- Los *flavors* nativos (otro `applicationId` para dev en el celular) se suman en el paso 1.1.1, al preparar las apps de las tiendas. En la Fase 0 (PWA) alcanza con la configuración por archivo.
