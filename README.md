# 🐾 SOS Mascota

Plataforma para dueños de mascotas y empresas del rubro: mapa, mascotas perdidas y encontradas, chapita QR, recordatorios de salud, adopción responsable y herramientas para empresas. Arranca en Pando (Uruguay).

> Etapa actual: **base técnica** (Fase 0) con la validación en paralelo. Ver [`docs/PROGRESO.md`](docs/PROGRESO.md).

## Por dónde empezar

| Archivo | Para qué |
|---|---|
| [`docs/PROGRESO.md`](docs/PROGRESO.md) | Plan paso a paso, con el marcador **← ESTÁS ACÁ** |
| [`docs/README.md`](docs/README.md) | Resumen del proyecto en 2 minutos |
| [`CLAUDE.md`](CLAUDE.md) | Contexto y reglas para trabajar con Claude Code |
| [`docs/`](docs/) | Documentación completa (visión, funcionalidades, reglas, arquitectura, costos, hoja de ruta, decisiones) |
| [`app/`](app/) | App Flutter (Android, iPhone y web). Cómo correrla: [`app/README.md`](app/README.md) |
| [`packages/core/`](packages/core/) | Código compartido |
| [`reference/`](reference/) | Brief anterior y prototipo HTML |

## Ver la documentación como web

- **Desde cualquier lado:** en GitHub, carpeta [`docs/`](docs/) (el repo es privado; entrás con tu cuenta).
- **Web completa, local:**

```bash
./ver-docs.sh        # abre http://localhost:3000/docs/
```

Lee los `.md` en vivo: si cambia la documentación, recargá la página. Necesita Python 3 y conexión a internet. La web online con login está preparada y pendiente: ver [`docs/PUBLICACION.md`](docs/PUBLICACION.md).

## Continuar en otra máquina

```bash
git clone https://github.com/Rodri18a/sosmascotas.git
cd sosmascotas
claude          # y decile: "seguimos"
```
