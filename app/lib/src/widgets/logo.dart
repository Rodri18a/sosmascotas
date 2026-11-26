import 'package:flutter/material.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';

/// Logo de Huellamy (D146).
///
/// Vertical (pantallas de bienvenida): el logo ilustrado con Ami y Mishi
/// (`assets/marca/logo.png`) y la frase debajo. [horizontal] (cabeceras y
/// menú): el isotipo a la izquierda y «Huellamy» en letras, «Huell» en azul
/// profundo y «amy» en azul brillante. Con [tinta], todo de un solo color.
class LogoHuellamy extends StatelessWidget {
  const LogoHuellamy({
    this.horizontal = false,
    this.conFrase = true,
    this.alto = 40,
    this.tinta,
    super.key,
  });

  /// Logo ilustrado, con fondo transparente (D157,
  /// `tool/recortar_ilustraciones.dart`).
  static const imagen = 'assets/marca/logo.png';

  final bool horizontal;
  final bool conFrase;

  /// Alto de las letras de «Huellamy»; el resto se calcula a partir de él.
  final double alto;
  final Color? tinta;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final oscuro = tema.brightness == Brightness.dark;
    final colorTexto =
        tinta ?? (oscuro ? tema.colorScheme.onSurface : ColoresLogo.nombre);
    final frase = Text(
      t.logoFrase,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      // El logo va siempre con su letra (Nunito), aunque el tema use otra
      // (Dongle en el Moderno, D174): todavía no está definido en el manual.
      style: tema.textTheme.titleMedium?.copyWith(
        color: colorTexto,
        fontFamily: 'Nunito',
        fontSize: alto * 0.42,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    );

    if (!horizontal && tinta == null) {
      return Semantics(
        label: t.appNombre,
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagen,
              width: alto * 5,
              height: alto * 5,
              fit: BoxFit.contain,
            ),
            if (conFrase) ...[SizedBox(height: alto * 0.3), frase],
          ],
        ),
      );
    }

    final nombre = _Nombre(
      texto: t.logoNombre,
      alto: alto,
      color: colorTexto,
      acento:
          tinta ??
          (oscuro ? const Color(0xFF7CC4F5) : ColoresLogo.nombreAcento),
      centrado: !horizontal,
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
      tamanio: alto * (horizontal ? (conFrase ? 2 : 1.4) : 2.6),
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

/// «Huellamy» en dos colores: la parte después de «Huell» va en [acento].
class _Nombre extends StatelessWidget {
  const _Nombre({
    required this.texto,
    required this.alto,
    required this.color,
    required this.acento,
    required this.centrado,
  });

  final String texto;
  final double alto;
  final Color color;
  final Color acento;
  final bool centrado;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: color,
      fontFamily: 'Nunito',
      fontSize: alto,
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: -0.3,
    );
    final corte = texto.startsWith('Huell') ? 5 : texto.length;
    return Text.rich(
      TextSpan(
        style: estilo,
        children: [
          TextSpan(text: texto.substring(0, corte)),
          TextSpan(
            text: texto.substring(corte),
            style: TextStyle(color: acento),
          ),
        ],
      ),
      textAlign: centrado ? TextAlign.center : TextAlign.start,
    );
  }
}
