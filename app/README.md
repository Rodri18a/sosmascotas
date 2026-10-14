# App SOS Mascota (Flutter)

App de usuarios y modo comercio, para Android, iPhone y web (PWA). La lógica compartida está en `../packages/core`.

## Primera vez en una máquina

```bash
flutter pub get                                   # en la raíz del repo (espacio de trabajo)
cp app/config/dev.example.json app/config/dev.json  # y completar las claves de Supabase dev (paso 0.1.4)
```

`config/*.json` **no se sube al repositorio** (solo los `*.example.json`).

## Comandos (desde `app/`)

```bash
flutter run -d chrome --dart-define-from-file=config/dev.json   # correr en el navegador
flutter analyze                                                 # reglas de estilo
flutter test                                                    # pruebas
flutter build web --dart-define-from-file=config/dev.json       # build web…
python3 tool/servir_web.py                                      # …y verla en http://localhost:3001
flutter build web --dart-define-from-file=config/prod.json      # build de producción
```

## Estructura

```
lib/
├── main.dart              # Lee el entorno y arranca la app
└── src/
    ├── app.dart           # MaterialApp + tema + etiqueta DEV
    ├── router.dart        # Rutas (go_router): /mapa, /sos, /mascotas, /ayuda, /ajustes
    ├── theme/             # Tema claro y oscuro
    ├── widgets/           # Piezas compartidas entre pantallas
    ├── config/            # Providers de configuración y Supabase
    └── features/<nombre>/ # Una carpeta por funcionalidad (pantallas, providers)
```

Estado con **Riverpod**, navegación con **go_router** (ver `docs/12-decisiones.md`, D45).
