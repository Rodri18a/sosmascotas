# Pruebas paso a paso con dos teléfonos

> Armada el 28/10/2026 para recorrer las rondas 1 a 3 de [Casos de prueba](../19-casos-de-prueba.md) (Equipo, Paseos y cuidados, Comunidad) **tocando botón por botón**. El 29/10 se sumaron las rondas 4 a 7 (Chapita QR, SOS, Mapa y Privacidad: lo que falta de la Fase 0). Los nombres entre «comillas» son los textos exactos que aparecen en la app.
>
> Cuando termines cada caso, anotá ✅ o ❌ con su ID (por ejemplo «EQ-04 ❌ ve las estadísticas») y se pasa a la tabla de casos.

## Los dos teléfonos

| | 📱 **Teléfono 1 · Cuenta A** | 📱 **Teléfono 2 · Cuenta B** |
|---|---|---|
| Quién es | Vos (rodrigo18a@gmail.com): dueño de «Pet Shop Ejemplo (catálogo)», plan Plus | Una segunda cuenta de prueba (otro correo) |
| Nombre en Perfil | El tuyo | Otro, por ejemplo «Rodri», para distinguirlos |

En esta guía, **📱1** = hacelo en el teléfono 1 y **📱2** = hacelo en el teléfono 2.

## Preparación (una sola vez)

En **los dos teléfonos**:

1. Abrí Chrome y entrá a **https://sosmascota-dev.vercel.app**.
2. Instalala: menú de Chrome **⋮** (arriba a la derecha) → **«Instalar app»** (o «Agregar a la pantalla principal»). Desde ahora, abrila siempre con el ícono de SOS Mascota, no desde Chrome.
3. Ingresá con tu correo (A en el 📱1, B en el 📱2) → poné el código de 6 números que te llega por correo → aceptá términos y privacidad.
4. Cuando pregunte por las notificaciones, tocá **«Permitir»**. Sin eso no llegan las push.
5. Solo en el **📱2**: **☰** (arriba a la izquierda) → **«Ajustes»** → tocá la **primera fila** (tu nombre y el correo, con un lápiz ✏️ a la derecha) → en «Tu nombre» escribí «Rodri» → guardar. (En «Mi perfil» el nombre se ve, pero no se cambia.)

### Cómo se mueve uno por la app

- **☰ Menú**: el botón de tres rayitas arriba a la izquierda, en cualquiera de las 5 pestañas de abajo (Noticias · SOS · Mapa · Mascotas · Ayuda). Desde ahí están **«Mi negocio»**, **«Mis pedidos»**, **«Mis paseos y estadías»**, **«Grupos»**, **«Mensajes»** y **«Ajustes»**.
- **Modo comercio**: **☰ → «Mi negocio»**. Abajo aparece una barra con **Panel · Agenda · Catálogo · Pedidos · Negocio**. Arriba a la derecha está **«Volver al modo dueño»**, y, si tenés más de un negocio, el ícono **⇄** para cambiar de negocio.

> ⚠️ Si a la cuenta B le falta alguna opción del ☰ (por ejemplo «Grupos» o el «Equipo» del Panel), es porque esa funcionalidad está en beta y B no está invitada. Avisá y se la invita con `supabase/funcionalidades.py invitar …`.

---

## Ronda 1 · Equipo de la empresa (3.5)

### Paso 0 · B hace un pedido (para tener algo que atender después)

**📱2**
1. Pestaña **Mapa** (el botón redondo del medio, abajo).
2. Arriba, tocá el chip **«Tiendas»**.
3. Buscá en el mapa el pin de **«Pet Shop Ejemplo (catálogo)»** (en Pando) y tocalo: se abre su ficha desde abajo.
4. Tocá **«Ver catálogo (…)»** → en un producto, **«Agregar»** (una o dos veces).
5. Abajo aparece **«Ver pedido · … · $ …»** → tocalo → elegí pago y entrega → **«Hacer pedido»**.

**📱1**: tendría que llegar la push del pedido nuevo (eso es el caso PE-04, de regalo).

### EQ-01 · Invitar

