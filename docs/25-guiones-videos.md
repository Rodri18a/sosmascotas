# 25 · Guiones de videos cortos

Guiones (lo que se dice), qué se muestra en pantalla y la descripción para publicar, uno por funcionalidad. Pensados para Reels, TikTok y YouTube Shorts, y para usar en el lanzamiento (0.8.8–0.8.9).

> Armado el 13/11/2026. Si cambia una función, revisar su guion antes de grabarlo.

## Cómo grabarlos

- **Formato:** vertical 9:16 (1080 × 1920), de 20 a 40 segundos. Los primeros 2 segundos son el gancho: si no engancha ahí, se pasa.
- **Subtítulos siempre:** la mayoría los mira sin sonido. El texto en pantalla va en negrita, corto y en voseo.
- **Imagen:** grabación de pantalla de la app (dev, con los ejemplos de `supabase/seeds/`) más tomas reales del perro o el gato. Ami y Mishi abren y cierran (guía de marca: Ami saluda y celebra, Mishi asoma y observa).
- **Privacidad en la grabación:** nada de teléfonos, correos ni direcciones reales en pantalla. Usar cuentas y mascotas de prueba.
- **No prometer lo que no está:** mientras no estén las apps en las tiendas (1.1), el cierre es **«Entrá a huellamy.com»**, no «descargala». Antes de publicar cada video, revisar que su funcionalidad gradual esté prendida en producción (`supabase/funcionalidades.py listar`).
- **Cierre fijo (3 s):** logo de Huellamy con Ami y Mishi + «huellamy.com» + «Hecho en Pando, Uruguay».
- **Tono:** cálido, simple y cercano, sin infantilizar. En los videos de SOS, sereno: acompaña, no asusta.

**Hashtags base** (sumar 3–5 propios de cada video): `#Huellamy #Pando #Canelones #Uruguay #Mascotas #Perros #Gatos`

## Índice

| # | Video | Para | Duración |
|---|---|---|---|
| 1 | Huellamy en 30 segundos | Dueños | 30 s |
| 2 | Se perdió tu mascota | Dueños | 35 s |
| 3 | Encontré una mascota | Todos | 30 s |
| 4 | Tu número nunca se muestra | Dueños | 25 s |
| 5 | La chapita QR | Dueños | 35 s |
| 6 | El cartel «Se busca» en un toque | Todos | 25 s |
| 7 | El mapa | Dueños | 30 s |
| 8 | Urgencias | Dueños | 25 s |
| 9 | Libreta y recordatorios | Dueños | 30 s |
| 10 | Hogar compartido | Familias | 30 s |
| 11 | Adopción y hogar de tránsito | Todos | 30 s |
| 12 | Turnos y pedidos | Dueños | 30 s |
| 13 | Paseos y estadías | Dueños | 30 s |
| 14 | Huellamy Comercios: tu ficha en el mapa | Comercios | 35 s |
| 15 | Catálogo, agenda y pedidos | Comercios | 35 s |
| 16 | Cómo te va + Socios Fundadores | Comercios | 30 s |

---

## 1. Huellamy en 30 segundos

**Objetivo:** presentar la app. Es el video para fijar en el perfil.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Ami saluda con la patita, Mishi asoma. Texto: **«Todo para tu mascota, en un mapa»** | «¿Tenés perro o gato en Pando? Esto es para vos.» |
| 3–10 s | El mapa con pines de veterinarias, pet shops y paseadores | «Huellamy junta en un mapa todo lo que tu mascota necesita: veterinarias, pet shops, paseadores, guarderías y lugares que aceptan mascotas.» |
| 10–17 s | Pestaña SOS con un aviso de perdido | «Si se pierde, publicás el aviso y les llega a los vecinos de la zona.» |
| 17–23 s | Chapita QR + recordatorio «Ya se la di» | «Tiene su chapita QR y sus vacunas y remedios al día, con recordatorios.» |
| 23–27 s | Texto: **«Lo que hace a su seguridad y su salud, gratis»** | «Y lo que hace a su seguridad y su salud es gratis. Siempre.» |
| 27–30 s | Cierre fijo | «Entrá a huellamy.com.» |

