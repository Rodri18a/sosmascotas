# Casos de prueba a validar

> Armado el 28/10/2026 a partir de `PROGRESO.md`. Son pruebas **a mano**, con la app online, para confirmar lo que las pruebas automáticas no ven: avisos push, dos cuentas a la vez, el celular real y la privacidad entre personas.
>
> **Estado:** ⬜ sin probar · ✅ anda · ❌ falla (anotar qué pasó y el paso de `PROGRESO.md`) · ➖ no aplica todavía.

> 👉 **Paso a paso, botón por botón:** [Pruebas con dos teléfonos](guias/pruebas-paso-a-paso.md) (rondas de Equipo, Paseos y cuidados y Comunidad).

## Preparación

| Qué | Dónde |
|---|---|
| App de dev | https://sosmascota-dev.vercel.app (instalarla como app en el celular para que lleguen las push) |
| Portal de administración | https://sosmascota-admin.vercel.app |
| Página pública (QR, SOS, comercio) | https://sosmascota-web-dev.vercel.app |
| **Cuenta A** | La del dueño del proyecto: `admin` en el portal, dueña de «Pet Shop Ejemplo (catálogo)» (Plus) y de «Paseos y cuidados Ejemplo» (Plus, `supabase/seeds/paseador_ejemplo.sql`) |
| **Cuenta B** | Segunda cuenta de prueba, invitada a todas las marcas en beta. Ponerle otro nombre en Perfil (por ejemplo «Rodri») |
| **Visitante** | Ventana privada sin sesión |
| Datos de ejemplo | `mapa_ejemplo.sql`, `noticias_ejemplo.sql`, `tienda_ejemplo.sql`, `paseador_ejemplo.sql` (ver `CLAUDE.md`) |

Si a una cuenta no le llega el código de ingreso, se genera un enlace de un uso (ver la memoria del proyecto). Las push en la web llegan solo si se dio permiso de notificaciones en ese navegador.

**En todos los casos con dos personas, revisar además:** que nunca se vea el teléfono ni el correo del otro, que se vea solo el primer nombre y que ninguna ubicación sea exacta salvo que la persona la mande a propósito en un chat.

---

## 1. Cuentas y acceso (Fase 0)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| CU-01 | Ingreso con código | Ingresar con correo → poner el código de 6 números | Entra; la primera vez pide aceptar términos y privacidad | ✅ 28/10 |
| CU-02 | Ingreso con Google | «Seguir con Google» con un usuario de prueba de Google | Entra y vuelve a la app | ✅ 28/10 |
| CU-03 | Visitante que actúa | Sin sesión, tocar «Reportar», «Agregar mascota» o «Escribir por chat» | Pide ingresar y, al hacerlo, vuelve a la misma acción | ✅ 28/10 |
| CU-04 | Términos | Cuenta nueva | No deja seguir sin aceptar; se pueden leer los dos textos | ✅ 28/10 |
| CU-05 | Perfil | Ajustes → Perfil → cambiar nombre | Se guarda; en chats y reseñas se ve solo el primer nombre | ✅ 28/10 |
| CU-06 | Radio de avisos | Ajustes → cambiar el radio (1 a 20 km) | Se guarda y se respeta en el aviso de SOS (SO-09) | ✅ 28/10 |
| CU-07 | Cerrar sesión | Ajustes → Cerrar sesión | Vuelve a visitante; no queda nada privado a la vista (ni la copia sin internet) | ✅ 28/10 (después del arreglo) |
| CU-08 | Borrar mi cuenta | Con una cuenta descartable: Ajustes → Borrar mi cuenta | Pide confirmar; borra la cuenta, las mascotas y las fotos; no se puede volver a entrar con los datos viejos | ✅ 28/10 |
| CU-09 | PWA instalable | Android: «Instalar la app». iPhone: instrucciones de «Compartir → Agregar a inicio» | Se instala con el ícono propio; ya instalada no vuelve a ofrecerlo | ✅ 28/10 |
| CU-10 | Barra inferior | Recorrer Noticias · SOS · Mapa · Mascotas · Ayuda | El Mapa es el botón redondo del medio; cada pestaña abre lo suyo | ✅ 28/10 |
| CU-11 | Flecha para volver | Entrar a una pantalla por un enlace o un aviso | Tiene flecha y vuelve al Mapa o a la ficha | ✅ 28/10 |

