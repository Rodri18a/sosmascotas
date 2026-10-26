import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'transito_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// El de la lista de la pantalla (los campos de texto tienen el suyo).
final _lista = find
    .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
    .first;

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  // Las listas arman lo de abajo recién al bajar.
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(objetivo, 300, scrollable: _lista);
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _ir(
  WidgetTester tester,
  String ruta, {
  required TransitoFalso transito,
  List<MiNegocio> negocios = const [],
  List<Map<String, Object?>>? eventos,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      transito: transito,
      negocios: NegociosFalsos(negocios),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.adopcion,
        Funcionalidades.comercios,
        Funcionalidades.chat,
      }),
      eventos: eventos,
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

MiNegocio _refugio({String verificacion = 'verified'}) => MiNegocio.fromJson({
  'id': 'r1',
  'name': 'Refugio Pando',
  'business_type': 'shelter',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'hours': const <String, Object?>{},
  'verification': verificacion,
  'plan': 'basic',
  'status': 'active',
});

const _hogarDeAna = HogarDisponible(
  id: 'u1',
  nombre: 'Ana',
  barrio: 'Centro',
  especies: [1],
  tamanos: ['chico', 'mediano'],
  maxDias: 30,
  patio: true,
);

void main() {
  testWidgets('me anoto como hogar de tránsito con mi barrio', (tester) async {
    final transito = TransitoFalso();
    final eventos = <Map<String, Object?>>[];
    await _ir(
      tester,
      '/adopcion/transito',
      transito: transito,
      eventos: eventos,
    );
    expect(
      find.textContaining('Nunca tu dirección ni tu teléfono'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Anotarme como hogar de tránsito'));
    expect(
      find.text(
        'Completá qué animales recibís, el tamaño, los días y tu barrio.',
      ),
      findsOneWidget,
    );
    expect(transito.mio, isNull);
    // Volver arriba, a las especies.
    await tester.drag(_lista, const Offset(0, 3000));
    await tester.pumpAndSettle();

    await _tocar(tester, find.widgetWithText(FilterChip, '🐶 Perro'));
    await _tocar(tester, find.widgetWithText(FilterChip, 'Grande'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Por cuántos días como máximo (1 a 365)'),
      '20',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Tu barrio'),
      'Centro',
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await _tocar(tester, find.text('Anotarme como hogar de tránsito'));

    final mio = transito.mio!;
    expect(mio.especies, [1]);
    expect(mio.tamanos, ['chico', 'mediano']);
    expect(mio.maxDias, 20);
    expect(mio.barrio, 'Centro');
    expect(mio.activo, isTrue);
    expect(
      [
        for (final e in eventos)
          if (e['name'] == 'foster_home_save') e['props'],
      ],
      [
        {'activo': true},
      ],
    );
    expect(find.text('Dejar de ser hogar de tránsito'), findsOneWidget);
  });

  testWidgets('el hogar acepta un pedido y se abre el chat con el refugio', (
    tester,
  ) async {
    final transito = TransitoFalso(
      mio: const HogarTransito(especies: [1], barrio: 'Centro'),
      recibidos: [
        PedidoTransito(
          id: 'p1',
          nombreAnimal: 'Luna',
          especieId: 1,
          dias: 15,
          mensaje: '¿La podés tener dos semanas?',
          estado: EstadoTransito.nuevo,
          creado: DateTime(2026, 10, 26),
          refugioId: 'r1',
          refugio: 'Refugio Pando',
        ),
      ],
    );
    final eventos = <Map<String, Object?>>[];
    await _ir(
      tester,
      '/adopcion/transito',
      transito: transito,
      eventos: eventos,
    );
    expect(find.text('Refugio Pando te pide recibir a Luna'), findsOneWidget);
    expect(find.textContaining('15 días'), findsOneWidget);

    await _tocar(tester, find.text('Puedo recibirlo'));
    expect(transito.recibidos.single.estado, EstadoTransito.aceptado);
    expect(
      GoRouter.of(
        tester.element(find.byType(Scaffold).last),
      ).state.uri.toString(),
      '/chats/chat-p1',
    );
    expect(
      [
        for (final e in eventos)
          if (e['name'] == 'foster_request_answer') e['props'],
      ],
      [
        {'acepta': true},
      ],
    );
  });

  testWidgets('el refugio verificado ve los hogares de su zona y pide', (
    tester,
  ) async {
    final transito = TransitoFalso(hogaresDeLaZona: [_hogarDeAna]);
    await _ir(tester, '/negocio', transito: transito, negocios: [_refugio()]);
    await _tocar(tester, find.text('Hogares de tránsito'));
    expect(find.text('Ana · Centro'), findsOneWidget);
    expect(find.textContaining('hasta 30 días'), findsOneWidget);

    await _tocar(tester, find.text('Pedir'));
    final dialogo = find.byType(AlertDialog);
    await tester.enterText(
      find.descendant(
        of: dialogo,
        matching: find.widgetWithText(TextField, 'Nombre del animal'),
      ),
      'Luna',
    );
    await tester.enterText(
      find.descendant(
        of: dialogo,
        matching: find.widgetWithText(TextField, 'Cuántos días (hasta 30)'),
      ),
      '60',
    );
    await _tocar(
      tester,
      find.descendant(
        of: dialogo,
        matching: find.widgetWithText(FilledButton, 'Pedir'),
      ),
    );
    expect(
      find.text('Son más días de los que puede ese hogar.'),
      findsOneWidget,
    );
    expect(transito.pedidos, isEmpty);

    await tester.enterText(
      find.descendant(
        of: dialogo,
        matching: find.widgetWithText(TextField, 'Cuántos días (hasta 30)'),
      ),
      '10',
    );
    await _tocar(
      tester,
      find.descendant(
        of: dialogo,
        matching: find.widgetWithText(FilledButton, 'Pedir'),
      ),
    );
    expect(transito.pedidos.single, ('u1', 'Luna', 1, null, 10));
    expect(find.text('Ya le pediste'), findsOneWidget);
    expect(find.text('Luna → Ana'), findsOneWidget);

    await _tocar(tester, find.text('Cancelar el de Luna'));
    expect(transito.cerrados.single, 'p0');
  });

  testWidgets('un refugio sin verificar no ve los hogares', (tester) async {
    await _ir(
      tester,
      '/negocio',
      transito: TransitoFalso(hogaresDeLaZona: [_hogarDeAna]),
      negocios: [_refugio(verificacion: 'unverified')],
    );
    expect(find.text('Hogares de tránsito'), findsNothing);

    await _ir(
      tester,
      '/negocio/transito/r1',
      transito: TransitoFalso(esRefugio: false),
    );
    expect(
      find.text('Solo para refugios y protectoras verificados.'),
      findsOneWidget,
    );
  });
}
