import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'libreta_falsa.dart';
import 'mascotas_falsas.dart';
import 'qr_falso.dart';
import 'recordatorios_falsos.dart';
import 'respaldo_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// La app con [respaldo]; [conInternet] decide si la base responde.
Widget _app({
  required AlmacenRespaldoFalso respaldo,
  required bool conInternet,
  ServicioCuentaFalso? cuenta,
}) {
  final mascotas = MascotasFalsas([_luna])..sinConexion = !conInternet;
  final qr = QrFalso()..sinConexion = !conInternet;
  final libreta = LibretaFalsa([
    RegistroSalud(
      id: 'v1',
      mascotaId: 'm1',
      tipo: TipoRegistroSalud.vaccine,
      nombre: 'Antirrábica',
      fecha: DateTime(2026, 9),
    ),
  ])..fallar = !conInternet;
  final recordatorios = RecordatoriosFalsos([
    Recordatorio(
      id: 'r1',
      mascotaId: 'm1',
      tipo: TipoRecordatorio.medication,
      titulo: 'Antibiótico',
      frecuencia: const CadaHoras(12),
      inicio: DateTime(2026, 10, 16, 8),
    ),
  ])..fallar = !conInternet;
  return appDePrueba(
    cuenta: cuenta ?? ServicioCuentaFalso(conectado: _ana),
    mascotas: mascotas,
    qr: qr,
    libreta: libreta,
    recordatorios: recordatorios,
    respaldo: respaldo,
    funcionalidades: FuncionalidadesFalsas({
      Funcionalidades.libreta,
      Funcionalidades.recordatorios,
    }),
    ahora: DateTime(2026, 10, 17, 10, 20),
  );
}

Future<void> _abrirFichaYQr(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
  await tester.pumpAndSettle();
  expect(find.text('Antirrábica'), findsOneWidget);
  expect(find.text('Antibiótico'), findsOneWidget);
  // La ficha es larga: se vuelve a subir hasta la chapita.
  await tester.scrollUntilVisible(
    find.text('Chapita QR'),
    -300,
    scrollable: find.byType(Scrollable).last,
  );
  await _tocar(tester, find.text('Chapita QR'));
  expect(find.text('K7M2QX9P'), findsOneWidget);
}

void main() {
  testWidgets('sin internet se ve lo último que se leyó: ficha, libreta, '
      'recordatorios y QR', (tester) async {
    _pantallaDeCelular(tester);
    final respaldo = AlmacenRespaldoFalso();

    await tester.pumpWidget(_app(respaldo: respaldo, conInternet: true));
    await _abrirFichaYQr(tester);
    expect(
      respaldo.datos.keys,
      containsAll([
        'u1/mascotas',
        'u1/libreta/m1',
        'u1/recordatorios',
        'u1/qr/m1',
      ]),
    );

    // Otra vez, ahora sin conexión: todo sale de la copia.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app(respaldo: respaldo, conInternet: false));
    await _abrirFichaYQr(tester);
  });

  testWidgets('la copia de otra cuenta no se usa', (tester) async {
    _pantallaDeCelular(tester);
    final respaldo = AlmacenRespaldoFalso();
    await tester.pumpWidget(_app(respaldo: respaldo, conInternet: true));
    await tester.pumpAndSettle();
    expect(respaldo.datos, contains('u1/mascotas'));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _app(
        respaldo: respaldo,
        conInternet: false,
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u2', email: 'beto@correo.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(BarraInferior),
        matching: find.text('Mascotas'),
      ),
    );
    expect(find.widgetWithText(ListTile, 'Luna'), findsNothing);
  });

  testWidgets('al cerrar sesión se borran las copias', (tester) async {
    _pantallaDeCelular(tester);
    final respaldo = AlmacenRespaldoFalso();
    final cuenta = ServicioCuentaFalso(conectado: _ana);
    await tester.pumpWidget(
      _app(respaldo: respaldo, conInternet: true, cuenta: cuenta),
    );
    await tester.pumpAndSettle();
    expect(respaldo.datos, isNotEmpty);

    cuenta.conectar(null);
    await tester.pumpAndSettle();
    expect(respaldo.datos, isEmpty);
  });
}
