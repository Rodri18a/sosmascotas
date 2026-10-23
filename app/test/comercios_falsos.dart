import 'dart:typed_data';

import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota/src/comercios/mis_lugares.dart';
import 'package:sosmascota/src/comercios/negocios_repositorio.dart';
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

  List<LugarSinReclamar> sinReclamar = [];
  final marcados = <(Categoria, Punto, String?)>[];
  final reclamos = <(String, String?, String?)>[];
  ErrorLugar? fallarCon;

  @override
  Future<List<LugarSinReclamar>> sinReclamarEnZona(Limites zona) async =>
      sinReclamar;

  @override
  Future<void> marcar(
    Categoria rubro,
    Punto punto, {
    String? enlaceGoogle,
  }) async {
    if (fallarCon case final m?) throw LugarException(m);
    marcados.add((rubro, punto, enlaceGoogle));
  }

  @override
  Future<void> reclamar(String comercioId, {String? rut, String? nota}) async {
    if (fallarCon case final m?) throw LugarException(m);
    reclamos.add((comercioId, rut, nota));
  }

  @override
  String urlFoto(String ruta) => 'https://fotos.ejemplo.uy/$ruta';

  final busquedas = <(String, Categoria?)>[];

  /// Busca como la base: por nombre (sin tildes) o por rubro; zona 1.
  @override
  Future<ResultadoBusqueda> buscar(
    String texto, {
    required Punto desde,
    Categoria? rubro,
  }) async {
    busquedas.add((texto, rubro));
    final t = normalizarBusqueda(texto);
    return (
      zona: 1,
      lugares: [
        for (final c in comercios)
          if (normalizarBusqueda(c.nombre).contains(t) || c.categoria == rubro)
            c,
      ],
    );
  }
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

/// Mis negocios en memoria para las pruebas.
class NegociosFalsos implements NegociosRepositorio {
  NegociosFalsos([List<MiNegocio>? iniciales]) : negocios = [...?iniciales];

  final List<MiNegocio> negocios;
  final altas = <Map<String, Object?>>[];
  final ediciones = <(String, Map<String, Object?>)>[];
  final verificaciones = <(String, String)>[];
  final renac = <String>[];
  final fotosSubidas = <String>[];
  PanelNegocio panelFijo = const PanelNegocio({
    'aperturas': 40,
    'aperturas_antes': 25,
    'clics': {'llamar': 6, 'como_llegar': 9},
    'favoritos': 4,
    'visitas': 3,
    'socios': 2,
  });

  @override
  Future<List<MiNegocio>> misNegocios() async => List.of(negocios);

  @override
  Future<String> alta(Map<String, Object?> datos) async {
    altas.add(datos);
    final id = 'negocio-${altas.length}';
    negocios.add(
      MiNegocio.fromJson({
        ...datos,
        'id': id,
        'verification': 'unverified',
        'status': 'active',
      }),
    );
    return id;
  }

  @override
  Future<void> editar(String id, Map<String, Object?> datos) async =>
      ediciones.add((id, datos));

  @override
  Future<void> pedirVerificacion(String id, String rut) async =>
      verificaciones.add((id, rut));

  @override
  Future<void> pedirInsigniaRenac(String id) async => renac.add(id);

  @override
  Future<PanelNegocio> panel(String id, {int dias = 30}) async => panelFijo;

  @override
  Future<void> subirFoto(String id, Uint8List jpeg) async =>
      fotosSubidas.add(id);

  @override
  Future<void> borrarFoto(String id, String ruta) async {}
}