**Descripción:**
> Veterinarias, pet shops, paseadores, mascotas perdidas y encontradas, la chapita QR y los recordatorios de salud: todo en un mapa 🐶🐱
> Lo que hace a la seguridad y la salud de tu mascota es gratis. Arrancamos en Pando 💙
> 👉 huellamy.com

`#AppParaMascotas #MascotasPerdidas #Veterinaria`

---

## 2. Se perdió tu mascota

**Objetivo:** mostrar que publicar un SOS es rápido y llega a los vecinos.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Collar vacío en el piso / portón abierto. Texto: **«¿Se te perdió?»** | «Si tu mascota se pierde, cada minuto cuenta.» |
| 3–12 s | SOS → «Se perdió» → elegir la mascota (los datos y la foto se cargan solos) | «En Huellamy tocás SOS, elegís a tu mascota y sus datos y su foto ya están cargados.» |
| 12–18 s | Marcar en el mapa dónde se perdió (arranca donde estás) | «Marcás dónde se perdió. Se publica una zona aproximada, nunca tu dirección.» |
| 18–25 s | Celular de un vecino recibe la notificación | «El aviso les llega a los vecinos que están cerca, al instante.» |
| 25–31 s | Botón «¡Apareció!» + Ami festejando | «Y cuando vuelve a casa, marcás "¡Apareció!" y se avisa a todos los que la estaban buscando.» |
| 31–35 s | Cierre fijo. Texto: **«Gratis. Siempre.»** | «Publicar un SOS es gratis. Siempre.» |

**Descripción:**
> Si tu mascota se pierde, publicá el aviso en Huellamy: les llega a los vecinos de la zona, sin mostrar tu dirección ni tu teléfono 🆘
> Y cuando aparece, avisás a todos con un toque. Gratis, siempre.
> 👉 huellamy.com

`#PerroPerdido #GatoPerdido #MascotasPerdidasUruguay #SeBusca`

---

## 3. Encontré una mascota

**Objetivo:** que cualquiera sepa qué hacer si encuentra un animal, aunque no tenga cuenta.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Perro suelto en la vereda mirando a cámara. Texto: **«¿Lo encontraste?»** | «¿Encontraste un perro o un gato en la calle?» |
| 3–10 s | Mapa → filtro «Perdidos y encontrados» → aviso parecido | «Fijate en el mapa de Huellamy si alguien lo está buscando.» |
| 10–18 s | Botón «Avisar al dueño» → mensaje, nombre y foto | «Si está, tocás "Avisar al dueño" y dejás un mensaje. No necesitás cuenta.» |
| 18–25 s | SOS → «Encontré». Texto: **«Guardate una seña sin publicar»** | «Si no está, publicás que lo encontraste. Un consejo: guardate una seña sin publicar para saber que es su familia de verdad.» |
| 25–30 s | Cierre fijo | «Entre todos, vuelven a casa.» |

**Descripción:**
> ¿Encontraste una mascota? Buscala en el mapa de Huellamy y avisale a su familia en un minuto, sin crear cuenta 🐾
> Si nadie la busca todavía, publicá que la encontraste (y guardate una seña para confirmar quién es el dueño).
> 👉 huellamy.com

`#MascotaEncontrada #PerroEncontrado #AdoptaNoCompres`

---

## 4. Tu número nunca se muestra

**Objetivo:** explicar el contacto inverso y el aviso contra estafas. Diferencial fuerte frente a los grupos de Facebook.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Mano tapando un número de teléfono en un cartel de papel. Texto: **«¿Tu número en un cartel?»** | «Poner tu número en un aviso de mascota perdida atrae estafas.» |
| 3–12 s | Formulario «Avisar al dueño» desde el lado de quien la vio | «En Huellamy, quien vio a tu mascota te deja un aviso con su contacto.» |
| 12–19 s | Bandeja «Avisos» del dueño, con el recordatorio «Nunca pagues por adelantado» | «Te llega a vos, y vos decidís a quién contestar. Tu número no lo ve nadie.» |
| 19–25 s | Texto: **«Nunca pagues por adelantado para recuperar a tu mascota»** + cierre | «Y acordate: nunca pagues por adelantado para recuperar a tu mascota.» |

