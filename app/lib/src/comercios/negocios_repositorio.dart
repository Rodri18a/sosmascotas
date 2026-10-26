import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Contadores del panel del comercio (`panel_negocio()`, 1.3.6).
class PanelNegocio {
  const PanelNegocio(this.datos);

  final Map<String, Object?> datos;

  int entero(String clave) => (datos[clave] as num?)?.toInt() ?? 0;

  Map<String, int> get clics => {
    for (final MapEntry(:key, :value)
        in ((datos['clics'] as Map?) ?? const {}).entries)
      key as String: (value as num).toInt(),
  };
}

/// Los negocios de la persona (modo comercio, 1.3, D77). Se reemplaza en las
/// pruebas.
abstract interface class NegociosRepositorio {
  Future<List<MiNegocio>> misNegocios();

  /// Alta (opción C): aparece al instante como "no verificado". Devuelve el id.
  Future<String> alta(Map<String, Object?> datos);

  Future<void> editar(String id, Map<String, Object?> datos);

  Future<void> pedirVerificacion(String id, String rut);

  Future<void> pedirInsigniaRenac(String id);

  Future<PanelNegocio> panel(String id, {int dias = 30});

  /// Estadísticas por mes y semana (2.3, D101).
  Future<EstadisticasNegocio> estadisticas(String id);

  /// Foto ya preparada (sin EXIF). Lanza si se pasó del tope del plan.
  Future<void> subirFoto(String id, Uint8List jpeg);

  Future<void> borrarFoto(String id, String ruta);
}

class SupabaseNegociosRepositorio implements NegociosRepositorio {
  SupabaseNegociosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<MiNegocio>> misNegocios() async {
    final filas = await _cliente.rpc<List<dynamic>>('mis_negocios');
    final negocios = [
      for (final f in filas) (f as Map).cast<String, Object?>(),
    ];
    if (negocios.isEmpty) return const [];
    // Las fotos de mis negocios (también de los ocultos).
    final fotos = await _cliente
        .from('business_photos')
        .select('business_id, path')
        .inFilter('business_id', [for (final n in negocios) n['id']])
        .order('sort');
    return [
      for (final n in negocios)
        MiNegocio.fromJson({
          ...n,
          'photos': [
            for (final f in fotos)
              if (f['business_id'] == n['id']) f['path'],
          ],
        }),
    ];
  }

  @override
  Future<String> alta(Map<String, Object?> datos) =>
      _cliente.rpc<String>('alta_negocio', params: {'p': datos});

  @override
  Future<void> editar(String id, Map<String, Object?> datos) =>
      _cliente.rpc<void>('editar_mi_negocio', params: {'p_id': id, 'p': datos});

  @override
  Future<void> pedirVerificacion(String id, String rut) => _cliente.rpc<void>(
    'pedir_verificacion',
    params: {'p_id': id, 'p_rut': rut},
  );

  @override
  Future<void> pedirInsigniaRenac(String id) =>
      _cliente.rpc<void>('pedir_insignia_renac', params: {'p_id': id});

  @override
  Future<PanelNegocio> panel(String id, {int dias = 30}) async => PanelNegocio(
    (await _cliente.rpc<Map<String, dynamic>>(
      'panel_negocio',
      params: {'p_id': id, 'p_dias': dias},
    )).cast<String, Object?>(),
  );

  @override
  Future<EstadisticasNegocio> estadisticas(String id) async =>
      EstadisticasNegocio.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'estadisticas_negocio',
          params: {'p_id': id},
        )).cast<String, Object?>(),
      );

  @override
  Future<void> subirFoto(String id, Uint8List jpeg) async {
    final ruta = '$id/${generarAnonId()}.jpg';
    await _cliente.storage
        .from('business-photos')
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    try {
      await _cliente.from('business_photos').insert({
        'business_id': id,
        'path': ruta,
      });
    } on Exception {
      // Pasado del tope del plan: no queda la foto suelta en el bucket.
      await _cliente.storage.from('business-photos').remove([ruta]);
      rethrow;
    }
  }

  @override
  Future<void> borrarFoto(String id, String ruta) async {
    await _cliente
        .from('business_photos')
        .delete()
        .eq('business_id', id)
        .eq('path', ruta);
    await _cliente.storage.from('business-photos').remove([ruta]);
  }
}

class NegociosSinConfigurar implements NegociosRepositorio {
  const NegociosSinConfigurar();

  @override
  Future<List<MiNegocio>> misNegocios() async => const [];

  @override
  Future<String> alta(Map<String, Object?> datos) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<void> editar(String id, Map<String, Object?> datos) async {}

  @override
  Future<void> pedirVerificacion(String id, String rut) async {}

  @override
  Future<void> pedirInsigniaRenac(String id) async {}

  @override
  Future<PanelNegocio> panel(String id, {int dias = 30}) async =>
      const PanelNegocio({});

  @override
  Future<EstadisticasNegocio> estadisticas(String id) async =>
      const EstadisticasNegocio(completo: false);

  @override
  Future<void> subirFoto(String id, Uint8List jpeg) async {}

  @override
  Future<void> borrarFoto(String id, String ruta) async {}
}

final negociosRepositorioProvider = Provider<NegociosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const NegociosSinConfigurar()
      : SupabaseNegociosRepositorio(cliente);
});

final misNegociosProvider = FutureProvider<List<MiNegocio>>((ref) async {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(negociosRepositorioProvider).misNegocios();
});

final panelNegocioProvider = FutureProvider.family<PanelNegocio, String>(
  (ref, id) => ref.watch(negociosRepositorioProvider).panel(id),
);

final estadisticasNegocioProvider =
    FutureProvider.family<EstadisticasNegocio, String>(
      (ref, id) => ref.watch(negociosRepositorioProvider).estadisticas(id),
    );