**📱1**
1. **☰ → «Mi negocio»**. Si abre otro negocio, cambialo con **⇄** (arriba a la derecha) a «Pet Shop Ejemplo (catálogo)».
2. Abajo, pestaña **«Panel»**.
3. Tocá la tarjeta **«Equipo»** (dice «Sumá personas para que atiendan pedidos, turnos y el catálogo»).
4. Tocá **«Invitar a alguien»**.
5. Se abre «Invitación al equipo» con un **código**. Anotalo y tocá **«Copiar enlace»**.
6. Mandate ese enlace al 📱2 (por WhatsApp a vos mismo, por ejemplo).

✅ Esperado: al cerrar el cuadro, el código figura en **«Invitaciones sin usar»** con «vence el …».

### EQ-02 · Sumarse con el enlace

**📱2**
1. Abrí el enlace que te mandaste.
2. Aparece **«Invitación a un equipo»** → tocá **«Unirme al equipo»**.

✅ Esperado: «¡Listo! Ya sos parte del equipo.» y entra al modo comercio del Pet Shop.

> Si el enlace se abre en Chrome sin tu sesión (en vez de la app instalada), no importa: hacé este paso con el código (EQ-03) y volvé acá después.

### EQ-04 · Lo que ve el empleado

**📱2**, dentro del modo comercio (**☰ → «Mi negocio»**):
1. Mirá la barra de abajo: la última pestaña tiene que decir **«Equipo»**, no «Negocio».
2. En **«Panel»**: **no** tienen que aparecer «Tu plan», «Ver estadísticas», reseñas ni tránsito.
3. Recorré **Agenda** y **Catálogo**: no tiene que poder cambiar la configuración (horarios de la agenda, socios, descuentos, pack, retiro).
4. Tocá la pestaña **«Equipo»**: se ve la lista con el primer nombre de cada uno (nunca el correo).

### EQ-05 · El empleado trabaja

**📱2**
1. Pestaña **«Catálogo»** → **«Agregar producto»** → nombre «Prueba equipo», precio 100 → guardar.
2. Pestaña **«Pedidos»** → el pedido del Paso 0 → **«Pasar a «Preparando»»**.

✅ Esperado: el producto queda cargado (📱1 lo ve en su Catálogo) y el pedido cambia de estado. Al que pidió (en este caso, la misma cuenta B) le llega la push del cambio.

### EQ-07 · El chat sigue siendo del dueño

**📱2**: buscá alguna forma de abrir los mensajes del comercio (en Pedidos o en el Panel).
✅ Esperado: no hay acceso al chat del negocio. Los chats de B son solo los personales.

### EQ-08 · Sacar del equipo

**📱1**: **Panel → «Equipo»** → al lado de «Rodri», **«Sacar del equipo»** → confirmar.
**📱2**: salí y volvé a entrar a **☰ → «Mi negocio»**.
✅ Esperado: B ya no ve el Pet Shop. Le aparece «Sumar mi negocio», como a cualquiera sin negocio.

### EQ-03 · Sumarse con el código

**📱1**: **Panel → «Equipo» → «Invitar a alguien»** → anotá el código nuevo.
**📱2**: **☰ → «Mi negocio»** → arriba, **«Tengo un código de equipo»** → escribí el código → aceptar.
✅ Esperado: igual que EQ-02.

### EQ-12 · Código ya usado

**📱2**: abrí otra vez el **primer enlace** (el de EQ-01, que ya se usó).
✅ Esperado: «Este código no existe, ya se usó o venció. Pedile uno nuevo al dueño.»

### EQ-09 · Dejar el equipo

**📱2**: modo comercio → pestaña **«Equipo»** → **«Dejar el equipo»** → confirmar.
✅ Esperado: sale; en el **📱1**, B ya no figura en la lista del Equipo.

> EQ-06 (la push del pedido les llega a los dos), EQ-10 (bajar a Básico) y EQ-11 (sexta persona) necesitan una tercera cuenta o el portal: quedan para otra ronda.

---

## Ronda 2 · Paseos y cuidados (3.3)

> ⚠️ Esta ronda necesita el negocio **«Paseos y cuidados Ejemplo»** a nombre de la cuenta A. `docs/19` dice que se carga con `supabase/seeds/paseador_ejemplo.sql`, pero **ese archivo no está en el repositorio**: quedó en la otra máquina sin subir, o se cargó directo en la base. Primero fijate en el **📱1**: **☰ → «Mi negocio» → ⇄**. Si aparece «Paseos y cuidados Ejemplo», seguí. Si no, avisá y se arma el ejemplo.

