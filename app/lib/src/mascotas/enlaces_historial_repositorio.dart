import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Un enlace vigente de solo lectura al historial (tabla `pet_shares`, D133).
typedef EnlaceHistorial = ({
  String id,
  String token,
  DateTime vence,
  int vistas,
});

/// Compartir el historial con la veterinaria o un cuidador. Solo el dueño
/// crea y corta enlaces (lo controla la base). Se reemplaza en las pruebas.
abstract interface class EnlacesHistorialRepositorio {
  Future<List<EnlaceHistorial>> vigentes(String mascotaId);

  /// Crea un enlace que vence en [dias] (1, 7 o 30) y devuelve su token.
  Future<String> crear(String mascotaId, int dias);

  Future<void> cortar(String id);
}

class SupabaseEnlacesHistorialRepositorio
    implements EnlacesHistorialRepositorio {
  SupabaseEnlacesHistorialRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<EnlaceHistorial>> vigentes(String mascotaId) async {
    final filas = await _cliente
        .from('pet_shares')
        .select('id, token, expires_at, views')
        .eq('pet_id', mascotaId)
        .isFilter('revoked_at', null)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('expires_at');
    return [
      for (final f in filas)
        (
          id: f['id']! as String,
          token: f['token']! as String,
          vence: DateTime.parse(f['expires_at']! as String).toLocal(),
          vistas: (f['views']! as num).toInt(),
        ),
    ];
  }

  @override
  Future<String> crear(String mascotaId, int dias) => _cliente.rpc<String>(
    'crear_enlace_historial',
    params: {'p_pet': mascotaId, 'p_dias': dias},
  );

  @override
  Future<void> cortar(String id) =>
      _cliente.rpc<void>('cortar_enlace_historial', params: {'p_id': id});
}

class EnlacesHistorialSinConfigurar implements EnlacesHistorialRepositorio {
  const EnlacesHistorialSinConfigurar();

  @override
  Future<List<EnlaceHistorial>> vigentes(String mascotaId) async => const [];

  @override
  Future<String> crear(String mascotaId, int dias) async =>
      'sin-configurar-000000';

  @override
  Future<void> cortar(String id) async {}
}

final enlacesHistorialRepositorioProvider =
    Provider<EnlacesHistorialRepositorio>((ref) {
      final cliente = ref.watch(supabaseClientProvider);
      return cliente == null
          ? const EnlacesHistorialSinConfigurar()
          : SupabaseEnlacesHistorialRepositorio(cliente);
    });

final enlacesHistorialProvider = FutureProvider.autoDispose
    .family<List<EnlaceHistorial>, String>(
      (ref, mascotaId) =>
          ref.watch(enlacesHistorialRepositorioProvider).vigentes(mascotaId),
    );
