import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../router.dart';
import 'estado_conexion.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.ajustes),
        // Si se entró por un enlace directo no hay a dónde volver: ir al mapa.
        leading: context.canPop()
            ? null
            : BackButton(onPressed: () => context.go(Rutas.mapa)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.t.ajustesPerfil),
            subtitle: Text(context.t.enConstruccionPaso('0.2.6')),
          ),
          if (!env.isProd) ...[
            const Divider(),
            ListTile(title: Text(context.t.ajustesDesarrollo)),
            const Align(
              alignment: Alignment.centerLeft,
              child: EstadoConexionChip(),
            ),
          ],
        ],
      ),
    );
  }
}
