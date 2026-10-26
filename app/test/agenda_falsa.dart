import 'dart:async';

import 'package:sosmascota/src/agenda/agenda_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Agenda en memoria para las pruebas (3.1, D104).
class AgendaFalsa implements AgendaRepositorio {
  AgendaFalsa({
    this.condicionesFijas,
    List<HorarioLibre>? libres,
    List<Turno>? mios,
    List<Turno>? delNegocio,
  }) : libres = [...?libres],
       mios = [...?mios],
       delNegocio = [...?delNegocio];

  CondicionesAgenda? condicionesFijas;
  final List<HorarioLibre> libres;
  final List<Turno> mios;
  final List<Turno> delNegocio;
  AjustesAgenda ajustes = const AjustesAgenda();
  final reservas = <Map<String, Object?>>[];
  final cambios = <(String, EstadoTurno)>[];
  final guardados = <AjustesAgenda>[];
  final bloqueos = <(DateTime, bool)>[];
  final consultas = <(DateTime, String?)>[];
  AgendaException? fallarAlReservar;
  final _vivo = StreamController<void>.broadcast();

  /// Simula un cambio que llega por Realtime.
  void avisarCambio() => _vivo.add(null);

  @override
  Future<CondicionesAgenda?> condiciones(String negocioId) async =>
      condicionesFijas;

  @override
  Future<List<HorarioLibre>> horariosLibres(
    String negocioId,
    DateTime dia, {
    String? servicioId,
  }) async {
    consultas.add((dia, servicioId));
    return libres;
  }

  @override
  Future<String> reservar({
    required String negocioId,
    required String mascotaId,
    required DateTime inicio,
    String? servicioId,
    String? nota,
  }) async {
    if (fallarAlReservar case final e?) throw e;
    reservas.add({
      'negocio': negocioId,
      'mascota': mascotaId,
      'inicio': inicio,
      'servicio': servicioId,
      'nota': nota,
    });
    return 't${reservas.length}';
  }

  @override
  Future<List<Turno>> misTurnos() async => List.of(mios);

  @override
  Future<List<Turno>> turnosDelNegocio(String negocioId) async =>
      List.of(delNegocio);

  @override
  Future<void> cambiarEstado(String turnoId, EstadoTurno estado) async =>
      cambios.add((turnoId, estado));

  @override
  Future<AjustesAgenda> miAgenda(String negocioId) async => ajustes;

  @override
  Future<void> guardarAgenda(String negocioId, AjustesAgenda a) async {
    guardados.add(a);
    ajustes = AjustesAgenda.fromJson({...a.toJson(), 'configurada': true});
  }

  @override
  Future<void> bloquearDia(
    String negocioId,
    DateTime dia, {
    String? nota,
    bool bloquear = true,
  }) async => bloqueos.add((dia, bloquear));

  @override
  Stream<void> enVivo({String? negocioId}) => _vivo.stream;
}
