import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../avisos/avisos_repositorio.dart';
import '../cuenta/servicio_cuenta.dart';
import '../router.dart';

/// Campana de avisos (solo con sesión), con la cantidad de avisos sin ver.
class BotonAvisos extends ConsumerWidget {
  const BotonAvisos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(conectadoProvider)) return const SizedBox.shrink();
    // Se cuenta acá (y no con un provider derivado): evita recalcular durante
    // el dibujo cuando una pestaña vuelve del fondo (caso borde de Riverpod 3).
    final nuevos = contarNuevos(ref.watch(avisosProvider).value);
    return IconButton(
      tooltip: context.t.avisosTitulo,
      onPressed: () => context.push(Rutas.avisos),
      icon: Badge(
        isLabelVisible: nuevos > 0,
        label: Text('$nuevos'),
        child: Icon(
          nuevos > 0 ? Icons.notifications_active : Icons.notifications_none,
        ),
      ),
    );
  }
}
