import 'package:sosmascota/src/adopcion/apadrinamiento_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Apadrinamientos en memoria, con las mismas reglas que la base.
class ApadrinamientoFalso implements ApadrinamientoRepositorio {
  ApadrinamientoFalso({
    this.esRefugio = false,
    this.puedeOfrecer = true,
    List<Apadrinamiento>? recibidos,
    List<RefugioParaApadrinar>? refugios,
    Map<(String?, String?), List<Padrino>>? padrinosDe,
  }) : recibidos = [...?recibidos],
       refugios = [...?refugios],
       padrinosDe = {...?padrinosDe};

  final bool esRefugio;
  final bool puedeOfrecer;
  final List<Apadrinamiento> recibidos;
  final List<RefugioParaApadrinar> refugios;
  final Map<(String?, String?), List<Padrino>> padrinosDe;

  /// (refugio, aporte, evento)
  final ofrecidos = <(String, String, String?)>[];
  final respuestas = <(String, bool)>[];
  final terminados = <String>[];

  @override
  Future<DatosApadrinamiento> delNegocio(String negocioId) async =>
      DatosApadrinamiento(
        esRefugio: esRefugio,
        puedeOfrecer: puedeOfrecer,
        recibidos: [
          for (final a in recibidos)
            Apadrinamiento(
              id: a.id,
              estado: switch (respuestas.where((r) => r.$1 == a.id)) {
                final r when r.isEmpty => a.estado,
                final r =>
                  r.last.$2
                      ? EstadoApadrinamiento.activo
                      : EstadoApadrinamiento.rechazado,
              },
              aporte: a.aporte,
              otro: a.otro,
              evento: a.evento,
            ),
        ],
        ofrecidos: [
          for (final (i, o) in ofrecidos.indexed)
            Apadrinamiento(
              id: 'o$i',
              estado: terminados.contains('o$i')
                  ? EstadoApadrinamiento.terminado
                  : EstadoApadrinamiento.pendiente,
              aporte: o.$2,
              otro: refugios.firstWhere((r) => r.id == o.$1).nombre,
            ),
        ],
        refugios: puedeOfrecer ? refugios : const [],
      );

  @override
  Future<void> ofrecer({
    required String negocioId,
    required String refugioId,
    required String aporte,
    String? eventoId,
  }) async {
    if (!puedeOfrecer) {
      throw const ApadrinamientoException(ErrorApadrinamiento.soloVerificados);
    }
    if (ofrecidos.any((o) => o.$1 == refugioId && o.$3 == eventoId)) {
      throw const ApadrinamientoException(ErrorApadrinamiento.yaHayUno);
    }
    ofrecidos.add((refugioId, aporte, eventoId));
  }

  @override
  Future<void> responder(String id, {required bool aceptar}) async =>
      respuestas.add((id, aceptar));

  @override
  Future<void> terminar(String id) async => terminados.add(id);

  @override
  Future<List<Padrino>> padrinos({String? negocioId, String? eventoId}) async =>
      padrinosDe[(negocioId, eventoId)] ?? const [];
}
