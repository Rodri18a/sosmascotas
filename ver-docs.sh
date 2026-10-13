#!/usr/bin/env bash
# Abre la documentación de SOS Mascota en el navegador.
# Lee los .md en vivo: si cambian, alcanza con recargar la página (F5).
cd "$(dirname "$0")" || exit 1
PUERTO="${1:-3000}"
URL="http://localhost:${PUERTO}/docs/"
echo "Documentación en ${URL}  (Ctrl+C para cerrar)"
(sleep 1 && xdg-open "$URL" >/dev/null 2>&1) &
python3 -m http.server "$PUERTO" --bind 127.0.0.1
