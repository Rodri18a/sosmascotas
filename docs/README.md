# SOS Mascota en 2 minutos

<div id="estado">Cargando el progreso…</div>

> **Identidad elegida (15/10/2026): C · Cielo**, con Faro, Vecinos y Pop como temas del plan Pro ([brief](14-brief-identidad-visual.md) §10). Lo que sigue está al principio de [Progreso](PROGRESO.md) ("Pendientes al retomar"): generar el logo, aplicar la identidad, la [habilitación gradual de funcionalidades](15-funcionalidades-graduales.md) y la PWA instalable.

## Qué es

Una app que conecta a **dueños de mascotas** con **empresas del rubro**, con un **mapa** como centro: veterinarias, petshops, servicios, lugares que aceptan mascotas, y mascotas **perdidas y encontradas**. Arranca en **Pando** y crece por zonas.

## Lo más importante de cada parte

| Tema | En una línea | Detalle |
|---|---|---|
| 🆘 **SOS** | Reportar mascotas perdidas o encontradas, con aviso a los vecinos a 5 km o menos | [Funcionalidades](03-funcionalidades-app.md) |
| 🏷️ **Chapita QR** | Quien encuentra a la mascota escanea y contacta al dueño sin ver su teléfono | [Funcionalidades](03-funcionalidades-app.md) |
| 🗺️ **Mapa** | Todo el mundo de las mascotas en un mapa con filtros | [Funcionalidades](03-funcionalidades-app.md) |
| ⏰ **Recordatorios** | Medicación, comida y vacunas, compartidos con la familia | [Funcionalidades](03-funcionalidades-app.md) |
| 🏡 **Adopción responsable** | Preparar al adoptante, compatibilidad, compromiso y seguimiento; gratis y sin venta | [Funcionalidades](03-funcionalidades-app.md) |
| 🏪 **Empresas** | Se registran solas; la insignia ✔️ llega después de validar el RUT | [Reglas](06-reglas-negocio.md) |
| 💰 **Planes** | Usuarios: Gratis / Pro / Familia · Empresas: Básico / Destacado / Plus | [Reglas](06-reglas-negocio.md) |
| 🛠️ **Tu portal** | Moderación, indicadores para las empresas y captación de nuevas | [Portal admin](05-portal-admin.md) |
| ⚙️ **Tecnología** | Flutter + Supabase + Google Maps nativo / MapLibre en web | [Arquitectura](08-arquitectura.md) |

## La regla de oro

> **Lo que hace a la seguridad y la salud del animal no se cobra.** SOS, QR, foto y recordatorios de medicación son gratis para todos.

## Las fases

| Fase | Cuándo | Qué sale |
|---|---|---|
| **0 · SOS** | Diciembre 2026 | Perdidos y encontrados, QR, avisos, veterinarias de urgencia (web instalable) |
| **1 · MVP** | Mar–Abr 2027 | Apps Android/iPhone, mapa completo, empresas, chat, recordatorios, hogar, reseñas, tu portal |
| **2 · Monetización** | Mediados 2027 | **Adopción responsable**, planes pagos, estadísticas, promociones, "Busco veterinaria", chapitas físicas |
| **3 · Servicios** | Fin 2027 | Turnos, pedidos, paseadores y hoteles, comunidad por raza, hogares de tránsito |
| **4 · Escala** | 2028 | Pagos en la app, tienda, nuevas zonas y países |

**En paralelo, la línea institucional:** Zoonosis de la Intendencia de Canelones → INBA/RENAC y otras intendencias → organismos de otros países.

Detalle completo en la [Hoja de ruta](11-roadmap.md) y el paso a paso en [Progreso](PROGRESO.md).

## Cómo leer esta documentación

1. Empezá por **[Progreso](PROGRESO.md)**: ahí ves en qué paso estás.
2. Si querés entender el producto: **[Visión](01-vision.md)** → **[Funcionalidades](03-funcionalidades-app.md)** → **[Reglas](06-reglas-negocio.md)**.
3. Lo técnico (**Arquitectura**, **Modelo de datos**) lo vamos a usar al programar; no hace falta leerlo ahora.
4. Usá el **buscador** del menú de la izquierda para encontrar cualquier tema.

<p class="ultima">Esta página lee los archivos de la carpeta <code>docs/</code> cada vez que se abre: si la documentación cambia, recargá el navegador (F5).</p>
