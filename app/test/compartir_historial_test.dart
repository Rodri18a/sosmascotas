import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'enlaces_historial_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2, duenoId: 'u1');

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('crear un enlace de 30 días: se copia, se lista y se corta', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final copiados = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (llamada) async {
        if (llamada.method == 'Clipboard.setData') {
          copiados.add((llamada.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    final enlaces = EnlacesHistorialFalsos();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.fichaMascota(_luna.id),
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        enlacesHistorial: enlaces,
        eventos: eventos,
        urlPublica: 'https://web.uy',
        funcionalidades: FuncionalidadesFalsas({
          Funcionalidades.compartirHistorial,
        }),
      ),
    );
    await tester.pumpAndSettle();

    await _tocar(tester, find.text('Compartir historial'));
    expect(find.text('Compartir el historial de Luna'), findsOneWidget);
    await _tocar(tester, find.text('30 días'));
    await _tocar(tester, find.text('Crear y copiar el enlace'));

    expect(enlaces.pedidos, [30]);
    expect(copiados.single, startsWith('https://web.uy/h/tok1'));
    expect(find.text('Nadie lo abrió todavía'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'history_share_create').single['props'],
      {'days': 30},
    );

    await _tocar(tester, find.text('Cortar'));
    expect(find.text('Nadie lo abrió todavía'), findsNothing);
  });

  testWidgets('quien no es el dueño no lo ve', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.fichaMascota('m2'),
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([
          const Mascota(id: 'm2', nombre: 'Tom', especieId: 2, duenoId: 'u7'),
        ]),
        funcionalidades: FuncionalidadesFalsas({
          Funcionalidades.compartirHistorial,
        }),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Compartir historial'), findsNothing);
  });
}
