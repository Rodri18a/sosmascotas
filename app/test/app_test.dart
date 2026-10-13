import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

Widget _app(AppFlavor flavor) => ProviderScope(
  overrides: [
    appEnvProvider.overrideWithValue(
      AppEnv(flavor: flavor, supabaseUrl: '', supabaseAnonKey: ''),
    ),
  ],
  child: const SosMascotaApp(),
);

void main() {
  testWidgets('arranca en la pantalla de inicio', (tester) async {
    await tester.pumpWidget(_app(AppFlavor.dev));

    expect(find.text('SOS Mascota'), findsOneWidget);
  });

  testWidgets('muestra la marca DEV solo en desarrollo', (tester) async {
    await tester.pumpWidget(_app(AppFlavor.dev));
    expect(find.byType(Banner), findsOneWidget);

    await tester.pumpWidget(_app(AppFlavor.prod));
    expect(find.byType(Banner), findsNothing);
  });
}
