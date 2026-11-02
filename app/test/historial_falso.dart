import 'dart:typed_data';

import 'package:sosmascota/src/mascotas/historial_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Historial de vida en memoria: anota lo que se sube y lo que se borra.
class HistorialFalso implements HistorialRepositorio {
  HistorialFalso([List<AcontecimientoVida> inicial = const []])
    : guardados = [...inicial];

  final List<AcontecimientoVida> guardados;
  final subidos = <String>[];
  final borrados = <String>[];
  var _siguiente = 0;

  @override
  Future<List<AcontecimientoVida>> deMascota(String mascotaId) async => [
    for (final a in guardados)
      if (a.mascotaId == mascotaId) a,
  ];

  @override
  Future<AcontecimientoVida> crear(AcontecimientoVida a) async {
    final nuevo = AcontecimientoVida.fromJson({
      ...a.toJson(),
      'id': 'v${guardados.length + 1}',
    });
    guardados.add(nuevo);
    return nuevo;
  }

  @override
  Future<AcontecimientoVida> actualizar(AcontecimientoVida a) async {
    final i = guardados.indexWhere((g) => g.id == a.id);
    guardados[i] = AcontecimientoVida.fromJson({...a.toJson(), 'id': a.id});
    return guardados[i];
  }

  @override
  Future<void> borrar(String id) async =>
      guardados.removeWhere((a) => a.id == id);

  @override
  Future<String> subirAdjunto(
    String mascotaId,
    Uint8List bytes, {
    required bool pdf,
  }) async {
    final ruta = '$mascotaId/a${_siguiente++}.${pdf ? 'pdf' : 'jpg'}';
    subidos.add(ruta);
    return ruta;
  }

  @override
  Future<void> borrarAdjuntos(List<String> rutas) async =>
      borrados.addAll(rutas);

  @override
  Future<String?> urlAdjunto(String ruta) async => 'https://firmado/$ruta';
}
