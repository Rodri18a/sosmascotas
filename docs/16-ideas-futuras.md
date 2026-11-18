# 16 · Ideas para el futuro

> Ideas anotadas para **pensar más adelante**. No están aprobadas ni tienen fase asignada: cuando una se quiera hacer, se evalúa, se le asigna una fase en `11-roadmap.md` y se anota la decisión en `12-decisiones.md`.

| # | Idea | Origen | Fecha | Estado |
|---|---|---|---|---|
| I1 | Seguir el paseo en vivo (el paseador comparte la ubicación) | Visto en MiMascota App | 16/10/2026 | 💡 Para evaluar |
| I2 | Seguimiento por GPS de la chapita o el collar | Visto en MiMascota App; retomado por el dueño | 16/10/2026 (act. 30/10) | ⏸️ Para una próxima versión (D121) |
| I3 | Collar que informa datos de salud (como un reloj biométrico) | Idea del dueño | 16/10/2026 | 💡 Para investigar |
| I4 | "Con quién me cruzo" por las mascotas | Idea del dueño | 17/10/2026 | 📝 Propuesta en `17-propuestas-perfil-gamificacion.md` §2 |
| I5 | Gamificación con logros concretos (protección, libreta al día, tratamiento completo, vecino solidario) | Idea del dueño | 17/10/2026 | 📝 Propuesta en `17-propuestas-perfil-gamificacion.md` §3 |
| I6 | Juegos con Ami y Mishi dentro de la app | Idea del dueño y Flavia | 18/11/2026 | 💡 Para evaluar |

---

## I1 · Seguir el paseo en vivo

**La idea:** cuando un **paseador** sale con la mascota, marca **"Empiezo el paseo"** en su celular y la app comparte su ubicación mientras dura el paseo. El dueño ve en el mapa por dónde va y recibe un aviso al empezar y al terminar.

**Por qué tiene sentido:** no hace falta hardware (usa el celular del paseador) y encaja con la contratación de paseadores de la Fase 3 (`03-funcionalidades-app.md` §12). Le da tranquilidad al dueño y es un diferencial para los paseadores que trabajen con la app.

**Cuidados (privacidad y seguridad, regla 7 y riesgo de robo de animales):**
- La ubicación la ve **solo el dueño** de esa mascota (y su hogar compartido), **nunca** otros usuarios, y solo **mientras dura el paseo**.
- El recorrido arranca y termina **lejos de la casa**: los primeros y últimos metros no se muestran o se muestran borrosos, para no revelar dónde vive la mascota.
- El historial de recorridos es privado y se borra solo después de un tiempo (no se usa para mostrar rutinas).
- El paseador tiene que aceptar compartir su ubicación en cada paseo; si se corta la señal, el dueño ve "última ubicación hace X minutos".
- Batería y costo: actualizar la posición cada 15–30 s es suficiente; con Realtime de Supabase no hace falta pagar APIs de mapas (`08-arquitectura.md`, reglas de costo).

**Preguntas abiertas:** ¿solo paseadores verificados o cualquiera (un familiar, un vecino)? ¿Es gratis o parte de un plan para paseadores? Como no es salud ni seguridad directa del animal, podría cobrarse, aunque mostrar dónde está una mascota en la calle se parece bastante a la seguridad.

## I2 · Seguimiento por GPS de la chapita o el collar

**La idea:** poder ver dónde está la mascota en todo momento, no solo cuando alguien la encuentra y escanea la chapita.

**Qué hay hoy:** la chapita es un **QR impreso** (sin batería ni electrónica). El único "seguimiento" es pasivo: cuando alguien la escanea puede **compartir su ubicación** con el dueño (`qr_scans.shared_location`, 0.4.5). Depende de que alguien la encuentre.

**Qué necesitaría una chapita con GPS:**
1. **Saber dónde está:** un receptor GPS, o apoyarse en los teléfonos que pasan cerca (sin GPS propio).
2. **Mandar la ubicación** a internet: es la decisión que define todo lo demás (ver la tabla).
3. **Batería:** y con ella carcasa resistente al agua, carga o recambio de pila, y más peso en el collar.