## 2. Mascotas (Fase 0)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| MA-01 | Alta con foto | Mascotas → Agregar → especie, raza, foto con GPS | Se guarda; la foto se ve comprimida y **sin datos de ubicación** | ✅ 28/10 |
| MA-02 | Edición | Cambiar nombre, raza o foto | Se actualiza en la lista y en la ficha | ✅ 28/10 |
| MA-03 | Fila superior | Con 2 o más mascotas | Se elige una y filtra lo que se muestra | ✅ 28/10 |
| MA-04 | Límite del plan Gratis | Con `planes_usuario`: cargar una tercera mascota en Gratis | Avisa que el tope es 2 y ofrece Pro (D118) | ✅ 28/10 |

## 3. Chapita QR y contacto inverso (Fase 0)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| QR-01 | Etiqueta para el collar | Ficha → Chapita QR → «Descargar la etiqueta para el collar» | Baja un PNG con el QR y el nombre, para papel adhesivo mientras no haya chapita | ⬜ |
| QR-02 | Página pública | Escanear el QR con otro celular | Abre `/m/<código>` con foto, nombre, la nota y los datos elegidos; **sin teléfono** | ⬜ |
| QR-03 | Push del escaneo | Escanear el QR (con la ubicación compartida y sin compartirla) | Al dueño le llega «📍 Escanearon el QR de…»; en la app figura en «Últimos escaneos» | ⬜ |
| QR-04 | Avisar a mi familia | En la página del QR, completar el formulario | Al dueño le llega la push «💬 Alguien vio a…» y el aviso a la bandeja Avisos, con el consejo contra estafas | ⬜ |
| QR-05 | Anti-bots y límites | Mandar más de 5 avisos en una hora desde el mismo dispositivo | A partir del sexto lo frena con un mensaje claro | ⬜ |
| QR-06 | Cambiar el código | Ficha → Chapita QR → Cambiar código | El código viejo deja de funcionar y el nuevo anda | ⬜ |
| QR-07 | Perdida con QR | Con un SOS activo, escanear el QR | La página muestra «Estoy perdido 🆘» y enlaza al reporte | ⬜ |
| QR-08 | Chapita física sin activar | Portal → Chapitas → crear un lote → abrir `/m/<código>` de uno | «Activá esta chapita con la app» y el código | ⬜ |
| QR-09 | Activar la chapita | Abrir «Activar con la app» → elegir la mascota | Queda vinculada; el escaneo muestra la mascota | ⬜ |
| QR-10 | Desvincular | Chapita QR → Chapitas físicas → Desvincular | Pide confirmar; la página dice «Esta chapita ya no está activa»; no se puede volver a activar | ⬜ |
| QR-11 | Pedir una chapita | (`pedido_chapitas`) Chapita QR → Pedir una chapita → elegir la veterinaria | Queda pedida; se puede cancelar; el estado cambia cuando la veterinaria la marca | ⬜ |
| QR-12 | Entregar en la veterinaria | Modo comercio → Chapitas: punto de retiro → «Llegó» → «Entregada» | Al entregarla queda vinculada sola a la mascota | ⬜ |
| QR-13 | Sponsor en la página | Lote con sponsor (portal → Chapitas → Sponsors) | La página del QR muestra «Chapita donada por» con el logo, chico y abajo | ⬜ |
| QR-14 | Stock en la veterinaria | Portal → Stock → asignar chapitas; modo comercio → «Entregar el N.º … de mi stock» | Se descuenta del stock y queda vinculada | ⬜ |

