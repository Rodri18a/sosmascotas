#!/usr/bin/env python3
"""Aplica la configuración de login (Auth) al proyecto Supabase vinculado.

Versiona en el repo lo que el panel de Supabase guarda aparte: direcciones
permitidas, largo del código y los correos en español (voseo).
Es idempotente: se puede correr las veces que haga falta.

Uso (desde la raíz del repo):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python3 -I supabase/configurar_auth.py            # muestra los cambios
    python3 -I supabase/configurar_auth.py --aplicar  # los aplica
"""
import json
import os
import pathlib
import sys
import urllib.error
import urllib.request

RAIZ = pathlib.Path(__file__).resolve().parents[1]
REF = (RAIZ / 'supabase/.temp/project-ref').read_text().strip()
API = f'https://api.supabase.com/v1/projects/{REF}/config/auth'
HEADERS = {
    'Authorization': f"Bearer {os.environ['SUPABASE_ACCESS_TOKEN']}",
    'Content-Type': 'application/json',
    'User-Agent': 'sosmascotas-configurar-auth',
}

# Cuerpo de los correos: el código sirve también en la PWA del iPhone
# (el enlace se abre en Safari, no en la app instalada).
CORREO = """<div style="font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;max-width:480px;margin:auto;color:#1b1b1b">
  <h2 style="color:#1F8A5B">🐾 SOS Mascota</h2>
  <p>Tu código para entrar es:</p>
  <p style="font-size:32px;font-weight:700;letter-spacing:6px;margin:16px 0">{{ .Token }}</p>
  <p>Escribilo en la app. Vence en 10 minutos.</p>
  <p>O, si abriste este correo en el mismo dispositivo, tocá acá: <a href="{{ .ConfirmationURL }}">Entrar a SOS Mascota</a></p>
  <p style="color:#666;font-size:13px">Si no lo pediste, ignorá este correo: nadie puede entrar sin el código.</p>
</div>"""

DESEADO = {
    'site_url': 'http://localhost:3001',
    'uri_allow_list': 'http://localhost:3001/**,http://127.0.0.1:3001/**',
    'mailer_otp_length': 6,
    'mailer_otp_exp': 600,
}

# El plan gratis no deja cambiar los correos con el servidor de correo de Supabase:
# se aplican solo cuando hay un proveedor propio (SMTP, paso 0.4.4b).
CORREOS = {
    'mailer_subjects_magic_link': 'Tu código para entrar a SOS Mascota',
    'mailer_templates_magic_link_content': CORREO,
    'mailer_subjects_confirmation': 'Tu código para entrar a SOS Mascota',
    'mailer_templates_confirmation_content': CORREO,
}


def pedir(metodo, cuerpo=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(API, data=datos, method=metodo, headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        sys.exit(f'Supabase respondió {e.code}: {e.read().decode()[:300]}')


def main():
    actual = pedir('GET')
    deseado = dict(DESEADO)
    # Google (paso 0.2.3): se activa cuando el archivo privado tiene las credenciales.
    if os.environ.get('GOOGLE_CLIENT_ID') and os.environ.get('GOOGLE_CLIENT_SECRET'):
        deseado.update({
            'external_google_enabled': True,
            'external_google_client_id': os.environ['GOOGLE_CLIENT_ID'],
            'external_google_secret': os.environ['GOOGLE_CLIENT_SECRET'],
        })
    else:
        print('ℹ️  Sin GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET: el ingreso con Google queda apagado (ver docs/guias/login-google.md).')
    if actual.get('smtp_host'):
        deseado.update(CORREOS)
    else:
        print('ℹ️  Sin proveedor de correo propio: los correos quedan en inglés y solo con enlace (ver 0.4.4b).')
    cambios = {k: v for k, v in deseado.items() if actual.get(k) != v}
    if not cambios:
        print('La configuración de login ya está al día.')
        return
    for clave, valor in cambios.items():
        antes = repr(actual.get(clave))[:60]
        despues = '«oculto»' if 'secret' in clave else repr(valor)[:60]
        print(f'- {clave}: {antes} → {despues}')
    if '--aplicar' in sys.argv:
        pedir('PATCH', cambios)
        print('✅ Aplicado.')
    else:
        print('(Vista previa. Para aplicar: --aplicar)')


if __name__ == '__main__':
    main()
