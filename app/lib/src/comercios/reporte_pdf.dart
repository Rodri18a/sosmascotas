import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Una fila del reporte: qué se mide, cuánto este mes y cuánto el anterior.
typedef FilaReporte = (String etiqueta, int ahora, int antes);

/// Reporte mensual del comercio en PDF (2.10, portal de empresas, D114): las
/// cantidades del mes contra el anterior, para guardar o imprimir. Se arma en
/// el dispositivo con lo mismo que muestra la pantalla de estadísticas.
Future<Uint8List> reporteMensualPdf({
  required String titulo,
  required String subtitulo,
  required String encabezadoAntes,
  required String encabezadoAhora,
  required List<FilaReporte> filas,
  required String privacidad,
  required String pie,
  ByteData? normal,
  ByteData? negrita,
}) {
  final doc = pw.Document(
    title: titulo,
    creator: 'SOS Mascotas',
    theme: normal == null
        ? null
        : pw.ThemeData.withFont(
            base: pw.Font.ttf(normal),
            bold: negrita == null ? null : pw.Font.ttf(negrita),
          ),
  );
  const gris = PdfColor.fromInt(0xFF5F6B73);
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titulo,
            style: const pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(subtitulo, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['', encabezadoAntes, encabezadoAhora, ''],
            data: [
              for (final (etiqueta, ahora, antes) in filas)
                [etiqueta, '$antes', '$ahora', _variacion(ahora, antes)],
            ],
            cellAlignments: {
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: null,
            headerDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: gris)),
            ),
          ),
          pw.Spacer(),
          pw.Text(
            privacidad,
            style: const pw.TextStyle(fontSize: 9, color: gris),
          ),
          pw.SizedBox(height: 4),
          pw.Text(pie, style: const pw.TextStyle(fontSize: 8, color: gris)),
        ],
      ),
    ),
  );
  return doc.save();
}

String _variacion(int ahora, int antes) {
  if (antes == 0) return ahora == 0 ? '' : '+$ahora';
  final p = ((ahora - antes) * 100 / antes).round();
  return p == 0 ? '=' : (p > 0 ? '+$p %' : '$p %');
}
