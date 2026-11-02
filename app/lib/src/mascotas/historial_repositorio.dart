import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../utiles/respaldo.dart';

/// Historial de vida de las mascotas (tabla `life_events` y bucket privado
/// `pet-records`, D131). La RLS deja verlo y editarlo a quienes pueden cuidar
/// la mascota. Se reemplaza en las pruebas.
abstract interface class HistorialRepositorio {
  Future<List<AcontecimientoVida>> deMascota(String mascotaId);

  Future<AcontecimientoVida> crear(AcontecimientoVida acontecimiento);

  Future<AcontecimientoVida> actualizar(AcontecimientoVida acontecimiento);

  Future<void> borrar(String id);

  /// Sube un adjunto a la carpeta de la mascota y devuelve su ruta.
  Future<String> subirAdjunto(
    String mascotaId,
    Uint8List bytes, {
    required bool pdf,
  });

  Future<void> borrarAdjuntos(List<String> rutas);

  /// Enlace que vence en una hora (el bucket es privado).
  Future<String?> urlAdjunto(String ruta);
}

class SupabaseHistorialRepositorio implements HistorialRepositorio {
  SupabaseHistorialRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static const _bucket = 'pet-records';

  SupabaseQueryBuilder get _tabla => _cliente.from('life_events');

  @override
  Future<List<AcontecimientoVida>> deMascota(String mascotaId) async {
    final filas = await _tabla.select().eq('pet_id', mascotaId);
    return filas.map(AcontecimientoVida.fromJson).toList();
  }

  @override
  Future<AcontecimientoVida> crear(AcontecimientoVida acontecimiento) async =>
      AcontecimientoVida.fromJson(
        await _tabla.insert(acontecimiento.toJson()).select().single(),
      );

  @override
  Future<AcontecimientoVida> actualizar(
    AcontecimientoVida acontecimiento,
  ) async => AcontecimientoVida.fromJson(
    await _tabla
        .update(acontecimiento.toJson())
        .eq('id', acontecimiento.id)
        .select()
        .single(),
  );

  @override
  Future<void> borrar(String id) => _tabla.delete().eq('id', id);

  @override
  Future<String> subirAdjunto(
    String mascotaId,
    Uint8List bytes, {
    required bool pdf,
  }) async {
    // Carpeta = la mascota (lo exigen la política del bucket y la tabla).
    final ruta = '$mascotaId/${generarAnonId()}.${pdf ? 'pdf' : 'jpg'}';
    await _cliente.storage
        .from(_bucket)
        .uploadBinary(
          ruta,
          bytes,
          fileOptions: FileOptions(
            contentType: pdf ? 'application/pdf' : 'image/jpeg',
          ),
        );
    return ruta;
  }

  @override
  Future<void> borrarAdjuntos(List<String> rutas) async {
    if (rutas.isEmpty) return;
    await _cliente.storage.from(_bucket).remove(rutas);
  }

  @override
  Future<String?> urlAdjunto(String ruta) async {
    try {
      return await _cliente.storage.from(_bucket).createSignedUrl(ruta, 3600);
    } on Exception {
      return null;
    }
  }
}

class HistorialSinConfigurar implements HistorialRepositorio {
  const HistorialSinConfigurar();

  @override
  Future<List<AcontecimientoVida>> deMascota(String mascotaId) async =>
      const [];

  @override
  Future<AcontecimientoVida> crear(AcontecimientoVida acontecimiento) async =>
      acontecimiento;

  @override
  Future<AcontecimientoVida> actualizar(
    AcontecimientoVida acontecimiento,
  ) async => acontecimiento;

  @override
  Future<void> borrar(String id) async {}

  @override
  Future<String> subirAdjunto(
    String mascotaId,
    Uint8List bytes, {
    required bool pdf,
  }) async => '$mascotaId/sin-configurar.${pdf ? 'pdf' : 'jpg'}';

  @override
  Future<void> borrarAdjuntos(List<String> rutas) async {}

  @override
  Future<String?> urlAdjunto(String ruta) async => null;
}

final historialRepositorioProvider = Provider<HistorialRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const HistorialSinConfigurar()
      : SupabaseHistorialRepositorio(cliente);
});

/// Historial de una mascota, de lo más nuevo a lo más viejo (con respaldo
/// para verlo sin conexión, como la libreta).
final historialProvider =
    FutureProvider.family<List<AcontecimientoVida>, String>((
      ref,
      mascotaId,
    ) async {
      final repo = ref.watch(historialRepositorioProvider);
      final lista = await conRespaldo(
        ref,
        clave: 'historial/$mascotaId',
        pedir: () => repo.deMascota(mascotaId),
        aJson: (lista) => [
          for (final a in lista) {...a.toJson(), 'id': a.id},
        ],
        deJson: (json) =>
            listaJson(json).map(AcontecimientoVida.fromJson).toList(),
      );
      return ordenarHistorial(lista);
    });

/// Un acontecimiento puntual (para editarlo).
final acontecimientoProvider =
    Provider.family<
      AsyncValue<AcontecimientoVida?>,
      ({String mascotaId, String id})
    >(
      (ref, clave) => ref
          .watch(historialProvider(clave.mascotaId))
          .whenData(
            (lista) => lista.where((a) => a.id == clave.id).firstOrNull,
          ),
    );
