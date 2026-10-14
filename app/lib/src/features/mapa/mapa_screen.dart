import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/en_construccion.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaMapa),
      actions: const [BotonAvisos(), BotonAjustes()],
    ),
    body: EnConstruccion(
      icono: Icons.map_outlined,
      descripcion: context.t.mapaDescripcion,
      paso: '0.5.2',
    ),
  );
}
