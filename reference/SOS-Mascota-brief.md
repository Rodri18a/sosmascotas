# SOS Mascota: brief completo del proyecto

> Documento de traspaso para continuar el proyecto desde cero en Claude (con Claude Code). Resume la idea, todo lo que se construyó paso a paso, las decisiones tomadas, las reglas de negocio, el plan por versiones con costos y prompts listos para arrancar.
> Autor del proyecto: Rodrigo (Uruguay). Actualizado: 10 de octubre de 2026.

---

## 0. Cómo usar este archivo

1. Creá un repositorio y guardá este archivo como `CLAUDE.md` en la raíz.
2. Guardá `sos-mascota.html` en una carpeta `reference/`. Es el prototipo funcional: sirve como referencia de pantallas, textos y comportamiento. **No hay que portar su código tal cual**, hay que reconstruirlo con una arquitectura real (sección 9).
3. Abrí Claude Code en esa carpeta y pegá el prompt de arranque de la sección 12.
4. Trabajá **una versión por vez** (0.1, 0.2, ...). Cada versión tiene su meta de resultados antes de pasar a la siguiente.

---

## 1. La idea en pocas líneas

App con mapa para dueños de mascotas. El usuario registra a su mascota (perro, gato, tortuga, pez, ave u otro) y en el mapa encuentra lugares útiles para ella, con filtros por necesidad (comida, veterinaria, peluquería, accesorios, farmacia). Al tocar un punto ve horario, dirección y contacto.

Hay dos tipos de usuario:
- **Dueño de mascota** (uso gratis): mapa, fichas de sus mascotas, favoritos y calificaciones, SOS de mascotas perdidas y encontradas, turnos y pedidos.
- **Comercio** (paga): reclama su lugar, lo destaca y activa módulos (catálogo, agenda, socios) según su tipo de negocio.

**Monetización:** planes mensuales para comercios (Destacado y Plus), versión Pro de pago único para usuarios (foto de la mascota, sin anuncios, personalización), y más adelante noticias patrocinadas de marcas.

**Estrategia:** empezar chico, en una zona cercana, con la versión mínima mínima (solo el mapa), captar primeros usuarios y comercios, y sumar funciones de a una. Gastar lo mínimo, que se pague rápido y reinvertir en mejorar la tecnología. La publicidad paga queda para después.

**Datos del proyecto:** nombre de la app "SOS Mascota". Dominio elegido: `sosmascotas.uy` (se vio libre; confirmar y comprar). Cambio usado en los números: US$1 = $40 uruguayos, €1 = $46.

---

## 2. Cronología: qué se hizo, paso a paso

1. **Primer MVP.** Mapa esquemático, registro de mascota (nombre y tipo), filtros por categoría, ficha del lugar con horario y dirección.
2. **Dos tipos de usuario.** El dueño puede marcar un punto en el mapa indicando solo el tipo de lugar (sin nombre) y un link de Google opcional. Queda como "sin reclamar". El comercio lo reclama, elige plan (básico gratis o destacado pago) y completa la ficha.
3. **Vista lista con distancia.** Alternativa al mapa, con filtro de distancia (300 m, 800 m, 2,5 km, todo), orden por abierto ahora y cercanía, y botón "Abierto ahora".
4. **Tiendas sin local.** Primero "tiendas online" con zona de envío, y luego ampliado a "Sin local": venta online y servicios a domicilio (por ejemplo peluquería que va a la casa), con zona de cobertura.
5. **Plan destacado ampliado.** Web, Instagram, Facebook y WhatsApp de contacto, y qué mascotas atiende el comercio.
6. **Varias mascotas.** Cada una filtra distinto; opción "Todas". Un supermercado que vende comida para perro no le aparece a quien tiene un pez.
7. **Ficha de la mascota, noticias, favoritos.** Nacimiento, último control, última vacuna; sección de noticias con promociones de marcas; favoritos, "fui", calificación y nota opcionales.
8. **Rediseño como aplicación real.** Pantallas separadas con barra inferior, sin scroll en las pantallas principales (solo en la grilla de noticias y formularios), filtros como grilla horizontal agrupada, barra de publicidad pequeña, versión Pro, foto y raza de la mascota, recordatorios, veterinaria asociada.
9. **Foto como parte de Pro.** Pago único (idea: unos 40 pesos) que incluye foto de la mascota, sin anuncios y personalización (color y tamaño de letra). Se analizó la rentabilidad (sección 8).
10. **Pestaña SOS.** Mascotas perdidas y encontradas, con pines en el mapa, foto, WhatsApp oculto y directorio de ayuda. Pantalla inicial con el logo.
11. **Proyección de costos y plan.** Gastos de puesta en marcha y mensuales, peor caso, punto de equilibrio y plan por fases.
12. **Versión mínima mínima.** Salir como web en el dominio propio, sumar funciones de a una, dejar las cuentas de las tiendas de apps para más adelante. Google Maps como pieza central, con su costo por paso.
13. **Feedback de un amigo.** Para tener mejor llegada a los comercios: catálogo con pedidos y agenda de turnos.
14. **Prototipo integral.** Dos entradas (dueño y comercio), módulos activables según el tipo de negocio, planes, catálogo, pedidos, agenda, socios y recordatorios que se cruzan entre ambos lados.

