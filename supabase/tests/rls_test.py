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
import math
import os
import pathlib
import struct
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


def subir(ruta, datos, tipo, quien):
    req = urllib.request.Request(f'{URL}/storage/v1/object/{ruta}', data=datos, method='POST',
                                 headers={**quien, 'Content-Type': tipo, 'User-Agent': 'sosmascotas-rls-test'})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


JPEG_MINIMO = bytes.fromhex('ffd8ffe000104a46494600010100000100010000ffdb004300') + bytes(64) + bytes.fromhex('ffd9')


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


# Ids de objetivos usados en las pruebas: sus eventos de métricas se borran al final.
OBJETIVOS_DE_PRUEBA = []


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

        print('pets')
        r_pet = rest('POST', 'pets', {'name': 'Firulais', 'species_id': 1, 'breed_id': 1, 'microchip': '858000000123456'}, a)
        pet = filas(r_pet)[0] if filas(r_pet) else {}
        caso('A puede crear su mascota (queda a su nombre)', pet.get('owner_id') == a_id)
        caso('B no ve la mascota de A', filas(rest('GET', 'pets?select=id', quien=b)) == [])
        caso('un visitante no ve mascotas', bloqueado(rest('GET', 'pets?select=id')))
        caso('B no puede cambiar la mascota de A', bloqueado(rest('PATCH', f"pets?id=eq.{pet.get('id')}", {'name': 'X'}, b)))
        caso('B no puede borrar la mascota de A', bloqueado(rest('DELETE', f"pets?id=eq.{pet.get('id')}", quien=b)))
        caso('A no puede crear una mascota a nombre de B',
             bloqueado(rest('POST', 'pets', {'name': 'X', 'species_id': 1, 'owner_id': b_id}, a)))
        razas_gato = filas(rest('GET', 'breeds?select=id&species_id=eq.2&limit=1'))
        caso('una raza de gato no sirve para un perro',
             rest('POST', 'pets', {'name': 'X', 'species_id': 1, 'breed_id': razas_gato[0]['id']}, a)[0] in (400, 409))
        caso('un microchip que no tiene 15 números se rechaza',
             rest('POST', 'pets', {'name': 'X', 'species_id': 1, 'microchip': '12345'}, a)[0] == 400)
        caso('A puede editar su mascota',
             filas(rest('PATCH', f"pets?id=eq.{pet.get('id')}", {'color': 'Negro'}, a))[0]['color'] == 'Negro')

        print('qr_tags y página pública')
        tags_a = filas(rest('GET', f"qr_tags?select=*&pet_id=eq.{pet.get('id')}", quien=a))
        tag = tags_a[0] if tags_a else {}
        caso('al crear la mascota se creó su QR digital activo',
             len(tags_a) == 1 and tag.get('active') and len(tag.get('code', '')) == 8)
        caso('B no ve los QR de A', filas(rest('GET', 'qr_tags?select=id', quien=b)) == [])
        caso('un visitante no lista QR', bloqueado(rest('GET', 'qr_tags?select=id')))
        s_pag, pagina = rest('POST', 'rpc/public_pet_page', {'p_code': tag.get('code', '').lower()})
        texto_pagina = json.dumps(pagina, ensure_ascii=False)
        caso('un visitante ve la página pública con el nombre (sin importar mayúsculas)',
             s_pag == 200 and pagina.get('status') == 'active' and pagina['pet']['name'] == 'Firulais')
        caso('la página no muestra el microchip ni datos del dueño',
             '858000000123456' not in texto_pagina and a_id not in texto_pagina
             and pagina['pet'].get('has_microchip') is True)
        caso('un código inexistente dice not_found',
             rest('POST', 'rpc/public_pet_page', {'p_code': 'ZZZZZZZZ'})[1].get('status') == 'not_found')
        caso('A puede escribir la nota pública',
             filas(rest('PATCH', f"qr_tags?id=eq.{tag.get('id')}", {'public_note': 'Toma medicación'}, a))[0]['public_note'] == 'Toma medicación')
        caso('A no puede cambiarse el código a mano', bloqueado(rest('PATCH', f"qr_tags?id=eq.{tag.get('id')}", {'code': 'AAAAAAAA'}, a)))
        caso('B no puede regenerar el QR de A',
             rest('POST', 'rpc/regenerar_qr', {'p_pet_id': pet.get('id')}, b)[0] in (401, 403))
        s_reg, nuevo = rest('POST', 'rpc/regenerar_qr', {'p_pet_id': pet.get('id')}, a)
        caso('A regenera su QR: el viejo deja de funcionar y el nuevo sí',
             s_reg == 200 and nuevo != tag.get('code')
             and rest('POST', 'rpc/public_pet_page', {'p_code': tag.get('code')})[1].get('status') == 'inactive'
             and rest('POST', 'rpc/public_pet_page', {'p_code': nuevo})[1].get('status') == 'active')
        caso('un visitante no puede regenerar QR', rest('POST', 'rpc/regenerar_qr', {'p_pet_id': pet.get('id')})[0] in (401, 403))

        print('owner-alert (contacto inverso)')
        aviso_url = f'{URL}/functions/v1/owner-alert'
        OBJETIVOS_DE_PRUEBA.extend([tag.get('id')] + [t['id'] for t in filas(rest('GET', 'qr_tags?select=id', quien=a))])
        ua = {'apikey': PUBLICA, 'User-Agent': f'prueba-{uuid.uuid4()}'}  # dispositivo nuevo en cada corrida
        base = {'target_type': 'qr', 'code': nuevo, 'message': 'La vi en la plaza', 'sender_name': 'Carla',
                'sender_contact': '099 555 666', 'consent': True, 'turnstile_token': 'XXXX.DUMMY.TOKEN.XXXX'}
        caso('sin aceptar compartir el contacto se rechaza',
             pedir('POST', aviso_url, {**base, 'consent': False}, ua)[0] == 400)
        caso('sin el control anti-bots se rechaza',
             pedir('POST', aviso_url, {k: v for k, v in base.items() if k != 'turnstile_token'}, ua)[0] == 400)
        caso('un código inexistente no revela nada', pedir('POST', aviso_url, {**base, 'code': 'ZZZZZZZZ'}, ua)[0] == 404)
        caso('el código viejo (cambiado) ya no recibe avisos', pedir('POST', aviso_url, {**base, 'code': tag.get('code')}, ua)[0] == 404)
        s_av, r_av = pedir('POST', aviso_url, {**base, 'location': {'lat': -34.7171, 'lng': -55.9581}}, ua)
        caso('un visitante deja un aviso (sin cuenta)', s_av == 200 and r_av.get('ok') is True)
        caso('la respuesta no expone al dueño', a_id not in json.dumps(r_av))
        avisos_a = filas(rest('GET', 'owner_alerts_app?select=*', quien=a))
        caso('A ve el aviso con el contacto de quien avisó y la ubicación',
             len(avisos_a) == 1 and avisos_a[0]['sender_contact'] == '099 555 666' and avisos_a[0]['lat'] is not None)
        caso('B no ve los avisos de A', filas(rest('GET', 'owner_alerts_app?select=id', quien=b)) == [])
        caso('un visitante no ve avisos', bloqueado(rest('GET', 'owner_alerts?select=id')))
        caso('nadie puede crear avisos directo en la tabla (solo la función)',
             bloqueado(rest('POST', 'owner_alerts', {'target_type': 'qr', 'target_id': tag.get('id'), 'owner_id': a_id,
                                                     'sender_name': 'x', 'sender_contact': '0991234', 'message': 'x',
                                                     'device_hash': 'a' * 64}, b)))
        aviso_id = avisos_a[0]['id'] if avisos_a else ''
        caso('A no puede cambiar el mensaje del aviso', bloqueado(rest('PATCH', f'owner_alerts?id=eq.{aviso_id}', {'message': 'x'}, a)))
        caso('A marca el aviso como estafa',
             filas(rest('PATCH', f'owner_alerts?id=eq.{aviso_id}', {'status': 'scam_reported'}, a))[0]['status'] == 'scam_reported')
        s_bl, _ = pedir('POST', aviso_url, base, ua)
        caso('el remitente bloqueado recibe "ok" pero el aviso no llega',
             s_bl == 200 and len(filas(rest('GET', 'owner_alerts_app?select=id', quien=a))) == 1)
        otro = {'apikey': PUBLICA, 'User-Agent': f'prueba-{uuid.uuid4()}'}
        resultados = [pedir('POST', aviso_url, base, otro)[0] for _ in range(6)]
        caso('más de 5 avisos por hora desde el mismo dispositivo se frenan', resultados[:5] == [200] * 5 and resultados[5] == 429)

        print('qr_scans (escaneos)')
        s_esc, escaneo = rest('POST', 'rpc/registrar_escaneo', {'p_code': nuevo})
        caso('un visitante registra un escaneo y recibe su id', s_esc == 200 and isinstance(escaneo, str))
        caso('con un código inexistente no se registra nada',
             rest('POST', 'rpc/registrar_escaneo', {'p_code': 'ZZZZZZZZ'})[1] is None)
        caso('con el código viejo (cambiado) no se registra nada',
             rest('POST', 'rpc/registrar_escaneo', {'p_code': tag.get('code')})[1] is None)
        caso('quien escaneó comparte su ubicación',
             rest('POST', 'rpc/compartir_ubicacion_escaneo', {'p_scan_id': escaneo, 'p_lat': -34.72, 'p_lng': -55.95})[1] is True)
        caso('no se puede cambiar la ubicación ya compartida',
             rest('POST', 'rpc/compartir_ubicacion_escaneo', {'p_scan_id': escaneo, 'p_lat': 0, 'p_lng': 0})[1] is False)
        escaneos_a = filas(rest('GET', 'qr_scans_app?select=*', quien=a))
        caso('A ve el escaneo con la ubicación compartida',
             len(escaneos_a) == 1 and abs(escaneos_a[0]['lat'] + 34.72) < 1e-6)
        caso('B no ve los escaneos de A', filas(rest('GET', 'qr_scans_app?select=id', quien=b)) == [])
        caso('un visitante no ve escaneos', bloqueado(rest('GET', 'qr_scans?select=id')))
        caso('nadie inserta escaneos directo', bloqueado(rest('POST', 'qr_scans', {'qr_id': tag.get('id'), 'owner_id': a_id}, b)))

        print('push por escaneo (aviso_escaneo y qr-scan-alert)')
        caso('un visitante no puede llamar a aviso_escaneo', rest('POST', 'rpc/aviso_escaneo', {'p_scan': escaneo})[0] >= 400)
        caso('A tampoco (solo la Edge Function)', rest('POST', 'rpc/aviso_escaneo', {'p_scan': escaneo}, a)[0] >= 400)
        s_q, r_q = pedir('POST', f'{URL}/functions/v1/qr-scan-alert', {'scan_id': str(uuid.uuid4())}, {'apikey': PUBLICA})
        caso('con un escaneo inventado responde igual y no avisa', s_q == 200 and r_q == {'ok': True})
        caso('sin id de escaneo no hace nada',
             pedir('POST', f'{URL}/functions/v1/qr-scan-alert', {'scan_id': 'x'}, {'apikey': PUBLICA})[0] == 400)
        aviso = filas(pedir('POST', f'{URL}/rest/v1/rpc/aviso_escaneo', {'p_scan': escaneo}, ADMIN))
        caso('el escaneo avisa al dueño, con el nombre de la mascota',
             len(aviso) == 1 and aviso[0]['owner_id'] == a_id and aviso[0]['pet_name'] == pet.get('name'))
        caso('un escaneo avisa una sola vez',
             filas(pedir('POST', f'{URL}/rest/v1/rpc/aviso_escaneo', {'p_scan': escaneo}, ADMIN)) == [])
        otro = rest('POST', 'rpc/registrar_escaneo', {'p_code': nuevo})[1]
        caso('otro escaneo del mismo QR antes de 10 minutos no vuelve a avisar',
             isinstance(otro, str) and filas(pedir('POST', f'{URL}/rest/v1/rpc/aviso_escaneo', {'p_scan': otro}, ADMIN)) == [])

        print('sos_reports (perdidos y encontrados)')
        caso('A sube una foto de SOS en su carpeta', subir(f'sos-photos/{a_id}/sos1.jpg', JPEG_MINIMO, 'image/jpeg', a) == 200)
        caso('A no puede subir fotos de SOS en la carpeta de B', subir(f'sos-photos/{b_id}/x.jpg', JPEG_MINIMO, 'image/jpeg', a) != 200)
        reporte = {'kind': 'lost', 'species_id': 1, 'name': 'Firulais', 'color': 'Negro',
                   'lat': -34.7171, 'lng': -55.9581, 'photos': [f'sos-photos/{a_id}/sos1.jpg'], 'pet_id': pet.get('id')}
        caso('sin foto no se puede publicar', rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'photos': []}}, a)[0] >= 400)
        caso('con una foto de otra persona no se puede publicar',
             rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'photos': [f'sos-photos/{b_id}/x.jpg']}}, a)[0] >= 400)
        caso('B no puede reportar la mascota de A como propia',
             rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'photos': [f'sos-photos/{b_id}/x.jpg']}}, b)[0] >= 400)
        caso('un visitante no puede publicar', rest('POST', 'rpc/crear_sos', {'p': reporte})[0] in (401, 403))
        caso('no se aceptan rutas con ".." ni de otros buckets',
             rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'photos': [f'sos-photos/{a_id}/../{b_id}/x.jpg']}}, a)[0] >= 400
             and rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'photos': [f'otro/{a_id}/x.jpg']}}, a)[0] >= 400)
        s_sos, sos_id = rest('POST', 'rpc/crear_sos', {'p': reporte}, a)
        caso('A publica un SOS de su mascota', s_sos == 200 and isinstance(sos_id, str))
        OBJETIVOS_DE_PRUEBA.append(sos_id if isinstance(sos_id, str) else '')
        caso('nadie lee la tabla de SOS directo (ni el autor)',
             bloqueado(rest('GET', 'sos_reports?select=*', quien=a)) and bloqueado(rest('GET', 'sos_reports?select=*')))
        mios = filas(rest('POST', 'rpc/mis_sos', {}, a))
        mio = mios[0] if mios else {}
        caso('A ve su reporte con la ubicación exacta', abs(mio.get('lat', 0) + 34.7171) < 1e-9 and mio.get('photos') == [f'sos-photos/{a_id}/sos1.jpg'])
        dlat = math.radians(mio.get('public_lat', 0) - mio.get('lat', 0))
        dlng = math.radians(mio.get('public_lng', 0) - mio.get('lng', 0))
        h = math.sin(dlat / 2) ** 2 + math.cos(math.radians(mio.get('lat', 0))) * math.cos(math.radians(mio.get('public_lat', 0))) * math.sin(dlng / 2) ** 2
        distancia = 2 * 6371000 * math.asin(math.sqrt(h))
        caso(f'el punto público está desplazado 150–200 m ({distancia:.0f} m)', 149 <= distancia <= 201)
        caso('B no ve los reportes de A en "mis SOS"', filas(rest('POST', 'rpc/mis_sos', {}, b)) == [])
        for _ in range(2):
            ids_extra = rest('POST', 'rpc/crear_sos', {'p': {**reporte, 'pet_id': None}}, a)[1]
            if isinstance(ids_extra, str):
                OBJETIVOS_DE_PRUEBA.append(ids_extra)
        caso('el cuarto reporte del día se rechaza (máximo 3)',
             'limite_diario' in json.dumps(rest('POST', 'rpc/crear_sos', {'p': reporte}, a)[1]))

        print('sos públicos (mapa y lista)')
        en_zona = filas(rest('POST', 'rpc/sos_en_zona', {'p_min_lat': -34.8, 'p_min_lng': -56.05, 'p_max_lat': -34.65, 'p_max_lng': -55.85}))
        pin = next((x for x in en_zona if x['id'] == sos_id), None)
        caso('un visitante ve el pin del SOS en la zona de Pando', pin is not None and set(pin) == {'id', 'kind', 'lat', 'lng'})
        caso('el pin usa el punto aproximado, no el exacto',
             pin is not None and abs(pin['lat'] - mio['public_lat']) < 1e-9 and abs(pin['lat'] - mio['lat']) > 1e-6)
        caso('fuera de la zona no aparece',
             all(x['id'] != sos_id for x in filas(rest('POST', 'rpc/sos_en_zona', {'p_min_lat': 10, 'p_min_lng': 10, 'p_max_lat': 11, 'p_max_lng': 11}))))
        cercanos = filas(rest('POST', 'rpc/sos_cercanos', {'p_lat': -34.7171, 'p_lng': -55.9581}))
        tarjeta = next((x for x in cercanos if x['id'] == sos_id), None)
        texto_cercanos = json.dumps(cercanos)
        caso('la lista por cercanía trae la tarjeta con foto y distancia',
             tarjeta is not None and tarjeta['photo'] == f'sos-photos/{a_id}/sos1.jpg' and 140 < tarjeta['distance_m'] < 210)
        caso('la lista no expone al autor ni la ubicación exacta',
             a_id + '"' not in texto_cercanos.replace(f'sos-photos/{a_id}', '') and 'lat' not in (tarjeta or {}))
        caso('la lista está ordenada por distancia',
             [x['distance_m'] for x in cercanos] == sorted(x['distance_m'] for x in cercanos))

        print('sos detalle, WhatsApp opcional y avisos al SOS')
        s_det, det = rest('POST', 'rpc/sos_publico', {'p_id': sos_id})
        texto_det = json.dumps(det)
        caso('un visitante ve el detalle con fotos y zona aproximada',
             s_det == 200 and det.get('status') == 'active' and det.get('photos') == [f'sos-photos/{a_id}/sos1.jpg']
             and abs(det.get('lat', 0) - mio['public_lat']) < 1e-9)
        caso('el detalle no expone al autor ni el punto exacto',
             texto_det.replace(f'sos-photos/{a_id}', '').find(a_id) == -1 and str(mio['lat']) not in texto_det
             and det.get('mine') is False)
        caso('por defecto no muestra WhatsApp', det.get('whatsapp') is None)
        caso('el autor se reconoce como dueño del reporte', rest('POST', 'rpc/sos_publico', {'p_id': sos_id}, a)[1].get('mine') is True)
        rest('POST', 'rpc/guardar_mi_whatsapp', {'p_whatsapp': '099 111 222'}, a)
        caso('B no puede activar el WhatsApp en el SOS de A',
             rest('POST', 'rpc/activar_whatsapp_en_sos', {'p_sos_id': sos_id, 'p_activo': True}, b)[0] >= 400)
        caso('A activa su WhatsApp en el reporte y se muestra',
             rest('POST', 'rpc/activar_whatsapp_en_sos', {'p_sos_id': sos_id, 'p_activo': True}, a)[0] in (200, 204)
             and rest('POST', 'rpc/sos_publico', {'p_id': sos_id})[1].get('whatsapp') == '099 111 222')
        rest('POST', 'rpc/activar_whatsapp_en_sos', {'p_sos_id': sos_id, 'p_activo': False}, a)
        caso('al desactivarlo deja de mostrarse', rest('POST', 'rpc/sos_publico', {'p_id': sos_id})[1].get('whatsapp') is None)
        caso('un visitante no puede guardar WhatsApp', rest('POST', 'rpc/guardar_mi_whatsapp', {'p_whatsapp': '099'})[0] in (401, 403))
        aviso_sos = {'target_type': 'sos', 'report_id': sos_id, 'message': 'La vi cerca de la plaza', 'sender_name': 'Beto',
                     'sender_contact': '098 765 432', 'consent': True}
        caso('sin sesión y sin anti-bots no se puede avisar al SOS',
             pedir('POST', aviso_url, aviso_sos, {'apikey': PUBLICA, 'User-Agent': f'prueba-{uuid.uuid4()}'})[0] == 400)
        caso('B (con sesión, desde la app) avisa al SOS sin anti-bots',
             pedir('POST', aviso_url, aviso_sos, {**b, 'User-Agent': f'prueba-{uuid.uuid4()}'})[0] == 200)
        caso('A recibe el aviso del SOS',
             any(x['target_type'] == 'sos' and x['sender_name'] == 'Beto' for x in filas(rest('GET', 'owner_alerts_app?select=*', quien=a))))

        print('cerrar SOS y "Estoy perdido" en el QR')
        pag_qr = rest('POST', 'rpc/public_pet_page', {'p_code': nuevo})[1]
        caso('con el SOS activo, la página del QR dice "Estoy perdido" y enlaza el reporte',
             pag_qr.get('lost') is True and pag_qr.get('sos_id') == sos_id)
        caso('B no puede cerrar el SOS de A', rest('POST', 'rpc/cerrar_sos', {'p_id': sos_id, 'p_estado': 'resolved'}, b)[0] >= 400)
        caso('no se aceptan estados inventados', rest('POST', 'rpc/cerrar_sos', {'p_id': sos_id, 'p_estado': 'hidden'}, a)[0] >= 400)

        print('flags (reportar contenido)')
        c_id, c = crear_usuario('c')
        try:
            caso('B reporta el SOS', rest('POST', 'flags', {'target_type': 'sos', 'target_id': sos_id, 'reason': 'spam'}, b, 'return=minimal')[0] == 201)
            caso('B no puede reportar dos veces', rest('POST', 'flags', {'target_type': 'sos', 'target_id': sos_id}, b, 'return=minimal')[0] == 409)
            caso('B no puede reportar a nombre de C',
                 bloqueado(rest('POST', 'flags', {'target_type': 'sos', 'target_id': sos_id, 'reporter_id': c_id}, b, 'return=minimal')))
            rest('POST', 'flags', {'target_type': 'sos', 'target_id': sos_id}, c, 'return=minimal')
            caso('con 2 reportes sigue activo', filas(rest('POST', 'rpc/mis_sos', {}, a))[-1]['status'] == 'active'
                 or any(r['id'] == sos_id and r['status'] == 'active' for r in filas(rest('POST', 'rpc/mis_sos', {}, a))))
            rest('POST', 'flags', {'target_type': 'sos', 'target_id': sos_id}, a, 'return=minimal')
            caso('un SOS oculto no se ve para otros', rest('POST', 'rpc/sos_publico', {'p_id': sos_id}, b)[1].get('status') in ('active', 'not_found'))
            caso('con 3 personas distintas se oculta solo',
                 any(r['id'] == sos_id and r['status'] == 'hidden' for r in filas(rest('POST', 'rpc/mis_sos', {}, a))))
            caso('oculto: otros ven not_found y el autor lo sigue viendo',
                 rest('POST', 'rpc/sos_publico', {'p_id': sos_id}, b)[1].get('status') == 'not_found'
                 and rest('POST', 'rpc/sos_publico', {'p_id': sos_id}, a)[1].get('status') == 'hidden')
            caso('A marca su SOS (oculto) como "¡Apareció!"',
                 rest('POST', 'rpc/cerrar_sos', {'p_id': sos_id, 'p_estado': 'resolved'}, a)[0] in (200, 204)
                 and rest('POST', 'rpc/sos_publico', {'p_id': sos_id}, a)[1].get('status') == 'resolved')
            caso('resuelto: ya no aparece en el mapa ni en la lista',
                 all(x['id'] != sos_id for x in filas(rest('POST', 'rpc/sos_en_zona', {'p_min_lat': -34.8, 'p_min_lng': -56.05, 'p_max_lat': -34.65, 'p_max_lng': -55.85})))
                 and all(x['id'] != sos_id for x in filas(rest('POST', 'rpc/sos_cercanos', {'p_lat': -34.7171, 'p_lng': -55.9581}))))
            caso('resuelto: la página del QR deja de decir "Estoy perdido"',
                 rest('POST', 'rpc/public_pet_page', {'p_code': nuevo})[1].get('lost') is False)
            caso('no se puede cerrar dos veces', rest('POST', 'rpc/cerrar_sos', {'p_id': sos_id, 'p_estado': 'archived'}, a)[0] >= 400)
            caso('B no ve los reportes de contenido de otros', all(f['reporter_id'] == b_id for f in filas(rest('GET', 'flags?select=*', quien=b))))
        finally:
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{c_id}', headers=ADMIN)

        print('push_tokens')
        token = 'prueba-rls-' + uuid.uuid4().hex
        guardar = lambda quien, tok=token: rest('POST', 'rpc/guardar_push_token', {'p_token': tok, 'p_platform': 'web'}, quien)[0]
        caso('un visitante no puede guardar tokens', guardar({'apikey': PUBLICA}) >= 400)
        caso('A guarda el token de su dispositivo', guardar(a) in (200, 204))
        caso('A ve su token', [t['token'] for t in filas(rest('GET', 'push_tokens?select=token', quien=a))] == [token])
        caso('B no ve los tokens de A', filas(rest('GET', 'push_tokens?select=token', quien=b)) == [])
        caso('A no puede insertar tokens directamente',
             bloqueado(rest('POST', 'push_tokens', {'token': 'x' * 30, 'user_id': a_id, 'platform': 'web'}, a)))
        caso('B no puede pasarse el token de A con un update',
             bloqueado(rest('PATCH', f'push_tokens?token=eq.{token}', {'user_id': b_id}, b)))
        caso('B no puede borrar el token de A',
             rest('DELETE', f'push_tokens?token=eq.{token}', quien=b)[1] == [])
        caso('no se aceptan plataformas inventadas',
             rest('POST', 'rpc/guardar_push_token', {'p_token': token, 'p_platform': 'tv'}, a)[0] >= 400)
        caso('celular compartido: si B ingresa en el mismo dispositivo, el token pasa a B',
             guardar(b) in (200, 204)
             and filas(rest('GET', 'push_tokens?select=token', quien=a)) == []
             and len(filas(rest('GET', 'push_tokens?select=token', quien=b))) == 1)
        for i in range(11):
            guardar(a, f'{token}-{i:02d}')
        caso('se guardan como máximo 10 dispositivos por persona',
             len(filas(rest('GET', 'push_tokens?select=token', quien=a))) == 10)
        caso('B borra su token al cerrar sesión',
             len(filas(rest('DELETE', f'push_tokens?token=eq.{token}', quien=b))) == 1
             and filas(rest('GET', 'push_tokens?select=token', quien=b)) == [])

        print('avisos por zona (difundir_sos y sos-zone-alert)')
        e_id, e = crear_usuario('e')   # publica
        f_id, f = crear_usuario('f')   # a ~3 km, con avisos activados
        g_id, g = crear_usuario('g')   # a ~30 km
        h_id, h = crear_usuario('h')   # a ~1 km, sin dispositivos con avisos
        try:
            for quien, lat in ((f, -34.690), (g, -34.450), (h, -34.708)):
                rest('POST', 'rpc/guardar_zona_aproximada', {'p_lat': lat, 'p_lng': -55.9581, 'p_origen': 'gps'}, quien)
            for quien, nombre in ((e, 'e'), (f, 'f'), (g, 'g')):
                rest('POST', 'rpc/guardar_push_token', {'p_token': f'prueba-rls-{nombre}-' + uuid.uuid4().hex, 'p_platform': 'web'}, quien)
            subir(f'sos-photos/{e_id}/z1.jpg', JPEG_MINIMO, 'image/jpeg', e)
            sos_e = {'kind': 'lost', 'species_id': 1, 'name': 'Toby', 'lat': -34.7171, 'lng': -55.9581,
                     'photos': [f'sos-photos/{e_id}/z1.jpg']}
            sos1 = rest('POST', 'rpc/crear_sos', {'p': sos_e}, e)[1]
            sos2 = rest('POST', 'rpc/crear_sos', {'p': {**sos_e, 'kind': 'found', 'name': None}}, e)[1]
            OBJETIVOS_DE_PRUEBA.extend([sos1, sos2])
            difundir = lambda sos, autor, tope=3: pedir('POST', f'{URL}/rest/v1/rpc/difundir_sos',
                                                        {'p_sos': sos, 'p_autor': autor, 'p_tope_diario': tope}, ADMIN)

            caso('la app no puede llamar a difundir_sos (ni el autor)',
                 rest('POST', 'rpc/difundir_sos', {'p_sos': sos1, 'p_autor': e_id}, e)[0] >= 400)
            caso('nadie lee a quién se avisó', bloqueado(rest('GET', 'sos_zone_alerts?select=*', quien=e))
                 and bloqueado(rest('GET', 'sos_zone_alerts?select=*', quien=f)))
            caso('otra persona no puede difundir el SOS de E', filas(difundir(sos1, f_id)) == [])
            alerta = pedir('GET', f'{URL}/rest/v1/sos_reports?select=zone_alerted_at&id=eq.{sos1}', headers=ADMIN)[1]
            caso('…y el SOS sigue sin difundir', alerta and alerta[0]['zone_alerted_at'] is None)

            s_fn, r_fn = pedir('POST', f'{URL}/functions/v1/sos-zone-alert', {'sos_id': sos1}, {'apikey': PUBLICA})
            caso('la función pide sesión', s_fn == 401)
            s_fn, r_fn = pedir('POST', f'{URL}/functions/v1/sos-zone-alert', {'sos_id': sos1}, f)
            caso('F no puede difundir el SOS de E desde la función', s_fn in (404, 503))
            s_fn, r_fn = pedir('POST', f'{URL}/functions/v1/sos-zone-alert', {'sos_id': sos1}, e)
            if s_fn == 503:
                alerta = pedir('GET', f'{URL}/rest/v1/sos_reports?select=zone_alerted_at&id=eq.{sos1}', headers=ADMIN)[1]
                caso('sin Firebase configurado no marca el SOS (la app reintenta)', alerta[0]['zone_alerted_at'] is None)
                destinatarios = filas(difundir(sos1, e_id))
            else:
                caso('la función difunde el SOS de E', s_fn == 200 and (r_fn or {}).get('avisados', 0) >= 1)
                destinatarios = [{'user_id': f_id}] if s_fn == 200 else []
                caso('los tokens que FCM rechaza se borran',
                     filas(rest('GET', 'push_tokens?select=token', quien=f)) == [])
            caso('se avisa a F (a 3 km, con avisos); no a G (30 km), ni a H (sin avisos), ni a E (autor)',
                 # Solo se miran las cuentas de prueba: en dev puede haber gente real en Pando.
                 [d['user_id'] for d in destinatarios if d['user_id'] in (e_id, f_id, g_id, h_id)] == [f_id])
            if s_fn == 503:
                de_f = next((d for d in destinatarios if d['user_id'] == f_id), {})
                caso('la distancia sale de la ubicación pública (~3 km, no exacta)',
                     2500 < de_f.get('distancia_m', 0) < 3500 and len(de_f.get('tokens', [])) == 1)
            caso('llamar de nuevo no avisa dos veces', filas(difundir(sos1, e_id)) == [])
            if s_fn == 503:
                caso('con el tope diario cumplido no se avisa más', filas(difundir(sos2, e_id, 1)) == [])
            caso('un SOS cerrado no se difunde',
                 rest('POST', 'rpc/cerrar_sos', {'p_id': sos2, 'p_estado': 'archived'}, e)[0] in (200, 204)
                 and filas(difundir(sos2, e_id)) == [])
        finally:
            pedir('DELETE', f'{URL}/storage/v1/object/sos-photos', {'prefixes': [f'{e_id}/z1.jpg']}, ADMIN)
            for uid in (e_id, f_id, g_id, h_id):
                pedir('DELETE', f'{URL}/auth/v1/admin/users/{uid}', headers=ADMIN)

        print('businesses (veterinarias)')
        pando_rect = {'p_min_lat': -34.80, 'p_min_lng': -56.05, 'p_max_lat': -34.65, 'p_max_lng': -55.85}
        vets = filas(rest('POST', 'rpc/comercios_en_zona', pando_rect))
        caso('un visitante ve las veterinarias activas de Pando', len(vets) >= 1 and all(v['business_type'] == 'vet' for v in vets))
        caso('las de urgencia y 24 h vienen primero',
             [v['emergencies'] for v in vets] == sorted([v['emergencies'] for v in vets], reverse=True))
        caso('fuera del rectángulo visible no aparecen',
             filas(rest('POST', 'rpc/comercios_en_zona', {'p_min_lat': -35.0, 'p_min_lng': -56.3, 'p_max_lat': -34.95, 'p_max_lng': -56.2})) == [])
        caso('nadie lee la tabla directo', bloqueado(rest('GET', 'businesses?select=id')) and bloqueado(rest('GET', 'businesses?select=id', quien=a)))
        caso('A no puede cargar comercios', bloqueado(rest('POST', 'businesses', {'name': 'Falsa', 'location': 'SRID=4326;POINT(-55.95 -34.71)'}, a)))
        if vets:
            caso('A no puede cambiar ni borrar comercios',
                 bloqueado(rest('PATCH', f"businesses?id=eq.{vets[0]['id']}", {'name': 'Hackeada'}, a))
                 and bloqueado(rest('DELETE', f"businesses?id=eq.{vets[0]['id']}", quien=a)))
        s_o, oculta = pedir('POST', f'{URL}/rest/v1/businesses', {
            'name': 'Prueba RLS oculta', 'location': 'SRID=4326;POINT(-55.958 -34.717)', 'status': 'hidden', 'is_sample': True},
            {**ADMIN, 'Prefer': 'return=representation'})
        try:
            caso('una veterinaria oculta no aparece en el mapa',
                 s_o == 201 and all(v['name'] != 'Prueba RLS oculta' for v in filas(rest('POST', 'rpc/comercios_en_zona', pando_rect))))
        finally:
            pedir('DELETE', f'{URL}/rest/v1/businesses?name=eq.Prueba%20RLS%20oculta', headers=ADMIN)
        if vets:
            caso('un visitante registra place_open de una veterinaria (métrica con business_id)',
                 rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': str(uuid.uuid4()), 'business_id': vets[0]['id']},
                      prefer='return=minimal')[0] == 201)
        caso('no se aceptan métricas de un comercio que no existe',
             rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': str(uuid.uuid4()), 'business_id': str(uuid.uuid4())},
                  prefer='return=minimal')[0] >= 400)
        caso('la base rechaza horarios mal escritos',
             pedir('POST', f'{URL}/rest/v1/businesses', {'name': 'Prueba RLS horario', 'location': 'SRID=4326;POINT(-55.958 -34.717)',
                                                       'hours': {'lunes': [['9', '13']]}}, ADMIN)[0] >= 400)

        print('zona para avisos (profiles.approx_location)')
        zona = lambda quien, lat=-34.7171, lng=-55.9581, origen='gps': rest(
            'POST', 'rpc/guardar_zona_aproximada', {'p_lat': lat, 'p_lng': lng, 'p_origen': origen}, quien)[0]
        mi_zona = lambda quien: (filas(rest('GET', 'profiles?select=approx_location,approx_location_source,approx_location_at', quien=quien)) or [{}])[0]
        caso('un visitante no puede guardar zonas', zona({'apikey': PUBLICA}) >= 400)
        caso('A guarda su zona', zona(a) in (200, 204))
        guardada = mi_zona(a)
        # PostgREST devuelve EWKB en hexadecimal: 1 + 4 (tipo) + 4 (SRID) bytes y luego x, y.
        x, y = struct.unpack('<dd', bytes.fromhex(guardada.get('approx_location') or '00' * 25)[9:25])
        caso('se guarda el centro de la celda, no el punto exacto (igual que zonaAproximada en la app)',
             (round(y, 6), round(x, 6)) == (-34.71525, -55.957628))
        caso('queda guardada con origen y fecha', guardada.get('approx_location_source') == 'gps' and guardada.get('approx_location_at') is not None)
        caso('B no ve la zona de A', all(p['id'] == b_id for p in filas(rest('GET', 'profiles?select=id,approx_location', quien=b))))
        caso('un visitante no ve zonas', bloqueado(rest('GET', 'profiles?select=approx_location')))
        caso('A no puede escribir su zona directo (sin redondear)',
             bloqueado(rest('PATCH', f'profiles?id=eq.{a_id}', {'approx_location': 'SRID=4326;POINT(-55.9581 -34.7171)'}, a))
             and mi_zona(a).get('approx_location') == guardada.get('approx_location'))
        caso('A no puede inventar el origen ni la fecha',
             bloqueado(rest('PATCH', f'profiles?id=eq.{a_id}', {'approx_location_source': 'mapa', 'approx_location_at': '2020-01-01'}, a)))
        caso('B no puede cambiar la zona de A', zona(b, -34.9, -56.16) in (200, 204)
             and mi_zona(a).get('approx_location') == guardada.get('approx_location'))
        caso('dos puntos de la misma celda guardan lo mismo (nunca el punto exacto)',
             zona(a, -34.7160, -55.9590) in (200, 204) and mi_zona(a).get('approx_location') == guardada.get('approx_location'))
        caso('un punto de otra celda cambia la zona', zona(a, -34.7300, -55.9581) in (200, 204)
             and mi_zona(a).get('approx_location') != guardada.get('approx_location'))
        caso('no se aceptan coordenadas imposibles', zona(a, 95, 10) >= 400 and zona(a, -34.7, 200) >= 400)
        caso('no se aceptan orígenes inventados', zona(a, origen='ip') >= 400)
        caso('A puede borrar su zona',
             rest('POST', 'rpc/borrar_zona_aproximada', {}, a)[0] in (200, 204)
             and mi_zona(a).get('approx_location') is None and mi_zona(a).get('approx_location_at') is None)
        caso('un visitante no puede usar celda_zona()', rest('POST', 'rpc/celda_zona', {'p_lat': 0, 'p_lng': 0})[0] >= 400)

        print('storage pet-photos')
        caso('A puede subir una foto en su carpeta', subir(f'pet-photos/{a_id}/prueba.jpg', JPEG_MINIMO, 'image/jpeg', a) == 200)
        caso('A no puede subir en la carpeta de B', subir(f'pet-photos/{b_id}/intruso.jpg', JPEG_MINIMO, 'image/jpeg', a) != 200)
        caso('un visitante no puede subir fotos', subir(f'pet-photos/{a_id}/v.jpg', JPEG_MINIMO, 'image/jpeg', {'apikey': PUBLICA}) != 200)
        caso('no se aceptan archivos que no son imágenes', subir(f'pet-photos/{a_id}/x.html', b'<script>', 'text/html', a) != 200)
        caso('no se aceptan fotos de más de 2 MB', subir(f'pet-photos/{a_id}/grande.jpg', JPEG_MINIMO + bytes(2_200_000), 'image/jpeg', a) != 200)
        publica = urllib.request.urlopen(f'{URL}/storage/v1/object/public/pet-photos/{a_id}/prueba.jpg', timeout=30).status
        caso('la foto se puede ver con su enlace', publica == 200)

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
        subir(f'pet-photos/{d_id}/foto.jpg', JPEG_MINIMO, 'image/jpeg', d)
        s_b, r_b = pedir('POST', funcion, {}, d)
        caso('con su sesión, D borra su cuenta', s_b == 200 and (r_b or {}).get('borrada') is True)
        caso('el login de D ya no existe', pedir('GET', f'{URL}/auth/v1/admin/users/{d_id}', headers=ADMIN)[0] == 404)
        caso('el perfil de D se borró', filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=eq.{d_id}', headers=ADMIN)) == [])
        caso('el teléfono de D se borró', filas(pedir('GET', f'{URL}/rest/v1/private_contacts?select=user_id&user_id=eq.{d_id}', headers=ADMIN)) == [])
        try:
            foto_d = urllib.request.urlopen(f'{URL}/storage/v1/object/public/pet-photos/{d_id}/foto.jpg', timeout=30).status
        except urllib.error.HTTPError as e:
            foto_d = e.code
        caso('las fotos de D se borraron', foto_d in (400, 404))
        caso('los eventos de D quedaron anónimos',
             filas(pedir('GET', f'{URL}/rest/v1/events?select=id&user_id=eq.{d_id}', headers=ADMIN)) == [])
        caso('A y B siguen existiendo',
             len(filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=in.({a_id},{b_id})', headers=ADMIN))) == 2)
    finally:
        pedir('DELETE', f'{URL}/storage/v1/object/pet-photos', {'prefixes': [f'{a_id}/prueba.jpg']}, ADMIN)
        pedir('DELETE', f'{URL}/storage/v1/object/sos-photos', {'prefixes': [f'{a_id}/sos1.jpg']}, ADMIN)
        for uid in (a_id, b_id):
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{uid}', headers=ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/events?name=eq.prueba_rls', headers=ADMIN)
        if OBJETIVOS_DE_PRUEBA:
            pedir('DELETE', f"{URL}/rest/v1/events?target_id=in.({','.join(OBJETIVOS_DE_PRUEBA)})", headers=ADMIN)
        quedan = filas(pedir('GET', f'{URL}/rest/v1/profiles?select=id&id=in.({a_id},{b_id})', headers=ADMIN))
        caso('al borrar las cuentas se borran sus perfiles', quedan == [])
        caso('al borrar las cuentas se borran sus mascotas',
             filas(pedir('GET', f'{URL}/rest/v1/pets?select=id&owner_id=in.({a_id},{b_id})', headers=ADMIN)) == [])

    print(f'\n{"Todo bien" if fallas == 0 else f"{fallas} caso(s) fallaron"}')
    sys.exit(1 if fallas else 0)


if __name__ == '__main__':
    main()
