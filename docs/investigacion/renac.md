# Investigación · RENAC (Registro Nacional de Animales de Compañía)

> Relevado el 12/10/2026 a partir de la página del MGAP, la consulta pública del RENAC y los PDF oficiales. **Verificar antes de usar:** el INBA informó una **migración del sistema RENAC a una nueva plataforma (01/12/2025)**, así que algunos enlaces pueden haber cambiado.

## 1. Qué es

- Registro oficial de los animales de compañía de Uruguay. Lo crea la **Ley 18.471 (art. 18)** y lo organiza la Comisión Nacional Honoraria de Bienestar Animal (COTRYBA), hoy dentro del **INBA** (MGAP).
- La identificación con **microchip es obligatoria**, sin excepción. El chip se implanta en el cuello y con él se cargan los datos en el RENAC.
- Se registran los animales de compañía **mayores de 90 días**.
- Al terminar el registro, el sistema genera una constancia con los datos del animal y del tenedor responsable (la "cédula animal").
- La **castración** también es obligatoria (Ley 19.889, arts. 375 a 388).

## 2. Cómo se registra un animal

1. El dueño va a un **operador RENAC**: un **veterinario acreditado** ante el INBA/COTRYBA.
2. El operador **implanta el microchip** y **carga los datos** en el sistema.
3. El dueño recibe la constancia.

- Costo: lo fija cada veterinario. Una resolución de 2016 fijaba un honorario de $207 + IVA, pero es una **cifra vieja** y no sirve como referencia actual.
- Los chips los distribuyen **empresas habilitadas** por el MGAP (BQN, Datamars, Allflex, Cantera, Universal Lab., entre otras, según el PDF de 2021).

## 3. Consulta pública

- **"Consulta para Propietarios"**: se ingresa el tipo de documento (CI, pasaporte o RUT), la especie (canino o felino) y el **número de chip**.
- Devuelve: especie, chip, nombre, raza, sexo, **peligroso** (sí/no), **castrado**, nacimiento, descripción, **estado** (vivo, muerto, **extraviado**, baja) y eventos.
- **No hay API pública ni datos abiertos** del RENAC. La consulta es un formulario web.

## 4. Operadores RENAC (veterinarios habilitados)

- El PDF oficial (junio de 2025) lista **unos 1.000 operadores** en todo el país, **154 en Canelones**.
- **En la zona de Pando:** 3 en Pando, 2 en Barros Blancos, 2 en Toledo y 1 en Empalme Olmos (**8 en total**). Además, 9 en Las Piedras, 6 en Sauce y la **Intendencia de Canelones** (zoonosis).
- Los nombres y contactos están en el PDF oficial (ver Fuentes). **No se copian a la app**: son datos personales, aunque estén publicados (ver punto 6).

## 5. Qué le aporta a SOS Mascota

| Idea | Para qué | Fase |
|---|---|---|
| **Campo microchip** en la ficha, validando 15 dígitos (norma ISO 11784; Uruguay usa el código de país 858) | Tener el dato a mano | 0 |
| En un SOS: *"Tiene microchip"* + consejo a quien lo encuentra: **"llevalo a una veterinaria para leer el chip"** | Más reencuentros | 0 |
| Consejo al dueño que pierde su mascota: **marcarla como extraviada en el RENAC** también | Coordinación con el registro oficial | 0 |
| **Estado RENAC** en la ficha (registrado / no registrado / no sé) + **guía "Cómo registrar a tu mascota"** + recordatorio | Tenencia responsable, cumplir la ley | 1 |
| Botón **"Verificar en el RENAC"**, que abre la consulta pública oficial en el navegador | Confianza, sin integrar nada | 1 |
| Insignia **"Operador RENAC"** en la ficha de la veterinaria, verificada contra el listado oficial | Diferenciar veterinarias y motivo para que reclamen su ficha | 1 |
| Filtro en el mapa **"Coloca microchip"** (veterinarias con la insignia) | Facilitar el trámite | 1 |
| Adopción responsable: el compromiso incluye chip y RENAC (ya previsto) | | 2 |
| **Eventos** de chipeo y castración (Intendencia, INBA, protectoras) en el mapa | Difusión y alianza con lo público | 2 |
| **Alianza con el INBA**: pedir una integración (API) para verificar chips o mostrar el estado oficial | Ser el aliado digital de la tenencia responsable | A gestionar |

**Mensaje de marketing:** *"El chip lo exige la ley. La chapita QR lo hace visible."* El chip necesita un lector que solo tienen las veterinarias. El QR lo lee cualquier celular. **Se complementan, no compiten.**

## 6. Reglas

- **No automatizar consultas al RENAC** (scraping). Solo **enlazar** al sitio oficial. Una integración real tiene que ser con un acuerdo con el INBA.
- **No publicar en la app los datos personales** del listado de operadores. Se usa para **contactar veterinarias** (prospectos) y para **verificar** la insignia cuando una veterinaria la pide.
- El estado RENAC lo declara el usuario. Hasta que haya una integración, la app no lo certifica.

## 7. Uso inmediato: lista de comercios (paso 0.0.3)

Los **8 operadores RENAC de la zona de Pando** son los **primeros candidatos** de la lista de comercios y de Socios Fundadores: ya trabajan en tenencia responsable y les sirve que más dueños registren a sus mascotas.

## Fuentes

- [MGAP — Registro Nacional de Animales de Compañía (RENAC)](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/politicas-y-gestion/registro-nacional-animales-compania-renac)
- [RENAC — Consulta pública de animales registrados](https://www.snig.gub.uy/renac/animalciainfoext.aspx)
- [Operadores RENAC por departamento (PDF, junio 2025)](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/sites/ministerio-ganaderia-agricultura-pesca/files/2025-06/OPERADORES%20RENAC%20POR%20DEPARTAMENTO%20A%20JUNIO%202025%20%281%29.pdf)
- [Empresas habilitadas para distribuir microchips (PDF, 2021)](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/sites/ministerio-ganaderia-agricultura-pesca/files/2021-05/DISTRIBUIDORES%20AUTORIZADOS_0.pdf)
- [Resolución 2/017 de COTRYBA — creación del RENAC](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/institucional/normativa/resolucion-2017-0)
- [Resolución 6/016 de COTRYBA — operadores RENAC](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/institucional/normativa/resolucion-6016)
- [INBA](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/inba) — contacto: renac@mgap.gub.uy · inba@mgap.gub.uy · (+598) 2413 8030
- [Microchip obligatorio para ingresar a Uruguay](https://www.gub.uy/ministerio-ganaderia-agricultura-pesca/comunicacion/noticias/viajas-perro-evita-contratiempos-debe-ingresar-uruguay-microchip)
