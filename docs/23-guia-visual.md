# 23 · Guía visual de Huellitas (look and feel)

> Armada el 01/11/2026. Es la referencia para **dibujar y programar** todo lo que se ve: logo, ícono, colores, tipografía, íconos, pines, componentes y tono. Sale de la exploración de marca ([21](21-brief-huellitas.md), página «Huellitas · Exploración de marca») y de lo que ya funciona en la app.
> Cada punto dice si está **✅ decidido** (lo eligió el dueño) o **🟡 propuesto** (a confirmar). Hasta que se aplique (paso 0.8.3c), la app sigue con la marca SOS Mascotas de la D122.
> Si cambia algo de esta guía, actualizar también el brief del diseñador ([20](20-brief-logo-iconos.md)) y anotar la decisión en [12](12-decisiones.md).

## 1. La idea en una línea

**Huellitas es la comunidad que deja huella:** alegre y cercana, simple como para que la entienda un chico de cinco años, y confiable cuando hay una urgencia.

| Se siente | No se siente |
|---|---|
| Alegre, cercana, de barrio | Infantil o de dibujito |
| Simple y clara | Recargada |
| Confiable con los datos | Fría o de clínica |
| Calma en una urgencia | Alarmista |
| Para todos los animales | Solo perros y gatos |

## 2. Ícono y logo

| Pieza | Cómo es | Estado |
|---|---|---|
| **Símbolo** | Globo de conversación de un solo color con una **huella toda blanca** adentro (almohadilla y 4 dedos) | ✅ |
| **Ícono de la app de personas** | Globo **celeste `#1E9BD7`** con la huella blanca, sobre fondo blanco | ✅ color · 🟡 fondo |
| **Ícono de la app de comercios** | El mismo globo en **azul `#1F4FD1`** | ✅ |
| **Logotipo** | Símbolo a la izquierda + «Huellitas» en Nunito Black, color azul noche `#13294B` | 🟡 |
| **Frase** | «La comunidad que deja huella» | 🟡 |

**Reglas del símbolo:**

- La huella va **siempre blanca** (o del color del fondo, calada). Nunca de colores.
- El globo va **siempre de un solo color**: celeste para personas, azul para comercios, negro o blanco a una tinta.
- Lo importante queda dentro del **80 % central** del ícono (Android lo recorta en círculo).
- **Tamaño mínimo:** 16 px el símbolo (favicon); 96 px de ancho el logotipo horizontal.
- **Área libre alrededor:** como mínimo, el alto de un dedo de la huella.
- **A una tinta** (chapita grabada, sello, fotocopia): el globo negro y la huella calada.
- 🟡 **Para el arte final:** darle al globo una forma propia (por ejemplo la cola en forma de dedo o de oreja) para que no se confunda con el ícono de las apps de mensajería.

**Cómo no usarlo:** huella de colores, globo con degradé o sombra, el símbolo girado o deformado, el logo sobre una foto sin un fondo liso detrás, el pin de mapa como símbolo (se confunde con los pines de perdidos).

## 3. Colores

### 3.1 App de personas · modo claro 🟡

| Rol | Color | HEX | Contraste | Dónde |
|---|---|---|---|---|
| Marca | Celeste profundo | `#1E9BD7` | blanco encima 3,1:1 | Ícono, logo, botón redondo del Mapa, rellenos grandes con íconos blancos. **No** para texto chico |
| Primario | Celeste oscuro | `#126FA3` | blanco encima 5,5:1 · sobre el fondo 5,1:1 | Barra de arriba, botones, enlaces, pestaña elegida |
| Acento | Coral | `#FF6150` | texto azul noche encima 4,9:1 | Botón SOS, «Se perdió», destacados. Siempre con texto azul noche |
| Fondo | Celeste muy claro | `#F2F8FC` | — | Fondo de las pantallas |
| Superficie | Blanco | `#FFFFFF` | — | Tarjetas, hojas de abajo, diálogos |
| Texto | Azul noche | `#13294B` | sobre el fondo 13,6:1 | Títulos y texto |
| Texto suave | Gris azulado | `#4A5B72` | sobre el fondo 6,5:1 | Notas, ayudas, fechas |
| Error | Rojo | `#B3261E` | 6,1:1 | Errores de formularios |
| Éxito / abierto ahora | Verde | `#17705F` | 5,6:1 | «Abierto ahora», confirmaciones |
| Urgencias | Ámbar oscuro | `#9A4A00` | 5,9:1 | «Urgencias 24 h» |

### 3.2 App de personas · modo oscuro 🟡

| Rol | HEX | Contraste |
|---|---|---|
| Fondo | `#0E1A26` | — |
| Superficie | `#15283A` | — |
| Texto | `#E8F1F8` | 15,4:1 |
| Texto suave | `#A9BCCB` | 9,0:1 |
| Primario | `#5CC8F0` (celeste vivo) con texto `#0E1A26` encima | 9,2:1 |
| Marca | `#1E9BD7` (igual que en claro) | — |
| Acento | `#FF8A7D` con texto `#0E1A26` encima | 7,7:1 |
| Error | `#FF8A80` | 7,7:1 |
| Éxito | `#5ED3BF` | 9,7:1 |
| Urgencias | `#FFB238` | 9,8:1 |

