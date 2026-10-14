import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../router.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class MascotasScreen extends ConsumerWidget {
  const MascotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.pestanaMascotas),
        actions: const [BotonAjustes()],
      ),
      body: EnConstruccion(
        icono: Icons.pets,
        descripcion: t.mascotasDescripcion,
        paso: '0.3.4',
        accion: FilledButton.icon(
          onPressed: () => abrirConCuenta(
            context,
            ref,
            destino: Rutas.mascotaNueva,
            motivo: t.mascotasMotivoCuenta,
          ),
          icon: const Icon(Icons.add),
          label: Text(t.mascotasAgregar),
        ),
      ),
    );
  }
}
