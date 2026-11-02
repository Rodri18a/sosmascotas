# 03 · Funcionalidades de la app

Cada función indica la **fase** en la que se construye (ver `11-roadmap.md`) y si es **gratis** o de un **plan pago** (ver `06-reglas-negocio.md`).

## Navegación (modo dueño)

Barra inferior: **Explorar** (mapa) · **Noticias** · **SOS** (en rojo) · **Mascotas** · **Ajustes**. Arriba, una fila con las mascotas del usuario, la opción "Todas" y "＋".

**Desde el 01/11/2026 (D127):** la barra es **Inicio · SOS · (Mapa) · Mascotas · Urgencias** y la app abre en Inicio (el muro, antes «Noticias»); «Ayuda» pasó a llamarse «Urgencias».

**Hecho hasta ahora (D88, D94):** la barra inferior es **Noticias · SOS · (Mapa) · Mascotas · Ayuda**. El Mapa va en el medio, como un botón redondo que sobresale de la barra (que se curva para dejarle lugar), y es donde abre la app. La barra reserva el lugar del botón, así que nunca tapa el contenido, y las hojas que se abren desde abajo quedan por encima de la barra. Cada pestaña tiene un **menú ☰** con:
- **Mis datos** (nombre, correo; abre Mi perfil o Ajustes) o "Ingresá o creá tu cuenta" para un visitante.
- **Ver todo para:** "Todas" o una de mis mascotas. La elegida filtra Noticias, Comunidad y Adopción por su especie (los chips de cada pantalla la pueden cambiar) y suma accesos a su ficha, su chapita QR y "Reportar que se perdió". Se recuerda en el dispositivo, por cuenta.
- **Secciones:** Adopción, Mensajes, Avisos, Mi hogar, Mis pedidos, Mi negocio y Ajustes, cada una según su funcionalidad gradual y si hace falta cuenta.
Ayuda queda para urgencias (911, guardias, refugios y denuncias). Los **próximos eventos** de la zona están arriba de Noticias → Comunidad (D94).

Pantalla inicial: el logo de la marca (D122) sobre el fondo claro `#EAF4FA` (oscuro `#0E1E26` en modo oscuro) mientras carga.

---

## 1. Cuenta — Fase 0

- Login con **Google** y **correo con enlace mágico**. **Apple** se suma al publicar en iPhone (Fase 1), porque Apple lo exige si se ofrece Google.
- **No se pide teléfono al registrarse.** Solo se pide al publicar un SOS, al configurar el contacto del QR o al registrar un negocio.
- Consentimiento de términos y privacidad al registrarse.
- **Descargar mis datos** y **borrar mi cuenta** (Ley 18.331).
- Ajustes: idioma (español por ahora), notificaciones, radio de avisos SOS, y tema de color (Cielo por defecto; Faro, Vecinos y Pop con Pro) y tamaño de letra (Pro). El modo oscuro y el tamaño de letra del sistema son gratis.

## 2. Mascotas — Fase 0 (básico) / Fase 1 (libreta)

