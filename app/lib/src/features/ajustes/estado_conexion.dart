import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env_provider.dart';
import '../../config/supabase_providers.dart';

/// Indicador de conexión con Supabase. Solo se muestra en desarrollo.
class EstadoConexionChip extends ConsumerWidget {
  const EstadoConexionChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appEnvProvider).isProd) return const SizedBox.shrink();

    final texto = switch (ref.watch(estadoConexionProvider)) {
      AsyncData(value: EstadoConexion.conectado) =>
        'Conectado a Supabase dev ✅',
      AsyncData(value: EstadoConexion.sinConfigurar) =>
        'Falta configurar Supabase (config/dev.json) ⚠️',
      AsyncData(value: EstadoConexion.sinConexion) ||
      AsyncError() => 'Sin conexión a Supabase ❌',
      _ => 'Conectando con Supabase…',
    };
    return Chip(label: Text(texto));
  }
}
