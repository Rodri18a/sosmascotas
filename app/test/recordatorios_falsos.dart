import 'package:sosmascota/src/recordatorios/avisador.dart';
import 'package:sosmascota/src/recordatorios/recordatorios_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Recordatorios en memoria para las pruebas.
class RecordatoriosFalsos implements RecordatoriosRepositorio {
  RecordatoriosFalsos([List<Recordatorio>? iniciales])
    : recordatorios = [...?iniciales];

  final List<Recordatorio> recordatorios;
  bool fallar = false;
  int _siguiente = 1;

  @override
  Future<List<Recordatorio>> misRecordatorios() async {
    if (fallar) throw Exception('sin internet');
    return List.of(recordatorios);
  }

  @override
  Future<Recordatorio> crear(Recordatorio recordatorio) async {
    if (fallar) throw Exception('sin internet');
    final guardado = Recordatorio.fromJson({
      ...recordatorio.toJson(),
      'id': 'recordatorio-${_siguiente++}',
    })!;
    recordatorios.add(guardado);
    return guardado;
  }

  @override
  Future<Recordatorio> actualizar(Recordatorio recordatorio) async {
    if (fallar) throw Exception('sin internet');
    final guardado = Recordatorio.fromJson({
      ...recordatorio.toJson(),
      'id': recordatorio.id,
    })!;
    recordatorios[recordatorios.indexWhere((r) => r.id == recordatorio.id)] =
        guardado;
    return guardado;
  }

  @override
  Future<void> borrar(String id) async {
    if (fallar) throw Exception('sin internet');
    recordatorios.removeWhere((r) => r.id == id);
  }

  final List<TomaHecha> tomas = [];

  /// Cuándo "se marca" (lo pone la base).
  DateTime ahora = DateTime(2026, 10, 17, 10, 20);

  @override
  Future<List<TomaHecha>> tomasHechas({required DateTime desde}) async =>
      tomas.where((t) => !t.prevista.isBefore(desde)).toList();

  @override
  Future<List<TomaHecha>> historial(
    String recordatorioId, {
    int limite = 30,
  }) async =>
      (tomas.where((t) => t.recordatorioId == recordatorioId).toList()
            ..sort((a, b) => b.prevista.compareTo(a.prevista)))
          .take(limite)
          .toList();

  @override
  Future<TomaHecha> marcar(String recordatorioId, DateTime prevista) async {
    if (fallar) throw Exception('sin internet');
    if (tomas.any(
      (t) => t.recordatorioId == recordatorioId && t.prevista == prevista,
    )) {
      throw Exception('duplicada');
    }
    final toma = TomaHecha(
      id: 'toma-${tomas.length + 1}',
      recordatorioId: recordatorioId,
      prevista: prevista,
      hecha: ahora,
    );
    tomas.add(toma);
    return toma;
  }

  @override
  Future<void> desmarcar(String tomaId) async {
    if (fallar) throw Exception('sin internet');
    tomas.removeWhere((t) => t.id == tomaId);
  }
}

/// Anota lo que la app programa en vez de mostrar avisos.
class AvisadorFalso implements AvisadorRecordatorios {
  AvisadorFalso({this.estado = PermisoAvisos.concedido});

  PermisoAvisos estado;
  List<AvisoProgramado> programados = const [];
  int pedidos = 0;

  @override
  Future<PermisoAvisos> permiso() async => estado;

  @override
  Future<PermisoAvisos> pedirPermiso() async {
    pedidos++;
    estado = PermisoAvisos.concedido;
    return estado;
  }

  @override
  void programar(List<AvisoProgramado> avisos) => programados = avisos;
}
