import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('se lee lo que devuelve mi_plan_usuario()', () {
    final p = MiPlanUsuario.fromJson({
      'plan': 'family',
      'efectivo': 'family',
      'por_hogar': false,
      'estado': 'active',
      'vence': '2026-11-26',
      'prueba': true,
      'precio': '0.00',
      'mascotas': 6,
      'limite_mascotas': null,
      'prueba_familia_usada': true,
      'pedido_abierto': null,
    });
    expect(p.plan, Plan.family);
    expect(p.esPro, isTrue);
    expect(p.prueba, isTrue);
    expect(p.estado, EstadoPlan.activo);
    expect(p.vence, DateTime(2026, 11, 26));
    expect(p.puedeSumarMascota, isTrue);
  });

  test('Gratis con el tope de mascotas', () {
    final p = MiPlanUsuario.fromJson({
      'plan': 'free',
      'efectivo': 'free',
      'mascotas': 2,
      'limite_mascotas': 2,
      'pedido_abierto': 'pro',
    });
    expect(p.esPro, isFalse);
    expect(p.puedeSumarMascota, isFalse);
    expect(p.pedidoAbierto, Plan.pro);
    expect(p.estado, isNull);
  });

  test('Familia por integrar el hogar de otra persona', () {
    final p = MiPlanUsuario.fromJson({
      'plan': 'free',
      'efectivo': 'family',
      'por_hogar': true,
      'mascotas': 1,
    });
    expect(p.plan, Plan.free);
    expect(p.esPro, isTrue);
    expect(p.porHogar, isTrue);
  });
}
