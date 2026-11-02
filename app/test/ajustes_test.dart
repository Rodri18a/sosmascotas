import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'perfil_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _abrirAjustes(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el nombre, el correo y el radio de avisos', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(cuenta: ServicioCuentaFalso(conectado: _ana)),
    );
    await _abrirAjustes(tester);

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(
      find.text('Avisarme de mascotas perdidas hasta a 5 km'),
      findsOneWidget,
    );
  });

  testWidgets('cambiar el nombre', (tester) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
      ),
    );
    await _abrirAjustes(tester);

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Ana Laura ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(perfiles.nombre, 'Ana Laura');
    expect(find.text('Ana Laura'), findsOneWidget);
  });

  testWidgets('el nombre también se cambia desde «Mi perfil» (CU-05)', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.perfil}),
      ),
    );
    await _abrirAjustes(tester);
    await tester.tap(find.text('Mi perfil'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tu nombre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ana Laura');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(perfiles.nombre, 'Ana Laura');
    expect(find.text('Ana Laura'), findsOneWidget);
  });

  testWidgets('cambiar el radio de avisos', (tester) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
      ),
    );
    await _abrirAjustes(tester);

    await tester.drag(find.byType(Slider), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(perfiles.radioAvisosKm, 20);
    expect(
      find.text('Avisarme de mascotas perdidas hasta a 20 km'),
      findsOneWidget,
    );
  });

  testWidgets('borrar la cuenta pide confirmación y deja al visitante en '
      'Inicio', (tester) async {
    _pantallaDeCelular(tester);
    final cuenta = ServicioCuentaFalso(conectado: _ana);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(cuenta: cuenta, eventos: eventos, inicio: Rutas.inicio),
    );
    await _abrirAjustes(tester);

    await tester.tap(find.text('Borrar mi cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('¿Borrar tu cuenta?'), findsOneWidget);

    await tester.tap(find.text('Sí, borrar todo'));
    await tester.pumpAndSettle();

    expect(cuenta.cuentasBorradas, 1);
    expect(eventos.map((e) => e['name']), contains('account_delete'));
    expect(find.widgetWithText(AppBar, 'Inicio'), findsOneWidget);
    expect(find.text('Tu cuenta y tus datos se borraron.'), findsOneWidget);
  });

  testWidgets('cancelar no borra nada', (tester) async {
    _pantallaDeCelular(tester);
    final cuenta = ServicioCuentaFalso(conectado: _ana);
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await _abrirAjustes(tester);

    await tester.tap(find.text('Borrar mi cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(cuenta.cuentasBorradas, 0);
    expect(cuenta.actual, isNotNull);
  });

  testWidgets('si falla el borrado, avisa y sigue con la sesión', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final cuenta = ServicioCuentaFalso(conectado: _ana);
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await _abrirAjustes(tester);
    cuenta.fallarCon = ErrorCuenta.sinConexion;

    await tester.tap(find.text('Borrar mi cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí, borrar todo'));
    await tester.pumpAndSettle();

    expect(cuenta.actual, isNotNull);
    expect(find.textContaining('No pudimos conectarnos'), findsOneWidget);
  });

  testWidgets('un visitante ve los textos legales y la opción de ingresar', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(appDePrueba());
    await _abrirAjustes(tester);

    expect(find.text('Ingresar o crear cuenta'), findsOneWidget);
    expect(find.text('Términos y condiciones'), findsOneWidget);
    expect(find.text('Borrar mi cuenta'), findsNothing);

    await tester.tap(find.text('Términos y condiciones'));
    await tester.pumpAndSettle();
    expect(find.textContaining('arranca en Pando'), findsOneWidget);
  });
}
