import 'package:sosmascota/src/theme/tema_elegido.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Tema guardado en memoria para las pruebas.
class AlmacenTemaFalso implements AlmacenTema {
  AlmacenTemaFalso([this.guardado]);

  String? guardado;

  @override
  Future<String?> leer() async => guardado;

  @override
  Future<void> guardar(String id) async => guardado = id;
}

/// Las pruebas no bajan tipografías; solo anotan qué temas se pidieron.
class FuentesFalsas implements CargadorFuentes {
  const FuentesFalsas([this.pedidas]);

  final List<String>? pedidas;

  @override
  Future<void> cargar(Paleta paleta) async => pedidas?.add(paleta.id);
}
