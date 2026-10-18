# PROGRESO · SOS Mascota

> **Cómo se usa:** cada paso es una tarea chica (1–4 h) con un resultado que se puede comprobar.
> Al terminar un paso: marcarlo `[x]`, anotar la fecha y mover el marcador **← ESTÁS ACÁ** al siguiente.
> 🧪 = paso sin código (validación o gestión) · 💳 = implica un gasto · ⏱️ = horas estimadas
> Las fases 2 a 4 se detallan en pasos cuando se llegue a ellas.

## Resumen

| Fase | Estado | Horas estimadas | Horas hechas |
|---|---|---|---|
| 0 · SOS | 🔄 En curso | ~145 h (≈ 45 sin código + ≈ 100 de desarrollo) | ≈ 10,5 h (pasos que se estimaron en 35,5 h) |
| 1 · MVP | ⏳ | ~160 h | 0 |
| 2 · Monetización | ⏳ | a detallar | 0 |
| 3 · Servicios | ⏳ | a detallar | 0 |
| 4 · Escala | ⏳ | a detallar | 0 |

**Paso actual:** 0.8.1 (desarrollo) · pendiente del dueño: 0.4.4b (proveedor de correo) · validación pendiente desde 0.0.2

> ▶️ Retomado el 16/10/2026 (se había pausado el 15/10). La lista de abajo sigue siendo el orden sugerido.

## Pendientes al retomar (15/10/2026)

Lo que quedó pedido o decidido en la última sesión y todavía no está hecho. Cada ítem dice dónde está su detalle.

1. ~~Elegir la identidad visual~~ ✅ 15/10: **C · Cielo** (D62). Falta **generar el logo y las piezas** con el prompt de `docs/14-brief-identidad-visual.md` §8 (IA o diseñador) para cerrar el 0.0.9b.
2. ~~Aplicar la identidad a la interfaz~~ ✅ 0.8.0 (15/10) y 0.8.0a, temas Pro (16/10).
3. ~~Aprobar la habilitación gradual~~ ✅ 16/10 (D64). Falta implementar los pasos **0.8.0b–0.8.0e** (abajo) antes del lanzamiento.
4. **0.8.1 PWA instalable**: el plan ya está acordado (ver el paso). Conviene hacerlo **después** del 0.8.0, así los íconos ya son los definitivos.
5. **Validación del dueño** que destraba datos reales:
   - **0.0.4** → completar `investigacion/veterinarias.csv` y cargar con `supabase/cargar_comercios.py` (sin `--aplicar` valida; con `--aplicar` reemplaza las 5 de ejemplo).
   - **0.0.5** → completar `investigacion/ayuda.csv` y cargar con `supabase/cargar_ayuda.py` (igual).
   - **0.4.4b** (proveedor de correo) y el resto de la Etapa 0.0.
