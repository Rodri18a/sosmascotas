# Publicación de la web de documentación

## Estado actual (13/10/2026)

El repositorio es **privado** y se queda así (decisión D44). Por ahora la documentación se lee:

- **En GitHub** (privado, con tu cuenta, desde cualquier máquina o celular): <https://github.com/Rodri18a/sosmascotas/tree/main/docs>. Muestra los `.md` con formato; no tiene el menú lateral ni el panel "Estás acá" (para el panel, abrir `PROGRESO.md` y buscar "ESTÁS ACÁ").
- **Local, con la web completa:** `./ver-docs.sh` → `http://localhost:3000/docs/`.

> **¿Por qué no GitHub Pages?** Con la cuenta gratis no funciona en repos privados, y aun pagando, la web queda pública para cualquiera con el link (el login solo existe en GitHub Enterprise). Hacer público el repo expondría la estrategia, los precios y el plan.

## Online con login en Vercel (16/10/2026)

La documentación está en el proyecto **`sosmascota-docs`** de Vercel. Se entra con la **dirección de la publicación** (`https://sosmascota-docs-<id>-rodrigo18a-9252s-projects.vercel.app/docs/`), que pide iniciar sesión con la cuenta de Vercel del dueño (Deployment Protection estándar, gratis). La dirección cambia en cada subida.

**Cuidado:** la dirección corta `sosmascota-docs.vercel.app` **no** tiene login. La CLI la vuelve a asignar en cada subida (aunque se pida `--target preview`), así que hay que quitarla siempre enseguida y comprobar que dé 404:

```bash
# carpeta temporal con solo lo versionado de docs/, reference/ e index.html
git ls-files docs reference index.html | while read f; do mkdir -p "$D/$(dirname "$f")"; cp "$f" "$D/$f"; done
cd "$D" && npx --yes vercel@latest link --yes --project sosmascota-docs && rm -f .env.local .gitignore
npx --yes vercel@latest deploy --yes
npx --yes vercel@latest alias rm sosmascota-docs.vercel.app --yes   # ¡siempre!
curl -s -o /dev/null -w "%{http_code}\n" https://sosmascota-docs.vercel.app/docs/   # tiene que dar 404
```

La **web pública** de prueba (páginas del QR `/m/<código>` y del SOS `/s/<id>`, base de dev) está en **`sosmascota-web-dev`** → <https://sosmascota-web-dev.vercel.app>. Se sube desde una carpeta temporal con el contenido de `web-publica/` (incluido `config.js`, que no está en el repo; sin `servir.py`, `_redirects` ni `_headers`, que son de Cloudflare: en Vercel las reglas están en `web-publica/vercel.json`) con `vercel link --yes --project sosmascota-web-dev` y `vercel deploy --prod --yes`. La app la usa como `PUBLIC_BASE_URL` (en `app/config/dev.json`), así los enlaces del QR y del SOS no apuntan a `localhost`.

El **login** (Supabase Auth de dev) tiene como dirección principal la app online y permite también `localhost:3001` (`supabase/configurar_auth.py`): los enlaces de los correos y Google vuelven a la app desde donde se pidieron.

El **portal de administración** (D76) está en **`sosmascota-admin`** → <https://sosmascota-admin.vercel.app> (no indexable; los datos solo los ve el rol `admin`, verificado en la base). Se sube con `npx --yes vercel@latest deploy --prod --yes` desde `admin/build/web` después de `flutter build web --release --no-wasm-dry-run --dart-define-from-file=config/dev.json` (en `admin/`) y de copiar `web/vercel.json` a `build/web/`. Si `vercel link` crea un `.env.local` en esa carpeta, **borrarlo antes de subir** (tiene un token).

La app de prueba (base de dev) está en **`sosmascota-dev`** → <https://sosmascota-dev.vercel.app> (pública: es la app, no tiene nada privado). Se sube con `npx --yes vercel@latest deploy --prod --yes` desde `app/build/web` después de `flutter build web --release --no-wasm-dry-run --dart-define-from-file=config/dev.json` (`--no-wasm-dry-run` evita una segunda compilación de prueba a WebAssembly: con poca memoria, como en la PC de casa con 3,4 GB, el sistema cortaba la compilación). **Nunca** correr `vercel` desde la raíz del repo: publicaría la documentación en esa dirección pública. Ninguno de los dos proyectos tiene que estar **conectado a GitHub** (`vercel git disconnect`): si lo está, cada push publica la raíz del repo (la documentación) encima de la app. Pasó el 16/10 y se desconectó.

## Pendiente (opcional): web online con login en Cloudflare

Con dirección fija y login por código al email (más cómodo que Vercel).