## 4. SOS: perdidas y encontradas (Fase 0)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| SO-01 | Reportar perdida | Ficha → «Se perdió» → foto y ubicación tocando el mapa → publicar | Aparece en el mapa **corrida 150–200 m** del punto real | ⬜ |
| SO-02 | Reportar encontrada | SOS → Reportar → Encontrada | Aparece con su pin propio | ⬜ |
| SO-03 | Mapa por zona | Mover el mapa | Carga solo los reportes de la zona visible | ⬜ |
| SO-04 | Detalle y compartir | Abrir un reporte → Compartir | La página `/s/<id>` se abre sin sesión, con vista previa al compartir | ⬜ |
| SO-05 | Avisar al dueño | Con B: «Avisar al dueño» en el reporte de A | A recibe el aviso con los datos que dejó B; B nunca ve el teléfono de A | ⬜ |
| SO-06 | WhatsApp opcional | Activar el WhatsApp directo en el reporte | Muestra la advertencia; por defecto está apagado | ⬜ |
| SO-07 | ¡Apareció! | Marcar «¡Apareció!» | Se archiva, sale del mapa y pregunta «¿Compartís la buena noticia?» | ⬜ |
| SO-08 | Reportar publicación | Con 3 cuentas distintas, reportar el mismo SOS | Se oculta solo y aparece en la moderación del portal | ⬜ |
| SO-09 | Push a la zona | B con la zona guardada cerca de A; A publica un SOS | A B le llega «🐾 Se perdió un perro cerca tuyo» | ⬜ |
| SO-10 | Tope de 3 por día | Publicar un cuarto SOS en el día | Lo frena con un mensaje claro | ✅ 29/10 |
| SO-11 | Seguir un reporte | Con B: «Seguir este reporte»; A marca «¡Apareció!» | A B le llega «¡<nombre> volvió a casa!», una sola vez | ⬜ |
| SO-12 | Zona aproximada | Ajustes → borrar la zona y guardarla de nuevo | Se guarda el centro de la celda, no el punto exacto; borrada no vuelve sola | ⬜ |
| SO-13 | Imprimir cartel (D119) | Reporte activo (propio o de otra persona) → «Imprimir cartel» → escribir dónde la vieron → «Armar el cartel». Repetir con una encontrada | Baja un PDF A4: «SE BUSCA · nombre» en rojo o «SE ENCONTRÓ · ¿Es tuyo?», foto, datos, dónde la vieron y QR. **Sin teléfono ni recompensa.** Escanear el QR abre la página del reporte y **no** le llega aviso al dueño hasta que alguien completa «Avisar» | ✅ 29/10 |
| SO-14 | Sin recompensa (D119) | SOS → Reportar | El formulario ya no pide recompensa; los reportes y la web pública no la muestran | ⬜ |
| SO-15 | Una perdida por mascota | Con un reporte de perdida abierto, ir a la ficha de esa mascota | En vez de «Se perdió: reportarla» aparece «Ver su reporte de perdida»; la base tampoco deja crear otro (`ya_reportada`) | ⬜ |

## 5. Mapa, lugares y búsqueda (Fases 0 y 1)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| MP-01 | Chips de rubros | Tocar Salud, Tiendas, Cuidado, Salidas y Refugios | Sin chips, todo; con alguno, solo lo elegido | ⬜ |
| MP-02 | Filtros | Distancia, abierto ahora, especie, coloca microchip, solo mis favoritos | Cada filtro deja solo lo que corresponde | ⬜ |
| MP-03 | Abierto ahora | Ver una veterinaria a distintas horas y en un día especial | Abierta o cerrada según la hora de Uruguay y los feriados | ⬜ |
| MP-04 | Clusters | Alejar el mapa | Se agrupan con un número; al tocarlo acerca; los SOS nunca se agrupan | ⬜ |
| MP-05 | Lista y «Sin local» | Cambiar a Lista y a Sin local | La lista arranca con perdidos y encontrados; después abiertos, sin horario y cerrados | ⬜ |
| MP-06 | Ficha de un lugar | Abrir una veterinaria | Horario, Llamar, WhatsApp, Cómo llegar, web e insignias | ⬜ |
| MP-07 | Favoritos y «Fui» | Marcar favorito, «Fui» y «Es mi veterinaria» | Se guardan; solo puede haber una «mi veterinaria» | ⬜ |
| MP-08 | Marcar un lugar | «Marcar un lugar» con rubro y punto | Pin gris; con varias marcas cerca, «Marcado por N personas» | ⬜ |
| MP-09 | Búsqueda | (`busqueda`) Lupa → buscar «vete», «peluqueria» sin tilde y algo que no existe | Encuentra por nombre y por sinónimos; sin resultados ofrece «Marcar un lugar» | ⬜ |
| MP-10 | Mapa nativo | ➖ Espera la clave de Google Cloud (1.2.1) | — | ➖ |
| MP-11 | Ayuda | Pestaña Ayuda | Tarjeta del 911, veterinarias de urgencia con «abierto ahora» y el directorio | ⬜ |

