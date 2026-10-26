import 'package:sosmascota/src/qr/pedidos_chapita_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Pedidos de chapitas en memoria, con las mismas reglas que la base.
class PedidosChapitaFalsos implements PedidosChapitaRepositorio {
  PedidosChapitaFalsos({
    this.puntos = const [],
    List<PedidoChapita>? pedidos,
    this.puedeSer = true,
    this.puntoRetiro = false,
    List<String>? stock,
  }) : pedidos = [...?pedidos],
       stock = [...?stock];

  final List<PuntoRetiro> puntos;
  final List<PedidoChapita> pedidos;
  final bool puedeSer;
  bool puntoRetiro;

  /// Códigos sin usar del stock de la veterinaria.
  final List<String> stock;
  int _activadasDelStock = 0;
  int _numero = 100;

  /// Nombre de la mascota por id, para armar el pedido.
  final nombres = <String, String>{};

  @override
  Future<List<PuntoRetiro>> puntosDeRetiro(Punto desde) async => puntos;

  @override
  Future<void> pedir(String mascotaId, String negocioId, String grabado) async {
    if (pedidos.any((p) => p.mascotaId == mascotaId && p.estado.abierto)) {
      throw const PedidoChapitaException(ErrorPedidoChapita.yaHayUno);
    }
    final punto = puntos.firstWhere((p) => p.id == negocioId);
    pedidos.add(
      PedidoChapita(
        id: 'pedido-${++_numero}',
        numero: _numero,
        mascotaId: mascotaId,
        nombreMascota: nombres[mascotaId] ?? mascotaId,
        negocioId: negocioId,
        negocioNombre: punto.nombre,
        grabado: grabado,
        estado: EstadoPedidoChapita.nuevo,
        creado: DateTime(2026, 10, 23),
      ),
    );
  }

  @override
  Future<List<PedidoChapita>> misPedidos() async => List.of(pedidos);

  PedidoChapita _con(PedidoChapita p, EstadoPedidoChapita estado) =>
      PedidoChapita(
        id: p.id,
        numero: p.numero,
        mascotaId: p.mascotaId,
        nombreMascota: p.nombreMascota,
        negocioId: p.negocioId,
        negocioNombre: p.negocioNombre,
        cliente: p.cliente,
        grabado: p.grabado,
        estado: estado,
        codigo: p.codigo,
        creado: p.creado,
      );

  @override
  Future<void> cancelar(String pedidoId) async {
    final i = pedidos.indexWhere((p) => p.id == pedidoId);
    if (pedidos[i].estado != EstadoPedidoChapita.nuevo) {
      throw const PedidoChapitaException(ErrorPedidoChapita.noSePuede);
    }
    pedidos[i] = _con(pedidos[i], EstadoPedidoChapita.cancelado);
  }

  @override
  Future<PedidosDelNegocio> delNegocio(String negocioId) async =>
      (
        puntoRetiro: puntoRetiro,
        puedeSer: puedeSer,
        pedidos: List.of(pedidos),
        stockDisponibles: stock.length,
        stockActivadas: _activadasDelStock,
      );

  @override
  Future<void> prenderPuntoRetiro(
    String negocioId, {
    required bool prender,
  }) async {
    if (!puedeSer) {
      throw const PedidoChapitaException(ErrorPedidoChapita.soloVerificadas);
    }
    puntoRetiro = prender;
  }

  @override
  Future<EstadoPedidoChapita> avanzar(String pedidoId) async {
    final i = pedidos.indexWhere((p) => p.id == pedidoId);
    final nuevo = switch (pedidos[i].estado) {
      EstadoPedidoChapita.enviado => EstadoPedidoChapita.listo,
      EstadoPedidoChapita.listo => EstadoPedidoChapita.entregado,
      _ => throw const PedidoChapitaException(ErrorPedidoChapita.noSePuede),
    };
    pedidos[i] = _con(pedidos[i], nuevo);
    return nuevo;
  }

  @override
  Future<void> entregarDeStock(String pedidoId, String codigo) async {
    final i = pedidos.indexWhere((p) => p.id == pedidoId);
    if (pedidos[i].estado != EstadoPedidoChapita.nuevo) {
      throw const PedidoChapitaException(ErrorPedidoChapita.noSePuede);
    }
    if (!stock.remove(codigo.toUpperCase())) {
      throw const PedidoChapitaException(ErrorPedidoChapita.noEstaEnStock);
    }
    _activadasDelStock++;
    pedidos[i] = _con(pedidos[i], EstadoPedidoChapita.entregado);
  }
}
