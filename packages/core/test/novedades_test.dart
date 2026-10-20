import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee una novedad de reencuentro', () {
    final n = Novedad.fromJson({
      'id': 'n1',
      'kind': 'reencuentro',
      'name': 'Lola',
      'detail': 'lost',
      'species_id': 1,
      'amount': 3,
      'starts_at': null,
      'photo_path': 'sos-photos/u1/foto.jpg',
      'created_at': '2026-10-20T13:00:00+00:00',
    })!;
    expect(n.tipo, TipoNovedad.reencuentro);
    expect(n.eraPerdida, isTrue);
    expect(n.cantidad, 3);
    expect(n.fotoPath, 'sos-photos/u1/foto.jpg');
  });

  test('un tipo desconocido se saltea', () {
    expect(
      Novedad.fromJson({
        'id': 'n1',
        'kind': 'algo_nuevo',
        'created_at': '2026-10-20T13:00:00+00:00',
      }),
      isNull,
    );
  });

  test('rubro y tipo de evento', () {
    final comercio = Novedad.fromJson({
      'id': 'c',
      'kind': 'comercio',
      'detail': 'pet_friendly',
      'created_at': '2026-10-20T13:00:00+00:00',
    })!;
    expect(comercio.categoria, Categoria.petFriendly);
    expect(comercio.tipoEvento, isNull);
    final evento = Novedad.fromJson({
      'id': 'e',
      'kind': 'evento',
      'detail': 'castracion',
      'starts_at': '2026-10-25T12:00:00+00:00',
      'created_at': '2026-10-20T13:00:00+00:00',
    })!;
    expect(evento.tipoEvento, TipoEvento.castracion);
    expect(evento.desde, isNotNull);
  });

  test('filtro por especie: sin especie es para todas', () {
    final perro = Novedad(
      id: 'a',
      tipo: TipoNovedad.reencuentro,
      fecha: DateTime(2026),
      especieId: 1,
    );
    final lugar = Novedad(
      id: 'b',
      tipo: TipoNovedad.comercio,
      fecha: DateTime(2026),
    );
    expect(perro.esPara({}), isTrue);
    expect(perro.esPara({1}), isTrue);
    expect(perro.esPara({2}), isFalse);
    expect(lugar.esPara({2}), isTrue);
  });

  test('resumen vacío no se muestra', () {
    expect(const ResumenComunidad().vacio, isTrue);
    final r = ResumenComunidad.fromJson({
      'reencuentros': 2,
      'adopciones': 0,
      'perdidas_activas': 1,
      'lugares_verificados': 5,
    });
    expect(r.vacio, isFalse);
    expect(r.reencuentros, 2);
  });
}
