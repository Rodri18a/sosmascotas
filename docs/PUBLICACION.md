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

**Dominio (D159, 16/11/2026):** `huellamy.com` y `www` → `sosmascota-web-dev`, `app.huellamy.com` → `sosmascota-dev`, `comercios.huellamy.com` → `sosmascota-comercios-dev`, `admin.huellamy.com` → `sosmascota-admin` (apuntan a dev hasta tener producción; al pasar, cambiar el proyecto de cada dominio en Vercel → Settings → Domains, sin tocar los DNS). DNS en Hostinger, por la API: `set -a; . ~/.config/sosmascotas/hostinger.env; set +a` y `curl -H "Authorization: Bearer $HOSTINGER_API_TOKEN" https://developers.hostinger.com/api/dns/v1/zones/huellamy.com` (lee la zona; `POST …/validate` y `PUT` con `{"overwrite":true,"zone":[…]}` la cambian). Los registros que pide cada dominio: `npx --yes vercel@latest domains verify <dominio>`.

**Dos apps (D156):** `tool/armar_web.sh dev` (desde `app/`) arma `build/web` (Huellamy → **`sosmascota-dev`**) y `build/web_comercios` (Huellamy Comercios → **`sosmascota-comercios-dev`** → <https://sosmascota-comercios-dev.vercel.app>). Cada carpeta se sube por separado con `vercel link --yes --project <proyecto>` (borrar el `.env.local` que crea) y `vercel deploy --prod --yes`. `config/dev.json` tiene que traer `APP_URL` y `COMERCIOS_URL`.

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

## Soporte (paso 0.8.6b, D160)

**Canales:** `contacto@huellamy.com` (reenvía al correo del dueño) y **Ajustes → Ayuda y soporte → «Escribinos»** en la app, que deja el mensaje en el portal → **Contactos** (filtro «Soporte (desde la app)»), con el correo de la cuenta para responder. El correo también está en la página del QR y en el pie de la landing. **Meta: responder en menos de 24 horas.**

**Correo (17/11/2026):** casilla **`contacto@huellamy.com`** en Hostinger (correo Business gratis del plan, 2 casillas, vence el 17/11/2027: renovar o pasar a otro plan antes). Es el correo de soporte y de contacto (no se armó `soporte@`: la API de Hostinger solo lee reenvíos y casillas, `GET /api/mail/v1/orders/{id}/mailboxes`; crearlos es desde hPanel). Responder **desde** `contacto@` (no desde el correo personal), así no se expone una dirección personal. **Redes:** Instagram [@huellamy.app](https://www.instagram.com/huellamy.app/) y Facebook [huellamy](https://www.facebook.com/huellamy), enlazadas en la landing y en Ayuda y soporte.

**Sumar el WhatsApp (después del lanzamiento):** número de la empresa, nunca uno personal de otra persona. Con las credenciales de siempre:

```sh
supabase db query --linked "insert into public.app_settings (key, value) values ('support_whatsapp', '598XXXXXXXX') on conflict (key) do update set value = excluded.value, updated_at = now()"
```

Aparece solo en la app (sin compilar). Para sacarlo: `delete from public.app_settings where key = 'support_whatsapp'`. En la web pública (`m.html`, `index.html`) hay que sumarlo a mano.

### Guardia de fin de año (24/12 al 2/1)

Son las semanas de los fuegos artificiales: más mascotas perdidas y más gente nueva en la app.

- Mirar el portal → Contactos y el correo **dos veces por día** (mañana y noche), y el portal → Moderación (avisos reportados).
- Si alguien escribe por una mascota perdida: primero, que publique el SOS (no se resuelve por soporte).
- Anotar acá quién cubre cada día si el dueño no está.

**Respuestas armadas** (copiar, completar y responder desde `contacto@`):

- **Se perdió mi mascota:** «¡Hola! Lo más rápido es publicar el aviso en la app: SOS → Publicar. Les llega a los vecinos de la zona y a las veterinarias y protectoras de la zona. Si tu mascota tiene la chapita QR, quien la encuentre te avisa sin ver tu teléfono. Cualquier cosa, escribinos de nuevo.»
- **Encontré una mascota:** «¡Gracias por ayudar! Si tiene chapita, escaneá el QR y avisale a la familia desde ahí. Si no, publicala en SOS → Encontré una mascota. Si está lastimada, en la app está la lista de veterinarias de Urgencias.»
- **No me llega el código para ingresar:** «Revisá la carpeta de spam o promociones; el correo llega de Huellamy. Si en 5 minutos no llegó, pedí uno nuevo desde la misma pantalla. Si sigue sin llegar, respondenos y lo resolvemos.»
- **La chapita no funciona:** «Contanos qué pasa al escanearla (si no abre nada, si dice que no está vinculada, etc.) y, si podés, mandanos una foto de la chapita. Si dice "todavía no tiene una mascota vinculada", se activa desde la app: Mascotas → tu mascota → Chapita QR.»
- **Quiero borrar mi cuenta:** «Lo podés hacer vos desde Ajustes → Borrar mi cuenta: se borran tus datos y los de tus mascotas. Si tenés algún problema, decinos.»
- **Soy un comercio y quiero aparecer:** «¡Qué bueno! Entrá a Huellamy Comercios (comercios.huellamy.com), creá tu cuenta y reclamá o cargá tu negocio. Si preferís, respondenos con el nombre y la dirección y te ayudamos.»

## Producción (paso 0.8.5) — lista para cuando se cree el proyecto

Revisado de nuevo el **30/10/2026**: las **82 migraciones** sirven tal cual para producción. No traen datos de ejemplo (van en `supabase/seeds/` y en los cargadores con `--ejemplo`), ni direcciones de dev, ni correos o ids de usuarios. La única funcionalidad gradual que crean es `temas_pro` (en beta); las otras 23 que hay en dev (`comercios`, `chat`, `cuidados`, etc.) se crean con `funcionalidades.py`, así que en producción quedan **apagadas** hasta crearlas. Las migraciones también prenden `pg_cron` y `pg_net` y programan 4 tareas (`resumir-estadisticas`, `reporte-mensual`, `vencer-planes`, `recordar-turnos`).

**Cuidado con el proyecto vinculado:** `supabase link` cambia `supabase/.temp/project-ref`, y **todos** los scripts de Python (`configurar_auth.py`, `funcionalidades.py`, `cargar_*.py`, `rls_test.py`) usan ese proyecto. `configurar_auth.py` se niega a correr si `SOSM_PROJECT_REF` no coincide con el vinculado; con los demás, mirar `cat supabase/.temp/project-ref` antes. **Volver a vincular dev al terminar.**

### Lo que hace el dueño (≈ 15 min)

1. Crear el proyecto de Supabase de producción, en la **misma región que dev**, y guardar la contraseña de la base.
2. Crear `~/.config/sosmascotas/supabase-prod.env` (**nunca** en el repo), con:
   ```
   SUPABASE_ACCESS_TOKEN=…        # el mismo token de la cuenta
   SUPABASE_DB_PASSWORD=…         # la de producción
   SOSM_PROJECT_REF=<ref de prod>
   SOSM_APP_URL=https://app.huellamy.com
   SOSM_COMERCIOS_URL=https://comercios.huellamy.com   # D156
   SOSM_ADMIN_URL=https://admin.huellamy.com           # D156
   ```
3. Si se separan los avisos: proyecto de **Firebase de producción** (cuenta de servicio y configuración web) y un sitio de **Turnstile** para el dominio de producción.
4. Decidir qué funcionalidades se prenden en el lanzamiento (ver el paso 9).

### Lo que hace Claude después, en orden

1. `set -a; . ~/.config/sosmascotas/supabase-prod.env; set +a`, después `supabase link --project-ref $SOSM_PROJECT_REF` y `supabase db push --linked --dry-run`. Mostrar el resultado, esperar el visto bueno y aplicar sin `--dry-run`.
2. **Edge Functions** (las 11): `delete-account`, `owner-alert`, `historial-adjuntos`, `landing-contact`, `qr-scan-alert`, `sos-follow-alert`, `sos-zone-alert`, `order-status-alert`, `booking-alert`, `care-alert` y `monthly-report`, con `supabase functions deploy <nombre> --use-api`. Todas llevan `verify_jwt = false` (está en `config.toml`) y controlan quién las llama por dentro.
3. **Secretos de las funciones** (`supabase secrets set`; en Windows, los que tienen JSON con `--env-file`):
   - `FIREBASE_SERVICE_ACCOUNT`: todas las que mandan push (`_shared/fcm.ts`).
   - `TURNSTILE_SECRET`: `owner-alert` (el anti-bots de la página del QR) y `landing-contact` (el formulario de la landing, D158).
   - `CRON_SECRET`: `booking-alert` (recordatorio de turnos).
   - `MONTHLY_REPORT_SECRET`: `monthly-report`.
   - `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` los pone Supabase.
4. **Vault** (para las tareas programadas que llaman a funciones; sin esto solo dejan un aviso y no hacen nada): `select vault.create_secret('<https://ref.supabase.co>', 'project_url');`, más `cron_secret` y `monthly_report_secret` con **los mismos valores** que `CRON_SECRET` y `MONTHLY_REPORT_SECRET`.
5. **Login:** `python -I -X utf8 supabase/configurar_auth.py` (vista previa) y después `--aplicar`. Con `SOSM_APP_URL` y `SOSM_ADMIN_URL` usa las direcciones de producción y **no** permite `localhost`. Si ya existe el proveedor de correo (0.4.4b), los correos salen en español con código.
6. **Datos reales:** `cargar_comercios.py investigacion/veterinarias.csv --aplicar` y `cargar_ayuda.py investigacion/ayuda.csv --aplicar`. **Nunca** los seeds de `supabase/seeds/` (son solo para dev: a nombre del dueño, con teléfonos de mentira).
7. **Rol de administración:** `update profiles set role = 'admin'` para la cuenta del dueño, después de que entre por primera vez.
8. **Configuración:** `app/config/prod.json` y `admin/config/prod.json` (copiar de `prod.example.json`) y `web-publica/config.js` con la clave publishable de producción. Antes de subir, revisar en `main.dart.js` que **no** aparezcan `localhost` ni `sosmascota-web-dev`.
9. **Funcionalidades:** crear con `funcionalidades.py crear` solo las que se lanzan y dejarlas en el estado que decida el dueño. Lo que no se cree queda apagado.
10. **Seguridad:** `python -I -X utf8 supabase/tests/rls_test.py` contra producción **antes** de abrirla al público (crea dos cuentas temporales y las borra).
11. **Respaldo:** el plan gratis de Supabase no incluye respaldos. Hasta pasar a Pro, `supabase db dump --linked -f <carpeta fuera del repo>/prod-AAAA-MM-DD.sql` **una vez por semana** (y también con `--data-only`).
12. Volver a vincular dev: `supabase link --project-ref <ref de dev>`.
