import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre un enlace (teléfono, WhatsApp, mapa, web) fuera de la app. Se
/// reemplaza en las pruebas para ver qué se abrió.
typedef AbrirEnlace = Future<bool> Function(Uri enlace);

final abrirEnlaceProvider = Provider<AbrirEnlace>(
  (ref) =>
      (enlace) => launchUrl(enlace, mode: LaunchMode.externalApplication),
);

/// La hora actual. Se reemplaza en las pruebas ("abierto ahora").
final relojProvider = Provider<DateTime Function()>((ref) => DateTime.now);
