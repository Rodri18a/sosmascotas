import 'dart:async';

import 'package:sosmascota/src/agenda/cuidados_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Paseos y estadías en memoria para las pruebas (3.3, D115).
class CuidadosFalsos implements CuidadosRepositorio {
  CuidadosFalsos({
    this.condicionesFijas,
    List<Cuidado>? mios,
    List<Cuidado>? delNegocio,
  }) : mios = [...?mios],
       delNegocio = [...?delNegocio];

  CondicionesCuidados? condicionesFijas;
  final List<Cuidado> mios;
  final List<Cuidado> delNegocio;
  AjustesCuidados ajustes = const AjustesCuidados();
  final pedidos = <Map<String, Object?>>[];
  final respuestas = <(String, bool)>[];
  final cambios = <(String, EstadoCuidado)>[];
  final guardados = <AjustesCuidados>[];
  CuidadosException? fallarAlPedir;
  final _vivo = StreamController<void>.broadcast();

  /// Simula un cambio que llega por Realtime.
  void avisarCambio() => _vivo.add(null);

  @override
  Future<CondicionesCuidados?> condiciones(String negocioId) async =>
      condicionesFijas;

  @override
  Future<String> pedir({
    required String negocioId,
    required TipoCuidado tipo,
    required DateTime desde,
    required DateTime hasta,
    required List<String> mascotaIds,
    FranjaCuidado? franja,
    String? nota,
  }) async {
    if (fallarAlPedir case final e?) throw e;
    pedidos.add({
      'negocio': negocioId,
      'tipo': tipo,
      'desde': desde,
      'hasta': hasta,
      'mascotas': mascotaIds,
      'franja': franja,
      'nota': nota,
    });
    return 'c${pedidos.length}';
  }

  @override
  Future<List<Cuidado>> misCuidados() async => List.of(mios);

  @override
  Future<List<Cuidado>> cuidadosDelNegocio(String negocioId) async =>
      List.of(delNegocio);

  @override
  Future<String?> responder(String cuidadoId, {required bool aceptar}) async {
    respuestas.add((cuidadoId, aceptar));
    return aceptar ? 'chat-$cuidadoId' : null;
  }

  @override
  Future<void> cambiarEstado(String cuidadoId, EstadoCuidado estado) async =>
      cambios.add((cuidadoId, estado));

  @override
  Future<AjustesCuidados> misAjustes(String negocioId) async => ajustes;

  @override
  Future<void> guardarAjustes(String negocioId, AjustesCuidados a) async {
    guardados.add(a);
    ajustes = a;
  }

  @override
  Stream<void> enVivo({String? negocioId}) => _vivo.stream;
}
