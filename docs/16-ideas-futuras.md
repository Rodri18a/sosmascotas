# 16 · Ideas para el futuro

> Ideas anotadas para **pensar más adelante**. No están aprobadas ni tienen fase asignada: cuando una se quiera hacer, se evalúa, se le asigna una fase en `11-roadmap.md` y se anota la decisión en `12-decisiones.md`.

| # | Idea | Origen | Fecha | Estado |
|---|---|---|---|---|
| I1 | Seguir el paseo en vivo (el paseador comparte la ubicación) | Visto en MiMascota App | 16/10/2026 | 💡 Para evaluar |
| I2 | Collar con GPS propio | Visto en MiMascota App | 16/10/2026 | 💡 Para investigar |
| I3 | Collar que informa datos de salud (como un reloj biométrico) | Idea del dueño | 16/10/2026 | 💡 Para investigar |

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

## I2 · Collar con GPS propio

**La idea:** que el collar emita su ubicación para encontrar a la mascota en todo momento, no solo durante un paseo.

**Lo que hay que saber antes:**
- Un GPS en el collar necesita **hardware con batería y conexión** (chip celular con SIM, LoRa o Bluetooth). Fabricarlo propio es caro y no es el negocio de SOS Mascota.
- Existen rastreadores comerciales (Tractive, Fi, y etiquetas Bluetooth como AirTag o SmartTag, que solo funcionan cerca de otros teléfonos). Lo razonable sería **integrarse** con alguno que tenga API, más que fabricar.
- Encaja con el SOS: si la mascota tiene rastreador, el aviso de perdido podría mostrar la última ubicación conocida **solo al dueño**.

**A investigar:** qué rastreadores se venden en Uruguay, su precio y mensualidad, si tienen API y cobertura en Pando.

## I3 · Collar con datos de salud

**La idea:** como los relojes biométricos de las personas, un collar que mida **actividad, descanso, frecuencia cardíaca o respiratoria y temperatura**, y avise si algo se sale de lo normal (por ejemplo, poca actividad varios días o se rasca mucho).

**Lo que hay que saber antes:**
- Ya hay productos así (por ejemplo, collares de monitoreo de salud y de actividad para perros). Igual que con el GPS, lo razonable es **integrarse**, no fabricar.
- Los datos se podrían sumar a la **libreta de salud** (Fase 1) y compartir con la veterinaria de la mascota, con permiso del dueño.
- **Regla de oro:** si se integra, los avisos de salud no se cobran. El costo del collar lo paga el dueño al fabricante.
- No es un diagnóstico médico: la app tiene que decir siempre "consultá con tu veterinaria".

**A investigar:** qué collares de salud existen, si son confiables, si se consiguen en Uruguay y si tienen API.