6. ~~Otra máquina~~ ✅ 15/10: la versión vieja del 0.6.2 quedó en `git stash` y se actualizó a `main`.
7. **Recordatorios técnicos** (también en `CLAUDE.md`): en Windows, al cortar `flutter run` puede quedar un `dartvm` en el puerto 3001; con Firebase configurado, cada corrida de `rls_test.py` manda una push de prueba a las cuentas reales de dev con zona en Pando.

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
- [ ] 0.0.4 🧪 Marcar cuáles atienden urgencias u horario extendido (para la capa de la Fase 0) (⏱️ 1 h) → volcarlas en `investigacion/veterinarias.csv` (formato en `supabase/cargar_comercios.py`) y cargarlas
- [ ] 0.0.5 🧪 Juntar refugios, protectoras y grupos de Facebook/WhatsApp de Pando (directorio de Ayuda y difusión) (⏱️ 1 h) → volcarlos en `investigacion/ayuda.csv` (formato en `supabase/cargar_ayuda.py`) y cargarlos
- [ ] 0.0.6 🧪 Revisar y ajustar el guion de entrevistas (borrador en `investigacion/entrevistas.md`) (⏱️ 1 h)
- [ ] 0.0.7 🧪 Entrevistar a 10 dueños de mascotas (⏱️ 5 h)
- [ ] 0.0.8 🧪 Mostrar el prototipo a 5–8 comercios y anotar candidatos a Socios Fundadores (⏱️ 6 h)
- [ ] 0.0.8b 🧪 Analizar las entrevistas en `investigacion/entrevistas.md` y aplicar los **criterios de corte** de `11-roadmap.md` (⏱️ 2 h)
- [ ] 0.0.9 🧪 Decidir los pendientes P1 (nombre) y P2 (horas por semana). Verificar que el nombre esté libre en DNPI, tiendas de apps y dominios (⏱️ 2 h)
- [ ] 0.0.9b 🧪 Identidad mínima: logo simple, colores y tipografía. **Requisito antes de imprimir chapitas o volantes** (⏱️ 3 h) → 15/10/2026: **elegida C · Cielo**, paleta, tipografías y pines definidos (D62, `docs/14-brief-identidad-visual.md` §10). **Falta:** generar el logo y las piezas con el prompt de la §8 (IA o diseñador) y guardarlas en `reference/identidad/`
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
- [x] 0.4.5 Registrar los escaneos (`qr_scans`) con ubicación opcional compartida (⏱️ 1 h) — 14/10/2026, botón en la página del QR (probado en Chrome) y "Últimos escaneos" en la app

### Etapa 0.5 · SOS
- [x] 0.5.1 Tablas `sos_reports`, `sos_photos`, `flags` + RLS + ubicación pública aproximada (⏱️ 2 h) — 14/10/2026, sin acceso directo (funciones `crear_sos`, `mis_sos`); punto público a 150–200 m; 3 por día; se oculta con 3 reportes
- [x] 0.5.2 Capa propia `MapView` + implementación web con MapLibre/OSM (elegir proveedor de teselas, P6) (⏱️ 4 h) — 14/10/2026, `MapaVista` + MapLibre con **OpenFreeMap** (D54). Falta verlo en una compilación web
- [x] 0.5.3 Formulario de reporte perdida/encontrada (precarga de mascota propia, foto, ubicación tocando el mapa) (⏱️ 4 h) — 14/10/2026, reusa la foto de la ficha; botón "Se perdió" en la ficha
- [x] 0.5.4 Mapa y lista de reportes por cercanía, cargando solo la zona visible (⏱️ 4 h) — 14/10/2026, `sos_en_zona()` (pines mínimos) + caché de zona 1,5×; `sos_cercanos()` con filtro
- [x] 0.5.5 Detalle del reporte + "Avisar al dueño" (contacto inverso) + página pública para compartir + consejos de microchip y RENAC + WhatsApp directo opcional (desactivado por defecto) (⏱️ 3 h) — 14/10/2026, `sos_publico()`, aviso desde la app (con sesión, sin anti-bots) y desde `/s/<id>` (probado en Chrome), WhatsApp opcional con advertencia
- [x] 0.5.6 Marcar "¡Apareció!" y archivar; la página del QR muestra "Estoy perdido 🆘" si hay un SOS activo (⏱️ 2 h) — 14/10/2026, `cerrar_sos()`, "Mis reportes" en la pestaña SOS; el QR enlaza al reporte
- [x] 0.5.7 Botón "Reportar" + ocultamiento automático con 3 reportes + límite de 3 SOS por día (⏱️ 3 h) — 14/10/2026, "Reportar publicación" en el detalle (motivo + detalle opcional, una vez por persona, evento `content_flag`); ocultamiento y límite ya estaban en la base desde 0.5.1. **Etapa 0.5 terminada**

