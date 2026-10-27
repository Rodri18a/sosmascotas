import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Cola de moderación (1.8.3): SOS ocultos por reportes y mensajes
/// reportados. Cada acción queda registrada en la base.
class ModeracionScreen extends ConsumerWidget {
  const ModeracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revision =
        ref.watch(adopcionesEnRevisionProvider).value ??
        const <Map<String, Object?>>[];
    return Column(
      children: [
        if (revision.isNotEmpty) _RevisionAdopciones(revision: revision),
        Expanded(child: _Cola(ref: ref)),
      ],
    );
  }
}

class _RevisionAdopciones extends ConsumerWidget {
  const _RevisionAdopciones({required this.revision});

  final List<Map<String, Object?>> revision;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            T.adopcionesRevision,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Text(T.adopcionesRevisionAyuda),
          for (final a in revision)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${a['publicador'] ?? ''}'),
              subtitle: Text(
                '${a['animales']} ${T.animales} · '
                '${a['camadas_12m']} ${T.camadas12m}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: T.aprobar,
                    onPressed: () async {
                      await ref
                          .read(adminRepositorioProvider)
                          .revisarAdopcion('${a['id']}', aprobar: true);
                      ref.invalidate(adopcionesEnRevisionProvider);
                    },
                    icon: const Icon(Icons.check),
                  ),
                  IconButton(
                    tooltip: T.eliminar,
                    onPressed: () async {
                      await ref
                          .read(adminRepositorioProvider)
                          .revisarAdopcion('${a['id']}', aprobar: false);
                      ref.invalidate(adopcionesEnRevisionProvider);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _Cola extends StatelessWidget {
  const _Cola({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => switch (ref.watch(moderacionProvider)) {
    AsyncData(value: final cola) when cola.isEmpty => const Center(
      child: Text(T.colaVacia),
    ),
    AsyncData(value: final cola) => RefreshIndicator(
      onRefresh: () => ref.refresh(moderacionProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [for (final item in cola) _Tarjeta(item: item)],
      ),
    ),
    AsyncError() => Center(
      child: TextButton(
        onPressed: () => ref.invalidate(moderacionProvider),
        child: const Text(T.reintentar),
      ),
    ),
    _ => const Center(child: CircularProgressIndicator()),
  };
}

class _Tarjeta extends ConsumerWidget {
  const _Tarjeta({required this.item});

  final ItemModeracion item;

  Future<String?> _pedirMotivo(BuildContext context, String accion) {
    final motivo = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accion),
        content: TextField(
          controller: motivo,
          maxLength: 300,
          decoration: const InputDecoration(labelText: T.motivo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(T.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, motivo.text),
            child: const Text(T.confirmar),
          ),
        ],
      ),
    );
  }

  Future<void> _hacer(
    BuildContext context,
    WidgetRef ref,
    String titulo,
    Future<void> Function(AdminRepositorio repo, String motivo) accion,
  ) async {
    final mensajes = ScaffoldMessenger.of(context);
    final motivo = await _pedirMotivo(context, titulo);
    if (motivo == null) return;
    try {
      await accion(ref.read(adminRepositorioProvider), motivo);
      mensajes.showSnackBar(const SnackBar(content: Text(T.hecho)));
    } on Exception {
      mensajes.showSnackBar(const SnackBar(content: Text(T.errorConexion)));
    }
    ref
      ..invalidate(moderacionProvider)
      ..invalidate(panelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final autor = item.autorId;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(switch (item.tipo) {
                    'sos' => T.sos,
                    'review' => T.resena,
                    'post' => T.publicacion,
                    'comment' => T.comentario,
                    _ => T.mensaje,
                  }),
                ),
                const SizedBox(width: 8),
                Text('${item.reportes} ${T.reportes}'),
                if (item.estado == 'hidden') ...[
                  const SizedBox(width: 8),
                  Text(
                    T.oculto,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(item.texto),
            if (item.autorNombre case final n?)
              Text('— $n', style: tema.textTheme.bodySmall),
            if (item.motivos.isNotEmpty)
              Text(item.motivos.join(' · '), style: tema.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _hacer(
                    context,
                    ref,
                    T.aprobar,
                    (repo, m) =>
                        repo.moderar(item.tipo, item.id, 'aprobar', motivo: m),
                  ),
                  child: const Text(T.aprobar),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: tema.colorScheme.error,
                    foregroundColor: tema.colorScheme.onError,
                  ),
                  onPressed: () => _hacer(
                    context,
                    ref,
                    T.eliminar,
                    (repo, m) =>
                        repo.moderar(item.tipo, item.id, 'eliminar', motivo: m),
                  ),
                  child: const Text(T.eliminar),
                ),
                if (autor != null) ...[
                  OutlinedButton(
                    onPressed: () => _hacer(
                      context,
                      ref,
                      T.advertir,
                      (repo, m) => repo.sancionar(autor, 'warning', motivo: m),
                    ),
                    child: const Text(T.advertir),
                  ),
                  OutlinedButton(
                    onPressed: () => _hacer(
                      context,
                      ref,
                      T.bloquear,
                      (repo, m) =>
                          repo.sancionar(autor, 'block', motivo: m, dias: 30),
                    ),
                    child: const Text(T.bloquear),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _Historial(usuarioId: autor),
                    ),
                    child: const Text(T.historial),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Historial extends ConsumerWidget {
  const _Historial({required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AlertDialog(
    title: const Text(T.historial),
    content: FutureBuilder<Map<String, Object?>>(
      future: ref.read(adminRepositorioProvider).historial(usuarioId),
      builder: (context, datos) {
        final h = datos.data;
        if (h == null) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sanciones = (h['sanciones'] as List?) ?? const [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${h['nombre'] ?? ''}'),
            Text('SOS reportados: ${h['sos_reportados'] ?? 0}'),
            Text('Mensajes reportados: ${h['mensajes_reportados'] ?? 0}'),
            if (h['bloqueado'] == true) const Text(T.bloqueado),
            const SizedBox(height: 8),
            const Text(T.sanciones),
            for (final s in sanciones.cast<Map<String, Object?>>())
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${s['tipo']} · ${s['motivo'] ?? ''}'
                      '${s['levantada'] != null ? ' (levantada)' : ''}',
                    ),
                  ),
                  if (s['levantada'] == null)
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(adminRepositorioProvider)
                            .levantarSancion(s['id']! as String);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(T.levantar),
                    ),
                ],
              ),
          ],
        );
      },
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(T.cancelar),
      ),
    ],
  );
}
