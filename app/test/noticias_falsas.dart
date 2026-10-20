import 'package:sosmascota/src/noticias/noticias_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Noticias en memoria para las pruebas.
class NoticiasFalsas implements NoticiasRepositorio {
  NoticiasFalsas([this.lista = const []]);

  final List<Noticia> lista;

  @override
  Future<List<Noticia>> noticias() async => lista;
}
