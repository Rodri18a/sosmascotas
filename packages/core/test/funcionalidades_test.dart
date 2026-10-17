import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('da la misma cubeta que public.cubeta_funcionalidad() en la base', () {
    // Valores de md5('clave:id') (16/10/2026). rls_test.py comprueba que la
    // base calcula igual que esta fórmula; si cambia uno, cambian los dos.
    const casos = [
      ('temas_pro', '00000000-0000-0000-0000-000000000000', 78),
      ('temas_pro', '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b', 49),
      ('chat', '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b', 83),
      ('resenas', 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d', 2),
      ('chat', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 83),
    ];
    for (final (clave, id, cubeta) in casos) {
      expect(cubetaFuncionalidad(clave, id), cubeta, reason: '$clave:$id');
    }
  });

  test('la cubeta está siempre entre 0 y 99 y se reparte parejo', () {
    final cuenta = List.filled(10, 0);
    for (var i = 0; i < 5000; i++) {
      final c = cubetaFuncionalidad('chat', 'id-$i');
      expect(c, inInclusiveRange(0, 99));
      cuenta[c ~/ 10]++;
    }
    for (final n in cuenta) {
      expect(n, inInclusiveRange(400, 600)); // ~500 por decena
    }
  });

  test('al subir el porcentaje nadie pierde la funcionalidad', () {
    final ids = [for (var i = 0; i < 300; i++) 'id-$i'];
    final con10 = ids.where((x) => entraEnPorcentaje('chat', x, 10)).toSet();
    final con30 = ids.where((x) => entraEnPorcentaje('chat', x, 30)).toSet();
    expect(con30.containsAll(con10), isTrue);
    expect(con30.length, greaterThan(con10.length));
    expect(ids.where((x) => entraEnPorcentaje('chat', x, 0)), isEmpty);
    expect(ids.every((x) => entraEnPorcentaje('chat', x, 100)), isTrue);
  });

  test(
    'cada funcionalidad reparte distinto (no siempre las mismas personas)',
    () {
      final ids = [for (var i = 0; i < 300; i++) 'id-$i'];
      final chat = ids.where((x) => entraEnPorcentaje('chat', x, 20)).toSet();
      final resenas = ids
          .where((x) => entraEnPorcentaje('resenas', x, 20))
          .toSet();
      expect(chat, isNot(resenas));
    },
  );

  test('los nombres cumplen la regla de la base', () {
    expect(nombreDeFuncionalidadValido(Funcionalidades.temasPro), isTrue);
    expect(nombreDeFuncionalidadValido('Chat'), isFalse);
    expect(nombreDeFuncionalidadValido('ab'), isFalse);
    expect(nombreDeFuncionalidadValido('1chat'), isFalse);
    expect(nombreDeFuncionalidadValido('chat-nuevo'), isFalse);
  });
}
