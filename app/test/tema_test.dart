import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/mapa/mapa_vista.dart';
import 'package:sosmascota/src/theme/app_theme.dart';
import 'package:sosmascota/src/theme/paleta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Contraste WCAG entre dos colores (1 a 21).
double contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const paletas = {'Cielo': Paleta.cielo};

  for (final MapEntry(key: nombre, value: paleta) in paletas.entries) {
    for (final brillo in Brightness.values) {
      group('$nombre ${brillo.name}', () {
        final c = paleta.modo(brillo);
        final esquema = AppTheme.esquema(c, brillo);

        test('texto y roles con contraste ≥ 4,5:1', () {
          final pares = {
            'texto/fondo': (c.texto, c.fondo),
            'texto suave/fondo': (c.textoSuave, c.fondo),
            'primario/fondo': (c.primario, c.fondo),
            'sobre primario': (c.sobrePrimario, c.primario),
            'sobre acento': (c.sobreAcento, c.acento),
            'error/fondo': (c.error, c.fondo),
            'sobre error': (c.sobreError, c.error),
            'éxito/fondo': (c.exito, c.fondo),
            'urgencia/fondo': (c.urgencia, c.fondo),
          };
          for (final MapEntry(key: par, value: (a, b)) in pares.entries) {
            expect(contraste(a, b), greaterThanOrEqualTo(4.5), reason: par);
          }
        });

        test('el texto contrasta sobre todas las superficies', () {
          final superficies = [
            esquema.surfaceContainerLowest,
            esquema.surfaceContainerLow,
            esquema.surfaceContainer,
            esquema.surfaceContainerHigh,
            esquema.surfaceContainerHighest,
          ];
          for (final s in superficies) {
            expect(contraste(esquema.onSurface, s), greaterThanOrEqualTo(4.5));
            expect(
              contraste(esquema.onSurfaceVariant, s),
              greaterThanOrEqualTo(4.5),
            );
          }
        });

        test('el esquema usa los colores exactos de la paleta', () {
          expect(esquema.primary, c.primario);
          expect(esquema.secondary, c.acento);
          expect(esquema.surface, c.fondo);
          expect(esquema.onSurface, c.texto);
          expect(esquema.error, c.error);
        });
      });
    }
  }

  test('los pines se distinguen también por luminosidad', () {
    final luminosidades =
        coloresPin.values.map((c) => c.computeLuminance()).toList()..sort();
    for (var i = 1; i < luminosidades.length; i++) {
      // Al menos 1,5:1 entre pines vecinos en luminosidad.
      expect(
        (luminosidades[i] + 0.05) / (luminosidades[i - 1] + 0.05),
        greaterThanOrEqualTo(1.5),
      );
    }
  });

  test('el borde de los pines contrasta con el mapa y con cada pin', () {
    const mapaClaro = Color(0xFFF2EFE9);
    expect(contraste(bordePin, mapaClaro), greaterThanOrEqualTo(3));
    // El borde solo es necesario para el ámbar, que se pierde sobre el mapa.
    expect(
      contraste(bordePin, coloresPin[TipoPin.urgencia]!),
      greaterThanOrEqualTo(3),
    );
  });

  testWidgets('títulos con Sora y texto con Source Sans 3', (tester) async {
    final tema = AppTheme.claro;
    expect(tema.textTheme.headlineSmall?.fontFamily, 'Sora');
    expect(tema.textTheme.titleLarge?.fontFamily, 'Sora');
    expect(tema.textTheme.bodyLarge?.fontFamily, 'SourceSans3');
    expect(tema.extension<ColoresMarca>(), isNotNull);
  });
}
