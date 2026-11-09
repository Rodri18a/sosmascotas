# 23 · Guía visual de Huellamy (look and feel)

> **Desde el 09/11/2026 la marca es Huellamy (D146)**, con sus mascotas **Ami** (perrito shiba, collar azul) y **Michi** (gatita, collar rosa). Reemplaza a Huellitas (D126). La guía del dueño, con personalidad, poses y el prompt para generar más imágenes, está en [`guias/huellamy/guia-de-marca-e-iconografia.md`](guias/huellamy/guia-de-marca-e-iconografia.md) y el logo original en `guias/huellamy/logo-huellamy.png`. Esta página es la referencia para **dibujar y programar**: logo, ícono, colores, tipografía, íconos, pines, componentes y tono.
> Si cambia algo de esta guía, actualizar también el brief del diseñador ([20](20-brief-logo-iconos.md)) y anotar la decisión en [12](12-decisiones.md).

## 1. La idea en una línea

**Huellamy es un lugar para quienes aman a los animales:** cálida, alegre, cercana y familiar. La huella es el vínculo y las mascotas (Ami y Michi) son los guías. Amistosa y simple, sin infantilizar, y confiable cuando hay una urgencia.

| Se siente | No se siente |
|---|---|
| Cálida, alegre, de barrio | Infantil |
| Simple y clara | Recargada |
| Confiable con los datos | Fría o de clínica |
| Calma en una urgencia | Alarmista (Ami y Michi nunca asustan) |
| Para perros y gatos (primera versión, D149) | Cerrada a otras mascotas en el futuro |

## 2. Ícono y logo

| Pieza | Cómo es | Dónde |
|---|---|---|
| **Logo ilustrado** | Ami y Michi saludando sobre «Huellamy» («Huell» azul profundo, «amy» azul brillante, la «a» es una huella). Solo hay versión con **fondo blanco**: va en un recuadro redondeado | Ingreso, pantalla de carga, inicio de la web pública (`app/assets/marca/logo.jpg`, `app/web/icons/logo.jpg`, `web-publica/assets/logo.jpg`) |
| **Isotipo** | **Huella azul profundo `#0B4F94` sobre una mancha redonda celeste `#BFE3FA`**, dibujado en código | Menú ☰, portal, PDF, favicon |
| **Ícono de la app de personas** | La huella azul profundo sobre fondo celeste | Web, Android, iPhone |
| **Ícono de Huellamy Comercios** | Al revés: huella blanca sobre azul profundo | `web_comercios/` |
| **Logotipo solo texto** | «Huell» azul profundo + «amy» azul brillante `#1AA0EA`, Nunito Black | Menú y cabeceras |
| **Frase** | «La comunidad que deja huella» | Debajo del logo |

**Reglas:**

- Margen libre alrededor del logo: como mínimo el alto de la «H».
- No deformar, rotar ni cambiar los colores de los collares.
- Sobre fondos oscuros: el logo ilustrado siempre dentro de su recuadro blanco; el logotipo de texto pasa a claro.
- Lo importante del ícono queda dentro del **80 % central** (Android lo recorta en círculo).
- ⏳ **Pendiente:** versión del logo con fondo transparente y versión «solo mascotas» (por ahora no hay; D146).

## 3. Colores

### 3.1 App de personas · modo claro

| Rol | Color | HEX | Contraste | Dónde |
|---|---|---|---|---|
| Marca | Azul brillante | `#1798DF` (el `#1AA0EA` del logo, apenas más oscuro) | blanco encima 3,2:1 | Botón redondo del Mapa, rellenos grandes con íconos blancos. **No** para texto chico |
| Primario | Azul profundo | `#0B4F94` | blanco encima 8,2:1 · sobre el fondo 7,6:1 | Barra de arriba, botones, enlaces, pestaña elegida |
| Acento | Naranja de Ami | `#E8923A` | texto azul noche encima 6,0:1 | Botón SOS, «Se perdió», destacados. Siempre con texto azul noche |
| Fondo | Celeste muy claro | `#F0F8FE` | — | Fondo de las pantallas |
| Superficie | Blanco | `#FFFFFF` | — | Tarjetas, hojas de abajo, diálogos |
| Texto | Azul noche | `#13294B` | sobre el fondo 13,5:1 | Títulos y texto |
| Texto suave | Gris azulado | `#4A5B72` | sobre el fondo 6,5:1 | Notas, ayudas, fechas |
| Error | Rojo | `#B3261E` | 6,1:1 | Errores de formularios |
| Éxito / abierto ahora | Verde | `#17705F` | 5,6:1 | «Abierto ahora», confirmaciones |
| Urgencias | Ámbar oscuro | `#9A4A00` | 5,9:1 | «Urgencias 24 h» |

