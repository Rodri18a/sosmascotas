import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import 'servicio_push.dart';

/// Pide el permiso y avisa cómo quedó. Se usa desde Ajustes y desde Avisos.
Future<void> activarPush(BuildContext context, WidgetRef ref) async {
  final mensajero = ScaffoldMessenger.of(context);
  final t = context.t;
  try {
    final estado = await ref.read(servicioPushProvider).activar();
    mensajero.showSnackBar(
      SnackBar(
        content: Text(switch (estado) {
          EstadoPush.activado => t.pushActivados,
          EstadoPush.bloqueado => t.pushBloqueado,
          EstadoPush.noDisponible ||
          EstadoPush.sinConfigurar => t.pushNoDisponible,
          _ => t.pushSinElegir,
        }),
      ),
    );
  } catch (e) {
    // Firebase web también lanza errores que no son Exception.
    debugPrint('[push] No se pudo activar: $e');
    mensajero.showSnackBar(SnackBar(content: Text(t.pushError)));
  }
  ref.invalidate(estadoPushProvider);
}

/// Interruptor "Avisos en este dispositivo" (Ajustes).
class InterruptorPush extends ConsumerWidget {
  const InterruptorPush({super.key});

  Future<void> _apagar(BuildContext context, WidgetRef ref) async {
    final mensajero = ScaffoldMessenger.of(context);
    final t = context.t;
    try {
      await ref.read(servicioPushProvider).apagar();
    } catch (e) {
      debugPrint('[push] No se pudo apagar: $e');
      mensajero.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(estadoPushProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final estado = ref.watch(estadoPushProvider).value;
    if (estado == null || estado == EstadoPush.sinConfigurar) {
      return const SizedBox.shrink();
    }
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: Text(t.pushInterruptor),
      subtitle: Text(switch (estado) {
        EstadoPush.noDisponible => t.pushNoDisponible,
        EstadoPush.bloqueado => t.pushBloqueado,
        _ => t.pushDetalle,
      }),
      isThreeLine: estado != EstadoPush.activado,
      value: estado == EstadoPush.activado,
      onChanged: switch (estado) {
        EstadoPush.noDisponible ||
        EstadoPush.bloqueado ||
        EstadoPush.sinConfigurar => null,
        EstadoPush.activado => (_) => _apagar(context, ref),
        _ => (_) => activarPush(context, ref),
      },
    );
  }
}

/// Invitación a activar los avisos (bandeja Avisos), solo si todavía no se
/// pidió el permiso o se apagaron desde la app.
class TarjetaActivarPush extends ConsumerWidget {
  const TarjetaActivarPush({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoPushProvider).value;
    if (estado != EstadoPush.sinPedir && estado != EstadoPush.apagado) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(width: 12),
                Expanded(child: Text(t.pushTarjeta)),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => activarPush(context, ref),
                child: Text(t.pushActivar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
