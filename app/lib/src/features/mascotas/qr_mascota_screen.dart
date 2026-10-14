import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../widgets/en_construccion.dart';

/// Chapita QR de la mascota (se completa en el paso 0.4.2).
class QrMascotaScreen extends StatelessWidget {
  const QrMascotaScreen({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t.fichaQrTitulo)),
    body: EnConstruccion(
      icono: Icons.qr_code_2,
      descripcion: context.t.fichaQrDescripcion,
      paso: '0.4.2',
    ),
  );
}
