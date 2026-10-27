# 18 · Campaña de fin de año 2027 (propuesta)

> Paso 3.7 de `PROGRESO.md`. **Propuesta para decidir**, escrita el 28/10/2026. Se ejecuta de octubre de 2027 a enero de 2028. Casi todo se arma con lo que la app ya tiene; lo que falta está marcado como **a programar**.

## Por qué

Los fuegos artificiales de Navidad y Año Nuevo son la época con **más mascotas perdidas** (01 · Visión). La Fase 0 se lanza justo antes de diciembre de 2026 para aprender; la campaña de 2027 es la primera **fuerte**, con un año de datos, comercios adheridos y la app en las tiendas.

## Objetivos (a confirmar con las métricas de 2026)

| Meta | Cómo se mide (evento ya existente) |
|---|---|
| Duplicar las mascotas con chapita QR activa antes del 24/12 | `qr_tags` activas por zona |
| Que el 80 % de los SOS del 24/12 al 2/1 tengan foto y zona | `sos_reports` con foto |
| Bajar a la mitad el tiempo mediano de reencuentro de esas fechas | `sos_reports.resolved_at - created_at` |
| Sumar 10 comercios que donen o entreguen chapitas | `sponsors` y el stock de las veterinarias (2.9) |
| Que Zoonosis de Canelones (P17) difunda la campaña | Reunión y pieza conjunta |

## Calendario

| Cuándo | Qué |
|---|---|
| **Octubre** | Revisar las métricas de 2026 (0.9.1). Pedir presupuesto de impresión. Conseguir sponsors de lotes de chapitas (2.9). Proponer la pieza conjunta a Zoonosis y a las protectoras. |
| **1–15 de noviembre** | Producir 300–500 chapitas (lotes con sponsor). Volante con QR y consejos. Preparar las noticias y las marcas de funcionalidades (abajo). |
| **15 de noviembre – 20 de diciembre** | **Prevención:** «Poné la chapita y actualizá la foto». Puntos de entrega en veterinarias con stock (2.9). Charlas cortas en ferias de adopción (2.7). |
| **21 – 23 de diciembre** | Recordatorio a toda la zona: foto al día, chapita puesta, cómo actuar si se escapa. |
| **24 de diciembre – 2 de enero** | **Guardia:** soporte en menos de 2 h (0.8.6b), SOS con radio ampliado, moderación diaria, publicaciones de reencuentros en Comunidad. |
| **Enero** | Balance público («X mascotas volvieron a casa»), agradecer a sponsors con su reporte por lote (2.9) y anotar lo aprendido en `12-decisiones.md`. |

## Lo que ya tiene la app (sin programar)

- **Marcas con fecha** (D64): `funcionalidades.py regla <clave> desde/hasta` prende y apaga solo, por zona.
- **Noticias patrocinadas** (2.8): consejos para los fuegos («dejalo adentro», «música suave», «chapita puesta»), con la marca del sponsor si la hay.
- **Chapitas con sponsor y stock en veterinarias** (2.9): reporte por lote con activadas, escaneos y reencuentros.
- **SOS por zona con push**, contacto inverso y novedades de reencuentros en Comunidad (D86).
- **Grupos** (3.4, D116): publicación fijada de la campaña en «Perros», «Gatos» y «Adopción responsable» (la publica el equipo).
- **Busco veterinaria y socios** (2.6): las veterinarias recuerdan a sus socios ponerse la chapita.
- **Paseos y estadías** (3.3, D115): hoteles y cuidadores para quienes viajan en las fiestas.

## A programar (estimado, si se aprueba)

| Qué | Para qué | Estimado |
|---|---|---|
| **Aviso de temporada** en el mapa (tarjeta que se cierra), detrás de una marca con fecha | Llevar a «Activar mi chapita» y «Actualizar la foto» | 2 h |
| **Radio del SOS ampliado** del 24/12 al 2/1: sumar unos km al radio de cada persona (`alert_radius_km`, hoy de 1 a 20) solo en esas fechas | Que el aviso llegue más lejos cuando los animales corren más | 2 h |
| **Recordatorio local** el 23/12: «¿Tu mascota tiene la chapita y la foto al día?» | Prevención en la noche más difícil | 1 h |
| **Push de campaña por zona** (una sola, del equipo, desde el portal) | El mensaje del 21–23/12 | 3 h |
| **Publicación fijada** en los grupos | Que la campaña esté arriba en la comunidad | 1 h |
| **Contador público** en la web liviana («N mascotas volvieron a casa estas fiestas») | Difusión y balance | 2 h |

Ninguno tiene costo de servicios: las push van por FCM (gratis) y lo demás es la base que ya existe.

## Costos

| Concepto | Estimado |
|---|---|
| 300–500 chapitas (impresión 3D o láser, P15) | lo cubren los sponsors por lote (2.9) |
| 1.000 volantes A6 | a cotizar en octubre de 2027 |
| Publicidad paga en redes | **opcional**; primero lo orgánico con protectoras y veterinarias |

Regla de oro (CLAUDE.md, 06): **lo que hace a la seguridad de la mascota no se cobra**. La chapita se regala o la paga un sponsor; nunca se exige un plan para el SOS ni para el QR.

## Para decidir

1. ¿Metas de arriba o las ajustamos con las métricas de la Fase 0?
2. ¿Qué de «A programar» entra? (sugerencia: aviso de temporada, radio ampliado y recordatorio local: 5 h).
3. ¿Se propone la pieza conjunta a Zoonosis (P17) en octubre?
4. ¿Presupuesto de volantes y, si hay, de publicidad?