**Descripción:**
> En Huellamy tu teléfono y tu dirección nunca se publican 🔒 Quien vio a tu mascota te deja su contacto y vos decidís a quién responder.
> ⚠️ Nunca pagues por adelantado para recuperar a tu mascota.
> 👉 huellamy.com

`#Privacidad #Estafas #MascotasPerdidas`

---

## 5. La chapita QR

**Objetivo:** mostrar qué pasa cuando alguien escanea la chapita.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Primer plano de la chapita en el collar de Ami (o de un perro real) | «Esta chapita puede traer a tu mascota de vuelta.» |
| 3–10 s | Alguien la escanea con la cámara del celular, sin app | «Quien la encuentra la escanea con la cámara del celular. No necesita ninguna app.» |
| 10–17 s | Página pública: foto, nombre, cartel «Estoy perdido 🆘», «Avisar a mi familia» | «Ve su foto, su nombre y, si está perdida, el cartel de SOS. Con un botón te avisa y te comparte dónde está.» |
| 17–23 s | Notificación al dueño: «Escanearon la chapita de Toby» | «A vos te llega el aviso al instante. Tu número y tu dirección no se muestran nunca.» |
| 23–31 s | App → Chapita QR → descargar / imprimir; «Activar chapita» | «El QR lo descargás o lo imprimís gratis, o activás una chapita física en un toque.» |
| 31–35 s | Cierre fijo | «Huellamy. Que siempre vuelva a casa.» |

**Descripción:**
> La chapita QR de Huellamy: quien encuentra a tu mascota la escanea con la cámara, ve su foto y te avisa al instante 🏷️
> Tu número y tu dirección no se muestran nunca. El QR es gratis.
> 👉 huellamy.com

`#ChapitaQR #PlaquitaParaPerros #IdentificacionMascotas`

---

## 6. El cartel «Se busca» en un toque

**Objetivo:** mostrar el cartel A4 para imprimir y que cualquier vecino puede armarlo.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Cartel pegado en una columna del barrio | «¿Querés ayudar a buscarla también en la calle?» |
| 3–12 s | Aviso → «Imprimir cartel» → PDF «SE BUSCA · Luna» con foto y QR | «Desde cualquier aviso armás un cartel listo para imprimir, con su foto y un QR al aviso.» |
| 12–19 s | Alguien escanea el QR del cartel → página del aviso | «Quien lo escanea ve el aviso actualizado y puede avisar desde ahí.» |
| 19–25 s | Texto: **«Sin teléfono. Sin recompensa.»** + cierre | «Sin tu teléfono y sin recompensas que atraigan estafas.» |

**Descripción:**
> Cualquier aviso de Huellamy se convierte en un cartel «SE BUSCA» para imprimir, con foto y un QR que lleva al aviso 📄
> No lleva tu teléfono. Lo puede armar el dueño o cualquier vecino que quiera ayudar.
> 👉 huellamy.com

`#SeBusca #PerroPerdido #Vecinos`

---

## 7. El mapa

**Objetivo:** mostrar todo lo que hay en el mapa y los filtros útiles.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Botón redondo del Mapa en el medio de la barra → abre el mapa lleno de pines | «Todo lo de tu mascota, en un mapa.» |
| 3–11 s | Chips: Salud, Tiendas, Cuidado, Salidas, Refugios | «Veterinarias, pet shops, peluquerías, paseadores, guarderías, refugios y bares que aceptan mascotas.» |
| 11–18 s | Filtro «Abierto ahora» + distancia | «Filtrás por lo que está abierto ahora y cerca tuyo.» |
| 18–25 s | Ficha de un lugar: horario, reseñas, «Cómo llegar», favorito | «Cada lugar tiene su horario, reseñas y cómo llegar.» |
| 25–30 s | «Marcar un lugar» + cierre | «¿Falta alguno? Lo marcás vos y lo sumamos. Entrá a huellamy.com.» |

