import 'package:sosmascota/src/mapa/filtros_guardados.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class AlmacenFiltrosFalso implements AlmacenFiltros {
  final guardados = <String, FiltrosMapa>{};

  @override
  Future<FiltrosMapa?> leer(String cuenta) async => guardados[cuenta];

  @override
  Future<void> guardar(String cuenta, FiltrosMapa filtros) async =>
      guardados[cuenta] = filtros;
}
