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
