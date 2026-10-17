import 'package:sosmascota/src/utiles/respaldo.dart';

/// Copias locales en memoria para las pruebas.
class AlmacenRespaldoFalso implements AlmacenRespaldo {
  final datos = <String, String>{};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async =>
      datos[clave] = valor;

  @override
  Future<void> borrarTodo() async => datos.clear();
}
