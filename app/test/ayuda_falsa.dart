import 'package:sosmascota/src/ayuda/ayuda_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Directorio de Ayuda en memoria para las pruebas.
class AyudaFalsa implements AyudaRepositorio {
  AyudaFalsa([this.entradas = const []]);

  final List<EntradaAyuda> entradas;

  @override
  Future<List<EntradaAyuda>> directorio() async => entradas;
}
