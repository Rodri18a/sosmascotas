# PROGRESO · SOS Mascota

> **Cómo se usa:** cada paso es una tarea chica (1–4 h) con un resultado que se puede comprobar.
> Al terminar un paso: marcarlo `[x]`, anotar la fecha y mover el marcador **← ESTÁS ACÁ** al siguiente.
> 🧪 = paso sin código (validación o gestión) · 💳 = implica un gasto · ⏱️ = horas estimadas
> Las fases 2 a 4 se detallan en pasos cuando se llegue a ellas.

## Resumen

| Fase | Estado | Horas estimadas | Horas hechas |
|---|---|---|---|
| 0 · SOS | 🔄 En curso | ~145 h (≈ 45 sin código + ≈ 100 de desarrollo) | ≈ 5 h (pasos que se estimaron en 23,5 h) |
| 1 · MVP | ⏳ | ~160 h | 0 |
| 2 · Monetización | ⏳ | a detallar | 0 |
| 3 · Servicios | ⏳ | a detallar | 0 |
| 4 · Escala | ⏳ | a detallar | 0 |

**Paso actual:** 0.4.5 (desarrollo) · validación pendiente desde 0.0.2

### Horas reales vs. estimadas (calibración)

Las estimaciones son para una persona programando sola. Con Claude, el desarrollo va más rápido; la validación, la gestión y los plazos externos (tiendas, asesoría legal, pruebas de la chapita) no cambian. **No se reescalan las estimaciones hasta terminar la Etapa 0.5** (mapa, la más incierta).

| Etapa | Estimado | Real | Proporción | Notas |
|---|---|---|---|---|
| 0.1 · Base técnica (0.1.2–0.1.7) | 10,5 h | ≈ 2 h 45 min | ≈ 4× | Compilación web lenta en esta máquina (7–15 min con 3,4 GB de RAM) |
| 0.2 · Cuentas (0.2.1–0.2.6) | 13 h | ≈ 1 h 30 min + ≈ 30 min del dueño (Supabase y Google) | ≈ 6× | Terreno conocido (login, tablas) |
| **Total** | **23,5 h** | **≈ 5 h** | **≈ 4–5×** | |

Regla de trabajo: **por cada etapa de desarrollo, avanzar al menos un paso de validación (Etapa 0.0)**, para que el código no se adelante a lo que confirman las entrevistas.

---

## FASE 0 · SOS — objetivo: diciembre de 2026, antes de los fuegos artificiales

**Meta para pasar a la Fase 1:** 300 usuarios registrados, 20 reportes, primeros reportes resueltos, 50 QR generados.