## 6. Chat (Fase 1)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| CH-01 | Chat desde un SOS | Con B: «Escribir por chat» en el SOS de A | A ve el mensaje al instante; B ve «Familia de <mascota>» | ⬜ |
| CH-02 | Chat con un negocio | Con B: «Escribir por chat» en el Pet Shop Ejemplo | B ve el nombre del negocio y A, en modo comercio, el de B | ⬜ |
| CH-03 | Foto | Mandar una foto con GPS | Llega sin datos de ubicación | ⬜ |
| CH-04 | Ubicación | Mandar la ubicación | Pide confirmar antes de mandar la exacta | ⬜ |
| CH-05 | No leídos | Recibir mensajes con la app en otra pestaña | El botón «Mensajes» muestra la cantidad | ⬜ |
| CH-06 | Bloquear | Bloquear a la otra persona | La conversación se corta para los dos; se puede desbloquear | ⬜ |
| CH-07 | Reportar mensaje | Reportar un mensaje con motivo | Aparece en la moderación del portal | ⬜ |
| CH-08 | Estafas | Mandar «pasame plata por transferencia» o «decime el código» | Aparece la alerta de estafa en el mensaje | ⬜ |

## 7. Libreta, recordatorios y hogar (Fase 1)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| LI-01 | Libreta | Cargar una vacuna con próxima dosis | Semáforo con color **y texto** («Faltan 5 días») | ✅ 23/10 |
| LI-02 | Recordatorio de medicación | Cada X horas, con la app abierta | Llega el aviso a la hora | ✅ 23/10 |
| LI-03 | «Ya se la di» | Marcar la toma y deshacer | Queda en el historial; una toma marcada no avisa | ✅ 23/10 |
| LI-04 | Recordatorio con la app cerrada | ➖ Espera los ajustes de Android (1.1.1) | — | ➖ |
| LI-05 | RENAC | (`renac`) Perro de más de 90 días → «Cómo registrarla» → «Ya la registré» | Tarjeta en la ficha, guía y enlace oficial | ⬜ |
| LI-06 | Historial en PDF | (Pro) Libreta → PDF | Se arma un PDF para imprimir o mandar | ⬜ |
| LI-07 | Sin internet | Abrir la ficha, la libreta y el QR en modo avión | Se ven los últimos datos leídos | ⬜ |
| HO-01 | Invitar al hogar | A: Mi hogar → invitar → B abre el enlace | B ve las mascotas de A como «Compartida por…» | ⬜ |
| HO-02 | «Ya se la di» compartido | B marca una toma | A la ve como «Marcada por <B>» | ⬜ |
| HO-03 | Permisos del hogar | Con B, intentar reportar SOS, borrar la mascota o cambiar el QR | No puede: es solo del dueño | ⬜ |
| HO-04 | Tareas | Crear «Paseo» asignado a B; B la marca hecha | Queda a nombre de B | ⬜ |
| HO-05 | Cuidador temporal | Invitar por 2 días con una sola mascota | Ve solo esa mascota y pierde el acceso al vencer | ⬜ |
| HO-06 | Prueba de Familia | (`planes_usuario`) Invitar al hogar desde Gratis | Empiezan los 30 días de prueba de Familia | ⬜ |

## 8. Comercios: alta, modo comercio y reseñas (Fase 1)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| CO-01 | Alta de negocio | Ajustes → Mi negocio → alta con rubro, punto o zona, horario | Aparece al instante como «no verificado» | ⬜ |
| CO-02 | Reclamar un lugar | Ficha de un lugar sin dueño → «¿Es tu negocio? Reclamalo» | Queda pendiente en el portal → Comercios | ⬜ |
| CO-03 | Verificación | Pedir ✔️ con RUT → aprobar desde el portal | La ficha muestra ✔️; el RUT nunca se ve en público | ⬜ |
| CO-04 | Modo comercio | Entrar y «Volver al modo dueño» | Barra Panel · Agenda · Catálogo · Pedidos · Negocio | ⬜ |
| CO-05 | Panel | Abrir la ficha y tocar contactos con B | Los contadores suben (aperturas, contactos, favoritos) | ⬜ |
| CO-06 | Pantalla grande | Abrir el modo comercio en la compu | Menú al costado y panel en dos columnas; «Para atender» arriba | ⬜ |
| CO-07 | Fotos | Subir fotos en Básico y en Plus | Tope de 3 y de 20 | ⬜ |
| RE-01 | Reseña sin contacto | Con B, intentar reseñar un comercio sin haberlo contactado | No lo deja | ⬜ |
| RE-02 | Reseña con contacto | B toca «Fui» o escribe por chat → reseña con estrellas | Se publica con el primer nombre; se puede editar | ⬜ |
| RE-03 | Responder | A responde desde el panel | Una sola respuesta, visible en la ficha | ⬜ |
| RE-04 | Propia | A intenta reseñar su propio negocio | No lo deja | ⬜ |

