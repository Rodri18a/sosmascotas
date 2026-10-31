import 'package:flutter/material.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';

/// Logo completo: isotipo, «SOS Mascotas» y la frase de la marca.
///
/// [horizontal]: el isotipo a la izquierda (cabeceras); si no, arriba
/// (pantallas de bienvenida). Con [tinta], todo de un solo color.
class LogoSosMascotas extends StatelessWidget {
  const LogoSosMascotas({
    this.horizontal = false,
    this.conFrase = true,
    this.alto = 40,
    this.tinta,
    super.key,
  });

  final bool horizontal;
  final bool conFrase;

  /// Alto de las letras de «SOS»; el resto se calcula a partir de él.
  final double alto;
  final Color? tinta;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final oscuro = tema.brightness == Brightness.dark;
    final color =
        tinta ?? (oscuro ? tema.colorScheme.onSurface : ColoresLogo.nombre);
    final titulos = tema.textTheme.displaySmall;
    final nombre = Text(
      t.logoNombre,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      style: titulos?.copyWith(
        color: color,
        fontSize: alto,
        fontWeight: FontWeight.w700,
        height: 0.95,
        letterSpacing: -0.5,
      ),
    );
    final frase = Text(
      t.logoFrase,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      style: tema.textTheme.titleMedium?.copyWith(
        color: color,
        fontSize: alto * 0.4,
        fontWeight: FontWeight.w600,
      ),
    );
    final texto = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        nombre,
        if (conFrase) ...[SizedBox(height: alto * 0.2), frase],
      ],
    );
    final isotipo = Isotipo(
      tamanio: alto * (horizontal ? 2.4 : 2.6),
      tinta: tinta,
    );
    return Semantics(
      label: t.appNombre,
      excludeSemantics: true,
      child: horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isotipo,
                SizedBox(width: alto * 0.3),
                Flexible(child: texto),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isotipo,
                SizedBox(height: alto * 0.1),
                texto,
              ],
            ),
    );
  }
}
