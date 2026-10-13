# Publicación de la web de documentación

La web se publica con **Cloudflare Pages** (gratis), conectada al repositorio privado de GitHub. **Se actualiza sola en cada `git push` a `main`.** El acceso está protegido con **Cloudflare Access**: solo entran los emails autorizados.

- Dirección: `https://<proyecto>.pages.dev` (se completa al terminar la configuración)
- Local: `./ver-docs.sh` → `http://localhost:3000/docs/`

## Configuración (una sola vez)

### 1. Crear la cuenta y conectar GitHub
1. Crear una cuenta gratis en <https://dash.cloudflare.com/sign-up>.
2. En el panel: **Workers y Pages → Crear → Pages → Conectar a Git**.
3. Autorizar GitHub y dar acceso **solo** al repositorio `Rodri18a/sosmascotas`.
4. Configuración de compilación:
   - Nombre del proyecto: `sosmascotas` (queda `sosmascotas.pages.dev`; si está tomado, elegir otro)
   - Rama de producción: `main`
   - Framework: **Ninguno**
   - Comando de compilación: **vacío**
   - Directorio de salida: **`/`** (la raíz)
5. **Guardar e implementar.** En un minuto queda publicada.

### 2. Protegerla con login (Cloudflare Access)
1. En el panel: **Zero Trust** (la primera vez pide elegir un nombre de equipo y el plan **Free**, hasta 50 usuarios; puede pedir una tarjeta aunque no cobra).
2. **Access → Aplicaciones → Agregar aplicación → Autoalojada (Self-hosted)**.
3. Dominios a proteger:
   - `sosmascotas.pages.dev`
   - `*.sosmascotas.pages.dev` (las vistas previas)
4. Política: **Permitir** → regla **Emails** → tu email (y los de quien quieras sumar).
5. Método de login: **One-time PIN** (llega un código al email; no hace falta otra cuenta).
6. Guardar. Probar en una ventana de incógnito: tiene que pedir el email.

> Los nombres de los menús de Cloudflare pueden cambiar un poco; la lógica es la misma.

## Cómo se actualiza

Cada cambio que se sube con `git push` a `main` dispara una nueva publicación automática (1–2 minutos). No hay que hacer nada más.

## Sumar a alguien

En **Zero Trust → Access → Aplicaciones → sosmascotas → Política**, agregar su email.
