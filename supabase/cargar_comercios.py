#!/usr/bin/env python3
"""Carga los comercios desde una planilla CSV (paso 0.7.1, D59; rubros y "sin local" en 1.2, D75).

Hasta el panel de administración (Fase 1) los comercios se cargan a mano: la
planilla es la fuente de verdad. Sin --aplicar solo valida y muestra qué haría.

Columnas (la primera fila es el encabezado):
    nombre, direccion, lat, lng, telefono, whatsapp, web, instagram,
    horario, urgencias, 24h, especies, descripcion

- lat / lng: copiadas de Google Maps (clic derecho en el lugar). No se usa
  geocodificación (regla de costo del mapa).
- horario: "lun-vie 09:00-13:00,15:00-19:00; sab 09:00-13:00". Días: lun mar
  mie jue vie sab dom. Si un día no figura, cerrado. Vacío si es 24 h.
- urgencias / 24h: "si" o vacío.
- especies: nombres de la app separados por coma ("Perro, Gato"); vacío = todas.
- rubro (opcional, por defecto veterinaria): veterinaria, petshop, farmacia,
  peluqueria, paseador, hotel, adiestrador, acepta_mascotas, refugio.
- modalidad (opcional, por defecto local): local, online o domicilio. Sin
  local, lat / lng pueden quedar vacías (no tienen pin: van a "Sin local").

Uso (desde la raíz del repo, con las credenciales de dev):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python -I -X utf8 supabase/cargar_comercios.py supabase/seeds/veterinarias_ejemplo.csv --ejemplo [--aplicar]
    python -I -X utf8 supabase/cargar_comercios.py investigacion/veterinarias.csv [--aplicar]

Con --ejemplo reemplaza las veterinarias de ejemplo (is_sample). Sin --ejemplo
borra las de ejemplo y sincroniza las reales **por nombre**: actualiza las que
ya están (conservan su id y sus métricas), agrega las nuevas y oculta (no
borra) las que ya no figuran en la planilla.
"""
import csv
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

DIAS = {'lun': 'mon', 'mar': 'tue', 'mie': 'wed', 'jue': 'thu', 'vie': 'fri', 'sab': 'sat', 'dom': 'sun'}
ORDEN = list(DIAS)
HORA = r'([01][0-9]|2[0-3]):[0-5][0-9]'
FRANJA = re.compile(rf'^({HORA})-({HORA}|24:00)$')
TELEFONO = re.compile(r'^\+?[0-9 ]{6,20}$')
RUBROS = {'veterinaria': 'vet', 'vet': 'vet', 'petshop': 'petshop', 'farmacia': 'pharmacy',
          'peluqueria': 'grooming', 'peluquería': 'grooming', 'paseador': 'walker', 'hotel': 'hotel',
          'guarderia': 'hotel', 'guardería': 'hotel', 'adiestrador': 'trainer',
          'acepta_mascotas': 'pet_friendly', 'refugio': 'shelter'}
MODALIDADES = {'local', 'online', 'domicilio'}
COLUMNAS = ['nombre', 'direccion', 'lat', 'lng', 'telefono', 'whatsapp', 'web', 'instagram',
            'horario', 'urgencias', '24h', 'especies', 'descripcion']


def horario(texto):
    """'lun-vie 09:00-19:00; sab 09:00-13:00' -> {'mon': [['09:00','19:00']], ...}."""
    resultado = {}
    for parte in filter(None, (p.strip() for p in texto.split(';'))):
        dias, _, franjas = parte.partition(' ')
        desde, _, hasta = dias.lower().partition('-')
        if desde not in DIAS or (hasta and hasta not in DIAS):
            raise ValueError(f'día desconocido en "{parte}"')
        i, j = ORDEN.index(desde), ORDEN.index(hasta or desde)
        if j < i:
            raise ValueError(f'rango de días al revés en "{parte}"')
        lista = []
        for f in filter(None, (x.strip() for x in franjas.split(','))):
            m = FRANJA.match(f)
            if not m or f.split('-')[0] >= f.split('-')[1]:
                raise ValueError(f'franja inválida "{f}" (formato 09:00-19:00)')
            lista.append(f.split('-'))
        if not lista:
            raise ValueError(f'falta la franja horaria en "{parte}"')
        for d in ORDEN[i:j + 1]:
            resultado.setdefault(DIAS[d], []).extend(lista)
    return resultado


def si(valor):
    return valor.strip().lower() in ('si', 'sí', 'x', '1', 'true')