## 9. Catálogo, servicios y pedidos (Fases 2 y 3)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| PE-01 | Catálogo a la vista | Visitante → Pet Shop Ejemplo → «Ver catálogo» | Se ve sin sesión; «Agregar» pide ingresar | ⬜ |
| PE-02 | Carrito | B agrega productos con cantidades, elige pago y entrega | Subtotal + envío = total; envío gratis desde $ 3.000 | ⬜ |
| PE-03 | Hacer pedido | B → «Hacer pedido» | Aparece en «Mis pedidos» de B y en Pedidos del comercio **en vivo** | ⬜ |
| PE-04 | Push al comercio | B hace un pedido | A A le llega la push del pedido nuevo | ⬜ |
| PE-05 | Avanzar el pedido | A: Preparando → Listo → Entregado | B ve cada cambio en vivo y recibe una push por estado | ⬜ |
| PE-06 | Cancelar | B cancela mientras es nuevo; en otro, A lo cancela | Avisa a la otra parte; B no puede cancelar uno ya en preparación | ⬜ |
| PE-07 | Pedido por WhatsApp | B → «Enviar pedido por WhatsApp» | Se guarda y abre WhatsApp con el resumen, sin guardar la dirección | ⬜ |
| PE-08 | Privacidad | A mira el pedido | Ve solo el primer nombre de B | ⬜ |
| PE-09 | Productos | A: alta, edición, sin stock y foto de un producto | La ficha muestra los cambios; sin stock no se puede agregar | ⬜ |
| PE-10 | Cargar desde planilla | Catálogo → «Cargar desde una planilla» → pegar desde Excel con una fila mala | Muestra nuevos, actualizados y la fila con error con su número | ⬜ |
| PE-11 | Servicios | A carga un servicio; B toca «Consultar» | Se ve en la ficha; abre chat o WhatsApp con el servicio | ⬜ |
| PE-12 | Página pública | Modo comercio → «Compartir mi página» | La página muestra fotos, servicios, catálogo y horario; **sin dueño, RUT ni contactos privados** | ⬜ |

## 10. Agenda de turnos (Fase 3, 3.1)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| AG-01 | Configurar | A en un comercio con agenda: horarios, duración, bloqueos | Se guardan | ⬜ |
| AG-02 | Reservar | B → «Reservar turno» → servicio, día, hora, mascota | Solo ofrece horarios libres; aparece en la Agenda del comercio en vivo | ⬜ |
| AG-03 | Confirmar o rechazar | A confirma uno y rechaza otro | B recibe la push de cada uno | ⬜ |
| AG-04 | Cancelar | B cancela con más de 2 h y con menos | Con más de 2 h, sí; con menos, no | ⬜ |
| AG-05 | Recordatorio | Turno para mañana | El día anterior a las 18:00 llega la push | ⬜ |
| AG-06 | Doble reserva | B y otra cuenta reservan el mismo horario a la vez | Solo una lo consigue | ⬜ |

## 11. Paseadores, hoteles y cuidadores (Fase 3, 3.3)

Antes: cargar `supabase/seeds/paseador_ejemplo.sql`.

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| CU3-01 | Ajustes del prestador | A en «Paseos y cuidados Ejemplo» → Agenda → configurar qué ofrece, el lugar por día y las condiciones | Se guardan | ⬜ |
| CU3-02 | Pedir | B → ficha → «Contratar» → servicio, días, momento, mascotas (hasta 5) y nota | Aparece en Paseos y estadías del prestador y en «Para atender», en vivo | ⬜ |
| CU3-03 | Push al prestador | B pide | A A le llega la push | ⬜ |
| CU3-04 | Aceptar | A acepta | Se abre el chat entre los dos; a B le llega la push | ⬜ |
| CU3-05 | Rechazar | A rechaza otro pedido | B lo ve rechazado y recibe la push | ⬜ |
| CU3-06 | Lugar lleno | Con lugar para 3, aceptar estadías hasta llenar un día | No deja pedir ni aceptar más para ese día | ⬜ |
| CU3-07 | Cancelar | B cancela el día anterior y el mismo día | El día anterior, sí; el mismo día, no | ⬜ |
| CU3-08 | Privacidad | A mira el pedido | Primer nombre, mascotas y nota; **nunca un contacto** | ⬜ |
| CU3-09 | Mis paseos y estadías | B → Ajustes o menú | Lista con el estado de cada pedido | ⬜ |

