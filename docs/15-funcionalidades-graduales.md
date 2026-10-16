# 15 · Habilitación gradual de funcionalidades

> **Aprobada** el 16/10/2026 (D64), sin cambios; se implementa en los pasos 0.8.0b–e. Complementa los roles de `02-usuarios-roles.md` y los planes de `06-reglas-negocio.md`: los roles dicen **quién puede** hacer algo; esto dice **a quién ya le llegó** una funcionalidad nueva.

## 1. Para qué

Después del lanzamiento cada funcionalidad nueva (chat, reseñas, recordatorios, adopciones, portal de empresas…) tiene que poder:

- **Prenderse de a poco**: primero el equipo, después un grupo de prueba, después una zona o un porcentaje, y al final todos.
- **Apagarse en segundos** si falla, **sin publicar una versión nueva** de la app (en las tiendas eso lleva días).
- Prenderse **por zona** (Pando primero, después otras ciudades) y **por plan** (lo pago).
- Medirse: saber cuántos la vieron y cuántos la usaron antes de ampliarla.

## 2. Tres capas de permiso (en este orden)

Una acción se permite solo si pasa las tres:

| Capa | Pregunta | Dónde vive | Ejemplo |
|---|---|---|---|
| 1. **Rol** | ¿Este tipo de usuario puede hacerlo? | RLS + `profiles.role` (`02-usuarios-roles.md`) | Solo un comercio responde reseñas |
| 2. **Plan** | ¿Su plan lo incluye? | `profiles.plan` / `businesses.plan` (`06-reglas-negocio.md`) | El hogar compartido es del plan Familia |
| 3. **Funcionalidad** | ¿Ya le llegó esta funcionalidad? | **`feature_flags`** (este documento) | El chat está prendido solo en Pando y para el 20 % |

> **Regla de oro:** lo que hace a la seguridad y la salud del animal (SOS, QR, contacto inverso, foto, recordatorios de medicación, 911) **nunca** queda detrás de un plan. Sí puede tener una funcionalidad *nueva* en prueba gradual (por ejemplo, una versión nueva del formulario de SOS), pero siempre con la versión anterior funcionando para el resto.

## 3. Ciclo de vida de una funcionalidad

```
borrador → interna → beta → gradual → todos → (se retira la marca)
                         ↘ apagada (kill switch, en cualquier momento)
```

| Estado | A quién le llega | Para qué |
|---|---|---|
| `borrador` | A nadie (el código ya está en la app, escondido) | Publicar sin miedo |
| `interna` | Administradores y cuentas del equipo | Probar en producción con datos reales |
| `beta` | Lista de personas invitadas (`feature_flag_users`) + interna | Probar con conocidos (paso 0.8.3) y comercios fundadores |
| `gradual` | Beta + las reglas: zonas, planes, roles, plataformas, versión mínima y **porcentaje** | Ampliar de a poco y medir |
| `todos` | Todo el mundo (respetando rol y plan) | Funcionalidad estable |
| `apagada` | A nadie, aunque esté en otro estado | Apagado de emergencia |

Cuando una marca lleva un tiempo en `todos` sin problemas, **se borra del código y de la tabla**. Si no, se acumulan.

## 4. Modelo de datos (propuesta)

```sql
create table public.feature_flags (
  key             text primary key check (key ~ '^[a-z][a-z0-9_]{2,40}$'),  -- 'chat', 'resenas'
  description     text not null,
  stage           text not null default 'borrador'
                  check (stage in ('borrador','interna','beta','gradual','todos')),
  killed          boolean not null default false,       -- apagado de emergencia
  rollout_percent smallint not null default 0 check (rollout_percent between 0 and 100),
  zone_ids        smallint[],   -- null = todas las zonas
  plans           text[],       -- null = todos los planes ('free','pro','family'; comercios: 'basic','featured','plus')
  roles           text[],       -- null = todos ('user','business','admin')
  platforms       text[],       -- null = todas ('web','android','ios')
  min_app_version text,         -- '1.2.0': versiones viejas no la ven
  allow_anonymous boolean not null default false,  -- ¿los visitantes sin cuenta la ven?
  starts_at       timestamptz,  -- prendido programado (por ejemplo, para un evento)
  ends_at         timestamptz,  -- apagado programado (campañas)
  updated_by      uuid references auth.users (id),
  updated_at      timestamptz not null default now()
);

-- Beta: personas invitadas (o excluidas) a mano.
create table public.feature_flag_users (
  flag_key text not null references public.feature_flags (key) on delete cascade,
  user_id  uuid not null references auth.users (id) on delete cascade,
  enabled  boolean not null default true,   -- false = excluida aunque le toque por porcentaje
  primary key (flag_key, user_id)
);

-- Historial: quién cambió qué y cuándo (para entender un problema).
create table public.feature_flag_audit (
  id         bigint generated always as identity primary key,
  flag_key   text not null,
  changed_by uuid,
  before     jsonb,
  after      jsonb,
  created_at timestamptz not null default now()
);
```