### Etapa 0.0 · Documentación y validación (en paralelo al desarrollo)
- [x] 0.0.0 Documentación del proyecto (`CLAUDE.md` + `docs/`) — 12/10/2026
- [x] 0.0.1 🧪 Repasar la documentación y anotar correcciones (⏱️ 2 h) — 12/10/2026
- [ ] 0.0.2 🧪 Descargar y probar Taponto y uno o dos competidores; anotar qué hacen bien y mal en `investigacion/competencia.md` (⏱️ 2 h) 🔁 *validación pendiente, en paralelo al desarrollo*
- [ ] 0.0.3 🧪 Listar 30 comercios de Pando (nombre, rubro, dirección, horario, contacto). Empezar por los 8 operadores RENAC de la zona (`investigacion/renac.md`) (⏱️ 3 h)
- [ ] 0.0.4 🧪 Marcar cuáles atienden urgencias u horario extendido (para la capa de la Fase 0) (⏱️ 1 h)
- [ ] 0.0.5 🧪 Juntar refugios, protectoras y grupos de Facebook/WhatsApp de Pando (directorio de Ayuda y difusión) (⏱️ 1 h)
- [ ] 0.0.6 🧪 Revisar y ajustar el guion de entrevistas (borrador en `investigacion/entrevistas.md`) (⏱️ 1 h)
- [ ] 0.0.7 🧪 Entrevistar a 10 dueños de mascotas (⏱️ 5 h)
- [ ] 0.0.8 🧪 Mostrar el prototipo a 5–8 comercios y anotar candidatos a Socios Fundadores (⏱️ 6 h)
- [ ] 0.0.8b 🧪 Analizar las entrevistas en `investigacion/entrevistas.md` y aplicar los **criterios de corte** de `11-roadmap.md` (⏱️ 2 h)
- [ ] 0.0.9 🧪 Decidir los pendientes P1 (nombre) y P2 (horas por semana). Verificar que el nombre esté libre en DNPI, tiendas de apps y dominios (⏱️ 2 h)
- [ ] 0.0.9b 🧪 Identidad mínima: logo simple, colores y tipografía. **Requisito antes de imprimir chapitas o volantes** (⏱️ 3 h)
- [ ] 0.0.9c 🧪 💳 Pedir presupuesto a una **asesoría legal** (términos, privacidad, registro URCDP, compromiso de adopción) y enviarle el borrador (ya escrito: `app/assets/legal/terminos.md` y `privacidad.md`). **Arrancar temprano: puede llevar semanas** (⏱️ 2 h)
- [ ] 0.0.9d 🧪 Consultar con un **contador** cómo formalizar (unipersonal, SAS u otra), DGI, BPS, facturación electrónica: costo y plazos. **Requisito antes del primer cobro**, sea de chapitas, sponsors o planes (⏱️ 1 h)
- [ ] 0.0.10 🧪 Prototipo de chapita con el amigo de impresión 3D: 3–5 muestras con distintos materiales y métodos de QR, costo por unidad y tiempo por lote (P15) (⏱️ 2 h)
- [ ] 0.0.11 🧪 Prueba de durabilidad: usar las muestras 2–3 semanas y escanearlas con varios celulares (⏱️ 1 h)

### Etapa 0.1 · Base técnica
- [x] 0.1.1 Inicializar git, `.gitignore` (incluye `.env`) y primer commit con la documentación (⏱️ 0,5 h) — 13/10/2026, repo privado en GitHub
- [x] 0.1.2 Crear el proyecto Supabase de **desarrollo** (gratis) y activar PostGIS (⏱️ 0,5 h) — 13/10/2026, `sosmascotas-dev` en São Paulo
- [x] 0.1.3 Crear el proyecto Flutter con la estructura de `08-arquitectura.md`, lints, flavors dev/prod y elegir la gestión de estado (⏱️ 3 h) — 13/10/2026, Riverpod + go_router (D45)
- [x] 0.1.4 Conectar Flutter con Supabase usando variables por entorno (⏱️ 1 h) — 13/10/2026, indicador de conexión en dev
- [x] 0.1.5 Tema (verde `#1f8a5b`, claro/oscuro), navegación base con barra inferior y pantalla del logo (⏱️ 3 h) — 13/10/2026, pestañas Mapa · SOS · Mis mascotas · Ayuda (D47)
- [x] 0.1.6 Configurar i18n (español rioplatense) sin textos fijos en el código (⏱️ 1 h) — 13/10/2026, `app_es.arb` + prueba que bloquea textos fijos (D48)
- [x] 0.1.7 Migraciones iniciales: `zones` (Pando) y `events` + helper `track()` (⏱️ 2 h) — 13/10/2026, RLS probado con 9 casos; `app_open` llega a la base (D49)

