import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/comercios/mis_lugares.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'filtros_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'plan_usuario_falso.dart';
import 'sos_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

// Lejos entre sí (dentro de Pando) para que no se agrupen.
const _vet = Comercio(
  id: 'vet',
  nombre: 'Veterinaria Gatuna',
  punto: Punto(-34.690, -55.990),
  horario: Horario({}),
  es24h: true,
  especieIds: [2],
);
const _petshop = Comercio(
  id: 'petshop',
  nombre: 'Petshop Perruno',
  tipo: 'petshop',
  punto: Punto(-34.740, -55.910),
  horario: Horario({
    0: [Franja(0, 1)],
  }),
  especieIds: [1],
  operadorRenac: true,
);
const _cafe = Comercio(
  id: 'cafe',
  nombre: 'Café Amigo',
  tipo: 'pet_friendly',
  punto: Punto(-34.740, -55.990),
  horario: Horario({}),
);
const _paseos = Comercio(
  id: 'paseos',
  nombre: 'Paseos a Domicilio',
  tipo: 'walker',
  modalidad: Modalidad.domicilio,
  horario: Horario({}),
);

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester, {
  required ComerciosFalsos comercios,
  bool completo = true,
  List<Mascota> mascotas = const [],
  MisLugaresFalsos? misLugares,
  List<Map<String, Object?>>? eventos,
  bool pro = false,
  AlmacenFiltrosFalso? almacenFiltros,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comercios: comercios,
      mascotas: MascotasFalsas(mascotas),
      misLugares: misLugares,
      eventos: eventos,
      sos: SosFalso(
        pins: const [
          Pin(id: 's1', tipo: TipoPin.perdido, punto: Punto(-34.72, -55.95)),
        ],
        listaCercanos: [
          SosResumen(
            id: 's1',
            tipo: TipoSos.perdida,
            especie: 'Perro',
            especieIcono: '🐶',
            nombre: 'Firulais',
            cuando: DateTime(2026, 10, 17, 8),
            distanciaMetros: 300,
          ),
        ],
      ),
      funcionalidades: FuncionalidadesFalsas({
        if (completo) Funcionalidades.mapaCompleto,
        if (pro) Funcionalidades.planesUsuario,
      }),
      planUsuario: PlanUsuarioFalso(
        MiPlanUsuario(plan: pro ? Plan.pro : Plan.free),
      ),
      almacenFiltros: almacenFiltros,
      ahora: DateTime(2026, 10, 17, 10, 20),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('mapa-mover')));
  await tester.pumpAndSettle();
}

/// Los chips de rubros están en una fila que se desplaza de costado.
Future<void> _chip(
  WidgetTester tester,
  String nombre, {
  bool haciaAtras = false,
}) async {
  final chip = find.widgetWithText(FilterChip, nombre);
  await tester.scrollUntilVisible(
    chip,
    haciaAtras ? -150 : 150,
    scrollable: find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
    ),
  );
  await _tocar(tester, chip);
}

