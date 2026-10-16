#!/usr/bin/env python3
"""Prende y apaga funcionalidades graduales desde la terminal (paso 0.8.0e, D64).

Hasta que exista la pantalla del portal de administración (Fase 1), esto es
lo que se usa para manejar `feature_flags` y `feature_flag_users`.
Ver docs/15-funcionalidades-graduales.md.

Uso (desde la raíz del repo, con las credenciales del proyecto vinculado):
    set -a; . ~/.config/sosmascotas/supabase-dev.env; set +a
    python3 -I supabase/funcionalidades.py listar
    python3 -I supabase/funcionalidades.py ver <clave>
    python3 -I supabase/funcionalidades.py crear <clave> "<descripción>"   [--aplicar]
    python3 -I supabase/funcionalidades.py etapa <clave> <etapa>           [--aplicar]
    python3 -I supabase/funcionalidades.py porcentaje <clave> <0-100>      [--aplicar]
    python3 -I supabase/funcionalidades.py regla <clave> <regla> <valor|->  [--aplicar]
    python3 -I supabase/funcionalidades.py apagar <clave>                  [--aplicar]
    python3 -I supabase/funcionalidades.py prender <clave>                 [--aplicar]
    python3 -I supabase/funcionalidades.py invitar <clave> <email>         [--aplicar]
    python3 -I supabase/funcionalidades.py excluir <clave> <email>         [--aplicar]
    python3 -I supabase/funcionalidades.py quitar <clave> <email>          [--aplicar]

Etapas: borrador → interna → beta → gradual → todos.
Reglas (solo cuentan en 'gradual'; '-' las borra):
    zonas 1,2 · planes pro,family · roles user,business · plataformas web,android,ios
    version-minima 1.2.0 · visitantes si|no · desde 2026-12-24T00:00-03:00 · hasta (igual)

'apagar' es el apagado de emergencia: gana sobre todo lo demás.
Sin --aplicar solo muestra qué cambiaría. Cada cambio queda en el historial
(`feature_flag_audit`, lo escribe un trigger).
"""
import datetime
import json
import os
import pathlib
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

