import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaSos),
      actions: const [BotonAjustes()],
    ),
    body: EnConstruccion(
      icono: Icons.sos,
      descripcion: context.t.sosDescripcion,
      paso: '0.5.3',
    ),
  );
}
