# 24 · Plan de mejoras de Huellitas

> Armado el 01/11/2026 con los lineamientos que trajo el dueño («HUELLITAS – Plan de mejoras y evolución de la aplicación»). Para cada punto dice **qué ya existe** en la app, **qué falta** y **qué propongo**. Los pasos que se aprueben pasan a [PROGRESO](PROGRESO.md); las decisiones, a [12](12-decisiones.md).
> Principio que manda sobre todo: **simple para quien entra una vez y útil para quien vuelve cada semana.**

## Resumen

| # | Lineamiento | Prioridad | Qué hay hoy | Qué falta |
|---|---|---|---|---|
| 1 | Muro como pantalla principal | Alta | Noticias es la 1.ª pestaña, la ve cualquiera, con Comunidad, eventos y reacciones (D83, D86, D87, D94) | **La app abre en el Mapa**, no en el muro. Faltan promociones, publicidad, adopciones y campañas mezcladas en el mismo muro |
| 2 | Historial de vida de cada mascota | Alta | Libreta: vacunas, desparasitaciones, controles, alergias, medicación (D66); historial de salud en PDF (Pro); al adoptar, la mascota pasa con su libreta | **Acontecimientos con fecha** (operaciones, accidentes, enfermedades, diagnósticos) con fotos o documentos, en una línea de tiempo; compartirlo y pasarlo al cambiar de dueño (no solo por adopción) |
| 3 | Ayuda contextual y textos breves | Alta | Algunas pantallas tienen explicaciones largas fijas | **Botón de ayuda igual en todas las pantallas** y textos fijos más cortos |
| 4 | Comunidad y consultas generales | Alta | Grupos por especie, raza y tema con preguntas, consejos, experiencias y comentarios (D116) | Un lugar de **preguntas generales** (viajes, documentación, alimentación, adopción) con **categorías, búsqueda** y, más adelante, **respuestas verificadas** por profesionales |
| 5 | Menú principal y navegación | Alta | Barra de abajo Noticias · SOS · Mapa · Mascotas · Ayuda (D94) y menú ☰ (D88) | Ordenar el menú ☰ con **todo** a la vista, con íconos y nombres simples; revisar caminos largos |
| 6 | Gamificación | Media | Propuestas en [17](17-propuestas-perfil-gamificacion.md); «Tus huellas» en la [guía visual](23-guia-visual.md) | Elegir y hacer una versión simple |
| 7 | Publicidad y monetización | Media | Planes en [22](22-planes-y-precios.md); «Promocionado» previsto en Noticias (Fase 2); estadísticas de comercios (D101) | **Avisos de comercios en el muro**, con vistas y toques medidos |
| 8 | Rastreo de paseadores | Futura | Pedidos de paseos y estadías (D115) | Todo |
| 9 | Expansión geográfica | Largo plazo | Zonas en la base; el mapa carga por zona visible | Contenido y comercios por ciudad, info de viajes |
| 10 | Diseño y experiencia | Transversal | [Guía visual](23-guia-visual.md) aplicada (D126) | Revisar cada pantalla con estos principios |

## Puntos a decidir antes de arrancar

1. ✅ **El botón de ayuda va arriba a la derecha** (decidido por el dueño el 01/11/2026), en el lugar del ícono de Ajustes de las pestañas, siempre con el mismo ícono (signo de pregunta en un círculo). El menú ☰ queda donde está, arriba a la izquierda, y Ajustes se sigue abriendo desde ahí.
2. ✅ (D127) **La pestaña «Ayuda» de la barra de abajo** hoy es para urgencias (911, guardias, refugios, denuncias). Con un botón de ayuda en cada pantalla, dos cosas llamadas «Ayuda» confunden. Propongo renombrar la pestaña a **«Urgencias»**.
3. ✅ (D127) **La pestaña «Noticias» pasa a ser «Inicio»** y la app abre ahí. El Mapa sigue en el medio, a un toque.
4. ✅ (aceptado por el dueño el 01/11/2026) **Puntos por mirar publicidad: no.** Si la gente toca un aviso para sumar puntos, las vistas y los toques dejan de decir quién está interesado de verdad, y eso es lo que paga el comercio. Además, las redes de anuncios (por ejemplo AdMob, si algún día se usa) prohíben premiar los toques. Se mide qué se vio y qué se tocó (sin saber quién), y los puntos («Tus huellas») quedan para acciones de cuidado y de comunidad: completar la ficha, la libreta al día, compartir un perdido, responder una pregunta.
5. **Publicidad y suscripciones.** El lineamiento pide no depender de suscripciones al principio. Encaja con los planes de [22](22-planes-y-precios.md): lo de seguridad y salud sigue gratis, y los ingresos arrancan por los comercios (Destacado y Plus, que incluyen aparecer en el muro). Pro y Familia quedan como extra.
6. **Rastreo de paseadores:** el paseador tiene que aceptarlo en cada paseo, la ubicación se comparte solo mientras dura, el recorrido se borra a los 30 días y nunca se ve la casa del dueño. Es de la Fase 4.

