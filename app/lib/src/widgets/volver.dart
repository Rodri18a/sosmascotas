import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dos_apps/dos_apps.dart';
import '../router.dart';

/// Flecha para volver en las pantallas que se abren fuera de las pestañas.
/// Si se entró por un enlace directo, un aviso o después de ingresar, no hay
/// a dónde volver: la flecha lleva a [destino] (el inicio, o el panel del
/// negocio en Huellitas Comercios, D129, si no se indica).
/// Con algo detrás devuelve `null` y la barra pone la flecha de siempre.
Widget? volverSiNoHayAtras(BuildContext context, [String? destino]) {
  if (context.canPop()) return null;
  final ir =
      destino ??
      (ProviderScope.containerOf(
            context,
            listen: false,
          ).read(esAppComercioProvider)
          ? Rutas.negocio
          : Rutas.inicio);
  return BackButton(onPressed: () => context.go(ir));
}
