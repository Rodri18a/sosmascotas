import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('se lee lo que devuelve mi_plan()', () {
    final p = MiPlan.fromJson({
      'plan': 'featured',
      'estado': 'past_due',
      'vence': '2026-11-25',
      'precio': '600.00',
      'moneda': 'UYU',
      'fundador': false,
      'socio_fundador_hasta': null,
      'pagos': [
        {'fecha': '2026-10-26', 'monto': 600, 'metodo': 'transfer', 'meses': 2},
      ],
      'pedido_abierto': false,
      'antes_despues': {
        'desde': '2026-10-01',
        'dias': 25,
        'aperturas_antes': 40,
        'aperturas_despues': 140,
        'contactos_antes': 2,
        'contactos_despues': 12,
      },
    });
    expect(p.plan, PlanComercio.featured);
    expect(p.esPago, isTrue);
    expect(p.estado, EstadoPlan.conAtraso);
    expect(p.precio, 600);
    expect(p.pagos.single.meses, 2);
    expect(p.antesYDespues!.aperturasDespues, 140);
    expect(p.diasParaVencer(DateTime(2026, 11, 20, 23, 59)), 5);
    expect(p.diasParaVencer(DateTime(2026, 11, 27)), -2);
  });

  test('plan Básico sin suscripción', () {
    final p = MiPlan.fromJson({'plan': 'basic', 'pagos': <Object?>[]});
    expect(p.esPago, isFalse);
    expect(p.estado, isNull);
    expect(p.diasParaVencer(DateTime(2026, 10, 26)), isNull);
    expect(p.antesYDespues, isNull);
  });
}
