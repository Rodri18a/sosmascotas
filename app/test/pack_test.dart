import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'pack_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

const _consulta = BeneficioAdopcion(
  id: 'b1',
  titulo: 'Primera consulta con 20 %',
  negocioId: 'v2',
  negocio: 'Vete Pando',
  direccion: 'Calle 1',
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  // La lista dibuja solo lo cercano: si todavía no está, bajar hasta verlo.
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _ir(
  WidgetTester tester,
  String ruta, {
  required PackFalso pack,
  List<MiNegocio> negocios = const [],
  List<Map<String, Object?>>? eventos,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      pack: pack,
      negocios: NegociosFalsos(negocios),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.adopcion,
        Funcionalidades.comercios,
      }),
      eventos: eventos,
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

MiNegocio _negocio(String tipo, {String verificacion = 'verified'}) =>
    MiNegocio.fromJson({
      'id': 'v2',
      'name': 'Vete Pando',
      'business_type': tipo,
      'kind': 'local',
      'lat': -34.71,
      'lng': -55.95,
      'hours': const <String, Object?>{},
      'verification': verificacion,
      'plan': 'basic',
      'status': 'active',
    });

void main() {
  testWidgets('quien no adoptó por la app no ve beneficios', (tester) async {
    await _ir(tester, '/adopcion/pack', pack: PackFalso(deLaZona: [_consulta]));
    expect(find.textContaining('para quien adoptó por la app'), findsOneWidget);
    expect(find.text('Primera consulta con 20 %'), findsNothing);
  });

  testWidgets('quien adoptó pide el código y lo ve para mostrar', (
    tester,
  ) async {
    final pack = PackFalso(adopto: true, deLaZona: [_consulta]);
    final eventos = <Map<String, Object?>>[];
    await _ir(tester, '/adopcion/pack', pack: pack, eventos: eventos);
    expect(find.text('Vete Pando · Calle 1'), findsOneWidget);

    await _tocar(tester, find.text('Quiero este beneficio'));
    expect(find.text('K7M2Q0'), findsOneWidget);
    expect(find.textContaining('Se usa una sola vez'), findsOneWidget);
    expect(
      [
        for (final e in eventos)
          if (e['name'] == 'perk_claim') e['business_id'],
      ],
      ['v2'],
    );
  });

  testWidgets('el comercio carga un beneficio y canjea un código', (
    tester,
  ) async {
    final pack = PackFalso()..codigos['ABC234'] = ('b0', false);
    await _ir(tester, '/negocio', pack: pack, negocios: [_negocio('vet')]);
    await _tocar(tester, find.text('Pack adopción'));
    expect(find.text('Todavía no cargaste ninguno.'), findsOneWidget);

    await _tocar(tester, find.text('Nuevo beneficio'));
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextField, 'Qué le das'),
      ),
      'Kit de bienvenida',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(pack.guardados.single, {
      'title': 'Kit de bienvenida',
      'description': '',
      'active': true,
    });
    expect(find.text('Kit de bienvenida'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Código de 6 letras y números'),
      'zzz999',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Canjear'));
    expect(
      find.text('Ese código no es de un beneficio de tu comercio.'),
      findsOneWidget,
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));
    await tester.enterText(
      find.widgetWithText(TextField, 'Código de 6 letras y números'),
      'abc234',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Canjear'));
    expect(find.text('¡Código canjeado!'), findsOneWidget);
    expect(find.textContaining('Para Ana'), findsOneWidget);
    expect(pack.codigos['ABC234'], ('b0', true));
  });

  testWidgets('un refugio o un comercio sin verificar no tienen pack', (
    tester,
  ) async {
    await _ir(
      tester,
      '/negocio',
      pack: PackFalso(),
      negocios: [_negocio('vet', verificacion: 'unverified')],
    );
    expect(find.text('Pack adopción'), findsNothing);

    await _ir(
      tester,
      '/negocio',
      pack: PackFalso(),
      negocios: [_negocio('shelter')],
    );
    expect(find.text('Pack adopción'), findsNothing);
  });
}
