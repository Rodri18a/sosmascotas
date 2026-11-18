# 10 · Costos

> Regla: **pagar cada cuenta o servicio recién cuando se necesite**. Mientras se desarrolla, el costo es casi cero.
> Cambio de referencia: US$1 = $40 uruguayos. **Verificar todos los precios antes de contratar**: cambian.
> El detalle original en pesos (inversión por paso y escenarios) está en `reference/SOS-Mascota-brief.md`, sección 8.

## Cuándo se paga cada cosa

| Concepto | Costo aprox. | Cuándo |
|---|---|---|
| Supabase (desarrollo) | Gratis (se pausa tras una semana sin actividad) | Desde el inicio |
| Firebase (push) | Gratis | Al programar los avisos |
| Google Cloud (clave de mapas) | Gratis en el mapa nativo móvil; **pide tarjeta** igual | Al programar el mapa móvil (Fase 1) |
| Proveedor de teselas para el mapa web | Gratis en su cupo | Al programar el mapa web (Fase 0) |
| Hosting de la app y la web pública (Vercel) | Gratis | Al publicar |
| **Dominio `huellamy.com` + Hostinger Premium Web Hosting** | ✅ **US$42 por un año, los dos juntos** (pagado el 10/11/2026, D155). Vence aprox. el **10/11/2027**: revisar el precio de renovación, que suele ser más alto que el del primer año | Ya pagado |
| **Licencia propia de Claude** (herramienta de desarrollo) | US$100/mes (Max); [precios](https://claude.com/pricing) | Más adelante: hoy se usa la licencia que paga CAAMEPA, el trabajo del dueño (D165) |
| **Supabase Pro** | US$25/mes | Cuando haya usuarios reales |
| **Google Play** | US$25 una vez | **3–4 semanas antes** de querer estar en la tienda (prueba cerrada de 14 días con 12 testers) |
| **Apple Developer** | US$99/año | Fase 1, al publicar en iPhone |
| Asesoría legal (términos y datos personales) | US$150–400 (estimado) | Antes del lanzamiento |
| Registro de marca (DNPI) | Consultar el arancel vigente | Antes de invertir en la marca |
| Chapitas QR (primer lote de 100) | US$50–150 | Fase 2 (antes, solo impresas en papel o como muestra) |
| Publicidad | US$50–100/mes | Después de captar los primeros usuarios |
| Contador y formalización | ~$3.000/mes (supuesto) | Desde el primer cobro |
| Comisión de tiendas por suscripciones | ~15% | Desde el primer cobro dentro de la app |
| Comisión de cobro (link de pago / Mercado Pago) | Según el medio | Desde el primer cobro |

## Gastos hechos

| Fecha | Concepto | Monto | Vence |
|---|---|---|---|
| 10/11/2026 | Dominio `huellamy.com` + Hostinger Premium Web Hosting (1 año) | US$42 | ~10/11/2027 |

**Total gastado:** US$42.

## Por fase (estimado)

| Fase | Gasto único | Gasto mensual |
|---|---|---|
| 0 · SOS (PWA) | Dominio + hosting (✅ US$42, pagado) (+ Google Play opcional) | $0 – US$25 |
| 1 · MVP | Apple US$99, asesoría legal | US$25–40 |
| 2 · Monetización | Chapitas, marca | US$25–60 + contador + publicidad |
| 3–4 | Según el crecimiento | Supabase según el uso |

## Mapa: por qué no es un gasto grande

- Móvil: el mapa nativo de Google no tiene costo por carga (verificar la política vigente).
- Web: MapLibre/OpenStreetMap con un proveedor de teselas gratis en su cupo.
- Los pines salen de Supabase.
- Sin Places, Geocoding ni Directions. Ver las reglas en `08-arquitectura.md`.

## Punto de equilibrio (empresas)

Empresas necesarias = gasto mensual ÷ ingreso neto por empresa (Destacado ~$600, neto ~$500).

| Gasto mensual | Empresas pagando |
|---|---|
| $1.800 (solo infraestructura) | 4 |
| $4.200 a $6.600 (con contador) | 9 a 14 |
| $10.000 | 20 |
| $62.000 (vivir del proyecto) | ~124 |

Los planes Pro y Familia suman ingreso recurrente. Por ejemplo, 2.000 usuarios con 3% en Familia a ~$120 ≈ $7.200/mes antes de la comisión de la tienda.

## Peor caso y tope

- **Austero:** solo dominio y todo gratis.
- **Conservador** (Supabase Pro, asesoría, tiendas, publicidad): unos US$700–1.150 en 6 meses.
- **Fijar un tope antes de empezar.** Si a los 3 meses del lanzamiento no se cumplen las metas, pasar a modo austero (ver `11-roadmap.md`).
