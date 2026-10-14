import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('nombreDeEventoValido', () {
    test('acepta nombres en minúscula con guion bajo', () {
      expect(nombreDeEventoValido(Eventos.appOpen), isTrue);
      expect(nombreDeEventoValido('place_click'), isTrue);
    });

    test('rechaza mayúsculas, espacios y nombres vacíos o largos', () {
      expect(nombreDeEventoValido('AppOpen'), isFalse);
      expect(nombreDeEventoValido('app open'), isFalse);
      expect(nombreDeEventoValido(''), isFalse);
      expect(nombreDeEventoValido('a' * 64), isFalse);
    });
  });

  group('generarAnonId', () {
    final formatoV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    test('genera un UUID v4 válido', () {
      expect(generarAnonId(), matches(formatoV4));
      expect(generarAnonId(Random(1)), matches(formatoV4));
    });

    test('no se repite', () {
      expect(generarAnonId(), isNot(generarAnonId()));
    });
  });
}
