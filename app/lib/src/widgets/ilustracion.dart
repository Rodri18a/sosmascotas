import 'package:flutter/material.dart';

/// Ilustraciones de Ami y Mishi (D157), recortadas de las láminas de marca
/// con `tool/recortar_ilustraciones.dart`. Son decorativas: los lectores de
/// pantalla no las leen (el texto de al lado dice lo importante).
enum Ilustracion {
  /// Ami saludando con la patita: bienvenida, avisos.
  amiSaludando('ami_saludando'),

  /// Mishi festejando: logros y cosas que salieron bien.
  mishiFestejando('mishi_festejando'),

  /// Los dos juntos.
  amiYMishi('ami_y_mishi'),

  /// Ami paseando con correa: paseos, guardería y estadías.
  amiPaseando('ami_paseando', escena: true),

  /// Mishi jugando con una pluma: mascotas.
  mishiJugando('mishi_jugando', escena: true),

  /// Los dos con el carrito: tienda y pedidos.
  tienda('tienda'),

  /// Calendario con estetoscopio: salud, libreta, recordatorios y turnos.
  salud('salud'),

  /// Ami, un perro y Mishi: comunidad, preguntas y conversaciones.
  comunidad('comunidad');

  const Ilustracion(this._archivo, {this.escena = false});

  final String _archivo;

  /// Escena con fondo propio (cuadrada): se muestra con esquinas redondeadas.
  final bool escena;

  String get ruta => 'assets/ilustraciones/$_archivo.png';
}

/// Muestra una [Ilustracion] con [alto] como máximo.
class ImagenIlustracion extends StatelessWidget {
  const ImagenIlustracion(this.ilustracion, {this.alto = 140, super.key});

  final Ilustracion ilustracion;
  final double alto;

  @override
  Widget build(BuildContext context) {
    Widget imagen = Image.asset(
      ilustracion.ruta,
      height: alto,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      // Si no carga, no rompe la pantalla: queda el texto.
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
    if (ilustracion.escena) {
      imagen = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imagen,
      );
    }
    return imagen;
  }
}

/// Estado vacío con dibujo: la ilustración arriba y el texto centrado.
class VacioIlustrado extends StatelessWidget {
  const VacioIlustrado(
    this.ilustracion,
    this.texto, {
    this.alto = 140,
    super.key,
  });

  final Ilustracion ilustracion;
  final String texto;
  final double alto;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ImagenIlustracion(ilustracion, alto: alto),
      const SizedBox(height: 16),
      Text(texto, textAlign: TextAlign.center),
    ],
  );
}