### Etapa 0.6 · Avisos
- [x] 0.6.1 Proyecto Firebase (gratis) + push web en la PWA + guardar `push_tokens` (⏱️ 3 h) — 14/10/2026, código, migración y pruebas OK; prueba real: el mensaje de prueba de Firebase llega a Chrome (`localhost:3001`) y al tocarlo abre la app en Avisos. Ojo: en la consola de Firebase pegar el token **sin comillas** (si no, no se envía a nadie)
- [x] 0.6.2 Pedir permiso de ubicación y guardar la zona aproximada del usuario (⏱️ 2 h) — 15/10/2026, código, migración (`zona_avisos`, D56) y pruebas OK (app, núcleo y 160 de seguridad); prueba real en Chrome (`localhost:3001`): borrar y volver a guardar desde Ajustes, cartel al activar los avisos, la zona borrada no se vuelve a guardar sola al recargar, y en la base queda el centro de la celda con origen `gps`
- [x] 0.6.3 Edge Function: nuevo SOS → push a los usuarios a 5 km o menos, con tope diario (⏱️ 3 h) — 15/10/2026, migración `sos_avisos_zona`, función `sos-zone-alert` (D57), app y pruebas OK (95 app, 4 Deno, 171 de seguridad con Firebase configurado); prueba real: un SOS de prueba a ~2 km mandó la push "🐾 Se perdió un perro cerca tuyo" y llegó a Chrome. Secreto `FIREBASE_SERVICE_ACCOUNT` cargado en dev. Ojo: con Firebase configurado, cada corrida de `rls_test.py` le manda esa push a las cuentas reales de dev con zona en Pando
- [x] 0.6.4 Push al dueño cuando escanean el QR de su mascota (⏱️ 1 h) — 15/10/2026, migración `qr_scans_aviso`, función `qr-scan-alert` y push también en `owner-alert` (aviso con mensaje) (D58); pruebas OK (6 Deno, 178 de seguridad); prueba real: escanear el QR de una mascota de prueba en la web pública (`localhost:3002`) y enviar el formulario → llegaron a Chrome "📍 Escanearon el QR de…" y "💬 Alguien vio a… y te dejó un mensaje" (mascota de prueba borrada). **Cierra la Etapa 0.6**

### Etapa 0.7 · Veterinarias de urgencia y Ayuda
- [x] 0.7.1 Tabla `businesses` mínima + cargar las veterinarias de 0.0.4 desde Supabase (⏱️ 2 h) — 15/10/2026, migración `businesses` + `comercios_en_zona()` (D59), modelo `Comercio`/`Horario` en el núcleo, `ComerciosRepositorio` en la app, cargador `supabase/cargar_comercios.py`; pruebas OK (97 app, 42 núcleo, 186 de seguridad). **Cargadas 5 veterinarias de ejemplo** (solo dev); las reales quedan pendientes del 0.0.4: completar `investigacion/veterinarias.csv` y correr el cargador con `--aplicar`
- [x] 0.7.2 Capa en el mapa + ficha (horario, "abierto ahora", llamar, cómo llegar) (⏱️ 3 h) — 15/10/2026, "abierto ahora" con la hora de Uruguay en el núcleo, capa de veterinarias + leyenda, ficha con horario, Llamar / WhatsApp / Cómo llegar / web / Instagram, métricas `place_open`/`place_click` (FK `events.business_id`), cargador que conserva ids (D60); pruebas OK (101 app, 48 núcleo, 188 de seguridad); prueba real en Chrome con las 5 de ejemplo (abierta/cerrada según la hora, 24 h, horario de la semana, métricas registradas)
- [x] 0.7.3 Pestaña Ayuda: `help_directory` + aviso del 911 (⏱️ 1 h) — 15/10/2026, migración `help_directory` (lectura pública de los activos), cargador `supabase/cargar_ayuda.py` + 5 entradas de ejemplo (solo dev), pantalla con tarjeta del 911, veterinarias de urgencia con "abierto ahora" y directorio agrupado; métrica `help_click` (D61); pruebas OK (104 app, 50 núcleo, 194 de seguridad); prueba real en Chrome. Las reales quedan pendientes del 0.0.5 (`investigacion/ayuda.csv`). **Cierra la Etapa 0.7**