- Varias mascotas por usuario. El plan Gratis permite **hasta 2** y Pro o Familia, ilimitadas (D118: vuelve a 2; D111 lo había subido a 5). ✅ 2.1 (D111), detrás de `planes_usuario`: la base corta la 3.ª; quien ya tenga más las conserva. Ajustes → **Mi plan** muestra qué incluye cada plan y permite pedir Pro o Familia.
- Ficha: nombre, especie, raza, sexo, color, señas particulares, fecha de nacimiento (se muestra la edad), **foto (gratis)**, microchip (opcional), castrado/a, notas.
- **Microchip (Fase 0):** número de 15 dígitos, validado (ISO 11784).
- **RENAC (Fase 1):** estado declarado (registrado / no registrado / no sé), guía "Cómo registrar a tu mascota", recordatorio si no está registrada, y botón **"Verificar en el RENAC"**, que abre la consulta pública oficial. Ver `investigacion/renac.md`.
- **Libreta sanitaria (Fase 1):** vacunas, desparasitaciones, controles, alergias, medicación actual, veterinaria asociada.
- **Historial de vida (D131, plan de mejoras 2.1):** operaciones, accidentes, enfermedades, tratamientos y diagnósticos con fecha, nota y hasta 4 fotos o PDF; línea de tiempo en la ficha, debajo de la libreta, y sección propia en el historial en PDF. Lo ven y lo editan el dueño y su hogar. Gratis (regla de oro).
- **Pasar una mascota a otra persona (D132, plan de mejoras 2.2):** el dueño genera en la ficha un código que vence en 7 días; quien lo recibe toca «Tengo un código» en Mis mascotas y la mascota pasa a su cuenta con la libreta, el historial de vida, los recordatorios y la chapita QR. No se puede con un SOS abierto. Gratis.
- **Compartir el historial (D133, plan de mejoras 2.2):** el dueño crea en la ficha un enlace de solo lectura que vence en 1, 7 o 30 días (lo copia y lo manda) y ve los vigentes con cuántas veces se abrieron, para cortarlos. Abre `/h/<token>` en la web pública: datos de la mascota, libreta e historial de vida, sin el teléfono ni la dirección del dueño. Los adjuntos se ven con enlaces firmados de 1 hora que pide la página a la Edge Function `historial-adjuntos` (fotos en miniatura, PDF como enlace). Gratis.
- **Preguntas (D134, plan de mejoras 2.3):** sección «Preguntas» (menú ☰ → Comunidad y tarjeta en Inicio → Comunidad) con temas (Viajes, Salud, Alimentación, Adopción, Trámites, Otros), buscador sin tildes y la lista de todos los grupos, con respuestas y «Resuelta». Se pregunta eligiendo el tema y el grupo (por defecto «Preguntas generales»); se responde uniéndose al grupo sin salir; quien preguntó marca «Me sirvió». Hereda las reglas de la comunidad (primer nombre, sin venta ni cruza, reportes).
- **Respuestas de profesional (D135, plan de mejoras 2.4):** quien atiende una veterinaria verificada (titular o equipo) firma su respuesta a una pregunta: se ve «Respuesta de profesional · <veterinaria>» y la lista marca «Responde una veterinaria». Si deja de estar verificada, la firma no se muestra. Gratis.
- **Promociones en el muro (D136, plan de mejoras 3.1):** los comercios Destacado (1 vigente) y Plus (2) publican desde el panel → Negocio una promoción con título, detalle, una foto de su ficha y duración (7, 15 o 30 días). En Inicio → Noticias se intercala una cada 4 noticias (hasta 3), marcada «Promocionado · <comercio>», de los comercios a 15 km o menos, rotando cada hora; tocarla abre su ficha del mapa. Se puede reportar. Nunca en SOS, Urgencias ni el QR. Las vistas y los toques aparecen en las Estadísticas del comercio.
- **Espacios de publicidad (D137, plan de mejoras 3.2):** las promociones también salen en Inicio → Comunidad (una cada 6 novedades) y en Preguntas (una cada 8), hasta 3 por pantalla y sin repetirse. Nunca en SOS, Urgencias, el QR, el chat ni las fichas de las mascotas. Los banners del carrusel cuentan sus vistas (`banner_view`, una vez por sesión).
- **Tus huellas (D138, plan de mejoras 3.3):** en Mi perfil, cuántas veces ayudaste (avisos a dueños, respuestas en la comunidad y avisos de perdidas compartidos) y seis insignias que se ganan solas: Perfil completo, Libreta al día, Chapita activa, Difusor, Buena respuesta y Reencuentro. Las que faltan dicen cómo ganarlas. Solo las ve la propia persona: no hay rankings ni comparación, y nunca se gana por mirar publicidad.
- Semáforo de próximos controles: rojo a 7 días o menos, amarillo hasta 30 días, verde si falta más, y "vencido" si pasó la fecha.

## 3. Chapita QR — Fase 0

