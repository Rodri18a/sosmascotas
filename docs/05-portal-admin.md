# 05 · Portal de administración

Herramienta propia del administrador, y a futuro de un equipo. Tiene tres objetivos:
1. **Operar** la plataforma (moderación, verificación, carga de lugares).
2. **Demostrar resultados** a las empresas que confían en el producto.
3. **Generar visibilidad** para captar empresas nuevas con datos concretos.

## Evolución

- **Fase 0:** sin portal propio. Se usa el **panel de Supabase** para moderar reportes, ocultar contenido y cargar las veterinarias de urgencia. **Los eventos de métricas se registran desde el día 1** (ver `08-arquitectura.md`), aunque los paneles se programen después.
- **Fase 1:** portal v1 en **Flutter Web** con moderación, empresas, lugares, indicadores generales y mini CRM. **Hecho el 18/10/2026 (D76):** proyecto `admin/`, publicado en https://sosmascota-admin.vercel.app con la base de prueba; secciones Panel, Moderación, Lugares, Prospectos y Ayuda.
- **Fase 2:** resultados por empresa, reporte mensual, generador de propuestas, planes y cobros, contenido patrocinado, chapitas QR.
- **Fase 3–4:** zonas, roles de equipo, auditoría completa.

Acceso: solo usuarios con rol `admin`, verificado en el servidor (RLS y claims), nunca solo en la interfaz.

---

## Secciones

### 1. Panel general — Fase 1
- Usuarios (totales, activos por día, semana y mes, nuevos), mascotas, hogares.
- SOS: activos, resueltos, tiempo promedio hasta resolverse, escaneos de QR.
- Empresas: por estado (sin reclamar, no verificada, verificada, destacada, Plus) y por rubro.
- Todo filtrable **por zona** y por período.

### 2. Moderación — Fase 1
- Cola de contenido reportado y **oculto automáticamente** (3 reportes de usuarios distintos).
- Acciones: aprobar (vuelve a mostrarse), eliminar, advertir, bloquear al usuario.
- Historial de cada usuario (reportes recibidos, sanciones).

### 3. Empresas — Fase 1
- Solicitudes de **verificación** (RUT y comprobante) → otorgar o quitar la insignia ✔️.
- **Reclamos** de lugares sin reclamar: aprobar o rechazar.
- Marcar **Socios Fundadores** (fecha de inicio y fin del beneficio, precio congelado).
- Editar fichas y fusionar duplicados. *(26/10/2026: editar fichas ✅ en Lugares, `admin_guardar_lugar()`; fusionar duplicados queda sin hacer y sin paso asignado: hoy se oculta el repetido.)*

### 4. Lugares — Fase 0 (vía Supabase) / Fase 1 (portal)
- Carga manual de comercios y lugares que aceptan mascotas.
- Ver lugares "sin reclamar" marcados por usuarios y su tracción.

### 5. Resultados para empresas clientes — Fase 2
*Objetivo: demostrar que pagar vale la pena y que renueven.*

Por cada empresa:
- **Visibilidad:** apariciones en el mapa y las búsquedas, aperturas de la ficha.
- **Interés:** clics en WhatsApp, llamar, cómo llegar, web e Instagram; guardados en favoritos.
- **Conversión:** chats iniciados, turnos y pedidos, socios captados.
- **Promociones:** vistas y usos de cada promo.
- **Reputación:** promedio de reseñas y su evolución.
- **Comparaciones:** mes contra mes, y antes contra después de pasar al plan pago.
- **Reporte mensual automático** (PDF o email) para enviar a la empresa. ✅ 2.3 (D101): por push el día 1; el email, con el SMTP. Resultados por empresa en Lugares → «Resultados».
- **Casos de éxito:** testimonios con números, para usar en ventas. ✅ 2.4 (D102): portal → Propuestas → Casos de éxito (con el permiso de la empresa para publicarlos).

### 6. Captación de empresas — Fase 1 (CRM) / Fase 2 (datos y propuestas)
*Objetivo: llegar a un comercio con datos concretos, no con una promesa.*

- **Demanda sin cubrir:** búsquedas por rubro y zona contra la oferta en el mapa. Ejemplo: *"En Pando, 85 personas buscaron 'peluquería' este mes y hay solo 1 en el mapa"*. Se basa en el evento `search` con resultados en cero. ✅ 1.8.7 (D97): sección del Panel con `admin_demanda()` (búsquedas y sin resultados por rubro contra los lugares activos, y los 20 textos sin rubro más buscados).
- **Lugares sin reclamar con tracción:** cuántos usuarios lo marcaron y cuántas veces se abrió su ficha. Ejemplo: *"Marcado por 23 usuarios, 140 aperturas de ficha"*. ✅ 1.8.5 (D99): Lugares → «Sin reclamar con tracción», con `admin_sin_reclamar()` y «Ver en Google Maps».
- **Audiencia por zona y especie:** usuarios y mascotas (*"1.200 perros, 400 gatos"*). Sirve para comercios y para **marcas** (noticias patrocinadas).
- **Embudo de ventas (mini CRM):** prospecto → contactado → demo → Socio Fundador → pagando → renovó / perdido. Con notas, responsable y fecha del próximo contacto.
- **Generador de propuesta:** PDF de una página con los datos de su zona y rubro, listo para mostrar en una visita. ✅ 2.4 (D102): portal → Propuestas, con `admin_propuesta()`; se descarga una página para imprimir o guardar como PDF.

