import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class MascotasScreen extends StatelessWidget {
  const MascotasScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaMascotas),
      actions: const [BotonAjustes()],
    ),
    body: EnConstruccion(
      icono: Icons.pets,
      descripcion: context.t.mascotasDescripcion,
      paso: '0.3.4',
    ),
  );
}
