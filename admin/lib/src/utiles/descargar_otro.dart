import 'dart:typed_data';

/// El portal solo corre en la web.
bool descargarArchivo(Uint8List bytes, String nombre, String tipo) => false;

void abrirEnlace(String url) {}

Future<({Uint8List bytes, String tipo})?> elegirImagen() async => null;
