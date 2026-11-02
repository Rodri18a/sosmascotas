import 'package:sosmascota/src/comercios/promociones_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Promociones en memoria.
class PromocionesFalsas implements PromocionesRepositorio {
  PromocionesFalsas({
    List<Promocion>? cerca,
    Map<String, List<Promocion>>? mias,
  }) : _cerca = [...?cerca],
       mias = {...?mias};

  final List<Promocion> _cerca;
  final Map<String, List<Promocion>> mias;
  final guardadas = <Map<String, Object?>>[];
  final terminadas = <String>[];
  final reportadas = <(String, String)>[];
  PromocionException? fallar;

  @override
  Future<List<Promocion>> cerca(Punto punto) async => List.of(_cerca);

  @override
  Future<List<Promocion>> deMiNegocio(String negocioId) async => [
    ...?mias[negocioId],
  ];

  @override
  Future<String> guardar({
    required String negocioId,
    required String titulo,
    required String texto,
    required int dias,
    String? id,
    String? fotoPath,
  }) async {
    if (fallar case final f?) throw f;
    guardadas.add({
      'id': id,
      'negocio': negocioId,
      'titulo': titulo,
      'texto': texto,
      'dias': dias,
      'foto': fotoPath,
    });
    final nueva = Promocion(
      id: id ?? 'promo${guardadas.length}',
      titulo: titulo,
      texto: texto,
      fotoPath: fotoPath,
      vence: DateTime(2026, 11, 2).add(Duration(days: dias)),
    );
    (mias[negocioId] ??= [])
      ..removeWhere((p) => p.id == nueva.id)
      ..insert(0, nueva);
    return nueva.id;
  }

  @override
  Future<void> terminar(String id) async {
    terminadas.add(id);
    for (final lista in mias.values) {
      lista.removeWhere((p) => p.id == id);
    }
  }

  @override
  Future<void> reportar(String id, String motivo) async =>
      reportadas.add((id, motivo));
}