## 12. Comunidad (Fase 3, 3.4)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| GR-01 | Entrar a un grupo | Noticias → Comunidad → Grupos → «Perros» → unirme | Queda como integrante | ⬜ |
| GR-02 | Publicar | A publica una pregunta con foto | Se ve en el grupo; la foto va sin EXIF | ⬜ |
| GR-03 | Venta y cruza | Publicar «vendo cachorros» o «busco macho para cruza» | La base lo frena con un mensaje claro | ⬜ |
| GR-04 | Comentar | B comenta la publicación de A | Se ve con el primer nombre de B | ⬜ |
| GR-05 | Reportar | Reportar una publicación con 3 cuentas | Se oculta y aparece en el portal → Moderación | ⬜ |
| GR-06 | Saludo | B → «Saludar» a A | A lo ve en Saludos | ⬜ |
| GR-07 | Aceptar el saludo | A acepta | Se abre un chat con solo el primer nombre | ⬜ |
| GR-08 | Grupo de raza | Mascota de una raza sin grupo | El grupo de la raza se crea solo | ⬜ |
| GR-09 | Portal | Portal → Grupos | Lista los grupos y deja moderarlos | ⬜ |

## 13. Equipo de la empresa (Fase 3, 3.5)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| EQ-01 | Invitar | A: Modo comercio → Panel → Equipo → «Invitar a alguien» | Da un enlace y un código; queda en «Invitaciones sin usar» | ⬜ |
| EQ-02 | Sumarse con el enlace | B abre el enlace → «Unirme al equipo» | Entra al modo comercio del negocio | ⬜ |
| EQ-03 | Sumarse con el código | B: Mi negocio → «Tengo un código de equipo» | Igual que EQ-02 | ⬜ |
| EQ-04 | Vista del empleado | B en el modo comercio | Pestaña **Equipo** en vez de Negocio; no ve plan, estadísticas, reseñas, tránsito ni la configuración de agenda, cuidados, catálogo, socios, descuentos, pack o retiro | ⬜ |
| EQ-05 | El empleado trabaja | B carga un producto y pasa un pedido a Preparando | Se guarda; a quien pidió le llega la push | ⬜ |
| EQ-06 | Avisos al equipo | Otra cuenta hace un pedido | La push les llega a A y a B | ⬜ |
| EQ-07 | Chat del comercio | B intenta abrir el chat del comercio | No puede: sigue siendo del dueño | ⬜ |
| EQ-08 | Sacar del equipo | A → «Sacar del equipo» a B | B deja de ver el negocio | ⬜ |
| EQ-09 | Dejar el equipo | B → «Dejar el equipo» | Sale y A lo ve en la lista | ⬜ |
| EQ-10 | Sin Plus | Bajar el negocio a Básico desde el portal | El panel avisa que el equipo es del plan Plus; B deja de entrar hasta que vuelva | ⬜ |
| EQ-11 | Tope de 5 | Invitar a una sexta persona | Lo frena | ⬜ |
| EQ-12 | Código vencido | Abrir un enlace ya usado o anulado | «Este código no existe, ya se usó o venció» | ⬜ |

