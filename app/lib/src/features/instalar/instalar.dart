import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../instalar/servicio_instalacion.dart';

/// Ofrece instalar: aviso del navegador o, en el iPhone, los pasos.
Future<void> ofrecerInstalar(
  BuildContext context,
  WidgetRef ref,
  String origen,
) async {
  final forma = ref.read(formaDeInstalarProvider);
  final notifier = ref.read(formaDeInstalarProvider.notifier);
  final mensajero = ScaffoldMessenger.of(context);
  final gracias = context.t.instalarGracias;
  if (forma == FormaDeInstalar.iphone) {
    unawaited(notifier.ofrecer(origen));
    await showDialog<void>(
      context: context,
      builder: (_) => const _PasosIphone(),
    );
    return;
  }
  if (await notifier.ofrecer(origen)) {
    mensajero.showSnackBar(SnackBar(content: Text(gracias)));
  }
}

/// Fila de Ajustes (solo si se puede instalar).
class TileInstalar extends ConsumerWidget {
  const TileInstalar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(formaDeInstalarProvider) == FormaDeInstalar.ninguna) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    return ListTile(
      leading: const Icon(Icons.install_mobile_outlined),
      title: Text(t.instalarTitulo),
      subtitle: Text(t.instalarSubtitulo),
      onTap: () => ofrecerInstalar(context, ref, 'ajustes'),
    );
  }
}

/// Tarjeta del mapa, desde la 2.ª apertura y hasta que se descarta.
class TarjetaInstalarApp extends ConsumerWidget {
  const TarjetaInstalarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forma = ref.watch(formaDeInstalarProvider);
    if (forma == FormaDeInstalar.ninguna ||
        !ref.watch(tarjetaInstalarProvider)) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.install_mobile_outlined,
                  color: tema.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.instalarTarjetaTitulo,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(t.instalarTarjetaTexto),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () =>
                        ref.read(tarjetaInstalarProvider.notifier).descartar(),
                    child: Text(t.instalarAhoraNo),
                  ),
                  FilledButton(
                    onPressed: () => ofrecerInstalar(context, ref, 'mapa'),
                    child: Text(t.instalarBoton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasosIphone extends StatelessWidget {
  const _PasosIphone();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final pasos = [
      t.instalarIphonePaso1,
      t.instalarIphonePaso2,
      t.instalarIphonePaso3,
    ];
    return AlertDialog(
      title: Text(t.instalarIphoneTitulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, paso) in pasos.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 12, child: Text('${i + 1}')),
                  const SizedBox(width: 10),
                  Expanded(child: Text(paso)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            t.instalarIphoneAvisos,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.instalarEntendido),
        ),
      ],
    );
  }
}
