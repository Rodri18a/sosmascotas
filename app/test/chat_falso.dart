import 'dart:async';
import 'dart:typed_data';

import 'package:sosmascota/src/chat/chat_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Chat en memoria para las pruebas. [llega] simula un mensaje en tiempo real.
class ChatFalso implements ChatRepositorio {
  ChatFalso({List<Conversacion>? conversaciones, this.yo = 'u2'})
    : conversaciones = [...?conversaciones];

  final List<Conversacion> conversaciones;
  final String yo;
  final mensajesGuardados = <Mensaje>[];
  final iniciados = <String>[];
  final reportados = <(String, String)>[];
  final leidos = <String>[];
  final _tiempoReal = StreamController<Mensaje>.broadcast();
  int _siguiente = 1;
  DateTime ahora = DateTime(2026, 10, 17, 10, 20);

  void llega(String texto, {String de = 'u1', String conversacion = 'c1'}) =>
      _tiempoReal.add(
        Mensaje(
          id: 'tr-${_siguiente++}',
          conversacionId: conversacion,
          remitenteId: de,
          texto: texto,
          creado: ahora,
        ),
      );

  @override
  Future<List<Conversacion>> misConversaciones() async =>
      List.of(conversaciones);

  @override
  Future<String> iniciarDesdeSos(String sosId) async {
    iniciados.add(sosId);
    return 'c1';
  }

  @override
  Future<List<Mensaje>> mensajes(String conversacionId) async => [
    for (final m in mensajesGuardados)
      if (m.conversacionId == conversacionId) m,
  ];

  @override
  Stream<Mensaje> nuevos(String conversacionId) =>
      _tiempoReal.stream.where((m) => m.conversacionId == conversacionId);

  void _guardar(
    String conversacionId, {
    String? texto,
    String? foto,
    double? lat,
    double? lng,
  }) => mensajesGuardados.add(
    Mensaje(
      id: 'm-${_siguiente++}',
      conversacionId: conversacionId,
      remitenteId: yo,
      texto: texto,
      foto: foto,
      lat: lat,
      lng: lng,
      creado: ahora,
    ),
  );

  @override
  Future<void> enviarTexto(String conversacionId, String texto) async =>
      _guardar(conversacionId, texto: texto);

  @override
  Future<void> enviarFoto(String conversacionId, Uint8List jpeg) async =>
      _guardar(conversacionId, foto: '$yo/$conversacionId/f.jpg');

  @override
  Future<void> enviarUbicacion(
    String conversacionId,
    double lat,
    double lng,
  ) async => _guardar(conversacionId, lat: lat, lng: lng);

  @override
  Future<void> marcarLeido(String conversacionId) async =>
      leidos.add(conversacionId);

  @override
  Future<void> bloquear(String conversacionId, {required bool bloquear}) async {
    final i = conversaciones.indexWhere((c) => c.id == conversacionId);
    final c = conversaciones[i];
    conversaciones[i] = Conversacion(
      id: c.id,
      tipo: c.tipo,
      contextoId: c.contextoId,
      ultimoMensajeEn: c.ultimoMensajeEn,
      otroId: c.otroId,
      otroNombre: c.otroNombre,
      soyAutor: c.soyAutor,
      sosEncontrada: c.sosEncontrada,
      sosNombre: c.sosNombre,
      bloqueada: bloquear,
      bloqueadaPorMi: bloquear,
    );
  }

  @override
  Future<void> reportar(String mensajeId, String motivo) async =>
      reportados.add((mensajeId, motivo));

  @override
  Future<String?> urlFoto(String ruta) async => null;
}
