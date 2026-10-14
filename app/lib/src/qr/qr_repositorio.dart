import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

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

/// QR de las mascotas propias. Se reemplaza en las pruebas.
abstract interface class QrRepositorio {
  /// QR digital activo de la mascota (`null` si no tiene).
  Future<QrTag?> qrActivo(String mascotaId);

  /// Desactiva el QR actual y crea uno nuevo. Devuelve el código nuevo.
  Future<String> regenerar(String mascotaId);

  Future<void> guardarNota(String qrId, String? nota);

  /// Últimos escaneos de los QR de la mascota (el más nuevo primero).
  Future<List<Escaneo>> escaneos(String mascotaId);
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
}

final qrRepositorioProvider = Provider<QrRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const QrSinConfigurar()
      : SupabaseQrRepositorio(cliente);
});

final qrActivoProvider = FutureProvider.family<QrTag?, String>(
  (ref, mascotaId) => ref.watch(qrRepositorioProvider).qrActivo(mascotaId),
);

final escaneosProvider = FutureProvider.family<List<Escaneo>, String>(
  (ref, mascotaId) => ref.watch(qrRepositorioProvider).escaneos(mascotaId),
);
