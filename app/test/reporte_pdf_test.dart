import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/comercios/reporte_pdf.dart';

void main() {
  test('arma el reporte mensual en PDF', () async {
    ByteData fuente(String nombre) => ByteData.sublistView(
      File('assets/fuentes/$nombre.ttf').readAsBytesSync(),
    );
    final bytes = await reporteMensualPdf(
      titulo: 'Reporte de septiembre de 2026',
      subtitulo: 'Peluquería Luna',
      encabezadoAntes: 'agosto de 2026',
      encabezadoAhora: 'septiembre de 2026',
      filas: const [('Aperturas de la ficha', 340, 200), ('Reseñas', 0, 0)],
      privacidad: 'Solo cantidades: nunca se muestra quién fue.',
      pie: 'Hecho con SOS Mascotas',
      normal: fuente('SourceSans3-Regular'),
      negrita: fuente('SourceSans3-Bold'),
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
  });
}
