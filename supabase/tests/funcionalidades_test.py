#!/usr/bin/env python3
"""Pruebas de supabase/funcionalidades.py que no necesitan la base.

Uso: python3 -I supabase/tests/funcionalidades_test.py
"""
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
import funcionalidades as f  # noqa: E402


class Pruebas(unittest.TestCase):
    def test_clave(self):
        self.assertEqual(f.validar_clave('temas_pro'), 'temas_pro')
        for mala in ('Temas', 'ab', '1chat', 'chat-nuevo', "x'; drop"):
            with self.assertRaises(f.ErrorDeUso):
                f.validar_clave(mala)

    def test_etapa_y_porcentaje(self):
        self.assertEqual(f.cambio_de('etapa', ['chat', 'beta']), {'stage': 'beta'})
        self.assertEqual(f.cambio_de('porcentaje', ['chat', '30']), {'rollout_percent': 30})
        for args in (['chat', 'casi'], ['chat']):
            with self.assertRaises(f.ErrorDeUso):
                f.cambio_de('etapa', args)
        for valor in ('101', '-1', 'diez'):
            with self.assertRaises(f.ErrorDeUso):
                f.cambio_de('porcentaje', ['chat', valor])

    def test_apagado_de_emergencia(self):
        self.assertEqual(f.cambio_de('apagar', ['chat']), {'killed': True})
        self.assertEqual(f.cambio_de('prender', ['chat']), {'killed': False})

    def test_reglas(self):
        self.assertEqual(f.regla_a_columna('zonas', '1,2'), ('zone_ids', [1, 2]))
        self.assertEqual(f.regla_a_columna('planes', 'pro,family'), ('plans', ['pro', 'family']))
        self.assertEqual(f.regla_a_columna('plataformas', 'web'), ('platforms', ['web']))
        self.assertEqual(f.regla_a_columna('version-minima', '1.2.0'), ('min_app_version', '1.2.0'))
        self.assertEqual(f.regla_a_columna('visitantes', 'si'), ('allow_anonymous', True))
        self.assertEqual(f.regla_a_columna('planes', '-'), ('plans', None))
        self.assertEqual(
            f.regla_a_columna('desde', '2026-12-24T00:00-03:00'),
            ('starts_at', '2026-12-24T00:00:00-03:00'))

    def test_reglas_invalidas(self):
        for regla, valor in (('planes', 'gold'), ('zonas', 'pando'), ('zonas', '0'),
                             ('roles', 'dueño'), ('version-minima', '1.x'),
                             ('visitantes', 'tal vez'), ('desde', '2026-12-24'),
                             ('hasta', 'mañana'), ('color', 'rojo')):
            with self.subTest(regla=regla, valor=valor), self.assertRaises(f.ErrorDeUso):
                f.regla_a_columna(regla, valor)

    def test_describir(self):
        fila = {'key': 'chat', 'stage': 'gradual', 'killed': False, 'rollout_percent': 30,
                'plans': ['pro'], 'allow_anonymous': False}
        texto = f.describir(fila, 2, 1)
        self.assertIn('gradual 30 %', texto)
        self.assertIn('2 invitada(s), 1 excluida(s)', texto)
        self.assertIn('planes=pro', texto)
        self.assertIn('APAGADA', f.describir({**fila, 'killed': True}))

    def test_sin_aplicar_valida_antes_de_conectarse(self):
        # Un error de uso sale antes de pedir credenciales (no hay red en la prueba).
        with self.assertRaises(f.ErrorDeUso):
            f.main(['porcentaje', 'chat', '200'])
        with self.assertRaises(f.ErrorDeUso):
            f.main(['invitar', 'chat', 'no-es-un-correo'])


if __name__ == '__main__':
    unittest.main(verbosity=1)
