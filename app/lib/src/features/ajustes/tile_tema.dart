import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../theme/paleta.dart';
import '../../theme/tema_elegido.dart';

/// Fila "Tema de colores" de Ajustes (solo con plan Pro o Familia, D62).
class TileTema extends ConsumerWidget {
  const TileTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final elegida = ref.watch(paletaActivaProvider);
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(t.ajustesTema),
      subtitle: Text(t.ajustesTemaPro(nombreTema(t, elegida))),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => const _SelectorTema(),
      ),
    );
  }
}

String nombreTema(AppLocalizations t, Paleta p) => switch (p.id) {
  'faro' => t.temaFaro,
  'vecinos' => t.temaVecinos,
  'pop' => t.temaPop,
  _ => t.temaCielo,
};

String _descripcionTema(AppLocalizations t, Paleta p) => switch (p.id) {
  'faro' => t.temaFaroDescripcion,
  'vecinos' => t.temaVecinosDescripcion,
  'pop' => t.temaPopDescripcion,
  _ => t.temaCieloDescripcion,
};

class _SelectorTema extends ConsumerWidget {
  const _SelectorTema();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final elegida = ref.watch(paletaActivaProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.temaElegirTitulo, style: tema.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              t.temaExplicacion,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final paleta in Paleta.todas)
              ListTile(
                contentPadding: EdgeInsets.zero,
                selected: paleta.id == elegida.id,
                leading: _Muestra(paleta.modo(tema.brightness)),
                title: Text(nombreTema(t, paleta)),
                subtitle: Text(_descripcionTema(t, paleta)),
                trailing: paleta.id == elegida.id
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () =>
                    ref.read(temaElegidoProvider.notifier).elegir(paleta),
              ),
          ],
        ),
      ),
    );
  }
}

/// Muestra los colores de un tema: fondo, primario y acento.
class _Muestra extends StatelessWidget {
  const _Muestra(this.c);

  final ColoresModo c;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.fondo,
        shape: BoxShape.circle,
        border: Border.all(color: c.texto.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          for (final color in [c.primario, c.acento])
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Fila "Tamaño de letra" de Ajustes (plan Pro, 2.11, D112).
class TileLetra extends ConsumerWidget {
  const TileLetra({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final elegido = ref.watch(tamanoLetraElegidoProvider);
    return ListTile(
      leading: const Icon(Icons.format_size),
      title: Text(t.ajustesLetra),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SegmentedButton<TamanoLetra>(
          segments: [
            ButtonSegment(
              value: TamanoLetra.normal,
              label: Text(t.letraNormal),
            ),
            ButtonSegment(
              value: TamanoLetra.grande,
              label: Text(t.letraGrande),
            ),
            ButtonSegment(
              value: TamanoLetra.muyGrande,
              label: Text(t.letraMuyGrande),
            ),
          ],
          selected: {elegido},
          onSelectionChanged: (s) =>
              ref.read(tamanoLetraElegidoProvider.notifier).elegir(s.first),
        ),
      ),
    );
  }
}