- Cada mascota tiene un **código QR único** (enlace a `sosmascotas.uy/m/<código>`).
- El dueño puede **descargar o imprimir** el QR gratis.
- **Chapitas físicas pre-codificadas:** se fabrican por **lotes** con códigos únicos sin mascota asignada. El dueño **escanea la chapita y la vincula** a su mascota ("Activar chapita"). Si la pierde, la desvincula y activa otra. Así se pueden repartir en veterinarias, ferias de adopción o eventos sin saber de quién va a ser cada una. ✅ 1.8b.2 (D95): se escanea con la cámara del celular → página "Activar con la app" → `/activar/<código>` (elige cuál de sus mascotas), o se escribe el código en **Chapita QR → Chapitas físicas**; ahí también se ven las vinculadas y se **desvinculan** (quedan inactivas para siempre). Solo el dueño activa y desvincula; el hogar las ve.
- **Formas de conseguir la chapita física:**
  - **Pedido con retiro en la veterinaria asociada** (Fase 1): el dueño la pide en la app y la retira en su veterinaria. Ideal para las personalizadas (nombre, colores). ✅ 1.8b.4 (D98): Chapita QR → «Pedir una chapita» (su veterinaria primero, texto grabado), estado del pedido en la misma pantalla; la veterinaria la recibe y entrega desde el modo comercio → «Chapitas: punto de retiro». Por ahora solo el texto grabado: colores y material esperan el prototipo (P15).
  - **Stock en la veterinaria** (Fase 1–2): la veterinaria tiene chapitas en blanco y el dueño la activa en el local. SOS Mascota **no ofrece ni coloca microchips**: eso lo hace la veterinaria por su cuenta. La app solo guarda el número que carga el dueño.
  - **Patrocinada** (Fase 2): una empresa financia un lote. Lleva su logo en el reverso y un "Chapita cortesía de X" discreto en la página del QR.
  - **Venta directa** (Fase 2): diseños con colores, nombre grabado o formas, con descuento para Pro y Familia.
- **Producción:** al inicio, con un amigo que tiene una empresa de impresión 3D. Requisitos: material resistente (PETG o TPU), QR de alto contraste (dos colores, grabado láser o etiqueta resinada, nunca en relieve del mismo color), unos 3 cm como mínimo y corrección de errores alta.
- **Página pública del QR** (no requiere app ni cuenta):
  - Foto y nombre de la mascota.
  - Cartel "**Estoy perdido 🆘**" si la mascota tiene un SOS activo.
  - Datos de salud que el dueño elija mostrar ("toma medicación", "es alérgico a…").
  - Botón **"Avisar a mi familia"** (**contacto inverso**, ver la sección 4): quien escanea deja un mensaje y su contacto, y **el dueño decide si llama**. El número del dueño nunca se muestra.
  - Opción de **compartir ubicación** con el dueño.
- Cada escaneo **notifica al dueño**, con la ubicación aproximada si quien escanea la compartió.

## 4. SOS: perdidos y encontrados — Fase 0

- **Reportar:** perdida o encontrada; mascota propia (precarga los datos) u otra; especie, raza, nombre, color, señas, descripción, **al menos una foto**, fecha, **ubicación tocando el mapa** (se publica una zona aproximada) y contacto. **Sin recompensa** (D119): la app es una red de apoyo y una recompensa a la vista atrae estafas. En los reportes de encontradas se aconseja guardarse una seña sin publicar para comprobar quién es la familia.
- **Lista** ordenada por cercanía y **pines en el mapa** (capa activable).
- **Contacto inverso (Fase 0):** el número del autor **nunca se muestra**, ni siquiera a quien quiere contactarlo.
  1. Quien vio o encontró al animal toca **"Avisar al dueño"** (en el reporte o en la página del QR). **No necesita cuenta.**
  2. Completa: **mensaje** (obligatorio), **su nombre y teléfono o WhatsApp** (obligatorio, con aceptación explícita de compartirlo con el dueño), **foto** y **ubicación** (opcionales).
  3. El dueño recibe un **push** y un **email** (respaldo por si el push falla), y el aviso queda en su bandeja **"Avisos"**.
  4. **El dueño decide** si llama o escribe. Su número solo lo ve quien él elija contactar.
  - Junto a cada aviso, el dueño ve un recordatorio anti-estafa: *"Nunca pagues por adelantado ni envíes dinero para recuperar a tu mascota"*.
  - **Opcional y desactivado por defecto:** el dueño puede mostrar su WhatsApp directo en un reporte, con una advertencia del riesgo de estafas.
  - Desde la Fase 1 se suma el **chat dentro de la app** (chat híbrido), que es la vía principal entre usuarios con cuenta.