### 3.3 App de comercios 🟡

Igual que la de personas, cambiando **marca y primario por el azul**:

| Rol | Claro | Oscuro |
|---|---|---|
| Marca y primario | `#1F4FD1` con texto blanco (6,8:1) | `#8FB0FF` con texto `#0E1A26` (8,2:1) |

Así, quien tiene las dos apps sabe en cuál está con solo mirar el color de la barra.

### 3.4 Colores de apoyo 🟡

Para ilustraciones, campañas, eventos y las tarjetas de noticias. **Nunca** como color de texto ni con letras blancas: van de relleno con texto azul noche encima.

| Turquesa | Amarillo | Rosa | Verde | Naranja |
|---|---|---|---|---|
| `#12B5A5` | `#FFC531` | `#FF7EB3` | `#2DBE73` | `#FF8A2B` |

### 3.5 Pines del mapa ✅ (no cambian)

| Pin | HEX | Luminosidad |
|---|---|---|
| Veterinaria | `#0B3D52` | muy oscuro |
| Perdido | `#D62839` | oscuro |
| Encontrado | `#1F9E8E` | medio |
| Urgencia 24 h | `#FFB238` | claro |

Se distinguen también por luminosidad (daltonismo), son gotas con la punta en el lugar exacto y llevan un borde que contrasta con el mapa. Ningún color de la marca se parece lo suficiente para confundirse.

### 3.6 Reglas de color ✅

1. **Contraste mínimo 4,5:1** para texto (3:1 si es de 24 px o más, o un ícono). Se controla en `app/test/tema_test.dart`.
2. **Colores vivos solo de relleno**, con texto azul noche encima. Con letras blancas no se leen al sol (lo que pasó con el celeste en la D123).
3. El rojo es solo para errores y el pin de perdido. La urgencia se transmite con calma.
4. El color nunca es la única señal: siempre va con un ícono o un texto.

## 4. Tipografía 🟡

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
- Hoy la app usa Sora + Source Sans 3; el cambio va en el paso 0.8.3c si se confirma.

## 5. Íconos ✅

- **Material de línea** (`_outlined`) en toda la app, del mismo trazo. Quedan rellenos solo los que muestran un estado (favorito, estrellas, pestaña elegida) y los de los pines.
- 🟡 Pasar a la variante **redondeada** (`_rounded`), que acompaña mejor a Nunito y a la huella.
- Barra de abajo: **Noticias** (artículo) · **SOS** (pin) · **Mapa** (botón redondo en el medio, color de marca) · **Mascotas** (huella) · **Ayuda** (signo de pregunta).
- Nada de emojis como íconos ni logos de otras marcas (el chat usa un globo genérico, no el de WhatsApp).
- La lista completa de íconos que necesita la app está en el [brief del diseñador](20-brief-logo-iconos.md).

## 6. Formas y componentes ✅

| Elemento | Regla |
|---|---|
| Esquinas | Botones y campos 12 px · tarjetas y hojas de abajo 16 px · ícono de la app 22 % |
| Botones | Alto mínimo 48 px. Principal: relleno primario. Secundario: borde. SOS: relleno coral con texto azul noche |
| Tarjetas | Superficie blanca sobre el fondo celeste muy claro 🟡 |
| Toques | Todo lo que se toca mide al menos 48 × 48 px |
| Barra de arriba | Color primario con texto e íconos blancos; flecha para volver en toda pantalla fuera de las pestañas |
| Hojas de abajo | Por encima de la barra de abajo, con la manija arriba |
| Movimiento | Corto y suave; se apaga si el sistema pide «reducir movimiento» |

## 7. Ilustraciones y fotos 🟡

- **Estados vacíos** (sin mascotas, sin perdidos cerca, sin avisos, sin conexión, «¡Apareció!»): dibujos simples, planos, con 2 o 3 colores de la paleta y la huella como recurso. Sin caras con ojos grandes.
- **Fotos:** las de las mascotas de la gente, siempre en un marco redondeado. Sin fotos de stock en la marca.

## 8. Tono y textos ✅

- **Español rioplatense con voseo:** «Reportá», «Avisale», «Tocá acá».
- Frases cortas y directas. Los botones dicen lo que pasa («Publicar aviso», no «Aceptar»).
- En una urgencia, calma y pasos claros: nada de mayúsculas ni signos de exclamación de más.
- **El juego con «huella»** 🟡, sin abusar:

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
| Logo con textos | `app/lib/src/widgets/logo.dart` |
| Íconos de la app (web, favicon, Android, iPhone, PDF, web pública) | Se generan con `flutter test tool/iconos_marca_test.dart` desde `app/` |
| Colores de los pines | `coloresPin` en `app/lib/src/mapa/mapa_vista.dart` |
| Web pública | `web-publica/assets/estilo.css` |
| Control de contraste | `app/test/tema_test.dart` |
| Textos | `app/lib/l10n/app_es.arb` |