| Opción | Cómo funciona | Costo aprox. | Contras |
|---|---|---|---|
| **Bluetooth + red de teléfonos** (AirTag, Galaxy SmartTag, red "Encontrar" de Google) | No tiene GPS: los teléfonos que pasan cerca informan dónde la vieron | US$ 15–35, sin mensualidad, pila de ~1 año | Solo funciona donde pasa gente; no es en vivo; las redes son **cerradas**: SOS Mascota no puede leer la ubicación |
| **GPS + chip celular** (Tractive y similares) | GPS real que envía la ubicación por la red móvil (LTE-M / NB-IoT) | US$ 50–100 + US$ 5–10 por mes | La batería dura días; hay que confirmar venta y cobertura en Uruguay; API solo si el fabricante la ofrece |
| **GPS + LoRa** | Radio de largo alcance hacia antenas (propias o de una red comunitaria) | Equipo barato | En Pando casi seguro no hay antenas: habría que instalarlas. Es un proyecto de hardware aparte |

**Recomendación (30/10/2026):** **no fabricar** hardware propio. En orden:
1. **Sin hardware (barato, se puede hacer ya):** en la ficha de la mascota, "¿Tiene rastreador?" con el tipo (AirTag, SmartTag, Tractive, otro). Si se pierde, el SOS le **recuerda al dueño** que lo busque en esa app y le deja anotar la última ubicación que ve ahí, como una pista **visible solo para él** (regla de privacidad: la ubicación nunca es pública). También sirve como dato: cuántos dueños ya usan rastreador.
2. **Accesorio:** chapita QR con hueco o funda para un AirTag/SmartTag. Se puede vender sin romper la regla de oro (el QR sigue siendo gratis).
3. **Integración:** si un rastreador con API se vende en Uruguay, mostrar su última ubicación dentro del SOS, solo al dueño.

**Antes de programar (validar primero):**
- Qué rastreadores se venden en Uruguay (Mercado Libre, veterinarias, pet shops), precio y mensualidad, cobertura en Pando y si tienen API.
- En las charlas con dueños: ¿ya usan alguno? ¿Pagarían por esto o es un "estaría bueno"?
- El paso 1 se puede hacer antes porque es chico y además **mide** el interés.

**Estado (30/10/2026, D121):** queda **para una próxima versión**, después del lanzamiento. Aunque el paso 1 es chico, toca la ficha de la mascota, el SOS, la base y la privacidad, y no tiene que demorar las pruebas ni el lanzamiento de la Fase 0.

## I3 · Collar con datos de salud

**La idea:** como los relojes biométricos de las personas, un collar que mida **actividad, descanso, frecuencia cardíaca o respiratoria y temperatura**, y avise si algo se sale de lo normal (por ejemplo, poca actividad varios días o se rasca mucho).

**Lo que hay que saber antes:**
- Ya hay productos así (por ejemplo, collares de monitoreo de salud y de actividad para perros). Igual que con el GPS, lo razonable es **integrarse**, no fabricar.
- Los datos se podrían sumar a la **libreta de salud** (Fase 1) y compartir con la veterinaria de la mascota, con permiso del dueño.
- **Regla de oro:** si se integra, los avisos de salud no se cobran. El costo del collar lo paga el dueño al fabricante.
- No es un diagnóstico médico: la app tiene que decir siempre "consultá con tu veterinaria".

**A investigar:** qué collares de salud existen, si son confiables, si se consiguen en Uruguay y si tienen API.

## I4 · Sumarse al hogar escaneando un QR

**La idea:** propuesta del dueño durante las pruebas del 28/10/2026. Hoy, para sumar a alguien al hogar (o como cuidador temporal) se manda un enlace o un código. Con un **QR en pantalla**, la otra persona lo escanea con su celular ahí mismo y queda sumada: más fácil cuando están juntos (la familia en casa, el paseador que viene a buscar al perro).

**Cómo encajaría:** el QR lleva al mismo enlace de un uso que ya existe (`/unirme/<código>`, vence a los 7 días), así que no cambia la seguridad; es otra forma de mostrar la invitación. Lo mismo serviría para el **equipo de una empresa** (`/equipo/<código>`, D117).

---

## I6 · Juegos con Ami y Mishi

**La idea** (18/11/2026, el dueño y Flavia): aprovechar a las mascotas de la marca, Ami (perrito) y Mishi (gatita), para un juego sencillo dentro de la app relacionado con las mascotas. Sirve para que la gente vuelva a entrar y se encariñe con Huellamy.

**Para pensar cuando se evalúe:** qué tipo de juego (cuidar, buscar una mascota perdida en el mapa, preguntas de tenencia responsable), si suma a «Tus huellas» (insignias, sin rankings) y que nunca tape lo urgente (SOS, Urgencias). Por ahora es solo la idea, sin diseño ni fase.
