import 'package:sosmascota/src/push/servicio_push.dart';

class PushFalso implements ServicioPush {
  PushFalso({
    this.actual = EstadoPush.sinPedir,
    this.alPedirPermiso = EstadoPush.activado,
  });

  EstadoPush actual;

  /// Lo que "elige" la persona en el cartel del navegador.
  EstadoPush alPedirPermiso;
  int renovaciones = 0;
  int olvidos = 0;

  @override
  Future<EstadoPush> estado() async => actual;

  /// Simula que Firebase falla al dar el token (lanza un Error, no Exception).
  bool fallar = false;

  @override
  Future<EstadoPush> activar() async {
    if (fallar) throw StateError('sin token');
    return actual = alPedirPermiso;
  }

  @override
  Future<void> apagar() async => actual = EstadoPush.apagado;

  @override
  Future<void> renovar() async => renovaciones++;

  @override
  Future<void> olvidarDispositivo() async => olvidos++;
}
