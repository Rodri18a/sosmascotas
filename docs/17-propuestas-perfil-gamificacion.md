# 17 · Propuestas: perfil, "con quién me cruzo" y gamificación

> **Propuesta para decidir** (18/10/2026), a pedido del dueño del proyecto. **Ya está hecho** el perfil básico, oculto detrás de la funcionalidad `perfil` (D70). Lo demás **no está aprobado**: elegí qué se hace y se pasa a `11-roadmap.md`, `PROGRESO.md` y `12-decisiones.md`.

## 1. Lo que ya está: "Mi perfil" (D70)

Ajustes → **Mi perfil**. Solo lo ve la propia persona.

- Nombre, correo, **rol** (dueño o dueña de mascotas; más adelante, comercio) y **plan**.
- **Mascotas a tu cargo:** las tuyas y las que te compartieron ("Compartida por Ana").
- **Con quién compartís el cuidado:** las personas de tus hogares, con su rol (creó el hogar, integrante, cuidador temporal hasta tal fecha) y un acceso a "Mi hogar".

**No hay perfiles públicos.** Otro usuario nunca ve tu perfil: ni tu nombre, ni tus mascotas, ni tu zona. Esto sigue la regla de privacidad (regla 7 de `CLAUDE.md`).

## 2. "Con quién me cruzo por mis mascotas"

**La idea:** ver a las personas que pasean por los mismos lugares, o que van a la misma veterinaria o la misma plaza.

**Recomendación: no hacerlo automático.** Calcular cruces por ubicación obliga a guardar recorridos y rutinas. Eso revela dónde vive y por dónde camina cada mascota, que es el riesgo de robo que el proyecto evita desde el principio (la ubicación del dueño nunca es exacta ni pública). Además, la ley 18.331 lo trata como dato personal sensible por uso.

**Alternativa segura**, para la Fase 3, junto con la comunidad por raza y especie (§3.4 de la hoja de ruta):

| Opción | Cómo funciona | Riesgo |
|---|---|---|
| **"Amigos de paseo" en persona** | Dos personas que se conocen en la plaza se agregan escaneando un código QR en el celular del otro. Desde ahí ven el nombre y la foto de las mascotas del otro y pueden saludarse. | Bajo: hace falta estar juntos y aceptar los dos |
| **"Somos de la misma veterinaria"** | La veterinaria (modo comercio) arma un grupo de sus clientes que **eligen** sumarse. | Bajo: lo propone el comercio y cada uno se suma si quiere |
| Cruces por ubicación | Automático por GPS. | **Alto: no se recomienda** |

## 3. Gamificación: qué sí y qué no

**Lo que no:** premiar mirar videos o publicidad, como Taponto. No ayuda a ningún animal y se siente forzado. Tampoco va nada que haga pagar para avanzar, ni rankings que avergüencen. La regla de oro sigue valiendo: lo que hace a la seguridad y la salud del animal no se cobra.

**Criterio:** cada logro tiene que corresponder a **algo concreto que mejora la seguridad o la salud de una mascota real**, o que ayuda a que un perdido vuelva a su casa. Además:
- se tiene que poder comprobar con los datos de la app;
- no puede incentivar trampas;
- tiene que ser privado, salvo que la persona elija mostrarlo.

### Propuestas, de más concreta a más ambiciosa

| # | Propuesta | Qué premia (algo real) | Cómo se comprueba | Fase sugerida | Esfuerzo |
|---|---|---|---|---|---|
| G1 | **Protección de la mascota** (barra 0–5) | Tener foto, chapita QR activa, microchip cargado, nota de la chapita y al menos una persona más en el hogar | Con los datos de la ficha (todo ya existe) | Fase 1 | 3 h |
| G2 | **Libreta al día** | Vacunas y desparasitación vigentes (semáforo verde, D66) | Con la libreta: si algo vence, la insignia se apaga y te avisa | Fase 1 | 2 h |
| G3 | **Tratamiento completo** | Dar todas las tomas de un tratamiento ("14 de 14 tomas: Luna terminó el antibiótico") | Con `reminder_logs`. Celebra el final; **no** castiga una toma perdida | Fase 1 | 2 h |
| G4 | **Vecino solidario** | Haber ayudado a que una mascota vuelva: el dueño marca tu aviso como "me ayudó" | Lo confirma el dueño (sin eso no cuenta, así no se puede inventar) | Fase 1, con el seguimiento de SOS (1.4.5) | 4 h |
| G5 | **Reencuentros del barrio** | Nada individual: un contador por zona ("Este mes volvieron a casa 7 mascotas en Pando") | Con los SOS cerrados con "¡Apareció!" | Fase 0.9 o 1 | 2 h |
| G6 | **Beneficios con comercios** | Una veterinaria Socia Fundadora le hace un descuento a quien tiene la "Libreta al día" o la "Protección 5/5" | Con G1 y G2 más el modo comercio | Fase 2 | 6 h |

**Cómo se ve:** en "Mi perfil" y en la ficha de cada mascota, como **checklists con progreso** ("Te falta: cargar el microchip"). No hay puntos que se acumulan sin sentido. Las insignias son privadas; mostrarlas sería opcional y en una fase posterior.

**Cómo se mide si sirve** (antes de seguir con G4–G6):
- % de mascotas con Protección 5/5;
- % de libretas al día;
- % de tratamientos completos;
- todo comparado con las cuentas que no ven los logros. Se puede hacer con la habilitación gradual, usando el porcentaje de `15-funcionalidades-graduales.md` (por ejemplo, la marca `logros` al 50 %).

### Recomendación

1. Empezar por **G1, G2 y G3**, detrás de una funcionalidad `logros`. Usan datos que ya existen, no tienen costo ni riesgo de privacidad, y empujan justo lo que hace distinta a la app: QR, libreta y recordatorios.
2. Sumar **G5** cuando haya movimiento real de SOS en la zona.
3. **G4** junto con el seguimiento de SOS (1.4.5), y **G6** cuando existan los planes de comercios (Fase 2).

**Decisiones pendientes** (anotadas como P24 en `13-riesgos-pendientes.md`):
- ¿Hacemos G1–G3 ya?
- ¿Las insignias se pueden mostrar a otros, o son siempre privadas?
- ¿"Amigos de paseo" va a la Fase 3?
