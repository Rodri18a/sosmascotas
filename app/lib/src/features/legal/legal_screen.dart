import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../legal/legal.dart';

/// Muestra los términos o la política de privacidad (Markdown simple).
class LegalScreen extends ConsumerWidget {
  const LegalScreen({required this.documento, super.key});

  final DocumentoLegal documento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final titulo = switch (documento) {
      DocumentoLegal.terminos => t.legalTerminos,
      DocumentoLegal.privacidad => t.legalPrivacidad,
      DocumentoLegal.compromisoAdopcion => t.adopcionCompromisoTitulo,
    };
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: switch (ref.watch(textoLegalProvider(documento))) {
        AsyncData(:final value) => TextoMarkdown(value),
        AsyncError() => Center(child: Text(t.errorDesconocido)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Lo justo de Markdown para los textos legales: títulos, viñetas, citas y negritas.
class TextoMarkdown extends StatelessWidget {
  const TextoMarkdown(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    final bloques = <Widget>[];
    for (final linea in texto.split('\n')) {
      final l = linea.trimRight();
      if (l.isEmpty) continue;
      final (estilo, contenido, sangria) = switch (l) {
        _ when l.startsWith('# ') => (
          estilos.headlineSmall,
          l.substring(2),
          0.0,
        ),
        _ when l.startsWith('## ') => (
          estilos.titleMedium,
          l.substring(3),
          0.0,
        ),
        _ when l.startsWith('- ') => (
          estilos.bodyMedium,
          '•  ${l.substring(2)}',
          8.0,
        ),
        _ when l.startsWith('> ') => (estilos.bodySmall, l.substring(2), 0.0),
        _ => (estilos.bodyMedium, l, 0.0),
      };
      bloques.add(
        Padding(
          padding: EdgeInsets.only(
            left: sangria,
            top: l.startsWith('#') ? 16 : 4,
            bottom: 4,
          ),
          child: Text.rich(_conNegritas(contenido), style: estilo),
        ),
      );
    }
    return SelectionArea(
      child: ListView(padding: const EdgeInsets.all(20), children: bloques),
    );
  }

  static TextSpan _conNegritas(String texto) {
    final partes = texto.split('**');
    return TextSpan(
      children: [
        for (var i = 0; i < partes.length; i++)
          TextSpan(
            text: partes[i],
            style: i.isOdd
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
      ],
    );
  }
}