### CU3-01 · Configurar lo que ofrece

**📱1**
1. **☰ → «Mi negocio» → ⇄ → «Paseos y cuidados Ejemplo»**.
2. Pestaña **«Agenda»**. Arriba hay dos botones: **«Paseos y estadías»** y **«Turnos»**.
3. Si aparece el aviso amarillo «Para que aparezca «Contratar» en tu ficha, prendé «Tomar turnos desde la app» en Turnos»: tocá **«Turnos»**, prendé **«Tomar turnos desde la app»**, guardá y volvé a **«Paseos y estadías»**.
4. En la tarjeta **«Qué ofrecés»**, marcá los chips **«Paseo»**, **«Guardería de día»** y **«Estadía»**.
5. Poné **«Mascotas por día»** en 3, completá **«Condiciones»** (por ejemplo «vacunas al día») → **«Guardar»**.

✅ Esperado: el mensaje de guardado.

### CU3-02 / CU3-03 · Pedir un paseo

**📱2**
1. **Mapa** → chip **«Cuidado»** → tocá el pin de **«Paseos y cuidados Ejemplo»**.
2. En la ficha, tocá **«Contratar: …»**.
3. **«¿Qué necesitás?»** → **«Estadía»**. **«¿Qué días?»** → **«Elegir las fechas»** → pasado mañana. **«¿En qué momento del día?»** → cualquiera. **«¿Para qué mascotas?»** → una (B tiene que tener al menos una mascota cargada). Escribí una nota.
4. **«Enviar el pedido»**.

✅ Esperado: «¡Listo! Te avisamos cuando responda.». En el **📱1** llega la push, y en **Agenda → «Paseos y estadías» → «Pedidos»** aparece el pedido sin recargar.

### CU3-08 · Privacidad

**📱1**: mirá ese pedido.
✅ Esperado: el primer nombre («Rodri»), la mascota y la nota. **Ningún** teléfono ni correo.

### CU3-04 · Aceptar

**📱1**: en el pedido, **«Aceptar y abrir el chat»**.
✅ Esperado: se abre el chat con B, y en el **📱2** llega la push.

### CU3-05 · Rechazar

**📱2**: hacé otro pedido igual (otra fecha).
**📱1**: en ese pedido, **«Rechazar»**.
✅ Esperado: en el **📱2**, **☰ → «Mis paseos y estadías»** lo muestra como «No disponible», y llega la push.

### CU3-09 / CU3-07 · Mis paseos y cancelar

**📱2**: **☰ → «Mis paseos y estadías»** → en el pedido aceptado (el de pasado mañana), **«Cancelar el pedido»**.
✅ Esperado: lo deja cancelar («Pedido cancelado.»). Si probás con uno de **hoy**: «Ya empezó: si necesitás cambiar algo, escribile por el chat.»

---

## Ronda 3 · Comunidad (3.4)

### GR-01 · Entrar a un grupo

**📱1 y 📱2**
1. **☰ → «Grupos»** (o pestaña **Noticias** → arriba, **«Comunidad»** → tarjeta **«Grupos»**).
2. En **«Por especie»**, tocá **«Perros»**.
3. Abajo, **«Unirme al grupo»**.

✅ Esperado: el grupo pasa a **«Tus grupos»** y suma un integrante.

### GR-02 · Publicar con foto

**📱1**, dentro del grupo Perros:
1. Botón **«Publicar»** (abajo a la derecha).
2. Elegí **«Pregunta»**, escribí «¿Qué alimento recomiendan para un cachorro?» → **«Agregar foto»** → una foto → **«Publicar»**.

✅ Esperado: aparece arriba de todo en el grupo.

### GR-03 · Ventas y cruzas prohibidas

**📱1**: publicá «vendo cachorros» (y en otra, «busco macho para cruza»).
✅ Esperado: no se publica y aparece «En la comunidad no se publican ventas ni cruzas de animales…».

### GR-04 · Comentar

**📱2**: grupo Perros → tocá la publicación de A → abajo, **«Escribí un comentario»** → escribí algo → **➤** (enviar).
✅ Esperado: el comentario aparece con el primer nombre «Rodri».

