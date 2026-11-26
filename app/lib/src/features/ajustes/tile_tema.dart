import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../theme/tema_elegido.dart';
import '../../widgets/explicacion_corta.dart';

/// Fila "Tema de colores" de Ajustes: Huellamy y Moderno para todos; los
/// demás temas, con plan Pro o Familia (D62, D172).
class TileTema extends ConsumerWidget {
  const TileTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final elegida = ref.watch(paletaActivaProvider);
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(t.ajustesTema),
      subtitle: Text(
        elegida.esGratis
            ? nombreTema(t, elegida)
            : t.ajustesTemaPro(nombreTema(t, elegida)),
      ),
      trailing: const Icon(Icons.chevron_right_outlined),
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
  'moderno' => t.temaModerno,
  'faro' => t.temaFaro,
  'vecinos' => t.temaVecinos,
  'pop' => t.temaPop,
  'blanco_negro' => t.temaBlancoNegro,
  _ => t.temaCielo,
};

String _descripcionTema(AppLocalizations t, Paleta p) => switch (p.id) {
  'moderno' => t.temaModernoDescripcion,
  'faro' => t.temaFaroDescripcion,
  'vecinos' => t.temaVecinosDescripcion,
  'pop' => t.temaPopDescripcion,
  'blanco_negro' => t.temaBlancoNegroDescripcion,
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
            ExplicacionCorta(
              id: 'tema_explicacion',
              corta: t.temaExplicacionCorta,
              larga: t.temaExplicacion,
              estilo: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final paleta in Paleta.gratuitas)
              _OpcionTema(paleta: paleta, elegida: elegida),
            // Los demás, del plan Pro y con la funcionalidad prendida.
            if (ref.watch(tienePlanConTemasProvider))
              SiFuncionalidad(
                Funcionalidades.temasPro,
                child: Column(
                  children: [
                    for (final paleta in Paleta.todas)
                      if (!paleta.esGratis)
                        _OpcionTema(paleta: paleta, elegida: elegida),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OpcionTema extends ConsumerWidget {
  const _OpcionTema({required this.paleta, required this.elegida});

  final Paleta paleta;
  final Paleta elegida;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final elegido = paleta.id == elegida.id;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: elegido,
      leading: _Muestra(paleta.modo(Theme.of(context).brightness)),
      title: Text(nombreTema(t, paleta)),
      subtitle: Text(_descripcionTema(t, paleta)),
      trailing: elegido ? const Icon(Icons.check_circle) : null,
      onTap: () => ref.read(temaElegidoProvider.notifier).elegir(paleta),
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

/// Fila "Letra" de Ajustes (D174): con el tema Moderno, Dongle (la letra
/// del manual de marca) solo en los títulos o en toda la app. Para todos.
class TileDongle extends ConsumerWidget {
  const TileDongle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    if (ref.watch(paletaActivaProvider).estilo != EstiloTema.moderno) {
      return const SizedBox.shrink();
    }
    final elegido = ref.watch(usoDongleProvider);
    return ListTile(
      key: const Key('tile-dongle'),
      leading: const Icon(Icons.text_fields_outlined),
      title: Text(t.ajustesDongle),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SegmentedButton<UsoDongle>(
          segments: [
            ButtonSegment(
              value: UsoDongle.titulos,
              label: Text(t.dongleTitulos),
            ),
            ButtonSegment(value: UsoDongle.todo, label: Text(t.dongleTodo)),
          ],
          selected: {elegido},
          onSelectionChanged: (s) =>
              ref.read(usoDongleProvider.notifier).elegir(s.first),
        ),
      ),
    );
  }
}

/// Fila "Tamaño de letra" de Ajustes (plan Pro, 2.11, D112).
class TileLetra extends ConsumerWidget {
  const TileLetra({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final elegido = ref.watch(tamanoLetraElegidoProvider);
    return ListTile(
      leading: const Icon(Icons.format_size_outlined),
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