### 3.2 App de personas · modo oscuro

| Rol | HEX | Contraste |
|---|---|---|
| Fondo | `#0E1A26` | — |
| Superficie | `#15283A` | — |
| Texto | `#E8F1F8` | 15,4:1 |
| Texto suave | `#A9BCCB` | 9,0:1 |
| Primario | `#7CC4F5` con texto `#0E1A26` encima | 9,3:1 |
| Marca | `#1798DF` (igual que en claro) | — |
| Acento | `#F5A75A` con texto `#0E1A26` encima | 8,8:1 |
| Error | `#FF8A80` | 7,7:1 |
| Éxito | `#5ED3BF` | 9,7:1 |
| Urgencias | `#FFB238` | 9,8:1 |

### 3.3 App de comercios

Igual que la de personas, con la **marca también en azul profundo** `#0B4F94` (botón del Mapa e ícono). La diferencia se ve en el ícono (huella blanca sobre azul) y en el nombre «Huellamy Comercios».

### 3.4 Colores de apoyo (de la guía de marca)

Para ilustraciones, campañas, insignias y tarjetas de noticias. **Nunca** como color de texto ni con letras blancas: van de relleno con texto azul noche encima. Proporción sugerida: 60 % blanco y celeste, 25 % azules, 15 % acentos.

| Celeste | Naranja Ami | Crema | Gris lila Michi | Rosa (favoritos, «me gusta») | Amarillo (destellos) | Marrón (contorno de las mascotas) |
|---|---|---|---|---|---|---|
| `#BFE3FA` | `#E8923A` | `#FFF1DC` | `#A59BA6` | `#F28B8B` | `#FBC02D` | `#4A2418` |

### 3.5 Pines del mapa ✅ (no cambian)

| Pin | HEX | Luminosidad |
|---|---|---|
| Veterinaria | `#0B3D52` | muy oscuro |
| Perdido | `#D62839` | oscuro |
| Encontrado | `#1F9E8E` | medio |
| Urgencia 24 h | `#FFB238` | claro |

Se distinguen también por luminosidad (daltonismo), son gotas con la punta en el lugar exacto y llevan un borde que contrasta con el mapa.

### 3.6 Reglas de color ✅

1. **Contraste mínimo 4,5:1** para texto (3:1 si es de 24 px o más, o un ícono). Se controla en `app/test/tema_test.dart`.
2. **Colores vivos solo de relleno**, con texto azul noche encima. Con letras blancas no se leen al sol (D123). Por eso el azul brillante del logo no va en botones con texto.
3. El rojo es solo para errores y el pin de perdido. La urgencia se transmite con calma.
4. El color nunca es la única señal: siempre va con un ícono o un texto.

## 4. Tipografía

| Uso | Familia | Peso | Tamaño |
|---|---|---|---|
| Logotipo | Nunito | Black (900) | — |
| Títulos de pantalla | Nunito | ExtraBold (800) | 22 px |
| Subtítulos y títulos de tarjeta | Nunito | Bold (700) | 18 px |
| Texto | Nunito Sans | Regular (400) | 16 px |
| Botones | Nunito Sans | SemiBold (600) | 16 px |
| Notas y etiquetas | Nunito Sans | Regular (400) | 13 px |

- Gratuitas (Google Fonts), con ñ, tildes, ¿ y ¡. Van **incluidas en la app** (sin pedirlas a Google al abrir).
- El texto respeta el tamaño de letra del sistema.

## 5. Íconos ✅