### Etapa 0.2 · Cuentas
- [x] 0.2.1 Tabla `profiles` y `private_contacts` + RLS + trigger de creación de perfil (⏱️ 2 h) — 14/10/2026, 22 pruebas de seguridad en `supabase/tests/rls_test.py`
- [x] 0.2.2 Login con correo y enlace mágico (⏱️ 2 h) — 14/10/2026, enlace + código de 6 números (D50)
- [x] 0.2.3 Login con Google (⏱️ 3 h) — 14/10/2026, credenciales de Google creadas y activadas con `configurar_auth.py` (app de Google en modo Prueba: solo usuarios de prueba)
- [x] 0.2.4 Modo visitante: ver sin cuenta; al actuar, pedir login y volver a la acción (⏱️ 2 h) — 14/10/2026, `abrirConCuenta()` + rutas que requieren cuenta
- [x] 0.2.5 Textos de términos y privacidad + consentimiento al registrarse (⏱️ 2 h) — 14/10/2026, borradores en `app/assets/legal/` para la asesoría (D51)
- [x] 0.2.6 Ajustes: perfil, radio de avisos, cerrar sesión, **borrar mi cuenta** (⏱️ 2 h) — 14/10/2026, Edge Function `delete-account` (D52)

### Etapa 0.3 · Mascotas
- [x] 0.3.1 Seed de `species` y `breeds` (⏱️ 2 h) — 14/10/2026, 10 especies y ~60 razas (Mestizo y Cimarrón uruguayo primero)
- [x] 0.3.2 Tabla `pets` + RLS + bucket de fotos con límite de tamaño (⏱️ 1 h) — 14/10/2026, bucket `pet-photos` (JPEG/WebP ≤ 2 MB, carpeta por usuario); borrar cuenta también borra las fotos
- [x] 0.3.3 Alta y edición de mascota con foto comprimida y sin metadatos de ubicación (EXIF) (⏱️ 4 h) — 14/10/2026, `prepararFoto()` probado con una foto con GPS
- [x] 0.3.4 Pantalla "Mis mascotas": lista, ficha y fila superior de mascotas (⏱️ 3 h) — 14/10/2026. **Etapa 0.3 terminada**

### Etapa 0.4 · Chapita QR
- [x] 0.4.1 Tabla `qr_tags` + código único automático por mascota (⏱️ 1 h) — 14/10/2026, código de 8 caracteres sin ambiguos, `regenerar_qr()` y `public_pet_page()`
- [x] 0.4.2 Mostrar, descargar e imprimir el QR desde la ficha (⏱️ 2 h) — 14/10/2026, cartel PNG para imprimir, nota pública y cambiar código
- [x] 0.4.3 Página pública liviana `/m/<código>` (foto, nombre, datos elegidos) (⏱️ 3 h) — 14/10/2026, `web-publica/` en HTML+JS sin frameworks; demo con `supabase/tests/datos_demo.py`
- [x] 0.4.4 **Contacto inverso:** tabla `owner_alerts` + formulario "Avisar a mi familia" (sin cuenta, con anti-bots) + Edge Function `owner-alert` con límites + bandeja "Avisos" del dueño con consejo anti-estafa (⏱️ 5 h) — 14/10/2026, Edge Function `owner-alert` (Turnstile, 5/h por dispositivo, 10/h por destino, bloqueo por estafa), formulario en la página del QR (probado en navegador real) y bandeja Avisos
- [ ] 0.4.4b Email de respaldo de los avisos (SMTP en Supabase con proveedor gratis) **+ correos de login en español con código** (`python3 -I supabase/configurar_auth.py --aplicar`). **Obligatorio antes del lanzamiento**: sin SMTP propio Supabase manda 2 correos por hora y en inglés (⏱️ 1 h)
- [ ] 0.4.5 Registrar los escaneos (`qr_scans`) con ubicación opcional compartida (⏱️ 1 h) **← ESTÁS ACÁ**

