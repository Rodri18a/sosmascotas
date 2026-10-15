import 'package:sosmascota/src/ubicacion/servicio_ubicacion.dart';

import 'perfil_falso.dart';

/// Permiso de ubicación simulado. Al guardar o borrar la zona actualiza el
/// perfil falso, como haría la base.
class UbicacionFalsa implements ServicioUbicacion {
  UbicacionFalsa(
    this.perfiles, {
    this.actual = EstadoUbicacion.sinPedir,
    this.alPedirPermiso = EstadoUbicacion.permitida,
  });

  final PerfilRepositorioFalso perfiles;
  EstadoUbicacion actual;

  /// Lo que "elige" la persona en el cartel del navegador.
  EstadoUbicacion alPedirPermiso;
  int activaciones = 0;
  int renovaciones = 0;

  @override
  Future<EstadoUbicacion> estado() async => actual;

  @override
  Future<EstadoUbicacion> activar() async {
    activaciones++;
    if (actual == EstadoUbicacion.sinPedir) actual = alPedirPermiso;
    if (actual == EstadoUbicacion.permitida) {
      perfiles.zonaAvisosEn = DateTime(2026, 10, 15);
    }
    return actual;
  }

  @override
  Future<bool> renovar() async {
    renovaciones++;
    return false;
  }

  @override
  Future<void> borrar() async => perfiles.zonaAvisosEn = null;
}
