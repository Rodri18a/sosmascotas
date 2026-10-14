import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../router.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/en_construccion.dart';

class SosScreen extends ConsumerWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.pestanaSos),
        actions: const [BotonAvisos(), BotonAjustes()],
      ),
      body: EnConstruccion(
        icono: Icons.sos,
        descripcion: t.sosDescripcion,
        paso: '0.5.3',
        accion: FilledButton.icon(
          onPressed: () => abrirConCuenta(
            context,
            ref,
            destino: Rutas.sosNuevo,
            motivo: t.sosMotivoCuenta,
          ),
          icon: const Icon(Icons.add),
          label: Text(t.sosReportar),
        ),
      ),
    );
  }
}
