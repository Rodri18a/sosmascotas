import 'package:sosmascota/src/comercios/equipo_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Equipo en memoria para las pruebas (3.5, D117).
class EquipoFalso implements EquipoRepositorio {
  EquipoFalso({this.soyTitular = true, List<PersonaEquipo>? personas})
    : personas = [...?personas];

  final bool soyTitular;
  final List<PersonaEquipo> personas;
  final invitaciones = <InvitacionEquipo>[];
  final unidos = <String>[];

  @override
  Future<EquipoNegocio> equipo(String negocioId) async => EquipoNegocio(
    soyTitular: soyTitular,
    personas: List.of(personas),
    invitaciones: soyTitular ? List.of(invitaciones) : const [],
  );

  @override
  Future<String> invitar(String negocioId) async {
    const codigo = 'ABCD2345';
    invitaciones.add(
      InvitacionEquipo(codigo: codigo, vence: DateTime(2026, 11, 4)),
    );
    return codigo;
  }

  @override
  Future<String> unirme(String codigo) async {
    if (codigo != 'ABCD2345') {
      throw const EquipoException(ErrorEquipo.codigoInvalido);
    }
    unidos.add(codigo);
    return 'b1';
  }

  @override
  Future<void> quitar(String negocioId, String userId) async =>
      personas.removeWhere((p) => p.userId == userId);

  @override
  Future<void> anular(String codigo) async =>
      invitaciones.removeWhere((i) => i.codigo == codigo);
}