### Etapa 0.5 · SOS
- [ ] 0.5.1 Tablas `sos_reports`, `sos_photos`, `flags` + RLS + ubicación pública aproximada (⏱️ 2 h)
- [ ] 0.5.2 Capa propia `MapView` + implementación web con MapLibre/OSM (elegir proveedor de teselas, P6) (⏱️ 4 h)
- [ ] 0.5.3 Formulario de reporte perdida/encontrada (precarga de mascota propia, foto, ubicación tocando el mapa) (⏱️ 4 h)
- [ ] 0.5.4 Mapa y lista de reportes por cercanía, cargando solo la zona visible (⏱️ 4 h)
- [ ] 0.5.5 Detalle del reporte + "Avisar al dueño" (contacto inverso) + página pública para compartir + consejos de microchip y RENAC + WhatsApp directo opcional (desactivado por defecto) (⏱️ 3 h)
- [ ] 0.5.6 Marcar "¡Apareció!" y archivar; la página del QR muestra "Estoy perdido 🆘" si hay un SOS activo (⏱️ 2 h)
- [ ] 0.5.7 Botón "Reportar" + ocultamiento automático con 3 reportes + límite de 3 SOS por día (⏱️ 3 h)

### Etapa 0.6 · Avisos
- [ ] 0.6.1 Proyecto Firebase (gratis) + push web en la PWA + guardar `push_tokens` (⏱️ 3 h)
- [ ] 0.6.2 Pedir permiso de ubicación y guardar la zona aproximada del usuario (⏱️ 2 h)
- [ ] 0.6.3 Edge Function: nuevo SOS → push a los usuarios a 5 km o menos, con tope diario (⏱️ 3 h)
- [ ] 0.6.4 Push al dueño cuando escanean el QR de su mascota (⏱️ 1 h)

### Etapa 0.7 · Veterinarias de urgencia y Ayuda
- [ ] 0.7.1 Tabla `businesses` mínima + cargar las veterinarias de 0.0.4 desde Supabase (⏱️ 2 h)
- [ ] 0.7.2 Capa en el mapa + ficha (horario, "abierto ahora", llamar, cómo llegar) (⏱️ 3 h)
- [ ] 0.7.3 Pestaña Ayuda: `help_directory` + aviso del 911 (⏱️ 1 h)

### Etapa 0.8 · Lanzamiento
- [ ] 0.8.1 PWA instalable (manifest, íconos, pantalla de instalación) (⏱️ 2 h)
- [ ] 0.8.2 Pruebas de recorrido: registro, mascota, QR, SOS, contacto (⏱️ 4 h)
- [ ] 0.8.3 Prueba con 5–10 conocidos y corrección de errores (⏱️ 4 h)
- [ ] 0.8.4 🧪 Cierre de la revisión legal iniciada en 0.0.9c: aplicar las correcciones a términos y privacidad (P10) (⏱️ 2 h)
- [ ] 0.8.5 Proyecto Supabase de **producción** + migraciones + respaldo (⏱️ 1 h)
- [ ] 0.8.6 💳 Comprar el dominio `sosmascotas.uy` + publicar en Cloudflare Pages o Vercel (⏱️ 2 h)
- [ ] 0.8.6b **Canal de soporte:** email `soporte@` del dominio (reenvío gratis, por ejemplo Cloudflare Email Routing) + WhatsApp Business, visible en Ajustes y en la página del QR. Respuesta en menos de 24 h, con **guardia especial del 24/12 al 2/1** (fuegos artificiales) (⏱️ 2 h)
- [ ] 0.8.7 🧪 Material de difusión: volante con QR + primer lote de 30–50 chapitas para regalar en el lanzamiento (se vinculan a mano desde Supabase hasta que exista la activación en la Fase 1) (⏱️ 2 h)
- [ ] 0.8.8 🧪 Lanzamiento: publicar en los grupos de Pando, veterinarias y protectoras (⏱️ 2 h)
- [ ] 0.8.9 💳 (Opcional) Cuenta de Google Play + iniciar la prueba cerrada con 12 testers para publicar Android en enero (⏱️ 2 h)

### Etapa 0.9 · Después del lanzamiento
- [ ] 0.9.1 🧪 Revisar las métricas semanales en Supabase (registros, SOS, QR) (⏱️ 1 h/semana)
- [ ] 0.9.2 🧪 Evaluar la meta de la Fase 0 y decidir si se pasa a la Fase 1 (⏱️ 1 h)
- [ ] 0.9.3 🧪 Preparar una propuesta de 1 página para Zoonosis de Canelones con las métricas de la Fase 0 y pedir una reunión (P17) (⏱️ 3 h)

