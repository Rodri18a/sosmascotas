import 'package:flutter/material.dart';

import '../../widgets/boton_ajustes.dart';
import '../../widgets/en_construccion.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mapa'), actions: const [BotonAjustes()]),
    body: const EnConstruccion(
      icono: Icons.map_outlined,
      descripcion: 'Veterinarias de urgencia y mascotas perdidas cerca tuyo',
      paso: '0.5.2',
    ),
  );
}
