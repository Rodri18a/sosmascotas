# 11 · Hoja de ruta

```
Oct 2026 ──► Dic 2026 ──► Mar–Abr 2027 ──► Mediados 2027 ──► Fin 2027 ──► 2028
  hoy        FASE 0         FASE 1           FASE 2           FASE 3      FASE 4
             "SOS"          MVP              Monetización     Servicios   Escala
```

Las fechas son objetivos. **La fecha real sale de las horas que se vayan completando** en `PROGRESO.md` (cada paso tiene sus horas estimadas).

## Fase 0 · "SOS" — objetivo: antes de los fuegos artificiales de diciembre de 2026

**Objetivo:** salir en Pando con lo mínimo útil y juntar los primeros usuarios.

**Plataforma:** PWA en `sosmascotas.uy` (no depende de las tiendas). En paralelo, opcionalmente, arranca la prueba cerrada de Google Play.

**Incluye:**
- Validación previa (competencia, lista de comercios, entrevistas)
- Cuentas (Google + correo), modo visitante, términos y borrar cuenta
- Mascotas con foto
- **Chapita QR** con página pública y **contacto inverso** ("Avisar a mi familia")
- **SOS** perdidos/encontrados, mapa y lista, **contacto inverso**, resolver
- **Canal de soporte** (email y WhatsApp de la app)
- **Avisos push a 5 km o menos** y aviso de escaneo del QR
- **Veterinarias de urgencia** cargadas a mano + directorio de Ayuda
- Reportar contenido + ocultamiento automático
- **Registro de eventos de métricas**

**Queda afuera:** empresas, chat interno, planes pagos, libreta, portal propio (se modera desde Supabase).

**Meta para avanzar:** 300 usuarios registrados en Pando, 20 reportes publicados, primeros reportes resueltos, 50 QR generados.

## Fase 1 · MVP — objetivo: marzo–abril de 2027

- Android en Google Play y **iPhone** en App Store (con login de Apple)
- **Mapa integral** con Google Maps nativo, capas y filtros, "Abierto ahora", regla de coincidencia por especie
- **Empresas en la app:** alta con opción C, lugares sin reclamar, reclamos, modo comercio básico
- **Chat híbrido**, seguir búsquedas
- **Libreta sanitaria y recordatorios** (medicación, alimentación, vacunas)
- **Hogar compartido** (gratis, para validar)
- **Reseñas**
- **Portal de administración v1:** panel, moderación, empresas, lugares, mini CRM
- Arranca **Socios Fundadores** (los contactos empiezan durante la Fase 0)
- Directorio de Ayuda con enlaces a las adopciones de cada refugio
- **Chapitas físicas pre-codificadas:** activación desde la app y pedido con **retiro en la veterinaria asociada**

**Meta para avanzar:** 1.500 usuarios activos por mes, 15 Socios Fundadores, 30% de usuarios con algún recordatorio activo.

## Fase 2 · Monetización — objetivo: mediados de 2027

- **Primero: adopción responsable** (perfil de adoptante, compatibilidad, proceso por etapas, compromiso, seguimiento a 7/30/90 días). Va antes que los cobros, porque gana la confianza de las protectoras
- Planes **Pro y Familia** (suscripción dentro de la app)
- Planes **Destacado y Plus** para empresas (cobro manual)
- Estadísticas para empresas + **reporte mensual**; generador de propuestas
- Promociones, catálogo con "Consultar", módulo Socios con recordatorios de la veterinaria
- **"Busco veterinaria"**: propuestas a mascotas sin veterinaria, con permiso del dueño
- Eventos, lugares que aceptan mascotas, denuncias de maltrato
- Noticias con contenido patrocinado
- **Chapitas QR:** programa de **sponsors**, stock en veterinarias y **venta** de diseños personalizados
- **Portal web de empresas v1**

**Meta para avanzar:** cubrir el gasto mensual con ingresos (punto de equilibrio de `10-costos.md`), 3% de conversión a Pro o Familia, 70% de renovación de los Socios Fundadores.

## Fase 3 · Servicios — objetivo: fin de 2027

- Agenda de turnos, pedidos
- Contratación de paseadores, hoteles y cuidadores (contacto + reserva)
- **Comunidad por raza y especie** (grupos, publicaciones, saludo previo al chat)
- Adopción: **pack adopción** de empresas, apadrinamiento y **hogares de tránsito**
- Portal de empresas completo, zonas, equipo y auditoría en el portal de administración
- 🎆 **Campaña fuerte de fin de año 2027**

## Fase 4 · Escala — 2028

