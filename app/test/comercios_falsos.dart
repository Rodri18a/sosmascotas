import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Comercios en memoria para las pruebas (la capa del mapa llega en 0.7.2).
class ComerciosFalsos implements ComerciosRepositorio {
  ComerciosFalsos([this.comercios = const []]);

  final List<Comercio> comercios;
  final zonasConsultadas = <Limites>[];

  @override
  Future<List<Comercio>> enZona(Limites zona, {String tipo = 'vet'}) async {
    zonasConsultadas.add(zona);
    return [
      for (final c in comercios)
        if (c.tipo == tipo &&
            c.punto.lat >= zona.minLat &&
            c.punto.lat <= zona.maxLat &&
            c.punto.lng >= zona.minLng &&
            c.punto.lng <= zona.maxLng)
          c,
    ];
  }
}
