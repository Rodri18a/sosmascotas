// Genera los íconos de la web instalable (PWA) y el favicon (paso 0.8.1).
//
// Uso (desde app/): dart run tool/generar_iconos.dart
//
// Íconos PROVISORIOS con la identidad Cielo (D62): huella hueso sobre azul
// petróleo. Cuando esté el logo de 0.0.9b, se cambia `_dibujarMarca` (o se
// carga el PNG del logo) y se vuelve a correr: los tamaños y nombres quedan.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

final _petroleo = img.ColorRgba8(0x0F, 0x5E, 0x7A, 0xFF);
final _hueso = img.ColorRgba8(0xF6, 0xF4, 0xEF, 0xFF);

/// Se dibuja grande y se achica, para que los bordes salgan suaves.
const _sobremuestreo = 4;

void main() {
  final salida = Directory('web/icons')..createSync(recursive: true);
  // Comunes: la huella ocupa casi todo. Maskable: dentro de la zona segura
  // (círculo del 80 %), porque Android recorta el ícono con su forma.
  _guardar(_icono(192, escala: 0.78), '${salida.path}/Icon-192.png');
  _guardar(_icono(512, escala: 0.78), '${salida.path}/Icon-512.png');
  _guardar(_icono(192, escala: 0.58), '${salida.path}/Icon-maskable-192.png');
  _guardar(_icono(512, escala: 0.58), '${salida.path}/Icon-maskable-512.png');
  // iPhone ("Agregar a inicio"): sin transparencia, iOS redondea solo.
  _guardar(_icono(180, escala: 0.72), '${salida.path}/apple-touch-icon.png');
  _guardar(_icono(48, escala: 0.86), 'web/favicon.png');
  stdout.writeln('Íconos generados en web/icons/ y web/favicon.png');
}

img.Image _icono(int lado, {required double escala}) {
  final grande = lado * _sobremuestreo;
  final lienzo = img.Image(width: grande, height: grande, numChannels: 4);
  img.fill(lienzo, color: _petroleo);
  _dibujarMarca(lienzo, escala);
  return img.copyResize(
    lienzo,
    width: lado,
    height: lado,
    interpolation: img.Interpolation.average,
  );
}

/// Huella: almohadilla y cuatro dedos. Coordenadas de 0 a 1 respecto de un
/// cuadrado centrado de tamaño [escala].
void _dibujarMarca(img.Image lienzo, double escala) {
  final lado = lienzo.width.toDouble();
  final margen = (1 - escala) / 2;
  Point<double> p(double x, double y) =>
      Point((margen + x * escala) * lado, (margen + y * escala) * lado);
  double r(double v) => v * escala * lado;

  // Almohadilla.
  _elipse(lienzo, p(0.5, 0.66), r(0.25), r(0.2), 0);
  // Dedos, de izquierda a derecha.
  _elipse(lienzo, p(0.17, 0.42), r(0.1), r(0.13), -0.35);
  _elipse(lienzo, p(0.37, 0.24), r(0.1), r(0.135), -0.12);
  _elipse(lienzo, p(0.63, 0.24), r(0.1), r(0.135), 0.12);
  _elipse(lienzo, p(0.83, 0.42), r(0.1), r(0.13), 0.35);
}

void _elipse(
  img.Image lienzo,
  Point<double> centro,
  double rx,
  double ry,
  double giro,
) {
  const lados = 96;
  final vertices = <img.Point>[
    for (var i = 0; i < lados; i++)
      () {
        final a = 2 * pi * i / lados;
        final x = rx * cos(a);
        final y = ry * sin(a);
        return img.Point(
          centro.x + x * cos(giro) - y * sin(giro),
          centro.y + x * sin(giro) + y * cos(giro),
        );
      }(),
  ];
  img.fillPolygon(lienzo, vertices: vertices, color: _hueso);
}

void _guardar(img.Image imagen, String ruta) {
  // Sin canal alfa: ningún ícono tiene transparencia.
  final rgb = imagen.convert(numChannels: 3);
  File(ruta).writeAsBytesSync(img.encodePng(rgb));
}