**RLS:** las tres tablas **sin acceso directo** desde la app (los nombres de las marcas revelan la hoja de ruta). Solo el administrador las edita desde el portal (Fase 1); un trigger escribe el historial.

## 5. Cómo se decide (en el servidor)

Una sola función, para que la app, las Edge Functions y las políticas de RLS respondan **lo mismo**:

```sql
-- ¿La funcionalidad está prendida para esta persona (o este visitante)?
funcionalidad_activa(p_key text, p_anon_id text default null, p_plataforma text default null,
                     p_version text default null) returns boolean

-- Todas las prendidas, para la app al abrir (una sola consulta).
mis_funcionalidades(p_anon_id text, p_plataforma text, p_version text) returns text[]
```

Orden de evaluación:

1. `killed` → **apagada**. Fuera de `starts_at`…`ends_at` → apagada.
2. Excluida en `feature_flag_users` → apagada. Invitada → **prendida** (salvo `borrador`).
3. `stage`: `borrador` → no; `interna` → solo admin; `beta` → solo invitadas; `todos` → sí.
4. `gradual`: tiene que cumplir **todas** las reglas que no sean `null` (zona del perfil, plan, rol, plataforma, versión ≥ mínima) **y** el porcentaje.
5. **Porcentaje estable:** `hash(clave || id) % 100 < rollout_percent`, con el `user_id` o, sin cuenta, el `anon_id` de métricas. La misma persona cae siempre del mismo lado: al subir del 10 % al 30 % nadie pierde la funcionalidad, solo se suman personas.

> **Lo que se esconde en la app no es seguridad.** Si una funcionalidad escribe datos, su política de RLS o su Edge Function **también** llama a `funcionalidad_activa()`. Así, aunque alguien modifique la app, no puede usar algo que no le llegó.

## 6. Del lado de la app

- **Al abrir y al iniciar sesión**: `mis_funcionalidades()` → se guarda en memoria y en el dispositivo (para abrir sin conexión con lo último conocido). Se refresca cada pocas horas y al volver a la app.
- **Sin conexión y sin nada guardado**: todo lo que está en prueba se considera **apagado** (lo seguro), menos lo que ya está en `todos`, que viene marcado en la app como prendido por defecto.
- **Uso en el código**:

```dart
// Un nombre por funcionalidad, en packages/core (como Eventos).
abstract final class Funcionalidades {
  static const chat = 'chat';
  static const resenas = 'resenas';
}

// En una pantalla:
if (ref.watch(funcionalidadActivaProvider(Funcionalidades.chat))) …

// O como widget:
SiFuncionalidad(Funcionalidades.chat, child: BotonChat(), sinoMostrar: SizedBox.shrink())
```

- **Rutas**: go_router redirige a "Todavía no está disponible" si alguien entra por un enlace a algo que no le llegó.
- **Pruebas**: un `FuncionalidadesFalsas` en `test/helpers.dart` para probar cada pantalla con la marca prendida y apagada.

