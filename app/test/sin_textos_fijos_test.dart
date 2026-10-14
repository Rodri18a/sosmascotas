import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Los textos que ve el usuario van en lib/l10n/app_es.arb, nunca escritos en
/// las pantallas. Una excepción justificada se marca con `// i18n-ok`.
void main() {
  test('las pantallas no tienen textos escritos a mano', () {
    // Text('…'), label: '…', tooltip: '…', etc. con una letra adentro.
    final textoFijo = RegExp(
      r"""(Text\(|(label|tooltip|title|subtitle|hintText|labelText|message|descripcion|semanticLabel):\s*)\s*(const\s+)?['"][^'"]*\p{L}""",
      unicode: true,
    );
    final soloTexto = RegExp(
      r"""^\s*['"][^'"]*\p{L}[^'"]*['"],?\s*$""",
      unicode: true,
    );

    final problemas = <String>[];
    final archivos = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final archivo in archivos) {
      final lineas = archivo.readAsLinesSync();
      for (var i = 0; i < lineas.length; i++) {
        final linea = lineas[i];
        if (linea.contains('i18n-ok') || linea.trimLeft().startsWith('//')) {
          continue;
        }
        // Un texto suelto en su propia línea, justo después de `Text(`.
        final anterior = i > 0 ? lineas[i - 1].trimRight() : '';
        if (textoFijo.hasMatch(linea) ||
            (anterior.endsWith('Text(') && soloTexto.hasMatch(linea))) {
          problemas.add('${archivo.path}:${i + 1}: ${linea.trim()}');
        }
      }
    }

    expect(
      problemas,
      isEmpty,
      reason:
          'Pasá estos textos a lib/l10n/app_es.arb:\n${problemas.join('\n')}',
    );
  });
}