### Etapa 0.8 · Lanzamiento
- [x] 0.8.0 **Aplicar la identidad elegida en 0.0.9b** (C · Cielo, D62) a la interfaz: paleta (claro y oscuro) y tipografías en `app/lib/src/theme/app_theme.dart`, `coloresPin` (`app/lib/src/mapa/mapa_vista.dart`), pantalla de carga (`app/web/index.html`), web pública (`web-publica/assets/estilo.css`) y textos del brief (`docs/14-brief-identidad-visual.md` §9 y §10). Revisar contraste en modo claro y oscuro (⏱️ 3 h) — 15/10/2026, paleta `Paleta.cielo` + `ColoresMarca` (`app/lib/src/theme/paleta.dart`), tema con superficies derivadas de la paleta, Sora + Source Sans 3 incluidas en la app y en la web pública (sin pedidos a Google), pines nuevos con borde, "Se perdió" y "Reportar" en coral, "abierto ahora" y "urgencias" con colores que contrastan; pantalla de carga, manifest, Android y web pública con Cielo; prueba `tema_test.dart` (contraste ≥ 4,5:1 de cada rol y superficie, luminosidad de los pines). Pruebas OK (113 app, 50 núcleo); revisado en Chrome por el dueño
- [x] 0.8.0a **Temas Pro** (D62): los 4 temas (Cielo, Faro, Vecinos, Pop) como datos en el tema de la app, con prueba automática de contraste ≥ 4,5:1; selector "Tema" en Ajustes que solo se puede cambiar con plan Pro (los demás ven Cielo y el aviso de Pro); elección guardada en el dispositivo; tipografías de los temas Pro descargadas solo al elegirlos; si el plan vence, vuelve a Cielo. Mientras no haya cobro (Fase 2) queda detrás de la habilitación gradual, en beta (⏱️ 3 h) — 16/10/2026: Faro, Vecinos y Pop en `Paleta` (todas con contraste ≥ 4,5:1 en `tema_test.dart`), `tema_elegido.dart` (elección en el dispositivo, solo Pro/Familia, vuelve a Cielo si vence), tipografías Pro en `app/web/fuentes/` bajadas al elegir, selector en Ajustes, métrica `theme_change` (D63); pruebas OK (137 app, 50 núcleo); revisado en Chrome por el dueño con una cuenta de dev en plan Pro
- [x] 0.8.0b Habilitación gradual (`docs/15-funcionalidades-graduales.md` §10 a): migración `feature_flags` + `feature_flag_users` + `feature_flag_audit`, `funcionalidad_activa()` y `mis_funcionalidades()`, casos en `rls_test.py` (incluido el porcentaje estable) (⏱️ 3 h) — 16/10/2026, migración `20261016000000_feature_flags.sql` aplicada en dev: tres tablas sin acceso desde la app, historial por trigger, `funcionalidad_activa()` / `mis_funcionalidades()`, porcentaje con `cubeta_funcionalidad()` (MD5, mismo cálculo que tendrá `packages/core`), primera marca `temas_pro` en beta; 41 casos nuevos en `rls_test.py`, todo OK
- [x] 0.8.0c Habilitación gradual (§10 b): nombres de funcionalidades y cálculo del porcentaje en `packages/core`, con pruebas cruzadas contra la base (⏱️ 1 h) — 16/10/2026, `packages/core/lib/src/funcionalidades/funcionalidades.dart`: `Funcionalidades.temasPro`, `nombreDeFuncionalidadValido()`, `cubetaFuncionalidad()` y `entraEnPorcentaje()` con `crypto` (MD5); valores fijos en `funcionalidades_test.dart` (la base ≡ fórmula lo comprueba `rls_test.py`). Pruebas OK (137 app, 55 núcleo)
- [x] 0.8.0d Habilitación gradual (§10 c): en la app, proveedor, `SiFuncionalidad`, caché en el dispositivo, redirección de rutas, evento `feature_exposure` y pruebas (⏱️ 3 h) — 16/10/2026, `app/lib/src/funcionalidades/funcionalidades_activas.dart`: `funcionalidadesProvider` con `mis_funcionalidades()` (al abrir, al iniciar/cerrar sesión, cada 3 h y al volver a la app), caché en el dispositivo por cuenta, `SiFuncionalidad` + `funcionalidadActivaProvider`, `Rutas.conFuncionalidad` → pantalla "Todavía no está disponible" (vuelve sola si llega), `feature_exposure` solo cuando ya se sabe la variante, `versionApp`; `temas_pro` ya respeta la marca (cuenta de dev del dueño invitada). Pruebas OK (153 app, 55 núcleo)
- [x] 0.8.0e Habilitación gradual (§10 d): script `supabase/funcionalidades.py` para prender/apagar desde la terminal hasta que exista el panel (⏱️ 1 h) — 16/10/2026, comandos listar/ver/crear/etapa/porcentaje/regla/apagar/prender/invitar/excluir/quitar, valida antes de conectarse y solo escribe con `--aplicar`; 7 pruebas en `supabase/tests/funcionalidades_test.py`; probado en dev (apagar y prender `temas_pro`, invitar, historial). **Cierra la habilitación gradual antes del lanzamiento**
- [ ] 0.8.1 PWA instalable (manifest, íconos, pantalla de instalación) (⏱️ 2 h) — plan acordado el 15/10: (1) íconos propios (hoy son el logo de Flutter) generados con `app/tool/generar_iconos.dart` (paquete `image`; sin Pillow en esta PC), 192/512/maskable/180/favicon, con el diseño de 0.0.9b; (2) manifest con `id`, `scope`, `lang: es-UY`, descripción en voseo y accesos directos "Reportar mascota perdida" (`/sos/nuevo`) y "Mapa"; (3) invitación a instalar: Android/Chrome con `beforeinstallprompt` y botón propio, iPhone con instrucciones "Compartir → Agregar a inicio" (las push solo funcionan instalada), nada si ya está instalada; fila "Instalar la app" en Ajustes y tarjeta descartable en el mapa desde la 2.ª apertura; (4) métricas `pwa_prompt` y `pwa_installed`; (5) pruebas con un servicio de instalación falso y prueba real en Chrome. Al terminar: D65 **← ESTÁS ACÁ** — 16/10/2026 **en curso**: hecho en código (D65): íconos provisorios con `app/tool/generar_iconos.dart` (192/512/maskable/180/favicon), manifest con id/scope/lang/accesos directos, aviso del navegador guardado en `web/index.html` + `lib/src/instalar/`, fila en Ajustes, tarjeta del mapa desde la 2.ª apertura, pasos del iPhone, métricas `pwa_prompt`/`pwa_installed`; 11 pruebas nuevas (164 app, 55 núcleo). 17/10/2026: compilada y subida a https://sosmascota-dev.vercel.app (enlaces de QR y SOS ya apuntan a la web pública de Vercel). **Falta:** probar la instalación real en Chrome/Android y en el iPhone
- [ ] 0.8.2 Pruebas de recorrido: registro, mascota, QR, SOS, contacto (⏱️ 4 h) — 16/10/2026 **en curso**: recorridos automáticos en `app/test/recorrido_test.dart` (visitante → código → términos → mascota con foto → chapita QR → se perdió → publicar → compartir con el enlace de la web pública; escaneo de la chapita → aviso con los datos de quien la encontró → "Ya lo contacté"; ninguna configuración de ejemplo apunta a `localhost`). Pruebas OK (167 app, 55 núcleo). **Falta:** hacer el mismo recorrido a mano en el celular con la app online (sosmascota-dev.vercel.app), después de subir la compilación nueva
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
- [x] 1.4.1 Tablas de chat + RLS + Realtime (⏱️ 3 h) — 18/10/2026 (D73): migración `chat` (`conversations`, `conversation_members`, `messages`, `iniciar_chat_sos()`, `mis_conversaciones()`, bucket privado `chat-photos`, Realtime, reportes de mensajes); aplicada en dev, `rls_test.py` OK (337)
- [ ] 1.4.2 Pantallas de conversaciones y mensajes (texto, foto, ubicación) (⏱️ 5 h)
- [ ] 1.4.3 Chat desde SOS y desde la ficha de un negocio + WhatsApp opcional (⏱️ 2 h)
- [ ] 1.4.4 Bloquear y reportar + aviso de seguridad contra estafas (⏱️ 2 h)
- [ ] 1.4.5 Seguir un SOS y notificar novedades y resolución (⏱️ 3 h)

