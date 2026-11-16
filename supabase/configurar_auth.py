#!/usr/bin/env python3
"""Aplica la configuración de login (Auth) al proyecto Supabase vinculado.

Versiona en el repo lo que el panel de Supabase guarda aparte: direcciones
permitidas, largo del código y los correos en español (voseo).
Es idempotente: se puede correr las veces que haga falta.

Uso (desde la raíz del repo):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python3 -I supabase/configurar_auth.py            # muestra los cambios
    python3 -I supabase/configurar_auth.py --aplicar  # los aplica

Producción (0.8.5): el archivo de credenciales de prod define SOSM_APP_URL,
SOSM_ADMIN_URL y SOSM_COMERCIOS_URL; con ellas se usan esas direcciones y no se permite localhost.
Si además define SOSM_PROJECT_REF, el script se niega a correr contra otro
proyecto (por ejemplo, con dev todavía vinculado).
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
  <h2 style="color:#0B4F94;font-weight:900">Huellamy</h2>
  <p>Tu código para entrar es:</p>
  <p style="font-size:32px;font-weight:700;letter-spacing:6px;margin:16px 0">{{ .Token }}</p>
  <p>Escribilo en la app. Vence en 10 minutos.</p>
  <p>O, si abriste este correo en el mismo dispositivo, tocá acá: <a href="{{ .ConfirmationURL }}">Entrar a Huellamy</a></p>
  <p style="color:#666;font-size:13px">Si no lo pediste, ignorá este correo: nadie puede entrar sin el código.</p>
</div>"""

# Dirección principal: la app de prueba online (Vercel, docs/PUBLICACION.md).
# Supabase manda ahí si el pedido no trae una dirección permitida; localhost
# queda permitido para desarrollar en la máquina.
APP_ONLINE = os.environ.get('SOSM_APP_URL', 'https://sosmascota-dev.vercel.app')
# Portal de administración (etapa 1.8, D76): el enlace del correo vuelve ahí.
ADMIN_ONLINE = os.environ.get('SOSM_ADMIN_URL', 'https://sosmascota-admin.vercel.app')
# Huellamy Comercios (D156): otra app, otro origen; el login vuelve ahí.
COMERCIOS_ONLINE = os.environ.get('SOSM_COMERCIOS_URL', 'https://sosmascota-comercios-dev.vercel.app')
PRODUCCION = 'SOSM_APP_URL' in os.environ
LOCALES = [] if PRODUCCION else ['http://localhost:3001/**', 'http://127.0.0.1:3001/**']
# Mientras no haya producción (0.8.5), los subdominios de huellamy.com apuntan a
# los proyectos de dev (0.8.6e, D159). Al pasarlos a prod, sacar esta lista.
DOMINIOS_EN_DEV = [] if PRODUCCION else [
    'https://app.huellamy.com/**',
    'https://comercios.huellamy.com/**',
    'https://admin.huellamy.com/**',
]
DESEADO = {
    'site_url': APP_ONLINE,
    'uri_allow_list': ','.join([
        f'{APP_ONLINE}/**',
        f'{ADMIN_ONLINE}/**',
        f'{COMERCIOS_ONLINE}/**',
        *DOMINIOS_EN_DEV,
        *LOCALES,
    ]),
    'mailer_otp_length': 6,
    'mailer_otp_exp': 600,
}

# El plan gratis no deja cambiar los correos con el servidor de correo de Supabase:
# se aplican solo cuando hay un proveedor propio (SMTP, paso 0.4.4b).
CORREOS = {
    'mailer_subjects_magic_link': 'Tu código para entrar a Huellamy',
    'mailer_templates_magic_link_content': CORREO,
    'mailer_subjects_confirmation': 'Tu código para entrar a Huellamy',
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
    esperado = os.environ.get('SOSM_PROJECT_REF')
    if esperado and esperado != REF:
        sys.exit(f'❌ El proyecto vinculado es {REF}, pero las credenciales son de {esperado}. '
                 'Vinculá el proyecto correcto con supabase link.')
    print(f"Proyecto {REF} ({'producción' if PRODUCCION else 'dev'}): {APP_ONLINE}")
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
        # Los secretos no se muestran nunca, ni el valor nuevo ni el actual.
        secreto = 'secret' in clave
        antes = '«oculto»' if secreto else repr(actual.get(clave))[:60]
        despues = '«oculto»' if secreto else repr(valor)[:60]
        print(f'- {clave}: {antes} → {despues}')
    if '--aplicar' in sys.argv:
        pedir('PATCH', cambios)
        print('✅ Aplicado.')
    else:
        print('(Vista previa. Para aplicar: --aplicar)')


if __name__ == '__main__':
    main()
