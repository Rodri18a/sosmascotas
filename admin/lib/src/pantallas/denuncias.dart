import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';

/// Denuncias de maltrato (2.7, D80): las nuevas primero; se derivan a las
/// autoridades o se cierran. La app no reemplaza la denuncia oficial.
class DenunciasScreen extends ConsumerWidget {
  const DenunciasScreen({super.key});

  Future<void> _estado(WidgetRef ref, String id, String estado) async {
    await ref.read(adminRepositorioProvider).estadoDenuncia(id, estado);
    ref.invalidate(denunciasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(denunciasProvider)) {
        AsyncData(value: final lista) when lista.isEmpty => const Center(
          child: Text(T.sinDenuncias),
        ),
        AsyncData(value: final lista) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final d in lista)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        T.estadosDenuncia[d['status']] ?? '${d['status']}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text('${d['description']}'),
                      if (d['reporter'] case final r?) Text('— $r'),
                      if (d['address'] case final a?) Text('$a'),
                      if (d['lat'] case final lat?)
                        SelectableText('${T.verUbicacion}: $lat, ${d['lng']}'),
                      Text('📷 ${(d['photos'] as List?)?.length ?? 0}'),
                      if (d['status'] != 'closed')
                        Wrap(
                          spacing: 8,
                          children: [
                            if (d['status'] == 'new')
                              FilledButton(
                                onPressed: () =>
                                    _estado(ref, '${d['id']}', 'referred'),
                                child: const Text(T.derivar),
                              ),
                            OutlinedButton(
                              onPressed: () =>
                                  _estado(ref, '${d['id']}', 'closed'),
                              child: const Text(T.cerrar),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AsyncError() => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(denunciasProvider),
            child: const Text(T.reintentar),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      };
}