### Etapa 1.5 · Libreta y recordatorios
- [ ] 1.5.1 `health_records` + pantalla de la libreta sanitaria (⏱️ 4 h) — 17/10/2026 **adelantado y oculto** (D66), detrás de la funcionalidad `libreta`: migración `health_records` + casos en `rls_test.py`, modelo `RegistroSalud` en el núcleo, sección en la ficha y formulario (alta, edición, borrado), evento `health_record_create`; pruebas OK (174 app, 62 núcleo). migración aplicada en dev, `rls_test.py` OK (248 casos), marca `libreta` creada en `beta` con rodrigo18a@gmail.com invitado. **Falta:** verla en la app online (compilación nueva) y marcar el paso
- [ ] 1.5.2 Semáforo de próximos controles (⏱️ 1 h) — 17/10/2026 **adelantado y oculto** (D66, con la libreta): `semaforoDe()` y `proximosVigentes()` en el núcleo (rojo ≤ 7 días, amarillo ≤ 30, verde, vencido; una dosis nueva de lo mismo reemplaza la próxima de la anterior), estado con color **y texto** en cada registro ("Venció hace 3 días", "Vence hoy", "Faltan 5 días") y aviso arriba de la libreta con lo vencido o lo de 7 días o menos. **Falta:** verlo en la app online
- [ ] 1.5.2b Estado RENAC + guía "Cómo registrar a tu mascota" + botón "Verificar en el RENAC" (⏱️ 2 h)
- [ ] 1.5.3 `reminders` + notificaciones locales de medicación (⏱️ 4 h) — 17/10/2026 **adelantado y oculto** (D67), detrás de la funcionalidad `recordatorios`: migración `reminders` + casos en `rls_test.py`, modelo `Recordatorio`/`Frecuencia` con el cálculo de tomas en el núcleo, tarjeta en la ficha (próxima toma, pausado, terminado), formulario cada X horas / todos los días / algunos días con fin opcional, avisos del navegador con la app abierta (`AvisadorWeb`) y evento `reminder_create`; pruebas OK (185 app, 78 núcleo). **Falta:** aplicar la migración en dev (con aprobación), crear la marca e invitarte, y las notificaciones nativas (1.1)
- [ ] 1.5.4 Recordatorios de alimentación y vacunas (⏱️ 2 h) — 17/10/2026 **adelantado y oculto** (D67): el formulario elige el tipo (medicación, comida, vacuna, control); comida con porción y horarios fijos (todos los días o algunos días); vacunas y controles una sola vez con fecha y hora; "Recordarme" en la libreta crea el recordatorio de la próxima dosis ese día a las 9; pruebas OK (188 app). **Falta:** lo mismo que 1.5.3
- [ ] 1.5.5 "✅ Ya se la di" + historial (`reminder_logs`) (⏱️ 2 h) — 17/10/2026 **adelantado y oculto** (D67): migración `reminder_logs` (única por toma, sin edición) + casos en `rls_test.py`, `tomaPendiente()` en el núcleo (desde 30 min antes hasta 12 h después), botón en la tarjeta con "Deshacer", historial en la edición, una toma marcada no avisa, evento `reminder_done`; pruebas OK (191 app, 82 núcleo). migraciones aplicadas en dev, `rls_test.py` OK (269 casos), marca `recordatorios` en `beta` con rodrigo18a@gmail.com invitado. **Falta:** verlo en la app online
- [ ] 1.5.6 Funcionamiento sin internet de la ficha, la libreta y el QR (⏱️ 3 h) — 17/10/2026 **hecho en código** (D68): copia local de lo último leído (mascotas, libreta, recordatorios y QR) por cuenta, que se usa si la base no responde y se borra al cerrar sesión (`app/lib/src/utiles/respaldo.dart`); los avisos de recordatorios se siguen programando sin internet; pruebas OK (194 app). Las fotos dependen de la caché del navegador. **Falta:** probarlo en el celular en modo avión

