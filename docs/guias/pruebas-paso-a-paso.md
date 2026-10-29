# Pruebas paso a paso con dos teléfonos

> Armada el 28/10/2026 para recorrer las rondas 1 a 3 de [Casos de prueba](../19-casos-de-prueba.md) (Equipo, Paseos y cuidados, Comunidad) **tocando botón por botón**. Los nombres entre «comillas» son los textos exactos que aparecen en la app.
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
5. Solo en el **📱2**: **☰** (arriba a la izquierda) → tocá tu nombre arriba de todo (abre **«Mi perfil»**) → cambiá el nombre a «Rodri» → guardar.

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

## Si algo falla

Anotá el **ID**, **qué esperabas** y **qué pasó**, y, si podés, una captura de pantalla. Va a la tabla «Registro de fallas» de [Casos de prueba](../19-casos-de-prueba.md) y se arregla.
