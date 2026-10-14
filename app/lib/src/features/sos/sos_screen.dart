import 'package:flutter/material.dart';

import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SOS'), actions: const [BotonAjustes()]),
    body: const EnConstruccion(
      icono: Icons.sos,
      descripcion: 'Reportá una mascota perdida o encontrada',
      paso: '0.5.3',
    ),
  );
}