- **Microchip:** si la mascota tiene chip, el reporte lo indica, y a quien la encuentra se le aconseja **llevarla a una veterinaria para leer el chip**. Al dueño se le sugiere marcarla también como **extraviada en el RENAC**.
- **Avisos por zona:** al publicar un reporte, se notifica a los usuarios a **5 km o menos** (radio configurable).
- **Seguir una búsqueda (Fase 1):** cualquier usuario puede seguir un reporte y recibe aviso cuando hay novedades o cuando la mascota aparece.
- **Resolver:** el autor marca "¡Apareció!" y el reporte pasa a resuelto y se archiva. Se avisa a los seguidores.
- **Vencimiento:** si no hay actividad en 60 días, se le pregunta al autor si sigue vigente. Si no responde, se archiva (valor a confirmar).
- **Compartir:** cada reporte tiene una página web pública para compartir en Facebook y WhatsApp.
- **Imprimir cartel** (D119): en cualquier reporte activo (no solo el de quien reportó, así los vecinos también pueden pegarlo), un PDF A4 con «SE BUSCA · nombre» (perdida) o «SE ENCONTRÓ · ¿Es tuyo?» (encontrada), la foto, los datos públicos, dónde la vieron (texto opcional que escribe quien lo arma: sin geocodificación) y un **QR a la página del reporte**. Nunca lleva teléfono ni recompensa. Abrir esa página **no avisa a nadie** (a diferencia del QR de la chapita): solo avisa el formulario «Avisar», así un cartel escaneado en la calle no genera falsas alarmas. Al marcar «¡Apareció!», la página dice «¡Apareció! Gracias por ayudar». Métrica `sos_poster`.
- **Ayuda:** directorio de refugios, protectoras y grupos de Pando, y aviso de llamar al **911** si hay una persona en riesgo (la app es solo para animales).

## 5. Mapa integral (Explorar) — Fase 0 (perdidos + urgencias) / Fase 1 (completo)

- Vistas: **Mapa**, **Lista** y **Sin local** (tiendas online y servicios a domicilio).
- **Chips agrupados (D91):** arriba del mapa, "Perdidos y encontrados" y un chip por grupo: **Salud** (veterinarias, farmacias), **Tiendas** (pet shops, agropecuarias), **Cuidado** (peluquerías, paseadores, hoteles y guarderías, adiestradores), **Salidas** (aceptan mascotas) y **Refugios**. El primer toque elige el grupo entero; el siguiente abre sus rubros para elegir solo algunos (el chip muestra "Cuidado · 1"); "Quitar" lo saca. Sin chips elegidos se ve todo.
- **Referencias de los pines:** abajo a la izquierda, se pliegan tocando "Referencias" y la app lo recuerda en el dispositivo.
- **Lo que se ve es para todos, también visitantes (D84):** rubros, lugares sin reclamar, eventos, lista y filtros. Con cuenta y la funcionalidad correspondiente se suman las acciones (marcar, reclamar, favoritos).
- **Chips (D84):** sin ninguno elegido se ve todo; con alguno, solo lo elegido. "Perdidos y encontrados" solo muestra únicamente los SOS. La lista arranca con las tarjetas de perdidos y encontrados y sigue con los lugares.
- **Capas / categorías:** veterinarias (y urgencias 24 h), petshops, farmacias veterinarias, peluquerías, paseadores, hoteles y guarderías, adiestradores, **lugares que aceptan mascotas** (bares, restaurantes, alojamientos), refugios, agropecuarias / agroveterinarias (D89: salen también al filtrar "Pet shop"), eventos, perdidos y encontrados.
- Filtros: categoría, especie de la mascota activa, distancia (300 m, 800 m, 2,5 km, todo), "Abierto ahora", favoritos, **"Coloca microchip"** (veterinarias con la insignia Operador RENAC, Fase 1).
- **Guardar filtros:** función Pro (✅ 2.11, D112: «Guardar como mis filtros» y el mapa abre con ellos). Los favoritos siguen gratis (D112).
- **Estados de un lugar:** sin reclamar (gris) · no verificado · verificado ✔️ · destacado (naranja, plan pago).
- **Íconos de los pines (D82):** el ícono dice el rubro (veterinaria cruz, pet shop carrito, farmacia pastilla, peluquería tijera, paseador persona caminando, hotel cama, adiestrador birrete, acepta mascotas huella, refugio casita, agropecuaria tractor) y el color, el estado. Perdidos y encontrados: lupa roja o verde. Eventos: calendario coral. Un lugar sin reclamar es gris **con el ícono de su rubro**.
- **Marcar lugar (Fase 1):** el usuario elige el rubro, toca el mapa y puede pegar un link de Google. **No puede ponerle nombre.** Queda "sin reclamar", con el texto "marcado por N usuarios".
- **Ficha del lugar:** sube desde abajo; horario, dirección, distancia, especies que atiende, promoción, contactos, reseñas, favorito, "fui", "**cómo llegar**" (enlace a Google Maps) y "es la veterinaria de mi mascota".
- **Fase 0:** el mapa muestra solo perdidos y encontrados + **veterinarias de urgencia cargadas a mano**.

