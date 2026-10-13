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
| Hosting web (Cloudflare Pages / Vercel) | Gratis | Al publicar |
| **Dominio `sosmascotas.uy`** | Entre €43 y más de €220 por año según el registrador. Comparar en nic.org.uy y preguntar por `.com.uy` | Al publicar la Fase 0 (opcional antes, para asegurarlo) |
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

## Por fase (estimado)

| Fase | Gasto único | Gasto mensual |
|---|---|---|
| 0 · SOS (PWA) | Dominio (+ Google Play opcional) | $0 – US$25 |
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
