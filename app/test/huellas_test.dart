import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

Future<List<Map<String, Object?>>> _abrir(
  WidgetTester tester,
  Huellas huellas,
) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final eventos = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: Rutas.perfil,
      cuenta: ServicioCuentaFalso(conectado: _ana),
      huellas: huellas,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.perfil,
        Funcionalidades.huellas,
      }),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

void main() {
  testWidgets('Tus huellas: ayudas, ganadas y cómo ganar las que faltan', (
    tester,
  ) async {
    final eventos = await _abrir(
      tester,
      const Huellas(ayudas: 3, ganadas: {Insignia.perfil, Insignia.chapita}),
    );
    expect(find.text('Tus huellas'), findsOneWidget);
    expect(
      find.text('Ayudaste 3 veces: avisos, respuestas y difusión.'),
      findsOneWidget,
    );
    expect(find.text('¡Ganada!'), findsNWidgets(2));
    expect(
      find.text('Vinculá una chapita QR a tu mascota.'),
      findsNothing,
      reason: 'ya la ganó',
    );
    expect(
      find.text('Cargá las vacunas y que ninguna esté vencida.'),
      findsOneWidget,
    );
    expect(
      find.text('Solo vos ves tus huellas. No hay rankings.'),
      findsOneWidget,
    );
    expect(eventos.map((e) => e['name']), contains('huellas_open'));
  });

  testWidgets('sin ayudas todavía, lo dice con ánimo', (tester) async {
    await _abrir(tester, const Huellas());
    expect(
      find.text('Todavía no ayudaste a nadie en la app. ¡Ya va a llegar!'),
      findsOneWidget,
    );
    expect(find.text('¡Ganada!'), findsNothing);
  });
}
