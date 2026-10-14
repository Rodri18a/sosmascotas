#!/usr/bin/env python3
"""Sirve app/build/web en http://localhost:3001 para probar la versión web.

Igual que el hosting real, devuelve index.html para cualquier ruta de la app
(/mapa, /sos…), así funcionan las direcciones limpias y los enlaces directos.
Uso (desde app/): flutter build web --dart-define-from-file=config/dev.json
                  python3 tool/servir_web.py
"""
import functools
import http.server
import os
import sys

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'build', 'web')
PUERTO = int(sys.argv[1]) if len(sys.argv) > 1 else 3001


class ConRutasDeLaApp(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        ruta = self.translate_path(self.path)
        if not os.path.exists(ruta):
            self.path = '/index.html'
        return super().send_head()


if __name__ == '__main__':
    manejador = functools.partial(ConRutasDeLaApp, directory=os.path.normpath(RAIZ))
    print(f'SOS Mascota web en http://localhost:{PUERTO}/  (Ctrl+C para cortar)')
    http.server.ThreadingHTTPServer(('127.0.0.1', PUERTO), manejador).serve_forever()
