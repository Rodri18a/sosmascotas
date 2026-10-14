import 'package:flutter/material.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mapa/mapa_vista.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';

/// Mapa (Fase 0): perdidos, encontrados y veterinarias de urgencia de la zona.
class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaMapa),
      actions: const [BotonAvisos(), BotonAjustes()],
    ),
    body: const MapaVista(centro: centroPando),
  );
}