### GR-06 · Saludar

**📱2**: en la publicación de A, tocá **···** (Opciones, arriba a la derecha de la publicación) → **«Saludar»** → **«Mandar el saludo»**.
✅ Esperado: «Saludo enviado. Si acepta, lo vas a ver en Saludos y en tus chats.»

### GR-07 · Aceptar el saludo

**📱1**: en la pantalla **«Grupos»**, tocá **👋 «Saludos»** → en «Rodri te saluda», **«Aceptar y abrir el chat»**.
✅ Esperado: se abre el chat. Cada uno ve solo el primer nombre del otro.

---

## Ronda 4 · Chapita QR: lo que falta (QR-10 a QR-14)

> Agregada el 29/10/2026. Se usa también el **portal de administración** en la compu: **https://sosmascota-admin.vercel.app** (con la cuenta A, que es admin).
>
> ⚠️ QR-12 y QR-14 necesitan que A tenga una **veterinaria verificada** con **«Ser punto de retiro de chapitas»** prendido. Si no la tiene: portal → Comercios → verificar una veterinaria de A (o reclamar una de ejemplo y verificarla).

### QR-10 · Desvincular

**📱1**
1. Pestaña **Mascotas** → la mascota que tiene la chapita activada en QR-09 → tarjeta **«Chapita QR»**.
2. Bajá hasta **«Chapitas físicas»** → al lado del código, **«Desvincular»**.
3. Aparece «¿Desvincular la chapita?» → confirmá.

✅ Esperado: «Chapita desvinculada.» y desaparece de la lista.

**📱2**: escaneá esa chapita (o abrí `/m/<código>`).
✅ Esperado: «Esta chapita ya no está activa».

**📱1**: **«Activar una chapita»** → escribí el mismo código.
✅ Esperado: «Esta chapita ya está vinculada o se dio de baja, y no se puede volver a usar.»

### QR-11 · Pedir una chapita

> Necesita la marca `pedido_chapitas` prendida para A. Si no aparece el botón, avisá.

**📱1**
1. Mascotas → una mascota **sin** chapita → **«Chapita QR»** → **«Pedir una chapita»**.
2. En **«Texto grabado»** poné el nombre (hasta 20 letras). En **«¿Dónde la retirás?»** elegí la veterinaria de retiro → **«Pedirla»**.

✅ Esperado: «Listo, la pediste…» y la tarjeta muestra «Pedido N.º … · Pedida: la estamos preparando.». Se puede **cancelar** mientras está pedida (probalo con un segundo pedido, no con este).

**Compu (portal)**: **Chapitas** → **«Pedidos con retiro en veterinaria»** → el pedido → **«Enviar»** → elegí un código de un lote sin usar → confirmar.
**📱1**: la tarjeta pasa a «En camino a <veterinaria>.».

### QR-12 · Entregar en la veterinaria

**📱1** (como veterinaria)
1. **☰ → «Mi negocio»** → **⇄** → la veterinaria de retiro.
2. **Panel** → tarjeta **«Chapitas: punto de retiro»** → en el pedido de QR-11, **«Llegó»**.
3. Después **«Entregada»** → confirmá «¿La entregaste?».

✅ Esperado: en el modo dueño, la ficha de la mascota muestra «Entregada y vinculada.» y la chapita figura en «Chapitas físicas». Al escanearla, aparece la mascota.

### QR-13 · Sponsor en la página

**Compu (portal)**
1. **Chapitas → «Sponsors» → «Nuevo sponsor»** → nombre «Sponsor de prueba», logo, **«Activo»** prendido → guardar.
2. **Chapitas → «Nuevo lote»** → cantidad 3 → **«Crear»**. En el lote, **«Sponsor del lote…»** → «Sponsor de prueba».
3. Copiá un código de ese lote (o **«Descargar CSV»**).

**📱1**: Mascotas → otra mascota → **«Chapita QR» → «Activar una chapita»** → ese código.
**📱2**: abrí `/m/<código>`.
✅ Esperado: abajo, chico, «Chapita donada por» con el logo y el nombre.

### QR-14 · Stock en la veterinaria