## 6. Recordatorios — Fase 1

- **Medicación:** nombre, dosis, frecuencia (cada X horas, diaria, semanal), fecha de fin. Al sonar: **"✅ Ya se la di"**, con historial.
- **Alimentación:** horarios fijos y porción opcional.
- **Vacunas, desparasitación y controles:** por fecha.
- Son **notificaciones locales**: funcionan sin internet y no tienen costo de servidor.
- **Gratis** para todos. Los recordatorios que manda la veterinaria (módulo Socios) llegan en la Fase 2.

## 7. Hogar compartido — Fase 1 (función) / Fase 2 (cobro, plan Familia)

- Invitar hasta 5 integrantes al hogar con un **enlace** (`/unirme/<código>`, sirve una vez, vence a los 7 días). Comparten mascotas, libreta y recordatorios, y reciben los avisos del QR. Solo el dueño borra la mascota, cambia el QR y reporta un SOS (D69).
- **Mi perfil** (D70): rol, plan, mascotas a cargo (propias y compartidas) y con quién se comparte el cuidado.
- Cuando alguien marca "ya se la di", lo ven todos. **Evita dosis dobles.**
- Registro de quién paseó o alimentó, y cuándo. Asignar tareas ("hoy pasea Juan").
- **Cuidador temporal** con acceso por X días.
- 30 días de prueba gratis al invitar al primer integrante. Paga quien invita y los invitados no.

## 8. Chat híbrido — Fase 1

- Chat dentro de la app entre usuarios, y entre usuarios y empresas. Es la vía principal.
- El usuario o la empresa puede mostrar además su **WhatsApp** de forma opcional.
- Enviar fotos y ubicación. Bloquear y reportar.

## 9. Reseñas — Fase 1

- De 1 a 5 estrellas y comentario, **solo si hubo contacto real** (chat, reserva, pedido o "fui" verificado).
- La empresa responde una vez y en público. No puede borrar reseñas, pero sí reportarlas.

## 10. Noticias — desde el lanzamiento (patrocinadas: Fase 2)

- Grilla de tarjetas filtrada por la especie de la mascota activa.
- Mezcla novedades de la comunidad, eventos y **promociones de marcas** con la etiqueta "Promocionado".
- **Comunidad (D86):** sección que se arma sola con lo que pasa en la app: reencuentros (solo si el dueño lo comparte al tocar "¡Apareció!"; lo puede quitar después), adopciones concretadas, lugares verificados y eventos, más un resumen de los últimos 30 días con totales. Nunca ubicaciones ni datos de personas; la administración puede ocultar cualquiera.
- **Reacciones y perdidas activas (D87):** a las noticias y a las novedades se reacciona con ❤️ Me alegra, 🎉 ¡Qué bueno! o 🙏 Gracias (una por persona, se cambia o se quita; sin comentarios; se muestran solo los totales; un visitante tiene que ingresar). Al tocar una novedad se abre su detalle con la foto y las reacciones; el autor de un reencuentro compartido ve cuántos reaccionaron. Las mascotas perdidas que se siguen buscando (últimos 30 días) aparecen en Comunidad sin ubicación y abren su reporte, donde se puede avisar o **Seguirlo** (D74). Pendiente: "Avisame" para eventos y aviso push al dueño cuando reaccionan (necesitan tareas programadas).
- **Es la primera pestaña y la ve cualquiera, también un visitante (D94);** reaccionar pide ingresar. Ya no depende de la funcionalidad gradual `noticias`, y compartir un reencuentro en Comunidad se ofrece a todos. Las carga la administración desde el portal. Las **patrocinadas** siguen siendo de la Fase 2 (hacen falta marcas).

## 11. Adopción responsable — Fase 1 (directorio) / Fase 2 (proceso) / Fase 3 (packs y tránsito)

