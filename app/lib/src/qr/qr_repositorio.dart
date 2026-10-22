import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../utiles/respaldo.dart';

/// Un escaneo del QR (alguien abrió la página).
class Escaneo {
  const Escaneo({required this.id, required this.creado, this.lat, this.lng});

  factory Escaneo.fromJson(Map<String, Object?> json) => Escaneo(
    id: json['id']! as String,
    creado: DateTime.parse(json['created_at']! as String).toLocal(),
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  final String id;
  final DateTime creado;
  final double? lat;
  final double? lng;

  bool get conUbicacion => lat != null && lng != null;
}

/// Por qué no se pudo activar una chapita (1.8b.2, D95).
enum ErrorChapita { inexistente, usada, limite, sinConexion }

class ChapitaFallida implements Exception {
  const ChapitaFallida(this.motivo);

  final ErrorChapita motivo;
}

/// QR de las mascotas propias. Se reemplaza en las pruebas.
abstract interface class QrRepositorio {
  /// QR digital activo de la mascota (`null` si no tiene).
  Future<QrTag?> qrActivo(String mascotaId);

  /// Desactiva el QR actual y crea uno nuevo. Devuelve el código nuevo.
  Future<String> regenerar(String mascotaId);

  Future<void> guardarNota(String qrId, String? nota);

  /// Últimos escaneos de los QR de la mascota (el más nuevo primero).
  Future<List<Escaneo>> escaneos(String mascotaId);

  /// Chapitas físicas vinculadas a la mascota (1.8b.2, D95).
  Future<List<QrTag>> chapitas(String mascotaId);

  /// Vincula la chapita [codigo] a la mascota. Lanza [ChapitaFallida].
  Future<void> activarChapita(String codigo, String mascotaId);

  /// La deja inactiva para siempre.
  Future<void> desvincularChapita(String tagId);
}

class SupabaseQrRepositorio implements QrRepositorio {
  SupabaseQrRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<QrTag?> qrActivo(String mascotaId) async {
    final fila = await _cliente
        .from('qr_tags')
        .select('id, code, active, pet_id, public_note')
        .eq('pet_id', mascotaId)
        .eq('kind', 'digital')
        .eq('active', true)
        .maybeSingle();
    return fila == null ? null : QrTag.fromJson(fila);
  }

  @override
  Future<String> regenerar(String mascotaId) async => await _cliente
      .rpc<String>('regenerar_qr', params: {'p_pet_id': mascotaId});

  @override
  Future<void> guardarNota(String qrId, String? nota) async {
    final limpia = nota?.trim();
    await _cliente
        .from('qr_tags')
        .update({
          'public_note': limpia == null || limpia.isEmpty ? null : limpia,
        })
        .eq('id', qrId);
  }

  @override
  Future<List<Escaneo>> escaneos(String mascotaId) async {
    final filas = await _cliente
        .from('qr_scans_app')
        .select()
        .eq('pet_id', mascotaId)
        .order('created_at', ascending: false)
        .limit(20);
    return filas.map(Escaneo.fromJson).toList();
  }

  @override
  Future<List<QrTag>> chapitas(String mascotaId) async =>
      (await _cliente
              .from('qr_tags')
              .select('id, code, active, pet_id, public_note')
              .eq('pet_id', mascotaId)
              .eq('kind', 'physical')
              .eq('active', true)
              .order('activated_at'))
          .map(QrTag.fromJson)
          .toList();

  @override
  Future<void> activarChapita(String codigo, String mascotaId) async {
    try {
      await _cliente.rpc<String>(
        'activar_chapita',
        params: {'p_code': codigo, 'p_pet_id': mascotaId},
      );
    } on PostgrestException catch (e) {
      throw ChapitaFallida(switch (e.message) {
        'chapita_usada' => ErrorChapita.usada,
        'limite_chapitas' => ErrorChapita.limite,
        _ => ErrorChapita.inexistente,
      });
    } on Exception {
      throw const ChapitaFallida(ErrorChapita.sinConexion);
    }
  }

  @override
  Future<void> desvincularChapita(String tagId) =>
      _cliente.rpc<void>('desvincular_chapita', params: {'p_tag': tagId});
}

class QrSinConfigurar implements QrRepositorio {
  const QrSinConfigurar();

  @override
  Future<QrTag?> qrActivo(String mascotaId) async => null;

  @override
  Future<String> regenerar(String mascotaId) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<void> guardarNota(String qrId, String? nota) async {}

  @override
  Future<List<Escaneo>> escaneos(String mascotaId) async => const [];

  @override
  Future<List<QrTag>> chapitas(String mascotaId) async => const [];

  @override
  Future<void> activarChapita(String codigo, String mascotaId) async =>
      throw const ChapitaFallida(ErrorChapita.sinConexion);

  @override
  Future<void> desvincularChapita(String tagId) async {}
}

final qrRepositorioProvider = Provider<QrRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const QrSinConfigurar()
      : SupabaseQrRepositorio(cliente);
});

final qrActivoProvider = FutureProvider.family<QrTag?, String>((
  ref,
  mascotaId,
) {
  final repo = ref.watch(qrRepositorioProvider);
  return conRespaldo(
    ref,
    clave: 'qr/$mascotaId',
    pedir: () => repo.qrActivo(mascotaId),
    aJson: (qr) => qr?.toJson(),
    deJson: (json) => json == null
        ? null
        : QrTag.fromJson((json as Map).cast<String, Object?>()),
  );
});

final escaneosProvider = FutureProvider.family<List<Escaneo>, String>(
  (ref, mascotaId) => ref.watch(qrRepositorioProvider).escaneos(mascotaId),
);

final chapitasProvider = FutureProvider.family<List<QrTag>, String>(
  (ref, mascotaId) => ref.watch(qrRepositorioProvider).chapitas(mascotaId),
);