**Descripción:**
> Veterinarias, pet shops, paseadores, guarderías y lugares que aceptan mascotas en Pando, en un solo mapa 🗺️ Filtrá por «abierto ahora», mirá reseñas y cómo llegar.
> ¿Falta un lugar? Marcalo vos.
> 👉 huellamy.com

`#PetFriendly #Veterinaria #PetShop #Paseadores`

---

## 8. Urgencias

**Objetivo:** que la gente sepa dónde mirar en una emergencia.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Perro decaído en su cama (tono sereno). Texto: **«¿Una urgencia de noche?»** | «Son las tres de la mañana y tu perro no está bien.» |
| 3–12 s | Pestaña Urgencias → veterinarias de urgencia 24 h | «En Urgencias tenés las veterinarias de guardia de la zona, a un toque.» |
| 12–19 s | Directorio: refugios, protectoras y grupos de Pando | «Y también refugios, protectoras y grupos que ayudan.» |
| 19–25 s | Texto: **«Si hay una persona en riesgo, llamá al 911»** + cierre | «Guardala hoy, para no buscar cuando más la necesitás.» |

**Descripción:**
> En Huellamy, la pestaña Urgencias tiene las veterinarias de guardia y los refugios y protectoras de Pando, a un toque 🚑
> Guardala hoy, para no tener que buscar en el peor momento.
> 👉 huellamy.com

`#VeterinariaDeUrgencia #Veterinaria24hs #Pando`

---

## 9. Libreta y recordatorios

**Objetivo:** mostrar la libreta de salud y los recordatorios de medicación (gratis).

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Libreta de papel arrugada, con datos tachados | «¿Cuándo le tocaba la vacuna?» |
| 3–11 s | Ficha de la mascota → libreta: vacunas, desparasitaciones, controles | «En Huellamy, la libreta de tu mascota está siempre en tu celular.» |
| 11–19 s | Crear recordatorio de medicación: dosis, cada 12 horas, hasta tal fecha | «Cargás sus remedios y te avisa cada vez que le toca. Funciona hasta sin internet.» |
| 19–25 s | Notificación → «✅ Ya se la di» → historial | «Tocás "Ya se la di" y queda anotado.» |
| 25–30 s | Texto: **«Gratis para todos»** + cierre | «Los recordatorios de salud son gratis. Siempre.» |

**Descripción:**
> Vacunas, desparasitaciones, controles y medicación de tu mascota, con recordatorios que funcionan hasta sin internet 💉
> Tocás «Ya se la di» y queda anotado. Gratis para todos.
> 👉 huellamy.com

`#SaludAnimal #VacunasMascotas #Recordatorios`

---

## 10. Hogar compartido

**Objetivo:** mostrar el cuidado en familia (evita dosis dobles).

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–4 s | Dos personas en la cocina con la misma pastilla en la mano. Texto: **«¿Ya le diste el remedio?»** | «"¿Le diste el remedio?" "No sé, ¿vos?"» |
| 4–12 s | Mi hogar → invitar con un enlace | «Con Hogar compartido invitás a tu familia con un enlace.» |
| 12–20 s | Celular A marca «Ya se la di» → celular B lo ve al instante | «Cuando alguien marca "Ya se la di", lo ven todos. Se terminaron las dosis dobles.» |
| 20–26 s | Mascotas, libreta y avisos del QR compartidos | «Comparten las mascotas, la libreta, los recordatorios y los avisos de la chapita.» |
| 26–30 s | Cierre fijo | «Cuidarla es cosa de todos.» |

**Descripción:**
> Invitá a tu familia a cuidar a tu mascota en Huellamy 🏡 Comparten libreta, recordatorios y avisos, y cuando alguien le da el remedio, lo ven todos. Chau dosis dobles.
> 👉 huellamy.com