---

## 3. Decisiones tomadas

| Tema | Decisión |
|---|---|
| Plataforma inicial | Web instalable (PWA) en `sosmascotas.uy`; app de Google Play desde la versión 0.5; iPhone más adelante |
| Mapa | Google Maps es fundamental. Con tope de cuota para gastar US$0 mientras se valida |
| Base de datos | Supabase (misma base para teléfono y computadora) |
| Login | Google primero; correo con enlace mágico como "usuario local"; Apple/iCloud para otra etapa |
| Datos al registrarse | Correo (viene con Google). El teléfono NO se pide al registrarse: solo al reportar una mascota o reclamar un comercio |
| Notificaciones | Las push usan un identificador del dispositivo, no el número de teléfono |
| Foto de la mascota | Función de Pro. La foto de un reporte SOS es gratis (es una cuestión de seguridad) |
| Cobro a comercios | Plan mensual. Cobro manual al inicio (transferencia o link de pago) |
| Pagos de pedidos | En la primera versión de catálogo el cliente paga directo al comercio; pago en la app queda para después |
| Publicidad paga | Después de captar los primeros usuarios, por boca a boca y QR en comercios |
| Carnet digital completo | En pausa; posible función pagada por la veterinaria para sus socios |
| Personas desaparecidas | La app es para animales; para personas se deriva a la Policía (911) |

---

## 4. Funcionalidades y reglas de negocio

### 4.1 Dueño de mascota

**Mascotas.** Tipos: perro, gato, tortuga, pez, ave, otro. Se pueden tener varias; hay una opción "Todas". Campos de la ficha: nombre, tipo, raza, nacimiento (se muestra la edad), último control, **próximo control o refuerzo**, última vacuna y su fecha, veterinaria asociada, notas y foto (Pro).

**Regla de coincidencia.** Un lugar, tienda o noticia coincide con la mascota activa si la lista de animales que atiende incluye su tipo. Con "Todas" se usa la unión de los tipos de todas las mascotas.

**Recordatorios.** Si el próximo control está a 30 días o menos, se muestra un aviso en la ficha (rojo a 7 días o menos, amarillo hasta 30, verde si falta más) y un punto en la pestaña. Si pasó la fecha, dice "vencido". Más adelante serán notificaciones reales, también desde la veterinaria.

**Mapa (pestaña Explorar).**
- Vistas: Mapa, Lista, Sin local (tiendas online y servicios a domicilio).
- Filtros: categoría, distancia (300 m, 800 m, 2,5 km, todo), "Abierto ahora", favoritos, capa de perdidos y encontrados.
- Estados de un lugar: **sin reclamar** (gris, "marcado por N usuarios", link de Google opcional), **básico** (verde) y **destacado** (naranja, etiqueta "Destacado", promo y contactos).
- Orden de la lista: abiertos primero, luego horario desconocido, luego cerrados; dentro de cada grupo, por cercanía.
- "Abierto ahora" se calcula desde el horario en texto (por ejemplo "Lun a Sáb 9:00–19:00") y la hora del teléfono. Hay que mejorarlo para que considere los días.
- Marcar lugar: botón flotante, el usuario elige el tipo, toca el mapa y puede pegar un link de Google. **No puede ponerle nombre.**
- Ficha del lugar: horario, dirección, distancia, animales que atiende, promo, links (web, Instagram, Facebook, WhatsApp), favorito, "fui", calificación de 1 a 5 y nota opcionales, y marcar como veterinaria de la mascota.

