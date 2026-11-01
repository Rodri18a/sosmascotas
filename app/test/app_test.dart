import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'helpers.dart';

void main() {
  test('abre en Inicio, el muro (D127)', () {
    final contenedor = ProviderContainer();
    addTearDown(contenedor.dispose);
    expect(contenedor.read(rutaInicialProvider), Rutas.inicio);
  });

  testWidgets('arranca en Inicio', (tester) async {
    await tester.pumpWidget(appDePrueba(inicio: Rutas.inicio));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Inicio'), findsOneWidget);
    expect(find.byType(BarraInferior), findsOneWidget);
  });

  testWidgets('muestra la marca DEV solo en desarrollo', (tester) async {
    await tester.pumpWidget(appDePrueba());
    expect(find.byType(MarcaDev), findsOneWidget);

    await tester.pumpWidget(
      appDePrueba(flavor: AppFlavor.prod, conSupabase: true),
    );
    expect(find.byType(MarcaDev), findsNothing);
  });

  testWidgets('sigue el modo claro u oscuro del sistema', (tester) async {
    await tester.pumpWidget(appDePrueba());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme!.colorScheme.brightness, Brightness.light);
    expect(app.darkTheme!.colorScheme.brightness, Brightness.dark);
  });
}
