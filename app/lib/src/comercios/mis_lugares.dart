import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Lo mío con un lugar (tabla `user_places`, 1.2.8, D75). Privado.
class LugarMio {
  const LugarMio({
    required this.comercioId,
    this.favorito = false,
    this.fuiEn,
    this.miVeterinaria = false,
  });

  factory LugarMio.fromJson(Map<String, Object?> json) => LugarMio(
    comercioId: json['business_id']! as String,
    favorito: json['favorite'] == true,
    fuiEn: switch (json['visited_at']) {
      final String fecha => DateTime.parse(fecha).toLocal(),
      _ => null,
    },
    miVeterinaria: json['is_my_vet'] == true,
  );

  final String comercioId;
  final bool favorito;
  final DateTime? fuiEn;
  final bool miVeterinaria;
}

/// Se reemplaza en las pruebas.
abstract interface class MisLugaresRepositorio {
  Future<List<LugarMio>> misLugares();

  /// Cambia lo que se pase; lo demás queda como estaba.
  Future<void> marcar(
    String comercioId, {
    bool? favorito,
    bool? fui,
    bool? miVeterinaria,
  });
}

class SupabaseMisLugares implements MisLugaresRepositorio {
  SupabaseMisLugares(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<LugarMio>> misLugares() async {
    final filas = await _cliente.from('user_places').select();
    return filas.map(LugarMio.fromJson).toList();
  }

  @override
  Future<void> marcar(
    String comercioId, {
    bool? favorito,
    bool? fui,
    bool? miVeterinaria,
  }) => _cliente.from('user_places').upsert({
    'business_id': comercioId,
    'user_id': _cliente.auth.currentUser?.id,
    'favorite': ?favorito,
    if (fui != null)
      'visited_at': fui ? DateTime.now().toUtc().toIso8601String() : null,
    'is_my_vet': ?miVeterinaria,
  });
}

class MisLugaresSinConfigurar implements MisLugaresRepositorio {
  const MisLugaresSinConfigurar();

  @override
  Future<List<LugarMio>> misLugares() async => const [];

  @override
  Future<void> marcar(
    String comercioId, {
    bool? favorito,
    bool? fui,
    bool? miVeterinaria,
  }) async {}
}

final misLugaresRepositorioProvider = Provider<MisLugaresRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const MisLugaresSinConfigurar()
      : SupabaseMisLugares(cliente);
});

/// Mis lugares por id de comercio (vacío si es visitante).
final misLugaresProvider = FutureProvider<Map<String, LugarMio>>((ref) async {
  if (ref.watch(usuarioActualProvider).value == null) return const {};
  final lista = await ref.watch(misLugaresRepositorioProvider).misLugares();
  return {for (final l in lista) l.comercioId: l};
});
