import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../config/supabase_providers.dart';

/// Indicador de conexión con Supabase. Solo se muestra en desarrollo.
class EstadoConexionChip extends ConsumerWidget {
  const EstadoConexionChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appEnvProvider).isProd) return const SizedBox.shrink();

    final t = context.t;
    final texto = switch (ref.watch(estadoConexionProvider)) {
      AsyncData(value: EstadoConexion.conectado) => t.conexionConectado,
      AsyncData(value: EstadoConexion.sinConfigurar) => t.conexionSinConfigurar,
      AsyncData(value: EstadoConexion.sinConexion) ||
      AsyncError() => t.conexionSinConexion,
      _ => t.conexionConectando,
    };
    return Chip(label: Text(texto));
  }
}