### 7. Planes y cobros — Fase 2
✅ 2.2 (D103): portal → **Planes** (crear un plan pago, registrar pagos, dar de baja, ingresos por mes y por plan, lo esperado por mes); los vencimientos corren solos todas las noches. ✅ 2.1 (D111): **Planes → Personas** con los pedidos de "Quiero Pro / Familia" desde la app (activar o descartar), las suscripciones de las personas (la prueba de Familia marcada) y los mismos pagos y bajas.
- Quién paga qué plan, vencimientos y renovaciones.
- **Cobro manual al inicio** (transferencia o link de pago): registrar el pago y activar el plan.
- Suscripciones de usuarios (Pro, Familia) cobradas por las tiendas: estado sincronizado.
- Ingresos por mes y por plan.

### 8. Contenido — Fase 2
Noticias, promociones patrocinadas, eventos, directorio de Ayuda y textos de la app.
- **Noticias (hecho, D83):** sección Noticias con borrador / publicada / oculta, fuente, enlace, especies (ninguna = todas) y patrocinio con la marca obligatoria. En la app se ve "Promocionado · marca".
- **Banners (hecho, D128):** pestaña dentro de Noticias para el carrusel de arriba del Inicio: imagen apaisada 2:1 de hasta 1 MB, título, a dónde lleva (un enlace `https://` o una noticia publicada), orden, desde y hasta, y patrocinio con la marca obligatoria. Estado borrador / publicado / oculto.
- **Comunidad (hecho, D86):** pestaña dentro de Noticias con las novedades que se generan solas (reencuentros compartidos, adopciones, lugares verificados, eventos); un interruptor las oculta o las vuelve a mostrar, con registro de la acción.

### 9. Chapitas QR — Fase 1 (básico) / Fase 2 (completo)
- **Lotes:** generar códigos pre-codificados para fabricar (exportar la lista para el productor), con su material, costo y sponsor. ✅ 1.8b.1 (D95): sección **Chapitas** con "Nuevo lote" (1 a 500), activadas y escaneos por lote y "Descargar CSV" (`codigo,enlace`); el sponsor se suma en la Fase 2.
- **Pedidos:** estado (pedido → pagado → impreso → enviado → entregado) y forma de entrega (retiro en veterinaria o envío).
- **Puntos de retiro:** veterinarias adheridas, chapitas pendientes de retirar en cada una.
- **Stock** en veterinarias. ✅ 2.9 (D105): en cada lote, "Pasar a una veterinaria…" (solo verificadas, 1 a 200; muestra los códigos a entregar) y la sección "Stock en veterinarias" (recibidas, disponibles, activadas; "Quitar una").
- **Sponsors:** resultados por lote (activadas, escaneos, reencuentros) para el reporte al sponsor. ✅ 2.9 (D105): sección "Sponsors" (alta con logo y notas privadas, activo), "Sponsor del lote…" en cada lote y "Reporte" con descarga en CSV.

### 9b. Reportes para instituciones — Fase 2
Informes **agregados y anónimos** por zona para organismos con convenio (Zoonosis de Canelones, INBA): mapa de calor de perdidos y encontrados, reencuentros, adopciones, mascotas sin castrar o sin RENAC declarado, y asistencia a jornadas. Ver "Línea institucional" en `11-roadmap.md`.

### 10. Zonas — Fase 3
Habilitar zonas nuevas a medida que se expande, con sus métricas propias. ✅ 3.6 (D109): sección **Zonas** con usuarios, mascotas, lugares y SOS activos de cada una; "Nueva zona" con un rectángulo de coordenadas (sin geocodificar), apagada hasta que se prende.

### 11. Equipo y auditoría — Fase 3
Roles (admin, moderador, ventas) y registro de cada acción administrativa (quién, qué, cuándo). ✅ 3.6 (D109): sección **Equipo** (dar o quitar el rol por correo; moderación ve Moderación y Denuncias, ventas ve Lugares, Prospectos y Propuestas) y **Auditoría** (las últimas 500 acciones, por días y por acción). Cada integrante de moderación o ventas ve solo sus zonas, que se tildan en Equipo; sin zonas no ve nada (D110).

---

## Indicadores clave (KPIs)

| Grupo | Indicador |
|---|---|
| Crecimiento | Usuarios nuevos, usuarios activos por mes, mascotas cargadas, instalaciones de la PWA y la app |
| Retención | % de usuarios que vuelven a la semana y al mes, recordatorios activos por usuario |
| SOS | Reportes publicados, % resueltos, días hasta resolverse, escaneos de QR, avisos enviados |
| Empresas | Reclamos, verificadas, pagando, renovaciones, bajas, ingreso por empresa |
| Monetización | Conversión a Pro y Familia, ingreso mensual recurrente, punto de equilibrio |
| Demanda | Búsquedas por rubro y zona, búsquedas sin resultados |

Las metas por fase están en `11-roadmap.md`.
