import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('un pedido de Mis cuidados y cuándo se puede cancelar', () {
    final c = Cuidado.fromJson({
      'id': 'c1',
      'business_id': 'b1',
      'business_name': 'Hotel Canino',
      'kind': 'boarding',
      'start_day': '2026-12-24',
      'end_day': '2026-12-26',
      'time_slot': null,
      'pets': ['Luna', 'Rocco'],
      'status': 'accepted',
      'conversation_id': 'chat1',
    });
    expect(c.tipo, TipoCuidado.estadia);
    expect(c.tipo.ocupaLugar, isTrue);
    expect(c.dias, 3);
    expect(c.mascotas, ['Luna', 'Rocco']);
    expect(c.chatId, 'chat1');
    expect(c.puedeCancelar(DateTime(2026, 12, 23, 22)), isTrue);
    expect(c.puedeCancelar(DateTime(2026, 12, 24, 8)), isFalse);
    expect(c.puedeTerminar(DateTime(2026, 12, 23)), isFalse);
    expect(c.puedeTerminar(DateTime(2026, 12, 24, 10)), isTrue);
  });

  test('un pendiente se cancela siempre y no se termina', () {
    final c = Cuidado.fromJson({
      'id': 'c2',
      'cliente': 'Ana',
      'kind': 'walk',
      'start_day': '2026-10-28',
      'end_day': '2026-10-28',
      'time_slot': 'morning',
      'pets': ['Luna (Perro)'],
      'status': 'pending',
    });
    expect(c.franja, FranjaCuidado.manana);
    expect(c.tipo.ocupaLugar, isFalse);
    expect(c.puedeCancelar(DateTime(2026, 10, 28, 12)), isTrue);
    expect(c.puedeTerminar(DateTime(2026, 10, 28, 12)), isFalse);
  });

  test('las condiciones revisan las fechas antes de pedir', () {
    final c = CondicionesCuidados.fromJson({
      'kinds': ['boarding', 'walk', 'cria'],
      'days_ahead': 30,
      'max_days': 5,
      'conditions': 'Vacunas al día',
      'completos': ['2026-11-03'],
    });
    final hoy = DateTime(2026, 10, 28, 15);
    expect(c.tipos, [TipoCuidado.estadia, TipoCuidado.paseo]);
    expect(
      c.revisar(
        TipoCuidado.estadia,
        DateTime(2026, 11),
        DateTime(2026, 11, 2),
        hoy,
      ),
      isNull,
    );
    expect(
      c.revisar(
        TipoCuidado.estadia,
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 4),
        hoy,
      ),
      ProblemaFechas.sinLugar,
    );
    // El paseo no ocupa lugar.
    expect(
      c.revisar(
        TipoCuidado.paseo,
        DateTime(2026, 11, 3),
        DateTime(2026, 11, 3),
        hoy,
      ),
      isNull,
    );
    expect(
      c.revisar(
        TipoCuidado.estadia,
        DateTime(2026, 11),
        DateTime(2026, 11, 6),
        hoy,
      ),
      ProblemaFechas.muyLargo,
    );
    expect(
      c.revisar(
        TipoCuidado.paseo,
        DateTime(2026, 10, 27),
        DateTime(2026, 10, 28),
        hoy,
      ),
      ProblemaFechas.fueraDeRango,
    );
    expect(
      c.revisar(TipoCuidado.paseo, DateTime(2026, 12), DateTime(2026, 12), hoy),
      ProblemaFechas.fueraDeRango,
    );
  });

  test('los ajustes del prestador van y vuelven', () {
    final a = AjustesCuidados.fromJson({
      'kinds': ['daycare'],
      'capacity': 8,
      'days_ahead': 60,
      'max_days': 15,
      'conditions': null,
    });
    final b = a.copyWith(tipos: {...a.tipos, TipoCuidado.visitas}, cupo: 10);
    expect(b.toJson(), {
      'kinds': ['daycare', 'home_visit'],
      'capacity': 10,
      'days_ahead': 60,
      'max_days': 15,
      'conditions': null,
    });
    expect(fechaCuidado(DateTime(2026, 1, 5)), '2026-01-05');
  });
}
