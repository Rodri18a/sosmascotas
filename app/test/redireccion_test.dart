import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/redireccion.dart';

void main() {
  group('redirigir', () {
    test('la raíz lleva al mapa', () {
      expect(redirigir(conectado: false, uri: Uri.parse('/')), '/noticias');
    });

    test('las pestañas se ven sin cuenta', () {
      expect(redirigir(conectado: false, uri: Uri.parse('/sos')), isNull);
    });

    test('con sesión, la pantalla de ingreso vuelve a la acción', () {
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/ingresar?volver=%2Fajustes'),
        ),
        '/ajustes',
      );
    });

    test('sin sesión, se queda en la pantalla de ingreso', () {
      expect(
        redirigir(conectado: false, uri: Uri.parse('/ingresar?volver=/sos')),
        isNull,
      );
    });
  });

  group('volverSeguro', () {
    test('acepta rutas internas', () {
      expect(volverSeguro('/mascotas'), '/mascotas');
    });

    test('rechaza otros sitios y bucles', () {
      expect(volverSeguro('https://malo.com'), '/noticias');
      expect(volverSeguro('//malo.com'), '/noticias');
      expect(volverSeguro('/ingresar?volver=/x'), '/noticias');
      expect(volverSeguro(null), '/noticias');
    });
  });
}
