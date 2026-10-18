import 'package:sosmascota/src/hogar/hogar_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Hogar compartido en memoria para las pruebas.
class HogarFalso implements HogarRepositorio {
  HogarFalso([List<Integrante>? iniciales]) : lista = [...?iniciales];

  final List<Integrante> lista;
  final unidos = <String>[];
  final invitaciones = <({int? dias, List<String>? mascotas})>[];
  ErrorInvitacion? fallarAlUnirse;

  @override
  Future<List<Integrante>> integrantes() async => List.of(lista);

  @override
  Future<String> invitar({int? diasCuidador, List<String>? mascotas}) async {
    invitaciones.add((dias: diasCuidador, mascotas: mascotas));
    return 'K7M2QX9PAB';
  }

  @override
  Future<void> unirme(String codigo) async {
    if (fallarAlUnirse case final motivo?) throw InvitacionFallida(motivo);
    unidos.add(codigo);
  }

  @override
  Future<void> sacar(String hogarId, String usuarioId) async => lista
      .removeWhere((i) => i.hogarId == hogarId && i.usuarioId == usuarioId);
}