---

## FASE 1 · MVP — objetivo: marzo–abril de 2027

**Meta para pasar a la Fase 2:** 1.500 usuarios activos por mes, 15 Socios Fundadores, 30% de usuarios con algún recordatorio activo.

### Etapa 1.1 · Apps nativas
- [ ] 1.1.1 Ajustes de Android (íconos, permisos, push nativo) (⏱️ 3 h)
- [ ] 1.1.2 Publicar en Google Play al terminar la prueba cerrada (⏱️ 2 h)
- [ ] 1.1.3 💳 Cuenta de Apple Developer + login con Apple (⏱️ 3 h)
- [ ] 1.1.4 Ajustes de iPhone y envío a revisión de App Store (⏱️ 4 h)

### Etapa 1.2 · Mapa integral
- [ ] 1.2.1 💳 Google Cloud: clave restringida, alerta de presupuesto y tope (pide tarjeta, sin costo) (⏱️ 1 h)
- [ ] 1.2.2 Implementación móvil de `MapView` con Google Maps nativo (⏱️ 3 h)
- [ ] 1.2.3 Capas y categorías + filtros (categoría, especie, distancia) (⏱️ 4 h)
- [ ] 1.2.4 Horario estructurado + "Abierto ahora" + orden de la lista (⏱️ 3 h)
- [ ] 1.2.5 Regla de coincidencia por especie y opción "Todas" (⏱️ 2 h)
- [ ] 1.2.6 Clusters y caché de pines (⏱️ 3 h)
- [ ] 1.2.7 Vistas Lista y "Sin local" (⏱️ 3 h)
- [ ] 1.2.8 Favoritos, "fui" y "es mi veterinaria" (`user_places`) (⏱️ 2 h)

### Etapa 1.3 · Empresas en la app
- [ ] 1.3.1 Ampliar `businesses` + fotos + contactos privados (⏱️ 2 h)
- [ ] 1.3.2 Marcar lugares sin reclamar (`place_marks`) y agruparlos (⏱️ 3 h)
- [ ] 1.3.3 Alta de negocio (opción C): tipo, datos, ubicación o zona de cobertura (⏱️ 4 h)
- [ ] 1.3.4 Reclamar un lugar sin reclamar + solicitud de verificación con RUT (⏱️ 3 h)
- [ ] 1.3.5 Cambio a modo comercio + pantalla Negocio (editar ficha) (⏱️ 4 h)
- [ ] 1.3.6 Panel del comercio básico con los contadores de `events` (⏱️ 3 h)

### Etapa 1.4 · Chat híbrido y seguimiento
- [ ] 1.4.1 Tablas de chat + RLS + Realtime (⏱️ 3 h)
- [ ] 1.4.2 Pantallas de conversaciones y mensajes (texto, foto, ubicación) (⏱️ 5 h)
- [ ] 1.4.3 Chat desde SOS y desde la ficha de un negocio + WhatsApp opcional (⏱️ 2 h)
- [ ] 1.4.4 Bloquear y reportar + aviso de seguridad contra estafas (⏱️ 2 h)
- [ ] 1.4.5 Seguir un SOS y notificar novedades y resolución (⏱️ 3 h)

### Etapa 1.5 · Libreta y recordatorios
- [ ] 1.5.1 `health_records` + pantalla de la libreta sanitaria (⏱️ 4 h)
- [ ] 1.5.2 Semáforo de próximos controles (⏱️ 1 h)
- [ ] 1.5.2b Estado RENAC + guía "Cómo registrar a tu mascota" + botón "Verificar en el RENAC" (⏱️ 2 h)
- [ ] 1.5.3 `reminders` + notificaciones locales de medicación (⏱️ 4 h)
- [ ] 1.5.4 Recordatorios de alimentación y vacunas (⏱️ 2 h)
- [ ] 1.5.5 "✅ Ya se la di" + historial (`reminder_logs`) (⏱️ 2 h)
- [ ] 1.5.6 Funcionamiento sin internet de la ficha, la libreta y el QR (⏱️ 3 h)