El objetivo no es solo publicar animales: es que **la adopción salga bien y el animal no vuelva a la calle**.

**Fase 1:** el directorio de Ayuda enlaza a las adopciones de cada refugio de la zona (sin desarrollo propio).

**Fase 2 — el proceso completo:**

1. **Preparar al adoptante**
   - Guía **"¿Estoy listo para adoptar?"**: tiempo, espacio, acuerdo de toda la casa, vacaciones, mudanzas.
   - **Calculadora de costos** mensuales por especie y tamaño (comida, vacunas, castración, veterinaria).
   - **Perfil de adoptante**: un cuestionario que se completa una vez y se reutiliza (vivienda, patio, horas solo, experiencia, otros animales, niños).
2. **Publicación**
   - Ficha: especie, raza, edad, tamaño, energía, salud (vacunas, castrado, chip), convivencia (niños, perros, gatos), necesidades especiales, requisitos, fotos.
   - **Aporte** (solo refugios y ONG): monto y qué cubre, a la vista ("$800 — cubre castración y vacunas").
   - **Camadas**: una publicación con varios animales.
3. **Compatibilidad**: cruza el perfil del adoptante con la ficha y orienta ("Buena compatibilidad" / "Ojo: necesita patio y vos indicaste apartamento"). No bloquea.
4. **Proceso por etapas**: Me interesa → Cuestionario → Chat / entrevista → Visita → Adopción → Seguimiento. Quien publica gestiona sus solicitudes y toma notas **privadas**.
5. **Compromiso de adopción** (aceptación digital): castración (Ley 19.889) con fecha límite si no está castrado, microchip y registro en el RENAC, vacunas al día, no abandonar y avisar a quien lo dio si no puede seguir.
6. **Después de adoptar**
   - La mascota **pasa al perfil del adoptante** con su libreta y su **chapita QR**.
   - Se crean solos los **recordatorios** de castración, vacunas y chip.
   - **Seguimiento a los 7, 30 y 90 días**: foto y "¿cómo va?". Quien la dio en adopción ve las respuestas.

**Fase 3:**
- **"Pack adopción"**: veterinarias (primera consulta o castración con descuento) y petshops (kit de bienvenida) para animales adoptados por la app. ✅ 3.4b (D107): gratis para comercios verificados; quien adoptó pide el código en Adopción → Mis solicitudes → Pack adopción y el comercio lo canjea en el modo comercio.
- **Apadrinamiento** de refugios y ferias de adopción por empresas. ✅ 3.4b (D108): modo comercio → Apadrinar un refugio (comercio verificado) o Padrinos del refugio (refugio); al aceptar, la ficha del refugio o el evento muestra "Apadrinado por".
- **Hogares de tránsito**: personas que cuidan temporalmente a un animal hasta que se adopte. ✅ 3.4b (D106): Adopción → Hogar de tránsito (me anoto con mi barrio, pauso, respondo pedidos); modo comercio de un refugio verificado → Hogares de tránsito (los de su zona, pedir, cancelar o terminar); al aceptar se abre el chat.

## 11b. Eventos y denuncias — Fase 2

- **Eventos:** jornadas de castración, ferias de adopción, encuentros. Aparecen en el mapa.
- **Denuncias de maltrato:** formulario con fotos y ubicación, más información sobre a quién recurrir (INBA y autoridades). La app no reemplaza a la denuncia oficial.

## 12. Turnos, pedidos y servicios — Fase 3

- **Reservar turno:** día, horario libre, servicio y mascota. El comercio confirma o rechaza.
  - **Hecho (D104), detrás de `agenda`:** «Reservar turno» en la ficha de los comercios Plus con la agenda prendida (lo ve cualquiera; reservar pide ingresar): servicio o consulta general, día (sin los bloqueados), horario libre (lo calcula la base), mascota y una nota. **Mis turnos** (Ajustes y menú) con el estado en vivo; se cancela hasta 2 horas antes. El comercio, en modo comercio → **Agenda**: prender el módulo, duración, turnos a la vez, anticipación, días adelante y días sin turnos; confirma, rechaza, marca atendido o cancela. Push en cada cambio y recordatorio el día anterior a las 18:00.
