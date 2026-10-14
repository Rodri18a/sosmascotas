import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaAyuda),
      actions: const [BotonAjustes()],
    ),
    body: EnConstruccion(
      icono: Icons.health_and_safety_outlined,
      descripcion: context.t.ayudaDescripcion,
      paso: '0.7.3',
    ),
  );
}
