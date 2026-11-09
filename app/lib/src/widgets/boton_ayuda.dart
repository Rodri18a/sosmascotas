import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../recorrido/recorrido.dart';
import 'boton_avisos.dart';
import 'boton_mensajes.dart';

/// Botón ? de arriba a la derecha (plan de mejoras 1.3, D130): vuelve a
/// mostrar el recorrido guiado de la pantalla. Siempre el mismo ícono y lugar.
class BotonAyuda extends StatelessWidget {
  const BotonAyuda({super.key});

  @override
  Widget build(BuildContext context) => MarcaRecorrido(
    'ayuda',
    child: IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: context.t.recorridoBoton,
      onPressed: () => ZonaRecorrido.de(context)?.mostrar(),
    ),
  );
}

/// Acciones de arriba a la derecha en las pestañas: Mensajes, Avisos y ?.
List<Widget> accionesPestana({List<Widget> antes = const []}) => [
  ...antes,
  const MarcaRecorrido(
    'avisos',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [BotonMensajes(), BotonAvisos()],
    ),
  ),
  const BotonAyuda(),
];

/// Título de una pestaña: si no entra (pantalla angosta o letra agrandada),
/// se achica en lugar de cortarse (D152).
class TituloPestana extends StatelessWidget {
  const TituloPestana(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: AlignmentDirectional.centerStart,
    child: Text(texto, maxLines: 1),
  );
}

/// El botón ☰, marcado para el recorrido.
const botonMenu = MarcaRecorrido('menu', child: DrawerButton());