## 14. Veterinarias, adopción, eventos y noticias (Fase 2)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| VE-01 | Compartir con mi veterinaria | B → ficha → compartir con su veterinaria | La veterinaria ve nombre, especie, primer nombre y próximo control; **nunca el teléfono** | ⬜ |
| VE-02 | Recordar desde la veterinaria | A en la veterinaria → «Recordar» | B recibe el recordatorio; tope de 3 por semana | ⬜ |
| VE-03 | Busco veterinaria | B → «Sí, quiero propuestas»; A manda una propuesta | A ve solo cantidades (grupos de 5 o más); al aceptar, la mascota pasa a socia | ⬜ |
| AD-01 | Publicar en adopción | Particular: publicar | Sin dinero y con 2 activas como máximo | ⬜ |
| AD-02 | Solicitud | B pide adoptar → proceso por etapas → compromiso | Compatibilidad, etapas y seguimiento a 7, 30 y 90 días | ⬜ |
| AD-03 | Hogar de tránsito | B se ofrece; un refugio verificado acepta | Se abre el chat; el refugio ve primer nombre y barrio | ⬜ |
| AD-04 | Pack adopción | Quien adoptó usa el código de 6 en un comercio | El comercio lo valida | ⬜ |
| EV-01 | Evento | Comercio verificado publica un evento | Se ve en el mapa (anillo coral) y en Comunidad | ⬜ |
| EV-02 | Denuncia de maltrato | Denunciar con foto | Privada: solo quien denuncia y la administración | ⬜ |
| NO-01 | Noticias | Abrir Noticias y filtrar por especie | Las patrocinadas dicen «Promocionado · marca» | ✅ 21/10 |
| NO-02 | Reacciones | Reaccionar a una novedad | Una por persona; se ven solo los totales | ✅ 21/10 |
| NO-03 | Reencuentro compartido | Resolver un SOS y compartir la buena noticia | Aparece en Comunidad | ✅ 21/10 |

## 15. Planes y estadísticas (Fase 2)

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| PL-01 | Pedir un plan de comercio | Panel → Tu plan → pedir Plus | Llega al portal → Planes | ⬜ |
| PL-02 | Registrar el pago | Portal → Planes → crear plan y registrar el pago | El comercio pasa a Plus | ⬜ |
| PL-03 | Vencimiento | Plan vencido | 7 días «con atraso» y después vuelve a Básico | ⬜ |
| PL-04 | Plan de persona | (`planes_usuario`) Ajustes → Mi plan → pedir Pro | Llega al portal → Planes → Personas | ⬜ |
| PL-05 | Temas Pro | Con Pro, elegir Faro, Vecinos o Pop | Cambia el tema; al vencer, vuelve a Cielo | ⬜ |
| PL-06 | Tamaño de letra y mis filtros | (Pro) Ajustes → letra Grande; mapa → «Guardar como mis filtros» | Se aplica y se recuerda | ⬜ |
| ES-01 | Estadísticas | Panel → «Ver estadísticas» | Este mes contra el anterior, 12 semanas y mes a mes | ⬜ |
| ES-02 | Reporte mensual | El día 1 | Llega el reporte del mes | ⬜ |

## 16. Portal de administración

| ID | Caso | Pasos | Resultado esperado | Estado |
|---|---|---|---|---|
| AD-P01 | Solo con rol | Entrar con B (sin rol) | No deja pasar | ⬜ |
| AD-P02 | Panel | Cambiar el período y la zona | Los KPIs cambian | ⬜ |
| AD-P03 | Moderación | Aprobar y eliminar con motivo; advertir y bloquear 30 días | Un bloqueo frena SOS, mensajes y chats nuevos | ⬜ |
| AD-P04 | Comercios | Verificar, RENAC, reclamos y Socio Fundador | Se ven en la ficha | ⬜ |
| AD-P05 | Lugares | Carga manual y «Sin reclamar con tracción» | Lista con personas y aperturas | ⬜ |
| AD-P06 | CRM | Prospecto → mover de etapa → nota → próximo contacto | Se guarda | ⬜ |
| AD-P07 | Demanda sin cubrir | Buscar algo sin resultados en la app | Aparece en el Panel del portal | ⬜ |
| AD-P08 | Propuestas | Propuestas → «Descargar para imprimir» | Página con la paleta Cielo para guardar como PDF | ⬜ |
| AD-P09 | Roles y zonas | Dar rol de moderación con una zona | Esa persona ve solo su zona y su sección | ⬜ |
| AD-P10 | Auditoría | Hacer cualquier acción | Queda registrada | ⬜ |
| AD-P11 | Funcionalidades | `funcionalidades.py` → apagar una marca | La app muestra «Todavía no está disponible» y vuelve sola al prenderla | ⬜ |

## 17. Privacidad y seguridad (en todo)

| ID | Caso | Cómo revisarlo | Resultado esperado | Estado |
|---|---|---|---|---|
| PR-01 | Teléfono del dueño | Recorrer QR, SOS, chat, pedidos, turnos, cuidados, grupos y equipo con la otra cuenta | Nunca aparece | ⬜ |
| PR-02 | Primer nombre | Los mismos lugares | Solo el primer nombre, nunca el apellido ni el correo | ⬜ |
| PR-03 | Ubicación | Mapa de SOS y zona de avisos | Siempre aproximada | ⬜ |
| PR-04 | Fotos sin EXIF | Bajar una foto subida (mascota, SOS, chat, grupo) y mirar sus datos | Sin GPS | ⬜ |
| PR-05 | Seguridad de la base | `python -I -X utf8 supabase/tests/rls_test.py` | Todo OK | ✅ 28/10 |
| PR-06 | Métricas | Hacer acciones y mirar `events` en Supabase | Un evento anónimo por cada acción | ⬜ |

