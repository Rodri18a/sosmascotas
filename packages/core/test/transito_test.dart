import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('mi hogar de tránsito va y vuelve de la base', () {
    const hogar = HogarTransito(
      especies: [1, 2],
      tamanos: ['chico'],
      maxDias: 15,
      patio: true,
      barrio: '  Centro ',
      notas: '   ',
    );
    final json = hogar.toJson();
    expect(json, {
      'species_ids': [1, 2],
      'sizes': ['chico'],
      'max_days': 15,
      'has_yard': true,
      'other_pets': false,
      'neighborhood': 'Centro',
      'notes': null,
      'active': true,
    });
    final vuelta = HogarTransito.fromJson(json);
    expect(vuelta.especies, [1, 2]);
    expect(vuelta.barrio, 'Centro');
    expect(vuelta.activo, isTrue);
  });

  test(
    'el refugio ve el hogar con el primer nombre y si ya tiene un animal',
    () {
      final h = HogarDisponible.fromJson({
        'id': 'u1',
        'nombre': 'Ana',
        'barrio': 'Centro',
        'species_ids': [1],
        'sizes': ['chico', 'mediano'],
        'max_days': 30,
        'has_yard': true,
        'con_animal': true,
      });
      expect(h.nombre, 'Ana');
      expect(h.tamanos, ['chico', 'mediano']);
      expect(h.conAnimal, isTrue);
      expect(h.pedidoAbierto, isFalse);
    },
  );

  test('un pedido de tránsito, con estado y chat', () {
    final p = PedidoTransito.fromJson({
      'id': 'p1',
      'animal_name': 'Luna',
      'species_id': 1,
      'size': 'chico',
      'days': 15,
      'status': 'accepted',
      'created_at': '2026-10-26T12:00:00Z',
      'shelter_name': 'Refugio Pando',
      'conversation_id': 'c1',
    });
    expect(p.estado, EstadoTransito.aceptado);
    expect(p.estado.abierto, isTrue);
    expect(p.refugio, 'Refugio Pando');
    expect(p.conversacionId, 'c1');
    expect(EstadoTransito.leer('finished').abierto, isFalse);
    expect(EstadoTransito.leer('raro'), EstadoTransito.cancelado);
  });

  test('un animal en adopción dice si está en tránsito', () {
    final a = AnimalAdopcion.fromJson({
      'animal_id': 'a1',
      'adoption_id': 'd1',
      'species_id': 1,
      'photos': ['x.jpg'],
      'in_foster': true,
    });
    expect(a.enTransito, isTrue);
  });

  test('un beneficio del pack con el código de quien adoptó', () {
    final b = BeneficioAdopcion.fromJson({
      'id': 'b1',
      'title': 'Kit de bienvenida',
      'business_name': 'Pet Shop Pando',
      'valid_until': '2026-12-31',
      'code': 'K7M2QX',
      'used': false,
    });
    expect(b.negocio, 'Pet Shop Pando');
    expect(b.vigenteHasta, DateTime(2026, 12, 31));
    expect(b.codigo, 'K7M2QX');
    expect(b.usado, isFalse);
    expect(b.activo, isTrue);
  });

  test('apadrinamiento: lo del negocio con refugios, eventos y padrinos', () {
    final d = DatosApadrinamiento.fromJson({
      'es_refugio': false,
      'puede_ofrecer': true,
      'ofrecidos': [
        {
          'id': 'a1',
          'status': 'active',
          'contribution': 'Alimento',
          'otro': 'Refugio Pando',
          'evento': 'Feria',
        },
      ],
      'refugios': [
        {
          'id': 'r1',
          'name': 'Refugio Pando',
          'eventos': [
            {'id': 'e1', 'title': 'Feria', 'starts_at': '2026-11-08T13:00:00Z'},
          ],
        },
      ],
    });
    expect(d.puedeOfrecer, isTrue);
    expect(d.ofrecidos.single.estado, EstadoApadrinamiento.activo);
    expect(d.ofrecidos.single.evento, 'Feria');
    expect(d.refugios.single.eventos.single.titulo, 'Feria');
    expect(
      Padrino.fromJson({'name': 'Pet Shop', 'contribution': 'Kit'}).aporte,
      'Kit',
    );
    expect(EstadoApadrinamiento.leer('raro'), EstadoApadrinamiento.terminado);
  });
}
