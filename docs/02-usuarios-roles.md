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
| **Integrante de hogar** | Fue invitado al hogar de un dueño (plan Familia) y comparte mascotas y recordatorios | App |
| **Cuidador temporal** | Acceso limitado por X días a una mascota (vacaciones, guardería) | App |
| **Empresa con local** | Veterinaria, petshop, peluquería, farmacia veterinaria, hotel o guardería, adiestrador | App (modo comercio) → luego portal web |
| **Empresa sin local** | Tienda online o servicio a domicilio (paseador, peluquería móvil) con zona de cobertura | App (modo comercio) → luego portal web |
| **Refugio / ONG / rescatista** | Publica adopciones y perdidos y aparece en el directorio de Ayuda | App |
| **Administrador** | Modera, verifica empresas, carga lugares, ve indicadores y gestiona ventas | Portal de administración |

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
