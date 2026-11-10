# Guía · Activar "Continuar con Google" (paso 0.2.3)

> ✅ Activado en dev el 14/10/2026.

La app ya tiene el botón: aparece solo cuando Google está activado en Supabase. Para activarlo hacen falta unas credenciales que **solo puede crear el dueño de la cuenta de Google** (≈ 15 minutos, gratis).

## 1. Crear el proyecto en Google Cloud

1. Entrar a <https://console.cloud.google.com/> con tu cuenta de Google.
2. Arriba, **Seleccionar proyecto → Proyecto nuevo** → nombre `SOS Mascota` → **Crear**.

## 2. Pantalla de consentimiento (lo que ve la persona al elegir su cuenta)

1. Menú → **APIs y servicios → Pantalla de consentimiento de OAuth** (o **Google Auth Platform → Branding**).
2. Tipo de usuario: **Externo**.
3. Nombre de la app: `SOS Mascota`. Correo de asistencia y de contacto: tu correo.
4. Permisos (scopes): dejar los básicos (`email`, `profile`, `openid`). **No agregar otros**.
5. Mientras esté en modo **Prueba**, solo entran los correos que agregues en **Usuarios de prueba** (agregate vos). Antes del lanzamiento se publica.

## 3. Crear las credenciales

1. **APIs y servicios → Credenciales → Crear credenciales → ID de cliente de OAuth** (o **Google Auth Platform → Clientes → Crear cliente**).
2. Tipo de aplicación: **Aplicación web**. Nombre: `SOS Mascota web`.
3. **Orígenes autorizados de JavaScript:** `http://localhost:3001`
4. **URI de redireccionamiento autorizados** (copiar exacto):
   ```
   https://svemuapldovnbdruzvkz.supabase.co/auth/v1/callback
   ```
5. **Crear.** Google muestra el **ID de cliente** y el **Secreto del cliente**.

## 4. Pasárselas a Supabase (sin ponerlas en el chat)

1. Abrir `~/.config/sosmascotas/supabase-dev.env` y completar:
   ```
   GOOGLE_CLIENT_ID=…apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=…
   ```
2. Decirle a Claude "listo": corre `python3 -I supabase/configurar_auth.py --aplicar` y el botón aparece solo.

> Cuando exista el dominio (0.8.6), sumar `https://huellamy.com` a los orígenes autorizados y a `uri_allow_list` del script. Para Android/iPhone nativos (Fase 1) se crean clientes aparte.