### Etapa 1.6 · Hogar compartido (gratis por ahora)
- [x] 1.6.1 `households` + `household_members` + invitación por enlace (⏱️ 4 h) — 18/10/2026 (D69), oculto detrás de `hogar`: migración `households` (+ `household_invites`, funciones `invitar_al_hogar`/`unirme_al_hogar`/`integrantes_de_mis_hogares`), pantallas "Mi hogar" (invitar con enlace copiable, sacar, irse) y `/unirme/<código>`, eventos `household_*`; aplicada en dev, `rls_test.py` OK (299), marca `hogar` en beta con rodrigo18a@gmail.com
- [x] 1.6.2 Mascotas y recordatorios compartidos con sincronización del "ya se la di" (⏱️ 4 h) — 18/10/2026 (D69): migración `hogar_compartido` (`puedo_cuidar()` en las políticas, dueño fijo, push al hogar con `tokens_de_cuidadores()`; `owner-alert` desplegada), "Compartida por …" en la lista y la ficha, solo el dueño reporta SOS / borra / cambia el QR, historial "Marcada por …". Además **Mi perfil** (D70, marca `perfil`). Pruebas OK (206 app, 85 núcleo, 299 seguridad)
- [x] 1.6.3 Tareas (paseo, comida) y registro de quién lo hizo (⏱️ 3 h) — 18/10/2026 (D71): migración `household_tasks` (asignar solo a quien puede cuidar, "hecha" a nombre de quien marca por trigger), modelo `Tarea` en el núcleo, tarjeta "Tareas de hoy" en la ficha con la marca `hogar`, eventos `task_create`/`task_done`; aplicada en dev, `rls_test.py` OK (308); pruebas OK (211 app, 87 núcleo)
- [x] 1.6.4 Cuidador temporal con acceso por X días (⏱️ 2 h) — 18/10/2026 (D72): migración `cuidador_temporal` (`household_member_pets`, invitación con mascotas y días, `puedo_cuidar()` y push por mascota; `owner-alert` desplegada), "Invitar a un cuidador temporal" en Mi hogar; aplicada en dev, `rls_test.py` OK (318); pruebas OK (212 app)

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
| 14/10/2026 | 0.4.1–0.5.6 | ✅ QR (código, cartel, página pública, contacto inverso con anti-bots y bandeja Avisos, escaneos) y SOS (tablas, mapa MapLibre+OpenFreeMap, formulario, lista por cercanía, detalle, página /s/, ¡Apareció!). Pendientes del dueño: 0.4.4b (correo). **No se compiló la web desde 0.3.3** (falta de memoria con Chrome abierto): compilar y probar el mapa real en otra máquina |
| 14/10/2026 | 0.5.7 | ✅ Reportar publicación (app) con motivo; la web `/s/` indica reportar desde la app (sin reporte anónimo). Arreglado: bloque "aviso enviado" duplicado en `s.html`. **Etapa 0.5 terminada** |
| 13/10/2026 | 0.0.2 | Análisis de puntos débiles: contacto inverso en lugar de redirección a WhatsApp; pasos nuevos de identidad, legal temprano, formalización, soporte y criterios de corte (D41–D43) |
| 12/10/2026 | 0.0.2 | Sin combo de microchip (D39). Línea institucional: Zoonosis de Canelones → nacional → mundial (D40) |
| 12/10/2026 | 0.0.2 | Chapitas pre-codificadas, retiro en veterinaria, sponsors y prototipo con impresión 3D (D35–D38) |
| 12/10/2026 | 0.0.2 | Investigación de competencia (`investigacion/competencia.md`) y del RENAC (`investigacion/renac.md`, D33–D34) |
| 12/10/2026 | 0.0.1 | Adopción responsable: directorio en Fase 1, proceso completo como primera etapa de la Fase 2, packs y tránsito en Fase 3 (D30–D32) |