- **Catálogo y pedidos:** cantidades y total. Estados: nuevo → preparando → listo → entregado. El pago se hace directo al comercio (pago en la app en la Fase 4).
  - **Hecho (D85), detrás de `catalogo`:** en la ficha, "Ver catálogo" (si el comercio lo tiene prendido); se suman productos con precio, se ve el total, se deja una nota y "Hacer pedido" (pide cuenta). "Mis pedidos" está en Ajustes. El comercio ve solo el primer nombre de quien pide y lo avanza de a un paso desde el modo comercio → Pedidos. **Avisos y estado en vivo (D100):** push al comercio con cada pedido nuevo o cancelado por quien pidió, y a quien pidió cuando pasa a preparando, listo, entregado o lo cancela el comercio; «Mis pedidos» y Pedidos del modo comercio se actualizan solos mientras están abiertos.
  - **Pago y entrega por WhatsApp (D92):** el comercio dice qué formas de pago acepta y si hace retiro, envío gratis o con costo (y gratis desde un monto). Quien pide elige el pago y la entrega, ve subtotal + envío = total y, después de guardar el pedido, «Abrir WhatsApp» manda el resumen al WhatsApp del comercio. La dirección se pasa por WhatsApp: no se guarda en la app.
  - **A la vista de todos (D93):** el catálogo y los servicios los ve cualquiera, también visitantes; «Agregar» y «Consultar» piden ingresar.
- **Contratar paseadores, hoteles y cuidadores:** solicitud por chat y reserva. El pago es entre las partes hasta la Fase 4.
  - **Hecho (D115), detrás de `cuidados`:** «Contratar: paseo, estadía…» en la ficha de los **paseadores y hoteles** con plan Plus y la agenda prendida (lo ve cualquiera; pedir pide ingresar). Se elige el servicio (paseo, guardería de día, estadía o visitas a domicilio), los días (hasta el máximo del prestador), el momento del día (opcional), hasta 5 mascotas y una nota; si no queda lugar en algún día (guardería y estadía) lo dice antes de enviar. El prestador acepta o rechaza en modo comercio → Agenda → **Paseos y estadías**; **aceptar abre el chat**, donde se acuerdan la dirección, el precio y el pago. **Mis paseos y estadías** (Ajustes y menú) con el estado en vivo y el chat; se cancela hasta el día anterior. Push en cada cambio (`care-alert`).
  - Idea a evaluar: **seguir el paseo en vivo** con la ubicación del paseador (`16-ideas-futuras.md`, I1).
- "**Mis turnos y pedidos**" con el estado en vivo.

## 13. Comunidad por raza y especie — Fase 3

- **Grupos** por raza ("Bulldog Francés Uruguay"), especie ("Gatos de Pando") o tema (adopción, salud senior).
- Publicaciones con fotos, preguntas, consejos y experiencias; comentarios.
- Eventos de grupo (por ejemplo, encuentro de una raza), que pueden patrocinar petshops o marcas.
- **Seguridad (prevención de robos y cría irregular):**
  - **No** hay listados de "mascotas cerca" ni perfiles de mascota buscables por ubicación.
  - Las fotos se suben **sin metadatos de ubicación** (se borra el EXIF).
  - Prohibido publicar **cruzas, venta de animales** o datos de ubicación de una mascota (ver `06-reglas-negocio.md`).
  - Contacto entre personas solo por el chat de la app, con un **saludo que el otro acepta** antes de abrir la conversación.
- Moderación de siempre: reportar, ocultamiento automático y revisión del administrador.

- **Hecho (D116), detrás de `grupos`:** Noticias → Comunidad → **Grupos** (también en el menú). Grupos por especie y por tema de entrada, y el **de la raza de tu mascota** con un toque (se crea solo; no para «Mestizo»). En cada grupo: unirse o salir, publicaciones (pregunta, consejo o experiencia, con hasta 4 fotos sin EXIF) y comentarios; se lee sin cuenta. En cada publicación o comentario: **Saludar** a quien lo escribió, reportar (vende o cruza, ofensivo, muestra dónde vive una mascota, otro) o borrar lo propio. **Saludos** muestra los recibidos (aceptar abre el chat; «Ahora no») y los mandados. Los eventos de grupo patrocinados quedan para más adelante.

> **En espera:** "compañeros de paseo / juego" (listado de mascotas cercanas para socializar). Se pausó por el riesgo de que se use para robar animales o para cruzas. Ver `13-riesgos-pendientes.md`.
> **Excluido:** cruza o reproducción entre mascotas.