## Registro de fallas

| Fecha | ID | Qué pasó | Paso de PROGRESO | Arreglado |
|---|---|---|---|---|
| 28/10 | CU-05 | Mejora (no es falla): en «Mi perfil» el nombre se ve, pero no se puede cambiar; se cambia en Ajustes → primera fila ✏️. Se buscó primero en «Mi perfil». Propuesta: un ✏️ al lado del nombre en «Mi perfil» que abra el mismo cuadro «Tu nombre» | 0.8.3 | ✅ 28/10: ✏️ al lado del nombre en «Mi perfil», validado en el celular |
| 28/10 | CU-07 | Después de cerrar sesión, el botón **Mascotas** de la barra de abajo no responde: al tocarlo no pasa nada (ni cambia de pestaña ni pide ingresar). Más tarde, en otro intento, al tocarlo vuelve siempre al Mapa. Quedó sin validar el resto de CU-07: Mensajes y Avisos sin sesión, y la copia sin internet (modo avión). Sospecha: la pestaña recuerda la última pantalla de antes de cerrar sesión (por ejemplo la ficha `/mascotas/<id>`, que pide cuenta) y la redirección la frena; la pestaña `/mascotas` sola sí está permitida al visitante (`router.dart`) | 0.8.3 | ✅ 28/10: al cerrar sesión se descarta toda la navegación y arranca en el Mapa (`router.dart`; prueba en `navegacion_test.dart`). Validado en el celular |
| 28/10 | CU-08 | Funciona, pero se probó con la cuenta principal (rodrigo18a@gmail.com): se perdieron el rol admin, el plan Pro, las invitaciones a las betas y las mascotas, y el Pet Shop Ejemplo quedó sin dueño. Restaurado a mano en dev (rol, plan, 24 invitaciones y `tienda_ejemplo.sql`); las mascotas hay que cargarlas de nuevo. **Mejora propuesta:** si la cuenta tiene negocios o un rol del equipo, que «Borrar mi cuenta» lo diga antes de confirmar (los negocios quedan sin dueño) | 0.8.3 | ⬜ |
| 28/10 | MA-04 | Observación: después de subir una versión nueva, la app instalada siguió mostrando el texto viejo hasta recargar la página en Chrome. **Mejora a evaluar:** avisar «Hay una versión nueva · Actualizar» cuando cambia la compilación, para que las personas no se queden con una versión vieja | 0.8.3 | ⬜ |
| 28/10 | QR-01 | Propuesta del dueño: descargar solo el QR sirve poco sin chapita; lo útil es un **cartel A4** de mascota perdida con foto, datos, zona y QR. Hecho como «Imprimir cartel» en los SOS (D119, casos SO-13 y SO-14), sin recompensa; el QR suelto queda como etiqueta para el collar. Idea relacionada para después: sumarse al hogar con un QR (16-ideas-futuras, I4) | 0.8.3 | ✅ 28/10, validado en el celular el 29/10 |
| 28/10 | SO-13 | El texto del recuadro del QR («No hace falta la app… Nunca pagues ni cobres nada») no iba con lo acordado: hablaba de plata y no explicaba que escanear muestra el reporte y que se avisa recién al dejar un mensaje. Reescrito: «Vas a ver su reporte y podés dejarle un mensaje a su familia… Como comunidad, la ayudamos a volver a casa.» (29/10: «comunidad» en vez de «vecinos», también en el pie) | 0.8.3 | ✅ 28/10, validado en el celular el 29/10 |
| 29/10 | SO-15 | Se pudo reportar dos veces como perdida la misma mascota. Arreglado: la base no deja dos reportes de perdida abiertos (activo u oculto) de la misma mascota (migración `sos_una_perdida_por_mascota`, con índice único; el repetido que había en dev quedó archivado) y la ficha muestra «Ver su reporte de perdida». Caso nuevo en `rls_test.py` | 0.8.3 | ✅ 29/10 (falta validar en el celular) |