Ya está casi todo preparado:

- [x] Cuenta de Cloudflare creada.
- [x] Publicación automática armada en `.github/workflows/publicar-docs.yml` (sube solo `docs/`, `reference/` e `index.html`).
- [x] Permiso `workflow` de GitHub autorizado en esta máquina.
- [ ] **Falta:** activar Zero Trust (plan Free) y crear el token de Cloudflare.

### Lo que hace el dueño del proyecto (5 minutos)

1. **Zero Trust:** en el panel de Cloudflare, menú **Zero Trust** → elegir nombre de equipo (`sosmascotas`) → plan **Free** (puede pedir tarjeta; no cobra).
2. **Token:** <https://dash.cloudflare.com/profile/api-tokens> → **Create Token** → **Create Custom Token** con estos permisos:

   | Tipo | Permiso | Nivel |
   |---|---|---|
   | Account | Cloudflare Pages | Edit |
   | Account | Access: Apps and Policies | Edit |
   | Account | Account Settings | Read |

3. Pegarlo en `~/.config/sosmascotas/cloudflare.env` (fuera del repo, **nunca** en el chat ni en un commit) y decirle a Claude "listo".

### Lo que hace Claude después

1. Crea el proyecto `sosmascotas` en Cloudflare Pages.
2. Guarda el token y el ID de cuenta como secretos del repo en GitHub.
3. Activa el disparo automático en cada push (hoy el workflow está solo en modo manual, para que no falle sin el token).
4. Crea la aplicación de Access con login por **código al email (One-time PIN)**, solo para tu email, sobre `sosmascotas.pages.dev` y `*.sosmascotas.pages.dev`.
5. Prueba que pida el login y anota acá la dirección final.

## Sumar a alguien (cuando esté online)

En **Zero Trust → Access → Aplicaciones → sosmascotas → Política**, agregar su email.

## Producción (paso 0.8.5) — lista para cuando se cree el proyecto

Revisado el 22/10/2026: las 51 migraciones sirven tal cual para producción. No traen datos de ejemplo (eso va en `supabase/seeds/` y en los cargadores con `--ejemplo`), ni direcciones de dev, ni ids de usuarios. La única funcionalidad gradual que crean es `temas_pro` (en beta). Las demás (`comercios`, `eventos`, `catalogo`, `chat`, etc.) se crean con `funcionalidades.py`; mientras no existan, en producción quedan **apagadas**, que es lo que queremos para el lanzamiento.

Pasos, en orden:

1. **El dueño** crea el proyecto de Supabase de producción (en la misma región que dev) y guarda la contraseña de la base. Credenciales en un archivo aparte, por ejemplo `~/.config/sosmascotas/supabase-prod.env`, **nunca** en el repo.
2. `supabase link --project-ref <ref de prod>` y `supabase db push --linked --dry-run`, revisar, y después sin `--dry-run`. Ojo: `link` cambia `supabase/.temp/project-ref`, que usan también los scripts de Python. **Volver a linkear dev al terminar.**
3. Edge Functions: `supabase functions deploy <nombre> --use-api` para `delete-account`, `owner-alert`, `qr-scan-alert`, `sos-follow-alert` y `sos-zone-alert`.
4. Secretos de las funciones: `FIREBASE_SERVICE_ACCOUNT` (del proyecto Firebase de **producción**; en Windows, con `--env-file`) y `TURNSTILE_SECRET` (clave de Turnstile para `sosmascotas.uy`). `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` los pone Supabase.
5. Login: **antes** de correr `supabase/configurar_auth.py --aplicar` contra producción, cambiarle `APP_ONLINE` y `ADMIN_ONLINE` a las direcciones de producción y sacar `localhost` de `uri_allow_list`. Hoy tiene escritas las de dev.
6. Datos reales: `cargar_comercios.py investigacion/veterinarias.csv --aplicar` y `cargar_ayuda.py investigacion/ayuda.csv --aplicar`. **Nunca** los seeds de `supabase/seeds/` (son solo para dev).
7. Rol de administración: `update profiles set role = 'admin'` para la cuenta del dueño, desde la base.
8. Configuración: `app/config/prod.json` (copiar de `prod.example.json`), `web-publica/config.js` con la clave publishable de producción y, para el portal, un `admin/config/prod.json` (no hay ejemplo todavía: copiar `dev.example.json` y cambiar la URL y la clave).
9. Respaldo: el plan gratis de Supabase no incluye respaldos. Hasta pagar Pro, `supabase db dump --linked` semanal guardado fuera del repo.
10. `rls_test.py` crea dos cuentas temporales y las borra: se puede correr contra producción, pero mejor antes de abrirla al público.
