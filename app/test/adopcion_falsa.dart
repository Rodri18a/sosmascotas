import 'dart:typed_data';

import 'package:sosmascota/src/adopcion/adopcion_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Adopción en memoria para las pruebas.
class AdopcionFalsa implements AdopcionRepositorio {
  AdopcionFalsa({
    this.animales = const [],
    this.perfil,
    this.solicitudes = const [],
    this.recibidasLista = const [],
    this.seguimientos = const [],
  });

  List<AnimalAdopcion> animales;
  PerfilAdoptante? perfil;
  List<SolicitudAdopcion> solicitudes;
  List<SolicitudRecibida> recibidasLista;
  List<Seguimiento> seguimientos;
  final interesados = <(String, String?)>[];
  final publicadas = <(Map<String, Object?>, List<Map<String, Object?>>)>[];
  final avances = <(String, EtapaAdopcion)>[];
  final compromisos = <(String, String)>[];
  final respuestas = <(String, String)>[];
  ErrorAdopcion? fallarCon;

  @override
  Future<List<AnimalAdopcion>> disponibles({int? especieId}) async => [
    for (final a in animales)
      if (especieId == null || a.especieId == especieId) a,
  ];

  @override
  Future<PerfilAdoptante?> miPerfil() async => perfil;

  @override
  Future<void> guardarPerfil(PerfilAdoptante perfil) async =>
      this.perfil = perfil;

  @override
  Future<String> subirFoto(Uint8List jpeg) async => 'u1/foto.jpg';

  @override
  String urlFoto(String ruta) => 'https://fotos.ejemplo.uy/$ruta';

  @override
  Future<String> publicar(
    Map<String, Object?> publicacion,
    List<Map<String, Object?>> animales,
  ) async {
    if (fallarCon case final m?) throw AdopcionException(m);
    publicadas.add((publicacion, animales));
    return 'p-nueva';
  }

  @override
  Future<void> meInteresa(String animalId, {String? mensaje}) async {
    if (fallarCon case final m?) throw AdopcionException(m);
    interesados.add((animalId, mensaje));
  }

  @override
  Future<List<SolicitudAdopcion>> misSolicitudes() async => solicitudes;

  @override
  Future<List<SolicitudRecibida>> recibidas() async => recibidasLista;

  @override
  Future<void> avanzar(String solicitudId, EtapaAdopcion etapa) async =>
      avances.add((solicitudId, etapa));

  @override
  Future<void> nota(String solicitudId, String nota) async {}

  @override
  Future<String> aceptarCompromiso(String solicitudId, String version) async {
    compromisos.add((solicitudId, version));
    return 'm-adoptada';
  }

  @override
  Future<List<Seguimiento>> misSeguimientos() async => seguimientos;

  @override
  Future<void> responderSeguimiento(
    String id,
    String respuesta, {
    String? foto,
  }) async => respuestas.add((id, respuesta));
}
