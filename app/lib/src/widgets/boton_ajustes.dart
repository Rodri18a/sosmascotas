import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../router.dart';

/// Ícono de Ajustes para la barra superior de las pestañas.
class BotonAjustes extends StatelessWidget {
  const BotonAjustes({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.settings_outlined),
    tooltip: context.t.ajustes,
    onPressed: () => context.push(Rutas.ajustes),
  );
}
