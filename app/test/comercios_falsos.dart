import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota/src/comercios/mis_lugares.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Lugares en memoria para las pruebas.
class ComerciosFalsos implements ComerciosRepositorio {
  ComerciosFalsos([this.comercios = const []]);

  final List<Comercio> comercios;
  final zonasConsultadas = <Limites>[];
  final categoriasPedidas = <Set<Categoria>?>[];

  @override
  Future<List<Comercio>> enZona(
    Limites zona, {
    Set<Categoria>? categorias,
  }) async {
    zonasConsultadas.add(zona);
    categoriasPedidas.add(categorias);
    return [
      for (final c in comercios)
        if (c.punto case final p?)
          if ((categorias == null || categorias.contains(c.categoria)) &&
              p.lat >= zona.minLat &&
              p.lat <= zona.maxLat &&
              p.lng >= zona.minLng &&
              p.lng <= zona.maxLng)
            c,
    ];
  }

  @override
  Future<List<Comercio>> sinLocal({int? zonaId}) async => [
    for (final c in comercios)
      if (c.punto == null) c,
  ];
}

/// Favoritos, "fui" y "mi veterinaria" en memoria.
class MisLugaresFalsos implements MisLugaresRepositorio {
  MisLugaresFalsos([Map<String, LugarMio>? iniciales])
    : lugares = {...?iniciales};

  final Map<String, LugarMio> lugares;

  @override
  Future<List<LugarMio>> misLugares() async => lugares.values.toList();

  @override
  Future<void> marcar(
    String comercioId, {
    bool? favorito,
    bool? fui,
    bool? miVeterinaria,
  }) async {
    final antes = lugares[comercioId] ?? LugarMio(comercioId: comercioId);
    if (miVeterinaria ?? false) {
      lugares.updateAll(
        (id, l) =>
            LugarMio(comercioId: id, favorito: l.favorito, fuiEn: l.fuiEn),
      );
    }
    lugares[comercioId] = LugarMio(
      comercioId: comercioId,
      favorito: favorito ?? antes.favorito,
      fuiEn: fui == null ? antes.fuiEn : (fui ? DateTime(2026, 10, 17) : null),
      miVeterinaria: miVeterinaria ?? antes.miVeterinaria,
    );
  }
}
