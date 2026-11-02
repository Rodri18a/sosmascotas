import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../config/supabase_providers.dart';
import 'servicio_cuenta.dart';

/// «Tus huellas» (D138): lo calcula `mis_huellas()` con datos que ya existen.
/// Se reemplaza en las pruebas.
typedef CargarHuellas = Future<Huellas> Function();

final cargarHuellasProvider = Provider<CargarHuellas>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return () async {
    if (cliente == null) return const Huellas();
    final json = await cliente.rpc<Map<String, dynamic>>('mis_huellas');
    return Huellas.fromJson(json);
  };
});

final huellasProvider = FutureProvider.autoDispose<Huellas>((ref) {
  // Cambia con la sesión.
  ref.watch(usuarioActualProvider);
  return ref.watch(cargarHuellasProvider)();
});
