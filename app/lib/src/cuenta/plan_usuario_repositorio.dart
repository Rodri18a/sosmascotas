import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../funcionalidades/funcionalidades_activas.dart';
import 'servicio_cuenta.dart';

/// Plan Pro o Familia de la persona (2.1, D111). Se reemplaza en las pruebas.
abstract interface class PlanUsuarioRepositorio {
  Future<MiPlanUsuario> miPlan();

  /// «Quiero Pro / Familia»: la administración lo activa (cobro manual).
  Future<void> pedir(Plan plan);
}

class SupabasePlanUsuarioRepositorio implements PlanUsuarioRepositorio {
  SupabasePlanUsuarioRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<MiPlanUsuario> miPlan() async => MiPlanUsuario.fromJson(
    (await _cliente.rpc<Map<String, dynamic>>('mi_plan_usuario')).cast(),
  );

  @override
  Future<void> pedir(Plan plan) =>
      _cliente.rpc<void>('pedir_plan_usuario', params: {'p_plan': plan.name});
}

class PlanUsuarioRepositorioSinConfigurar implements PlanUsuarioRepositorio {
  const PlanUsuarioRepositorioSinConfigurar();

  @override
  Future<MiPlanUsuario> miPlan() async => const MiPlanUsuario(plan: Plan.free);

  @override
  Future<void> pedir(Plan plan) async {}
}

final planUsuarioRepositorioProvider = Provider<PlanUsuarioRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const PlanUsuarioRepositorioSinConfigurar()
      : SupabasePlanUsuarioRepositorio(cliente);
});

/// El plan de la persona con sesión; `null` si es visitante o si los planes
/// todavía están apagados (`planes_usuario`).
final miPlanUsuarioProvider = FutureProvider<MiPlanUsuario?>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null ||
      !ref.watch(funcionalidadActivaProvider(Funcionalidades.planesUsuario))) {
    return null;
  }
  return ref.watch(planUsuarioRepositorioProvider).miPlan();
});
