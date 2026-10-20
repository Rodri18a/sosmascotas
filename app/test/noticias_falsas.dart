import 'package:sosmascota/src/noticias/noticias_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Noticias y novedades de la comunidad en memoria para las pruebas.
class NoticiasFalsas implements NoticiasRepositorio {
  NoticiasFalsas([
    this.lista = const [],
    this.lasNovedades = const [],
    this.elResumen = const ResumenComunidad(),
  ]);

  final List<Noticia> lista;
  final List<Novedad> lasNovedades;
  final ResumenComunidad elResumen;

  /// Reencuentros compartidos (ids de SOS).
  final compartidos = <String>{};

  @override
  Future<List<Noticia>> noticias() async => lista;

  @override
  Future<List<Novedad>> novedades() async => lasNovedades;

  @override
  Future<ResumenComunidad> resumen() async => elResumen;

  @override
  Future<void> compartirReencuentro(
    String sosId, {
    required bool compartir,
  }) async => compartir ? compartidos.add(sosId) : compartidos.remove(sosId);

  @override
  Future<bool> reencuentroCompartido(String sosId) async =>
      compartidos.contains(sosId);

  /// Reacciones por id (con la mía) y las que se mandaron.
  final reaccionesGuardadas = <String, Reacciones>{};
  final reaccionesEnviadas = <(String, Reaccion?)>[];
  var reaccionesDeMiReencuentroTotal = 0;

  @override
  Future<Map<String, Reacciones>> reacciones(List<String> ids) async => {
    for (final id in ids) id: ?reaccionesGuardadas[id],
  };

  @override
  Future<void> reaccionar(String id, Reaccion? reaccion) async =>
      reaccionesEnviadas.add((id, reaccion));

  @override
  Future<int> reaccionesDeMiReencuentro(String sosId) async =>
      reaccionesDeMiReencuentroTotal;

  @override
  String? urlFoto(String? ruta) => null;
}
