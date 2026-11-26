import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'helpers.dart';
import 'tema_falso.dart';

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  group('Moderno con la letra del manual (D174)', () {
    test('Dongle en los títulos y Manrope en los textos, por defecto', () {
      final t = AppTheme.tema(Paleta.moderno, Brightness.light).textTheme;
      expect(t.titleLarge!.fontFamily, 'Dongle');
      expect(t.titleLarge!.fontSize, 20 * escalaDongle);
      expect(t.headlineSmall!.fontFamily, 'Dongle');
      expect(t.bodyMedium!.fontFamily, 'Manrope');
      expect(t.bodyMedium!.fontSize, 14);
      expect(t.labelLarge!.fontFamily, 'Manrope');
    });

    test('con «En toda la app», también los textos van en Dongle', () {
      final t = AppTheme.tema(
        Paleta.moderno,
        Brightness.light,
        dongle: UsoDongle.todo,
      ).textTheme;
      expect(t.bodyMedium!.fontFamily, 'Dongle');
      expect(t.bodyMedium!.fontSize, 14 * escalaDongle);
      expect(t.bodySmall!.fontFamily, 'Dongle');
      expect(t.labelSmall!.fontFamily, 'Dongle');
    });

    test('Huellamy no cambia de letra', () {
      final t = AppTheme.tema(
        Paleta.cielo,
        Brightness.light,
        dongle: UsoDongle.todo,
      ).textTheme;
      expect(t.titleLarge!.fontFamily, isNot('Dongle'));
      expect(t.bodyMedium!.fontFamily, isNot('Dongle'));
    });

    test('los colores son los del manual de marca', () {
      final c = Paleta.moderno.claro;
      expect(c.primario, const Color(0xFF2E7B76));
      expect(c.texto, const Color(0xFF12323E));
      expect(c.fondo, const Color(0xFFF3F7F8));
      expect(c.acento, const Color(0xFFF26B69));
    });
  });

  testWidgets('Ajustes: con Moderno se elige dónde va Dongle y se guarda', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    SharedPreferences.setMockInitialValues({});
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(almacenTema: AlmacenTemaFalso('moderno'), eventos: eventos),
    );
    await tester.pumpAndSettle();
    await abrirAjustesDesdeMenu(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tile-dongle')), findsOneWidget);
    await tester.tap(find.text('En todo'));
    await tester.pumpAndSettle();

    final tema = Theme.of(tester.element(find.byType(Scaffold).first));
    expect(tema.textTheme.bodyMedium!.fontFamily, 'Dongle');
    expect(
      (await SharedPreferences.getInstance()).getString('tema.dongle'),
      'todo',
    );
    final cambio = eventos.singleWhere((e) => e['name'] == 'font_change');
    expect(cambio['props'], {'use': 'todo'});
  });

  testWidgets('Ajustes: con Huellamy no aparece la letra de la marca', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(almacenTema: AlmacenTemaFalso('cielo')),
    );
    await tester.pumpAndSettle();
    await abrirAjustesDesdeMenu(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tile-dongle')), findsNothing);
  });
}