**Noticias.** Grilla de tarjetas filtrada por mascota. Mezcla novedades de la comunidad con promociones de marcas, que llevan la etiqueta "Promocionado".

**SOS (perdidas y encontradas).**
- Lista ordenada por cercanía, con foto, nombre, descripción, zona, fecha y distancia.
- Reporte: perdida o encontrada, mascota propia (precarga datos) u otra, tipo de animal, nombre, descripción, zona, ubicación tocando un mapa, foto y WhatsApp.
- **El WhatsApp se muestra oculto** (`*** *** 123`, solo los últimos tres dígitos). En la app real el número debe guardarse en el servidor y el contacto debe pasar por una función del servidor, para que nunca viaje al teléfono de los demás.
- El autor puede marcar el reporte como resuelto. Los reportes también aparecen como pines en el mapa.
- Pestaña "Ayuda": directorio de refugios, protectoras y grupos asociados, y el aviso de llamar al 911 si hay una persona en riesgo.

**Turnos y pedidos.** Desde la ficha de un comercio con módulos activos: "Ver catálogo" (cantidades, total, hacer pedido) y "Reservar turno" (día, horario libre, servicio y mascota). Un cuadro "Mis turnos y pedidos" en Mascotas muestra el estado en vivo y los recordatorios de la veterinaria.

**Pro (pago único, idea de unos 40 pesos).** Foto de la mascota, sin publicidad, color (5 opciones) y tamaño de letra (14, 16 o 18 px). Los usuarios sin Pro ven una barra de anuncio pequeña; la ✕ lleva a Ajustes.

### 4.2 Comercio

**Tipos de negocio y módulos disponibles:**

| Tipo | Catálogo y pedidos | Agenda de turnos | Socios y recordatorios |
|---|---|---|---|
| Veterinaria | Sí | Sí | Sí |
| Pet shop | Sí | No | No |
| Peluquería | No | Sí | No |
| Farmacia veterinaria | Sí | No | No |
| Tienda online | Sí | No | No |
| Servicio a domicilio | No | Sí | No |

**Planes (precios de ejemplo, pago simulado en el prototipo):**
- **Básico, gratis:** ficha en el mapa (nombre, dirección, horario, animales que atiende).
- **Destacado, unos $600 por mes (neto UYU 500):** pin naranja, promoción, web, Instagram, Facebook y WhatsApp.
- **Plus, unos $1.200 por mes (ejemplo):** todo lo anterior más catálogo, agenda y socios.

**Regla de activación.** Un módulo está activo solo si el plan es Plus, el tipo de negocio lo admite y el comercio lo prendió en su Panel. Si el tipo no lo admite, aparece "No aplica".

**Alta del negocio.** Se elige el tipo, el nombre y la ubicación: marcar en el mapa o reclamar un lugar sin reclamar del mismo rubro. Los negocios sin local piden zona de envío o cobertura. En la versión real, el reclamo debe verificarse (manual al principio, luego con código por teléfono).

**Agenda.** Días de atención, hora de inicio y fin, duración (15, 30 o 60 minutos) y servicios (texto separado por comas). Los horarios libres excluyen turnos ya tomados y horas pasadas. Los turnos llegan como pendientes y el comercio los confirma o rechaza.

**Catálogo y pedidos.** Productos con nombre, precio y disponibilidad (disponible o agotado). El pedido pasa por Nuevo, Preparando, Listo y Entregado. El cliente paga directo al comercio.

**Socios.** Mascotas que eligieron a esa veterinaria como suya. Botón "Recordar" para avisar del control; el dueño lo ve en su ficha.

**Panel.** Plan, módulos, resumen (turnos pendientes, pedidos nuevos, socios, productos) y puntos de aviso en las pestañas Agenda y Pedidos.

---

## 5. Pantallas del prototipo (guía de diseño)

