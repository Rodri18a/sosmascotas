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
| `reference/sos-mascota.html` | Prototipo funcional: referencia de pantallas y textos. **No portar el código tal cual** |
| `reference/SOS-Mascota-brief.md` | Brief anterior (costos detallados en pesos, cronología del prototipo) |

Si un dato de `reference/` contradice `docs/`, **manda `docs/`** (ver `docs/12-decisiones.md`).

## Stack

- **App:** Flutter (Android + iPhone + web instalable/PWA). Panel de administración en Flutter Web.
- **Backend:** Supabase (Postgres + PostGIS, Auth, Storage, Realtime, Edge Functions) con RLS en todas las tablas.
- **Notificaciones push:** Firebase Cloud Messaging. Recordatorios con notificaciones locales.
- **Mapa:** Google Maps nativo en Android/iPhone y MapLibre/OpenStreetMap en web, detrás de una capa propia.
- **Web pública del QR y de los perdidos:** página liviana y rápida, apta para SEO y para compartir.

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
12. **Web de documentación** (`./ver-docs.sh` → `http://localhost:3000/docs/`): lee los `.md` en vivo. Si se crea un documento nuevo, agregarlo a `docs/_sidebar.md`. Si cambia algo central (fases, planes, regla de oro), actualizar el resumen de `docs/README.md`. El panel "Estás acá" sale del marcador de `PROGRESO.md`.
