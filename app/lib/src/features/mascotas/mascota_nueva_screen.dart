import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/en_construccion.dart';

/// Requiere cuenta (ver `Rutas.requierenCuenta`).
class MascotaNuevaScreen extends StatelessWidget {
  const MascotaNuevaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.mascotaNuevaTitulo)),
    body: EnConstruccion(
      icono: Icons.pets,
      descripcion: context.t.mascotaNuevaDescripcion,
      paso: '0.3.3',
    ),
  );
}
