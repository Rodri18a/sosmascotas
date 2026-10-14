import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../router.dart';
import 'estado_conexion.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final usuario = ref.watch(usuarioActualProvider).value;
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.ajustes),
        // Si se entró por un enlace directo no hay a dónde volver: ir al mapa.
        leading: context.canPop()
            ? null
            : BackButton(onPressed: () => context.go(Rutas.mapa)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (usuario == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(t.ingresarOCrearCuenta),
              subtitle: Text(t.ingresarSubtitulo),
              onTap: () => context.push(Rutas.ingresarYVolverA(Rutas.ajustes)),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(usuario.email ?? t.ajustesPerfil),
              subtitle: Text(t.enConstruccionPaso('0.2.6')),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(t.cerrarSesion),
              onTap: () => ref.read(servicioCuentaProvider).salir(),
            ),
          ],
          if (!env.isProd) ...[
            const Divider(),
            ListTile(title: Text(t.ajustesDesarrollo)),
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
