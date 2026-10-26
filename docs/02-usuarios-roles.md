# 02 · Usuarios y roles

## Visitante (sin cuenta)

**Puede ver todo**: el mapa, las fichas de los lugares, los perdidos y encontrados, la página pública de un QR, eventos y adopciones.

**Para cualquier acción hay que tener cuenta**: publicar, contactar, chatear, reseñar, marcar favoritos, cargar mascotas o reportar. Al intentarlo se muestra el login y, al terminar, se vuelve a la acción que estaba haciendo.

> Excepción: quien escanea un **QR** puede contactar al dueño sin cuenta (ver `06-reglas-negocio.md`). Encontrar a la mascota es más importante que registrar al usuario.

## Tipos de usuario

| Rol | Descripción | Gestiona desde |
|---|---|---|
| **Dueño de mascota** | Registra una o varias mascotas, usa el mapa, SOS, QR y recordatorios | App |
| **Persona que encuentra un animal** | Puede no tener mascota. Reporta animales encontrados o escanea un QR | App / web del QR |
| **Integrante de hogar** | Fue invitado al hogar de un dueño (plan Familia; gratis en la Fase 1) y comparte mascotas, libreta y recordatorios. Ve y edita la ficha, marca "ya se la di" y recibe los avisos del QR; **no** borra la mascota, no cambia el QR ni reporta SOS (D69) | App |
| **Cuidador temporal** | Acceso por X días (1 a 90) **solo a las mascotas que elige el dueño** (vacaciones, guardería). Con esas mascotas puede lo mismo que un integrante; al vencer, deja de verlas solo (D72) | App |
| **Empresa con local** | Veterinaria, petshop, peluquería, farmacia veterinaria, hotel o guardería, adiestrador | App (modo comercio) → luego portal web |
| **Empresa sin local** | Tienda online o servicio a domicilio (paseador, peluquería móvil) con zona de cobertura | App (modo comercio) → luego portal web |
| **Refugio / ONG / rescatista** | Publica adopciones y perdidos y aparece en el directorio de Ayuda | App |
| **Administrador** | Modera, verifica empresas, carga lugares, ve indicadores y gestiona ventas | Portal de administración |
| **Equipo: moderación** | Modera contenido y denuncias (3.6, D109) | Portal: Moderación y Denuncias |
| **Equipo: ventas** | Carga lugares, sigue prospectos y arma propuestas (3.6, D109) | Portal: Lugares, Prospectos y Propuestas |

Una misma cuenta puede ser **dueño y comercio a la vez** y cambiar de modo dentro de la app, como en el prototipo.

## Especies

Entran **todo tipo de animales**. Al cargar una mascota se elige:
1. **Especie:** perro, gato, ave, conejo, roedor, tortuga/reptil, pez, caballo, otro.
2. **Raza o tipo**, de un catálogo según la especie, con la opción "Mestizo / sin raza" y "Otra" (texto libre).

Las empresas indican **qué especies atienden**. Eso se usa para filtrar (ver la regla de coincidencia en `06-reglas-negocio.md`).

## Permisos resumidos

> Además del rol y el plan, cada funcionalidad nueva puede estar prendida solo para una parte de los usuarios mientras se prueba: ver `15-funcionalidades-graduales.md`.

| Acción | Visitante | Usuario | Empresa | Admin |
|---|---|---|---|---|
| Ver mapa, fichas, perdidos | ✅ | ✅ | ✅ | ✅ |
| Contactar desde un QR | ✅ | ✅ | ✅ | ✅ |
| Publicar SOS, cargar mascotas | ❌ | ✅ | ✅ | ✅ |
| Chatear, reseñar, favoritos | ❌ | ✅ | ✅ | ✅ |
| Marcar un lugar "sin reclamar" | ❌ | ✅ | ✅ | ✅ |
| Reclamar o crear un negocio | ❌ | ✅ | — | ✅ |
| Responder reseñas, ver estadísticas propias | ❌ | ❌ | ✅ | ✅ |
| Moderar, verificar, ver indicadores globales | ❌ | ❌ | ❌ | ✅ |
