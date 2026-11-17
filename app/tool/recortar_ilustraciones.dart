// Recorta las ilustraciones de Ami y Mishi de las láminas generadas
// (`docs/guias/huellamy/`, D157) y les saca el fondo blanco o crema.
//
// Uso, desde app/:  dart run tool/recortar_ilustraciones.dart
//
// Cada pieza se recorta con coordenadas fijas. El fondo se borra solo si
// toca el borde del recorte (relleno por inundación): el blanco de adentro de
// los dibujos (ojos, hocicos, bordes de sticker) no se toca. Salen PNG
// transparentes de [_ladoMaximo] px como máximo en `assets/ilustraciones/`.
// El logo sale en `assets/marca/logo.png`, `web/icons/logo.png` (pantalla de
// carga) y `../web-publica/assets/logo.png`.
import 'dart:collection';
import 'dart:io';

import 'package:image/image.dart';

const _origen = '../docs/guias/huellamy';
const _destino = 'assets/ilustraciones';
const _ladoMaximo = 480;

class _Pieza {
  const _Pieza(
    this.nombre,
    this.archivo,
    this.x,
    this.y,
    this.ancho,
    this.alto,
  );
  final String nombre;
  final String archivo;
  final int x, y, ancho, alto;
}

const _y321 = 'Gemini_Generated_Image_y3211iy3211iy321.jpg';
const _gfs3 = 'Gemini_Generated_Image_gfs3sygfs3sygfs3.jpg';
// Láminas de pantallas del 17/11/2026 (D162).
const _g4ze = 'Gemini_Generated_Image_g4zea5g4zea5g4ze.jpg';
const _h9ut = 'Gemini_Generated_Image_h9utjgh9utjgh9ut.jpg';
const _ms5v = 'Gemini_Generated_Image_ms5vjmms5vjmms5v.jpg';

const _piezas = [
  // Bienvenida: Ami saludando con la patita.
  _Pieza('ami_saludando', _y321, 468, 52, 250, 245),
  // Éxito: Mishi festejando.
  _Pieza('mishi_festejando', _gfs3, 762, 52, 232, 214),
  // Carga y «Tus huellas»: los dos juntos.
  _Pieza('ami_y_mishi', _y321, 95, 62, 330, 190),
  // Paseos y contrataciones.
  _Pieza('ami_paseando', _y321, 299, 411, 182, 186),
  // Mascotas: Mishi jugando con la pluma.
  _Pieza('mishi_jugando', _y321, 799, 411, 180, 186),
  // Tienda y pedidos: los dos con el carrito.
  _Pieza('tienda', _y321, 40, 668, 540, 335),
  // Salud: recordatorios y libreta.
  _Pieza('salud', _gfs3, 30, 645, 475, 300),
  // Comunidad, Preguntas y Grupos.
  _Pieza('comunidad', _gfs3, 640, 400, 355, 195),
  // D162: bienvenida con los dos saludando.
  _Pieza('bienvenida', _g4ze, 55, 125, 420, 240),
  // D162: adopción (grupo con la cucha).
  _Pieza('adopcion', _g4ze, 565, 112, 285, 278),
  // D162: mascota perdida (megáfono y mapa).
  _Pieza('perdida', _g4ze, 378, 945, 195, 140),
  // D162: «Adoptá»: cachorro y gatito.
  _Pieza('adopta', _h9ut, 125, 650, 270, 175),
  // D162: caritas para la mascota sin foto (perro y gato).
  _Pieza('carita_perro', _h9ut, 683, 490, 85, 90),
  _Pieza('carita_gato', _h9ut, 778, 490, 88, 90),
  // D162: Ami con lentes (consejos y novedades).
  _Pieza('consejo', _ms5v, 615, 100, 345, 240),
  // D162: Mishi con termómetro (vacunas y alertas de salud).
  _Pieza('alerta_salud', _ms5v, 105, 600, 320, 210),
];

