# 06 · Reglas de negocio

## Regla de oro

**Lo que hace a la seguridad y la salud del animal no se cobra:** SOS, avisos por zona, QR, foto de la mascota, recordatorios de medicación y alimentación. Lo pago es comodidad, personalización, coordinación familiar y visibilidad comercial.

## Planes para usuarios

| | Gratis | Pro | Familia |
|---|---|---|---|
| SOS, avisos, QR, foto, mapa, chat | ✅ | ✅ | ✅ |
| Recordatorios de medicación, comida y vacunas | ✅ | ✅ | ✅ |
| Mascotas | Hasta 2 | Ilimitadas | Ilimitadas |
| Sin publicidad (barra de anuncio chica) | | ✅ | ✅ |
| Sin repreguntas de "Busco veterinaria" tras un "Ahora no" | | ✅ | ✅ |
| Filtros y favoritos guardados | | ✅ | ✅ |
| Descuentos en comercios adheridos | | ✅ | ✅ |
| Historial de salud en PDF | | ✅ | ✅ |
| Personalización: temas Faro, Vecinos y Pop (`14-brief-identidad-visual.md` §10) y tamaño de letra | | ✅ | ✅ |
| Hogar compartido (hasta 5 integrantes), tareas, cuidador temporal | | | ✅ |
| **Precio de ejemplo (a validar)** | $0 | ~$60/mes | ~$120/mes |

- Suscripción mensual o anual con descuento.
- Plan Familia: **30 días gratis** al invitar al primer integrante. Paga quien invita.
- Si el cobro es dentro de la app, la tienda retiene alrededor del 15%.
- Cobro: Fase 2. El hogar compartido funciona gratis en la Fase 1 para validar el uso.

## Planes para empresas

| | Básico | Destacado | Plus |
|---|---|---|---|
| Ficha en el mapa (nombre, dirección, horario, especies) | ✅ | ✅ | ✅ |
| Fotos | Hasta 3 | Galería | Galería |
| Responder reseñas | ✅ | ✅ | ✅ |
| Pin naranja y prioridad en el mapa y las búsquedas | | ✅ | ✅ |
| Promoción, web, Instagram, Facebook, WhatsApp | | ✅ | ✅ |
| Estadísticas completas y reporte mensual | Resumen | ✅ | ✅ |
| Módulos: catálogo, agenda, socios | | | ✅ |
| **Precio de ejemplo (a validar)** | $0 | ~$600/mes | ~$1.200/mes |

- **Suscripción mensual** con cobro manual al inicio (transferencia o link de pago). **Comisión** por ventas y reservas recién cuando haya pagos dentro de la app (Fase 4, 8–15%).
- **Socios Fundadores:** las primeras 20–30 empresas de Pando reciben Destacado (o Plus) gratis por 6 meses y un precio congelado después.

### Módulos según el tipo de negocio

| Tipo | Catálogo y pedidos | Agenda de turnos | Socios y recordatorios |
|---|---|---|---|
| Veterinaria | Sí | Sí | Sí |
| Petshop | Sí | No | No |
| Peluquería | No | Sí | No |
| Farmacia veterinaria | Sí | No | No |
| Hotel / guardería | No | Sí | No |
| Paseador / adiestrador | No | Sí | No |
| Tienda online | Sí | No | No |
| Servicio a domicilio | No | Sí | No |

**Regla de activación:** un módulo está activo solo si el plan es Plus, el tipo de negocio lo admite y la empresa lo prendió. Si el tipo no lo admite, se muestra "No aplica".

## Alta y verificación de empresas (opción C)

1. La empresa se registra sola y **aparece al instante** como "no verificada".
2. Puede crear un lugar nuevo o **reclamar un lugar "sin reclamar"** del mismo rubro.
3. Para la insignia **verificada ✔️**: el administrador valida el **RUT** y que el reclamo sea legítimo (al principio, a mano; más adelante, con un código por teléfono).
4. Reclamar un lugar ya reclamado → se abre una disputa que resuelve el administrador.

### Insignia "Operador RENAC"

- La veterinaria la pide desde su ficha y el administrador la verifica contra el **listado oficial de operadores RENAC** del MGAP.
- Habilita el filtro "Coloca microchip" en el mapa.