### Etapa 1.6 · Hogar compartido (gratis por ahora)
- [ ] 1.6.1 `households` + `household_members` + invitación por enlace (⏱️ 4 h)
- [ ] 1.6.2 Mascotas y recordatorios compartidos con sincronización del "ya se la di" (⏱️ 4 h)
- [ ] 1.6.3 Tareas (paseo, comida) y registro de quién lo hizo (⏱️ 3 h)
- [ ] 1.6.4 Cuidador temporal con acceso por X días (⏱️ 2 h)

### Etapa 1.7 · Reseñas
- [ ] 1.7.1 Tabla `reviews` + regla de contacto real (⏱️ 2 h)
- [ ] 1.7.2 Escribir, ver y responder reseñas (⏱️ 3 h)

### Etapa 1.8 · Portal de administración v1 (Flutter Web)
- [ ] 1.8.1 Proyecto `admin/` + login con validación del rol en el servidor (⏱️ 3 h)
- [ ] 1.8.2 Panel general con los KPIs de `05-portal-admin.md` (⏱️ 5 h)
- [ ] 1.8.3 Cola de moderación + acciones + sanciones (⏱️ 4 h)
- [ ] 1.8.4 Empresas: verificación, reclamos, Socios Fundadores, insignia "Operador RENAC" + filtro "Coloca microchip" (⏱️ 5 h)
- [ ] 1.8.5 Lugares: carga manual y lugares sin reclamar con su tracción (⏱️ 3 h)
- [ ] 1.8.6 Mini CRM: `prospects` + embudo + notas + próximo contacto (⏱️ 4 h)
- [ ] 1.8.7 Demanda sin cubrir (búsquedas sin resultados por rubro y zona) (⏱️ 2 h)
- [ ] 1.8.8 Directorio de Ayuda: enlaces a las adopciones de cada refugio (⏱️ 1 h)

### Etapa 1.8b · Chapitas físicas
- [ ] 1.8b.1 `qr_batches` + generación de lotes pre-codificados y exportación para el productor (⏱️ 3 h)
- [ ] 1.8b.2 "Activar chapita": escanear y vincular a una mascota; desvincular (⏱️ 3 h)
- [ ] 1.8b.3 Página de código sin activar ("Activá esta chapita con la app") (⏱️ 1 h)
- [ ] 1.8b.4 Pedido con retiro en la veterinaria asociada + marcar entregada desde el modo comercio (⏱️ 4 h)

### Etapa 1.9 · Socios Fundadores y cierre
- [ ] 1.9.0 🧪 💳 **Formalizar la actividad** según lo averiguado en 0.0.9d. Debe estar hecho antes del primer cobro (⏱️ 3 h de gestión)
- [ ] 1.9.1 🧪 Visitar comercios con datos de la Fase 0 y sumar Socios Fundadores (⏱️ 8 h)
- [ ] 1.9.2 Pruebas de recorrido de todos los flujos nuevos (⏱️ 4 h)
- [ ] 1.9.3 💳 Pasar Supabase a Pro si hace falta (⏱️ 0,5 h)
- [ ] 1.9.4 🧪 Evaluar la meta de la Fase 1 (⏱️ 1 h)

---