- **Inicio:** pantalla con solo el logo (🐾 sobre un cuadrado verde redondeado) durante 1,5 segundos; luego "¿Cómo querés entrar?": dueño o comercio.
- **Dueño:** barra inferior con Explorar, Noticias, SOS (en rojo), Mascotas y Ajustes. Arriba, una fila con las mascotas y "＋".
- **Comercio:** barra inferior con Panel, Agenda, Catálogo, Pedidos y Negocio. Cabecera con nombre, tipo y plan, y botón para volver al modo dueño.
- **Reglas de interfaz:** pantallas principales sin scroll de página; el mapa ocupa el espacio disponible; la ficha de un lugar sube desde abajo; filtros como grillas horizontales agrupadas (no burbujas sueltas); colores con modo claro y oscuro automático; verde `#1f8a5b` como color principal, naranja para destacados, rojo para SOS.
- **Textos:** español rioplatense (voseo).

---

## 6. Modelo de datos propuesto (Supabase / Postgres)

| Tabla | Campos clave |
|---|---|
| `profiles` | id (auth), email, display_name, phone (privado), role, pro (bool), prefs (color, tamaño de letra) |
| `pets` | id, owner_id, name, type, breed, birth, last_checkup, next_checkup, last_vaccine, vaccine_date, vet_business_id, notes, photo_path |
| `businesses` | id, owner_id, kind (`local`, `online`, `domicilio`), business_type, category, name, address, lat, lng, hours (estructurado por día), zone, pet_types[], plan, promo, web, instagram, facebook, whatsapp_private, status (`pendiente`, `activo`) |
| `place_marks` | id, user_id, category, lat, lng, google_link, business_id (cuando se reclama) |
| `business_modules` | business_id, module (`catalogo`, `agenda`, `socios`), enabled |
| `catalog_items` | id, business_id, name, price, available |
| `orders` / `order_items` | cliente, negocio, estado (nuevo, preparando, listo, entregado), total, items |
| `agenda_config` | business_id, days[], from_time, to_time, slot_minutes, services[] |
| `bookings` | id, business_id, user_id, pet_id, date, time, service, status (pendiente, confirmado, rechazado) |
| `user_places` | user_id, business_id, favorite, visited, rating, note |
| `reports` | id, kind (`perdida`, `encontrada`), user_id, pet_type, name, description, zone, lat, lng, photo_path, contact_phone (privado), status |
| `news` | id, title, source, date, body, pet_types[], sponsored |
| `push_tokens` | user_id, token |
| `subscriptions` | business_id o user_id, plan, status, periodo, medio de pago |

Notas de seguridad: activar RLS en todas las tablas; los teléfonos y WhatsApp nunca se devuelven al cliente (contacto a través de una Edge Function que redirige a WhatsApp); los archivos de fotos con tamaño máximo y reducción en el cliente.

---

## 7. Stack recomendado

- **Frontend:** React + Vite + TypeScript, instalable como PWA. Mapa con `@googlemaps/js-api-loader`.
- **Backend:** Supabase (Auth con Google, Postgres con RLS, Storage, Edge Functions).
- **Hosting:** Cloudflare Pages o Vercel (verificar condiciones de uso comercial del plan gratis).
- **Android:** más adelante, con Capacitor. Si se quiere el mapa gratis, hay que usar el mapa nativo (el SDK de Android no tiene costo ni límite), no la web envuelta.
- **Pruebas:** pruebas de recorrido en un navegador simulado (jsdom o Playwright) para los flujos principales.

**Configuración de Google Maps (hacerlo al arrancar la versión 0.1):**
1. Crear proyecto en Google Cloud y activar solo "Maps JavaScript API". Requiere cuenta de facturación con tarjeta aunque no se pase el cupo.
2. Restringir la clave por dominio (HTTP referrer).
3. Fijar un tope diario de cuota de unas 300 cargas por día (cerca de 9.000 por mes) y, al llegar, mostrar la lista en lugar del mapa.
4. Activar alerta de presupuesto.
5. Crear el mapa **una sola vez por sesión** y reutilizarlo; cargarlo solo al entrar a Explorar.
6. No usar Places API (cuesta US$32 por 1.000 consultas pasadas las 5.000 gratis) ni geocodificación: la ubicación se marca tocando el mapa. "Cómo llegar" es un enlace a Google Maps.
7. Armar el mapa detrás de una capa propia para poder cambiar de proveedor (por ejemplo MapLibre).
8. Cargar los comercios con datos propios; revisar los términos de Google antes de guardar datos suyos.

---

## 8. Costos, equilibrio y escenarios