## RENAC

- **No se automatizan consultas** al sitio del RENAC: solo se **enlaza** a la consulta pública oficial. Una integración requiere un acuerdo con el INBA.
- Los datos personales del listado de operadores **no se publican en la app**. Se usan solo para contactar veterinarias y verificar la insignia.
- El estado RENAC de una mascota lo **declara el usuario**. La app no lo certifica mientras no haya integración.

## Lugares sin reclamar

- Cualquier usuario con cuenta puede marcar un lugar indicando **solo el rubro** (sin nombre) y un link de Google opcional.
- Si varios usuarios marcan el mismo rubro a menos de 30 m, se suman ("marcado por N usuarios").
- Se muestran en gris. Cuando un comercio los reclama, pasan a su ficha.

## Regla de coincidencia por especie

Un lugar, producto o noticia **coincide** con la mascota activa si la lista de especies que atiende incluye la suya. Con "Todas", se usa la unión de las especies de todas las mascotas del usuario. Quien solo tiene un pez no ve comida para perros.

## "Abierto ahora"

- El horario se guarda **estructurado por día** (por ejemplo, lunes a viernes 9:00–19:00, sábado 9:00–13:00), con la opción "24 h" y días especiales (feriados).
- "Abierto ahora" se calcula con el día y la hora de la zona horaria del lugar.
- Orden de la lista: abiertos primero, después horario desconocido, después cerrados. Dentro de cada grupo, por cercanía.

## SOS

- Para publicar hay que tener cuenta, y el reporte necesita **al menos una foto** y una ubicación.
- La ubicación publicada es **aproximada** (se desplaza al azar dentro de unos 150–200 m). La exacta queda guardada en privado.
- **Límite:** 3 reportes por usuario por día.
- Aviso a los usuarios a **5 km o menos** (configurable por usuario entre 1 y 20 km). Un usuario recibe como máximo un número limitado de avisos por día, para no saturar.
- Vencimiento: 60 días sin actividad → se pregunta al autor; si no responde en 7 días, se archiva.
- Al resolverse, se avisa a los seguidores y el reporte sale del mapa.

## QR

- Quien escanea **no necesita cuenta** para contactar al dueño. Para evitar abusos: límite de contactos por QR y por dispositivo, y un control anti-bots.
- El dueño elige qué datos de salud se muestran.
- Si la mascota tiene un SOS activo, la página muestra "Estoy perdido 🆘".
- El dueño puede **desactivar o regenerar** el código (por ejemplo, si cambia de chapita).

### Chapitas físicas

- El **QR digital es siempre gratis**. La **chapita física** es un producto: puede ser **patrocinada** (gratis para el dueño), **entregada por una veterinaria** o **vendida**.
- Las chapitas se fabrican **pre-codificadas por lotes**. Cada código se activa **una sola vez** y queda vinculado a una mascota hasta que el dueño lo desvincula.
- Un código sin activar muestra una página "Activá esta chapita con la app".
- **Retiro en la veterinaria:** solo en veterinarias adheridas que aceptaron ser punto de retiro. La veterinaria marca la chapita como entregada en su panel.
- **Sponsors:** el logo va en el reverso de la chapita y, en la página del QR, **chico y abajo** (la página es para una emergencia). El sponsor recibe resultados de su lote: activadas, escaneos y reencuentros.
- Precios de venta y de patrocinio: a definir con el costo real por unidad del primer lote.

## Contacto y chat

- **Contacto inverso:** el teléfono del dueño (SOS o QR) **nunca se envía a otros usuarios**. Quien quiere contactarlo deja un aviso con su propio contacto, y **el dueño decide** si responde.
  - Redirigir a `wa.me/<número>` o `tel:` **no** cuenta como ocultar el número: quien contacta lo ve completo. Por eso no se usa como vía por defecto.
  - Quien deja el aviso **acepta explícitamente** compartir su contacto con el dueño.
  - Límites anti-abuso: avisos por dispositivo y por reporte o QR por hora, control anti-bots (por ejemplo, Cloudflare Turnstile, gratis) y bloqueo de remitentes.
  - El dueño puede reportar un aviso como estafa: se bloquea el remitente y se revisa en moderación.
