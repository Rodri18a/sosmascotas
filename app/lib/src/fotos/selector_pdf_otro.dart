import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Elige un PDF en Android y iPhone con `file_picker`.
Future<Uint8List?> elegirPdf() async {
  final archivo = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
  );
  return archivo?.readAsBytes();
}