**Supuestos:** plan Destacado a $600 por mes, neto $500 tras impuestos y comisión (confirmar con contador); Pro a $40 único, neto ~$34 si la tienda se queda el 15%; 8 aperturas de mapa por usuario por mes; 20 horas semanales de trabajo; contador y formalización $3.000 por mes desde el primer cobro (supuesto). El tiempo de Rodrigo no está costeado.

### 8.1 Costos separados (versión mínima)

| Concepto | Costo | Cuándo |
|---|---|---|
| Dominio sosmascotas.uy | Entre €43 y más de €220 por año según el registrador (unos $2.000 a $10.400). Comparar en nic.org.uy; preguntar por .com.uy | Paso 0.1 |
| Hosting web | $0 en planes gratis | Paso 0.1 |
| Supabase | $0 en plan gratis (se pausa tras una semana sin actividad); Pro US$25 por mes | Pro con usuarios reales |
| Login con Google | $0 | Paso 0.2 |
| Google Maps web | 10.000 cargas gratis por mes y luego US$7 por 1.000 | Paso 0.1 |
| Notificaciones push web | $0 | Paso 0.5 |
| SMS para verificar teléfonos | Costo por mensaje; evitar | Evitar |
| Google Play | US$25 una vez (cuentas personales nuevas: prueba cerrada con 12 testers durante 14 días antes de publicar) | Paso 0.5 |
| Apple Developer | US$99 por año | Cuando haya público en iPhone |
| Claude Pro | US$20 por mes (opcional, herramienta de trabajo; la app no usa Claude) | Opcional |
| Imágenes generadas | $0 para que la app funcione (emojis, íconos, fotos de usuarios) | Fuera del mínimo |
| Asesoría legal (términos y datos personales) | US$150 a 400 (estimado) | Antes del paso 0.3 |
| Publicidad | US$50 a 100 por mes en el piloto | Después del paso 0.4 |
| Comisión de cobro | Porcentaje por cobro según el medio (verificar). Si Pro se vende dentro de la app, la tienda se queda cerca del 15% | Desde el primer cobro |

### 8.2 Regla práctica de Google Maps
El cupo gratis alcanza para unos 1.200 usuarios activos por mes. Cada 1.000 usuarios activos adicionales suman unos US$56 por mes (cerca de $2.240), lo mismo que 4 o 5 comercios pagando. Con 20.000 cargas mensuales el costo ronda US$70 y con 100.000, US$630.

### 8.3 Inversión por paso (en pesos uruguayos, aproximada)

| Paso | Gasto mensual al terminar | Acumulado | Comercios (a $500) que lo cubren |
|---|---|---|---|
| 0.1 Mapa | 170 a 870 | 2.000 a 10.400 | 1 a 2 |
| 0.2 Cuentas y mascotas | 170 a 870 | 2.000 a 10.400 | 1 a 2 |
| 0.3 SOS | 170 a 1.870 | hasta 11.400 | 1 a 4 |
| 0.4 Comercios | 4.170 a 6.550 | 3.000 a 17.100 | 9 a 14 con contador; 3 a 8 sin contador |
| 0.5 Pro y app | 4.170 a 13.270 (según mapa nativo o web) | 4.000 a 18.100 | 9 a 27 |

### 8.4 Peor caso (6 meses sin visibilidad)
- **Austero** (solo dominio, todo gratis, sin anuncios): $2.000 a $10.400.
- **Conservador** (todos los pasos, Supabase Pro, asesoría legal, anuncios y Google Play): $27.000 a $45.400 (unos US$675 a 1.135).
- Fijar un tope antes de empezar: si a los 3 meses del lanzamiento no se cumplen las metas, pasar a modo austero.

### 8.5 Punto de equilibrio
Comercios necesarios = gasto mensual dividido el ingreso neto por comercio ($500).

| Gasto mensual | Comercios pagando |
|---|---|
| $1.800 (solo infraestructura) | 4 |
| $4.170 a $6.550 (paso 0.4) | 9 a 14 |
| $10.000 (cifra mencionada por el padre de Rodrigo) | 20 |
| $62.000 (vivir de esto, unos $50.000 netos) | 124 |

Los usuarios son la audiencia, no quienes pagan. Las marcas piden audiencia: recién tiene sentido hablarles con unos miles de usuarios activos en una zona. Los pagos únicos de Pro ayudan poco (con 2.000 usuarios y 3% de conversión, unas 60 compras, cerca de $2.000 una vez).

