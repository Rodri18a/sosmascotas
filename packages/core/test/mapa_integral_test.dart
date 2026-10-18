import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Sábado 17/10/2026 a las 10:20 en Uruguay.
final _sabado = DateTime.utc(2026, 10, 17, 13, 20);

Comercio _c(
  String id, {
  String tipo = 'vet',
  Punto? punto = const Punto(-34.7171, -55.9581),
  Map<String, Object?> horas = const {},
  Map<String, Object?> especiales = const {},
  List<int> especies = const [],
  bool renac = false,
  bool es24h = false,
}) => Comercio(
  id: id,
  nombre: id,
  tipo: tipo,
  punto: punto,
  horario: Horario.conEspeciales(horas, especiales),
  especieIds: especies,
  operadorRenac: renac,
  es24h: es24h,
);

const _abiertoSabado = {
  'sat': [
    ['09:00', '13:00'],
  ],
};

void main() {
  group('rubros', () {
    test('lee el rubro y la modalidad', () {
      final c = Comercio.fromJson({
        'id': 'x',
        'name': 'Paseos',
        'business_type': 'walker',
        'kind': 'domicilio',
        'hours': {},
        'renac_operator': false,
      });
      expect(c.categoria, Categoria.walker);
      expect(c.modalidad, Modalidad.domicilio);
      expect(c.punto, isNull);
      expect(c.pin, isNull);
      expect(Categoria.leer('pet_friendly'), Categoria.petFriendly);
    });

    test('color del pin por rubro', () {
      expect(_c('a').pin!.tipo, TipoPin.veterinaria);
      expect(_c('b', es24h: true).pin!.tipo, TipoPin.urgencia);
      expect(_c('c', tipo: 'pet_friendly').pin!.tipo, TipoPin.aceptaMascotas);
      expect(_c('d', tipo: 'petshop').pin!.tipo, TipoPin.comercio);
    });
  });

  group('días especiales', () {
    test('un feriado cerrado le gana al horario del día', () {
      final normal = _c('a', horas: _abiertoSabado);
      final feriado = _c(
        'b',
        horas: _abiertoSabado,
        especiales: {'2026-10-17': <Object>[]},
      );
      expect(normal.estadoEn(_sabado).abierto, isTrue);
      expect(feriado.estadoEn(_sabado).abierto, isFalse);
    });

    test('un día especial con horario propio', () {
      final c = _c(
        'a',
        especiales: {
          '2026-10-17': [
            ['10:00', '12:00'],
          ],
        },
      );
      expect(c.estadoEn(_sabado), const EstadoApertura.abierto(cierra: 720));
    });
  });

  group('filtros', () {
    final cerca = _c('cerca', horas: _abiertoSabado, especies: [1]);
    final lejos = _c(
      'lejos',
      tipo: 'petshop',
      punto: const Punto(-34.75, -55.99),
      especies: [2],
      renac: true,
    );
    final todos = [cerca, lejos];
    const centro = Punto(-34.7171, -55.9581);

    List<String> ids(
      FiltrosMapa f, {
      Set<String> favs = const {},
      Set<int> esp = const {},
    }) => filtrarComercios(
      todos,
      f,
      ahora: _sabado,
      desde: centro,
      favoritos: favs,
      especies: esp,
    ).map((c) => c.id).toList();

    test('sin filtros, todo', () {
      expect(ids(const FiltrosMapa()), ['cerca', 'lejos']);
      expect(const FiltrosMapa().activos, 0);
    });

    test('por rubro, distancia, abierto, favoritos y microchip', () {
      expect(ids(const FiltrosMapa(categorias: {Categoria.petshop})), [
        'lejos',
      ]);
      expect(ids(const FiltrosMapa(distancia: Distancia.m800)), ['cerca']);
      expect(ids(const FiltrosMapa(abiertoAhora: true)), ['cerca']);
      expect(ids(const FiltrosMapa(soloFavoritos: true), favs: {'lejos'}), [
        'lejos',
      ]);
      expect(ids(const FiltrosMapa(colocaMicrochip: true)), ['lejos']);
    });

    test('regla de especie: atiende a mi mascota o a todas', () {
      expect(ids(const FiltrosMapa(), esp: {1}), ['cerca']);
      expect(ids(const FiltrosMapa(), esp: {1, 2}), ['cerca', 'lejos']);
      expect(coincideConEspecies(_c('sin especies'), {7}), isTrue);
    });
  });

  test('lista: abiertos, sin horario, cerrados; y por cercanía', () {
    final orden = ordenarParaLista(
      [
        _c(
          'cerrado',
          horas: const {
            'mon': [
              ['09:00', '10:00'],
            ],
          },
        ),
        _c('sin horario lejos', punto: const Punto(-34.80, -56.0)),
        _c('sin horario cerca'),
        _c('abierto', horas: _abiertoSabado, punto: const Punto(-34.80, -56.0)),
      ],
      ahora: _sabado,
      desde: const Punto(-34.7171, -55.9581),
    );
    expect(orden.map((c) => c.id), [
      'abierto',
      'sin horario cerca',
      'sin horario lejos',
      'cerrado',
    ]);
  });

  group('grupos de pines', () {
    const visible = Limites(
      minLat: -34.8,
      minLng: -56.0,
      maxLat: -34.6,
      maxLng: -55.9,
    );
    Pin p(
      String id,
      double lat,
      double lng, [
      TipoPin tipo = TipoPin.comercio,
    ]) => Pin(id: id, tipo: tipo, punto: Punto(lat, lng));

    test('junta 3 o más en la misma celda y deja los SOS sueltos', () {
      final pins = [
        p('a', -34.701, -55.951),
        p('b', -34.702, -55.952),
        p('c', -34.703, -55.953),
        p('sola', -34.79, -55.99),
        p('sos', -34.702, -55.952, TipoPin.perdido),
      ];
      final resultado = agruparPins(pins, visible);
      final grupo = resultado.singleWhere((x) => x.tipo == TipoPin.grupo);
      expect(grupo.cantidad, 3);
      expect(resultado.map((x) => x.id), containsAll(['sola', 'sos']));
      expect(resultado.last.id, 'sos');
    });

    test('con pocos, no junta nada', () {
      final pins = [p('a', -34.701, -55.951), p('b', -34.702, -55.952)];
      expect(agruparPins(pins, visible), pins);
    });
  });
}
