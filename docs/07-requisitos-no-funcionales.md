# 07 · Requisitos no funcionales

## Plataformas

| Pieza | Plataforma | Fase |
|---|---|---|
| App de usuarios y modo comercio | **Web instalable (PWA)** en `sosmascotas.uy` | 0 |
| | **Android** (Google Play) | Fase 0 en paralelo → publicada a inicios de la Fase 1 |
| | **iPhone** (App Store) | 1 |
| Página pública de QR y de reportes | Web liviana (sin instalar nada) | 0 |
| Portal de administración | Flutter Web | 1 |
| Portal de empresas | Flutter Web | 2 |

> Las notificaciones push en la PWA funcionan en Android. En iPhone solo funcionan si la PWA se agregó a la pantalla de inicio (iOS 16.4 o posterior). Por eso la app nativa de iPhone llega en la Fase 1.

## Idioma, moneda y región

- **Español rioplatense (voseo)** al inicio.
- Preparada desde el principio para varios idiomas (archivos de traducción, sin textos fijos en el código). Próximos: portugués e inglés.
- Moneda, formato de fecha y zona horaria por zona o país.

## Funcionamiento sin internet

Funcionan sin conexión: el perfil de la mascota, la libreta sanitaria, el QR (para mostrarlo) y los **recordatorios** (notificaciones locales). El resto necesita internet y muestra un aviso claro cuando no hay conexión.

## Rendimiento

- La página pública del QR carga en **menos de 2 segundos** con 4G (alguien está en la calle con un animal perdido).
- El mapa trae solo los pines de la zona visible, agrupados cuando son muchos.
- Las fotos se comprimen en el celular antes de subirlas (lado mayor de 1080 px, WebP o JPG con calidad ~80).

## Escala

- Meta: **~10.000 usuarios activos**.
- Arquitectura que arranca en planes gratis y **crece sin rehacerse** (Supabase gratis → Pro → planes superiores).
- Datos separados **por zona** para poder habilitar zonas y países nuevos.

## Seguridad

- **RLS** en todas las tablas. Las acciones sensibles pasan por Edge Functions.
- Los teléfonos nunca se devuelven al cliente.
- El rol de administrador se valida en el servidor.
- Claves y secretos fuera del repositorio (`.env`, secretos de Supabase).
- Límites de uso (rate limiting) en la publicación de SOS, contactos desde el QR y el chat.
- Copias de seguridad diarias (plan Pro de Supabase).

## Privacidad

Cumplimiento de la **Ley 18.331** de Protección de Datos Personales de Uruguay (ver `06-reglas-negocio.md`).

## Accesibilidad

- Tamaño de letra ajustable (y respeta el tamaño del sistema).
- Buen contraste, en modo claro y oscuro automático.
- Compatible con lectores de pantalla (etiquetas en botones e íconos).
- Botones grandes, pensando en personas mayores.

## Diseño

- Identidad **C · Cielo** (D62): azul petróleo `#0F5E7A`, coral `#FF7A59` para lo destacado y el SOS, fondo hueso `#F6F4EF`; Sora + Source Sans 3. Paleta, pines y temas Pro en `14-brief-identidad-visual.md` §10.
- Pantallas principales sin scroll de página; el mapa ocupa el espacio disponible; la ficha del lugar sube desde abajo.
- Filtros como grillas horizontales agrupadas, no como burbujas sueltas.
- Referencia visual: `reference/sos-mascota.html`.

## Calidad

- Pruebas de los flujos principales (registro, cargar mascota, publicar SOS, escanear QR, contactar).
- Un commit por funcionalidad y pruebas antes de cada commit.
- Entornos separados de **desarrollo** y **producción**.
