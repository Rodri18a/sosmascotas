import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sosmascota_core/sosmascota_core.dart';

/// Los textos ya traducidos que lleva el historial (los arma la pantalla).
typedef TextosHistorial = ({
  String titulo,
  List<(String, String)> datos,
  String sinRegistros,
  String Function(TipoRegistroSalud) grupo,
  String Function(DateTime) fecha,
  String Function(String) proxima,
  String pie,
});

/// Historial de salud en PDF (2.11, plan Pro, D112): los datos de la mascota y
/// la libreta agrupada, en A4, para imprimir o mandar a la veterinaria.
/// Se arma en el dispositivo: nada de la libreta sale a otro servidor.
/// [normal] y [negrita]: la letra de la app (con acentos y eñe); sin ellas,
/// la del PDF, que no los muestra bien.
Future<Uint8List> historialSaludPdf({
  required Map<TipoRegistroSalud, List<RegistroSalud>> grupos,
  required TextosHistorial textos,
  ByteData? normal,
  ByteData? negrita,
}) {
  final doc = pw.Document(
    title: textos.titulo,
    creator: 'Huellitas',
    theme: normal == null
        ? null
        : pw.ThemeData.withFont(
            base: pw.Font.ttf(normal),
            bold: negrita == null ? null : pw.Font.ttf(negrita),
          ),
  );
  const gris = PdfColor.fromInt(0xFF5F6B73);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (contexto) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${textos.pie} · ${contexto.pageNumber}/${contexto.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: gris),
        ),
      ),
      build: (_) => [
        pw.Text(
          textos.titulo,
          style: const pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        for (final (etiqueta, valor) in textos.datos)
          pw.Text('$etiqueta: $valor', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 16),
        if (grupos.isEmpty) pw.Text(textos.sinRegistros),
        for (final MapEntry(key: tipo, value: registros) in grupos.entries) ...[
          pw.Text(
            textos.grupo(tipo),
            style: const pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          for (final r in registros)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    [
                      r.nombre,
                      if (r.fecha case final f?) textos.fecha(f),
                    ].join(' · '),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  if (r.proxima case final p?)
                    pw.Text(
                      textos.proxima(textos.fecha(p)),
                      style: const pw.TextStyle(fontSize: 9, color: gris),
                    ),
                  if (r.notas case final n? when n.isNotEmpty)
                    pw.Text(
                      n,
                      style: const pw.TextStyle(fontSize: 9, color: gris),
                    ),
                ],
              ),
            ),
          pw.SizedBox(height: 10),
        ],
      ],
    ),
  );
  return doc.save();
}
