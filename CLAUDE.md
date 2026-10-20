# SOS Mascota

Plataforma para dueños de mascotas y empresas del rubro, con un mapa como centro: veterinarias, petshops, servicios, lugares que aceptan mascotas, mascotas perdidas y encontradas, chapita QR, recordatorios de salud y más. Es un emprendimiento propio que arranca en **Pando (Uruguay)** y se expande por zonas.

> Documentación definida el 12/10/2026 a partir de una entrevista de requisitos y del brief anterior (`reference/SOS-Mascota-brief.md`).

## Dónde está cada cosa

| Archivo | Contenido |
|---|---|
| `docs/PROGRESO.md` | **Plan paso a paso con casillas y marcador "← ESTÁS ACÁ". Leelo siempre primero.** |
| `docs/01-vision.md` | Visión, problema, mercado, competencia, estrategia |
| `docs/02-usuarios-roles.md` | Tipos de usuario, permisos, visitante |
| `docs/03-funcionalidades-app.md` | Funciones de la app (usuario y modo comercio), con la fase de cada una |
| `docs/04-portal-empresas.md` | Portal web de empresas (futuro) |
| `docs/05-portal-admin.md` | Portal del administrador: moderación, indicadores, captación de empresas |
| `docs/06-reglas-negocio.md` | Planes, verificación, reseñas, moderación, privacidad y reglas de cálculo |
| `docs/07-requisitos-no-funcionales.md` | Plataformas, idioma, offline, seguridad, accesibilidad, escala |
| `docs/08-arquitectura.md` | Stack, estructura, **reglas de costo del mapa**, notificaciones, métricas |
| `docs/09-modelo-datos.md` | Tablas de Supabase/Postgres |
| `docs/10-costos.md` | Costos, cuándo se paga cada cosa, punto de equilibrio |
| `docs/11-roadmap.md` | Fases 0 a 4, metas y métricas para avanzar |
| `docs/12-decisiones.md` | Registro de decisiones (qué se decidió y por qué) |
| `docs/13-riesgos-pendientes.md` | Riesgos y temas abiertos |
| `docs/14-brief-identidad-visual.md` | Brief para generar logo, paleta, tipografías e íconos (con una IA o un diseñador) |
| `docs/15-funcionalidades-graduales.md` | Propuesta: prender funcionalidades de a poco (marcas, porcentaje, zona, plan, apagado de emergencia) |
| `reference/sos-mascota.html` | Prototipo funcional: referencia de pantallas y textos. **No portar el código tal cual** |
| `reference/SOS-Mascota-brief.md` | Brief anterior (costos detallados en pesos, cronología del prototipo) |

Si un dato de `reference/` contradice `docs/`, **manda `docs/`** (ver `docs/12-decisiones.md`).

## Stack

- **App:** Flutter (Android + iPhone + web instalable/PWA). Panel de administración en Flutter Web.
- **Backend:** Supabase (Postgres + PostGIS, Auth, Storage, Realtime, Edge Functions) con RLS en todas las tablas.
- **Notificaciones push:** Firebase Cloud Messaging. Recordatorios con notificaciones locales.
- **Mapa:** Google Maps nativo en Android/iPhone y MapLibre/OpenStreetMap en web, detrás de una capa propia.
- **Web pública del QR y de los perdidos:** página liviana y rápida, apta para SEO y para compartir.

## Comandos

