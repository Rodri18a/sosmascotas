import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'transferencias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2, duenoId: 'u1');
const _rocco = Mascota(id: 'm9', nombre: 'Rocco', especieId: 1, duenoId: 'u1');

Future<List<Map<String, Object?>>> _abrir(
  WidgetTester tester,
  TransferenciasFalsas transferencias, {
  String? inicio,
  List<Mascota> mascotas = const [_luna],
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final eventos = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: inicio ?? Rutas.fichaMascota(_luna.id),
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas(mascotas),
      transferencias: transferencias,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({Funcionalidades.pasarMascota}),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

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
  testWidgets('el dueño genera un código, lo ve y lo puede cancelar', (
    tester,
  ) async {
    final transferencias = TransferenciasFalsas();
    final eventos = await _abrir(tester, transferencias);
    await _tocar(tester, find.text('Pasar a otra persona'));
    expect(find.text('Pasar a Luna'), findsOneWidget);

    await _tocar(tester, find.text('Generar código'));
    expect(find.text('K7M2Q9XPWA'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('pet_transfer_create'));

    await _tocar(tester, find.text('Cancelar el código'));
    expect(find.text('K7M2Q9XPWA'), findsNothing);
    expect(find.text('Generar código'), findsOneWidget);
  });

  testWidgets('con un SOS abierto no se puede pasar', (tester) async {
    await _abrir(tester, TransferenciasFalsas(conSos: true));
    await _tocar(tester, find.text('Pasar a otra persona'));
    await _tocar(tester, find.text('Generar código'));
    expect(
      find.text('Tiene un SOS abierto: cerralo antes de pasarla.'),
      findsOneWidget,
    );
  });

  testWidgets('recibir: código, confirmar y queda en mis mascotas', (
    tester,
  ) async {
    final transferencias = TransferenciasFalsas(
      recibible: (
        mascotaId: 'm9',
        nombre: 'Rocco',
        especieId: 1,
        fotoPath: null,
      ),
    );
    final eventos = await _abrir(
      tester,
      transferencias,
      inicio: Rutas.mascotas,
      mascotas: const [_luna, _rocco],
    );
    await _tocar(tester, find.text('Tengo un código'));

    await tester.enterText(find.byType(TextField), 'zzzzzzzzzz');
    await _tocar(tester, find.text('Buscar'));
    expect(
      find.text('El código no es válido, venció o ya se usó.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'abcdefghjk');
    await _tocar(tester, find.text('Buscar'));
    expect(
      find.text('Pasa a tu cuenta con todo su historial.'),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Aceptar'));

    expect(transferencias.aceptados, ['abcdefghjk']);
    expect(find.text('¡Listo! Ya está en tus mascotas.'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Rocco'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('pet_transfer_accept'));
  });

  testWidgets('quien no es el dueño no ve «Pasar a otra persona»', (
    tester,
  ) async {
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
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.pasarMascota}),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Pasar a otra persona'), findsNothing);
  });
}