> **Implementado en 0.8.0d** (`app/lib/src/funcionalidades/funcionalidades_activas.dart`):
> - `funcionalidadesProvider` pregunta con `mis_funcionalidades(anon_id, plataforma, versión)` al abrir, al iniciar o cerrar sesión, cada 3 h con la app abierta y al volver a la app si pasaron 15 min. La versión sale de `app/lib/src/config/version.dart` (una prueba la compara con `pubspec.yaml`).
> - Lo guardado en el dispositivo va **junto con la cuenta** a la que corresponde: otra cuenta, o un visitante en el mismo dispositivo, no lo usa.
> - `SiFuncionalidad(clave, child: …, sinoMostrar: …)` y `funcionalidadActivaProvider(clave)`. La primera marca en uso es `temas_pro` (Ajustes → Tema de colores, además del plan Pro o Familia).
> - Rutas: `Rutas.conFuncionalidad` (comienzo de la ruta → clave) lleva a `/no-disponible?volver=…`, que vuelve sola a la ruta si la funcionalidad llega después (por ejemplo, al terminar de cargar). Un visitante primero ingresa y después se evalúa.
> - `feature_exposure` se anota solo cuando ya se sabe qué le tocó (de la base o de lo guardado), así no cuenta como "apagada" a quien todavía no recibió la respuesta.

## 7. Métricas

- `feature_exposure` (una vez por sesión y marca, cuando la persona **ve** la funcionalidad): props `key`, `variante` (prendida/apagada) → permite comparar grupos.
- El uso se mide con los eventos que ya tiene cada funcionalidad (`chat_message`, `review_create`…).
- Antes de pasar de `gradual` a `todos`: errores sin aumento, uso razonable y ninguna queja de moderación.

## 8. Ejemplos con la hoja de ruta

| Funcionalidad | Cómo se lanzaría |
|---|---|
| Chat entre usuarios (Fase 1) | `interna` → `beta` con 20 conocidos → `gradual` Pando 10 % → 50 % → `todos` |
| Reseñas de comercios (Fase 1) | `beta` con los comercios fundadores → `gradual` por zona |
| Recordatorios de medicación (Fase 1) | `beta` → `todos` rápido (salud: gratis para todos, regla de oro) |
| Hogar compartido (Fase 1) | `gradual` con `plans = {family}` |
| Adopciones (Fase 2) | `gradual` por zona, solo donde haya refugios cargados |
| Portal de empresas (Fase 1–2) | `beta` con comercios elegidos, `roles = {business}` |
| Campaña de fin de año | `todos` con `starts_at` / `ends_at` |

## 9. Panel de administración (Fase 1)

En `05-portal-admin.md` se suma una pantalla **Funcionalidades**: lista de marcas con su estado, un control de porcentaje, zonas, planes, la lista de beta (buscar persona por correo), el botón rojo **Apagar ya** y el historial de cambios. Cada cambio pide confirmación y queda en `feature_flag_audit`.

## 10. Cómo implementarlo (pasos sugeridos)

| Paso | Qué | ⏱️ |
|---|---|---|
| a | Migración de las tres tablas + `funcionalidad_activa()` + `mis_funcionalidades()` + casos en `rls_test.py` (incluido el porcentaje estable) | 3 h |
| b | `packages/core`: nombres de funcionalidades + cálculo del porcentaje (misma cuenta que la base, con pruebas cruzadas) | 1 h |
| c | App: proveedor, `SiFuncionalidad`, caché en el dispositivo, redirección de rutas, evento `feature_exposure`, pruebas | 3 h |
| d | Script `supabase/funcionalidades.py` para prender/apagar desde la terminal hasta que exista el panel | 1 h |
| e | Pantalla en el portal de administración (Fase 1) | 4 h |

> **Paso d implementado en 0.8.0e** (`supabase/funcionalidades.py`): `listar`, `ver <clave>` (con los últimos 10 cambios del historial), `crear`, `etapa`, `porcentaje`, `regla` (zonas, planes, roles, plataformas, version-minima, visitantes, desde, hasta; `-` la borra), `apagar`/`prender` (apagado de emergencia), `invitar`/`excluir`/`quitar` por email. Valida todo antes de conectarse, muestra antes/después y solo escribe con `--aplicar`. Usa la clave secreta del proyecto vinculado (pedida en el momento, no se guarda). Como no hay sesión de administrador, en el historial `changed_by` queda vacío.

Recomendación: hacer **a–d antes del lanzamiento** (Etapa 0.8), para que la primera funcionalidad posterior ya salga con marca y apagado de emergencia.
