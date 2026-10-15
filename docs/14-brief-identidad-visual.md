# 14 · Brief de identidad visual (para pasarle a una IA o a un diseñador)

> Documento pensado para **copiar y pegar** en una IA de imágenes o de diseño (o mandárselo a un diseñador) y obtener la identidad completa de SOS Mascota: logo, ícono de la app, paleta, tipografías, íconos, pines del mapa, ilustraciones y piezas impresas.
> Las 4 direcciones de partida se pueden ver en el lienzo **"SOS Mascota · Opciones de identidad"** (enlace en la sesión del 15/10/2026). **No tiene por qué ser verde**: el verde `#1F8A5B` de la app es provisorio (paso 0.0.9b).

---

## 1. Qué es SOS Mascota (contexto para la IA)

- App (Android, iPhone y web instalable) para **dueños de mascotas** y **comercios del rubro**, con un **mapa** como centro.
- Arranca en **Pando, Uruguay**, y se expande por zonas. Todo el texto es en **español rioplatense (voseo)**: "Reportá", "Avisale", "Tocá".
- Funciones que la identidad tiene que poder representar:
  - **SOS**: mascotas perdidas y encontradas en el mapa, avisos push a los vecinos cercanos.
  - **Chapita con QR**: quien encuentra a la mascota escanea la chapita y avisa a la familia **sin ver su teléfono** (privacidad).
  - **Veterinarias de urgencia** con "abierto ahora", petshops, servicios, lugares que aceptan mascotas.
  - **Ayuda**: refugios, protectoras, grupos de difusión, aviso del 911.
  - Más adelante: recordatorios de salud, libreta sanitaria, adopciones, reseñas, portal para empresas.
- Regla de oro del negocio: **lo que hace a la seguridad y la salud del animal es gratis**.

## 2. A quién le habla

- Dueños de perros y gatos (también aves, conejos, caballos…) de 18 a 65 años, en ciudades chicas y medianas de Uruguay. Muchos usan el celular al sol, con apuro y nervios (se perdió la mascota).
- Vecinos que **encuentran** un animal y quieren ayudar en 30 segundos, sin descargar nada.
- Veterinarias y comercios de barrio que tienen que verla como una herramienta seria.

## 3. Personalidad

| Es | No es |
|---|---|
| Cercana, de barrio, solidaria | Infantil o caricaturesca |
| Clara y calma en una urgencia | Alarmista (rojo sirena por todos lados) |
| Confiable con los datos (privacidad) | Fría o burocrática |
| Uruguaya, sin estereotipos turísticos | Genérica de Silicon Valley |

Palabras clave: **rescate, vecinos, confianza, rapidez, cuidado, huella, señal**.

## 4. Restricciones técnicas (obligatorias)

1. **Legibilidad al sol**: contraste mínimo 4,5:1 para texto (3:1 para texto ≥ 24 px). Los colores que se tienen que distinguir (perdido / encontrado / veterinaria / urgencia en el mapa) también difieren en **luminosidad**, no solo en tono (daltonismo).
2. **Modo claro y oscuro**: la paleta tiene que funcionar en los dos.
3. **El logo funciona a una tinta** (grabado láser en la chapita, sello, fotocopia en blanco y negro) y a **16 px** (favicon).
4. **Ícono de la app** cuadrado con zona segura para Android (*maskable*: lo importante dentro del 80 % central) y sin texto.
5. **Tipografías gratuitas de Google Fonts**, con buen soporte de **ñ, tildes, ¿ ¡**. Máximo 2 familias. Evitar Inter, Roboto, Arial y Open Sans (demasiado genéricas).
6. Nada de fotos de stock ni emojis como parte de la marca.
7. Texto en las piezas siempre en voseo.

## 5. Qué hay que entregar

| # | Pieza | Formatos y tamaños |
|---|---|---|
| 1 | **Logo** completo (isotipo + nombre) horizontal y vertical | SVG; versión a color, a una tinta negra y a una tinta blanca |
| 2 | **Isotipo** solo (sin texto) | SVG; tiene que leerse a 16 px |
| 3 | **Ícono de la app** | PNG 1024, 512, 192 (normal y *maskable*), 180 (iPhone), favicon 32 y 16 |
| 4 | **Paleta** | 1 primario, 1 de acento, 2 neutros (fondo y texto), 4 de estado para el mapa (perdido, encontrado, veterinaria, urgencia) y éxito / error. Hex, con su versión para modo oscuro y los pares de contraste verificados |
| 5 | **Tipografía** | Familia de títulos y de texto (Google Fonts), pesos a usar, escala de tamaños (título, subtítulo, cuerpo, nota) |
| 6 | **Set de íconos** (mismo estilo, trazo y esquinas) | SVG 24×24, ver lista en la sección 6 |
| 7 | **Pines del mapa** | 4 tipos (perdido, encontrado, veterinaria, urgencia 24 h), legibles sobre un mapa claro y uno oscuro, a 24 y 32 px |
| 8 | **Ilustraciones de estado vacío** (5) | "Todavía no cargaste mascotas", "No hay perdidos cerca", "Sin avisos", "Sin conexión", "¡Apareció!" (festejo). Estilo simple, 2–3 colores de la paleta |
| 9 | **Chapita QR** | Redonda de 25–30 mm y de hueso; lado A con el isotipo, lado B con el QR (código de 8 caracteres debajo) y "Escaneame si me encontrás" |
| 10 | **Pantalla de carga** | Fondo de color de marca con el isotipo centrado |
| 11 | **Volante A5 y post cuadrado para redes** | "¿Se perdió tu mascota? Reportala en SOS Mascota" + QR a la web |

