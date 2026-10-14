import 'package:flutter/material.dart';

import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class MascotasScreen extends StatelessWidget {
  const MascotasScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis mascotas'),
      actions: const [BotonAjustes()],
    ),
    body: const EnConstruccion(
      icono: Icons.pets,
      descripcion: 'Tus mascotas, su ficha y su chapita QR',
      paso: '0.3.4',
    ),
  );
}