- **WhatsApp directo:** solo si el dueño lo activa (desactivado por defecto), con advertencia de riesgo de estafa.
- En los negocios, el WhatsApp es un dato comercial público si la empresa lo elige (plan Destacado o superior).
- Chat híbrido (Fase 1): el chat interno es la vía principal y el WhatsApp es opcional.

## Reseñas

- Solo con **contacto real** previo (chat, reserva, pedido).
- De 1 a 5 estrellas + comentario. Una reseña por usuario y empresa, editable.
- La empresa responde una vez en público. No puede borrar reseñas, solo reportarlas.

## Moderación

1. **Reportar:** botón en publicaciones, comentarios, reseñas, perfiles y chats.
2. **Ocultamiento automático:** con **3 reportes de usuarios distintos**, el contenido se oculta hasta que lo revise el administrador.
3. **Revisión** en el portal de administración: aprobar, eliminar, advertir o bloquear.
- Prevención: cuenta verificada (correo o Google), foto obligatoria en SOS, límites por día.
- Si el contenido menciona a una persona en riesgo, se deriva al **911**.

## "Busco veterinaria" (propuestas a mascotas sin veterinaria)

- Es **opt-in por mascota**, con un consentimiento registrado (fecha, alcance) y revocable.
- Si el usuario elige "Ahora no": en el plan Gratis no se vuelve a preguntar por 90 días; en Pro y Familia **no se vuelve a preguntar nunca** (sigue disponible desde Ajustes o la ficha de la mascota). Nunca más de una tarjeta por sesión.
- La veterinaria solo ve **cantidades agregadas** por zona y especie, con un mínimo de 5 mascotas para mostrar el dato (para que nadie se pueda identificar).
- Máximo **3 propuestas por mes por mascota**, en total y entre todas las veterinarias.
- La identidad del usuario se comparte **solo cuando acepta** una propuesta.
- Disponible en el plan **Plus**. Más adelante se puede evaluar un cobro por contacto concretado.

## Adopción responsable

- **Siempre gratis** para quien publica y para quien adopta (regla de oro).
- **Nunca venta.** Refugios y ONG verificados pueden indicar un **aporte transparente**: monto y qué cubre (castración, vacunas, chip). Los particulares **no pueden pedir dinero**.
- **Refugios y ONG:** publican con la insignia de verificados, sin límite de publicaciones.
- **Particulares (con límites):**
  - Cuenta verificada y al menos una foto por animal.
  - Máximo **2 publicaciones activas**. Una camada cuenta como una publicación (hasta 8 animales).
  - Si un mismo usuario publica **2 camadas o más en 12 meses**, pasa a revisión del administrador (posible cría irregular) y se le muestra información sobre castración.
- **Adoptantes:** máximo **3 solicitudes activas** a la vez, para evitar acaparadores.
- El **compromiso de adopción** queda registrado (fecha y texto aceptado). Si el animal no está castrado, se fija una fecha límite y se crea el recordatorio.
- **No hay listas negras compartidas** de adoptantes entre refugios (Ley 18.331). Cada publicador tiene notas privadas sobre sus solicitudes.
- Reportar una adopción sospechosa (venta encubierta, maltrato) sigue la moderación habitual.

## Comunidad: contenido prohibido

Además de lo habitual (ofensas, spam, estafas):
- Ofrecer o pedir **cruzas** o reproducción.
- **Vender** animales (las adopciones van por su sección, sin costo).
- Publicar la **ubicación** o la rutina de una mascota (dónde vive, a qué hora la pasean).
- Las fotos se suben siempre **sin metadatos de ubicación** (EXIF), en toda la app.

## Privacidad (Ley 18.331)

- Términos, política de privacidad y consentimiento al registrarse.
- Registro de la base de datos ante la URCDP (consultar con un profesional).
- Descargar y borrar mi cuenta.
- La **ubicación del usuario nunca es pública**. Para los avisos se guarda solo una zona aproximada.
- Las métricas que ven las empresas son **anónimas y agregadas**.
- *Esto no es asesoramiento legal: hay que revisarlo con un profesional antes del lanzamiento.*
