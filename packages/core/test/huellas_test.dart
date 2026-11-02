import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee las ayudas y solo las insignias ganadas', () {
    final h = Huellas.fromJson({
      'ayudas': 7,
      'insignias': {
        'perfil': true,
        'libreta': false,
        'chapita': true,
        'difusor': false,
        'respuesta': false,
        'reencuentro': false,
        'otra_que_no_existe': true,
      },
    });
    expect(h.ayudas, 7);
    expect(h.ganadas, {Insignia.perfil, Insignia.chapita});
  });

  test('sin datos queda en cero', () {
    final h = Huellas.fromJson(const {});
    expect(h.ayudas, 0);
    expect(h.ganadas, isEmpty);
  });
}