---

## 9. Plan por versiones (con unas 20 horas semanales)

| Versión | Qué incluye | Plazo | Meta para avanzar |
|---|---|---|---|
| **0.1 Mapa** | Mapa público de solo lectura con Google Maps, filtros por mascota y rubro, ficha del lugar con botón de contacto, 30 comercios cargados a mano en la zona piloto. Sin cuentas, fotos ni pagos | Semanas 1 a 3 | 100 visitas y 5 comercios que quieran aparecer |
| **0.2 Cuentas y mascotas** | Login con Google, mascotas (varias), ficha, favoritos, marcar lugares sin nombre | Semanas 4 a 6 | 100 usuarios registrados |
| **0.3 SOS** | Perdidas y encontradas con WhatsApp oculto, pines en el mapa, directorio de ayuda | Semanas 7 a 9 | Primeros reportes reales y resueltos |
| **0.4 Comercios** | Reclamar la ficha, planes Destacado, cobro manual, verificación manual | Semanas 10 a 12 | 3 a 5 comercios pagando |
| **0.5 Pro y app** | Foto de la mascota, tema, noticias, recordatorios, Google Play | Mes 4 en adelante | Conversión a Pro y costo real de Maps |
| **0.6 Catálogo** | Catálogo y pedidos por WhatsApp o dentro de la app, sin pago en la app | Después del 0.4 | Lo piden los comercios |
| **0.7 Turnos** | Agenda de turnos con confirmación | Después del 0.6 | Lo piden los comercios |

**Qué medir en cada paso:**
- 0.1: visitas, aperturas del mapa por visita, toques en "contactar", comercios que aceptan aparecer. Si el mapa se abre pero nadie toca "contactar", cambiar la ficha antes de seguir.
- 0.2: registros, usuarios que vuelven la semana siguiente, mascotas cargadas.
- 0.3: reportes publicados y cuántos terminan resueltos.
- 0.4: comercios que reclaman y cuántos pagan; cargas de mapa por usuario real.
- 0.5: conversión a Pro; costo real de Maps frente al estimado.

**Regla para avanzar:** se pasa al siguiente paso cuando se cumple la meta y el gasto mensual está cubierto por ingresos o por presupuesto personal. Si no, se repite el paso con ajustes. Señal de alerta: si a los 3 meses del lanzamiento hay menos de 100 usuarios o menos de 3 comercios reclamados, no sumar publicidad; cambiar el enfoque (más trabajo presencial, otra zona u otro rubro).

**Validación previa (semanas 1 y 2, antes de programar):** mostrar la demo a 10 dueños y 5 a 8 comercios; preguntar cuánto pagarían por Destacado, catálogo y turnos y qué les falta; elegir la zona piloto; listar 30 comercios; verificar que el nombre esté libre. Meta: al menos 5 comercios que digan que pagarían el plan.

---

## 10. Riesgos y pendientes por confirmar

- **Retención:** que el dueño vuelva a abrir la app. SOS, recordatorios y favoritos ayudan.
- **Que los comercios paguen:** validarlo en la fase previa y en el paso 0.4.
- **Competencia:** catálogos de WhatsApp Business, Mercado Libre y sistemas de agenda de veterinarias; la ventaja está en juntar mapa, SOS, recordatorios y turnos.
- **Moderación y verificación:** reportes falsos, spam y comercios que reclaman fichas ajenas. Hace falta botón de denuncia y verificación del reclamo.
- **Datos personales:** los reportes manejan contactos y ubicaciones. Revisar con un profesional la normativa uruguaya de protección de datos antes del paso 0.3 (esto no es asesoramiento legal).
- **Precio real del dominio .uy:** los valores encontrados varían mucho entre registradores.
- **Contador, formalización y comisiones de cobro:** son supuestos hasta confirmarlos.
- **Políticas de las tiendas de apps:** reglas para cobrar planes a comercios fuera de la app, y para ofrecer Google como login en iPhone (Apple puede exigir una opción equivalente en privacidad).
- **Cifras que cambian:** Supabase, Google Maps, las tiendas y el tipo de cambio. Revisar precios vigentes antes de contratar.

---

## 11. El prototipo `sos-mascota.html` (cómo está hecho)

