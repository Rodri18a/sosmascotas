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

  @override
  String? urlFoto(String? ruta) => null;
}
