# 13 · Riesgos y pendientes

## Pendientes por definir

| # | Tema | Estado / propuesta |
|---|---|---|
| P1 | **Nombre definitivo**: "SOS Mascota" o "SOS Mascotas" (el dominio es `sosmascotas.uy`) | "SOS" sugiere solo emergencias y "Mascotas" está en español. Opción: un nombre más amplio y "SOS" como función. Verificar en DNPI, en las tiendas y en los dominios |
| P2 | **Horas por semana** disponibles | No definido (el brief decía 20; recomendación: 10–15 sostenibles). Las fechas salen de `PROGRESO.md` |
| P3 | Tecnologías que se usan en el trabajo actual | Para reutilizar conocimiento |
| P4 | **Precios** de Pro, Familia, Destacado y Plus | Validar en las entrevistas de la Fase 0 |
| P5 | Vencimiento de los reportes SOS (60 días) y radio de aviso (5 km) | Propuesta; ajustar con el uso real |
| P6 | ~~Proveedor de teselas para el mapa web~~ | ✅ OpenFreeMap (D54) |
| P7 | ~~Gestión de estado y librerías de Flutter~~ | ✅ Resuelto en 0.1.3: Riverpod + go_router (D45) |
| P8 | Comprar el dominio antes, para asegurarlo | Decisión del dueño del proyecto |
| P9 | Logo e identidad | Algo simple al inicio; no invertir en branding hasta validar |
| P10 | Revisión legal (términos, privacidad, registro URCDP) | **Se inicia en 0.0.9c** y se cierra en 0.8.4. Incluir el consentimiento de "Busco veterinaria", el contacto inverso (el remitente comparte su contacto) y el compromiso de adopción |
| P18 | Formalización (empresa, DGI, BPS, facturación) | Averiguar en 0.0.9d; formalizar antes del primer cobro (1.9.0 o antes si se cobra algo antes) |
| P19 | Proveedor de email para los avisos de respaldo | Elegir en 0.4.4b (plan gratis) |
| P11 | **"Compañeros de paseo"** (en espera) | Retomar solo si hay una forma segura: por ejemplo, perfiles verificados, sin listado por cercanía, encuentros en eventos organizados |
| P12 | Ampliar "Busco veterinaria" a otros rubros | Evaluar después de medir la aceptación con las veterinarias |
| P14 | **Contactar al INBA** (renac@mgap.gub.uy): confirmar la nueva plataforma RENAC (migrada el 01/12/2025), preguntar por una API o alianza, y presentar SOS Mascota | Después de tener la Fase 0 publicada (para mostrar algo concreto) |
| P17 | **Contactar a Zoonosis de la Intendencia de Canelones** con una propuesta concreta (jornadas en el mapa, encontrados, datos anónimos) | Después de la Fase 0, con métricas en la mano |
| P15 | **Prototipo de chapita** con el amigo: material, método de impresión del QR, costo por unidad, tiempo por lote | Paso 0.0.10 |
| P16 | Precio de venta de la chapita y precio del patrocinio por lote | Con el costo real del prototipo |
| P20 | ~~**Identidad visual**~~ | ✅ C · Cielo, con Faro, Vecinos y Pop como temas Pro (D62). Falta generar el logo y las piezas con el prompt de `14-brief-identidad-visual.md` §8 |
| P21 | **Habilitación gradual de funcionalidades** (`15-funcionalidades-graduales.md`): aprobar la propuesta y sumar los pasos a–d a la Etapa 0.8 | Antes del lanzamiento |
| P13 | Texto del **compromiso de adopción** | Redactarlo con protectoras de Pando y revisarlo en la asesoría legal |

## Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| **Retención:** el dueño no vuelve a abrir la app | Alto | Recordatorios diarios, hogar compartido, SOS, favoritos |
| **Las empresas no pagan** | Alto | Validar antes de programar, Socios Fundadores, demostrar resultados con métricas |
| **Una sola persona** desarrollando todo | Alto | Fases chicas, pasos de 1–4 h, gastar solo lo necesario, usar servicios administrados |
| **Plazo de diciembre** ajustado | Medio | Fase 0 recortada; PWA sin depender de las tiendas |
| Competencia (Taponto, grupos de Facebook, WhatsApp Business) | Medio | Diferencial: mapa + SOS + QR + recordatorios + herramientas para empresas |
| Reportes falsos, spam, estafas ("tengo a tu perro, mandame plata") | Alto | **Contacto inverso** (el número del dueño nunca sale), consejo anti-estafa en cada aviso, reportar remitente, anti-bots, límites, moderación |
| El push del aviso no llega (permiso denegado, PWA en iPhone) | Alto | Email de respaldo y bandeja "Avisos" dentro de la app |
| **Robo de animales** usando datos de la app | Alto | Sin listados de mascotas por ubicación, fotos sin EXIF, prohibido publicar ubicación o rutina, saludo previo al chat |
| Uso de la comunidad para cruzas o venta | Medio | Contenido prohibido + moderación |
| Venta encubierta o criaderos que usan las adopciones | Medio | Particulares sin aporte, límite de publicaciones, revisión con camadas repetidas, reportes |
| Adopciones que fracasan (devolución o abandono) | Medio | Perfil de adoptante, compatibilidad, compromiso y seguimiento a 7/30/90 días |
| Las propuestas de veterinarias se sienten como spam | Medio | Opt-in, máximo 3 por mes, 90 días sin volver a preguntar |
| Reclamos de fichas ajenas | Medio | Verificación por RUT, disputas resueltas por el administrador |
| Datos personales y ubicaciones | Alto | Ley 18.331, ubicación aproximada, revisión legal |
| Políticas de las tiendas (cobro de planes a empresas fuera de la app, login de Apple) | Medio | Revisar las políticas antes de la Fase 1 y la Fase 2 |
| Google Play: prueba cerrada de 14 días con 12 testers | Medio | Crear la cuenta 3–4 semanas antes de querer publicar |
| Cambios de precios (Supabase, Google, tiendas, tipo de cambio) | Bajo | Revisar los precios antes de contratar; capa propia del mapa |
| La chapita 3D se gasta y el QR deja de escanearse | Medio | Probar materiales y métodos, corrección de errores alta, test con celulares de gama baja tras semanas de uso |
| Push en la PWA de iPhone limitado | Bajo | App nativa de iPhone en la Fase 1 |