void main() {
  Directory(_destino).createSync(recursive: true);
  final cache = <String, Image>{};
  for (final p in _piezas) {
    final lamina = cache.putIfAbsent(
      p.archivo,
      () => decodeImage(File('$_origen/${p.archivo}').readAsBytesSync())!,
    );
    final recorte = copyCrop(
      lamina,
      x: p.x,
      y: p.y,
      width: p.ancho,
      height: p.alto,
    );
    _guardar(_sinFondo(recorte), '$_destino/${p.nombre}.png');
  }

  // Logo con fondo transparente (pendiente del 0.8.3f).
  final logo = _sinFondo(
    decodeImage(File('$_origen/logo-huellamy.png').readAsBytesSync())!,
  );
  _guardar(logo, 'assets/marca/logo.png');
  _guardar(logo, 'web/icons/logo.png', lado: 320);
  _guardar(logo, '../web-publica/assets/logo.png', lado: 320);
  stdout.writeln(
    '✅ ${_piezas.length} ilustraciones en $_destino y el logo transparente',
  );
}

void _guardar(Image imagen, String ruta, {int lado = _ladoMaximo}) {
  var salida = _recortarTransparente(imagen);
  if (salida.width > lado || salida.height > lado) {
    salida = salida.width >= salida.height
        ? copyResize(salida, width: lado, interpolation: Interpolation.cubic)
        : copyResize(salida, height: lado, interpolation: Interpolation.cubic);
  }
  File(ruta).writeAsBytesSync(encodePng(salida, level: 9));
}

/// ¿Es fondo? Claro y casi sin color (blanco, crema del papel).
bool _esFondo(Pixel p) {
  final r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
  final minimo = [r, g, b].reduce((a, c) => a < c ? a : c);
  final maximo = [r, g, b].reduce((a, c) => a > c ? a : c);
  return minimo >= 228 && maximo - minimo <= 22;
}

/// Borra el fondo conectado con el borde y suaviza el contorno.
Image _sinFondo(Image origen) {
  final img = origen.convert(numChannels: 4);
  final w = img.width, h = img.height;
  final fondo = List<bool>.filled(w * h, false);
  final cola = Queue<int>();
  void sembrar(int x, int y) {
    final i = y * w + x;
    if (!fondo[i] && _esFondo(img.getPixel(x, y))) {
      fondo[i] = true;
      cola.add(i);
    }
  }

  for (var x = 0; x < w; x++) {
    sembrar(x, 0);
    sembrar(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    sembrar(0, y);
    sembrar(w - 1, y);
  }
  while (cola.isNotEmpty) {
    final i = cola.removeFirst();
    final x = i % w, y = i ~/ w;
    if (x > 0) sembrar(x - 1, y);
    if (x < w - 1) sembrar(x + 1, y);
    if (y > 0) sembrar(x, y - 1);
    if (y < h - 1) sembrar(x, y + 1);
  }

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = img.getPixel(x, y);
      if (fondo[y * w + x]) {
        p.a = 0;
        continue;
      }
      // Borde: los píxeles claros pegados al fondo quedan semitransparentes,
      // así no queda un halo blanco sobre fondos de color.
      var vecinos = 0;
      for (final (dx, dy) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final nx = x + dx, ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < w && ny < h && fondo[ny * w + nx]) {
          vecinos++;
        }
      }
      if (vecinos > 0) {
        final claridad = (p.r + p.g + p.b) / 3;
        if (claridad > 200) p.a = (255 - (claridad - 200) * 3).clamp(90, 255);
      }
    }
  }
  return img;
}

/// Saca los márgenes totalmente transparentes.
Image _recortarTransparente(Image img) {
  var x0 = img.width, y0 = img.height, x1 = -1, y1 = -1;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (img.getPixel(x, y).a > 0) {
        if (x < x0) x0 = x;
        if (x > x1) x1 = x;
        if (y < y0) y0 = y;
        if (y > y1) y1 = y;
      }
    }
  }
  if (x1 < 0) return img;
  return copyCrop(img, x: x0, y: y0, width: x1 - x0 + 1, height: y1 - y0 + 1);
}
