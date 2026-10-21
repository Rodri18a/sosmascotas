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
import hashlib
import json
import math
import os
import pathlib
import struct
import sys
import time
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


def pedir(metodo, url, cuerpo=None, headers=None, intentos=4):
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
    except (urllib.error.URLError, ConnectionError, TimeoutError):
        # Un corte de red (no una respuesta): se reintenta con una pausa.
        if intentos <= 1:
            raise
        time.sleep(2)
        return pedir(metodo, url, cuerpo, headers, intentos - 1)


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

        print('health_records (libreta sanitaria)')
        r_vac = rest('POST', 'health_records', {'pet_id': pet.get('id'), 'kind': 'vaccine', 'name': 'Antirrábica',
                                                'date': '2026-09-01', 'next_date': '2027-09-01'}, a)
        vacuna = filas(r_vac)[0] if filas(r_vac) else {}
        caso('A puede cargar una vacuna de su mascota', vacuna.get('name') == 'Antirrábica')
        caso('A ve la libreta de su mascota',
             [v['id'] for v in filas(rest('GET', f"health_records?select=id&pet_id=eq.{pet.get('id')}", quien=a))] == [vacuna.get('id')])
        caso('B no ve la libreta de A', filas(rest('GET', 'health_records?select=id', quien=b)) == [])
        caso('un visitante no ve libretas', bloqueado(rest('GET', 'health_records?select=id')))
        caso('B no puede cargar en la libreta de la mascota de A',
             bloqueado(rest('POST', 'health_records', {'pet_id': pet.get('id'), 'kind': 'other', 'name': 'X'}, b)))
        caso('B no puede cambiar un registro de A',
             bloqueado(rest('PATCH', f"health_records?id=eq.{vacuna.get('id')}", {'name': 'X'}, b)))
        caso('B no puede borrar un registro de A',
             bloqueado(rest('DELETE', f"health_records?id=eq.{vacuna.get('id')}", quien=b)))
        r_pet_b = filas(rest('POST', 'pets', {'name': 'Michi', 'species_id': 2}, b))
        caso('A no puede pasar su registro a la mascota de B',
             bloqueado(rest('PATCH', f"health_records?id=eq.{vacuna.get('id')}", {'pet_id': r_pet_b[0]['id']}, a))
             if r_pet_b else False)
        if r_pet_b:  # la mascota de B y su QR automático confundirían las pruebas de qr_tags
            pedir('DELETE', f"{URL}/rest/v1/qr_tags?owner_id=eq.{b_id}", headers=ADMIN)
            rest('DELETE', f"pets?id=eq.{r_pet_b[0]['id']}", quien=b)
        caso('un tipo inventado se rechaza',
             rest('POST', 'health_records', {'pet_id': pet.get('id'), 'kind': 'magia', 'name': 'X'}, a)[0] == 400)
        caso('la próxima fecha no puede ser anterior a la fecha',
             rest('POST', 'health_records', {'pet_id': pet.get('id'), 'kind': 'checkup', 'name': 'Control',
                                             'date': '2026-09-01', 'next_date': '2026-08-01'}, a)[0] == 400)
        caso('A puede cargar una alergia sin fecha',
             rest('POST', 'health_records', {'pet_id': pet.get('id'), 'kind': 'allergy', 'name': 'Pollo'}, a)[0] == 201)
        caso('A puede editar su registro',
             filas(rest('PATCH', f"health_records?id=eq.{vacuna.get('id')}", {'notes': 'Lote 123'}, a))[0]['notes'] == 'Lote 123')
        caso('A puede borrar su registro',
             len(filas(rest('DELETE', f"health_records?id=eq.{vacuna.get('id')}", quien=a))) == 1)

        print('reminders (recordatorios)')
        pastilla = {'pet_id': pet.get('id'), 'kind': 'medication', 'title': 'Antibiótico', 'dose': '1/2',
                    'schedule': {'tipo': 'cada_horas', 'horas': 8}, 'starts_at': '2026-10-17T11:00:00Z'}
        r_rec = rest('POST', 'reminders', pastilla, a)
        rec = filas(r_rec)[0] if filas(r_rec) else {}
        caso('A puede crear un recordatorio de su mascota', rec.get('title') == 'Antibiótico' and rec.get('active') is True)
        caso('B no ve los recordatorios de A', filas(rest('GET', 'reminders?select=id', quien=b)) == [])
        caso('un visitante no ve recordatorios', bloqueado(rest('GET', 'reminders?select=id')))
        caso('B no puede crear un recordatorio para la mascota de A', bloqueado(rest('POST', 'reminders', pastilla, b)))
        caso('B no puede cambiar un recordatorio de A',
             bloqueado(rest('PATCH', f"reminders?id=eq.{rec.get('id')}", {'title': 'X'}, b)))
        caso('B no puede borrar un recordatorio de A',
             bloqueado(rest('DELETE', f"reminders?id=eq.{rec.get('id')}", quien=b)))
        caso('una frecuencia inventada se rechaza',
             rest('POST', 'reminders', {**pastilla, 'schedule': {'tipo': 'mensual'}}, a)[0] == 400)
        caso('un tipo inventado se rechaza',
             rest('POST', 'reminders', {**pastilla, 'kind': 'magia'}, a)[0] == 400)
        caso('el fin no puede ser antes del inicio',
             rest('POST', 'reminders', {**pastilla, 'ends_on': '2026-10-01'}, a)[0] == 400)
        caso('A puede pausar su recordatorio',
             filas(rest('PATCH', f"reminders?id=eq.{rec.get('id')}", {'active': False}, a))[0]['active'] is False)

        print('reminder_logs (ya se la di)')
        toma = {'reminder_id': rec.get('id'), 'due_at': '2026-10-17T11:00:00Z'}
        r_toma = rest('POST', 'reminder_logs', toma, a)
        hecha = filas(r_toma)[0] if filas(r_toma) else {}
        caso('A puede marcar una toma (queda a su nombre)', hecha.get('done_by') == a_id)
        caso('la misma toma no se puede marcar dos veces', rest('POST', 'reminder_logs', toma, a)[0] == 409)
        caso('A ve el historial', len(filas(rest('GET', f"reminder_logs?select=id&reminder_id=eq.{rec.get('id')}", quien=a))) == 1)
        caso('B no ve el historial de A', filas(rest('GET', 'reminder_logs?select=id', quien=b)) == [])
        caso('un visitante no ve historiales', bloqueado(rest('GET', 'reminder_logs?select=id')))
        caso('B no puede marcar tomas de A',
             bloqueado(rest('POST', 'reminder_logs', {**toma, 'due_at': '2026-10-17T19:00:00Z'}, b)))
        caso('A no puede marcar a nombre de B',
             bloqueado(rest('POST', 'reminder_logs', {**toma, 'due_at': '2026-10-18T03:00:00Z', 'done_by': b_id}, a)))
        caso('no se puede marcar en el futuro',
             rest('POST', 'reminder_logs', {**toma, 'due_at': '2026-10-18T11:00:00Z', 'done_at': '2099-01-01T00:00:00Z'}, a)[0] in (400, 403))
        caso('nadie puede cambiar una toma marcada',
             bloqueado(rest('PATCH', f"reminder_logs?id=eq.{hecha.get('id')}", {'due_at': '2026-10-01T00:00:00Z'}, a)))
        caso('B no puede desmarcar tomas de A',
             bloqueado(rest('DELETE', f"reminder_logs?id=eq.{hecha.get('id')}", quien=b)))
        caso('A puede desmarcar su toma',
             len(filas(rest('DELETE', f"reminder_logs?id=eq.{hecha.get('id')}", quien=a))) == 1)

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

        print('chat (conversaciones y mensajes)')
        s_ch, conv = rest('POST', 'rpc/iniciar_chat_sos', {'p_sos': sos_id}, b)
        caso('B abre un chat con quien publicó el SOS', s_ch == 200 and isinstance(conv, str))
        caso('el mismo chat se reusa', rest('POST', 'rpc/iniciar_chat_sos', {'p_sos': sos_id}, b)[1] == conv)
        caso('A no puede abrir un chat con su propio SOS', rest('POST', 'rpc/iniciar_chat_sos', {'p_sos': sos_id}, a)[0] >= 400)
        caso('un visitante no abre chats', rest('POST', 'rpc/iniciar_chat_sos', {'p_sos': sos_id})[0] in (401, 403))
        caso('B escribe', rest('POST', 'messages', {'conversation_id': conv, 'body': 'La vi en la plaza'}, b, 'return=minimal')[0] == 201)
        caso('B no escribe a nombre de A',
             bloqueado(rest('POST', 'messages', {'conversation_id': conv, 'body': 'X', 'sender_id': a_id}, b, 'return=minimal')))
        lista_a = filas(rest('POST', 'rpc/mis_conversaciones', {}, a))
        caso('A ve el chat con un mensaje sin leer y el nombre de B',
             len(lista_a) == 1 and lista_a[0]['sin_leer'] == 1 and lista_a[0]['otro_nombre'] == 'Prueba b'
             and lista_a[0]['soy_autor'] is True)
        lista_b = filas(rest('POST', 'rpc/mis_conversaciones', {}, b))
        caso('B no ve el nombre de cuenta de A (ve la mascota)',
             len(lista_b) == 1 and lista_b[0]['otro_nombre'] is None and lista_b[0]['sos_nombre'] == 'Firulais')
        caso('A responde', rest('POST', 'messages', {'conversation_id': conv, 'body': 'Gracias!'}, a, 'return=minimal')[0] == 201)
        caso('un visitante no ve mensajes', bloqueado(rest('GET', 'messages?select=id')))
        caso('nadie edita ni borra mensajes',
             bloqueado(rest('PATCH', f'messages?conversation_id=eq.{conv}', {'body': 'X'}, a))
             and bloqueado(rest('DELETE', f'messages?conversation_id=eq.{conv}', quien=a)))
        caso('nadie se agrega a una conversación',
             bloqueado(rest('POST', 'conversation_members', {'conversation_id': conv, 'user_id': a_id}, a)))
        caso('A marca leído', len(filas(rest('PATCH', f'conversation_members?conversation_id=eq.{conv}&user_id=eq.{a_id}',
                                             {'last_read_at': '2099-01-01T00:00:00Z'}, a))) == 1)
        caso('A no puede tocar la fila de B',
             bloqueado(rest('PATCH', f'conversation_members?conversation_id=eq.{conv}&user_id=eq.{b_id}', {'blocked': True}, a)))
        rest('PATCH', f'conversation_members?conversation_id=eq.{conv}&user_id=eq.{a_id}', {'blocked': True}, a)
        caso('con el chat bloqueado, B ya no puede escribir',
             bloqueado(rest('POST', 'messages', {'conversation_id': conv, 'body': 'Hola?'}, b, 'return=minimal')))
        caso('A puede reportar un mensaje',
             rest('POST', 'flags', {'target_type': 'message', 'target_id': conv}, a, 'return=minimal')[0] == 201)
        caso('A sube una foto al chat en su carpeta',
             subir(f'chat-photos/{a_id}/{conv}/f.jpg', JPEG_MINIMO, 'image/jpeg', a) == 200)
        caso('B no sube fotos a nombre de A',
             subir(f'chat-photos/{a_id}/{conv}/g.jpg', JPEG_MINIMO, 'image/jpeg', b) != 200)
        caso('las fotos del chat no son públicas',
             pedir('GET', f'{URL}/storage/v1/object/public/chat-photos/{a_id}/{conv}/f.jpg')[0] >= 400)
        pedir('DELETE', f'{URL}/storage/v1/object/chat-photos', {'prefixes': [f'{a_id}/{conv}/f.jpg']}, ADMIN)

        print('sos_follows (seguir un SOS)')
        caso('quien abre un chat desde el SOS lo sigue solo',
             len(filas(rest('GET', f'sos_follows?select=sos_id&sos_id=eq.{sos_id}', quien=b))) == 1)
        caso('A no ve quién sigue su SOS', filas(rest('GET', 'sos_follows?select=user_id', quien=a)) == [])
        caso('A no puede seguir su propio SOS', rest('POST', 'rpc/seguir_sos', {'p_sos': sos_id}, a)[0] >= 400)
        caso('nadie inserta seguimientos a mano',
             bloqueado(rest('POST', 'sos_follows', {'sos_id': sos_id, 'user_id': b_id}, b)))
        caso('B deja de seguir y vuelve a seguir',
             rest('POST', 'rpc/seguir_sos', {'p_sos': sos_id, 'p_seguir': False}, b)[1] is False
             and filas(rest('GET', 'sos_follows?select=sos_id', quien=b)) == []
             and rest('POST', 'rpc/seguir_sos', {'p_sos': sos_id}, b)[1] is True)
        caso('solo el servidor avisa a los seguidores',
             rest('POST', 'rpc/avisar_seguidores_sos', {'p_sos': sos_id, 'p_autor': a_id}, a)[0] in (401, 403, 404))
        caso('mientras está activo, no se avisa a nadie',
             filas(pedir('POST', f'{URL}/rest/v1/rpc/avisar_seguidores_sos', {'p_sos': sos_id, 'p_autor': a_id}, ADMIN)) == [])
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
        def en_comunidad():
            return [n for n in filas(rest('POST', 'rpc/novedades_comunidad', {})) if n['origin_id'] == sos_id]
        perdida = [n for n in en_comunidad() if n['kind'] == 'perdida']
        caso('perdida activa: aparece en Comunidad sin ubicación ni datos del dueño (D87)',
             len(perdida) == 1 and not ({'lat', 'lng', 'location', 'user_id', 'phone'} & set(perdida[0])))
        caso('a una perdida no se le reacciona',
             rest('POST', 'rpc/reaccionar', {'p_id': sos_id, 'p_tipo': 'alegra'}, b)[0] >= 400)
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
            caso('oculto: tampoco aparece en Comunidad', en_comunidad() == [])
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

            print('novedades de la comunidad: reencuentros (D86)')
            def reencuentros():
                return [n for n in filas(rest('POST', 'rpc/novedades_comunidad', {}))
                        if n['kind'] == 'reencuentro' and n['name'] == 'Firulais']
            antes = len(reencuentros())
            caso('sin el consentimiento del dueño no se publica',
                 rest('POST', 'rpc/reencuentro_compartido', {'p_sos': sos_id}, a)[1] is False)
            caso('B no puede compartir el reencuentro de A',
                 rest('POST', 'rpc/compartir_reencuentro', {'p_sos': sos_id}, b)[0] >= 400)
            caso('nadie lee ni escribe la tabla directo',
                 bloqueado(rest('GET', 'community_updates?select=*', quien=a))
                 and bloqueado(rest('POST', 'community_updates', {'kind': 'reencuentro', 'sos_id': sos_id}, a)))
            caso('A comparte su reencuentro',
                 rest('POST', 'rpc/compartir_reencuentro', {'p_sos': sos_id}, a)[0] in (200, 204)
                 and rest('POST', 'rpc/reencuentro_compartido', {'p_sos': sos_id}, a)[1] is True)
            visibles = reencuentros()
            caso('un visitante lo ve, sin ubicación ni datos del dueño',
                 len(visibles) == antes + 1
                 and set(visibles[0]) == {'id', 'kind', 'origin_id', 'name', 'detail', 'species_id', 'amount',
                                          'starts_at', 'photo_path', 'created_at'})
            nov_r = visibles[0]['id']
            caso('un visitante no reacciona',
                 rest('POST', 'rpc/reaccionar', {'p_id': nov_r, 'p_tipo': 'alegra'})[0] >= 400)
            caso('B reacciona al reencuentro de A (D87)',
                 rest('POST', 'rpc/reaccionar', {'p_id': nov_r, 'p_tipo': 'alegra'}, b)[0] in (200, 204))
            caso('A ve cuántos reaccionaron', rest('POST', 'rpc/reacciones_de_mi_reencuentro', {'p_sos': sos_id}, a)[1] == 1)
            caso('B no ve el total del de A', rest('POST', 'rpc/reacciones_de_mi_reencuentro', {'p_sos': sos_id}, b)[1] == 0)
            caso('B no ve el estado del de A', rest('POST', 'rpc/reencuentro_compartido', {'p_sos': sos_id}, b)[1] is False)
            rest('POST', 'rpc/quitar_reencuentro', {'p_sos': sos_id}, b)
            caso('B no puede quitarlo', len(reencuentros()) == antes + 1)
            rest('POST', 'rpc/quitar_reencuentro', {'p_sos': sos_id}, a)
            caso('A lo quita cuando quiere', len(reencuentros()) == antes)
            aviso_seg = filas(pedir('POST', f'{URL}/rest/v1/rpc/avisar_seguidores_sos', {'p_sos': sos_id, 'p_autor': a_id}, ADMIN))
            caso('resuelto: se avisa a los seguidores con el nombre de la mascota',
                 len(aviso_seg) == 1 and aviso_seg[0]['nombre'] == 'Firulais')
            caso('cada seguidor recibe el aviso una sola vez',
                 filas(pedir('POST', f'{URL}/rest/v1/rpc/avisar_seguidores_sos', {'p_sos': sos_id, 'p_autor': a_id}, ADMIN))[0]['tokens'] == [])
            caso('con otro autor no avisa nada',
                 filas(pedir('POST', f'{URL}/rest/v1/rpc/avisar_seguidores_sos', {'p_sos': sos_id, 'p_autor': b_id}, ADMIN)) == [])
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
        print('lugares (mapa integral) y user_places')
        lugares = filas(rest('POST', 'rpc/lugares_en_zona', pando_rect))
        caso('el mapa integral trae varios rubros, solo con local',
             len({l['business_type'] for l in lugares}) >= 2 and all(l['kind'] == 'local' for l in lugares))
        solo_vets = filas(rest('POST', 'rpc/lugares_en_zona', {**pando_rect, 'p_tipos': ['vet']}))
        caso('se puede pedir un rubro', solo_vets and all(l['business_type'] == 'vet' for l in solo_vets))
        sin_local = filas(rest('POST', 'rpc/lugares_sin_local', {}))
        caso('"Sin local" trae los online y a domicilio', sin_local and all(l['kind'] != 'local' for l in sin_local))
        caso('un local sin ubicación se rechaza',
             pedir('POST', f'{URL}/rest/v1/businesses', {'name': 'Sin punto', 'kind': 'local', 'is_sample': True},
                   {**ADMIN, 'Prefer': 'return=minimal'})[0] >= 400)
        caso('un rubro inventado se rechaza',
             pedir('POST', f'{URL}/rest/v1/businesses', {'name': 'Rubro raro', 'kind': 'online', 'business_type': 'casino',
                                                         'is_sample': True}, {**ADMIN, 'Prefer': 'return=minimal'})[0] >= 400)
        caso('un feriado mal escrito se rechaza',
             pedir('POST', f'{URL}/rest/v1/businesses', {'name': 'Feriado raro', 'kind': 'online', 'special_days': {'navidad': []},
                                                         'is_sample': True}, {**ADMIN, 'Prefer': 'return=minimal'})[0] >= 400)
        vet = next((l for l in lugares if l['business_type'] == 'vet'), None)
        otro_rubro = next((l for l in lugares if l['business_type'] != 'vet'), None)
        if vet:
            caso('A marca favorita una veterinaria',
                 rest('POST', 'user_places', {'business_id': vet['id'], 'favorite': True}, a, 'return=minimal')[0] == 201)
            caso('B no ve los favoritos de A', filas(rest('GET', 'user_places?select=business_id', quien=b)) == [])
            caso('un visitante no ve user_places', bloqueado(rest('GET', 'user_places?select=business_id')))
            caso('A no marca a nombre de B',
                 bloqueado(rest('POST', 'user_places', {'business_id': vet['id'], 'user_id': b_id, 'favorite': True}, a, 'return=minimal')))
            caso('A la marca como su veterinaria',
                 len(filas(rest('PATCH', f"user_places?business_id=eq.{vet['id']}", {'is_my_vet': True}, a))) == 1)
            otra_vet = next((l for l in lugares if l['business_type'] == 'vet' and l['id'] != vet['id']), None)
            if otra_vet:
                rest('POST', 'user_places', {'business_id': otra_vet['id'], 'is_my_vet': True}, a, 'return=minimal')
                mias = [x for x in filas(rest('GET', 'user_places?select=business_id,is_my_vet', quien=a)) if x['is_my_vet']]
                caso('solo una "mi veterinaria" por persona', [x['business_id'] for x in mias] == [otra_vet['id']])
        if otro_rubro:
            caso('"mi veterinaria" solo en veterinarias',
                 rest('POST', 'user_places', {'business_id': otro_rubro['id'], 'is_my_vet': True}, a, 'return=minimal')[0] >= 400)

        caso('no se aceptan métricas de un comercio que no existe',
             rest('POST', 'events', {'name': 'prueba_rls', 'anon_id': str(uuid.uuid4()), 'business_id': str(uuid.uuid4())},
                  prefer='return=minimal')[0] >= 400)
        caso('la base rechaza horarios mal escritos',
             pedir('POST', f'{URL}/rest/v1/businesses', {'name': 'Prueba RLS horario', 'location': 'SRID=4326;POINT(-55.958 -34.717)',
                                                       'hours': {'lunes': [['9', '13']]}}, ADMIN)[0] >= 400)

        print('help_directory (pestaña Ayuda)')
        caso('un visitante lee el directorio de Ayuda', isinstance(filas(rest('GET', 'help_directory?select=id,kind,name')), list)
             and rest('GET', 'help_directory?select=id')[0] == 200)
        caso('A no puede cargar entradas', bloqueado(rest('POST', 'help_directory', {'kind': 'grupo', 'name': 'Falso', 'link': 'https://x.com'}, a)))
        caso('un visitante tampoco', bloqueado(rest('POST', 'help_directory', {'kind': 'grupo', 'name': 'Falso', 'link': 'https://x.com'})))
        s_h, oculta_h = pedir('POST', f'{URL}/rest/v1/help_directory', {
            'kind': 'refugio', 'name': 'Prueba RLS ayuda oculta', 'phone': '099000099', 'status': 'hidden', 'is_sample': True},
            {**ADMIN, 'Prefer': 'return=representation'})
        try:
            id_h = oculta_h[0]['id'] if s_h == 201 else ''
            caso('una entrada oculta no se ve', s_h == 201
                 and filas(rest('GET', f'help_directory?select=id&id=eq.{id_h}')) == []
                 and filas(rest('GET', f'help_directory?select=id&id=eq.{id_h}', quien=a)) == [])
            caso('A no puede mostrarla ni borrarla',
                 bloqueado(rest('PATCH', f'help_directory?id=eq.{id_h}', {'status': 'active'}, a))
                 and bloqueado(rest('DELETE', f'help_directory?id=eq.{id_h}', quien=a)))
        finally:
            pedir('DELETE', f'{URL}/rest/v1/help_directory?name=eq.Prueba%20RLS%20ayuda%20oculta', headers=ADMIN)
        caso('la base rechaza enlaces que no son https',
             pedir('POST', f'{URL}/rest/v1/help_directory', {'kind': 'grupo', 'name': 'Prueba RLS http', 'link': 'http://x.com'}, ADMIN)[0] >= 400)

        print('feature_flags (habilitación gradual, D64)')
        caso('un visitante no puede leer las marcas', bloqueado(rest('GET', 'feature_flags?select=key')))
        caso('A no puede leer las marcas', bloqueado(rest('GET', 'feature_flags?select=key', quien=a)))
        caso('A no puede crear marcas', bloqueado(rest('POST', 'feature_flags', {'key': 'prueba_rls_x', 'description': 'x', 'stage': 'todos'}, a)))
        caso('A no puede cambiar marcas', bloqueado(rest('PATCH', 'feature_flags?key=eq.temas_pro', {'stage': 'todos'}, a)))
        caso('A no puede invitarse a una beta',
             bloqueado(rest('POST', 'feature_flag_users', {'flag_key': 'temas_pro', 'user_id': a_id}, a)))
        caso('A no puede leer las invitaciones', bloqueado(rest('GET', 'feature_flag_users?select=user_id', quien=a)))
        caso('A no puede leer el historial', bloqueado(rest('GET', 'feature_flag_audit?select=id', quien=a)))

        def activa(clave, quien=None, **params):
            s, d = rest('POST', 'rpc/funcionalidad_activa', {'p_key': clave, **params}, quien)
            assert s == 200, (s, d)
            return d is True

        def mis(quien=None, **params):
            s, d = rest('POST', 'rpc/mis_funcionalidades', params, quien)
            assert s == 200, (s, d)
            return d or []

        def marca(clave, **campos):
            s, d = pedir('PATCH', f'{URL}/rest/v1/feature_flags?key=eq.{clave}', campos, {**ADMIN, 'Prefer': 'return=minimal'})
            assert s in (200, 204), (s, d)

        def perfil(uid, **campos):
            pedir('PATCH', f'{URL}/rest/v1/profiles?id=eq.{uid}', campos, {**ADMIN, 'Prefer': 'return=minimal'})

        caso('temas_pro existe y A (no invitada) no la tiene', not activa('temas_pro', a))
        caso('una clave que no existe está apagada', not activa('no_existe_xyz', a))

        clave = f'prueba_rls_{uuid.uuid4().hex[:8]}'
        s, _ = pedir('POST', f'{URL}/rest/v1/feature_flags', {'key': clave, 'description': 'Prueba RLS'},
                     {**ADMIN, 'Prefer': 'return=minimal'})
        caso('con la clave secreta se crea una marca (en borrador)', s == 201)
        pedir('POST', f'{URL}/rest/v1/feature_flag_users', {'flag_key': clave, 'user_id': a_id},
              {**ADMIN, 'Prefer': 'return=minimal'})
        caso('borrador: ni invitada le llega', not activa(clave, a) and clave not in mis(a))

        marca(clave, stage='interna')
        caso('interna: le llega a la invitada', activa(clave, a))
        caso('interna: no le llega a un usuario común', not activa(clave, b))
        perfil(b_id, role='admin')
        caso('interna: le llega a un administrador', activa(clave, b))
        perfil(b_id, role='user')

        marca(clave, stage='beta')
        caso('beta: le llega a la invitada (y aparece en mis_funcionalidades)', activa(clave, a) and clave in mis(a))
        caso('beta: no le llega a quien no está invitado', not activa(clave, b) and clave not in mis(b))
        caso('beta: no le llega a un visitante', not activa(clave, p_anon_id=str(uuid.uuid4())))

        marca(clave, stage='todos')
        caso('todos: le llega a cualquier cuenta', activa(clave, b))
        caso('todos: no le llega a un visitante si no se permite', not activa(clave, p_anon_id=str(uuid.uuid4())))
        marca(clave, allow_anonymous=True)
        caso('todos: le llega a un visitante si se permite', activa(clave, p_anon_id=str(uuid.uuid4())))

        marca(clave, killed=True)
        caso('apagado de emergencia: no le llega a nadie',
             not activa(clave, a) and not activa(clave, b) and clave not in mis(a))
        perfil(b_id, role='admin')
        caso('apagado de emergencia: ni a un administrador', not activa(clave, b))
        perfil(b_id, role='user')
        marca(clave, killed=False, starts_at='2099-01-01T00:00:00Z')
        caso('antes de la fecha de inicio está apagada', not activa(clave, b))
        marca(clave, starts_at=None, ends_at='2020-01-01T00:00:00Z')
        caso('después de la fecha de fin está apagada', not activa(clave, b))
        marca(clave, ends_at=None)
        caso('la base rechaza un fin anterior al inicio',
             pedir('PATCH', f'{URL}/rest/v1/feature_flags?key=eq.{clave}',
                   {'starts_at': '2030-01-01T00:00:00Z', 'ends_at': '2029-01-01T00:00:00Z'}, ADMIN)[0] >= 400)
        caso('la base rechaza planes inventados',
             pedir('PATCH', f'{URL}/rest/v1/feature_flags?key=eq.{clave}', {'plans': ['oro']}, ADMIN)[0] >= 400)

        pedir('PATCH', f'{URL}/rest/v1/feature_flag_users?flag_key=eq.{clave}&user_id=eq.{a_id}', {'enabled': False},
              {**ADMIN, 'Prefer': 'return=minimal'})
        caso('una persona excluida no la ve aunque esté en todos', not activa(clave, a) and activa(clave, b))

        pando = filas(rest('GET', 'zones?select=id&slug=eq.pando'))[0]['id']
        marca(clave, stage='gradual', rollout_percent=100, allow_anonymous=False)
        caso('gradual al 100 %: le llega a B', activa(clave, b))
        marca(clave, zone_ids=[pando])
        caso('gradual por zona: le llega a B (Pando)', activa(clave, b))
        marca(clave, zone_ids=[32000])
        caso('gradual por zona: no le llega fuera de la zona', not activa(clave, b))
        marca(clave, zone_ids=None, plans=['pro'])
        caso('gradual por plan: no le llega a B (gratis)', not activa(clave, b))
        perfil(b_id, plan='pro')
        caso('gradual por plan: le llega a B con Pro', activa(clave, b))
        perfil(b_id, plan='free')
        marca(clave, plans=None, roles=['admin'])
        caso('gradual por rol: no le llega a un usuario común', not activa(clave, b))
        marca(clave, roles=None, platforms=['android'])
        caso('gradual por plataforma: sí en Android, no en la web ni sin decir',
             activa(clave, b, p_plataforma='android') and not activa(clave, b, p_plataforma='web') and not activa(clave, b))
        marca(clave, platforms=None, min_app_version='1.10.0')
        caso('versión mínima 1.10.0: 1.10.0 y 1.10.1 sí; 1.9.5, basura y sin versión no',
             activa(clave, b, p_version='1.10.0') and activa(clave, b, p_version='1.10.1')
             and not activa(clave, b, p_version='1.9.5') and not activa(clave, b, p_version='x; drop')
             and not activa(clave, b))
        marca(clave, min_app_version=None)

        def cubeta(id_):
            return int(hashlib.md5(f'{clave}:{id_}'.encode()).hexdigest()[:8], 16) % 100

        anons = [str(uuid.uuid4()) for _ in range(25)]
        marca(clave, allow_anonymous=True, rollout_percent=30)
        con30 = {x for x in anons if activa(clave, p_anon_id=x)}
        caso('porcentaje: la base calcula igual que la fórmula (MD5)', con30 == {x for x in anons if cubeta(x) < 30})
        caso('porcentaje: la misma persona cae siempre del mismo lado',
             con30 == {x for x in anons if activa(clave, p_anon_id=x)})
        marca(clave, rollout_percent=10)
        con10 = {x for x in anons if activa(clave, p_anon_id=x)}
        caso('porcentaje: al subir de 10 % a 30 % nadie pierde la funcionalidad', con10 <= con30)
        caso('porcentaje: con cuenta se usa el id de la cuenta',
             activa(clave, b, p_anon_id=anons[0]) == (cubeta(b_id) < 10))
        marca(clave, rollout_percent=0)
        caso('porcentaje 0: no le llega a nadie (salvo invitadas)', not any(activa(clave, p_anon_id=x) for x in anons[:5]))

        historial = filas(pedir('GET', f'{URL}/rest/v1/feature_flag_audit?select=tabla&flag_key=eq.{clave}', headers=ADMIN))
        caso('el historial registra cada cambio (marca e invitaciones)',
             len(historial) >= 20 and {h['tabla'] for h in historial} == {'feature_flags', 'feature_flag_users'})

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
        print('households (hogar compartido)')
        c_id, c = crear_usuario('c')
        try:
            def rpc(nombre, cuerpo, quien):
                return pedir('POST', f'{URL}/rest/v1/rpc/{nombre}', cuerpo, quien)
            pet_id = pet.get('id')
            caso('antes de unirse, B no ve la mascota de A', filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=b)) == [])
            s_inv, codigo = rpc('invitar_al_hogar', {}, a)
            caso('A puede invitar (se crea su hogar)', s_inv == 200 and isinstance(codigo, str) and len(codigo) == 10)
            caso('A ve su invitación', len(filas(rest('GET', 'household_invites?select=code', quien=a))) == 1)
            caso('B no ve las invitaciones de A', filas(rest('GET', 'household_invites?select=code', quien=b)) == [])
            caso('nadie crea integrantes a mano',
                 bloqueado(rest('POST', 'household_members', {'household_id': str(uuid.uuid4()), 'user_id': b_id}, b)))
            caso('A no se puede unir a su propio hogar', rpc('unirme_al_hogar', {'p_codigo': codigo}, a)[0] >= 400)
            s_union, hogar = rpc('unirme_al_hogar', {'p_codigo': codigo.lower()}, b)
            caso('B se une con el código', s_union == 200 and isinstance(hogar, str))
            caso('el mismo código no sirve dos veces', rpc('unirme_al_hogar', {'p_codigo': codigo}, c)[0] >= 400)
            caso('un código inventado no sirve', rpc('unirme_al_hogar', {'p_codigo': 'ABCDEFGHJK'}, c)[0] >= 400)
            integrantes = filas(rpc('integrantes_de_mis_hogares', {}, b))
            caso('B ve a los integrantes con su nombre, sin correo',
                 {i['user_id'] for i in integrantes} == {a_id, b_id}
                 and all('email' not in i for i in integrantes)
                 and any(i['es_dueno'] and i['user_id'] == a_id for i in integrantes))
            caso('C (de afuera) no ve el hogar', filas(rest('GET', 'households?select=id', quien=c)) == [])
            caso('B ve la mascota de A', len(filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=b))) == 1)
            caso('C sigue sin ver la mascota de A', filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=c)) == [])
            caso('B puede editar la ficha', len(filas(rest('PATCH', f'pets?id=eq.{pet_id}', {'color': 'Blanco'}, b))) == 1)
            caso('B no puede quedarse con la mascota',
                 rest('PATCH', f'pets?id=eq.{pet_id}', {'owner_id': b_id}, b)[0] in (400, 401, 403))
            caso('B no puede borrar la mascota', bloqueado(rest('DELETE', f'pets?id=eq.{pet_id}', quien=b))
                 and len(filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=a))) == 1)
            caso('B ve el QR de la mascota', len(filas(rest('GET', f'qr_tags?select=code&pet_id=eq.{pet_id}&active=eq.true', quien=b))) == 1)
            caso('B no puede cambiar el QR', bloqueado(rest('PATCH', f'qr_tags?pet_id=eq.{pet_id}', {'public_note': 'X'}, b)))
            caso('B carga en la libreta',
                 rest('POST', 'health_records', {'pet_id': pet_id, 'kind': 'checkup', 'name': 'Control'}, b)[0] == 201)
            caso('A ve lo que cargó B', len(filas(rest('GET', f'health_records?select=id&pet_id=eq.{pet_id}&name=eq.Control', quien=a))) == 1)
            caso('B ve los recordatorios', len(filas(rest('GET', f'reminders?select=id&id=eq.{rec.get("id")}', quien=b))) == 1)
            toma_b = rest('POST', 'reminder_logs', {'reminder_id': rec.get('id'), 'due_at': '2026-10-19T11:00:00Z'}, b)
            caso('B marca "ya se la di" a su nombre', toma_b[0] == 201 and filas(toma_b)[0]['done_by'] == b_id)
            caso('A ve la toma que marcó B (no hay dosis doble)',
                 rest('POST', 'reminder_logs', {'reminder_id': rec.get('id'), 'due_at': '2026-10-19T11:00:00Z'}, a)[0] == 409)
            caso('C no ve las tomas', filas(rest('GET', 'reminder_logs?select=id', quien=c)) == [])
            tokens = pedir('POST', f'{URL}/rest/v1/rpc/tokens_de_cuidadores', {'p_owner': a_id}, ADMIN)
            caso('los push del dueño también van al hogar (solo el servidor lo consulta)',
                 tokens[0] == 200 and rpc('tokens_de_cuidadores', {'p_owner': a_id}, b)[0] in (401, 403, 404))
            print('household_tasks (tareas del hogar)')
            r_t = rest('POST', 'household_tasks', {'pet_id': pet_id, 'kind': 'walk', 'day': '2026-10-18',
                                                   'assigned_to': b_id, 'created_by': a_id}, a)
            tarea = filas(r_t)[0] if filas(r_t) else {}
            caso('A crea una tarea y se la asigna a B', tarea.get('assigned_to') == b_id)
            caso('B ve la tarea', len(filas(rest('GET', f"household_tasks?select=id&id=eq.{tarea.get('id')}", quien=b))) == 1)
            caso('C (de afuera) no ve tareas', filas(rest('GET', 'household_tasks?select=id', quien=c)) == [])
            caso('no se le asigna a alguien de afuera',
                 bloqueado(rest('PATCH', f"household_tasks?id=eq.{tarea.get('id')}", {'assigned_to': c_id}, a)))
            hecha = filas(rest('PATCH', f"household_tasks?id=eq.{tarea.get('id')}", {'done_by': b_id}, b))
            caso('B la marca hecha a su nombre, con la hora del servidor',
                 bool(hecha) and hecha[0]['done_by'] == b_id and hecha[0]['done_at'] is not None)
            caso('A no puede ponerla a nombre de B',
                 rest('POST', 'household_tasks', {'pet_id': pet_id, 'kind': 'food', 'day': '2026-10-18',
                                                   'created_by': a_id, 'done_by': b_id}, a)[0] in (400, 401, 403))
            caso('C no puede crear tareas para la mascota de A',
                 bloqueado(rest('POST', 'household_tasks', {'pet_id': pet_id, 'kind': 'walk', 'day': '2026-10-18',
                                                            'created_by': c_id}, c)))
            caso('un tipo inventado se rechaza',
                 rest('POST', 'household_tasks', {'pet_id': pet_id, 'kind': 'magia', 'day': '2026-10-18',
                                                   'created_by': a_id}, a)[0] == 400)
            caso('B no puede crear una tarea a nombre de otro',
                 bloqueado(rest('POST', 'household_tasks', {'pet_id': pet_id, 'kind': 'walk', 'day': '2026-10-18',
                                                            'created_by': a_id}, b)))

            caso('B no puede sacar a A ni renombrar el hogar',
                 bloqueado(rest('PATCH', f'households?id=eq.{hogar}', {'name': 'X'}, b)))
            caso('B se puede ir', len(filas(rest('DELETE', f'household_members?user_id=eq.{b_id}', quien=b))) == 1)
            caso('al irse, B deja de ver la mascota', filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=b)) == [])
            s2, codigo2 = rpc('invitar_al_hogar', {}, a)
            rpc('unirme_al_hogar', {'p_codigo': codigo2}, c)
            caso('A puede sacar a un integrante',
                 len(filas(rest('DELETE', f'household_members?user_id=eq.{c_id}', quien=a))) == 1
                 and filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=c)) == [])
            s3, codigo3 = rpc('invitar_al_hogar', {'p_rol': 'jefe'}, a)
            caso('un rol inventado se rechaza', s3 >= 400)

            print('household_member_pets (cuidador temporal)')
            otra = filas(rest('POST', 'pets', {'name': 'Otra', 'species_id': 1}, a))[0]
            caso('un cuidador temporal necesita mascotas',
                 rpc('invitar_al_hogar', {'p_rol': 'temp_caregiver', 'p_dias': 3}, a)[0] >= 400)
            mascota_b = filas(rest('POST', 'pets', {'name': 'DeB', 'species_id': 1}, b))[0]
            caso('no se comparte una mascota ajena',
                 rpc('invitar_al_hogar', {'p_rol': 'temp_caregiver', 'p_dias': 3, 'p_mascotas': [mascota_b['id']]}, a)[0] >= 400)
            pedir('DELETE', f"{URL}/rest/v1/qr_tags?owner_id=eq.{b_id}", headers=ADMIN)
            rest('DELETE', f"pets?id=eq.{mascota_b['id']}", quien=b)
            s_c, codigo_c = rpc('invitar_al_hogar', {'p_rol': 'temp_caregiver', 'p_dias': 3, 'p_mascotas': [pet_id]}, a)
            caso('A invita a C como cuidador de una sola mascota', s_c == 200)
            rpc('unirme_al_hogar', {'p_codigo': codigo_c}, c)
            caso('C ve la mascota que cuida', len(filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=c))) == 1)
            caso('C no ve la otra mascota de A', filas(rest('GET', f"pets?select=id&id=eq.{otra['id']}", quien=c)) == [])
            caso('C ve la libreta de la que cuida',
                 len(filas(rest('GET', f'health_records?select=id&pet_id=eq.{pet_id}', quien=c))) >= 1)
            caso('C no puede borrar la mascota', bloqueado(rest('DELETE', f'pets?id=eq.{pet_id}', quien=c)))
            integ = filas(rpc('integrantes_de_mis_hogares', {}, a))
            caso('A ve a C como cuidador con fecha de fin',
                 any(i['user_id'] == c_id and i['role'] == 'temp_caregiver' and i['access_until'] for i in integ))
            tokens2 = pedir('POST', f'{URL}/rest/v1/rpc/tokens_de_cuidadores', {'p_owner': a_id, 'p_pet': pet_id}, ADMIN)
            caso('las push de esa mascota también le llegan al cuidador (consulta del servidor)', tokens2[0] == 200)
            pedir('PATCH', f'{URL}/rest/v1/household_members?user_id=eq.{c_id}',
                  {'access_until': '2020-01-01T00:00:00Z'}, ADMIN)
            caso('al vencer, C deja de ver la mascota', filas(rest('GET', f'pets?select=id&id=eq.{pet_id}', quien=c)) == [])
            pedir('DELETE', f"{URL}/rest/v1/qr_tags?pet_id=eq.{otra['id']}", headers=ADMIN)
            rest('DELETE', f"pets?id=eq.{otra['id']}", quien=a)
        finally:
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{c_id}', headers=ADMIN)

        print('portal de administración')
        x_id, x = crear_usuario('admin')
        try:
            pedir('PATCH', f'{URL}/rest/v1/profiles?id=eq.{x_id}', {'role': 'admin'}, ADMIN)
            caso('A no es admin', rest('POST', 'rpc/es_admin', {}, a)[1] is False)
            caso('X es admin (el rol lo pone solo el servidor)', rest('POST', 'rpc/es_admin', {}, x)[1] is True)
            caso('A no ve el panel', rest('POST', 'rpc/admin_panel', {}, a)[0] >= 400)
            caso('un visitante no ve el panel', rest('POST', 'rpc/admin_panel', {})[0] >= 400)
            s_p, panel = rest('POST', 'rpc/admin_panel', {'p_dias': 30}, x)
            caso('X ve el panel con los indicadores', s_p == 200 and {'usuarios', 'sos_activos', 'comercios_por_rubro'} <= set(panel))
            caso('A no ve la cola de moderación', rest('POST', 'rpc/admin_moderacion', {}, a)[0] >= 400)
            caso('X ve la cola de moderación', rest('POST', 'rpc/admin_moderacion', {}, x)[0] == 200)
            caso('A no puede moderar', rest('POST', 'rpc/admin_moderar', {'p_tipo': 'sos', 'p_id': str(uuid.uuid4()), 'p_accion': 'eliminar'}, a)[0] >= 400)
            caso('una acción inventada se rechaza',
                 rest('POST', 'rpc/admin_moderar', {'p_tipo': 'sos', 'p_id': str(uuid.uuid4()), 'p_accion': 'borrar_todo'}, x)[0] >= 400)
            caso('A no puede sancionar', rest('POST', 'rpc/admin_sancionar', {'p_user': b_id, 'p_tipo': 'block'}, a)[0] >= 400)
            s_s, sancion = rest('POST', 'rpc/admin_sancionar', {'p_user': b_id, 'p_tipo': 'block', 'p_motivo': 'prueba', 'p_dias': 1}, x)
            caso('X bloquea a B', s_s == 200 and rest('POST', 'rpc/esta_bloqueado', {'p_user': b_id}, a)[1] is True)
            # A desbloquea el chat de las pruebas de arriba: así solo frena la sanción.
            rest('PATCH', f'conversation_members?conversation_id=eq.{conv}&user_id=eq.{a_id}', {'blocked': False}, a)
            caso('bloqueado, B no puede escribir mensajes',
                 rest('POST', 'messages', {'conversation_id': conv, 'body': 'hola'}, b, 'return=minimal')[0] >= 400)
            hist = rest('POST', 'rpc/admin_historial_usuario', {'p_user': b_id}, x)[1]
            caso('X ve el historial de B', isinstance(hist, dict) and hist.get('bloqueado') is True and len(hist.get('sanciones', [])) == 1)
            rest('POST', 'rpc/admin_levantar_sancion', {'p_sancion': sancion}, x)
            caso('al levantar la sanción, B deja de estar bloqueado', rest('POST', 'rpc/esta_bloqueado', {'p_user': b_id}, a)[1] is False)
            caso('y vuelve a poder escribir',
                 rest('POST', 'messages', {'conversation_id': conv, 'body': 'hola de nuevo'}, b, 'return=minimal')[0] == 201)
            caso('nadie lee las sanciones ni el registro de acciones directo',
                 bloqueado(rest('GET', 'user_sanctions?select=id', quien=x)) and bloqueado(rest('GET', 'admin_actions?select=id', quien=x)))
            caso('A no ve la lista de lugares de administración', rest('POST', 'rpc/admin_lugares', {}, a)[0] >= 400)
            caso('X ve todos los lugares', len(filas(rest('POST', 'rpc/admin_lugares', {}, x))) >= 1)
            s_l, lugar = rest('POST', 'rpc/admin_guardar_lugar', {'p': {
                'name': 'Prueba RLS admin', 'business_type': 'grooming', 'kind': 'local',
                'lat': -34.71, 'lng': -55.95, 'hours': {'mon': [['09:00', '18:00']]}}}, x)
            caso('X carga un lugar', s_l == 200 and isinstance(lugar, str))
            caso('X lo verifica y le pone Operador RENAC',
                 rest('POST', 'rpc/admin_guardar_lugar', {'p': {'id': lugar, 'verification': 'verified', 'renac_operator': True}}, x)[0] == 200
                 and any(l['id'] == lugar and l['verification'] == 'verified' and l['renac_operator']
                         for l in filas(rest('POST', 'rpc/admin_lugares', {'p_buscar': 'Prueba RLS admin'}, x))))
            caso('un horario inválido se rechaza',
                 rest('POST', 'rpc/admin_guardar_lugar', {'p': {'id': lugar, 'hours': {'lunes': 'todo el día'}}}, x)[0] >= 400)
            caso('A no puede cargar lugares', rest('POST', 'rpc/admin_guardar_lugar', {'p': {'name': 'X', 'lat': -34.7, 'lng': -55.9}}, a)[0] >= 400)
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{lugar}', headers=ADMIN)
            caso('A no ve prospectos', bloqueado(rest('GET', 'prospects?select=id', quien=a)))
            caso('X carga un prospecto', rest('POST', 'prospects', {'name': 'Peluquería Prueba RLS', 'stage': 'contacted'}, x, 'return=minimal')[0] == 201)
            caso('A no puede cargar prospectos', bloqueado(rest('POST', 'prospects', {'name': 'X'}, a, 'return=minimal')))
            pedir('DELETE', f'{URL}/rest/v1/prospects?name=eq.Peluquer%C3%ADa%20Prueba%20RLS', headers=ADMIN)
            caso('A no puede cargar en la Ayuda',
                 bloqueado(rest('POST', 'help_directory', {'kind': 'grupo', 'name': 'Prueba RLS', 'status': 'hidden'}, a, 'return=minimal')))
            caso('X carga en la Ayuda (oculto) y lo ve',
                 rest('POST', 'help_directory', {'kind': 'grupo', 'name': 'Prueba RLS ayuda', 'status': 'hidden', 'is_sample': True}, x, 'return=minimal')[0] == 201
                 and len(filas(rest('GET', 'help_directory?select=id&name=eq.Prueba%20RLS%20ayuda', quien=x))) == 1
                 and filas(rest('GET', 'help_directory?select=id&name=eq.Prueba%20RLS%20ayuda', quien=a)) == [])
            pedir('DELETE', f'{URL}/rest/v1/help_directory?name=eq.Prueba%20RLS%20ayuda', headers=ADMIN)

            print('comercios con cuenta (1.3)')
            s_n, negocio = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Peluquería Prueba RLS', 'business_type': 'grooming', 'kind': 'local',
                'lat': -34.7101, 'lng': -55.9501, 'phone': '099111222'}}, a)
            caso('A da de alta su negocio (al instante, sin verificar)', s_n == 200 and isinstance(negocio, str))
            mio = filas(rest('POST', 'rpc/mis_negocios', {}, a))
            caso('A ve su negocio como no verificado', len(mio) == 1 and mio[0]['verification'] == 'unverified')
            caso('el negocio aparece en el mapa con dueño',
                 any(l['id'] == negocio and l['has_owner'] for l in filas(rest('POST', 'rpc/lugares_en_zona', pando_rect))))
            caso('A no puede darse la verificación en el alta',
                 rest('POST', 'rpc/alta_negocio', {'p': {'name': 'X', 'kind': 'online', 'verification': 'verified'}}, a)[0] >= 400)
            caso('A edita su negocio', rest('POST', 'rpc/editar_mi_negocio', {'p_id': negocio, 'p': {'description': 'Baños y cortes'}}, a)[0] in (200, 204))
            caso('A no puede ponerse RENAC ni plan',
                 rest('POST', 'rpc/editar_mi_negocio', {'p_id': negocio, 'p': {'renac_operator': True}}, a)[0] >= 400
                 and rest('POST', 'rpc/editar_mi_negocio', {'p_id': negocio, 'p': {'plan': 'plus'}}, a)[0] >= 400)
            caso('B no puede editar el negocio de A',
                 rest('POST', 'rpc/editar_mi_negocio', {'p_id': negocio, 'p': {'name': 'Hackeado'}}, b)[0] >= 400)
            caso('B no ve el panel del negocio de A', rest('POST', 'rpc/panel_negocio', {'p_id': negocio}, b)[0] >= 400)
            s_pn, panel_n = rest('POST', 'rpc/panel_negocio', {'p_id': negocio}, a)
            caso('A ve su panel', s_pn == 200 and 'aperturas' in panel_n)
            caso('A pide la verificación con su RUT',
                 rest('POST', 'rpc/pedir_verificacion', {'p_id': negocio, 'p_rut': '21 234567 0019'}, a)[0] in (200, 204)
                 and filas(rest('POST', 'rpc/mis_negocios', {}, a))[0]['verification'] == 'pending')
            caso('el RUT no sale en el mapa',
                 all('rut' not in l for l in filas(rest('POST', 'rpc/lugares_en_zona', pando_rect))))
            caso('la insignia RENAC solo la piden veterinarias',
                 rest('POST', 'rpc/pedir_insignia_renac', {'p_id': negocio}, a)[0] >= 400)
            caso('A sube el contacto privado y B no lo ve',
                 rest('POST', 'business_contacts_private', {'business_id': negocio, 'email': 'a@prueba.uy'}, a, 'return=minimal')[0] == 201
                 and filas(rest('GET', 'business_contacts_private?select=email', quien=b)) == [])
            caso('B no puede cargar fotos en el negocio de A',
                 bloqueado(rest('POST', 'business_photos', {'business_id': negocio, 'path': 'x.jpg'}, b, 'return=minimal')))
            caso('A carga hasta 3 fotos con el plan Básico',
                 all(rest('POST', 'business_photos', {'business_id': negocio, 'path': f'{negocio}/{i}.jpg'}, a, 'return=minimal')[0] == 201
                     for i in range(3))
                 and rest('POST', 'business_photos', {'business_id': negocio, 'path': f'{negocio}/4.jpg'}, a, 'return=minimal')[0] >= 400)
            pend = filas(rest('POST', 'rpc/admin_pendientes_comercios', {}, x))
            caso('X ve el pedido de verificación', any(q['tipo'] == 'verification' and q['business_id'] == negocio for q in pend))
            caso('A no ve los pendientes de administración', rest('POST', 'rpc/admin_pendientes_comercios', {}, a)[0] >= 400)
            rest('POST', 'rpc/admin_resolver_comercio', {'p_tipo': 'verification', 'p_id': negocio, 'p_aprobar': True}, x)
            caso('X verifica el negocio', filas(rest('POST', 'rpc/mis_negocios', {}, a))[0]['verification'] == 'verified')
            s_r, reclamo = rest('POST', 'rpc/reclamar_negocio', {'p_business': negocio, 'p_rut': '211111110019', 'p_nota': 'Es mío'}, b)
            caso('B reclama un negocio que ya tiene dueño: se abre una disputa',
                 s_r == 200 and any(q['tipo'] == 'dispute' and q['id'] == reclamo for q in filas(rest('POST', 'rpc/admin_pendientes_comercios', {}, x))))
            rest('POST', 'rpc/admin_resolver_comercio', {'p_tipo': 'dispute', 'p_id': reclamo, 'p_aprobar': False}, x)
            caso('rechazada la disputa, A sigue siendo el dueño', len(filas(rest('POST', 'rpc/mis_negocios', {}, a))) == 1)
            s_l2, sin_duenio = rest('POST', 'rpc/admin_guardar_lugar', {'p': {
                'name': 'Petshop sin dueño RLS', 'business_type': 'petshop', 'kind': 'local', 'lat': -34.712, 'lng': -55.952}}, x)
            s_r2, reclamo2 = rest('POST', 'rpc/reclamar_negocio', {'p_business': sin_duenio, 'p_rut': '211111110019'}, b)
            rest('POST', 'rpc/admin_resolver_comercio', {'p_tipo': 'claim', 'p_id': reclamo2, 'p_aprobar': True}, x)
            caso('aprobado el reclamo, B pasa a ser el dueño y queda verificado',
                 any(n['id'] == sin_duenio and n['verification'] == 'verified' for n in filas(rest('POST', 'rpc/mis_negocios', {}, b))))
            caso('A no puede nombrar Socios Fundadores', rest('POST', 'rpc/admin_socio_fundador', {'p_business': sin_duenio, 'p_hasta': '2027-06-30'}, a)[0] >= 400)
            rest('POST', 'rpc/admin_socio_fundador', {'p_business': sin_duenio, 'p_hasta': '2027-06-30'}, x)
            caso('X lo nombra Socio Fundador (plan Destacado)',
                 any(n['id'] == sin_duenio and n['plan'] == 'featured' and n['founder_until'] == '2027-06-30'
                     for n in filas(rest('POST', 'rpc/mis_negocios', {}, b))))

            print('place_marks (lugares sin reclamar)')
            caso('A marca un lugar (solo el rubro)',
                 rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'trainer', 'p_lat': -34.7300, 'p_lng': -55.9300}, a)[0] == 200)
            caso('A no lo marca dos veces',
                 rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'trainer', 'p_lat': -34.73001, 'p_lng': -55.93001}, a)[0] >= 400)
            rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'trainer', 'p_lat': -34.73005, 'p_lng': -55.93003,
                                              'p_link': 'https://maps.app.goo.gl/abc'}, b)
            grupos = [g for g in filas(rest('POST', 'rpc/lugares_sin_reclamar_en_zona', pando_rect)) if g['category'] == 'trainer']
            caso('dos marcas del mismo rubro a menos de 30 m se suman ("marcado por 2")',
                 any(g['marcas'] == 2 for g in grupos))
            caso('un visitante ve los grupos sin saber quién marcó',
                 all('user_id' not in g for g in filas(rest('POST', 'rpc/lugares_sin_reclamar_en_zona', pando_rect))))
            caso('B no ve las marcas de A', all(m.get('user_id') == b_id for m in filas(rest('GET', 'place_marks?select=user_id', quien=b))))
            caso('un enlace que no es de Google Maps se rechaza',
                 rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'vet', 'p_lat': -34.74, 'p_lng': -55.94, 'p_link': 'https://estafa.com/x'}, a)[0] >= 400)
            s_n3, desde_marca = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Adiestramiento RLS', 'business_type': 'trainer', 'kind': 'local', 'lat': -34.73002, 'lng': -55.93002}}, a)
            caso('al dar de alta el negocio, las marcas cercanas del rubro quedan absorbidas',
                 s_n3 == 200 and not any(g['category'] == 'trainer' and abs(g['lat'] + 34.73) < 0.001
                                         for g in filas(rest('POST', 'rpc/lugares_sin_reclamar_en_zona', pando_rect))))
            print('chat con comercios y reseñas (1.4.3 y 1.7)')
            caso('A no puede abrir un chat con su propio negocio', rest('POST', 'rpc/iniciar_chat_negocio', {'p_business': negocio}, a)[0] >= 400)
            caso('B no puede reseñar sin contacto real',
                 rest('POST', 'rpc/puedo_resenar', {'p_business': negocio}, b)[1] is False
                 and rest('POST', 'rpc/guardar_resena', {'p_business': negocio, 'p_estrellas': 5}, b)[0] >= 400)
            s_cn, conv_n = rest('POST', 'rpc/iniciar_chat_negocio', {'p_business': negocio}, b)
            caso('B abre un chat con el negocio de A', s_cn == 200 and isinstance(conv_n, str))
            rest('POST', 'messages', {'conversation_id': conv_n, 'body': '¿Tienen turno el sábado?'}, b, 'return=minimal')
            lista_n = filas(rest('POST', 'rpc/mis_conversaciones', {}, b))
            caso('B ve el chat con el nombre del negocio (no el de A)',
                 any(c['id'] == conv_n and c['negocio_nombre'] == 'Peluquería Prueba RLS' and c['otro_nombre'] is None for c in lista_n))
            caso('A (el comercio) ve el nombre de B',
                 any(c['id'] == conv_n and c['otro_nombre'] == 'Prueba b' and c['soy_autor'] for c in filas(rest('POST', 'rpc/mis_conversaciones', {}, a))))
            caso('con el chat hay contacto real: B puede reseñar', rest('POST', 'rpc/puedo_resenar', {'p_business': negocio}, b)[1] is True)
            caso('las estrellas van de 1 a 5',
                 rest('POST', 'rpc/guardar_resena', {'p_business': negocio, 'p_estrellas': 6}, b)[0] >= 400)
            s_rv, resena = rest('POST', 'rpc/guardar_resena', {'p_business': negocio, 'p_estrellas': 4, 'p_comentario': 'Muy buena atención'}, b)
            caso('B deja su reseña', s_rv == 200)
            caso('B la edita (una sola por comercio)',
                 rest('POST', 'rpc/guardar_resena', {'p_business': negocio, 'p_estrellas': 5, 'p_comentario': 'Excelente'}, b)[1] == resena)
            publicas = filas(rest('POST', 'rpc/resenas_de', {'p_business': negocio}))
            caso('un visitante ve la reseña con el nombre (sin el id de quien la escribió)',
                 len(publicas) == 1 and publicas[0]['estrellas'] == 5 and publicas[0]['autor'] == 'Prueba'
                 and 'user_id' not in publicas[0])
            caso('A no puede reseñar su propio negocio',
                 rest('POST', 'rpc/guardar_resena', {'p_business': negocio, 'p_estrellas': 5}, a)[0] >= 400)
            caso('nadie lee la tabla de reseñas directo', bloqueado(rest('GET', 'reviews?select=id', quien=a)))
            caso('B no responde reseñas de un negocio ajeno',
                 rest('POST', 'rpc/responder_resena', {'p_review': resena, 'p_respuesta': 'X'}, b)[0] >= 400)
            caso('A responde una vez', rest('POST', 'rpc/responder_resena', {'p_review': resena, 'p_respuesta': '¡Gracias!'}, a)[0] in (200, 204))
            caso('y no dos', rest('POST', 'rpc/responder_resena', {'p_review': resena, 'p_respuesta': 'Otra'}, a)[0] >= 400)
            caso('A no puede borrar la reseña', bloqueado(rest('DELETE', f'reviews?id=eq.{resena}', quien=a)))
            caso('A puede reportarla', rest('POST', 'flags', {'target_type': 'review', 'target_id': resena, 'reason': 'falsa'}, a, 'return=minimal')[0] == 201)
            caso('la reseña reportada aparece en moderación',
                 any(i['target_type'] == 'review' and i['target_id'] == resena for i in filas(rest('POST', 'rpc/admin_moderacion', {}, x))))
            panel_r = rest('POST', 'rpc/panel_negocio', {'p_id': negocio}, a)[1]
            caso('el panel del comercio suma la reputación', panel_r.get('resenas') == 1 and float(panel_r.get('promedio')) == 5.0)
            rest('POST', 'rpc/admin_moderar', {'p_tipo': 'review', 'p_id': resena, 'p_accion': 'eliminar'}, x)
            caso('X elimina la reseña', filas(rest('POST', 'rpc/resenas_de', {'p_business': negocio})) == [])
            pedir('DELETE', f'{URL}/rest/v1/flags?target_type=eq.review', headers=ADMIN)

            print('adopción responsable (2.0)')
            animal = {'name': 'Pelusa', 'species_id': 2, 'age_months': 6, 'size': 'chico', 'energy': 'media',
                      'neutered': False, 'vaccinated': False, 'microchip': False, 'photos': [f'{a_id}/pelusa.jpg']}
            s_ad, adopcion1 = rest('POST', 'rpc/publicar_adopcion', {'p': {'description': 'Muy cariñosa'}, 'p_animales': [animal]}, a)
            caso('A publica un animal en adopción (particular)', s_ad == 200 and isinstance(adopcion1, str))
            caso('un particular no puede pedir dinero',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {'contribution_amount': 800}, 'p_animales': [animal]}, a)[0] >= 400)
            caso('no se usan fotos de otra persona',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {}, 'p_animales': [{**animal, 'photos': [f'{b_id}/x.jpg']}]}, a)[0] >= 400)
            caso('sin foto no se publica',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {}, 'p_animales': [{**animal, 'photos': []}]}, a)[0] >= 400)
            caso('A publica una segunda',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {}, 'p_animales': [{**animal, 'name': 'Michi'}]}, a)[0] == 200)
            caso('una tercera activa no (máximo 2 de particulares)',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {}, 'p_animales': [{**animal, 'name': 'Otra'}]}, a)[0] >= 400)
            caso('un refugio sin verificar no publica como refugio',
                 rest('POST', 'rpc/publicar_adopcion', {'p': {'shelter_id': negocio}, 'p_animales': [animal]}, a)[0] >= 400)
            disponibles = filas(rest('POST', 'rpc/adopciones_disponibles', {}))
            pelusa = next((d for d in disponibles if d['adoption_id'] == adopcion1), None)
            caso('un visitante ve el animal sin datos de quien publica',
                 pelusa is not None and pelusa['publisher_kind'] == 'individual' and 'publisher_id' not in pelusa)
            caso('nadie lee las tablas de adopción directo',
                 bloqueado(rest('GET', 'adoptions?select=id', quien=a)) and bloqueado(rest('GET', 'adoption_requests?select=id', quien=b)))
            caso('A no puede interesarse en su propio animal', rest('POST', 'rpc/me_interesa', {'p_animal': pelusa['animal_id']}, a)[0] >= 400)
            caso('B completa su perfil de adoptante',
                 rest('POST', 'adopter_profiles', {'housing': 'apartamento', 'has_yard': False, 'hours_alone': 6, 'kids': True}, b, 'return=minimal')[0] == 201)
            caso('A no lee el perfil de B directo', filas(rest('GET', 'adopter_profiles?select=user_id', quien=a)) == [])
            s_mi, solicitud = rest('POST', 'rpc/me_interesa', {'p_animal': pelusa['animal_id'], 'p_mensaje': 'Me encantaría'}, b)
            caso('B dice "Me interesa"', s_mi == 200 and isinstance(solicitud, str))
            recibidas = filas(rest('POST', 'rpc/solicitudes_recibidas', {}, a))
            caso('A ve la solicitud con el perfil de B (para la compatibilidad), sin su id',
                 len(recibidas) == 1 and recibidas[0]['perfil']['housing'] == 'apartamento' and 'user_id' not in recibidas[0]['perfil'])
            caso('B no ve solicitudes de otros', filas(rest('POST', 'rpc/solicitudes_recibidas', {}, b)) == [])
            caso('A deja una nota privada', rest('POST', 'rpc/nota_de_solicitud', {'p_id': solicitud, 'p_nota': 'Muy amable'}, a)[0] in (200, 204))
            caso('B no puede escribir notas', rest('POST', 'rpc/nota_de_solicitud', {'p_id': solicitud, 'p_nota': 'X'}, b)[0] >= 400)
            caso('B no puede avanzar su propia solicitud', rest('POST', 'rpc/avanzar_solicitud', {'p_id': solicitud, 'p_etapa': 'agreement'}, b)[0] >= 400)
            caso('nadie salta a "adoptado" sin el compromiso', rest('POST', 'rpc/avanzar_solicitud', {'p_id': solicitud, 'p_etapa': 'adopted'}, a)[0] >= 400)
            caso('B no acepta el compromiso antes de tiempo',
                 rest('POST', 'rpc/aceptar_compromiso', {'p_id': solicitud, 'p_version': 'borrador'}, b)[0] >= 400)
            for etapa in ('questionnaire', 'interview', 'visit', 'agreement'):
                rest('POST', 'rpc/avanzar_solicitud', {'p_id': solicitud, 'p_etapa': etapa}, a)
            caso('A no acepta el compromiso por B', rest('POST', 'rpc/aceptar_compromiso', {'p_id': solicitud, 'p_version': 'borrador'}, a)[0] >= 400)
            s_ac, mascota_b = rest('POST', 'rpc/aceptar_compromiso', {'p_id': solicitud, 'p_version': 'borrador-2026-10'}, b)
            caso('B acepta el compromiso y la mascota pasa a su cuenta',
                 s_ac == 200 and len(filas(rest('GET', f'pets?select=id&id=eq.{mascota_b}', quien=b))) == 1)
            rec_b = filas(rest('GET', f'reminders?select=title&pet_id=eq.{mascota_b}', quien=b))
            caso('se crean los recordatorios de castración, vacunas y microchip', len(rec_b) == 3)
            caso('el seguimiento queda a los 7, 30 y 90 días',
                 sorted(f['day'] for f in filas(rest('POST', 'rpc/mis_seguimientos', {}, b))) == [7, 30, 90])
            caso('ya no aparece en adopción',
                 all(d['adoption_id'] != adopcion1 for d in filas(rest('POST', 'rpc/adopciones_disponibles', {}))))
            seg = filas(rest('POST', 'rpc/mis_seguimientos', {}, b))
            caso('no se responde el seguimiento antes de tiempo',
                 rest('POST', 'rpc/responder_seguimiento', {'p_id': seg[0]['id'], 'p_respuesta': 'Bien'}, b)[0] >= 400)
            caso('A no responde el seguimiento de B',
                 rest('POST', 'rpc/responder_seguimiento', {'p_id': seg[0]['id'], 'p_respuesta': 'X'}, a)[0] >= 400)
            caso('X ve la cola de revisión de adopciones', rest('POST', 'rpc/admin_adopciones_en_revision', {}, x)[0] == 200)
            caso('A no la ve', rest('POST', 'rpc/admin_adopciones_en_revision', {}, a)[0] >= 400)
            pedir('DELETE', f'{URL}/rest/v1/adoptions?publisher_id=eq.{a_id}', headers=ADMIN)

            print('eventos y denuncias (2.7)')
            evento = {'kind': 'castracion', 'title': 'Jornada de castración', 'starts_at': '2027-01-10T12:00:00Z',
                      'ends_at': '2027-01-10T20:00:00Z', 'lat': -34.715, 'lng': -55.955, 'business_id': negocio}
            caso('un negocio sin verificar no publica eventos',
                 rest('POST', 'rpc/publicar_evento', {'p': {**evento, 'business_id': sin_duenio}}, a)[0] >= 400)
            caso('B no publica eventos a nombre del negocio de A', rest('POST', 'rpc/publicar_evento', {'p': evento}, b)[0] >= 400)
            s_ev, ev = rest('POST', 'rpc/publicar_evento', {'p': evento}, a)
            caso('A (negocio verificado) publica un evento', s_ev == 200)
            en_zona_ev = filas(rest('POST', 'rpc/eventos_en_zona', pando_rect))
            caso('un visitante lo ve en el mapa con el organizador',
                 any(e['id'] == ev and e['organizador'] == 'Peluquería Prueba RLS' and e['mine'] is False for e in en_zona_ev))
            caso('un evento de más de 14 días se rechaza',
                 rest('POST', 'rpc/publicar_evento', {'p': {**evento, 'ends_at': '2027-02-10T20:00:00Z'}}, a)[0] >= 400)
            caso('B no cancela el evento de A', rest('POST', 'rpc/cancelar_evento', {'p_id': ev}, b)[0] >= 400)
            rest('POST', 'rpc/cancelar_evento', {'p_id': ev}, a)
            caso('cancelado, ya no aparece', all(e['id'] != ev for e in filas(rest('POST', 'rpc/eventos_en_zona', pando_rect))))
            caso('nadie lee la tabla de eventos directo', bloqueado(rest('GET', 'events_calendar?select=id', quien=a)))
            s_dn, denuncia = rest('POST', 'rpc/denunciar_maltrato', {'p_descripcion': 'Perro atado sin agua desde hace días',
                                                                     'p_lat': -34.72, 'p_lng': -55.96}, b)
            caso('B denuncia un maltrato', s_dn == 200)
            caso('B ve su denuncia', len(filas(rest('POST', 'rpc/mis_denuncias', {}, b))) == 1)
            caso('A no ve las denuncias de B', filas(rest('POST', 'rpc/mis_denuncias', {}, a)) == [])
            caso('una denuncia muy corta se rechaza', rest('POST', 'rpc/denunciar_maltrato', {'p_descripcion': 'mal'}, b)[0] >= 400)
            caso('fotos de otra persona no', rest('POST', 'rpc/denunciar_maltrato',
                 {'p_descripcion': 'Descripción suficiente', 'p_fotos': [f'{a_id}/x.jpg']}, b)[0] >= 400)
            caso('A no ve las denuncias de administración', rest('POST', 'rpc/admin_denuncias', {}, a)[0] >= 400)
            caso('X las ve con la ubicación', any(d['id'] == denuncia and d['lat'] is not None
                                                  for d in filas(rest('POST', 'rpc/admin_denuncias', {}, x))))
            rest('POST', 'rpc/admin_estado_denuncia', {'p_id': denuncia, 'p_estado': 'referred', 'p_nota': 'Derivada al INBA'}, x)
            caso('X la deriva y B ve el estado', filas(rest('POST', 'rpc/mis_denuncias', {}, b))[0]['status'] == 'referred')
            caso('las fotos de denuncias no son públicas',
                 pedir('GET', f'{URL}/storage/v1/object/public/abuse-photos/{b_id}/x.jpg')[0] >= 400)
            pedir('DELETE', f'{URL}/rest/v1/qr_tags?pet_id=eq.{mascota_b}', headers=ADMIN)
            pedir('DELETE', f'{URL}/rest/v1/pets?id=eq.{mascota_b}', headers=ADMIN)

            print('socios de la veterinaria y "Busco veterinaria" (2.6)')
            s_vet, vet = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Veterinaria Socios RLS', 'business_type': 'vet', 'kind': 'local', 'lat': -34.7201, 'lng': -55.9601}}, a)
            caso('A da de alta una veterinaria', s_vet == 200)
            caso('sin plan Plus no se prende el módulo Socios',
                 rest('POST', 'rpc/prender_modulo', {'p_business': vet, 'p_modulo': 'socios', 'p_prendido': True}, a)[0] >= 400)
            caso('A no se pone el plan', rest('POST', 'rpc/admin_plan_comercio', {'p_business': vet, 'p_plan': 'plus'}, a)[0] >= 400)
            caso('X le pone el plan Plus', rest('POST', 'rpc/admin_plan_comercio', {'p_business': vet, 'p_plan': 'plus'}, x)[0] in (200, 204))
            caso('una peluquería no admite Socios',
                 rest('POST', 'rpc/admin_plan_comercio', {'p_business': negocio, 'p_plan': 'plus'}, x)[0] in (200, 204)
                 and rest('POST', 'rpc/prender_modulo', {'p_business': negocio, 'p_modulo': 'socios', 'p_prendido': True}, a)[0] >= 400)
            caso('sin prenderlo, no hay socios', rest('POST', 'rpc/mis_socios', {'p_business': vet}, a)[0] >= 400)
            caso('A prende Socios', rest('POST', 'rpc/prender_modulo', {'p_business': vet, 'p_modulo': 'socios', 'p_prendido': True}, a)[0] in (200, 204))
            caso('B no prende módulos ajenos',
                 rest('POST', 'rpc/prender_modulo', {'p_business': vet, 'p_modulo': 'agenda', 'p_prendido': True}, b)[0] >= 400)
            caso('nadie escribe los módulos directo',
                 bloqueado(rest('POST', 'business_modules', {'business_id': vet, 'module': 'catalogo'}, a)))
            s_tb, toby = rest('POST', 'pets', {'name': 'Toby', 'species_id': 1}, b)
            toby = toby[0]['id']
            caso('A no comparte la mascota de B',
                 rest('POST', 'rpc/compartir_con_veterinaria', {'p_pet': toby, 'p_business': vet, 'p_compartir': True}, a)[0] >= 400)
            caso('solo se comparte con veterinarias',
                 rest('POST', 'rpc/compartir_con_veterinaria', {'p_pet': toby, 'p_business': negocio, 'p_compartir': True}, b)[0] >= 400)
            caso('B comparte a Toby con la veterinaria',
                 rest('POST', 'rpc/compartir_con_veterinaria', {'p_pet': toby, 'p_business': vet, 'p_compartir': True}, b)[0] in (200, 204))
            socios = filas(rest('POST', 'rpc/mis_socios', {'p_business': vet}, a))
            caso('la veterinaria ve a Toby con el primer nombre del dueño (sin su id ni teléfono)',
                 len(socios) == 1 and socios[0]['nombre'] == 'Toby' and socios[0]['duenio'] == 'Prueba'
                 and set(socios[0]) == {'pet_id', 'nombre', 'especie', 'duenio', 'proximo', 'proximo_que'})
            caso('B no ve los socios', rest('POST', 'rpc/mis_socios', {'p_business': vet}, b)[0] >= 400)
            caso('"Recordar" crea un recordatorio en la mascota',
                 rest('POST', 'rpc/recordar_a_socio', {'p_business': vet, 'p_pet': toby, 'p_titulo': 'Control anual',
                                                       'p_cuando': '2027-03-01T13:00:00Z'}, a)[0] in (200, 204)
                 and any(r['title'] == 'Control anual (de tu veterinaria)'
                         for r in filas(rest('GET', f'reminders?select=title&pet_id=eq.{toby}', quien=b))))
            caso('no se recuerda con fecha pasada',
                 rest('POST', 'rpc/recordar_a_socio', {'p_business': vet, 'p_pet': toby, 'p_titulo': 'X',
                                                       'p_cuando': '2020-01-01T00:00:00Z'}, a)[0] >= 400)
            rest('POST', 'rpc/compartir_con_veterinaria', {'p_pet': toby, 'p_business': vet, 'p_compartir': False}, b)
            caso('B deja de compartir y la veterinaria ya no la ve', filas(rest('POST', 'rpc/mis_socios', {'p_business': vet}, a)) == [])
            caso('ni le puede recordar',
                 rest('POST', 'rpc/recordar_a_socio', {'p_business': vet, 'p_pet': toby, 'p_titulo': 'X',
                                                       'p_cuando': '2027-03-01T13:00:00Z'}, a)[0] >= 400)
            caso('nadie lee lo compartido directo (salvo quien cuida)',
                 filas(rest('GET', 'pet_vet_shares?select=pet_id', quien=a)) == []
                 and len(filas(rest('GET', 'pet_vet_shares?select=pet_id', quien=b))) == 1)
            estado = rest('POST', 'rpc/estado_busco_veterinaria', {'p_pet': toby}, b)[1]
            caso('a B se le puede preguntar si busca veterinaria', estado == {'buscando': False, 'preguntar': True})
            caso('A no decide por B', rest('POST', 'rpc/busco_veterinaria', {'p_pet': toby, 'p_quiero': True}, a)[0] >= 400)
            zona(b, -34.7205, -55.9605)
            caso('B dice que busca veterinaria', rest('POST', 'rpc/busco_veterinaria', {'p_pet': toby, 'p_quiero': True}, b)[0] in (200, 204))
            caso('con menos de 5 mascotas cerca la demanda no se muestra',
                 filas(rest('POST', 'rpc/demanda_de_veterinaria', {'p_business': vet}, a)) == [])
            caso('B no ve la demanda', rest('POST', 'rpc/demanda_de_veterinaria', {'p_business': vet}, b)[0] >= 400)
            caso('nadie lee los consentimientos ni las propuestas directo',
                 bloqueado(rest('GET', 'vet_search_consents?select=pet_id', quien=b))
                 and bloqueado(rest('GET', 'vet_proposals?select=id', quien=a)))
            s_pr, llegaron = rest('POST', 'rpc/enviar_propuesta_veterinaria', {'p_business': vet, 'p_mensaje': 'Primera consulta sin cargo'}, a)
            caso('la propuesta le llega a Toby', s_pr == 200 and llegaron == 1)
            bandeja = filas(rest('POST', 'rpc/propuestas_para', {'p_pet': toby}, b))
            caso('B ve la propuesta con el nombre de la veterinaria', len(bandeja) == 1 and bandeja[0]['negocio'] == 'Veterinaria Socios RLS')
            caso('A no ve la bandeja de B', rest('POST', 'rpc/propuestas_para', {'p_pet': toby}, a)[0] >= 400)
            propuesta = bandeja[0]['proposal_id'] if bandeja else '00000000-0000-0000-0000-000000000000'
            resultados = filas(rest('POST', 'rpc/resultados_propuestas', {'p_business': vet}, a))
            caso('la veterinaria ve cantidades, no personas',
                 bool(resultados) and resultados[0]['enviadas'] == 1 and resultados[0]['vistas'] == 1 and 'pet_id' not in resultados[0])
            caso('A no acepta por B',
                 rest('POST', 'rpc/responder_propuesta', {'p_proposal': propuesta, 'p_pet': toby, 'p_acepto': True}, a)[0] >= 400)
            caso('B acepta y Toby pasa a ser socio',
                 rest('POST', 'rpc/responder_propuesta', {'p_proposal': propuesta, 'p_pet': toby, 'p_acepto': True}, b)[1] == vet
                 and len(filas(rest('POST', 'rpc/mis_socios', {'p_business': vet}, a))) == 1)
            caso('no se responde dos veces',
                 rest('POST', 'rpc/responder_propuesta', {'p_proposal': propuesta, 'p_pet': toby, 'p_acepto': False}, b)[0] >= 400)
            rest('POST', 'rpc/enviar_propuesta_veterinaria', {'p_business': vet, 'p_mensaje': 'Segunda propuesta'}, a)
            caso('como máximo 2 propuestas por semana',
                 rest('POST', 'rpc/enviar_propuesta_veterinaria', {'p_business': vet, 'p_mensaje': 'Tercera propuesta'}, a)[0] >= 400)
            rest('POST', 'rpc/ahora_no_busco_veterinaria', {'p_pet': toby}, b)
            caso('"Ahora no" deja de buscar y no vuelve a preguntar',
                 rest('POST', 'rpc/estado_busco_veterinaria', {'p_pet': toby}, b)[1] == {'buscando': False, 'preguntar': False})
            pedir('DELETE', f'{URL}/rest/v1/pets?id=eq.{toby}', headers=ADMIN)
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{vet}', headers=ADMIN)

            print('noticias (2.8)')
            noticia = {'title': 'Prueba RLS: vacunación', 'body': 'Jornada de vacunación antirrábica en la plaza.',
                       'species_ids': [1], 'status': 'published'}
            caso('A no carga noticias', rest('POST', 'rpc/admin_guardar_noticia', {'p': noticia}, a)[0] >= 400)
            caso('nadie escribe la tabla directo', bloqueado(rest('POST', 'news', noticia, a)))
            s_nt, nt = rest('POST', 'rpc/admin_guardar_noticia', {'p': noticia}, x)
            caso('X carga una noticia para perros', s_nt == 200)
            s_np, nt_p = rest('POST', 'rpc/admin_guardar_noticia', {'p': {
                'title': 'Prueba RLS: alimento', 'body': 'Nuevo alimento para gatos adultos.', 'species_ids': [2],
                'sponsored': True, 'sponsor_name': 'Marca Prueba', 'status': 'published'}}, x)
            caso('X carga una patrocinada para gatos', s_np == 200)
            caso('una patrocinada sin marca no se acepta', rest('POST', 'rpc/admin_guardar_noticia', {'p': {
                **noticia, 'sponsored': True}}, x)[0] >= 400)
            s_nb, nt_b = rest('POST', 'rpc/admin_guardar_noticia', {'p': {**noticia, 'title': 'Prueba RLS: borrador', 'status': 'draft'}}, x)
            perros = [n['id'] for n in filas(rest('POST', 'rpc/noticias', {'p_especies': [1]}))]
            caso('un visitante ve la de perros y no la de gatos', nt in perros and nt_p not in perros)
            gatos = [n for n in filas(rest('POST', 'rpc/noticias', {'p_especies': [2]})) if n['id'] == nt_p]
            caso('la patrocinada dice de qué marca es', len(gatos) == 1 and gatos[0]['sponsored'] and gatos[0]['sponsor_name'] == 'Marca Prueba')
            caso('los borradores no se ven', all(n['id'] != nt_b for n in filas(rest('POST', 'rpc/noticias', {}))))
            caso('A no ve la lista de administración', rest('POST', 'rpc/admin_noticias', {}, a)[0] >= 400)
            caso('A reacciona a una noticia publicada (D87)',
                 rest('POST', 'rpc/reaccionar', {'p_id': nt, 'p_tipo': 'gracias'}, a)[0] in (200, 204)
                 and filas(rest('POST', 'rpc/reacciones', {'p_ids': [nt]}))[0]['gracias'] == 1)
            caso('a un borrador no', rest('POST', 'rpc/reaccionar', {'p_id': nt_b, 'p_tipo': 'gracias'}, a)[0] >= 400)
            rest('POST', 'rpc/admin_guardar_noticia', {'p': {**noticia, 'id': nt, 'status': 'hidden'}}, x)
            caso('oculta, ya no aparece', all(n['id'] != nt for n in filas(rest('POST', 'rpc/noticias', {}))))
            pedir('DELETE', f'{URL}/rest/v1/news?title=like.Prueba%20RLS*', headers=ADMIN)

            print('novedades de la comunidad: generadas solas y moderación (D86)')
            lugar = filas(pedir('POST', f'{URL}/rest/v1/businesses', {
                'name': 'Veterinaria Novedad RLS', 'business_type': 'vet', 'verification': 'verified',
                'location': 'SRID=4326;POINT(-55.9581 -34.7171)'}, {**ADMIN, 'Prefer': 'return=representation'}))[0]['id']
            def del_lugar():
                return [n for n in filas(rest('POST', 'rpc/novedades_comunidad', {}))
                        if n['kind'] == 'comercio' and n['name'] == 'Veterinaria Novedad RLS']
            caso('un lugar verificado aparece solo en la comunidad', len(del_lugar()) == 1)
            caso('A no ve la lista de moderación', rest('POST', 'rpc/admin_novedades', {}, a)[0] >= 400)
            nov = del_lugar()[0]['id']
            caso('A no puede ocultar una novedad',
                 rest('POST', 'rpc/admin_estado_novedad', {'p_id': nov, 'p_estado': 'hidden'}, a)[0] >= 400)
            print('reacciones (D87)')
            def reacciones(quien=None):
                return {k: v for k, v in (filas(rest('POST', 'rpc/reacciones', {'p_ids': [nov]}, quien)) or [{}])[0].items() if k != 'id'}
            caso('nadie lee ni escribe las reacciones directo',
                 bloqueado(rest('GET', 'news_reactions?select=*', quien=a))
                 and bloqueado(rest('POST', 'news_reactions', {'update_id': nov, 'user_id': a_id, 'kind': 'alegra'}, a)))
            caso('no se aceptan reacciones inventadas',
                 rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'enojo'}, a)[0] >= 400)
            rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'alegra'}, a)
            rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'alegra'}, a)
            rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'gracias'}, b)
            caso('un visitante ve solo totales (una por persona)',
                 reacciones() == {'alegra': 1, 'festejo': 0, 'gracias': 1, 'mia': None})
            caso('cada uno ve la suya', reacciones(a)['mia'] == 'alegra' and reacciones(b)['mia'] == 'gracias')
            rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'festejo'}, a)
            caso('A la cambia', reacciones(a) == {'alegra': 0, 'festejo': 1, 'gracias': 1, 'mia': 'festejo'})
            rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': None}, b)
            caso('B la quita', reacciones(b) == {'alegra': 0, 'festejo': 1, 'gracias': 0, 'mia': None})
            caso('X la oculta', rest('POST', 'rpc/admin_estado_novedad', {'p_id': nov, 'p_estado': 'hidden'}, x)[0] in (200, 204))
            caso('oculta, no se le reacciona',
                 rest('POST', 'rpc/reaccionar', {'p_id': nov, 'p_tipo': 'alegra'}, b)[0] >= 400)
            caso('oculta, ya no aparece', del_lugar() == [])
            caso('el resumen solo trae totales',
                 set(filas(rest('POST', 'rpc/resumen_comunidad', {}))[0]) ==
                 {'reencuentros', 'adopciones', 'perdidas_activas', 'lugares_verificados'})
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{lugar}', headers=ADMIN)

            print('catálogo y pedidos (2.5 y 3.2)')
            s_ps, tienda = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Pet Shop Catálogo RLS', 'business_type': 'petshop', 'kind': 'local', 'lat': -34.7211, 'lng': -55.9611}}, a)
            caso('A da de alta un pet shop', s_ps == 200)
            producto = {'name': 'Alimento perro adulto 3 kg', 'price': 890, 'species_ids': [1]}
            caso('sin plan Plus no se cargan productos',
                 rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': producto}, a)[0] >= 400)
            rest('POST', 'rpc/admin_plan_comercio', {'p_business': tienda, 'p_plan': 'plus'}, x)
            s_p1, p1 = rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': producto}, a)
            caso('con Plus, A carga un producto', s_p1 == 200)
            s_p2, p2 = rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': {'name': 'Cucha a medida'}}, a)
            caso('y uno sin precio ("Consultar")', s_p2 == 200)
            s_p3, p3 = rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': {
                'name': 'Collar', 'price': 250, 'available': False}}, a)
            caso('B no carga productos en un comercio ajeno',
                 rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': producto}, b)[0] >= 400)
            caso('la foto tiene que estar en la carpeta del comercio',
                 rest('POST', 'rpc/guardar_producto', {'p_negocio': tienda, 'p': {
                     **producto, 'photo_path': f'{b_id}/catalogo/x.jpg'}}, a)[0] >= 400)
            caso('nadie lee ni escribe las tablas directo',
                 bloqueado(rest('GET', 'catalog_items?select=id', quien=a))
                 and bloqueado(rest('POST', 'catalog_items', {'business_id': tienda, 'name': 'X'}, a))
                 and bloqueado(rest('GET', 'orders?select=id', quien=a))
                 and bloqueado(rest('POST', 'orders', {'business_id': tienda, 'total': 0}, b)))
            caso('sin prender el módulo, el catálogo no se ve',
                 filas(rest('POST', 'rpc/catalogo_de', {'p_negocio': tienda})) == [])
            caso('ni toma pedidos', rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p1, 'qty': 1}]}, b)[0] >= 400)
            rest('POST', 'rpc/prender_modulo', {'p_business': tienda, 'p_modulo': 'catalogo', 'p_prendido': True}, a)
            publico = filas(rest('POST', 'rpc/catalogo_de', {'p_negocio': tienda}))
            caso('prendido, un visitante ve lo disponible (no lo agotado)',
                 {i['id'] for i in publico} == {p1, p2})
            caso('el dueño ve también lo no disponible', len(filas(rest('POST', 'rpc/mi_catalogo', {'p_negocio': tienda}, a))) == 3)
            caso('B no ve el catálogo interno', rest('POST', 'rpc/mi_catalogo', {'p_negocio': tienda}, b)[0] >= 400)
            caso('un visitante no hace pedidos', rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p1, 'qty': 1}]})[0] >= 400)
            caso('no se pide lo que no tiene precio', rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p2, 'qty': 1}]}, b)[0] >= 400)
            caso('ni lo que no está disponible', rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p3, 'qty': 1}]}, b)[0] >= 400)
            caso('ni cantidades fuera de 1 a 99', rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p1, 'qty': 0}]}, b)[0] >= 400)
            s_pe, pedido = rest('POST', 'rpc/hacer_pedido', {
                'p_negocio': tienda, 'p_items': [{'id': p1, 'qty': 2, 'price': 1}], 'p_nota': 'Paso a las 18'}, b)
            caso('B hace un pedido', s_pe == 200)
            mios = filas(rest('POST', 'rpc/mis_pedidos', {}, b))
            caso('el total lo calcula la base (no el precio que manda la app)',
                 len(mios) == 1 and float(mios[0]['total']) == 1780 and mios[0]['items'][0]['qty'] == 2
                 and mios[0]['status'] == 'new' and mios[0]['business_name'] == 'Pet Shop Catálogo RLS')
            caso('A no ve los pedidos de B como propios', filas(rest('POST', 'rpc/mis_pedidos', {}, a)) == [])
            del_negocio = filas(rest('POST', 'rpc/pedidos_del_negocio', {'p_negocio': tienda}, a))
            caso('el comercio ve el pedido con el primer nombre (sin id ni contacto)',
                 len(del_negocio) == 1 and del_negocio[0]['cliente'] == 'Prueba'
                 and 'user_id' not in del_negocio[0] and 'phone' not in del_negocio[0])
            caso('B no ve los pedidos del comercio', rest('POST', 'rpc/pedidos_del_negocio', {'p_negocio': tienda}, b)[0] >= 400)
            caso('el comercio cuenta los nuevos', rest('POST', 'rpc/pedidos_nuevos', {'p_negocio': tienda}, a)[1] == 1)
            caso('el comercio no salta pasos', rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': pedido, 'p_estado': 'ready'}, a)[0] >= 400)
            caso('B no avanza su propio pedido', rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': pedido, 'p_estado': 'preparing'}, b)[0] >= 400)
            for paso in ('preparing', 'ready', 'delivered'):
                rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': pedido, 'p_estado': paso}, a)
            caso('el comercio lo lleva hasta entregado y B lo ve',
                 filas(rest('POST', 'rpc/mis_pedidos', {}, b))[0]['status'] == 'delivered')
            caso('entregado ya no se cancela', rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': pedido, 'p_estado': 'cancelled'}, a)[0] >= 400)
            s_p4, otro = rest('POST', 'rpc/hacer_pedido', {'p_negocio': tienda, 'p_items': [{'id': p1, 'qty': 1}]}, b)
            caso('B cancela un pedido nuevo', rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': otro, 'p_estado': 'cancelled'}, b)[0] in (200, 204))
            caso('quien no es el comercio ni quien pidió no lo toca',
                 rest('POST', 'rpc/cambiar_estado_pedido', {'p_id': pedido, 'p_estado': 'cancelled'}, x)[0] >= 400)
            caso('B no borra productos ajenos', rest('POST', 'rpc/borrar_producto', {'p_id': p3}, b)[0] >= 400)
            caso('A borra un producto y el pedido conserva su renglón',
                 rest('POST', 'rpc/borrar_producto', {'p_id': p1}, a)[0] in (200, 204)
                 and filas(rest('POST', 'rpc/mis_pedidos', {}, b))[-1]['items'][0]['name'] == 'Alimento perro adulto 3 kg')
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{tienda}', headers=ADMIN)

            print('rubro Agropecuaria (2.8e)')
            s_ag, agro = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Agropecuaria RLS', 'business_type': 'agro', 'kind': 'local', 'lat': -34.7213, 'lng': -55.9613}}, a)
            caso('A da de alta una agropecuaria', s_ag == 200)
            caso('se marca una agropecuaria sin reclamar',
                 rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'agro', 'p_lat': -34.7400, 'p_lng': -55.9400}, b)[0] == 200)
            caso('un rubro inventado no se marca',
                 rest('POST', 'rpc/marcar_lugar', {'p_rubro': 'ferreteria', 'p_lat': -34.7410, 'p_lng': -55.9410}, b)[0] >= 400)
            rest('POST', 'rpc/admin_plan_comercio', {'p_business': agro, 'p_plan': 'plus'}, x)
            caso('con Plus, la agropecuaria carga productos y prende el catálogo',
                 rest('POST', 'rpc/guardar_producto', {'p_negocio': agro, 'p': {'name': 'Ración ovina 25 kg', 'price': 1200}}, a)[0] == 200
                 and rest('POST', 'rpc/prender_modulo', {'p_business': agro, 'p_modulo': 'catalogo', 'p_prendido': True}, a)[0] in (200, 204)
                 and len(filas(rest('POST', 'rpc/catalogo_de', {'p_negocio': agro}))) == 1)
            caso('pero no la agenda (no aplica)',
                 rest('POST', 'rpc/prender_modulo', {'p_business': agro, 'p_modulo': 'agenda', 'p_prendido': True}, a)[0] >= 400)
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{agro}', headers=ADMIN)

            print('servicios del comercio (2.10a)')
            s_pl, pelu = rest('POST', 'rpc/alta_negocio', {'p': {
                'name': 'Peluquería Servicios RLS', 'business_type': 'grooming', 'kind': 'local',
                'lat': -34.7215, 'lng': -55.9615}}, a)
            caso('A da de alta una peluquería', s_pl == 200)
            bano = {'name': 'Baño y corte', 'price': 600, 'price_from': True, 'duration_min': 90}
            caso('sin plan Plus no se cargan servicios',
                 rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': bano}, a)[0] >= 400)
            rest('POST', 'rpc/admin_plan_comercio', {'p_business': pelu, 'p_plan': 'plus'}, x)
            s_s1, s1 = rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': bano}, a)
            caso('con Plus, A carga un servicio', s_s1 == 200)
            s_s2, s2 = rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': {
                'name': 'Deslanado', 'available': False}}, a)
            caso('y uno oculto, sin precio', s_s2 == 200)
            caso('"desde" sin precio no se acepta',
                 rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': {
                     'name': 'Paseo', 'price_from': True}}, a)[0] >= 400)
            caso('ni una duración fuera de 5 min a 24 h',
                 rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': {
                     'name': 'Paseo', 'duration_min': 2}}, a)[0] >= 400)
            caso('B no carga servicios en un comercio ajeno',
                 rest('POST', 'rpc/guardar_servicio', {'p_negocio': pelu, 'p': bano}, b)[0] >= 400)
            caso('nadie lee ni escribe la tabla directo',
                 bloqueado(rest('GET', 'business_services?select=id', quien=a))
                 and bloqueado(rest('POST', 'business_services', {'business_id': pelu, 'name': 'X'}, a)))
            publicos = filas(rest('POST', 'rpc/servicios_de', {'p_negocio': pelu}))
            caso('un visitante ve lo visible, con precio "desde" y duración',
                 [s['id'] for s in publicos] == [s1] and publicos[0]['price_from'] is True
                 and publicos[0]['duration_min'] == 90)
            caso('el dueño ve también lo oculto',
                 len(filas(rest('POST', 'rpc/mis_servicios', {'p_negocio': pelu}, a))) == 2)
            caso('B no ve la lista interna', rest('POST', 'rpc/mis_servicios', {'p_negocio': pelu}, b)[0] >= 400)
            caso('B no borra servicios ajenos', rest('POST', 'rpc/borrar_servicio', {'p_id': s2}, b)[0] >= 400)
            rest('POST', 'rpc/admin_plan_comercio', {'p_business': pelu, 'p_plan': 'basic'}, x)
            caso('si el plan baja, dejan de verse (sin borrarse)',
                 filas(rest('POST', 'rpc/servicios_de', {'p_negocio': pelu})) == []
                 and len(filas(rest('POST', 'rpc/mis_servicios', {'p_negocio': pelu}, a))) == 2)
            caso('A borra un servicio', rest('POST', 'rpc/borrar_servicio', {'p_id': s2}, a)[0] in (200, 204))

            print('página pública del comercio (2.10b)')
            def pagina():
                return rest('POST', 'rpc/pagina_comercio', {'p_id': pelu})[1]
            caso('sin plan Plus no hay página', pagina() == {'status': 'not_found'})
            rest('POST', 'rpc/admin_plan_comercio', {'p_business': pelu, 'p_plan': 'plus'}, x)
            pedir('PATCH', f'{URL}/rest/v1/businesses?id=eq.{pelu}', {'rut': '211234560018'}, ADMIN)
            pag = pagina()
            caso('con Plus, un visitante ve la página con sus servicios visibles',
                 pag.get('status') == 'ok' and pag['name'] == 'Peluquería Servicios RLS'
                 and [s['name'] for s in pag['services']] == ['Baño y corte'])
            caso('sin el dueño, el RUT ni los contactos privados',
                 not {'owner_id', 'rut', 'private_contacts', 'user_id'} & set(pag)
                 and '211234560018' not in json.dumps(pag))
            caso('sin el catálogo prendido no muestra productos', pag['products'] == [])
            caso('un visitante registra la apertura (métrica anónima)',
                 rest('POST', 'events', {'name': 'business_page_open', 'anon_id': str(uuid.uuid4()),
                                         'business_id': pelu, 'platform': 'web'},
                      prefer='return=minimal')[0] in (200, 201, 204))
            pedir('PATCH', f'{URL}/rest/v1/businesses?id=eq.{pelu}', {'status': 'hidden'}, ADMIN)
            caso('un comercio oculto no tiene página', pagina() == {'status': 'not_found'})
            caso('un id que no existe tampoco',
                 rest('POST', 'rpc/pagina_comercio', {'p_id': str(uuid.uuid4())})[1] == {'status': 'not_found'})
            pedir('DELETE', f'{URL}/rest/v1/businesses?id=eq.{pelu}', headers=ADMIN)

            pedir('DELETE', f'{URL}/rest/v1/businesses?id=in.({negocio},{sin_duenio},{desde_marca})', headers=ADMIN)
            pedir('DELETE', f'{URL}/rest/v1/place_marks?user_id=in.({a_id},{b_id})', headers=ADMIN)
        finally:
            pedir('DELETE', f"{URL}/rest/v1/admin_actions?admin_id=eq.{x_id}", headers=ADMIN)
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{x_id}', headers=ADMIN)

    finally:
        pedir('DELETE', f'{URL}/storage/v1/object/pet-photos', {'prefixes': [f'{a_id}/prueba.jpg']}, ADMIN)
        pedir('DELETE', f'{URL}/storage/v1/object/sos-photos', {'prefixes': [f'{a_id}/sos1.jpg']}, ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/flags?target_type=eq.message&reporter_id=eq.{a_id}', headers=ADMIN)
        for uid in (a_id, b_id):
            pedir('DELETE', f'{URL}/auth/v1/admin/users/{uid}', headers=ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/events?name=eq.prueba_rls', headers=ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/feature_flags?key=like.prueba_rls_*', headers=ADMIN)
        pedir('DELETE', f'{URL}/rest/v1/feature_flag_audit?flag_key=like.prueba_rls_*', headers=ADMIN)
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