- `flutter pub get` en la raíz (espacio de trabajo: `app/` + `packages/core`).
- Desde `app/`: `flutter analyze`, `flutter test`, `flutter run -d chrome --dart-define-from-file=config/dev.json`.
- Desde `packages/core/`: `flutter test`.
- Portal de administración (`admin/`, D76): `flutter analyze`, `flutter test` y `flutter run -d chrome --dart-define-from-file=config/dev.json` desde `admin/` (config real en `admin/config/dev.json`, ignorada por git). El rol `admin` se pone solo desde la base (`profiles.role`).
- La configuración real va en `app/config/dev.json` / `prod.json` (ignorados por git; copiar de `*.example.json`).
- Textos de la app: solo en `app/lib/l10n/app_es.arb` (voseo), usados con `context.t.<clave>`.
- Base de datos: migraciones en `supabase/migrations/`. Aplicar con `set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a; supabase db push --linked` (probar antes con `--dry-run` y mostrar el SQL y las políticas para aprobar). En otra máquina: instalar la CLI, crear ese archivo y `supabase link --project-ref <ref>`.
- Edge Functions en `supabase/functions/`: `supabase functions deploy <nombre> --use-api` (no hace falta Docker).
- Configuración de login (Auth) versionada en `supabase/configurar_auth.py` (`--aplicar`).
- Veterinarias (Fase 0): planilla `investigacion/veterinarias.csv` → `supabase/cargar_comercios.py <csv> [--aplicar]` (con las mismas credenciales; `--ejemplo` para `supabase/seeds/veterinarias_ejemplo.csv`). Directorio de Ayuda: `investigacion/ayuda.csv` → `supabase/cargar_ayuda.py`, igual.
- Ejemplos para ver en el mapa (solo dev: SOS, eventos, lugares sin reclamar, todos los rubros): `supabase db query --linked -f supabase/seeds/mapa_ejemplo.sql` (con las mismas credenciales; se puede repetir, recrea los ejemplos). Noticias de ejemplo: `supabase/seeds/noticias_ejemplo.sql`, igual. Pet shop de ejemplo con catálogo (a nombre del dueño del proyecto): `supabase/seeds/tienda_ejemplo.sql`, igual.
- Funcionalidades graduales (D64): `supabase/funcionalidades.py listar | ver | crear | etapa | porcentaje | regla | apagar | prender | invitar | excluir | quitar` (mismas credenciales; sin `--aplicar` solo muestra el cambio). Pruebas: `python3 -I supabase/tests/funcionalidades_test.py`.
- Pruebas de seguridad de la base: `python3 -I supabase/tests/rls_test.py` (con el mismo `set -a; . …`). Sumar casos en cada tabla nueva.
- **En Windows** (PC del trabajo): la CLI se usa con `npx --yes supabase@2.120.0 …` (sin instalar), los comandos con `set -a; . …` van en Git Bash, y los scripts de Python con `python -I -X utf8 …` (si no, la consola no imprime los ✅). Los secretos de Edge Functions con JSON (por ejemplo `FIREBASE_SERVICE_ACCOUNT`) se cargan con `secrets set --env-file <archivo temporal>` con el JSON en una sola línea: pasarlos como argumento por `npx` en Windows los corta. Si falta alguna credencial: token nuevo en supabase.com/dashboard/account/tokens y, si hace falta, resetear la contraseña de la base; `dev.json` y `web-publica/config.js` se arman con la API (clave publishable) sin copiar nada de otra máquina.
- La compilación web tarda (en esta máquina, varios minutos): correrla en segundo plano, con `--no-wasm-dry-run` (usa menos memoria) y **sin tocar el código mientras compila**. En Windows, al cortar `flutter run` puede quedar un `dartvm` escuchando en el puerto (3001): revisar con `Get-NetTCPConnection -LocalPort 3001` y cerrarlo.

## Reglas para trabajar en este proyecto

1. **Hablar en español rioplatense (voseo).** Los textos de la app también van en voseo.
2. Antes de cada paso, leer `docs/PROGRESO.md`, mostrar el plan en pocas líneas y **esperar la aprobación**.
3. **Un paso de `PROGRESO.md` por vez.** Al terminarlo, marcarlo `[x]`, mover el marcador "← ESTÁS ACÁ" y decir cuál es el siguiente.
4. Un commit por funcionalidad. Correr las pruebas antes de cada commit.
5. **Nunca** subir claves, `.env` ni credenciales al repositorio.
6. RLS activado en toda tabla nueva, y mostrar las políticas.
7. **Privacidad:** el teléfono del dueño nunca llega a otros usuarios. Se usa **contacto inverso**: quien contacta deja sus datos y el dueño decide. **No** redirigir a `wa.me/<número>` como vía por defecto, porque expone el número. La ubicación del dueño nunca es exacta ni pública.
8. **Costo del mapa:** respetar las reglas de `docs/08-arquitectura.md` (sin Places API, sin geocodificación, carga de pines por zona visible).
9. **Métricas desde el día 1:** toda acción relevante registra un evento anónimo (`docs/08-arquitectura.md`, sección Métricas).
10. Regla de oro del negocio: **lo que hace a la seguridad y la salud del animal no se cobra** (SOS, QR, foto, recordatorios de medicación).
11. Si una decisión nueva cambia algo de `docs/`, actualizar el documento y anotarla en `docs/12-decisiones.md`.
13. **Repositorio:** `github.com/Rodri18a/sosmascotas` (privado). Se trabaja en varias máquinas: al empezar, `git pull`; al terminar cada sesión o cambio importante, commit y `git push`.
12. **Web de documentación** (`./ver-docs.sh` → `http://localhost:3000/docs/`): lee los `.md` en vivo. Si se crea un documento nuevo, agregarlo a `docs/_sidebar.md`. Si cambia algo central (fases, planes, regla de oro), actualizar el resumen de `docs/README.md`. El panel "Estás acá" sale del marcador de `PROGRESO.md`.
