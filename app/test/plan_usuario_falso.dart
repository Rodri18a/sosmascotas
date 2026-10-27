import 'package:sosmascota/src/cuenta/plan_usuario_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class PlanUsuarioFalso implements PlanUsuarioRepositorio {
  PlanUsuarioFalso([this.plan = const MiPlanUsuario(plan: Plan.free)]);

  MiPlanUsuario plan;
  final pedidos = <Plan>[];

  @override
  Future<MiPlanUsuario> miPlan() async => plan;

  @override
  Future<void> pedir(Plan plan) async {
    if (pedidos.isNotEmpty) throw Exception('23505');
    pedidos.add(plan);
    this.plan = MiPlanUsuario(
      plan: this.plan.plan,
      mascotas: this.plan.mascotas,
      limiteMascotas: this.plan.limiteMascotas,
      pedidoAbierto: plan,
    );
  }
}
