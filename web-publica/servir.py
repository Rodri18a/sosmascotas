#!/usr/bin/env python3
"""Sirve la web pública en http://localhost:3002 con las mismas reglas que
Cloudflare Pages (_redirects): /m/<código> → m.html y /s/<id> → s.html.

Uso: python3 web-publica/servir.py  (antes: copiar config.example.js como config.js)
"""
import functools
import http.server
import os

RAIZ = os.path.dirname(os.path.abspath(__file__))
REGLAS = {'/m/': '/m.html', '/s/': '/s.html'}


class ConReglas(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        for prefijo, destino in REGLAS.items():
            if self.path.startswith(prefijo):
                self.path = destino
                break
        return super().send_head()


if __name__ == '__main__':
    manejador = functools.partial(ConReglas, directory=RAIZ)
    print('Web pública en http://localhost:3002/  (Ctrl+C para cortar)')
    http.server.ThreadingHTTPServer(('127.0.0.1', 3002), manejador).serve_forever()