**Compu (portal)**: **Chapitas → «Stock en veterinarias» → «Pasar a una veterinaria…»** → la veterinaria de A, cantidad 2 → **«Pasar»**. Anotá los códigos que muestra («Entregale estas 2 chapitas (y solo estas)»).

**📱1**
1. Hacé otro pedido como en QR-11 (otra mascota, misma veterinaria).
2. Modo comercio → **«Chapitas: punto de retiro»**: arriba dice «Tu stock: 2 chapitas sin usar…».
3. En el pedido, **«Entregar el N.º … de mi stock»** → escribí uno de los códigos → **«Entregada»**.

✅ Esperado: el stock baja a 1 sin usar · 1 activada, y la mascota queda vinculada. Con un código que no es del stock: «Ese código no está entre las chapitas sin usar de tu stock.»

---

## Ronda 5 · SOS (SO-01 a SO-12)

> Antes: los dos teléfonos con las notificaciones permitidas. En el **📱2**, **☰ → «Ajustes»** → **«Zona para avisos de perdidos»** → **«Usar mi zona»** (estando cerca del 📱1, o en Pando) y el radio en 5 km.
>
> Ojo con el **tope de 3 SOS por día por cuenta** (SO-10): en esta ronda A publica 2 y B publica 1.

### SO-01 · Reportar perdida

**📱1**
1. Mascotas → una mascota **sin** reporte abierto → **«Se perdió: reportarla»**.
2. Revisá que esté la foto de la ficha. En **«¿Dónde la viste por última vez?»** tocá el mapa en un punto que conozcas (anotalo: por ejemplo, una esquina) → «Lugar marcado ✔».
3. Completá la descripción. Dejá **apagado** «Mostrar mi WhatsApp en este reporte» → **«Publicar»**.

✅ Esperado: «¡Publicado! Los vecinos de la zona ya pueden verlo.». En el Mapa aparece el pin **corrido unos 150–200 m** del punto que tocaste (no encima).

### SO-09 · Push a la zona

**📱2** (sin hacer nada): tendría que llegar «🐾 Se perdió un perro cerca tuyo» (o la especie que sea) **justo después de SO-01**.
Si no llega, anotá si el 📱2 tenía la app abierta o cerrada.

### SO-02 · Reportar encontrada

**📱2**
1. Pestaña **SOS** → **«Reportar»** → **«Encontré una mascota»**.
2. Una foto cualquiera de un animal, tocá el mapa en **«¿Dónde la encontraste o la viste?»**, descripción → **«Publicar»**.

✅ Esperado: en el mapa aparece con su pin propio (distinto del de las perdidas). En la pestaña SOS, el filtro **«Encontradas»** la muestra y **«Perdidas»** no.

### SO-03 · Mapa por zona

**📱1**: en el Mapa, alejate mucho y movete a otra ciudad (por ejemplo, Montevideo), y después volvé a Pando.
✅ Esperado: lejos no aparecen los SOS de Pando; al volver aparecen otra vez. (Si querés verlo técnico: en la compu, con las herramientas de Chrome → Red, cada movimiento pide solo la zona visible.)

### SO-04 · Detalle y compartir

**📱2**
1. Tocá el pin de la perdida de A → se abre «Reporte» → **«Compartir»**.
2. Mandate el enlace por WhatsApp.

✅ Esperado: en WhatsApp se ve la **vista previa** con la foto. Al abrirlo en Chrome **sin sesión** (o en una ventana de incógnito en la compu) se ve la página `/s/<id>` con la foto, la «Zona aproximada» y el botón para avisar.

### SO-05 · Avisar al dueño

**📱2**: en el reporte de A, **«Avisar al dueño»** → «Dejale un aviso» → mensaje («La vi en la plaza a las 10»), tu nombre y teléfono → marcá «Acepto que reciba mi nombre y mi teléfono…» → **«Enviar aviso»**.
✅ Esperado: «¡Gracias! Tu aviso le llegó.».

**📱1**: llega la push. **☰ → «Avisos»**: está el aviso de «Rodri» con el contacto de B, el consejo contra estafas y «Ya lo contacté» / «Es una estafa».
✅ Y en todo el recorrido del 📱2, **nunca** aparece el teléfono de A.

Repetilo desde la **página web** (`/s/<id>`, sin sesión): el aviso también tiene que llegar.