def filas_del_csv(ruta, especies, ejemplo):
    filas, errores = [], []
    with open(ruta, encoding='utf-8-sig', newline='') as f:
        lector = csv.DictReader(f)
        faltan = [c for c in COLUMNAS if c not in (lector.fieldnames or [])]
        if faltan:
            sys.exit(f'Faltan columnas en {ruta}: {", ".join(faltan)}')
        for n, r in enumerate(lector, start=2):
            if None in r:
                errores.append(f'  fila {n}: tiene columnas de más (¿un horario con comas sin comillas?)')
                continue
            r = {k: (v or '').strip() for k, v in r.items()}
            try:
                rubro = RUBROS.get((r.get('rubro') or 'veterinaria').lower())
                if rubro is None:
                    raise ValueError(f'rubro desconocido "{r.get("rubro")}"')
                modalidad = (r.get('modalidad') or 'local').lower()
                if modalidad not in MODALIDADES:
                    raise ValueError(f'modalidad desconocida "{modalidad}" (local, online o domicilio)')
                ubicacion = None
                if modalidad == 'local' or r['lat'] or r['lng']:
                    lat, lng = float(r['lat'].replace(',', '.')), float(r['lng'].replace(',', '.'))
                    if not (-35.1 < lat < -30 and -58.5 < lng < -53):
                        raise ValueError('lat/lng fuera de Uruguay (¿están invertidas?)')
                    ubicacion = f'SRID=4326;POINT({lng} {lat})'
                for campo in ('telefono', 'whatsapp'):
                    if r[campo] and not TELEFONO.match(r[campo]):
                        raise ValueError(f'{campo} inválido')
                if r['web'] and not r['web'].startswith('https://'):
                    raise ValueError('la web tiene que empezar con https://')
                ids = []
                for e in filter(None, (x.strip().lower() for x in r['especies'].split(','))):
                    if e not in especies:
                        raise ValueError(f'especie desconocida "{e}"')
                    ids.append(especies[e])
                es_24h = si(r['24h'])
                fila = {
                    'business_type': rubro,
                    'kind': modalidad,
                    'name': r['nombre'],
                    'address': r['direccion'] or None,
                    'description': r['descripcion'] or None,
                    'location': ubicacion,
                    'phone': r['telefono'] or None,
                    'whatsapp': r['whatsapp'] or None,
                    'web': r['web'] or None,
                    'instagram': r['instagram'].lstrip('@') or None,
                    'hours': {} if es_24h else horario(r['horario']),
                    'is_24h': es_24h,
                    'emergencies': si(r['urgencias']) or es_24h,
                    'species_ids': ids,
                    'is_sample': ejemplo,
                }
                if len(fila['name']) < 2:
                    raise ValueError('falta el nombre')
                if not es_24h and not fila['hours'] and modalidad == 'local':
                    raise ValueError('falta el horario (o marcar 24h)')
                filas.append(fila)
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

    # La clave secreta se pide en el momento y no se guarda en ningún lado.
    _, claves = pedir('GET', f'https://api.supabase.com/v1/projects/{ref}/api-keys?reveal=true',
                      headers={'Authorization': f'Bearer {os.environ["SUPABASE_ACCESS_TOKEN"]}'})
    secreta = next(c['api_key'] for c in claves if c.get('type') == 'secret' or c.get('name') == 'service_role')
    admin = {'apikey': secreta, 'Authorization': f'Bearer {secreta}'}

    _, especies = pedir('GET', f'{url}/rest/v1/species?select=id,name', headers=admin)
    _, zonas = pedir('GET', f'{url}/rest/v1/zones?select=id&slug=eq.pando', headers=admin)
    filas, errores = filas_del_csv(argumentos[0], {e['name'].lower(): e['id'] for e in especies}, ejemplo)
    if errores:
        sys.exit('Hay errores en la planilla:\n' + '\n'.join(errores))
    for f in filas:
        f['zone_id'] = zonas[0]['id'] if zonas else None

    tipo = 'de ejemplo' if ejemplo else 'reales'
    print(f'{len(filas)} comercios {tipo} válidos:')
    for f in filas:
        marca = '24 h' if f['is_24h'] else ('urgencias' if f['emergencies'] else '')
        extra = ', '.join(x for x in (f['business_type'], f['kind'] if f['kind'] != 'local' else '', marca) if x)
        print(f"  - {f['name']} ({extra})")
    if not aplicar:
        print('\nNo se cambió nada. Para cargarlas, repetir con --aplicar.')
        return

    def ok(respuesta, que):
        s, r = respuesta
        if s not in (200, 201, 204):
            sys.exit(f'No se pudo {que}: {s} {r}')

    # Las de ejemplo no tienen historia: se borran siempre.
    ok(pedir('DELETE', f'{url}/rest/v1/businesses?is_sample=eq.true', headers=admin),
       'borrar los de ejemplo')
    if ejemplo:
        ok(pedir('POST', f'{url}/rest/v1/businesses', filas, {**admin, 'Prefer': 'return=minimal'}), 'cargar')
        print(f'\n✅ Cargados {len(filas)} comercios de ejemplo.')
        return

    # Reales: por rubro y nombre, para conservar el id (y las métricas de cada uno).
    _, existentes = pedir('GET', f'{url}/rest/v1/businesses?select=id,name,business_type&is_sample=eq.false',
                          headers=admin)
    por_nombre = {(e['business_type'], e['name'].strip().lower()): e['id'] for e in existentes}
    nuevas, actualizadas = [], 0
    for f in filas:
        existente = por_nombre.pop((f['business_type'], f['name'].strip().lower()), None)
        if existente:
            ok(pedir('PATCH', f'{url}/rest/v1/businesses?id=eq.{existente}', {**f, 'status': 'active'},
                     {**admin, 'Prefer': 'return=minimal'}), f"actualizar {f['name']}")
            actualizadas += 1
        else:
            nuevas.append(f)
    if nuevas:
        ok(pedir('POST', f'{url}/rest/v1/businesses', nuevas, {**admin, 'Prefer': 'return=minimal'}), 'cargar las nuevas')
    for (_, nombre), id_ in por_nombre.items():
        ok(pedir('PATCH', f'{url}/rest/v1/businesses?id=eq.{id_}', {'status': 'hidden'},
                 {**admin, 'Prefer': 'return=minimal'}), f'ocultar {nombre}')
    print(f'\n✅ {len(nuevas)} nuevas, {actualizadas} actualizadas, {len(por_nombre)} ocultadas '
          '(ya no figuran en la planilla). Las de ejemplo se borraron.')


if __name__ == '__main__':
    main()
