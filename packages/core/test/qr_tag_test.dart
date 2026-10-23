import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un QR de la base', () {
    final tag = QrTag.fromJson({
      'id': 't1',
      'code': 'K7M2QX9P',
      'active': true,
      'pet_id': 'p1',
      'public_note': null,
    });
    expect(tag.codigo, 'K7M2QX9P');
    expect(tag.activo, isTrue);
  });

  test('arma el enlace de la página del QR', () {
    expect(urlPaginaQr('K7M2QX9P'), 'https://sosmascotas.uy/m/K7M2QX9P');
    expect(
      urlPaginaQr('K7M2QX9P', base: 'http://localhost:3002/'),
      'http://localhost:3002/m/K7M2QX9P',
    );
  });

  test('lee el código de una chapita escrito a mano o desde el enlace', () {
    expect(codigoChapita('K7M2QX9P'), 'K7M2QX9P');
    expect(codigoChapita(' k7m2-qx9p '), 'K7M2QX9P');
    expect(codigoChapita('K7M2 QX9P'), 'K7M2QX9P');
    expect(codigoChapita('https://sosmascotas.uy/m/k7m2qx9p?x=1'), 'K7M2QX9P');
    expect(codigoChapita('K7M2QX9'), isNull, reason: 'faltan caracteres');
    expect(codigoChapita('K7M2QX9O'), isNull, reason: 'la O no se usa');
    expect(codigoChapita('K7M2QX91'), isNull, reason: 'el 1 no se usa');
    expect(codigoChapita(''), isNull);
  });
}
