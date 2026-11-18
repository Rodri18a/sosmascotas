# 26 · Lanzamiento: quién hace qué, por etapa

> Propuesta del 17/11/2026 para discutir entre Rodrigo (desarrollo y producto) y Flavia (marketing, marca y empresas), que se sumó ese día. Versión editable compartida: [documento en Claude](https://claude.ai/artifact/PM2yJ7N8gmUCfSYbHe6PAK) · PDF: [informes/26-lanzamiento-roles-etapas.pdf](informes/26-lanzamiento-roles-etapas.pdf ':ignore')

## Resumen

El código de Huellamy va muy adelantado; lo que frena el lanzamiento de diciembre es casi todo trabajo **fuera del código**: validar con dueños y comercios, cargar datos reales de Pando, legal, y salir a comunicar. Este documento reparte ese trabajo entre dos roles y en tres etapas, como **propuesta para discutir juntos**.

| Rol | Quién | Se encarga de |
| --- | --- | --- |
| Desarrollo y producto | Rodrigo | La app, Huellamy Comercios, el portal, la base, la publicación, las tiendas, la seguridad y las métricas. Gestiones técnicas y de proveedores (correo, producción, Google Play, Apple) |
| Marketing, marca y empresas | Flavia | Nombre y marca, redes, videos y piezas, landing, investigación (competencia, entrevistas), relación con comercios, refugios y grupos, Socios Fundadores, difusión del lanzamiento |
| Juntos | Los dos | Decisiones de negocio (precios, qué se lanza, formalización), revisión legal, soporte en la guardia de fin de año, lectura de métricas |

Cómo leerlo: cada etapa dice **qué sale** y después **qué le toca a cada uno**. Los códigos entre paréntesis (0.8.5, D160…) remiten a `docs/PROGRESO.md` y `docs/12-decisiones.md`. Las etapas siguen las fases del roadmap: **Etapa 1 = Fase 0**, **Etapa 2 = Fase 1**, **Etapa 3 = Fases 2 y 3**.

## Dónde estamos hoy

Las dos apps, el portal y la web pública funcionan en dev, ya bajo `huellamy.com`; casi todo lo de las Fases 1 a 3 está programado y **apagado** detrás de interruptores, listo para prenderse cuando se decida. Lo que no está hecho es la validación con gente real (3 de 16 pasos) y la puesta en producción.

| Fecha | Qué se hizo |
| --- | --- |
| 17/11/2026 | Soporte: Ajustes → Ayuda y soporte, correo `contacto@huellamy.com`, redes Instagram `@huellamy.app` y Facebook `huellamy` (D160, D163). Diseño más ilustrado en la app y la landing (D162). «Hecho en Uruguay» en vez de Pando (D161) |
| 16/11/2026 | Dominios `huellamy.com`, `app.`, `comercios.` y `admin.` funcionando con HTTPS (por ahora apuntan a dev) |
| 12/11/2026 | Landing de `huellamy.com` con formulario de contacto que llega al portal → Contactos |
| 11–12/11/2026 | Ilustraciones de Ami y Mishi en la app. Guiones de 16 videos cortos y el video 1 «Huellamy en 30 segundos» |
| 10/11/2026 | Dominio y hosting comprados en Hostinger (US$42, primer gasto) |
| 09/11/2026 | Marca **Huellamy** aplicada (paleta, isotipo, logo, íconos). Primera versión solo para perros y gatos |
| 01–04/11/2026 | Plan de mejoras completo: Inicio con novedades y banners, menú ordenado, recorrido guiado, historial de vida, preguntas, promociones en el muro, insignias «Tus huellas». Dos apps independientes: Huellamy y Huellamy Comercios |
| 18–28/10/2026 | Programado (apagado hasta decidir): comercios con cuenta, chat, libreta y recordatorios, hogar compartido, reseñas, portal de administración con mini CRM, chapitas físicas, adopción, planes, turnos, pedidos, paseos, grupos, equipo del comercio |
| 12–20/10/2026 | Núcleo de la Fase 0: cuentas, mascotas, chapita QR, SOS con avisos a 5 km, urgencias, app instalable desde el navegador. Probado a mano en Android y iPhone |

**Lo que frena el lanzamiento hoy:** sin veterinarias ni refugios reales cargados, sin entrevistas, sin revisión legal, sin proyecto de producción, y los correos de ingreso todavía salen en inglés (falta el proveedor de correo).

## Las tres etapas: qué sale en cada una

La Etapa 1 sale en diciembre de 2026 en Pando, gratis y desde el navegador; las Etapas 2 y 3 prenden lo que ya está programado, a medida que se cumplen las metas.

| | Etapa 1 · Lanzamiento SOS | Etapa 2 · App completa y comercios | Etapa 3 · Ingresos y servicios |
| --- | --- | --- | --- |
| Cuándo | Diciembre 2026, antes de los fuegos artificiales | Marzo–abril 2027 | Mediados a fin de 2027 |
| Dónde | Web instalable en `app.huellamy.com` (sin tiendas) | Google Play y App Store, Android e iPhone | Las mismas apps |
| Para quién | Dueños de perros y gatos de Pando | Dueños y comercios de Pando | Dueños y comercios, y zonas cercanas |
| Meta para pasar a la siguiente | 300 registrados, 20 reportes SOS, primeros reencuentros, 50 QR | 1.500 activos por mes, 15 Socios Fundadores, 30 % con un recordatorio activo | Cubrir el gasto mensual con ingresos; 3 % pasa a Pro o Familia |
| Cobra algo | No | No (Socios Fundadores gratis 6 meses) | Sí: planes de personas y de comercios |

### Etapa 1 · Lanzamiento SOS (Fase 0)

- Cuenta con Google o correo, modo visitante, términos y borrar cuenta
- Mascotas con foto (perros y gatos)
- **Chapita QR digital** con página pública y contacto inverso (el número del dueño nunca se muestra)
- **SOS** perdidos y encontrados: mapa, lista, avisos a vecinos a 5 km, cartel «Se busca», marcar resuelto
- **Urgencias**: veterinarias de guardia y directorio de ayuda (refugios, protectoras)
- Mapa con veterinarias y lugares de Pando
- Inicio con novedades y banners; soporte por correo y «Escribinos»
- Landing `huellamy.com` con formulario para comercios
- Primer lote de 30–50 chapitas físicas para regalar
- **A decidir juntos:** qué de lo ya programado se prende desde el día 1 (ver la última sección)

### Etapa 2 · App completa y comercios (Fase 1)

- Apps en Google Play y App Store, login con Apple, mapa nativo de Google
- **Huellamy Comercios**: ficha gratis, reclamar «¿Es tu negocio?», verificación, reseñas
- **Socios Fundadores**: 20–30 comercios de Pando con plan gratis 6 meses y precio congelado
- Chat entre vecinos y seguir búsquedas
- **Libreta sanitaria y recordatorios** (vacunas, medicación, comida), hogar compartido
- Chapitas físicas con activación desde la app y retiro en la veterinaria asociada
- Adopción responsable y hogar de tránsito (el roadmap la pone al inicio de la Fase 2; se puede adelantar)

### Etapa 3 · Ingresos y servicios (Fases 2 y 3)

- Planes para personas: **Pro y Familia**
- Planes para comercios: **Destacado (unos $600/mes) y Plus (unos $1.200/mes)**, promociones en el muro, estadísticas y reporte mensual
- Turnos, pedidos y catálogo; paseos, guardería y estadías
- Grupos por raza y especie, preguntas con respuestas de veterinarias
- Sponsors de chapitas y venta de diseños
- Campaña fuerte de fin de año 2027

Más adelante (2028, fuera de este plan): pagos con Mercado Pago, tienda, otras especies, otras zonas y países.

## Plazos: lo pensado y lo estimado

Diciembre para la Etapa 1 es posible, pero solo si la asesoría legal arranca esta semana: lo realista es un **lanzamiento público entre el 15 y el 20 de diciembre**. Marzo–abril para la Etapa 2 también es realista, siempre que la cuenta de Google Play se cree a más tardar a principios de enero.

| Etapa | Fecha pensada | Fecha estimada | Qué la puede atrasar |
| --- | --- | --- | --- |
| 1 · Lanzamiento SOS | Diciembre 2026 | Prueba con conocidos del 1 al 7/12; lanzamiento público del 15 al 20/12, antes de la guardia del 24/12 | Asesoría legal (3–5 semanas en total), datos reales de Pando sin cargar, chapitas físicas sin probar |
| 2 · App completa y comercios | Marzo–abril 2027 | Android a fines de febrero; iPhone en marzo; comercios y Socios Fundadores entre marzo y abril | Prueba cerrada de Google (14 días + revisión), primera revisión de Apple, número D-U-N-S si las cuentas son de la empresa, no llegar a las metas de la Etapa 1 |
| 3 · Ingresos y servicios | Mediados a fin de 2027 | Primeros cobros no antes de julio 2027 | Formalización y facturación electrónica, configurar los cobros en las tiendas, metas de la Etapa 2 |

### Trámites y esperas que no dependen de nosotros

| Trámite | Tiempo estimado | Cuándo arrancar | Costo |
| --- | --- | --- | --- |
| Asesoría legal: términos, privacidad, compromiso de adopción | 1 semana para el presupuesto + 2–4 semanas de revisión | Esta semana | US$150–400 (estimado) |
| Registro de la base de datos en la URCDP | En línea y gratis; el plazo de respuesta no está publicado | Con la asesoría legal, antes de lanzar | Gratis |
| Proveedor de correo (correos de ingreso en español) | 1–2 días, con los registros DNS | Ya | Gratis en el plan inicial |
| Proyecto de producción en Supabase | 1–2 días | Primera semana de diciembre | Gratis hasta pasar a Pro (unos US$25/mes) |
| Chapitas: muestras y prueba de durabilidad | 1 semana de muestras + 2–3 semanas de uso | Ya. Si no llegan, se lanza con la chapita digital y las físicas salen en enero | US$50–150 el lote de 100 |
| Cuenta de Google Play personal | Verificación de identidad: unos días. Prueba cerrada: 14 días seguidos con 12 testers. Revisión para producción: hasta 7 días. Total: unas 4 semanas | Diciembre o principios de enero | US$25 una vez |
| Cuentas de Google Play o Apple a nombre de la empresa | Piden un número D-U-N-S: hasta 30 días, gratis. Google no les exige la prueba cerrada | Apenas exista la empresa | Gratis |
| Apple Developer | Alta: 1–2 días como persona (con empresa, más el D-U-N-S) | Enero | US$99 por año |
| Revisión de App Store | La mayoría en 1–2 días; una app nueva puede esperar 2–5 días y el primer envío suele volver con observaciones. Contar 1–2 semanas | Febrero | Incluido |
| Constituir la empresa (SAS) | Unos días hábiles para constituirla; con inscripciones y facturación electrónica, calcular 3–6 semanas (estimación propia, confirmar con el contador) | Consulta en diciembre. Constituirla antes de la Etapa 2 si las tiendas van a nombre de la empresa, y sí o sí antes del primer cobro | Honorarios a cotizar; contador unos $3.000/mes desde el primer cobro (supuesto) |

### Gastos por etapa

| Etapa | Gasto | Monto |
| --- | --- | --- |
| Ya pagado | Dominio y hosting | US$42 |
| 1 | Asesoría legal | US$150–400 |
| 1 | Chapitas (primer lote) y volantes | US$50–150 + impresión a cotizar |
| 1 o 2 | Google Play | US$25 una vez |
| 2 | Apple Developer | US$99 por año |
| 2 | Supabase Pro, si el uso lo pide | Unos US$25 por mes |
| 2 o 3 | Constituir la empresa y contador | A cotizar; unos $3.000 por mes |
| 3 | Comisión de las tiendas sobre Pro y Familia | 15 % para desarrolladores chicos (30 % en el caso general) |

### Lo que más mueve las fechas

1. **Pedir el presupuesto legal esta semana.** Es lo único que hoy puede correr el lanzamiento a enero.
2. **Decidir si las tiendas van a nombre personal o de la empresa** antes de crear las cuentas: pasar una app de una cuenta a otra después es engorroso. Con cuenta personal se sale antes; con la empresa hace falta el D-U-N-S, pero Google no pide la prueba cerrada.
3. **Crear la cuenta de Google Play en diciembre** y que Flavia junte a los 12 testers (conocidos que la usen 14 días seguidos). Así Android puede estar en la tienda a fines de enero o en febrero.

Fuentes (consultadas el 18/11/2026): [prueba cerrada de Google Play](https://support.google.com/googleplay/android-developer/answer/14151465?hl=es), [tiempos de revisión de App Store](https://developer.apple.com/distribute/app-review/), [inscripción de bases de datos (URCDP)](https://www.gub.uy/tramites/inscripcion-bases-datos-personales), [inscripción de una SAS](https://www.gub.uy/tramites/inscripcion-sociedad-acciones-simplificadas-sas). Los costos de legal, chapitas y contador salen de `10-costos.md`.

## Etapa 1 · Pendientes por rol (hasta diciembre 2026)

Quedan unas 5 semanas hasta Navidad: el camino crítico es **datos reales de Pando + legal + producción**. Casi todo lo de Flavia arranca ya, en paralelo a lo técnico.

### Rodrigo · desarrollo y producto

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Proveedor de correo | Para que los correos de ingreso salgan en español y con la marca (hoy salen en inglés) | 0.4.4b |
| Terminar el soporte | Subir la web pública con el correo nuevo | 0.8.6b |
| Revisar la marca en el celular | Huellamy y Huellamy Comercios instaladas; poses de Ami y Mishi para carga, éxito y error | 0.8.3f, 0.8.3d |
| Cerrar pruebas pendientes | PM-11 en iPhone y seguir desde PM-12; funcionamiento sin internet; pruebas de seguridad con token nuevo; subir las 8 funciones de avisos | 0.8.3e, 1.5.6, 0.8.6c |
| Prueba con 5–10 conocidos | Corregir lo que reporten (Flavia consigue y acompaña a los testers) | 0.8.3 |
| Cargar los datos reales | Veterinarias y directorio de ayuda que junta Flavia, con los scripts de carga | 0.0.4, 0.0.5 |
| Proyecto de producción | Crear Supabase de producción, migraciones, respaldo; apuntar los dominios a producción | 0.8.5 |
| Prender lo que se lanza | Interruptores según lo que decidamos juntos | 0.8.5 |
| Chapitas de prueba | 3–5 muestras con el amigo de impresión 3D, prueba de durabilidad, primer lote de 30–50 | 0.0.10, 0.0.11, 0.8.7 |
| Activar chapitas del lanzamiento | Vincularlas a las mascotas de quienes las reciben | 0.8.7 |
| (Opcional) Google Play | Crear la cuenta e iniciar la prueba cerrada para publicar Android en enero | 0.8.9 |
| Tablero de métricas | Sacar cada semana registros, SOS, QR e instalaciones para leerlos juntos | 0.9.1 |

### Flavia · marketing, marca y empresas

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Verificar el nombre Huellamy | Registro en DNPI, disponibilidad en tiendas y redes; decidir si se registra la marca | 0.0.9, 0.8.3f |
| Redes sociales | Armar Instagram `@huellamy.app` y Facebook `huellamy`: biografía, primeras publicaciones, calendario hasta el lanzamiento | D163 |
| Videos cortos | Revisar los 16 guiones y priorizar los de la Etapa 1 (1 al 8: qué es, se perdió, encontré, tu número no se muestra, chapita, cartel, mapa, urgencias) | `25-guiones-videos.md` |
| Revisar la landing | Textos, tono, propuesta para dueños y para comercios | 0.8.6d |
| Competencia | Probar Taponto y uno o dos más; qué hacen bien y mal, en qué nos diferenciamos | 0.0.2 |
| Lista de 30 comercios de Pando | Nombre, rubro, dirección, horario, contacto; marcar los que atienden urgencias | 0.0.3, 0.0.4 |
| Refugios, protectoras y grupos | Para el directorio de ayuda y para difundir el lanzamiento | 0.0.5 |
| Entrevistas a dueños | Ajustar el guion y entrevistar a 10 dueños (¿pagarían Pro o Familia?, ¿usarían el QR?) | 0.0.6, 0.0.7 |
| Mostrar la app a comercios | 5–8 comercios: qué les falta, cuánto pagarían; anotar candidatos a Socios Fundadores en el mini CRM del portal | 0.0.8 |
| Conseguir testers | 5–10 conocidos para la prueba antes de salir | 0.8.3 |
| Volante y chapitas | Volante con QR y a quién regalar las 30–50 chapitas (veterinarias, protectoras, influencers del barrio) | 0.8.7 |
| Plan de lanzamiento | Mensaje, fecha, publicaciones en grupos de Pando, veterinarias y protectoras; mensaje especial por los fuegos artificiales | 0.8.8 |

## Etapa 2 · Pendientes por rol (enero a abril 2027)

Lo técnico de la Etapa 2 es sobre todo publicar en las tiendas: el código ya está. El peso pasa a Flavia: **sumar comercios y Socios Fundadores** con los números de la Etapa 1.

### Rodrigo · desarrollo y producto

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Android | Ajustes, avisos nativos (incluidos los recordatorios con la app cerrada), publicar en Google Play tras la prueba cerrada | 1.1.1, 1.1.2 |
| iPhone | Cuenta de Apple Developer (US$99/año), login con Apple, envío a App Store | 1.1.3, 1.1.4 |
| Huellamy Comercios en tiendas | Publicar la app de comercios en Android y iPhone | 0.8.3d |
| Mapa nativo | Google Cloud con tope de presupuesto; Google Maps en el celular | 1.2.1, 1.2.2 |
| Prender funciones de la Etapa 2 | Comercios, chat, libreta y recordatorios, hogar compartido, reseñas, chapitas físicas, adopción | — |
| Cargar comercios | Fichas de los comercios que consiga Flavia; verificar reclamos desde el portal | 1.3 |
| Pruebas de los flujos nuevos | Recorridos completos antes de abrir cada función | 1.9.2 |
| Supabase Pro | Pasar al plan pago si el uso lo pide (unos US$25/mes) | 1.9.3 |
| Datos para Zoonosis | Datos agregados y anónimos de la Etapa 1 para la propuesta | 0.9.3 |

### Flavia · marketing, marca y empresas

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Socios Fundadores | Visitar comercios con los datos de la Etapa 1; meta: 15 socios (hasta 20–30 lugares) | 1.9.1 |
| Material para comercios | Folleto y presentación de Huellamy Comercios; videos 14 a 16 | `22-planes-y-precios.md` |
| Fichas de las tiendas | Textos, capturas y video de Google Play y App Store | 1.1.2, 1.1.4 |
| Lanzamiento de las apps nativas | Campaña «ya está en tu tienda»; videos 9 a 13 (libreta, hogar, adopción, turnos, paseos) | — |
| Protectoras y adopción | Redactar con ellas el compromiso de adopción; sumar refugios | P13 |
| Chapitas en veterinarias | Acordar con veterinarias asociadas el retiro de chapitas | — |
| Zoonosis de Canelones | Propuesta de una página y pedido de reunión, con las métricas de la Etapa 1 | 0.9.3, P17 |
| Comunidad | Mantener las redes, responder, publicar reencuentros (con permiso) | — |

## Etapa 3 · Pendientes por rol (mediados a fin de 2027)

La Etapa 3 empieza a cobrar, así que antes hay que **formalizar la empresa**. Los precios salen de lo que digan las entrevistas y los Socios Fundadores.

### Rodrigo · desarrollo y producto

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Cobro de planes | Pro y Familia dentro de la app (hoy está con cobro manual); Destacado y Plus con comprobante | 2.1 |
| Prender servicios | Turnos, pedidos y catálogo, paseos y estadías, grupos, equipo del comercio; probar pedidos con dos cuentas | 3.2–3.5 |
| Sponsors de chapitas | Venta de diseños personalizados | 2.9 |
| Estadísticas y reportes | Reporte mensual para comercios; tablero para los indicadores de la etapa | — |
| Programar la campaña de fin de año | Las 6 piezas de la propuesta (unas 11 h) si se aprueban | 3.7 |

### Flavia · marketing, marca y empresas

| Tarea | Detalle | Paso |
| --- | --- | --- |
| Vender planes a comercios | Pasar Socios Fundadores a pago (meta: 70 % renueva) y sumar Destacado y Plus | — |
| Comunicar Pro y Familia | Qué se paga y qué es siempre gratis (regla de oro); meta: 3 % de conversión | `22-planes-y-precios.md` |
| Sponsors | Conseguir marcas que patrocinen lotes de chapitas | 2.9 |
| Contenido patrocinado | Noticias y espacios de publicidad para comercios | — |
| Campaña de fin de año 2027 | Ejecutar de octubre 2027 a enero 2028 | `18-campana-fin-de-anio.md` |
| Próximas zonas | Elegir la siguiente zona a abrir e INBA / RENAC | P14 |

## Tareas compartidas y temas para discutir juntos

Lo más urgente para charlar es cómo entra Flavia a la empresa: cambia la formalización y la revisión legal, que pueden llevar semanas.

### Tareas de los dos

| Tarea | Quién lidera | Etapa | Paso |
| --- | --- | --- | --- |
| Asesoría legal: términos, privacidad, registro URCDP, compromiso de adopción. Arrancar ya | Rodrigo (Flavia revisa el tono) | 1 | 0.0.9c, 0.8.4 |
| Contador: forma de la empresa (SAS u otra) con dos socios, DGI, BPS, facturación | Los dos | 1 (consulta), 2–3 (formalizar) | 0.0.9d, 1.9.0 |
| Leer las entrevistas y aplicar los criterios de corte (¿seguimos con empresas pagas?) | Flavia trae los datos, deciden juntos | 1 | 0.0.8b |
| Guardia de soporte del 24/12 al 2/1 (respuesta en menos de 24 h) | Turnos entre los dos | 1 | 0.8.6b |
| Revisar las métricas cada semana y decidir si se pasa de etapa | Rodrigo saca los números, leen juntos | Todas | 0.9.1, 0.9.2 |
| Accesos: rol en el portal de administración (ventas y moderación), acceso a redes y al correo `contacto@` | Rodrigo los da | 1 | D109 |

### Para decidir en la reunión

- [ ] ¿Las tres etapas son como están acá (Etapa 1 = Fase 0, Etapa 2 = Fase 1, Etapa 3 = Fases 2 y 3)?
- [ ] ¿Qué se prende desde el día 1? Ya está programado: libreta y recordatorios, adopción, chat, reseñas, comercios con ficha propia. Más cosas = más valor, pero más soporte y moderación en plena guardia
- [ ] ¿Comercios desde la Etapa 1 (fichas gratis y Socios Fundadores ya) o recién en la Etapa 2?
- [ ] Fecha exacta del lanzamiento y mensaje principal (¿SOS y fuegos artificiales?)
- [ ] Presupuesto de marketing: hoy el único gasto es el dominio (US$42); ¿publicidad paga, impresión de volantes, chapitas?
- [ ] Precios de Destacado, Plus, Pro y Familia: ¿los ajusta Flavia con lo que digan los comercios?
- [ ] Diferencial frente a Taponto: competir con foco local y salud, o proponer una alianza (P22)
- [ ] ¿Se suma WhatsApp Business al soporte? Hoy se sale solo con correo (D160)
- [ ] Horas por semana de cada uno (P2)
