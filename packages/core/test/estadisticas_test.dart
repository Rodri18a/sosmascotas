import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  final json = <String, Object?>{
    'completo': true,
    'meses': [
      {
        'mes': '2026-09-01',
        'metricas': {'place_open': 200, 'contactos': 40},
      },
      {
        'mes': '2026-10-01',
        'metricas': {
          'place_open': 340,
          'contactos': 30,
          'place_click:whatsapp': 20,
          'place_click:como_llegar': 6,
          'chat_start': 4,
        },
      },
    ],
    'semanas': [
      {'semana': '2026-10-19', 'aperturas': 6, 'contactos': 5},
    ],
  };

  test('se lee lo que devuelve estadisticas_negocio()', () {
    final e = EstadisticasNegocio.fromJson(json);
    expect(e.completo, isTrue);
    expect(e.meses, hasLength(2));
    expect(e.actual!.mes, DateTime(2026, 10));
    expect(e.actual![MetricasComercio.aperturas], 340);
    expect(e.actual![MetricasComercio.favoritos], 0);
    expect(e.actual!.clics, {'whatsapp': 20, 'como_llegar': 6});
    expect(e.semanas.single.contactos, 5);
    expect(e.sinDatos, isFalse);
  });

  test('variación entre el mes anterior y el actual', () {
    final e = EstadisticasNegocio.fromJson(json);
    final aperturas = e.variacion(MetricasComercio.aperturas);
    expect(aperturas.sube, isTrue);
    expect(aperturas.porcentaje, 70);
    final contactos = e.variacion(MetricasComercio.contactos);
    expect(contactos.baja, isTrue);
    expect(contactos.porcentaje, -25);
    // Sin nada el mes anterior no hay porcentaje.
    expect(e.variacion(MetricasComercio.chats).porcentaje, isNull);
    expect(e.variacion(MetricasComercio.chats).sube, isTrue);
  });

  test('plan Básico y comercio sin movimiento', () {
    final e = EstadisticasNegocio.fromJson({
      'completo': false,
      'meses': [
        {'mes': '2026-10-01', 'metricas': <String, Object?>{}},
      ],
      'semanas': <Object?>[],
    });
    expect(e.completo, isFalse);
    expect(e.anterior, isNull);
    expect(e.sinDatos, isTrue);
    expect(e.variacion(MetricasComercio.aperturas).porcentaje, isNull);
  });
}
