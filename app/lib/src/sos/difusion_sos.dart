import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cuenta/servicio_cuenta.dart';
import 'sos_repositorio.dart';

/// Avisa a quienes están cerca cuando se publica un SOS. Si no se pudo (sin
/// conexión), el SOS queda pendiente y se reintenta al volver a abrir la app:
/// la función del servidor no avisa dos veces por el mismo SOS.
class DifusionSos {
  DifusionSos(this._repo);

  final SosRepositorio _repo;

  static const _clave = 'sos.difusion_pendiente';

  /// No lanza errores: se llama sin esperar, después de publicar.
  Future<void> difundir(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _clave,
        {...?prefs.getStringList(_clave), id}.toList(),
      );
      await _intentar(prefs, id);
    } on Exception catch (e) {
      debugPrint('[sos] No se pudo avisar a la zona: $e');
    }
  }

  Future<void> reintentarPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in prefs.getStringList(_clave) ?? const <String>[]) {
      await _intentar(prefs, id);
    }
  }

  Future<void> _intentar(SharedPreferences prefs, String id) async {
    if (!await _repo.difundirEnZona(id)) {
      debugPrint('[sos] No se pudo avisar a la zona; se reintenta al abrir.');
      return;
    }
    final pendientes = prefs.getStringList(_clave) ?? const <String>[];
    await prefs.setStringList(_clave, [...pendientes.where((p) => p != id)]);
  }
}

final difusionSosProvider = Provider<DifusionSos>(
  (ref) => DifusionSos(ref.watch(sosRepositorioProvider)),
);

/// Al abrir la app o iniciar sesión, reintenta los SOS que no se difundieron.
/// Se mantiene vivo desde la raíz de la app.
final reintentarDifusionProvider = Provider<void>((ref) {
  ref.listen(usuarioActualProvider, (_, usuario) {
    if (usuario.value == null) return;
    unawaited(
      ref.read(difusionSosProvider).reintentarPendientes().catchError((
        Object e,
      ) {
        debugPrint('[sos] No se pudieron reintentar los avisos: $e');
      }),
    );
  }, fireImmediately: true);
});
