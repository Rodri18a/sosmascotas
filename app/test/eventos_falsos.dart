import 'dart:typed_data';

import 'package:sosmascota/src/eventos/eventos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Eventos y denuncias en memoria para las pruebas.
class EventosFalsos implements EventosRepositorio {
  EventosFalsos([List<Evento>? iniciales]) : eventos = [...?iniciales];

  final List<Evento> eventos;
  final publicados = <Map<String, Object?>>[];
  final cancelados = <String>[];
  final denuncias = <(String, Punto?, List<String>)>[];

  @override
  Future<List<Evento>> enZona(Limites zona) async => List.of(eventos);

  @override
  Future<void> publicar(Map<String, Object?> evento) async =>
      publicados.add(evento);

  @override
  Future<void> cancelar(String id) async => cancelados.add(id);

  @override
  Future<String> subirFotoDenuncia(Uint8List jpeg) async => 'u1/denuncia.jpg';

  @override
  Future<void> denunciar(
    String descripcion, {
    Punto? punto,
    String? direccion,
    List<String> fotos = const [],
  }) async => denuncias.add((descripcion, punto, fotos));

  @override
  Future<List<Denuncia>> misDenuncias() async => [
    for (final (d, _, _) in denuncias)
      Denuncia(
        id: 'd',
        descripcion: d,
        estado: EstadoDenuncia.nueva,
        creada: DateTime(2026, 10, 19),
      ),
  ];
}
