import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/en_construccion.dart';

/// Detalle público de un SOS (se completa en el paso 0.5.5).
class SosDetalleScreen extends StatelessWidget {
  const SosDetalleScreen({required this.sosId, super.key});

  final String sosId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.sosDetalleTitulo)),
    body: EnConstruccion(
      icono: Icons.campaign_outlined,
      descripcion: context.t.sosPublicado,
      paso: '0.5.5',
    ),
  );
}
