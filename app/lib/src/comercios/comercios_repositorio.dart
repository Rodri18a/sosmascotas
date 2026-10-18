import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Lugares del mapa (comercios, refugios y lugares que aceptan mascotas). Se
/// reemplaza en las pruebas.
abstract interface class ComerciosRepositorio {
  /// Lugares con local dentro de la zona visible (regla de costo del mapa),
  /// de [categorias] (todas si es `null`).
  Future<List<Comercio>> enZona(Limites zona, {Set<Categoria>? categorias});

  /// "Sin local": tiendas online y servicios a domicilio (1.2.7, D75).
  Future<List<Comercio>> sinLocal({int? zonaId});

  /// Lugares marcados por usuarios en la zona visible (1.3.2, D77).
  Future<List<LugarSinReclamar>> sinReclamarEnZona(Limites zona);

  /// Marcar un lugar (solo el rubro y el punto; enlace de Google opcional).
  Future<void> marcar(Categoria rubro, Punto punto, {String? enlaceGoogle});

  /// "¿Es tu negocio?": reclamarlo (con el RUT para la insignia ✔️).
  Future<void> reclamar(String comercioId, {String? rut, String? nota});

  /// Enlace público de una foto de comercio.
  String urlFoto(String ruta);
}

/// Por qué no se pudo marcar o reclamar.
enum ErrorLugar { yaMarcado, demasiados, invalido, sinConexion }

class LugarException implements Exception {
  const LugarException(this.motivo);
  final ErrorLugar motivo;
}

ErrorLugar _motivo(PostgrestException e) => switch (e.code) {
  '23505' => ErrorLugar.yaMarcado,
  '54000' => ErrorLugar.demasiados,
  _ => ErrorLugar.invalido,
};

class SupabaseComerciosRepositorio implements ComerciosRepositorio {
  SupabaseComerciosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static List<String>? _tipos(Set<Categoria>? categorias) =>
      categorias?.map((c) => c.valor).toList();

  @override
  Future<List<Comercio>> enZona(
    Limites zona, {
    Set<Categoria>? categorias,
  }) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'lugares_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
        'p_tipos': _tipos(categorias),
      },
    );
    return filas.cast<Map<String, dynamic>>().map(Comercio.fromJson).toList();
  }

  @override
  Future<List<Comercio>> sinLocal({int? zonaId}) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'lugares_sin_local',
      params: {'p_zona': zonaId},
    );
    return filas.cast<Map<String, dynamic>>().map(Comercio.fromJson).toList();
  }

  @override
  Future<List<LugarSinReclamar>> sinReclamarEnZona(Limites zona) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'lugares_sin_reclamar_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
      },
    );
    return filas
        .cast<Map<String, dynamic>>()
        .map(LugarSinReclamar.fromJson)
        .toList();
  }

  Future<void> _traducir(Future<void> Function() accion) async {
    try {
      await accion();
    } on PostgrestException catch (e) {
      throw LugarException(_motivo(e));
    } on Exception {
      throw const LugarException(ErrorLugar.sinConexion);
    }
  }

  @override
  Future<void> marcar(Categoria rubro, Punto punto, {String? enlaceGoogle}) =>
      _traducir(
        () => _cliente.rpc<String>(
          'marcar_lugar',
          params: {
            'p_rubro': rubro.valor,
            'p_lat': punto.lat,
            'p_lng': punto.lng,
            'p_link': enlaceGoogle,
          },
        ),
      );

  @override
  Future<void> reclamar(String comercioId, {String? rut, String? nota}) =>
      _traducir(
        () => _cliente.rpc<String>(
          'reclamar_negocio',
          params: {'p_business': comercioId, 'p_rut': rut, 'p_nota': nota},
        ),
      );

  @override
  String urlFoto(String ruta) =>
      _cliente.storage.from('business-photos').getPublicUrl(ruta);
}

/// Sin Supabase configurado no hay comercios.
class ComerciosSinConfigurar implements ComerciosRepositorio {
  const ComerciosSinConfigurar();

  @override
  Future<List<Comercio>> enZona(
    Limites zona, {
    Set<Categoria>? categorias,
  }) async => const [];

  @override
  Future<List<Comercio>> sinLocal({int? zonaId}) async => const [];

  @override
  Future<List<LugarSinReclamar>> sinReclamarEnZona(Limites zona) async =>
      const [];

  @override
  Future<void> marcar(
    Categoria rubro,
    Punto punto, {
    String? enlaceGoogle,
  }) async => throw const LugarException(ErrorLugar.sinConexion);

  @override
  Future<void> reclamar(String comercioId, {String? rut, String? nota}) async =>
      throw const LugarException(ErrorLugar.sinConexion);

  @override
  String urlFoto(String ruta) => '';
}

final comerciosRepositorioProvider = Provider<ComerciosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ComerciosSinConfigurar()
      : SupabaseComerciosRepositorio(cliente);
});

/// Lugares sin local de la zona de la persona.
final sinLocalProvider = FutureProvider<List<Comercio>>(
  (ref) => ref.watch(comerciosRepositorioProvider).sinLocal(),
);