`#Familia #CuidadoDeMascotas #Organizacion`

> Revisar antes de publicar: si el plan Familia ya se cobra, agregar «30 días de prueba gratis» y no decir «gratis».

---

## 11. Adopción y hogar de tránsito

**Objetivo:** adopción responsable, que el animal no vuelva a la calle.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Gato de refugio mirando a cámara | «¿Estás pensando en sumar una mascota a tu familia?» |
| 3–11 s | Inicio → «Adopción y hogar de tránsito» → listado con filtros Perro / Gato | «En Huellamy ves los perros y gatos en adopción de los refugios de la zona.» |
| 11–19 s | Guía «¿Estoy listo para adoptar?» y calculadora de costos | «Antes de decidir, te ayudamos a pensarlo: tiempo, espacio y cuánto cuesta por mes.» |
| 19–25 s | Ficha: edad, tamaño, energía, convivencia | «Cada ficha te dice cómo es: su energía, si se lleva con niños o con otros animales.» |
| 25–30 s | Ami y Mishi abrazados + cierre | «Adoptar es para siempre. Que salga bien.» |

**Descripción:**
> Perros y gatos en adopción en Pando, con todo lo que necesitás saber antes de decidir: cómo es cada uno, cuánto cuesta por mes y si estás listo 🐾
> Adoptar es para siempre. ¿Te sumás como hogar de tránsito?
> 👉 huellamy.com

`#AdoptaNoCompres #Adopcion #HogarDeTransito #Refugio`

> Revisar antes de publicar qué partes del proceso de adopción están prendidas en producción.

---

## 12. Turnos y pedidos

**Objetivo:** reservar turno y hacer un pedido a un comercio desde la app.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Ficha de una veterinaria → «Reservar turno» | «¿Turno en la veterinaria sin llamar?» |
| 3–11 s | Elegir servicio, día, horario libre y mascota | «Elegís el servicio, el día, un horario libre y la mascota. Listo.» |
| 11–15 s | «Mis turnos» con el estado «Confirmado» | «Te avisamos cuando lo confirman y el día antes.» |
| 15–25 s | Pet shop → «Ver catálogo» → agregar productos → «Hacer pedido» | «En los pet shops ves el catálogo con precios, armás tu pedido y elegís retiro o envío.» |
| 25–30 s | Estados del pedido: preparando → listo + cierre | «Y seguís el pedido en vivo hasta que está listo.» |

**Descripción:**
> Reservá turno en la veterinaria y hacé tu pedido al pet shop desde Huellamy 📅🛍️ Elegís horario, ves precios y seguís el estado en vivo.
> 👉 huellamy.com

`#PetShop #Veterinaria #TurnosOnline`

---

## 13. Paseos y estadías

**Objetivo:** contratar paseadores, guarderías y estadías.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Perro con la correa en la boca esperando en la puerta | «Él quiere salir. Vos tenés que trabajar.» |
| 3–10 s | Mapa → chip Cuidado → paseadores y hoteles | «Encontrá paseadores, guarderías y hoteles para mascotas cerca tuyo.» |
| 10–19 s | «Contratar: paseo, estadía…» → servicio, días, mascotas, nota | «Elegís paseo, guardería, estadía o visitas a domicilio, los días y tus mascotas.» |
| 19–26 s | El prestador acepta → se abre el chat | «Cuando el prestador acepta, se abre el chat para coordinar. Sin dar tu número.» |
| 26–30 s | Perro volviendo feliz del paseo + cierre | «Él contento. Vos tranquilo.» |

**Descripción:**
> Paseadores, guarderías y estadías para tu mascota, cerca tuyo 🦮 Pedís el servicio en la app y coordinás por chat, sin compartir tu número.
> 👉 huellamy.com

`#Paseador #GuarderiaCanina #HotelParaPerros`

---

## 14. Huellamy Comercios: tu ficha en el mapa