## FASE 2 · Monetización — mediados de 2027 (etapas, a detallar en pasos)
- [ ] 2.0 Adopción responsable: guía, calculadora, perfil de adoptante, publicación (refugios con aporte, particulares con límites), compatibilidad, proceso por etapas, compromiso, seguimiento 7/30/90
- [ ] 2.1 Planes Pro y Familia con suscripción dentro de la app
- [ ] 2.2 Planes Destacado y Plus con cobro manual + `subscriptions` y `payments`
- [ ] 2.3 Estadísticas para empresas (`daily_stats`) + reporte mensual automático
- [ ] 2.4 Generador de propuestas y casos de éxito en el portal de administración
- [ ] 2.5 Promociones, catálogo con "Consultar" y módulos según el plan
- [ ] 2.6 Módulo Socios de la veterinaria con recordatorios
- [ ] 2.6b "Busco veterinaria": consentimiento, propuestas y resultados
- [ ] 2.7 Eventos, lugares que aceptan mascotas, denuncias de maltrato
- [ ] 2.8 Noticias con contenido patrocinado
- [ ] 2.9 Chapitas: programa de sponsors (logo, reporte por lote), stock en veterinarias, venta de diseños personalizados
- [ ] 2.10 Portal web de empresas v1
- [ ] 2.11 Filtros guardados, personalización, descuentos, historial en PDF

## FASE 3 · Servicios — fin de 2027 (etapas)
- [ ] 3.1 Agenda de turnos
- [ ] 3.2 Pedidos
- [ ] 3.3 Contratación de paseadores, hoteles y cuidadores
- [ ] 3.4 Comunidad por raza y especie (grupos, publicaciones, saludo previo al chat)
- [ ] 3.4b Adopción: pack adopción de empresas, apadrinamiento y hogares de tránsito
- [ ] 3.5 Portal de empresas completo (agenda, pedidos, socios, equipo)
- [ ] 3.6 Zonas, roles y auditoría en el portal de administración
- [ ] 3.7 🎆 Campaña de fin de año 2027

## FASE 4 · Escala — 2028 (etapas)
- [ ] 4.1 Pagos con Mercado Pago + comisión
- [ ] 4.2 Tienda tipo marketplace
- [ ] 4.3 Nuevas zonas y países, portugués e inglés, varias monedas

---

## Registro