## Etapas propuestas

Cada paso es chico y se prueba antes de pasar al siguiente.

### Etapa 1 · Experiencia y estructura

| Paso | Qué | Resultado que se puede comprobar |
|---|---|---|
| 1.1 | **El muro como inicio:** la app abre en «Inicio» (hoy Noticias); la pestaña se renombra; el muro mezcla noticias, eventos de la zona, jornadas de adopción y campañas, con filtros simples arriba (Todo · Eventos · Adopción · Promos) | Al abrir la app se ve el muro con contenido |
| 1.2 | **Menú ☰ ordenado:** todas las funciones en grupos con ícono y nombre corto (Mis mascotas · Mapa y lugares · Comunidad · Adopción · Eventos · Turnos y pedidos · Mi negocio · Ajustes) | Cualquier función está a 2 toques como máximo |
| 1.3 | **Botón de ayuda** arriba a la derecha de cada pantalla (en las pestañas, en lugar del ícono de Ajustes), con una hoja corta: para qué sirve, qué significa cada opción, qué pasa al confirmar. Textos en `app_es.arb` | Mismo botón, mismo lugar, en todas las pantallas principales |
| 1.4 | **Textos más cortos:** las explicaciones largas fijas pasan a la ayuda; en pantalla queda una línea | Revisión pantalla por pantalla |
| 1.5 | **Pestaña Urgencias** (hoy «Ayuda») y revisión de caminos largos | Prueba con 3 personas: llegar a 5 funciones sin ayuda |

### Etapa 2 · Funciones principales

| Paso | Qué |
|---|---|
| 2.1 | **Historial de vida:** acontecimientos con fecha y tipo (operación, accidente, enfermedad, tratamiento, diagnóstico, alergia, otro), nota y hasta 4 fotos o documentos; línea de tiempo en la ficha junto con la libreta; entra en el PDF |
| 2.2 | **Pasar o compartir el historial:** al transferir la mascota a otra persona (no solo por adopción) va con todo su historial; compartir de solo lectura con una veterinaria o un cuidador por un enlace que vence |
| 2.3 | **Consultas:** sección «Preguntas» en Comunidad con categorías (Viajes · Salud · Alimentación · Adopción · Trámites · Otros), buscador y respuestas; se apoya en los grupos (D116) |
| 2.4 | **Respuestas verificadas:** una veterinaria verificada puede marcar su respuesta como «Respuesta de profesional» |

### Etapa 3 · Recurrencia y monetización

| Paso | Qué |
|---|---|
| 3.1 | **Promociones en el muro:** los comercios Destacado y Plus publican su promo, que aparece marcada «Promocionado» y por zona; se miden vistas y toques en las estadísticas del comercio |
| 3.2 | **Espacios de publicidad:** una tarjeta promocionada cada tantas publicaciones; nunca en las pantallas de SOS ni en la página del QR |
| 3.3 | **Gamificación simple:** «Tus huellas» (contador de ayudas e insignias por perfil completo, libreta al día, avisos compartidos, respuestas útiles), sin rankings públicos de personas |

### Etapa 4 · Servicios avanzados (Fase 4)

| Paso | Qué |
|---|---|
| 4.1 | Diseño y privacidad del seguimiento de paseos |
| 4.2 | Seguimiento en vivo durante el paseo, inicio y fin con aviso, duración y recorrido |

### Etapa 5 · Expansión

| Paso | Qué |
|---|---|
| 5.1 | Ciudades como zonas con su propio contenido (eventos, promos, comercios) |
| 5.2 | Información de viajes y traslados (nacional e internacional), revisada por profesionales |
| 5.3 | Preparar la app para otro país (moneda, textos, teléfonos de emergencia) |