**Objetivo:** que un comercio cree o reclame su ficha. Público: veterinarias, pet shops, peluquerías, paseadores.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Vidriera de un pet shop de Pando. Texto: **«¿Tenés un comercio de mascotas?»** | «¿Trabajás con mascotas en Pando?» |
| 3–10 s | Mapa de Huellamy con el pin gris «sin reclamar» del comercio | «Puede que tu local ya esté en el mapa de Huellamy, marcado por tus clientes.» |
| 10–19 s | Huellamy Comercios → reclamar el lugar → nombre, horario, fotos, especies | «Lo reclamás, cargás tu horario, tus fotos y las especies que atendés.» |
| 19–27 s | Pin verificado ✔️ en el mapa de un dueño | «Y te encuentran los dueños de tu zona, justo cuando buscan.» |
| 27–35 s | Texto: **«Ficha básica sin costo»** + cierre con «comercios.huellamy.com» | «La ficha básica no tiene costo. Entrá a comercios.huellamy.com.» |

**Descripción:**
> ¿Tenés una veterinaria, pet shop, peluquería o sos paseador? Poné tu comercio en el mapa de Huellamy y que te encuentren los dueños de tu zona 📍
> La ficha básica no tiene costo.
> 👉 comercios.huellamy.com

`#Emprendedores #ComerciosDePando #PetShop #Veterinaria`

---

## 15. Catálogo, agenda y pedidos

**Objetivo:** mostrar las herramientas de los planes pagos para comercios.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Dueña de un pet shop con el celular lleno de mensajes | «¿Tus pedidos llegan desordenados por diez lados?» |
| 3–11 s | Modo comercio → Catálogo: productos con foto y precio; servicios | «En Huellamy Comercios cargás tus productos y servicios con precio.» |
| 11–19 s | Pedidos: nuevo → preparando → listo → entregado | «Los pedidos te llegan ordenados y los avanzás con un toque. El cliente lo ve en vivo.» |
| 19–27 s | Agenda: turnos, paseos y estadías; confirmar / rechazar | «Con la agenda, te reservan turnos, paseos y estadías, y vos confirmás.» |
| 27–35 s | «Compartir mi página» → página web pública del comercio + cierre | «Y tenés tu propia página para compartir en Instagram y WhatsApp.» |

**Descripción:**
> Catálogo, pedidos, turnos, paseos y estadías, todo ordenado en Huellamy Comercios 🛍️📅 Y tu propia página para compartir en redes.
> 👉 comercios.huellamy.com

`#Emprendedores #Agenda #VentasOnline`

---

## 16. Cómo te va + Socios Fundadores

**Objetivo:** estadísticas y la oferta de lanzamiento para los primeros comercios.

| Tiempo | En pantalla | Voz en off |
|---|---|---|
| 0–3 s | Panel del comercio con el número de vistas subiendo | «¿Cuánta gente vio tu comercio este mes?» |
| 3–12 s | Estadísticas: vistas, llamadas, «cómo llegar», comparación mensual | «En tu panel ves cuántos vieron tu ficha, cuántos te llamaron o pidieron cómo llegar, y cómo vas mes a mes.» |
| 12–22 s | Texto: **«Socios Fundadores: plan Destacado gratis por 6 meses»** | «Y si sos de los primeros comercios de Pando, tenés el plan Destacado gratis por 6 meses y el precio congelado después.» |
| 22–30 s | Ami celebrando + cierre con «huellamy.com · Soy un comercio» | «Escribinos desde huellamy.com y sumate.» |

**Descripción:**
> Los primeros comercios de Pando que se suman a Huellamy son Socios Fundadores: plan Destacado gratis por 6 meses y precio congelado después ⭐
> Mirá cuánta gente ve tu ficha y te contacta, mes a mes.
> 👉 huellamy.com → «Soy un comercio»

`#SociosFundadores #ComerciosDePando #Emprendedores`

> Revisar antes de publicar que las condiciones de Socios Fundadores sigan iguales (`22-planes-y-precios.md`).
