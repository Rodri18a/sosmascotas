#!/usr/bin/env python3
"""Pruebas de seguridad (RLS) contra el proyecto Supabase de desarrollo.

Prueba desde afuera, como lo haría la app o un atacante con la clave pública:
crea dos cuentas temporales (A y B), comprueba qué puede ver y cambiar cada una,
y al final las borra. La clave secreta se pide a la API de gestión en el momento
y no se guarda en ningún lado.

Uso (desde la raíz del repo):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python3 -I supabase/tests/rls_test.py
"""
import json
import os
import pathlib
import sys
import urllib.error
import urllib.request
import uuid

RAIZ = pathlib.Path(__file__).resolve().parents[2]
REF = (RAIZ / 'supabase/.temp/project-ref').read_text().strip()
URL = f'https://{REF}.supabase.co'
CONFIG = json.loads((RAIZ / 'app/config/dev.json').read_text())
PUBLICA = CONFIG['SUPABASE_PUBLISHABLE_KEY']
TOKEN = os.environ['SUPABASE_ACCESS_TOKEN']

fallas = 0


def pedir(metodo, url, cuerpo=None, headers=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(url, data=datos, method=metodo, headers={
        'Content-Type': 'application/json', 'User-Agent': 'sosmascotas-rls-test', **(headers or {})})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            texto = r.read().decode()
            return r.status, json.loads(texto) if texto else None
    except urllib.error.HTTPError as e:
        texto = e.read().decode()
        try:
            return e.code, json.loads(texto)
        except json.JSONDecodeError:
            return e.code, texto


def clave_secreta():
    _, claves = pedir('GET', f'https://api.supabase.com/v1/projects/{REF}/api-keys?reveal=true',
                      headers={'Authorization': f'Bearer {TOKEN}'})
    for c in claves:
        if c.get('type') == 'secret' or c.get('name') == 'service_role':
            return c['api_key']
    sys.exit('No se encontró la clave secreta')


SECRETA = clave_secreta()
ADMIN = {'apikey': SECRETA, 'Authorization': f'Bearer {SECRETA}'}


def crear_usuario(nombre):
    email = f'prueba-rls-{nombre}-{uuid.uuid4().hex[:8]}@example.com'
    clave = uuid.uuid4().hex
    s, u = pedir('POST', f'{URL}/auth/v1/admin/users', {
        'email': email, 'password': clave, 'email_confirm': True,
        'user_metadata': {'full_name': f'Prueba {nombre}'}}, ADMIN)
    assert s == 200, (s, u)
    s, sesion = pedir('POST', f'{URL}/auth/v1/token?grant_type=password',
                      {'email': email, 'password': clave}, {'apikey': PUBLICA})
    assert s == 200, (s, sesion)
    return u['id'], {'apikey': PUBLICA, 'Authorization': f"Bearer {sesion['access_token']}"}


def rest(metodo, ruta, cuerpo=None, quien=None, prefer='return=representation'):
    h = dict(quien or {'apikey': PUBLICA})
    h['Prefer'] = prefer
    return pedir(metodo, f'{URL}/rest/v1/{ruta}', cuerpo, h)


def caso(descripcion, ok):
    global fallas
    print(('  ✅ ' if ok else '  ❌ ') + descripcion)
    fallas += 0 if ok else 1


def filas(resp):
    s, d = resp
    return d if s in (200, 201) and isinstance(d, list) else []


def bloqueado(resp):
    s, d = resp
    return s in (401, 403) or (s in (200, 201) and d == [])


def main():
    a_id, a = crear_usuario('a')
    b_id, b = crear_usuario('b')
    try:
        print('zones')
        caso('un visitante ve Pando', any(z['slug'] == 'pando' for z in filas(rest('GET', 'zones?select=slug'))))
        caso('un visitante no puede crear zonas', bloqueado(rest('POST', 'zones', {'slug': 'x', 'name': 'x'})))

        print('species / breeds')
        caso('un visitante ve las especies', len(filas(rest('GET', 'species?select=id'))) >= 10)
        caso('un visitante ve las razas de perro', len(filas(rest('GET', 'breeds?select=id&species_id=eq.1'))) > 20)
        caso('A no puede crear especies', bloqueado(rest('POST', 'species', {'slug': 'x', 'name': 'x', 'icon': 'x'}, a)))
        caso('A no puede cambiar razas', bloqueado(rest('PATCH', 'breeds?id=eq.1', {'name': 'x'}, a)))

        print('events')
        anon = str(uuid.uuid4())
        caso('un visitante puede agregar un evento sin usuario',
             rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': anon}, prefer='return=minimal')[0] == 201)
        caso('A puede agregar un evento a su nombre',
             rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': anon, 'user_id': a_id}, a, 'return=minimal')[0] == 201)
        caso('A no puede agregar un evento a nombre de B',
             bloqueado(rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': anon, 'user_id': b_id}, a, 'return=minimal')))
        caso('A no puede leer eventos', bloqueado(rest('GET', 'events?select=id', quien=a)))
        caso('no se puede inventar la fecha',
             bloqueado(rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': anon, 'created_at': '2020-01-01'}, prefer='return=minimal')))

        print('profiles')
        perfil_a = filas(rest('GET', 'profiles?select=*', quien=a))
        caso('el perfil de A se creó solo, con su nombre, plan Gratis y zona Pando',
             len(perfil_a) == 1 and perfil_a[0]['display_name'] == 'Prueba a'
             and perfil_a[0]['plan'] == 'free' and perfil_a[0]['role'] == 'user' and perfil_a[0]['zone_id'] is not None)
        caso('A ve solo su perfil (no el de B)', [p['id'] for p in perfil_a] == [a_id])
        caso('un visitante no ve perfiles', bloqueado(rest('GET', 'profiles?select=id')))
        caso('A puede cambiar su nombre y radio',
             filas(rest('PATCH', f'profiles?id=eq.{a_id}', {'display_name': 'Ana', 'alert_radius_km': 10}, a))[0]['display_name'] == 'Ana')
        caso('A puede registrar que aceptó los términos',
             filas(rest('PATCH', f'profiles?id=eq.{a_id}', {'terms_version': 'prueba', 'terms_accepted_at': '2026-10-14T10:00:00Z'}, a))[0]['terms_version'] == 'prueba')
        caso('A no puede cambiar el perfil de B',
             bloqueado(rest('PATCH', f'profiles?id=eq.{b_id}', {'display_name': 'Hackeado'}, a)))
        caso('A no puede darse el plan Pro', bloqueado(rest('PATCH', f'profiles?id=eq.{a_id}', {'plan': 'pro'}, a)))
        caso('A no puede hacerse administrador', bloqueado(rest('PATCH', f'profiles?id=eq.{a_id}', {'role': 'admin'}, a)))
        caso('A no puede poner un radio de 500 km',
             rest('PATCH', f'profiles?id=eq.{a_id}', {'alert_radius_km': 500}, a)[0] == 400)
        caso('A no puede crear otro perfil', bloqueado(rest('POST', 'profiles', {'id': str(uuid.uuid4())}, a)))
        caso('A no puede borrar su perfil directamente', bloqueado(rest('DELETE', f'profiles?id=eq.{a_id}', quien=a)))

        print('private_contacts')
        pedir('POST', f'{URL}/rest/v1/private_contacts', {'user_id': b_id, 'phone': '099123456'}, {**ADMIN, 'Prefer': 'return=minimal'})
        caso('A no puede leer teléfonos (ni el de B)', bloqueado(rest('GET', 'private_contacts?select=*', quien=a)))
        caso('B no puede leer ni su propio teléfono desde la app', bloqueado(rest('GET', 'private_contacts?select=*', quien=b)))
        caso('A no puede cargar teléfonos', bloqueado(rest('POST', 'private_contacts', {'user_id': a_id, 'phone': '099000000'}, a)))
        caso('un visitante no puede leer teléfonos', bloqueado(rest('GET', 'private_contacts?select=*')))

        print('auth')
        email_c = f'prueba-rls-c-{uuid.uuid4().hex[:8]}@example.com'
        s_link, link = pedir('POST', f'{URL}/auth/v1/admin/generate_link', {'type': 'magiclink', 'email': email_c}, ADMIN)
        if s_link != 200:
            s_link, link = pedir('POST', f'{URL}/auth/v1/admin/generate_link', {'type': 'signup', 'email': email_c, 'password': uuid.uuid4().hex}, ADMIN)
        codigo = (link or {}).get('email_otp', '')
        caso('el código del correo tiene 6 números', len(codigo) == 6 and codigo.isdigit())
        s_v, ses = pedir('POST', f'{URL}/auth/v1/verify', {'type': 'email', 'email': email_c, 'token': codigo}, {'apikey': PUBLICA})
        caso('con el código se inicia sesión (como en la app)', s_v == 200 and 'access_token' in (ses or {}))
        s_v2, _ = pedir('POST', f'{URL}/auth/v1/verify', {'type': 'email', 'email': email_c, 'token': codigo}, {'apikey': PUBLICA})
        caso('el mismo código no sirve dos veces', s_v2 != 200)
        c_id = (link or {}).get('id') or ((ses or {}).get('user') or {}).get('id')
        if c_id:
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{c_id}', headers=ADMIN)

        print('delete-account (borrar mi cuenta)')
        funcion = f'{URL}/functions/v1/delete-account'
        caso('sin sesión no borra nada', pedir('POST', funcion, {}, {'apikey': PUBLICA})[0] == 401)
        caso('con un token inventado no borra nada',
             pedir('POST', funcion, {}, {'apikey': PUBLICA, 'Authorization': 'Bearer inventado'})[0] == 401)
        d_id, d = crear_usuario('d')
        pedir('POST', f'{URL}/rest/v1/private_contacts', {'user_id': d_id, 'phone': '099111222'}, {**ADMIN, 'Prefer': 'return=minimal'})
        pedir('POST', f'{URL}/rest/v1/events', {'name': 'prueba_rls', 'anon_id': str(uuid.uuid4()), 'user_id': d_id}, {**d, 'Prefer': 'return=minimal'})
        s_b, r_b = pedir('POST', funcion, {}, d)
        caso('con su sesión, D borra su cuenta', s_b == 200 and (r_b or {}).get('borrada') is True)
        caso('el login de D ya no existe', pedir('GET', f'{URL}/auth/v1/admin/users/{d_id}', headers=ADMIN)[0] == 404)
        caso('el perfil de D se borró', filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=eq.{d_id}', headers=ADMIN)) == [])
        caso('el teléfono de D se borró', filas(pedir('GET', f'{URL}/rest/v1/private_contacts?select=user_id&user_id=eq.{d_id}', headers=ADMIN)) == [])
        caso('los eventos de D quedaron anónimos',
             filas(pedir('GET', f'{URL}/rest/v1/events?select=id&user_id=eq.{d_id}', headers=ADMIN)) == [])
        caso('A y B siguen existiendo',
             len(filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=in.({a_id},{b_id})', headers=ADMIN))) == 2)
    finally:
        for uid in (a_id, b_id):
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{uid}', headers=ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/events?name=eq.prueba_rls', headers=ADMIN)
        quedan = filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=in.({a_id},{b_id})', headers=ADMIN))
        caso('al borrar las cuentas se borran sus perfiles', quedan == [])

    print(f'\n{"Todo bien" if fallas == 0 else f"{fallas} caso(s) fallaron"}')
    sys.exit(1 if fallas else 0)


if __name__ == '__main__':
    main()