## 14. "Busco veterinaria" — Fase 2

Conecta mascotas sin veterinaria con veterinarias cercanas, **solo con permiso del dueño**.

- **Disparador discreto:** si una mascota no tiene veterinaria asociada, en un momento natural (al cargar una vacuna o un control) aparece una tarjeta que se puede cerrar: *"¿Toby todavía no tiene veterinaria? Podés recibir propuestas de veterinarias cercanas"* → **[Quiero recibir propuestas]** / **[Ahora no]**.
- "Ahora no" → plan Gratis: no se vuelve a preguntar por **90 días**. Planes Pro y Familia: **no se vuelve a preguntar nunca**. En ambos casos se puede activar en cualquier momento desde Ajustes o la ficha de la mascota.
- Al aceptar se registra el **consentimiento** (fecha y alcance). Se revoca desde Ajustes o desde la ficha de la mascota.
- Bandeja **"Propuestas para Toby"** con un **máximo de 3 propuestas por mes**.
- Al aceptar una propuesta, se abre el chat con la veterinaria o la mascota pasa a ser **socia** (módulo Socios).
- Al principio solo para **veterinarias**. La mecánica queda preparada para sumar peluquerías, paseadores y petshops.

**Del lado de la veterinaria (plan Plus):**
- Dato **anónimo y agregado**: *"Hay 14 mascotas sin veterinaria a menos de 2 km tuyo (9 perros, 5 gatos)"*.
- Enviar una propuesta a ese grupo ("Primera consulta 20% off").
- **No ve la identidad** de nadie hasta que el usuario acepta.
- Resultados: enviadas, vistas, aceptadas.

## 15. Tienda — Fase 2 (catálogo) / Fase 4 (marketplace)

- Fase 2: catálogo de cada petshop con fotos, precios y botón "Consultar" (chat o WhatsApp). **Hecho (D85):** "Consultar" abre el chat con el comercio (si tiene cuenta y la funcionalidad `chat`) o su WhatsApp con el nombre del producto; un producto sin precio dice "Consultar precio".
- **Servicios del comercio (2.10a, D90), plan Plus, detrás de `catalogo`:** cualquier rubro carga sus servicios (nombre, descripción, precio opcional o "desde", duración) desde el modo comercio → Negocio → Tus servicios; en la ficha aparece la sección "Servicios" con "Consultar" (el mismo camino que el catálogo). Si el plan baja, se ocultan sin borrarse. Máximo 50 por comercio.
- **Página pública del comercio (2.10b, D90), plan Plus:** `/n/<id>` en la web liviana, sin app ni cuenta: fotos, horario y "abierto ahora", contactos públicos, "Cómo llegar", servicios y productos con "Consultar" por WhatsApp. Se comparte desde Mi negocio → Negocio → "Compartir mi página" (copia el enlace) o se abre con "Ver".
- Fase 4: carrito, pago con Mercado Pago y envío.

---

## Modo comercio (dentro de la app) — Fase 1 en adelante

Barra inferior: **Panel** · **Agenda** · **Catálogo** · **Pedidos** · **Negocio**. Cabecera con el nombre, el tipo, el plan y la insignia de verificación, más un botón para volver al modo dueño.

- **Alta del negocio (opción C):** elegir el tipo, el nombre y la ubicación (marcar en el mapa o **reclamar un lugar sin reclamar** del mismo rubro). Si no tiene local, indicar la zona de cobertura. Aparece al instante como "no verificado". Para recibir la insignia ✔️, el administrador valida el RUT y que el reclamo sea legítimo.
- **Negocio:** datos, horario estructurado por día, especies que atiende, fotos, contactos (web, Instagram, Facebook, WhatsApp), promoción (planes pagos).
- **Módulos según el tipo de negocio y el plan** (ver `06-reglas-negocio.md`): catálogo y pedidos, agenda de turnos, socios y recordatorios.
- **Panel:** plan, módulos, resumen (turnos pendientes, pedidos nuevos, socios, productos) y **estadísticas** (planes pagos): vistas, contactos, clics y comparación mensual.
- **Reseñas:** ver y responder.
- **Socios (veterinarias):** mascotas que eligieron esa veterinaria. Botón "Recordar" para avisar del próximo control.
