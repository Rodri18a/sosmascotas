#!/usr/bin/env python3
"""Carga el directorio de la pestaña Ayuda desde una planilla CSV (paso 0.7.3, D61).

Columnas (la primera fila es el encabezado):
    tipo, nombre, descripcion, telefono, whatsapp, enlace, orden

- tipo: refugio, protectora, grupo (de Facebook o WhatsApp) u organismo.
- enlace: la dirección completa con https:// (página, grupo de Facebook,
  enlace de invitación de WhatsApp).
- orden: número para ordenar dentro de cada tipo (menor, primero). Opcional.
- Cada fila necesita al menos un teléfono, un WhatsApp o un enlace.

Uso (desde la raíz del repo, con las credenciales de dev):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python -I -X utf8 supabase/cargar_ayuda.py supabase/seeds/ayuda_ejemplo.csv --ejemplo [--aplicar]
    python -I -X utf8 supabase/cargar_ayuda.py investigacion/ayuda.csv [--aplicar]

Sin --aplicar solo valida. Con --ejemplo reemplaza los de ejemplo. Sin
--ejemplo borra los de ejemplo y sincroniza los reales por nombre: actualiza
los que ya están, agrega los nuevos y oculta los que ya no figuran.
"""
import csv
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.request

TIPOS = ('refugio', 'protectora', 'grupo', 'organismo')
TELEFONO = re.compile(r'^\+?[0-9 ]{3,20}$')
WHATSAPP = re.compile(r'^\+?[0-9 ]{6,20}$')
COLUMNAS = ['tipo', 'nombre', 'descripcion', 'telefono', 'whatsapp', 'enlace', 'orden']


def filas_del_csv(ruta, ejemplo):
    filas, errores = [], []
    with open(ruta, encoding='utf-8-sig', newline='') as f:
        lector = csv.DictReader(f)
        faltan = [c for c in COLUMNAS if c not in (lector.fieldnames or [])]
        if faltan:
            sys.exit(f'Faltan columnas en {ruta}: {", ".join(faltan)}')
        for n, r in enumerate(lector, start=2):
            if None in r:
                errores.append(f'  fila {n}: tiene columnas de más (¿una descripción con comas sin comillas?)')
                continue
            r = {k: (v or '').strip() for k, v in r.items()}
            try:
                tipo = r['tipo'].lower()
                if tipo not in TIPOS:
                    raise ValueError(f'tipo desconocido "{r["tipo"]}" (refugio, protectora, grupo u organismo)')
                if len(r['nombre']) < 2:
                    raise ValueError('falta el nombre')
                if r['telefono'] and not TELEFONO.match(r['telefono']):
                    raise ValueError('teléfono inválido')
                if r['whatsapp'] and not WHATSAPP.match(r['whatsapp']):
                    raise ValueError('WhatsApp inválido')
                if r['enlace'] and not r['enlace'].startswith('https://'):
                    raise ValueError('el enlace tiene que empezar con https://')
                if not (r['telefono'] or r['whatsapp'] or r['enlace']):
                    raise ValueError('necesita un teléfono, un WhatsApp o un enlace')
                filas.append({
                    'kind': tipo,
                    'name': r['nombre'],
                    'description': r['descripcion'] or None,
                    'phone': r['telefono'] or None,
                    'whatsapp': r['whatsapp'] or None,
                    'link': r['enlace'] or None,
                    'sort': int(r['orden']) if r['orden'] else 100,
                    'is_sample': ejemplo,
                })
            except ValueError as e:
                errores.append(f'  fila {n} ({r.get("nombre") or "sin nombre"}): {e}')
    return filas, errores


def main():
    argumentos = [a for a in sys.argv[1:] if not a.startswith('--')]
    if len(argumentos) != 1:
        sys.exit(__doc__)
    aplicar, ejemplo = '--aplicar' in sys.argv, '--ejemplo' in sys.argv

    raiz = pathlib.Path(__file__).resolve().parents[1]
    ref = (raiz / 'supabase/.temp/project-ref').read_text().strip()
    url = f'https://{ref}.supabase.co'

    def pedir(metodo, destino, cuerpo=None, headers=None):
        req = urllib.request.Request(
            destino, method=metodo,
            data=json.dumps(cuerpo).encode() if cuerpo is not None else None,
            headers={'Content-Type': 'application/json', 'User-Agent': 'sosmascotas-carga', **(headers or {})})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                texto = r.read().decode()
                return r.status, json.loads(texto) if texto else None
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode()

    filas, errores = filas_del_csv(argumentos[0], ejemplo)
    if errores:
        sys.exit('Hay errores en la planilla:\n' + '\n'.join(errores))

    tipo = 'de ejemplo' if ejemplo else 'reales'
    print(f'{len(filas)} entradas {tipo} válidas:')
    for f in filas:
        print(f"  - [{f['kind']}] {f['name']}")
    if not aplicar:
        print('\nNo se cambió nada. Para cargarlas, repetir con --aplicar.')
        return

    # La clave secreta se pide en el momento y no se guarda en ningún lado.
    _, claves = pedir('GET', f'https://api.supabase.com/v1/projects/{ref}/api-keys?reveal=true',
                      headers={'Authorization': f'Bearer {os.environ["SUPABASE_ACCESS_TOKEN"]}'})
    secreta = next(c['api_key'] for c in claves if c.get('type') == 'secret' or c.get('name') == 'service_role')
    admin = {'apikey': secreta, 'Authorization': f'Bearer {secreta}'}
    _, zonas = pedir('GET', f'{url}/rest/v1/zones?select=id&slug=eq.pando', headers=admin)
    for f in filas:
        f['zone_id'] = zonas[0]['id'] if zonas else None

    def ok(respuesta, que):
        s, r = respuesta
        if s not in (200, 201, 204):
            sys.exit(f'No se pudo {que}: {s} {r}')

    ok(pedir('DELETE', f'{url}/rest/v1/help_directory?is_sample=eq.true', headers=admin), 'borrar los de ejemplo')
    if ejemplo:
        ok(pedir('POST', f'{url}/rest/v1/help_directory', filas, {**admin, 'Prefer': 'return=minimal'}), 'cargar')
        print(f'\n✅ Cargadas {len(filas)} entradas de ejemplo.')
        return

    _, existentes = pedir('GET', f'{url}/rest/v1/help_directory?select=id,name&is_sample=eq.false', headers=admin)
    por_nombre = {e['name'].strip().lower(): e['id'] for e in existentes}
    nuevas, actualizadas = [], 0
    for f in filas:
        existente = por_nombre.pop(f['name'].strip().lower(), None)
        if existente:
            ok(pedir('PATCH', f'{url}/rest/v1/help_directory?id=eq.{existente}', {**f, 'status': 'active'},
                     {**admin, 'Prefer': 'return=minimal'}), f"actualizar {f['name']}")
            actualizadas += 1
        else:
            nuevas.append(f)
    if nuevas:
        ok(pedir('POST', f'{url}/rest/v1/help_directory', nuevas, {**admin, 'Prefer': 'return=minimal'}), 'cargar las nuevas')
    for nombre, id_ in por_nombre.items():
        ok(pedir('PATCH', f'{url}/rest/v1/help_directory?id=eq.{id_}', {'status': 'hidden'},
                 {**admin, 'Prefer': 'return=minimal'}), f'ocultar {nombre}')
    print(f'\n✅ {len(nuevas)} nuevas, {actualizadas} actualizadas, {len(por_nombre)} ocultadas '
          '(ya no figuran en la planilla). Las de ejemplo se borraron.')


if __name__ == '__main__':
    main()
