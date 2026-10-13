# Publicación de la web de documentación

## Estado actual (13/10/2026)

El repositorio es **privado** y se queda así (decisión D44). Por ahora la documentación se lee:

- **En GitHub** (privado, con tu cuenta, desde cualquier máquina o celular): <https://github.com/Rodri18a/sosmascotas/tree/main/docs>. Muestra los `.md` con formato; no tiene el menú lateral ni el panel "Estás acá" (para el panel, abrir `PROGRESO.md` y buscar "ESTÁS ACÁ").
- **Local, con la web completa:** `./ver-docs.sh` → `http://localhost:3000/docs/`.

> **¿Por qué no GitHub Pages?** Con la cuenta gratis no funciona en repos privados, y aun pagando, la web queda pública para cualquiera con el link (el login solo existe en GitHub Enterprise). Hacer público el repo expondría la estrategia, los precios y el plan.

## Pendiente (opcional): web online con login en Cloudflare

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
