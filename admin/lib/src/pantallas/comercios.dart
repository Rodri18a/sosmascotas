import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Reclamos, disputas, verificaciones ✔️ e insignia RENAC (1.3.4 y 1.8.4).
class ComerciosScreen extends ConsumerWidget {
  const ComerciosScreen({super.key});

  Future<void> _resolver(
    BuildContext context,
    WidgetRef ref,
    PendienteComercio p, {
    required bool aprobar,
  }) async {
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminRepositorioProvider)
          .resolverComercio(p.tipo, p.id, aprobar: aprobar);
      mensajes.showSnackBar(const SnackBar(content: Text(T.hecho)));
    } on Exception {
      mensajes.showSnackBar(const SnackBar(content: Text(T.errorConexion)));
    }
    ref
      ..invalidate(pendientesComerciosProvider)
      ..invalidate(lugaresProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(pendientesComerciosProvider)) {
        AsyncData(value: final lista) when lista.isEmpty => const Center(
          child: Text(T.sinPendientes),
        ),
        AsyncData(value: final lista) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final p in lista)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        T.tiposPendiente[p.tipo] ?? p.tipo,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text('${p.negocio} · ${T.rubros[p.rubro] ?? p.rubro}'),
                      if (p.usuarioNombre case final n?) Text('— $n'),
                      if (p.rut case final r?) Text('${T.rut}: $r'),
                      if (p.nota case final n?) Text(n),
                      if (p.tipo == 'renac') const Text(T.revisarRenac),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton(
                            onPressed: () =>
                                _resolver(context, ref, p, aprobar: true),
                            child: const Text(T.aprobar),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                _resolver(context, ref, p, aprobar: false),
                            child: const Text(T.rechazar),
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
            onPressed: () => ref.invalidate(pendientesComerciosProvider),
            child: const Text(T.reintentar),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      };
}
