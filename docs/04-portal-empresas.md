# 04 · Portal web de empresas

## Enfoque

**En primera instancia, todo se gestiona desde la app** (modo comercio, ver `03-funcionalidades-app.md`). El portal web llega cuando las empresas lo necesiten, porque cargar un catálogo grande o analizar estadísticas es más cómodo en la computadora.

- **Fase 2:** portal v1 con estadísticas, reporte mensual, promociones y catálogo.
- **Fase 3:** portal completo con agenda, pedidos, socios y varios usuarios por empresa.

Tecnología: **Flutter Web**, reutilizando el código del modo comercio. Se entra con la misma cuenta de la app.

## Funciones

| Sección | Qué incluye | Fase |
|---|---|---|
| **Inicio** | Resumen: vistas, contactos, reseñas nuevas, turnos y pedidos pendientes | 2 |
| **Estadísticas** | Apariciones en mapa y búsquedas, aperturas de ficha, clics (WhatsApp, llamar, cómo llegar, web, Instagram), favoritos, chats, promos vistas y usadas, evolución de las reseñas, comparación mensual y antes/después del plan | 2 |
| **Reporte mensual** | PDF o email automático: *"Este mes 340 personas vieron tu ficha y 52 te contactaron"* | 2 |
| **Mi negocio** | Datos, horarios, fotos, especies que atiende, contactos, zona de cobertura | 2 |
| **Promociones y eventos** | Crear, programar y medir | 2 |
| **Catálogo** | Carga de productos y servicios (también carga masiva por planilla) | 2 |
| **Reseñas** | Ver, responder, reportar | 2 |
| **Plan y facturación** | Plan actual, vencimiento, cambio de plan, comprobantes | 2 |
| **Agenda** | Configuración (días, horarios, duración, servicios) y turnos | 3 |
| **Pedidos** | Gestión de estados | 3 |
| **Socios** | Lista de mascotas socias y envío de recordatorios | 3 |
| **Equipo** | Varios usuarios por empresa con roles (dueño, empleado) | 3 |

## Reglas

- Las estadísticas son **anónimas y agregadas**: la empresa ve cantidades, nunca quién fue (Ley 18.331).
- El plan Básico (gratis) ve solo un resumen. Destacado y Plus ven las estadísticas completas.
