# Prueba con 3 personas: llegar a 5 funciones sin ayuda

Paso 1.5 del [plan de mejoras](../24-plan-mejoras.md). Sirve para comprobar que la app se entiende sin explicarla. Lleva unos 15 minutos por persona.

## Antes de empezar

- **Quiénes:** 3 personas que **no** hayan usado Huellitas. Mejor si son distintas entre sí (por ejemplo, alguien joven, alguien mayor y alguien que use poco el celular).
- **Dónde:** en su propio celular, con https://sosmascota-dev.vercel.app/ recién abierta (o instalada). Si ya la abrieron antes, que la abran en una ventana de incógnito, así ven el recorrido guiado desde cero.
- **Vos:** mirás y anotás. **No ayudes ni señales nada.** Si alguien se traba más de 2 minutos en una tarea, anotalo como «no llegó» y pasá a la siguiente.
- Pediles que digan en voz alta lo que piensan («busco… no sé dónde está…»). Lo que dicen vale tanto como lo que hacen.

## Las 5 tareas

Leelas tal cual, de a una:

1. «Se perdió tu perro. **Avisale a la gente de la zona.**»
2. «Tu gata tiene que vacunarse el mes que viene. **Hacé que la app te lo recuerde.**» (antes tiene que cargar una mascota: también cuenta)
3. «Encontraste un perro en la calle con una chapita. **Fijate cómo avisarle al dueño.**» (alcanza con encontrar dónde se escanea o se ve la chapita QR)
4. «Es domingo a la noche y tu perro está mal. **Encontrá una veterinaria que atienda urgencias.**»
5. «Querés adoptar un gato. **Encontrá dónde ver los que buscan familia.**»

## Qué anotar por tarea

| Persona | Tarea | ¿Llegó? (sí / con dudas / no) | Toques aprox. | Dónde dudó o se equivocó | Qué dijo |
|---|---|---|---|---|---|
| 1 | 1 | | | | |
| 1 | 2 | | | | |
| … | | | | | |

Y al final, una pregunta: «¿Qué fue lo más confuso?».

## Después de la prueba

- **Meta:** que cada persona llegue a **4 de las 5** sin ayuda. Si una tarea falla en 2 o más personas, ese camino se rediseña.
- **Métricas para mirar** (Portal → Indicadores, o la tabla `events`), filtrando por la hora de la prueba:
  - `tour_skip`: en qué paso se saltó el recorrido (si todos saltan en el paso 1, el recorrido molesta).
  - `menu_item_open`: qué buscaron en el menú ☰.
  - `more_info_open`: qué explicaciones necesitaron abrir.
- Pasame lo anotado y lo arreglo en el momento. Con la prueba hecha se marca el paso 1.5 y se cierra la etapa 1.
