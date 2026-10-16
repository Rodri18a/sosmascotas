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

La app de prueba (base de dev) está en **`sosmascota-dev`** → <https://sosmascota-dev.vercel.app> (pública: es la app, no tiene nada privado). Se sube con `npx --yes vercel@latest deploy --prod --yes` desde `app/build/web` después de `flutter build web --release --dart-define-from-file=config/dev.json`. **Nunca** correr `vercel` desde la raíz del repo: publicaría la documentación en esa dirección pública.

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
