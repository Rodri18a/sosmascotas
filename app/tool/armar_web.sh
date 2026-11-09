#!/usr/bin/env bash
# Arma la web de las dos apps en build/web (D129):
#   /            Huellamy (personas)
#   /comercios/  Huellamy Comercios (mismo código, entra por main_comercio.dart)
# Mismo sitio: comparten la sesión. Cada una se instala aparte, con su nombre
# y su ícono. Uso, desde app/:
#   tool/armar_web.sh [dev|prod]      (por defecto dev)
# Después: cd build/web && vercel deploy --prod --yes
set -euo pipefail

entorno="${1:-dev}"
app="$(cd "$(dirname "$0")/.." && pwd)"
config="$app/config/$entorno.json"
[[ -f "$config" ]] || { echo "Falta $config (copiar de config/$entorno.example.json)" >&2; exit 1; }

cd "$app"
comun=(--release --no-wasm-dry-run "--dart-define-from-file=$config")

echo "▶ Huellamy (personas)"
flutter build web "${comun[@]}" --target="$app/lib/main.dart" --output="$app/build/web"

echo "▶ Huellamy Comercios"
# Rutas relativas y sin conversión: en Git Bash (Windows), /comercios/ se
# volvía una ruta de Windows.
MSYS_NO_PATHCONV=1 flutter build web --release --no-wasm-dry-run \
  "--dart-define-from-file=config/$entorno.json" \
  --target=lib/main_comercio.dart --base-href=/comercios/ \
  --output=build/web_comercios

destino="$app/build/web/comercios"
rm -rf "$destino"
cp -r "$app/build/web_comercios" "$destino"
# Nombre, color e íconos propios.
cp "$app/web_comercios/manifest.json" "$destino/manifest.json"
cp "$app/web_comercios/favicon.png" "$destino/favicon.png"
cp "$app/web_comercios/icons/"*.png "$destino/icons/"
sed -i \
  -e 's#<title>Huellamy</title>#<title>Huellamy Comercios</title>#' \
  -e 's#content="Huellamy">#content="Huellamy Comercios">#' \
  -e 's#aria-label="Cargando Huellamy"#aria-label="Cargando Huellamy Comercios"#' \
  -e 's#<img class="logo ilustrado" src="icons/logo.jpg" alt="Huellamy">#<img class="logo" src="icons/isotipo.png" alt=""><div class="nombre">Huellamy Comercios</div>#' \
  "$destino/index.html"
# Las reglas del sitio van una sola vez, en la raíz.
rm -f "$destino/vercel.json"
rm -rf "$app/build/web_comercios"
echo "✅ build/web listo (personas en / y comercios en /comercios/)"
