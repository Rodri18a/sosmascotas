# Pruebas del plan de mejoras (etapas 1, 2 y 3)

> Armada el 02/11/2026 para probar a mano, **botón por botón**, todo lo del [plan de mejoras](../24-plan-mejoras.md) que ya está en dev. Usa los mismos dos teléfonos que [Pruebas paso a paso](pruebas-paso-a-paso.md): **📱1 = Cuenta A** (vos, dueño de «Pet Shop Ejemplo (catálogo)», plan Plus, y de «Veterinaria de prueba (dev)», verificada) y **📱2 = Cuenta B** («Rodri»). Los textos entre «comillas» son los exactos de la app.
>
> Al terminar cada caso anotá ✅ o ❌ con su código (por ejemplo «PM-07 ❌ el código no llega») y pasámelo: lo arreglo en el momento.

## Antes de empezar (en los dos teléfonos)

1. Abrí la app instalada (o https://sosmascota-dev.vercel.app) y **recargala** para tener la versión nueva: en Chrome, deslizá hacia abajo; instalada, cerrala del todo y abrila de nuevo.
2. Para ver los recorridos guiados desde cero, la primera vez abrí la app en una **ventana de incógnito** (salen solos una sola vez por teléfono).
3. Tené a mano el portal: https://sosmascota-admin.vercel.app (con tu cuenta de administración, en la computadora).

---

## Ronda 1 · Inicio, menú y ayuda (etapa 1)

| Código | Dónde | Qué hacer | Qué tiene que pasar |
|---|---|---|---|
| PM-01 | 📱1 | Abrí la app | Abre en **Inicio**. Arriba, el **carrusel** pasa solo cada 3 segundos (hay 3 banners de ejemplo). Tocar «Ola de calor» abre la noticia del calor |
| PM-02 | 📱1 incógnito | Abrí la app por primera vez | Sale solo el **recorrido guiado**: se oscurece la pantalla y se ilumina una parte por vez, con «Siguiente», «Atrás» y «Saltar». Tocar fuera del globo también avanza |
| PM-03 | 📱1 | En Inicio tocá el **?** de arriba a la derecha | Se repite el recorrido de Inicio |
| PM-04 | 📱1 | Entrá a SOS, Mapa, Mascotas y Urgencias | En cada una, la primera vez sale su recorrido; después, con el **?** |
| PM-05 | 📱1 | Tocá **☰** | El menú está en grupos con título: Mis mascotas · Mapa y lugares · Comunidad · Adopción · Turnos y pedidos · Mi cuenta. **Ajustes** está en Mi cuenta (ya no arriba a la derecha) |
| PM-06 | 📱1 | Entrá a Mi hogar o a Hogar de tránsito | La explicación de arriba es **una línea** con «Ver más», que despliega el texto completo |
| PM-07 | 📱1 | Mascotas → en la fila de una mascota tocá el ícono **QR** | Abre su chapita QR directo |
| PM-08 | 📱1 | En la fila de la mascota tocá **⋮** | Aparecen «Agregar al historial», «Agregar a la libreta», «Nuevo recordatorio» y «Reportar que se perdió»; cada uno abre su pantalla |
| PM-09 | 📱1 | Abrí https://sosmascota-dev.vercel.app/comercios/ | Abre **Huellitas Comercios** (en azul) en el panel del negocio; se puede instalar aparte. «Ir a Huellitas» vuelve a la app de personas |

## Ronda 2 · Historial de vida y compartir (etapa 2)

| Código | Dónde | Qué hacer | Qué tiene que pasar |
|---|---|---|---|
| PM-10 | 📱1 | Mascotas → una mascota → bajá hasta **«Historial de vida»** → «Agregar al historial» | Formulario: tipo (Operación, Accidente…), título, fecha, nota |
| PM-11 | 📱1 | Elegí «Operación», título «Castración», agregá **una foto** («Foto» → galería) y **un PDF** («PDF») → «Guardar» | Vuelve a la ficha y aparece en la línea de tiempo con «Adjunto 1» y «Adjunto 2». Tocarlos los abre |
| PM-12 | 📱1 | Intentá agregar un 5.º adjunto | Con 4, los botones se apagan: «Llegaste a 4…» |
| PM-13 | 📱1 | Ficha → al final, **«Compartir historial»** → 7 días → «Crear y copiar el enlace» | Dice «Enlace copiado». Abajo aparece el enlace vigente con «Nadie lo abrió todavía» |
| PM-14 | 📱2 (o la computadora) | Pegá el enlace en el navegador | Se ve la mascota, la libreta y el historial de vida **con la foto y el PDF**. **No** aparece tu teléfono, tu correo ni tu dirección |
| PM-15 | 📱1 | Volvé a «Compartir historial» | El enlace dice «Se abrió 1 vez». Tocá «Cortar» y recargá la página en el 📱2: «Este enlace ya no funciona» |
| PM-16 | 📱1 | Ficha de una mascota de prueba → **«Pasar a otra persona»** → «Generar código» | Aparece un código de 10 letras y «Vence el …». «Copiar para mandar» copia un mensaje con el código |
| PM-17 | 📱2 | Mascotas → abajo, **«Tengo un código»** → escribí el código → «Buscar» | Se ve el nombre y la foto de la mascota |
| PM-18 | 📱2 | «Aceptar» | «¡Listo! Ya está en tus mascotas» y se abre su ficha **con su historial**. En el 📱1 ya no está |
| PM-19 | 📱1 | Intentá pasar una mascota que tenga un **SOS abierto** | «Tiene un SOS abierto: cerralo antes de pasarla.» |

## Ronda 3 · Preguntas (etapa 2)

| Código | Dónde | Qué hacer | Qué tiene que pasar |
|---|---|---|---|
| PM-20 | 📱2 | ☰ → Comunidad → **«Preguntas»** → «Preguntar» | Pide el tema (Viajes, Salud…) y la pregunta; abajo, «¿Dónde la publicás?» con «Preguntas generales» |
| PM-21 | 📱2 | Tema «Salud», «¿Cada cuánto se desparasita un perro?» → «Publicar pregunta» | Se abre la pregunta con el chip «Salud» |
| PM-22 | 📱1 | Preguntas → buscá **«desparasita»** (sin tilde) | Aparece. Los chips de tema filtran |
| PM-23 | 📱1 | Abrila → «Unirme al grupo para responder» → respondé «Cada tres meses» | La respuesta queda publicada |
| PM-24 | 📱1 | Debajo de tu respuesta tocá **«Firmar como profesional»** → elegí «Veterinaria de prueba (dev)» | Tu respuesta dice **«Respuesta de profesional · Veterinaria de prueba (dev)»**. En la lista, la pregunta dice «Responde una veterinaria» |
| PM-25 | 📱2 | Abrí tu pregunta → en la respuesta tocá **«Me sirvió»** | La respuesta queda marcada «Le sirvió a quien preguntó» y la pregunta, «✓ Resuelta» |
| PM-26 | 📱2 | Intentá preguntar «Vendo cachorros» | No se publica: avisa que no se permite venta ni cruza |

## Ronda 4 · Promociones y publicidad (etapa 3)

| Código | Dónde | Qué hacer | Qué tiene que pasar |
|---|---|---|---|
| PM-27 | 📱1 | ☰ → «Mi negocio» (abre Huellitas Comercios) → «Pet Shop Ejemplo (catálogo)» → abajo **«Negocio»** → «Promoción en el muro» | Dice que tenés hasta 2 vigentes (plan Plus). «Nueva promoción» |
| PM-28 | 📱1 | Título «10% en alimento», detalle, 7 días, «Foto 1» → «Publicar» | Aparece en la lista con «Hasta el …» y «Terminar» |
| PM-29 | 📱2 | Inicio → bajá entre las noticias | Después de la 4.ª noticia sale **«Promocionado · Pet Shop Ejemplo (catálogo)»** con la foto. Tocarla abre la ficha del comercio |
| PM-30 | 📱2 | Inicio → Comunidad, y ☰ → Preguntas | También aparece intercalada (si hay suficientes publicaciones). **Nunca** en SOS, Urgencias ni la ficha de una mascota |
| PM-31 | 📱2 | En la promoción tocá **⋯** → «Es engañosa» | «Gracias, la vamos a revisar.» |
| PM-32 | Portal | **Moderación** | Aparece la promoción reportada («Promoción del muro»), con 1 reporte |
| PM-33 | Portal | **Espacios** → 7 días | La promoción y los banners con sus vistas, personas, toques y tasa |
| PM-34 | 📱1 (al otro día) | Panel → Estadísticas del pet shop | Suman «Vistas de tu promoción» y «Toques en tu promoción» (el resumen se arma de noche) |
| PM-35 | 📱1 | Panel de la «Veterinaria de prueba (dev)» (plan Gratis) → Negocio | «Promoción en el muro» explica que es de Destacado o Plus, sin botón para crear |

## Ronda 5 · Tus huellas (etapa 3)

| Código | Dónde | Qué hacer | Qué tiene que pasar |
|---|---|---|---|
| PM-36 | 📱1 | ☰ → tu nombre (Mi perfil) | Tarjeta **«Tus huellas»**: cuántas veces ayudaste y 6 insignias. Las que tenés dicen «¡Ganada!»; las otras, cómo ganarlas. Abajo: «Solo vos ves tus huellas. No hay rankings.» |
| PM-37 | 📱1 | Abrí un SOS de la lista → «Compartir» → volvé a Mi perfil | Se gana **«Difusor»** y suma una ayuda |
| PM-38 | 📱1 | Después de PM-25 (te marcaron «Me sirvió»), mirá Mi perfil | Ganaste **«Buena respuesta»** |

---

## Si algo falla

Anotá el código, qué esperabas y qué pasó (una captura ayuda). Si es algo de un solo teléfono, decí cuál. Lo arreglo y lo subo a dev en el momento.

Después de estas rondas, la prueba con 3 personas de afuera está en [prueba-5-funciones.md](prueba-5-funciones.md).