## 6. Íconos que necesita la app

Mapa · SOS (alerta) · Mascota (huella) · Ayuda (escudo/corazón) · Avisos (campana) · Ajustes · QR · Chapita · Veterinaria (cruz) · Urgencia 24 h · Teléfono · WhatsApp (genérico de chat, no el logo de WhatsApp) · Cómo llegar · Compartir · Cámara / foto · Ubicación · Zona aproximada (círculo punteado) · Perro · Gato · Ave · Conejo · Otro animal · Recompensa · Microchip · Encontrado (mano/abrazo) · ¡Apareció! (corazón) · Reportar contenido (bandera) · Refugio (casa) · Grupo (personas) · Calendario · Medicación (pastilla) · Vacuna · Reseña (estrella) · Favorito · Filtro · Buscar · Cerrar · Atrás · Más.

## 7. Direcciones de partida (para elegir o mezclar)

| | A · Faro | B · Vecinos | C · Cielo | D · Pop |
|---|---|---|---|---|
| Idea | Señal de rescate: urgencia sin alarma | El barrio que se cuida entre todos | Calma y confianza, aire de salud | Joven, sticker, redes |
| Colores | Naranja señal `#F25C05`, azul noche `#14213D`, crema `#FFF8F0`, verde agua `#2A9D8F` | Terracota `#B5462F`, mostaza `#F2C14E`, marfil `#FAF3E3`, verde monte `#3E5C4A` | Azul petróleo `#0F5E7A`, coral `#FF7A59`, hueso `#F6F4EF`, tinta `#102A35` | Violeta `#5B2EBB`, amarillo `#FFD23F`, lila `#F3EEFF`, carbón `#17151F` |
| Tipografías | Bricolage Grotesque + Atkinson Hyperlegible | Fraunces + Nunito Sans | Sora + Source Sans 3 | Baloo 2 + Figtree |
| Logo | Huella dentro de un pin de mapa | Casita con una huella | Chapita redonda con argolla y huella | "SOS" con una huella en lugar de la O, tipo calcomanía |
| Íconos | Trazo grueso redondeado, fondo sólido | Trazo medio en círculos de color | Trazo fino, sin relleno | Trazo grueso con contorno y sombra dura |
| Riesgo | Naranja muy usado en apps de delivery | Puede verse "antiguo" | Puede verse genérico si no se cuida | Puede sentirse un juego en una urgencia |

## 8. Prompt listo para copiar

```text
Sos un diseñador de identidad de marca. Diseñá la identidad visual completa de "SOS Mascota",
una app uruguaya (arranca en Pando) para encontrar mascotas perdidas, con un mapa de
veterinarias de urgencia, chapitas con QR para que quien encuentra a la mascota avise a la
familia sin ver su teléfono, y un directorio de refugios. Tono: cercano, de barrio, calmo
en una urgencia, confiable con los datos; nunca infantil ni alarmista. Textos en español
rioplatense (voseo).

Partí de la dirección [A Faro / B Vecinos / C Cielo / D Pop / mezcla de …] y proponé 3
variantes de logo dentro de esa dirección.

Restricciones: contraste mínimo 4,5:1; modo claro y oscuro; el logo funciona a una tinta
(grabado láser en una chapita de 25 mm) y a 16 px; ícono de app maskable sin texto;
tipografías gratuitas de Google Fonts con buen soporte de ñ y tildes (no Inter, Roboto,
Arial ni Open Sans); los 4 colores del mapa (perdido, encontrado, veterinaria, urgencia)
se distinguen también en luminosidad; sin emojis ni fotos de stock.

Entregá: logo horizontal y vertical (color, negro, blanco), isotipo, ícono de app
(1024/512/192/180 y favicon), paleta con roles y hex para claro y oscuro, tipografía con
escala de tamaños, set de íconos SVG 24×24 de un solo estilo [pegar la lista de la
sección 6], 4 pines de mapa, 5 ilustraciones de estado vacío, diseño de chapita QR
redonda (lado A isotipo, lado B QR con el código de 8 caracteres), pantalla de carga,
volante A5 y post cuadrado para redes.
```

## 9. Después de elegir

1. Cargar la paleta y las tipografías en `app/lib/src/theme/app_theme.dart` (hoy el tema sale del verde `#1F8A5B`) y en la web pública (`web-publica/assets/estilo.css`).
2. Reemplazar los íconos de `app/web/icons/` (hoy son el logo de Flutter) y el favicon: es parte del paso **0.8.1**.
3. Colores de los pines en `coloresPin` (`app/lib/src/mapa/mapa_vista.dart`).
4. Anotar la decisión en `12-decisiones.md` y cerrar el paso **0.0.9b**.
