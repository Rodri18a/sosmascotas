#!/usr/bin/env python3
"""Datos de demostración en Supabase dev: una cuenta, una mascota con foto y su QR.

Sirve para ver las páginas públicas (QR, SOS) sin cargar nada a mano.
La cuenta usa un correo @example.com (no recibe correos) y se borra con --borrar.

Uso (desde la raíz del repo):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python3 -I supabase/tests/datos_demo.py           # crea y muestra los enlaces
    python3 -I supabase/tests/datos_demo.py --borrar  # borra todo lo de demo
"""
import io
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
PUBLICA = json.loads((RAIZ / 'app/config/dev.json').read_text())['SUPABASE_PUBLISHABLE_KEY']
EMAIL = 'demo-sosmascota@example.com'


def pedir(metodo, url, cuerpo=None, headers=None, crudo=None, tipo='application/json'):
    datos = crudo if crudo is not None else (json.dumps(cuerpo).encode() if cuerpo is not None else None)
    req = urllib.request.Request(url, data=datos, method=metodo,
                                 headers={'Content-Type': tipo, 'User-Agent': 'sosmascotas-demo', **(headers or {})})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            texto = r.read().decode()
            return r.status, json.loads(texto) if texto else None
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def admin():
    _, claves = pedir('GET', f'https://api.supabase.com/v1/projects/{REF}/api-keys?reveal=true',
                      headers={'Authorization': f"Bearer {os.environ['SUPABASE_ACCESS_TOKEN']}"})
    secreta = next(c['api_key'] for c in claves if c.get('type') == 'secret' or c.get('name') == 'service_role')
    return {'apikey': secreta, 'Authorization': f'Bearer {secreta}'}


def foto_demo():
    """Una foto simple (círculo naranja) generada en el momento, sin EXIF."""
    from PIL import Image, ImageDraw
    img = Image.new('RGB', (600, 600), (227, 243, 234))
    ImageDraw.Draw(img).ellipse((120, 120, 480, 480), fill=(214, 140, 60))
    salida = io.BytesIO()
    img.save(salida, 'JPEG', quality=80)
    return salida.getvalue()


def borrar(h):
    _, usuarios = pedir('GET', f'{URL}/auth/v1/admin/users?per_page=1000', headers=h)
    for u in (usuarios or {}).get('users', []):
        if u.get('email') == EMAIL:
            _, archivos = pedir('POST', f"{URL}/storage/v1/object/list/pet-photos",
                                {'prefix': u['id'], 'limit': 100}, h)
            if isinstance(archivos, list) and archivos:
                pedir('DELETE', f'{URL}/storage/v1/object/pet-photos',
                      {'prefixes': [f"{u['id']}/{a['name']}" for a in archivos]}, h)
            pedir('DELETE', f"{URL}/auth/v1/admin/users/{u['id']}", headers=h)
            print('🗑️  Demo borrada.')
            return
    print('No había datos de demo.')


def crear(h):
    borrar(h)
    clave = uuid.uuid4().hex
    _, u = pedir('POST', f'{URL}/auth/v1/admin/users', {
        'email': EMAIL, 'password': clave, 'email_confirm': True,
        'user_metadata': {'full_name': 'Demo SOS Mascota'}}, h)
    _, sesion = pedir('POST', f'{URL}/auth/v1/token?grant_type=password',
                      {'email': EMAIL, 'password': clave}, {'apikey': PUBLICA})
    yo = {'apikey': PUBLICA, 'Authorization': f"Bearer {sesion['access_token']}"}

    ruta = f"{u['id']}/{uuid.uuid4()}.jpg"
    pedir('POST', f'{URL}/storage/v1/object/pet-photos/{ruta}', headers=yo, crudo=foto_demo(), tipo='image/jpeg')
    _, mascotas = pedir('POST', f'{URL}/rest/v1/pets', {
        'name': 'Canela', 'species_id': 1, 'breed_id': 1, 'sex': 'female', 'color': 'Marrón claro',
        'marks': 'Collar rojo y una mancha blanca en el pecho', 'microchip': '858000000654321',
        'photo_path': ruta}, {**yo, 'Prefer': 'return=representation'})
    mascota = mascotas[0]
    _, tags = pedir('GET', f"{URL}/rest/v1/qr_tags?select=id,code&pet_id=eq.{mascota['id']}", headers=yo)
    pedir('PATCH', f"{URL}/rest/v1/qr_tags?id=eq.{tags[0]['id']}",
          {'public_note': 'Es miedosa con los ruidos fuertes. Toma medicación para la tiroides.'}, yo)
    _, sos_id = pedir('POST', f'{URL}/rest/v1/rpc/crear_sos', {'p': {
        'kind': 'lost', 'species_id': 1, 'pet_id': mascota['id'], 'name': 'Canela', 'color': 'Marrón claro',
        'marks': 'Collar rojo y una mancha blanca en el pecho', 'has_microchip': True,
        'description': 'Se escapó con los fuegos artificiales. Es miedosa: no la persigas.',
        'reward': 'Sí, a convenir', 'lat': -34.7195, 'lng': -55.9555, 'photos': [f'pet-photos/{ruta}']}}, yo)
    print(f"✅ Demo creada: Canela (código {tags[0]['code']}), reportada perdida")
    print(f"   Página del QR: http://localhost:3002/m/{tags[0]['code']}")
    print(f"   Página del SOS: http://localhost:3002/s/{sos_id}")
    return tags[0]['code']


if __name__ == '__main__':
    credenciales = admin()
    borrar(credenciales) if '--borrar' in sys.argv else crear(credenciales)
