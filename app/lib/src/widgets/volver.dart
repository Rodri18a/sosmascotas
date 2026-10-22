import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

/// Flecha para volver en las pantallas que se abren fuera de las pestañas.
/// Si se entró por un enlace directo, un aviso o después de ingresar, no hay
/// a dónde volver: la flecha lleva a [destino] (el mapa, si no se indica).
/// Con algo detrás devuelve `null` y la barra pone la flecha de siempre.
Widget? volverSiNoHayAtras(
  BuildContext context, [
  String destino = Rutas.mapa,
]) =>
    context.canPop() ? null : BackButton(onPressed: () => context.go(destino));
