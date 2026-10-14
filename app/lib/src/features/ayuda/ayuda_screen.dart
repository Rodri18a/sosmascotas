import 'package:flutter/material.dart';

import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ayuda'), actions: const [BotonAjustes()]),
    body: const EnConstruccion(
      icono: Icons.health_and_safety_outlined,
      descripcion: 'Urgencias, refugios y grupos de difusión de tu zona',
      paso: '0.7.3',
    ),
  );
}
