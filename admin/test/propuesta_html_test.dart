import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_admin/src/modelos.dart';
import 'package:sosmascota_admin/src/propuesta_html.dart';

void main() {
  final fecha = DateTime(2026, 10, 26);

  test('la propuesta para un comercio suma sus números y escapa el HTML', () {
    final html = htmlDePropuesta(
      const Propuesta({
        'rubro': 'vet',
        'dias': 30,
        'zona': 'Pando y alrededores',
        'audiencia': {
          'usuarios': 120,
          'activos': 40,
          'mascotas': [
            {'especie': 'Perro', 'cantidad': 80},
            {'especie': 'Gato', 'cantidad': null},
          ],
        },
        'demanda': {'busquedas': 0, 'sin_resultados': 0},
        'oferta': {'lugares': 3},
        'negocio': {'nombre': 'Vete <Pando>', 'aperturas': 14, 'contactos': 0},
        'casos': <Object?>[],
      }),
      fecha: fecha,
    );
    expect(html, contains('SOS Mascotas para Vete &lt;Pando&gt;'));
    expect(html, isNot(contains('<Pando>')));
    expect(html, contains('14</b>veces se abrió tu ficha'));
    // Lo que es cero no se muestra como destacado.
    expect(html, isNot(contains('búsquedas de')));
    expect(html, isNot(contains('contactos (WhatsApp')));
    expect(html, contains('120 personas con cuenta, 40 activas'));
    // Los grupos chicos no se muestran con el número.
    expect(html, contains('80 perro · menos de 5 gato'));
    expect(html, contains('26/10/2026'));
    expect(html, isNot(contains('Lo que dicen otros comercios')));
  });

  test('con casos de éxito, los cita', () {
    final html = htmlDePropuesta(
      const Propuesta({
        'rubro': 'petshop',
        'casos': [
          {
            'comercio': 'Pet Shop Luna',
            'cita': 'Nos llaman más.',
            'autor': 'Laura, dueña',
            'numeros': 'De 40 a 140 aperturas por mes',
          },
        ],
      }),
      fecha: fecha,
    );
    expect(html, contains('SOS Mascotas para Petshop'));
    expect(html, contains('todas las zonas'));
    expect(html, contains('«Nos llaman más.»'));
    expect(html, contains('Pet Shop Luna — Laura, dueña'));
    expect(html, contains('<strong>De 40 a 140 aperturas por mes</strong>'));
  });
}