### SO-06 · WhatsApp opcional

**📱1**: publicá la segunda perdida (otra mascota) y esta vez prendé **«Mostrar mi WhatsApp en este reporte»**.
✅ Esperado: el interruptor arranca **apagado**; al prenderlo se ve «No recomendado: cualquiera vería tu número…» y pide «Tu WhatsApp».

**📱2**: en ese reporte aparece el botón de WhatsApp. Al tocarlo, primero «Antes de escribir por WhatsApp» con «Nunca pidas ni mandes plata…» y después **«Abrir WhatsApp»**.

### SO-11 · Seguir un reporte

**📱2**: en la **primera** perdida de A, **«Seguir este reporte»**.
✅ Esperado: «Te vamos a avisar cuando vuelva a casa.» y el botón pasa a «Dejar de seguir».

### SO-07 · ¡Apareció!

**📱1**: en esa misma perdida, **«¡Apareció!»** → confirmá «¿Apareció?».
✅ Esperado:
- «¡Qué alegría! 💚 Gracias por avisar.» y la pregunta **«¿Compartís la buena noticia?»** → «Compartir»: aparece en **Noticias → Comunidad**.
- El pin sale del mapa. En **SOS → «Mis reportes»** figura «Apareció».
- Si la mascota tiene QR, la página deja de decir «Estoy perdido 🆘».

**📱2** (SO-11): llega **una sola** push «¡<nombre> volvió a casa!».

### SO-08 · Reportar publicación (3 cuentas)

> A es el autor y no cuenta, así que hacen falta **tres cuentas más**: B (📱2), C y D (por ejemplo, en la compu, en ventanas de incógnito con otros correos).

Sobre la **segunda perdida de A**:
1. **📱2**: en el reporte, **⋮ → «Reportar publicación»** → motivo «Es falso» → **«Enviar reporte»** → «Gracias, lo vamos a revisar.».
2. Lo mismo con la **cuenta C**.
3. Lo mismo con una **cuenta D** (otra ventana o el 📱2 con otra cuenta).

✅ Esperado: después del tercero, el reporte desaparece del mapa; A lo ve con «Este reporte está oculto mientras lo revisamos.». En el **portal → Moderación** aparece como «Oculto por reportes». Desde ahí, **«Aprobar»** lo vuelve a mostrar (eso ya es AD-P03).

### SO-12 · Zona aproximada

**📱2**: **☰ → «Ajustes» → «Zona para avisos de perdidos»** → borrala → «Borramos tu zona…». Cerrá y abrí la app: **no** tiene que volver sola. Después **«Usar mi zona»** otra vez.
✅ Esperado: «Guardada: una zona aproximada (unos 500 m)…».

**Compu** (opcional, técnico): en Supabase, la zona guardada de B es el **centro de una celda**, no las coordenadas exactas del teléfono.

> Al terminar: archivá los reportes de prueba (**SOS → «Mis reportes» → el reporte → «Archivar»**) para que no queden en el mapa de dev.

---

## Ronda 6 · Mapa, lugares y búsqueda (MP-01 a MP-11)

> Con un solo teléfono alcanza (📱1). Antes, conviene recargar los ejemplos del mapa (`supabase/seeds/mapa_ejemplo.sql`).

### MP-01 · Chips de rubros

1. **Mapa**: sin ningún chip elegido se ve todo.
2. Tocá **«Salud»**: quedan solo veterinarias y similares. Sumá **«Tiendas»**: se suman los pet shops.
3. Probá **«Cuidado»**, **«Salidas»** y **«Refugios»** de a uno. Con **«Quitar»** vuelve a mostrarse todo.

### MP-02 · Filtros

**«Filtros»** → probá de a uno y tocá **«Listo»**:
- **«Distancia»**: 1 km, 5 km y **«Todo»**.
- **«Abierto ahora»**.
- **«Para qué mascota»**: con una mascota activa, por ejemplo «Para <nombre>».
- **«Coloca microchip (Operador RENAC)»**.
- **«Solo mis favoritos»** (marcá antes uno como favorito, en MP-07).

✅ Esperado: cada filtro deja solo lo que corresponde. **«Limpiar»** vuelve todo atrás.

### MP-03 · Abierto ahora

