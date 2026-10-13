# 05 · Portal de administración

Herramienta propia del administrador, y a futuro de un equipo. Tiene tres objetivos:
1. **Operar** la plataforma (moderación, verificación, carga de lugares).
2. **Demostrar resultados** a las empresas que confían en el producto.
3. **Generar visibilidad** para captar empresas nuevas con datos concretos.

## Evolución

- **Fase 0:** sin portal propio. Se usa el **panel de Supabase** para moderar reportes, ocultar contenido y cargar las veterinarias de urgencia. **Los eventos de métricas se registran desde el día 1** (ver `08-arquitectura.md`), aunque los paneles se programen después.
- **Fase 1:** portal v1 en **Flutter Web** con moderación, empresas, lugares, indicadores generales y mini CRM.
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
- Editar fichas y fusionar duplicados.

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
- **Reporte mensual automático** (PDF o email) para enviar a la empresa.
- **Casos de éxito:** testimonios con números, para usar en ventas.

### 6. Captación de empresas — Fase 1 (CRM) / Fase 2 (datos y propuestas)
*Objetivo: llegar a un comercio con datos concretos, no con una promesa.*

- **Demanda sin cubrir:** búsquedas por rubro y zona contra la oferta en el mapa. Ejemplo: *"En Pando, 85 personas buscaron 'peluquería' este mes y hay solo 1 en el mapa"*. Se basa en el evento `search` con resultados en cero.
- **Lugares sin reclamar con tracción:** cuántos usuarios lo marcaron y cuántas veces se abrió su ficha. Ejemplo: *"Marcado por 23 usuarios, 140 aperturas de ficha"*.
- **Audiencia por zona y especie:** usuarios y mascotas (*"1.200 perros, 400 gatos"*). Sirve para comercios y para **marcas** (noticias patrocinadas).
- **Embudo de ventas (mini CRM):** prospecto → contactado → demo → Socio Fundador → pagando → renovó / perdido. Con notas, responsable y fecha del próximo contacto.
- **Generador de propuesta:** PDF de una página con los datos de su zona y rubro, listo para mostrar en una visita.

### 7. Planes y cobros — Fase 2
- Quién paga qué plan, vencimientos y renovaciones.
- **Cobro manual al inicio** (transferencia o link de pago): registrar el pago y activar el plan.
- Suscripciones de usuarios (Pro, Familia) cobradas por las tiendas: estado sincronizado.
- Ingresos por mes y por plan.

### 8. Contenido — Fase 2
Noticias, promociones patrocinadas, eventos, directorio de Ayuda y textos de la app.

### 9. Chapitas QR — Fase 1 (básico) / Fase 2 (completo)
- **Lotes:** generar códigos pre-codificados para fabricar (exportar la lista para el productor), con su material, costo y sponsor.
- **Pedidos:** estado (pedido → pagado → impreso → enviado → entregado) y forma de entrega (retiro en veterinaria o envío).
- **Puntos de retiro:** veterinarias adheridas, chapitas pendientes de retirar en cada una.
- **Stock** en veterinarias.
- **Sponsors:** resultados por lote (activadas, escaneos, reencuentros) para el reporte al sponsor.

### 9b. Reportes para instituciones — Fase 2
Informes **agregados y anónimos** por zona para organismos con convenio (Zoonosis de Canelones, INBA): mapa de calor de perdidos y encontrados, reencuentros, adopciones, mascotas sin castrar o sin RENAC declarado, y asistencia a jornadas. Ver "Línea institucional" en `11-roadmap.md`.

### 10. Zonas — Fase 3
Habilitar zonas nuevas a medida que se expande, con sus métricas propias.

### 11. Equipo y auditoría — Fase 3
Roles (admin, moderador, ventas) y registro de cada acción administrativa (quién, qué, cuándo).

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
