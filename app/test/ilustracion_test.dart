import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/widgets/ilustracion.dart';
import 'package:sosmascota/src/widgets/logo.dart';

void main() {
  test('cada ilustración y el logo tienen su archivo (D157)', () {
    for (final i in Ilustracion.values) {
      expect(File(i.ruta).existsSync(), isTrue, reason: i.ruta);
    }
    expect(File(LogoHuellamy.imagen).existsSync(), isTrue);
  });

  testWidgets('el vacío ilustrado muestra el texto y el dibujo no se lee', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VacioIlustrado(Ilustracion.mishiJugando, 'Sin mascotas'),
        ),
      ),
    );
    expect(find.text('Sin mascotas'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('mishi', caseSensitive: false)),
      findsNothing,
    );
    semantica.dispose();
  });
}