Abrí una veterinaria con horario y fijate si dice abierta o cerrada según la **hora de Uruguay**. Repetilo de noche o un domingo. Si hay un feriado cargado, en ese día tiene que respetarlo.

### MP-04 · Clusters

Alejá el mapa: los lugares cercanos se agrupan en un círculo con un número; al tocarlo, se acerca. **Los SOS nunca se agrupan** (siempre se ven sueltos).

### MP-05 · Lista y «Sin local»

Arriba, cambiá a **«Lista»**.
✅ Esperado: primero **«Perdidos y encontrados»**, después los abiertos, los sin horario y al final los cerrados, cada uno con «a … km».
Después **«Sin local»**: tiendas online y servicios a domicilio, con «Trabaja en: <zona>».

### MP-06 · Ficha de un lugar

Abrí una veterinaria con todos los datos.
✅ Esperado: horario, **Llamar**, **WhatsApp**, **Cómo llegar** (abre Google Maps con el destino), web, e insignias (✔️ verificada, RENAC, etc.).

### MP-07 · Favoritos y «Fui»

En la ficha: **«Favorito»**, **«Fui»** (pasa a «Fuiste el …») y **«Es mi veterinaria»** (pasa a «Tu veterinaria»).
Después, en **otra** veterinaria, **«Es mi veterinaria»**.
✅ Esperado: la primera deja de ser «Tu veterinaria» (solo puede haber una). Todo sigue igual al cerrar y abrir la app.

### MP-08 · Marcar un lugar

**Mapa → «Marcar un lugar»** → **«Rubro»** → tocá el mapa → (opcional) un enlace de Google Maps → **«Marcar»**.
✅ Esperado: «¡Gracias! Quedó marcado.» y aparece un **pin gris**. Si marcás el mismo otra vez: «Ya marcaste este lugar.». Con el **📱2** marcando cerca, el mismo rubro: la ficha dice «Marcado por 2 personas».

### MP-09 · Búsqueda

> Necesita la marca `busqueda`.

Tocá la **lupa** («Buscar lugares») y buscá:
- **«vete»**: aparecen las veterinarias.
- **«peluqueria»** (sin tilde): aparecen las peluquerías.
- **«zzzz»**: «No encontramos lugares con «zzzz».» y «¿Conocés uno? Marcalo en el mapa…», que lleva a «Marcar un lugar».

### MP-11 · Ayuda

Pestaña **Ayuda**.
✅ Esperado: la tarjeta del **911**, **«Veterinarias de urgencia»** con «abierto ahora», y el directorio (**«Refugios y protectoras»**, **«Grupos para difundir»**, **«Organismos»**) con **«Abrir»**.

---

## Ronda 7 · Privacidad (PR-01 a PR-06): ir mirando durante las otras rondas

No es una ronda aparte: **en cada pantalla de las rondas 4 a 6** fijate en esto, y al final anotá el resultado.

- **PR-01 · Teléfono**: en el 📱2, en ningún lugar (QR, SOS, avisos, chat, pedidos, turnos, cuidados, grupos, equipo) aparece el teléfono de A. La única excepción es el WhatsApp que A prendió a propósito en SO-06.
- **PR-02 · Primer nombre**: siempre «Rodri», nunca un apellido ni un correo.
- **PR-03 · Ubicación**: los SOS siempre corridos (SO-01) y la zona de avisos en una celda (SO-12).
- **PR-04 · Fotos sin GPS**: en el 📱2, mantené apretada una foto de un SOS → «Descargar imagen» → en la galería, **Detalles**: no tiene que tener ubicación. Repetilo con una foto de mascota, del chat y de un grupo, subidas desde un celular con el GPS de la cámara prendido.
- **PR-06 · Métricas**: en Supabase → Table Editor → `events`, ordenado por fecha: después de cada ronda tiene que haber eventos de lo que hiciste (por ejemplo `sos_follow`, `sos_poster`, `alert_zone_set`, `favorite_add`, `my_vet_set`, `search`, `tab_open`), **sin** correo ni nombre.

---

## Si algo falla

Anotá el **ID**, **qué esperabas** y **qué pasó**, y, si podés, una captura de pantalla. Va a la tabla «Registro de fallas» de [Casos de prueba](../19-casos-de-prueba.md) y se arregla.
