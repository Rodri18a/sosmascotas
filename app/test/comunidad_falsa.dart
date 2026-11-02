import 'dart:typed_data';

import 'package:sosmascota/src/comunidad/comunidad_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Comunidad en memoria para las pruebas (3.4, D116).
class ComunidadFalsa implements ComunidadRepositorio {
  ComunidadFalsa({
    List<Grupo>? grupos,
    List<Publicacion>? publicaciones,
    this.detalle,
    List<Saludo>? saludos,
  }) : listaGrupos = [...?grupos],
       lista = [...?publicaciones],
       saludos = [...?saludos];

  final List<Grupo> listaGrupos;
  final List<Publicacion> lista;
  Publicacion? detalle;
  final List<Saludo> saludos;
  final razasPedidas = <int>[];
  final uniones = <(String, bool)>[];
  final publicadas = <Map<String, Object?>>[];
  final comentarios = <(String, String)>[];
  final reportes = <(String, String, String)>[];
  final saludados = <(String, String, String)>[];
  final respuestas = <(String, bool)>[];
  final borrados = <(String, String)>[];
  ComunidadException? fallar;

  @override
  Future<List<Grupo>> grupos() async => List.of(listaGrupos);

  @override
  Future<String> grupoDeRaza(int razaId) async {
    razasPedidas.add(razaId);
    return 'raza-$razaId';
  }

  @override
  Future<void> unirme(String grupoId, {required bool unirme}) async =>
      uniones.add((grupoId, unirme));

  @override
  Future<List<Publicacion>> publicaciones(String grupoId) async =>
      List.of(lista);

  @override
  Future<Publicacion?> publicacion(String id) async => detalle;

  @override
  Future<String> publicar({
    required String grupoId,
    required TipoPublicacion tipo,
    required String texto,
    List<String> fotos = const [],
  }) async {
    if (fallar case final e?) throw e;
    publicadas.add({
      'grupo': grupoId,
      'tipo': tipo,
      'texto': texto,
      'fotos': fotos,
    });
    return 'p${publicadas.length}';
  }

  @override
  Future<void> comentar(String publicacionId, String texto) async =>
      comentarios.add((publicacionId, texto));

  final busquedas = <(TemaPregunta?, String?)>[];
  final preguntadas = <(TemaPregunta, String, String?)>[];
  final marcadas = <(String, String?)>[];

  @override
  Future<List<Publicacion>> preguntas({
    TemaPregunta? tema,
    String? buscar,
  }) async {
    busquedas.add((tema, buscar));
    final texto = buscar?.trim().toLowerCase() ?? '';
    return [
      for (final p in lista)
        if (p.tipo == TipoPublicacion.pregunta &&
            (tema == null || p.tema == tema) &&
            p.texto.toLowerCase().contains(texto))
          p,
    ];
  }

  @override
  Future<String> preguntar({
    required TemaPregunta tema,
    required String texto,
    String? grupoId,
  }) async {
    if (fallar case final f?) throw f;
    preguntadas.add((tema, texto, grupoId));
    return 'q${preguntadas.length}';
  }

  @override
  Future<void> marcarRespuesta(String preguntaId, String? comentarioId) async =>
      marcadas.add((preguntaId, comentarioId));

  @override
  Future<void> borrar(String tipo, String id) async => borrados.add((tipo, id));

  @override
  Future<void> reportar(String tipo, String id, String motivo) async =>
      reportes.add((tipo, id, motivo));

  @override
  Future<void> saludar(String tipo, String id, String mensaje) async {
    if (fallar case final e?) throw e;
    saludados.add((tipo, id, mensaje));
  }

  @override
  Future<List<Saludo>> misSaludos() async => List.of(saludos);

  @override
  Future<String?> responderSaludo(String id, {required bool aceptar}) async {
    respuestas.add((id, aceptar));
    return aceptar ? 'chat-$id' : null;
  }

  @override
  Future<String> subirFoto(Uint8List jpeg) async => 'u1/foto.jpg';

  @override
  String urlFoto(String ruta) => 'https://fotos.test/$ruta';
}