ETAPAS = ('borrador', 'interna', 'beta', 'gradual', 'todos')
PLANES = ('free', 'pro', 'family', 'basic', 'featured', 'plus')
ROLES = ('user', 'business', 'admin')
PLATAFORMAS = ('web', 'android', 'ios')
CLAVE = re.compile(r'^[a-z][a-z0-9_]{2,40}$')
VERSION = re.compile(r'^[0-9]{1,4}(\.[0-9]{1,4}){0,3}$')
EMAIL = re.compile(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')


class ErrorDeUso(Exception):
    pass


def validar_clave(clave):
    if not CLAVE.match(clave):
        raise ErrorDeUso(f'Clave inválida "{clave}": minúsculas, números y _, de 3 a 41 caracteres.')
    return clave


def _lista(valor, permitidos, nombre):
    items = [v.strip() for v in valor.split(',') if v.strip()]
    if not items:
        raise ErrorDeUso(f'{nombre}: falta al menos un valor.')
    malos = [v for v in items if v not in permitidos]
    if malos:
        raise ErrorDeUso(f'{nombre}: {", ".join(malos)} no vale ({", ".join(permitidos)}).')
    return items


def _fecha(valor, nombre):
    try:
        f = datetime.datetime.fromisoformat(valor)
    except ValueError:
        raise ErrorDeUso(f'{nombre}: fecha inválida "{valor}" (por ejemplo 2026-12-24T00:00-03:00).') from None
    if f.tzinfo is None:
        raise ErrorDeUso(f'{nombre}: poné la zona horaria (por ejemplo -03:00 para Uruguay).')
    return f.isoformat()


def regla_a_columna(regla, valor):
    """Traduce una regla de la terminal a (columna, valor) de feature_flags."""
    borrar = valor == '-'
    if regla == 'zonas':
        if borrar:
            return 'zone_ids', None
        try:
            zonas = [int(z) for z in valor.split(',') if z.strip()]
        except ValueError:
            raise ErrorDeUso('zonas: números separados por coma (ids de la tabla zones).') from None
        if not zonas or any(z <= 0 for z in zonas):
            raise ErrorDeUso('zonas: números positivos separados por coma.')
        return 'zone_ids', zonas
    if regla == 'planes':
        return 'plans', None if borrar else _lista(valor, PLANES, 'planes')
    if regla == 'roles':
        return 'roles', None if borrar else _lista(valor, ROLES, 'roles')
    if regla == 'plataformas':
        return 'platforms', None if borrar else _lista(valor, PLATAFORMAS, 'plataformas')
    if regla == 'version-minima':
        if not borrar and not VERSION.match(valor):
            raise ErrorDeUso('version-minima: números separados por punto, por ejemplo 1.2.0.')
        return 'min_app_version', None if borrar else valor
    if regla == 'visitantes':
        if valor not in ('si', 'no'):
            raise ErrorDeUso('visitantes: si o no.')
        return 'allow_anonymous', valor == 'si'
    if regla in ('desde', 'hasta'):
        columna = 'starts_at' if regla == 'desde' else 'ends_at'
        return columna, None if borrar else _fecha(valor, regla)
    raise ErrorDeUso(f'Regla desconocida "{regla}" (zonas, planes, roles, plataformas, '
                     'version-minima, visitantes, desde, hasta).')


def cambio_de(comando, args):
    """Para los comandos que tocan feature_flags: el cambio a aplicar."""
    if comando == 'etapa':
        if len(args) != 2 or args[1] not in ETAPAS:
            raise ErrorDeUso(f'Uso: etapa <clave> <{"|".join(ETAPAS)}>')
        return {'stage': args[1]}
    if comando == 'porcentaje':
        if len(args) != 2 or not args[1].isdigit() or not 0 <= int(args[1]) <= 100:
            raise ErrorDeUso('Uso: porcentaje <clave> <0-100>')
        return {'rollout_percent': int(args[1])}
    if comando == 'regla':
        if len(args) != 3:
            raise ErrorDeUso('Uso: regla <clave> <regla> <valor|->')
        columna, valor = regla_a_columna(args[1], args[2])
        return {columna: valor}
    if comando == 'apagar':
        return {'killed': True}
    if comando == 'prender':
        return {'killed': False}
    raise ErrorDeUso(f'Comando desconocido "{comando}".')


def describir(f, invitadas=None, excluidas=0):
    estado = '🛑 APAGADA' if f['killed'] else f['stage']
    if f['stage'] == 'gradual' and not f['killed']:
        estado += f" {f['rollout_percent']} %"
    elif f.get('rollout_percent'):
        estado += f" ({f['rollout_percent']} % al pasar a gradual)"
    reglas = []
    for nombre, columna in (('zonas', 'zone_ids'), ('planes', 'plans'), ('roles', 'roles'),
                            ('plataformas', 'platforms')):
        if f.get(columna):
            reglas.append(f"{nombre}={','.join(str(v) for v in f[columna])}")
    if f.get('min_app_version'):
        reglas.append(f"versión≥{f['min_app_version']}")
    if f.get('allow_anonymous'):
        reglas.append('visitantes')
    if f.get('starts_at'):
        reglas.append(f"desde {f['starts_at']}")
    if f.get('ends_at'):
        reglas.append(f"hasta {f['ends_at']}")
    gente = '' if invitadas is None else (
        f'{invitadas} invitada(s)' + (f', {excluidas} excluida(s)' if excluidas else ''))
    return f"{f['key']:<24} {estado:<14} {gente:<26} {' · '.join(reglas)}".rstrip()


class Base:
    """REST de Supabase con la clave secreta (pedida en el momento, no se guarda)."""

    def __init__(self):
        raiz = pathlib.Path(__file__).resolve().parents[1]
        ref = (raiz / 'supabase/.temp/project-ref').read_text().strip()
        self.url = f'https://{ref}.supabase.co'
        _, claves = self._pedir(
            'GET', f'https://api.supabase.com/v1/projects/{ref}/api-keys?reveal=true',
            headers={'Authorization': f'Bearer {os.environ["SUPABASE_ACCESS_TOKEN"]}'})
        secreta = next(c['api_key'] for c in claves
                       if c.get('type') == 'secret' or c.get('name') == 'service_role')
        self.admin = {'apikey': secreta, 'Authorization': f'Bearer {secreta}'}

    @staticmethod
    def _pedir(metodo, destino, cuerpo=None, headers=None):
        req = urllib.request.Request(
            destino, method=metodo,
            data=json.dumps(cuerpo).encode() if cuerpo is not None else None,
            headers={'Content-Type': 'application/json', 'User-Agent': 'sosmascotas-funcionalidades',
                     **(headers or {})})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                texto = r.read().decode()
                return r.status, json.loads(texto) if texto else None
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode()

    def rest(self, metodo, ruta, cuerpo=None, prefer=None):
        headers = {**self.admin, **({'Prefer': prefer} if prefer else {})}
        estado, respuesta = self._pedir(metodo, f'{self.url}/rest/v1/{ruta}', cuerpo, headers)
        if estado not in (200, 201, 204):
            sys.exit(f'Supabase respondió {estado}: {str(respuesta)[:300]}')
        return respuesta

    def funcionalidad(self, clave):
        filas = self.rest('GET', f'feature_flags?select=*&key=eq.{urllib.parse.quote(clave)}')
        if not filas:
            sys.exit(f'No existe la funcionalidad "{clave}". Ver: listar')
        return filas[0]

    def usuario_por_email(self, email):
        email = email.strip().lower()
        pagina = 1
        while True:
            estado, datos = self._pedir(
                'GET', f'{self.url}/auth/v1/admin/users?page={pagina}&per_page=200', headers=self.admin)
            if estado != 200:
                sys.exit(f'No se pudo buscar la cuenta: {estado}')
            usuarios = datos.get('users', [])
            for u in usuarios:
                if (u.get('email') or '').lower() == email:
                    return u['id']
            if len(usuarios) < 200:
                sys.exit(f'No hay ninguna cuenta con el correo {email}.')
            pagina += 1


def main(argv):
    aplicar = '--aplicar' in argv
    args = [a for a in argv if a != '--aplicar']
    if not args or args[0] in ('-h', '--help', 'ayuda'):
        print(__doc__)
        return
    comando, resto = args[0], args[1:]
    if comando != 'listar':
        if not resto:
            raise ErrorDeUso(f'Falta la clave. {__doc__}')
        validar_clave(resto[0])

    # Validar todo antes de conectarse.
    cambio = None
    if comando in ('etapa', 'porcentaje', 'regla', 'apagar', 'prender'):
        cambio = cambio_de(comando, resto)
    elif comando == 'crear':
        if len(resto) != 2 or not 3 <= len(resto[1].strip()) <= 300:
            raise ErrorDeUso('Uso: crear <clave> "<descripción de 3 a 300 caracteres>"')
    elif comando in ('invitar', 'excluir', 'quitar'):
        if len(resto) != 2 or not EMAIL.match(resto[1]):
            raise ErrorDeUso(f'Uso: {comando} <clave> <email>')
    elif comando not in ('listar', 'ver'):
        raise ErrorDeUso(f'Comando desconocido "{comando}". {__doc__}')

    base = Base()

    if comando == 'listar':
        flags = base.rest('GET', 'feature_flags?select=*&order=key')
        gente = base.rest('GET', 'feature_flag_users?select=flag_key,enabled')
        for f in flags:
            inv = sum(1 for g in gente if g['flag_key'] == f['key'] and g['enabled'])
            exc = sum(1 for g in gente if g['flag_key'] == f['key'] and not g['enabled'])
            print(describir(f, inv, exc))
        if not flags:
            print('Todavía no hay funcionalidades.')
        return

    clave = resto[0]

    if comando == 'ver':
        f = base.funcionalidad(clave)
        gente = base.rest('GET', f'feature_flag_users?select=user_id,enabled&flag_key=eq.{clave}')
        print(describir(f, sum(g['enabled'] for g in gente), sum(not g['enabled'] for g in gente)))
        print(f"  {f['description']}")
        historial = base.rest(
            'GET', f'feature_flag_audit?select=tabla,before,after,created_at&flag_key=eq.{clave}'
                   '&order=created_at.desc&limit=10')
        if historial:
            print('  Últimos cambios:')
            for h in historial:
                antes, despues = h['before'] or {}, h['after'] or {}
                cambios = {k: v for k, v in despues.items()
                           if antes.get(k) != v and k not in ('updated_at', 'created_at')}
                que = ('alta' if not antes else 'baja' if not despues
                       else json.dumps(cambios, ensure_ascii=False) if cambios else 'sin cambios')
                print(f"   {h['created_at'][:16]}  {h['tabla']}: {que}")
        return

    if comando == 'crear':
        fila = {'key': clave, 'description': resto[1].strip(), 'stage': 'borrador'}
        print(f'Crear "{clave}" en borrador: {fila["description"]}')
        if aplicar:
            base.rest('POST', 'feature_flags', fila, 'return=minimal')
            print('✅ Creada. Agregá también la constante en packages/core (Funcionalidades).')
        else:
            print('No se cambió nada. Para aplicarlo, repetir con --aplicar.')
        return

    if cambio is not None:
        f = base.funcionalidad(clave)
        print('Antes:   ' + describir(f))
        print('Después: ' + describir({**f, **cambio}))
        if cambio.get('stage') == 'todos':
            print('ℹ️  Cuando esté en todos, sumala a Funcionalidades.prendidasPorDefecto (packages/core).')
        if cambio.get('stage') == 'gradual' and not f['rollout_percent']:
            print('ℹ️  Con 0 % no le llega a nadie: después, porcentaje <clave> <n>.')
        if aplicar:
            base.rest('PATCH', f'feature_flags?key=eq.{clave}', cambio, 'return=minimal')
            print('✅ Aplicado. La app lo toma al abrir, al volver a ella o en menos de 3 h.')
        else:
            print('No se cambió nada. Para aplicarlo, repetir con --aplicar.')
        return

    # invitar / excluir / quitar
    base.funcionalidad(clave)
    email = resto[1]
    usuario = base.usuario_por_email(email)
    if comando == 'quitar':
        print(f'Quitar a {email} de la lista de "{clave}" (vuelve a decidir la etapa).')
        if aplicar:
            base.rest('DELETE', f'feature_flag_users?flag_key=eq.{clave}&user_id=eq.{usuario}')
    else:
        habilitada = comando == 'invitar'
        print(f'{"Invitar" if habilitada else "Excluir"} a {email} en "{clave}".')
        if aplicar:
            base.rest('POST', 'feature_flag_users?on_conflict=flag_key,user_id',
                      {'flag_key': clave, 'user_id': usuario, 'enabled': habilitada},
                      'resolution=merge-duplicates,return=minimal')
    print('✅ Aplicado.' if aplicar else 'No se cambió nada. Para aplicarlo, repetir con --aplicar.')


if __name__ == '__main__':
    try:
        main(sys.argv[1:])
    except ErrorDeUso as e:
        sys.exit(str(e))