ComerciosFalsos _todos() => ComerciosFalsos([_vet, _petshop, _cafe, _paseos]);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sin funcionalidades igual se ve todo el mapa (D84)', (
    tester,
  ) async {
    final comercios = _todos();
    await _abrir(tester, comercios: comercios, completo: false);

    expect(comercios.categoriasPedidas.last, isNull);
    expect(find.text('mapa: 4 pines'), findsOneWidget);
    expect(find.text('Lista'), findsOneWidget);
    // Marcar un lugar es una acción: sigue detrás de `comercios`.
    expect(find.text('Marcar un lugar'), findsNothing);
  });

  testWidgets('completo: todos los rubros con local y los SOS', (tester) async {
    final comercios = _todos();
    await _abrir(tester, comercios: comercios);

    expect(comercios.categoriasPedidas.last, isNull);
    expect(find.text('mapa: 4 pines'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-cafe')), findsOneWidget);
    expect(find.text('Aceptan mascotas'), findsWidgets);
  });

  testWidgets('los rubros y "Perdidos" filtran sin volver a consultar', (
    tester,
  ) async {
    final comercios = _todos();
    await _abrir(tester, comercios: comercios);

    await _tocar(
      tester,
      find.widgetWithText(FilterChip, 'Perdidos y encontrados'),
    );
    expect(find.text('mapa: 1 pines'), findsOneWidget, reason: 'solo el SOS');
    expect(find.byKey(const ValueKey('pin-s1')), findsOneWidget);
    await _chip(tester, 'Tiendas');
    expect(find.text('mapa: 2 pines'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-petshop')), findsOneWidget);
    await _chip(tester, 'Perdidos y encontrados', haciaAtras: true);
    expect(find.text('mapa: 1 pines'), findsOneWidget, reason: 'sin el SOS');
    expect(comercios.zonasConsultadas, hasLength(1));
  });

  testWidgets('chips por grupo: dentro de "Tiendas" se elige un rubro (D91)', (
    tester,
  ) async {
    final comercios = _todos();
    await _abrir(tester, comercios: comercios);
    await _chip(tester, 'Tiendas');
    expect(find.byKey(const ValueKey('pin-petshop')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-vet')), findsNothing);

    // Con el grupo elegido, el segundo toque abre sus rubros.
    await _tocar(tester, find.byKey(const ValueKey('grupo-tiendas')));
    expect(find.byKey(const ValueKey('rubro-agro')), findsOneWidget);
    await _tocar(tester, find.byKey(const ValueKey('rubro-agro')));
    await _tocar(tester, find.text('Listo'));
    expect(find.widgetWithText(FilterChip, 'Tiendas · 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-petshop')), findsOneWidget);

    // "Quitar" saca el grupo: sin chips elegidos se ve todo otra vez.
    await _tocar(tester, find.byKey(const ValueKey('grupo-tiendas')));
    await _tocar(tester, find.text('Quitar'));
    expect(find.byKey(const ValueKey('pin-vet')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-s1')), findsOneWidget);
    expect(comercios.zonasConsultadas, hasLength(1));
  });

  testWidgets('las referencias se ocultan y la app lo recuerda (D91)', (
    tester,
  ) async {
    await _abrir(tester, comercios: _todos());
    expect(find.text('Perdido'), findsOneWidget);
    await _tocar(tester, find.byKey(const ValueKey('leyenda-plegar')));
    expect(find.text('Perdido'), findsNothing);
    expect(find.text('Referencias'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('mapa_leyenda_abierta'), isFalse);
  });

  testWidgets('lista ordenada: abiertos primero, con rubro y distancia', (
    tester,
  ) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.text('Lista'));

    final nombres = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => (t.title! as Text).data)
        .toList();
    expect(nombres.first, 'Veterinaria Gatuna', reason: 'abierta 24 h');
    expect(nombres.last, 'Petshop Perruno', reason: 'cerrada');
    expect(find.textContaining('Veterinaria · a '), findsOneWidget);
  });

  testWidgets('la lista muestra los perdidos y encontrados primero', (
    tester,
  ) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.text('Lista'));
    expect(find.text('Se perdió: Firulais'), findsOneWidget);
    expect(find.text('Veterinaria Gatuna'), findsOneWidget);

    // Solo "Perdidos y encontrados": los lugares se van, el SOS queda.
    await _chip(tester, 'Perdidos y encontrados');
    expect(find.text('Se perdió: Firulais'), findsOneWidget);
    expect(find.text('Veterinaria Gatuna'), findsNothing);

    // Solo un rubro: el SOS se va.
    await _chip(tester, 'Perdidos y encontrados');
    await _chip(tester, 'Tiendas');
    expect(find.text('Se perdió: Firulais'), findsNothing);
    expect(find.text('Petshop Perruno'), findsOneWidget);
  });

  testWidgets('"Sin local" muestra los servicios a domicilio', (tester) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.text('Sin local'));

    expect(find.text('Paseos a Domicilio'), findsOneWidget);
    expect(find.textContaining('Paseador · A domicilio'), findsOneWidget);
  });

  testWidgets('filtros guardados: solo con Pro, y el mapa abre con ellos', (
    tester,
  ) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.text('Filtros'));
    expect(find.text('Guardar como mis filtros'), findsNothing);
    await _tocar(tester, find.text('Listo'));

    final almacen = AlmacenFiltrosFalso();
    final eventos = <Map<String, Object?>>[];
    await _abrir(
      tester,
      comercios: _todos(),
      pro: true,
      almacenFiltros: almacen,
      eventos: eventos,
    );
    await _tocar(tester, find.text('Filtros'));
    await _tocar(tester, find.text('Abierto ahora'));
    await _tocar(tester, find.text('Guardar como mis filtros'));
    expect(almacen.guardados['u1']?.abiertoAhora, isTrue);
    expect(eventos.where((e) => e['name'] == 'filters_save'), hasLength(1));
    expect(find.text('mapa: 2 pines'), findsOneWidget);

    // Al volver a abrir la app, el mapa ya viene filtrado.
    await _abrir(
      tester,
      comercios: _todos(),
      pro: true,
      almacenFiltros: almacen,
    );
    expect(find.text('mapa: 2 pines'), findsOneWidget);
  });

  testWidgets('filtros: abierto ahora y coloca microchip', (tester) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.text('Filtros'));
    await _tocar(tester, find.text('Abierto ahora'));
    await _tocar(tester, find.text('Listo'));
    // Solo la abierta 24 h (y el SOS).
    expect(find.text('mapa: 2 pines'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-vet')), findsOneWidget);

    await _tocar(tester, find.text('Filtros'));
    await _tocar(tester, find.text('Limpiar'));
    await _tocar(tester, find.text('Filtros'));
    await _tocar(tester, find.text('Coloca microchip (Operador RENAC)'));
    await _tocar(tester, find.text('Listo'));
    expect(find.byKey(const ValueKey('pin-petshop')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-vet')), findsNothing);
  });

  testWidgets('especie: la mascota activa o todas', (tester) async {
    await _abrir(
      tester,
      comercios: _todos(),
      mascotas: const [
        Mascota(id: 'm1', nombre: 'Toby', especieId: 1),
        Mascota(id: 'm2', nombre: 'Luna', especieId: 2),
      ],
    );
    // La activa es la primera (Toby, perro): la veterinaria de gatos no.
    expect(find.byKey(const ValueKey('pin-vet')), findsNothing);
    expect(find.byKey(const ValueKey('pin-petshop')), findsOneWidget);

    await _tocar(tester, find.text('Filtros'));
    expect(find.text('Para Toby'), findsOneWidget);
    await _tocar(tester, find.text('Para todas mis mascotas'));
    await _tocar(tester, find.text('Listo'));
    expect(find.byKey(const ValueKey('pin-vet')), findsOneWidget);
  });

  testWidgets('favorito, fui y mi veterinaria desde la ficha', (tester) async {
    final mis = MisLugaresFalsos();
    final eventos = <Map<String, Object?>>[];
    await _abrir(
      tester,
      comercios: _todos(),
      misLugares: mis,
      eventos: eventos,
    );

    await _tocar(tester, find.byKey(const ValueKey('pin-vet')));
    await _tocar(tester, find.text('Favorito'));
    expect(mis.lugares['vet']!.favorito, isTrue);
    await _tocar(tester, find.text('Fui'));
    expect(mis.lugares['vet']!.fuiEn, isNotNull);
    await _tocar(tester, find.text('Es mi veterinaria'));
    expect(mis.lugares['vet']!.miVeterinaria, isTrue);
    expect(find.text('Tu veterinaria'), findsOneWidget);
    expect(
      eventos.map((e) => e['name']),
      containsAll(['favorite_add', 'place_visit', 'my_vet_set']),
    );
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await _tocar(tester, find.text('Filtros'));
    await _tocar(tester, find.text('Solo mis favoritos'));
    await _tocar(tester, find.text('Listo'));
    expect(find.byKey(const ValueKey('pin-vet')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-petshop')), findsNothing);
    // Solo los favoritos: tampoco los perdidos y encontrados.
    expect(find.byKey(const ValueKey('pin-s1')), findsNothing);
  });

  testWidgets('"es mi veterinaria" solo aparece en veterinarias', (
    tester,
  ) async {
    await _abrir(tester, comercios: _todos());
    await _tocar(tester, find.byKey(const ValueKey('pin-cafe')));
    expect(find.text('Acepta mascotas'), findsOneWidget);
    expect(find.text('Es mi veterinaria'), findsNothing);
  });

  testWidgets('muchos lugares juntos se agrupan', (tester) async {
    await _abrir(
      tester,
      comercios: ComerciosFalsos([
        for (var i = 0; i < 4; i++)
          Comercio(
            id: 'p$i',
            nombre: 'Lugar $i',
            tipo: 'petshop',
            punto: Punto(-34.701 - i * 0.0005, -55.951),
            horario: const Horario({}),
          ),
      ]),
    );
    expect(find.text('mapa: 2 pines'), findsOneWidget, reason: 'grupo + SOS');
    expect(find.textContaining('pin grupo:'), findsOneWidget);
  });

  test('LugarMio lee user_places', () {
    final l = LugarMio.fromJson({
      'business_id': 'b1',
      'favorite': true,
      'visited_at': '2026-10-17T12:00:00Z',
      'is_my_vet': false,
    });
    expect(l.favorito, isTrue);
    expect(l.fuiEn, isNotNull);
  });
}
