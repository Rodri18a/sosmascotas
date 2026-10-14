import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/en_construccion.dart';

/// Requiere cuenta (ver `Rutas.requierenCuenta`).
class SosNuevoScreen extends StatelessWidget {
  const SosNuevoScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.sosNuevoTitulo)),
    body: EnConstruccion(
      icono: Icons.edit_location_alt_outlined,
      descripcion: context.t.sosNuevoDescripcion,
      paso: '0.5.3',
    ),
  );
}
