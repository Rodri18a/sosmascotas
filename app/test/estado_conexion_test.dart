import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'helpers.dart';

/// Abre Ajustes, donde está el indicador de conexión (solo en desarrollo).
Future<void> _abrirAjustes(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('avisa si falta la configuración', (tester) async {
    await _abrirAjustes(tester, appDePrueba());

    expect(find.textContaining('Falta configurar Supabase'), findsOneWidget);
  });

  testWidgets('muestra conectado si Supabase responde', (tester) async {
    await _abrirAjustes(tester, appDePrueba(conSupabase: true));

    expect(find.text('Conectado a Supabase dev ✅'), findsOneWidget);
  });

  testWidgets('muestra sin conexión si Supabase falla', (tester) async {
    await _abrirAjustes(
      tester,
      appDePrueba(conSupabase: true, respuestaSalud: 503),
    );

    expect(find.text('Sin conexión a Supabase ❌'), findsOneWidget);
  });

  testWidgets('no se muestra en producción', (tester) async {
    await _abrirAjustes(
      tester,
      appDePrueba(flavor: AppFlavor.prod, conSupabase: true),
    );

    expect(find.byType(Chip), findsNothing);
  });
}
