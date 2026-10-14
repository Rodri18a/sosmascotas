import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: const Text('Ajustes'),
        // Si se entró por un enlace directo no hay a dónde volver: ir al mapa.
        leading: context.canPop()
            ? null
            : BackButton(onPressed: () => context.go(Rutas.mapa)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Perfil, avisos y cuenta'),
            subtitle: Text('Llega en el paso 0.2.6'),
          ),
          if (!env.isProd) ...[
            const Divider(),
            const ListTile(title: Text('Desarrollo')),
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