- Un solo archivo con HTML, CSS y dos bloques de JavaScript sin librerías. El segundo bloque extiende al primero (roles, módulos de comercio, catálogo, agenda).
- **Estado:** objeto global `S`. Datos de ejemplo en `P` (lugares), `O` (negocios sin local), `N` (noticias), `R` (reportes SOS) y `AY` (ayuda).
- **Mapa:** esquemático, dibujado en SVG de 100 por 100. Distancia simulada: 1 unidad ≈ 40 metros desde el centro. En la app real se usan coordenadas y GPS reales.
- **Render:** funciones que devuelven texto HTML, y un solo manejador de clics por `data-a` (acción) y `data-v` (valor).
- **Guardado local** (`localStorage`): `sosm2` (mascotas), `sosm_rv` (favoritos y calificaciones), `sosm_cfg` (Pro, color, letra), `sosm_r` (reportes propios). Los datos de comercios, turnos y pedidos viven solo mientras la página está abierta.
- **No implementado:** backend, cuentas, pagos reales, notificaciones reales, geolocalización, verificación de comercios, moderación, "abierto ahora" que considere los días, y persistencia de negocios.
- **Qué conviene hacer con él:** usarlo para mostrar a comercios y amigos y como referencia de pantallas. La app real se reconstruye por componentes y con base de datos.

---

## 12. Prompts listos para Claude Code

**Prompt de arranque (pegar primero):**
> Leé `CLAUDE.md` y abrí `reference/sos-mascota.html` para entender el producto. No implementes nada todavía. Proponeme el stack final, la estructura de carpetas y los pasos de configuración de Supabase y Google Cloud, y esperá mi confirmación. Hablame en español rioplatense.

**Versión 0.1 (mapa):**
> Implementá la versión 0.1 de `CLAUDE.md`: web instalable (PWA) en React + Vite + TypeScript con mapa de Google Maps de solo lectura. Incluí filtros por tipo de mascota y rubro, ficha del lugar con horario, dirección y botón "contactar" por WhatsApp, y "cómo llegar" como enlace a Google Maps. Los comercios salen de una tabla de Supabase que cargo a mano. Respetá las reglas de Google Maps de la sección 7 (un solo mapa por sesión, carga diferida, tope de cuota). Sin cuentas ni pagos. Dejame los pasos manuales para crear el proyecto de Supabase y la clave de Google. Agregá pruebas de recorrido para el mapa y los filtros.

**Versión 0.2 (cuentas y mascotas):**
> Sumá login con Google y correo con enlace mágico (Supabase Auth), mascotas múltiples con su ficha (sección 4.1), favoritos, "fui", calificación y nota, y marcar lugares sin nombre. No pidas teléfono al registrarse. Activá RLS en todas las tablas nuevas y mostrame las políticas.

**Versión 0.3 (SOS):**
> Implementá la pestaña SOS (sección 4.1): reportes de perdidas y encontradas con foto reducida en el cliente, pines en el mapa y directorio de ayuda. El WhatsApp se guarda en el servidor y el contacto se resuelve con una Edge Function; nunca devuelvas el número completo al cliente, mostralo como `*** *** 123`. Agregá botón de denuncia de contenido.

**Versión 0.4 (comercios):**
> Implementá el modo comercio: alta del negocio por tipo, reclamo de lugares sin reclamar con verificación manual (una bandera que apruebo yo), planes Básico y Destacado con cobro manual, promoción y contactos. Los módulos de Plus quedan como "próximamente".

**Versiones 0.5 a 0.7:**
> Sumá Pro (foto de la mascota, sin anuncios, color y tamaño de letra), noticias, recordatorios y el empaquetado para Google Play. Después, catálogo con pedidos (sin pago en la app), y agenda de turnos con confirmación. Las reglas están en las secciones 4.2 y 6.

**Buenas prácticas para pedirle a Claude Code:** que haga un commit por funcionalidad, que corra las pruebas antes de cada commit, que nunca suba claves ni archivos `.env`, y que antes de cada versión te muestre el plan en pocas líneas para aprobarlo.

---

## 13. Qué queda fuera de este archivo

El documento de costos con sus versiones 1 y 2 y la presentación visual de los cinco pasos están en la cuenta anterior. Todo su contenido está resumido acá. Si querés conservarlos como archivos, se pueden exportar desde esa cuenta antes de dejarla: el documento a Word, PDF o Markdown, y la presentación a PowerPoint o PDF.
