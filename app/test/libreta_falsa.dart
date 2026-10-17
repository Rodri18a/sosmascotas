import 'package:sosmascota/src/mascotas/libreta_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Libreta sanitaria en memoria para las pruebas.
class LibretaFalsa implements LibretaRepositorio {
  LibretaFalsa([List<RegistroSalud>? iniciales]) : registros = [...?iniciales];

  final List<RegistroSalud> registros;
  bool fallar = false;
  int _siguiente = 1;

  @override
  Future<List<RegistroSalud>> deMascota(String mascotaId) async {
    if (fallar) throw Exception('sin internet');
    return registros.where((r) => r.mascotaId == mascotaId).toList();
  }

  @override
  Future<RegistroSalud> crear(RegistroSalud registro) async {
    if (fallar) throw Exception('sin internet');
    final guardado = RegistroSalud.fromJson({
      ...registro.toJson(),
      'id': 'registro-${_siguiente++}',
    });
    registros.add(guardado);
    return guardado;
  }

  @override
  Future<RegistroSalud> actualizar(RegistroSalud registro) async {
    if (fallar) throw Exception('sin internet');
    final guardado = RegistroSalud.fromJson({
      ...registro.toJson(),
      'id': registro.id,
    });
    registros[registros.indexWhere((r) => r.id == registro.id)] = guardado;
    return guardado;
  }

  @override
  Future<void> borrar(String id) async {
    if (fallar) throw Exception('sin internet');
    registros.removeWhere((r) => r.id == id);
  }
}
