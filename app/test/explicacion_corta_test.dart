import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/l10n/l10n.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota/src/widgets/explicacion_corta.dart';

void main() {
  testWidgets('muestra una línea y «Ver más» despliega el texto completo', (
    tester,
  ) async {
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metricasProvider.overrideWithValue(
            Metricas(
              anonId: 'a',
              plataforma: 'web',
              enviar: (fila) async => eventos.add(fila),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ExplicacionCorta(
              id: 'prueba',
              corta: 'Es gratis.',
              larga: 'Es gratis y nunca es una venta, con todos los detalles.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Es gratis.'), findsOneWidget);
    expect(find.textContaining('todos los detalles'), findsNothing);

    await tester.tap(find.text('Ver más'));
    await tester.pumpAndSettle();
    expect(find.textContaining('todos los detalles'), findsOneWidget);
    expect(
      eventos
          .where((e) => e['name'] == 'more_info_open')
          .map((e) => e['props']),
      [
        {'item': 'prueba'},
      ],
    );

    await tester.tap(find.text('Ver menos'));
    await tester.pumpAndSettle();
    expect(find.text('Es gratis.'), findsOneWidget);
  });
}
