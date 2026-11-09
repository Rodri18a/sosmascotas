import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'ayuda_falsa.dart';
import 'comercios_falsos.dart';
import 'helpers.dart';

const _refugio = EntradaAyuda(
  id: 'a1',
  tipo: TipoAyuda.refugio,
  nombre: 'Refugio Ejemplo Pando',
  descripcion: 'Datos de ejemplo',
  telefono: '099000011',
  whatsapp: '099000011',
  esEjemplo: true,
);
const _grupo = EntradaAyuda(
  id: 'a2',
  tipo: TipoAyuda.grupo,
  nombre: 'Grupo Ejemplo de difusión',
  enlace: 'https://example.com/grupo',
);

const _guardia = Comercio(
  id: 'vet-24h',
  nombre: 'Clínica Ejemplo 24 h',
  punto: Punto(-34.7215, -55.9512),
  horario: Horario({}),
  es24h: true,
  urgencias: true,
);
const _comun = Comercio(
  id: 'vet-comun',
  nombre: 'Veterinaria Ejemplo Sur',
  punto: Punto(-34.7262, -55.9603),
  horario: Horario({}),
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _irAAyuda(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Urgencias'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'un visitante ve las urgencias y el directorio, sin el 911 (D151)',
    (tester) async {
      _pantallaDeCelular(tester);
      final enlaces = <Uri>[];
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          ayuda: AyudaFalsa([_refugio, _grupo]),
          comercios: ComerciosFalsos([_guardia, _comun]),
          enlacesAbiertos: enlaces,
          eventos: eventos,
        ),
      );
      await _irAAyuda(tester);

      expect(find.text('¿Hay una persona en riesgo?'), findsNothing);
      expect(find.text('Llamar al 911'), findsNothing);

      // Solo las de urgencia o 24 h, con su estado.
      expect(find.text('Clínica Ejemplo 24 h'), findsOneWidget);
      expect(find.text('Abierto las 24 h'), findsOneWidget);
      expect(find.text('Veterinaria Ejemplo Sur'), findsNothing);

      expect(find.text('Refugios y protectoras'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Grupos para difundir'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Grupos para difundir'), findsOneWidget);
      expect(find.text('Organismos'), findsNothing, reason: 'no hay ninguno');
      expect(find.text('Ejemplo'), findsOneWidget);

      await tester.tap(find.text('WhatsApp'));
      await tester.ensureVisible(find.text('Abrir'));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(enlaces.map((u) => u.toString()), [
        'https://wa.me/59899000011',
        'https://example.com/grupo',
      ]);
      expect(
        eventos.where((e) => e['name'] == 'help_click').map((e) => e['props']),
        [
          {'tipo': 'whatsapp', 'kind': 'refugio'},
          {'tipo': 'enlace', 'kind': 'grupo'},
        ],
      );
    },
  );

  testWidgets('tocar una veterinaria de urgencia abre su ficha', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(comercios: ComerciosFalsos([_guardia])),
    );
    await _irAAyuda(tester);

    await tester.tap(find.text('Clínica Ejemplo 24 h'));
    await tester.pumpAndSettle();
    expect(find.text('Cómo llegar'), findsOneWidget);
  });

  testWidgets('sin datos cargados explica que todavía no hay', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(appDePrueba());
    await _irAAyuda(tester);

    expect(
      find.textContaining('no hay veterinarias de urgencia'),
      findsOneWidget,
    );
    expect(find.textContaining('no hay refugios ni grupos'), findsOneWidget);
  });
}
