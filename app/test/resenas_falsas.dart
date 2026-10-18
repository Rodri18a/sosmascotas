import 'package:sosmascota/src/comercios/resenas_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Reseñas en memoria para las pruebas.
class ResenasFalsas implements ResenasRepositorio {
  ResenasFalsas({List<Resena>? iniciales, this.puedo = false})
    : resenas = [...?iniciales];

  final List<Resena> resenas;
  bool puedo;
  final reportadas = <String>[];
  final respuestas = <(String, String)>[];

  @override
  Future<List<Resena>> deComercio(String comercioId) async => List.of(resenas);

  @override
  Future<bool> puedoResenar(String comercioId) async => puedo;

  @override
  Future<void> guardar(
    String comercioId,
    int estrellas,
    String? comentario,
  ) async {
    resenas
      ..removeWhere((r) => r.mia)
      ..insert(
        0,
        Resena(
          id: 'mia',
          estrellas: estrellas,
          comentario: comentario,
          creada: DateTime(2026, 10, 18),
          autor: 'Ana',
          mia: true,
        ),
      );
  }

  @override
  Future<void> responder(String resenaId, String respuesta) async =>
      respuestas.add((resenaId, respuesta));

  @override
  Future<void> reportar(String resenaId, String motivo) async =>
      reportadas.add(resenaId);
}
