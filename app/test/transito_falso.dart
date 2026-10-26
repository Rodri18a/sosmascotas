import 'package:sosmascota/src/adopcion/transito_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Hogares de tránsito en memoria, con las mismas reglas que la base.
class TransitoFalso implements TransitoRepositorio {
  TransitoFalso({
    this.mio,
    List<PedidoTransito>? recibidos,
    List<HogarDisponible>? hogaresDeLaZona,
    this.esRefugio = true,
  }) : recibidos = [...?recibidos],
       hogaresDeLaZona = [...?hogaresDeLaZona];

  HogarTransito? mio;
  final List<PedidoTransito> recibidos;
  final List<HogarDisponible> hogaresDeLaZona;
  final bool esRefugio;

  /// Lo que pidió el refugio: (hogar, nombre, especie, tamaño, días).
  final pedidos = <(String, String, int, String?, int)>[];
  final cerrados = <String>[];
  var borrado = false;

  PedidoTransito _con(
    PedidoTransito p,
    EstadoTransito estado, {
    String? chat,
  }) => PedidoTransito(
    id: p.id,
    nombreAnimal: p.nombreAnimal,
    especieId: p.especieId,
    tamano: p.tamano,
    dias: p.dias,
    mensaje: p.mensaje,
    estado: estado,
    creado: p.creado,
    refugioId: p.refugioId,
    refugio: p.refugio,
    hogar: p.hogar,
    barrio: p.barrio,
    conversacionId: chat ?? p.conversacionId,
  );

  @override
  Future<HogarTransito?> miHogar() async => mio;

  @override
  Future<void> guardarHogar(HogarTransito hogar) async => mio = hogar;

  @override
  Future<void> borrarHogar() async {
    mio = null;
    borrado = true;
    recibidos.clear();
  }

  @override
  Future<List<PedidoTransito>> misPedidos() async => List.of(recibidos);

  @override
  Future<String?> responder(String pedidoId, {required bool aceptar}) async {
    final i = recibidos.indexWhere((p) => p.id == pedidoId);
    if (recibidos[i].estado != EstadoTransito.nuevo) {
      throw const TransitoException(ErrorTransito.noSePuede);
    }
    final chat = aceptar ? 'chat-$pedidoId' : null;
    recibidos[i] = _con(
      recibidos[i],
      aceptar ? EstadoTransito.aceptado : EstadoTransito.rechazado,
      chat: chat,
    );
    return chat;
  }

  void _exigirRefugio() {
    if (!esRefugio) throw const TransitoException(ErrorTransito.soloRefugios);
  }

  @override
  Future<List<HogarDisponible>> hogares(
    String refugioId, {
    int? especieId,
  }) async {
    _exigirRefugio();
    return [
      for (final h in hogaresDeLaZona)
        HogarDisponible(
          id: h.id,
          nombre: h.nombre,
          barrio: h.barrio,
          especies: h.especies,
          tamanos: h.tamanos,
          maxDias: h.maxDias,
          patio: h.patio,
          pedidoAbierto: pedidos.any((p) => p.$1 == h.id),
        ),
    ];
  }

  @override
  Future<void> pedir({
    required String refugioId,
    required String hogarId,
    required int dias,
    required String nombre,
    required int especieId,
    String? tamano,
    String? mensaje,
  }) async {
    _exigirRefugio();
    final h = hogaresDeLaZona.firstWhere((h) => h.id == hogarId);
    if (dias > h.maxDias) throw const TransitoException(ErrorTransito.masDias);
    if (pedidos.any((p) => p.$1 == hogarId)) {
      throw const TransitoException(ErrorTransito.yaHayUno);
    }
    pedidos.add((hogarId, nombre, especieId, tamano, dias));
  }

  @override
  Future<List<PedidoTransito>> pedidosDelRefugio(String refugioId) async => [
    for (final (i, p) in pedidos.indexed)
      PedidoTransito(
        id: 'p$i',
        nombreAnimal: p.$2,
        especieId: p.$3,
        tamano: p.$4,
        dias: p.$5,
        estado: cerrados.contains('p$i')
            ? EstadoTransito.cancelado
            : EstadoTransito.nuevo,
        creado: DateTime(2026, 10, 26),
        hogar: hogaresDeLaZona.firstWhere((h) => h.id == p.$1).nombre,
      ),
  ];

  @override
  Future<EstadoTransito> cerrar(String pedidoId) async {
    cerrados.add(pedidoId);
    return EstadoTransito.cancelado;
  }
}
