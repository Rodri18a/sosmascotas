#!/usr/bin/env bash
# Arma la web de las dos apps, cada una en la raíz de su dirección (D156):
#   build/web            Huellamy (personas)  → app.huellamy.com
#   build/web_comercios  Huellamy Comercios   → comercios.huellamy.com
# Mismo código: Comercios entra por main_comercio.dart, con su nombre, su
# manifest y sus íconos. Son direcciones distintas: no comparten la sesión
# (misma cuenta, se ingresa en cada una). Uso, desde app/:
#   tool/armar_web.sh [dev|prod]      (por defecto dev)
# config/<entorno>.json tiene que traer APP_URL y COMERCIOS_URL.
# Después, en cada carpeta: vercel deploy --prod --yes
set -euo pipefail

entorno="${1:-dev}"
app="$(cd "$(dirname "$0")/.." && pwd)"
config="$app/config/$entorno.json"
[[ -f "$config" ]] || { echo "Falta $config (copiar de config/$entorno.example.json)" >&2; exit 1; }

valor() { sed -n "s#.*\"$1\": *\"\([^\"]*\)\".*#\1#p" "$config"; }
url_app="$(valor APP_URL)"
url_comercios="$(valor COMERCIOS_URL)"
for u in "$url_app" "$url_comercios"; do
  [[ "$u" == https://* ]] || { echo "En $config faltan APP_URL y COMERCIOS_URL (https://…)" >&2; exit 1; }
done

cd "$app"
comun=(--release --no-wasm-dry-run "--dart-define-from-file=$config")

echo "▶ Huellamy (personas) → $url_app"
flutter build web "${comun[@]}" --target="$app/lib/main.dart" --output="$app/build/web"

echo "▶ Huellamy Comercios → $url_comercios"
flutter build web "${comun[@]}" --target="$app/lib/main_comercio.dart" --output="$app/build/web_comercios"

# Los avisos push que tocan la otra app se abren en su dirección.
sed -i -e "s#__OTRA_APP_URL__#$url_comercios#" -e "s#__ES_COMERCIOS__#no#" \
  "$app/build/web/firebase-messaging-sw.js"

destino="$app/build/web_comercios"
sed -i -e "s#__OTRA_APP_URL__#$url_app#" -e "s#__ES_COMERCIOS__#si#" \
  "$destino/firebase-messaging-sw.js"
# Nombre, color e íconos propios.
cp "$app/web_comercios/manifest.json" "$destino/manifest.json"
cp "$app/web_comercios/favicon.png" "$destino/favicon.png"
cp "$app/web_comercios/icons/"*.png "$destino/icons/"
sed -i \
  -e 's#<title>Huellamy</title>#<title>Huellamy Comercios</title>#' \
  -e 's#content="Huellamy">#content="Huellamy Comercios">#' \
  -e 's#aria-label="Cargando Huellamy"#aria-label="Cargando Huellamy Comercios"#' \
  -e 's#<img class="logo ilustrado" src="icons/logo.png" alt="Huellamy">#<img class="logo" src="icons/isotipo.png" alt=""><div class="nombre">Huellamy Comercios</div>#' \
  "$destino/index.html"
grep -q "Huellamy Comercios</title>" "$destino/index.html" || { echo "No se pudo poner el nombre de Comercios en index.html" >&2; exit 1; }
echo "✅ build/web (Huellamy) y build/web_comercios (Huellamy Comercios) listos"
