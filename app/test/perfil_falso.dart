import 'package:sosmascota/src/cuenta/perfil_repositorio.dart';
import 'package:sosmascota/src/legal/legal.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Perfiles en memoria para las pruebas.
class PerfilRepositorioFalso implements PerfilRepositorio {
  PerfilRepositorioFalso({bool aceptoTerminos = true})
    : _acepto = aceptoTerminos;

  bool _acepto;
  String nombre = 'Ana';
  int radioAvisosKm = 5;
  int aceptaciones = 0;
  bool fallar = false;

  @override
  Future<Perfil?> obtener(String id) async => Perfil(
    id: id,
    nombre: nombre,
    plan: Plan.free,
    radioAvisosKm: radioAvisosKm,
    versionTerminos: _acepto ? versionTerminos : null,
    terminosAceptadosEn: _acepto ? DateTime(2026, 10, 14) : null,
  );

  @override
  Future<void> aceptarTerminos(String id, String version) async {
    if (fallar) throw Exception('sin internet');
    aceptaciones++;
    _acepto = true;
  }

  @override
  Future<void> actualizar(
    String id, {
    String? nombre,
    int? radioAvisosKm,
  }) async {
    if (fallar) throw Exception('sin internet');
    if (nombre != null) this.nombre = nombre;
    if (radioAvisosKm != null) this.radioAvisosKm = radioAvisosKm;
  }
}