- Estilo de la guía: línea gruesa y redondeada, sin ángulos filosos; la **huella** como motivo (viñeta, «me gusta», logros, separador).
- **Material de línea** (`_outlined`) en toda la app, del mismo trazo. Quedan rellenos solo los que muestran un estado (favorito, estrellas, pestaña elegida) y los de los pines.
- La variante de línea **redondeada** (Material Symbols Rounded) acompaña mejor a Nunito, pero Flutter no la trae: necesita otra librería y suma peso a la web. Por ahora quedan los de línea de Material (0.8.3c); se revisa con el set propio del diseñador.
- Barra de abajo: **Noticias** (artículo) · **SOS** (pin) · **Mapa** (botón redondo en el medio, color de marca) · **Mascotas** (huella) · **Ayuda** (signo de pregunta).
- Nada de emojis como íconos ni logos de otras marcas (el chat usa un globo genérico, no el de WhatsApp).
- La lista completa de íconos que necesita la app está en el [brief del diseñador](20-brief-logo-iconos.md).

## 6. Formas y componentes ✅

| Elemento | Regla |
|---|---|
| Esquinas | Botones y campos 12 px · tarjetas y hojas de abajo 16 px · ícono de la app 22 % |
| Botones | Alto mínimo 48 px. Principal: relleno primario. Secundario: borde. SOS: relleno naranja con texto azul noche |
| Tarjetas | Superficie blanca sobre el fondo celeste muy claro |
| Toques | Todo lo que se toca mide al menos 48 × 48 px |
| Barra de arriba | Color primario con texto e íconos blancos; flecha para volver en toda pantalla fuera de las pestañas |
| Hojas de abajo | Por encima de la barra de abajo, con la manija arriba |
| Movimiento | Corto y suave; se apaga si el sistema pide «reducir movimiento» |

## 7. Ilustraciones y fotos

- **Ami y Michi** acompañan los momentos de la app (⏳ falta generar las poses con el prompt de la guía de marca, §8):

| Momento | Mascota y pose |
|---|---|
| Bienvenida | Ami saludando con la patita; Michi asomada |
| Pantalla vacía | Michi curiosa, con cara de duda |
| Cargando | Ami corriendo o moviendo la cola |
| Éxito / publicación hecha | Los dos celebrando, con destellos amarillos |
| Error / sin conexión | Ami con orejas caídas; Michi tapándose los ojos (tierno, nunca alarmante) |
| Perfil y logros | Insignias con chapitas azules y rosas |

- Estilo de las ilustraciones: chibi, contorno marrón oscuro grueso, cabeza grande y cuerpo chico, fondo de manchas celestes. Personajes nuevos: de a uno, con un collar de color propio y una función concreta.
- **Fotos:** las de las mascotas de la gente, siempre en un marco redondeado. Sin fotos de stock en la marca.

## 8. Tono y textos ✅

- **Español rioplatense con voseo:** «Reportá», «Avisale», «Tocá acá».
- Frases cortas y directas. Los botones dicen lo que pasa («Publicar aviso», no «Aceptar»).
- En una urgencia, calma y pasos claros: nada de mayúsculas ni signos de exclamación de más.
- **El juego con «huella»**, sin abusar:

| Dónde | Texto |
|---|---|
| Frase de la marca | La comunidad que deja huella |
| Después de publicar un SOS | Tu aviso dejó huella: lo vieron 48 vecinos |
| Botón de compartir un perdido | Compartir también deja huella |
| Pedido de reseña | Tu reseña deja huella para otros dueños |
| Ficha de adopción | Adoptar deja la huella más grande |
| Estado vacío | Todavía no dejaste huellas acá |
| Perfil (idea, ver [17](17-propuestas-perfil-gamificacion.md)) | Tus huellas: 12 |
| Campañas | Juntos dejamos huella · Dejá tu huella · Cada huella cuenta |

## 9. Dónde vive cada cosa en el código

| Qué | Archivo |
|---|---|
| Paleta, tema e isotipo (app y portal) | `packages/core/lib/src/tema/` (`paleta.dart`, `app_theme.dart`, `isotipo.dart`) |
| Logo con textos (`LogoHuellamy`) e imagen del logo | `app/lib/src/widgets/logo.dart`, `app/assets/marca/logo.jpg` |
| Íconos de la app (web, favicon, Android, iPhone, PDF, web pública) | Se generan con `flutter test tool/iconos_marca_test.dart` desde `app/` |
| Colores de los pines | `coloresPin` en `app/lib/src/mapa/mapa_vista.dart` |
| Web pública | `web-publica/assets/estilo.css` |
| Control de contraste | `app/test/tema_test.dart` |
| Textos | `app/lib/l10n/app_es.arb` |
