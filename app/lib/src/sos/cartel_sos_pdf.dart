import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Los textos ya traducidos que lleva el cartel (los arma la pantalla).
typedef TextosCartel = ({
  String titulo,
  String subtitulo,
  String datos,
  String? senas,
  String? descripcion,
  String cuando,
  String? donde,
  String escanea,
  String privacidad,
  String pie,
});

/// Cartel A4 de un SOS para imprimir y pegar en el barrio (D119): foto
/// grande, los datos públicos del reporte y un QR a su página pública, donde
/// quien la vio avisa sin cuenta (contacto inverso). Nunca lleva teléfono ni
/// recompensa. Abrir esa página no avisa a nadie: solo el formulario.
/// [perdida]: «SE BUSCA» en rojo; si no, «SE ENCONTRÓ» en el color de la app.
Future<Uint8List> cartelSosPdf({
  required TextosCartel textos,
  required String url,
  required bool perdida,
  Uint8List? foto,
  Uint8List? logo,
  ByteData? normal,
  ByteData? negrita,
}) {
  final doc = pw.Document(
    title: textos.titulo,
    creator: 'Huellamy',
    theme: normal == null
        ? null
        : pw.ThemeData.withFont(
            base: pw.Font.ttf(normal),
            bold: negrita == null ? null : pw.Font.ttf(negrita),
          ),
  );
  final color = perdida
      ? const PdfColor.fromInt(0xFFC62828)
      : const PdfColor.fromInt(0xFF00796B);
  const gris = PdfColor.fromInt(0xFF5F6B73);
  final imagen = foto == null ? null : _imagen(foto);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 12),
            color: color,
            child: pw.Text(
              textos.titulo,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(
                color: PdfColors.white,
                fontSize: 48,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            textos.subtitulo,
            textAlign: pw.TextAlign.center,
            maxLines: 1,
            style: pw.TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (imagen != null)
            pw.Expanded(
              child: pw.Center(child: pw.Image(imagen, fit: pw.BoxFit.contain)),
            )
          else
            pw.Spacer(),
          pw.SizedBox(height: 8),
          pw.Text(
            textos.datos,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          for (final linea in [?textos.senas, ?textos.descripcion])
            pw.Text(
              linea,
              textAlign: pw.TextAlign.center,
              maxLines: 3,
              style: const pw.TextStyle(fontSize: 16),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            [textos.cuando, ?textos.donde].join(' · '),
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 14, color: gris),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: color, width: 2),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                // Corrección alta: se sigue leyendo con el papel gastado.
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(
                    errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
                  ),
                  data: url,
                  width: 130,
                  height: 130,
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        textos.escanea,
                        style: const pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        textos.privacidad,
                        style: const pw.TextStyle(fontSize: 11, color: gris),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          // El pie con el isotipo de la marca (D122), si se pasó.
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (logo case final logo?) ...[
                pw.Image(pw.MemoryImage(logo), width: 18, height: 18),
                pw.SizedBox(width: 6),
              ],
              pw.Flexible(
                child: pw.Text(
                  textos.pie,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 9, color: gris),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

/// La foto del reporte, o nada si no es una imagen que el PDF entienda.
pw.ImageProvider? _imagen(Uint8List bytes) {
  try {
    return pw.MemoryImage(bytes);
  } on Object {
    return null;
  }
}
