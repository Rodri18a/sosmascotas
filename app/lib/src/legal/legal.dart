import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Versión vigente de los términos y la política de privacidad.
/// Si cambia, se le vuelve a pedir el consentimiento a todos (D51).
const versionTerminos = '2026-10-14-borrador';

enum DocumentoLegal {
  terminos('assets/legal/terminos.md'),
  privacidad('assets/legal/privacidad.md');

  const DocumentoLegal(this.archivo);

  final String archivo;
}

final textoLegalProvider = FutureProvider.family<String, DocumentoLegal>(
  (ref, documento) => rootBundle.loadString(documento.archivo),
);
