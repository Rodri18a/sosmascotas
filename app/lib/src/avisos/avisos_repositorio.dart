import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Avisos que le dejaron al dueño (contacto inverso). Se reemplaza en las pruebas.
abstract interface class AvisosRepositorio {
  Future<List<Aviso>> misAvisos();

  Future<void> cambiarEstado(String id, EstadoAviso estado);

  Future<void> borrar(String id);
}

class SupabaseAvisosRepositorio implements AvisosRepositorio {
  SupabaseAvisosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Aviso>> misAvisos() async {
    final filas = await _cliente
        .from('owner_alerts_app')
        .select()
        .order('created_at', ascending: false)
        .limit(100);
    return filas.map(Aviso.fromJson).toList();
  }

  @override
  Future<void> cambiarEstado(String id, EstadoAviso estado) => _cliente
      .from('owner_alerts')
      .update({'status': estadoAvisoABase(estado)})
      .eq('id', id);

  @override
  Future<void> borrar(String id) =>
      _cliente.from('owner_alerts').delete().eq('id', id);
}

class AvisosSinConfigurar implements AvisosRepositorio {
  const AvisosSinConfigurar();

  @override
  Future<List<Aviso>> misAvisos() async => const [];

  @override
  Future<void> cambiarEstado(String id, EstadoAviso estado) async {}

  @override
  Future<void> borrar(String id) async {}
}

final avisosRepositorioProvider = Provider<AvisosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const AvisosSinConfigurar()
      : SupabaseAvisosRepositorio(cliente);
});

final avisosProvider = FutureProvider<List<Aviso>>((ref) async {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(avisosRepositorioProvider).misAvisos();
});

/// Cantidad de avisos sin ver (para el globito de la campana).
int contarNuevos(List<Aviso>? avisos) =>
    avisos?.where((a) => a.estado == EstadoAviso.nuevo).length ?? 0;