- Pagos dentro de la app con **Mercado Pago** + comisión
- Tienda tipo marketplace
- Expansión a otras zonas y países, portugués e inglés, varias monedas

---

## Línea institucional (en paralelo a las fases)

Objetivo: que SOS Mascota sea la **herramienta digital de tenencia responsable** que usan los organismos públicos. Empieza en lo local y escala con el modelo de zonas.

| Etapa | Con quién | Qué se le ofrece | Cuándo |
|---|---|---|---|
| **A · Local** | **Zoonosis de la Intendencia de Canelones** (y el Municipio de Pando) | Jornadas de castración y vacunación en el mapa y con aviso a la zona; animales recogidos por zoonosis publicados como "encontrados"; contenido de tenencia responsable; **datos agregados y anónimos** (zonas con más perdidos, demanda de castración, abandono) | Después de la Fase 0, con métricas que mostrar |
| **B · Nacional** | **INBA / RENAC** (MGAP) y otras intendencias | Integración con el RENAC (verificar chips, estado oficial), réplica del modelo en otros departamentos | Fase 2–3 |
| **C · Internacional** | Registros y organismos equivalentes de cada país | Mismo modelo por zona y país, en otros idiomas | Fase 4 en adelante |

**Reglas:**
- Siempre con un **acuerdo formal** (convenio). La app mantiene su independencia.
- A los organismos se les entregan **solo datos agregados y anónimos** (Ley 18.331), nunca datos de usuarios.
- La propuesta de valor es **concreta**: una herramienta gratis para el organismo, más alcance para sus campañas y datos para decidir dónde actuar.
- El argumento para cada paso son los **resultados de la etapa anterior** (usuarios en la zona, reencuentros, adopciones).

---

## Qué medir en cada fase

| Fase | Métricas |
|---|---|
| 0 | Registros, mascotas cargadas, QR generados y escaneados, reportes publicados y resueltos, avisos enviados, instalaciones de la PWA |
| 1 | Usuarios activos por mes, retención semanal, recordatorios activos, empresas reclamadas y verificadas, chats iniciados, búsquedas sin resultados |
| 2 | Conversión a Pro y Familia, empresas pagando, renovaciones, ingreso mensual, chapitas vendidas |
| 3 | Turnos y pedidos por mes, servicios contratados |

## Reglas para avanzar

- Se pasa a la siguiente fase cuando **se cumple la meta** y **el gasto mensual está cubierto** (por ingresos o por presupuesto personal). Si no, se repite con ajustes.
- **Señal de alerta:** si a los 3 meses del lanzamiento hay menos de 100 usuarios o menos de 3 empresas interesadas, no sumar publicidad. Cambiar el enfoque (más trabajo presencial, otra zona, otro rubro).
- **Validar antes de programar** lo que es pago: mostrar la demo y preguntar cuánto pagarían.

## Validación previa (Fase 0, en paralelo al desarrollo)

- Probar Taponto y uno o dos competidores más, y anotar qué hacen bien y mal.
- Listar 30 comercios de Pando (veterinarias, petshops, peluquerías) e identificar las urgencias.
- Entrevistar a 10 dueños: cómo buscan hoy, qué usarían, si pagarían Pro o Familia y cuánto.
- Mostrar el prototipo a 5–8 comercios: qué les falta y cuánto pagarían por Destacado y Plus.
- Meta: al menos 5 comercios que digan que pagarían, y que sean los primeros candidatos a Socios Fundadores.

### Criterios de corte de la validación

Los resultados se anotan en `investigacion/entrevistas.md` y se decide en el paso 0.0.8b:

| Resultado | Qué se hace |
|---|---|
| **5 comercios o más** pagarían Destacado o Plus | Seguir con el plan de empresas como está |
| **De 2 a 4** pagarían | Seguir, pero revisar precios y propuesta antes de la Fase 1 (qué les falta, cuánto pagarían) |
| **Menos de 2** pagarían | **No construir la parte paga de empresas todavía.** Replantear el modelo de ingresos (chapitas, sponsors, Pro/Familia) antes de la Fase 1 |
| **Menos de la mitad** de los dueños usaría el QR o los recordatorios | Revisar la prioridad de esas funciones y qué pedirían en su lugar |
| **La mayoría** de los dueños ya usa Taponto y está conforme | Priorizar lo que Taponto no tiene y considerar seriamente la alianza |
| Los dueños **no pagarían** Pro ni Familia | El ingreso de usuarios pasa a ser secundario; foco en empresas, chapitas y sponsors |

Cualquier cambio de plan se anota en `12-decisiones.md`.