| Fecha | Paso | Nota |
|---|---|---|
| 12/10/2026 | 0.0.0 | Documentación inicial creada |
| 12/10/2026 | 0.0.1 | Sumados "Busco veterinaria" (Fase 2) y comunidad por raza (Fase 3). "Compañeros de paseo" en espera y cruzas excluidas (D25–D28) |
| 12/10/2026 | 0.0.1 | Pro y Familia sin repreguntas de "Busco veterinaria" (D29) |
| 12/10/2026 | 0.0.1 | Web de documentación (`ver-docs.sh`) |
| 12/10/2026 | 0.0.1 | ✅ Paso cerrado |
| 13/10/2026 | 0.1.1 | Repositorio privado en GitHub (`Rodri18a/sosmascotas`), adelantado para trabajar desde otra máquina |
| 13/10/2026 | — | Repo privado; documentación desde GitHub; Cloudflare preparado y pendiente (D44) |
| 13/10/2026 | 0.1.3 | ✅ Proyecto Flutter (`app/` + `packages/core`), Riverpod + go_router, reglas estrictas, entornos por archivo; pruebas y build web OK (D45). El desarrollo arranca antes de cerrar la validación |
| 13/10/2026 | 0.1.2 | ✅ Supabase dev (`sosmascotas-dev`, São Paulo, Free) + PostGIS; migración en `supabase/migrations/`. Claves solo en `app/config/dev.json` (ignorado) |
| 13/10/2026 | 0.1.4 | ✅ `supabase_flutter` conectado a `sosmascotas-dev` (probado en el navegador). Variable renombrada a `SUPABASE_PUBLISHABLE_KEY` (D46) |
| 13/10/2026 | 0.1.5 | ✅ Tema claro/oscuro, barra inferior con 4 pestañas que conservan su estado, Ajustes desde arriba, pantalla de carga verde (web y Android), direcciones limpias `/mapa`, `/sos`… (D47) |
| 13/10/2026 | 0.1.6 | ✅ Textos en `app/lib/l10n/app_es.arb` (voseo), idioma `es_UY`, acceso `context.t`; prueba que falla si aparece un texto escrito en una pantalla (D48) |
| 13/10/2026 | 0.1.7 | ✅ Supabase CLI 2.118.0 vinculado a dev (credenciales en `~/.config/sosmascotas/supabase-dev.env`). Migraciones `zones` (Pando) + `events` aplicadas; RLS verificado; `track()` con id anónimo por instalación (D49). **Etapa 0.1 terminada** |
| 14/10/2026 | 0.2.1 | ✅ `profiles` (se crea solo al registrarse; plan y rol no editables desde la app) y `private_contacts` (nadie la lee desde la app). Script de pruebas de seguridad con cuentas temporales |
| 14/10/2026 | 0.2.2 | ✅ Pantalla Ingresar (correo → enlace o código de 6 números, sin contraseña), vuelve a la acción; cerrar sesión. Config de login versionada en `supabase/configurar_auth.py`. Los correos en español requieren SMTP propio (pasado a 0.4.4b) (D50) |
| 14/10/2026 | 0.2.3 | ⏳ Botón "Continuar con Google" listo: aparece solo si Google está activo en Supabase. Activación con `configurar_auth.py` cuando estén las credenciales (guía en `docs/guias/login-google.md`) |
| 14/10/2026 | 0.2.4 | ✅ Visitante ve todo; al tocar "Reportar" o "Agregar mascota" se explica por qué hace falta cuenta y, después de ingresar, llega directo a la acción. Enlaces directos a acciones también piden ingresar |
| 14/10/2026 | 0.2.5 | ✅ Borradores de términos y privacidad (voseo, Ley 18.331) visibles en la app; pantalla de consentimiento obligatoria con casilla al crear la cuenta y al cambiar la versión; evento `signup` (D51) |
| 14/10/2026 | 0.2.6 | ✅ Ajustes: nombre, radio de avisos (1–20 km), textos legales, cerrar sesión y borrar mi cuenta con confirmación. Edge Function `delete-account` probada en el servidor (borra login, perfil y teléfono; eventos quedan anónimos) (D52). **Etapa 0.2 terminada** salvo activar Google (0.2.3) |
| 14/10/2026 | 0.2.3 | ✅ Google activado en Supabase dev; el servidor redirige bien a Google. Antes del lanzamiento: publicar la app de Google (salir de modo Prueba) y sumar el dominio |
| 14/10/2026 | — | Calibración: 0.1 y 0.2 llevaron ≈ 5 h reales contra 23,5 h estimadas. Se recalibra después de la 0.5. Regla: intercalar un paso de validación por etapa (D53) |
| 14/10/2026 | 0.3.1–0.3.4 | ✅ Especies y razas, tabla `pets` + fotos, formulario de alta/edición (foto achicada y **sin EXIF**), lista con fila superior (mascota activa) y ficha. Arreglado: el formulario no validaba campos fuera de pantalla |
| 13/10/2026 | 0.0.2 | Análisis de puntos débiles: contacto inverso en lugar de redirección a WhatsApp; pasos nuevos de identidad, legal temprano, formalización, soporte y criterios de corte (D41–D43) |
| 12/10/2026 | 0.0.2 | Sin combo de microchip (D39). Línea institucional: Zoonosis de Canelones → nacional → mundial (D40) |
| 12/10/2026 | 0.0.2 | Chapitas pre-codificadas, retiro en veterinaria, sponsors y prototipo con impresión 3D (D35–D38) |
| 12/10/2026 | 0.0.2 | Investigación de competencia (`investigacion/competencia.md`) y del RENAC (`investigacion/renac.md`, D33–D34) |
| 12/10/2026 | 0.0.1 | Adopción responsable: directorio en Fase 1, proceso completo como primera etapa de la Fase 2, packs y tránsito en Fase 3 (D30–D32) |
