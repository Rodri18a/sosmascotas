import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../tienda/tienda_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/volver.dart';
import '../chat/chat_screen.dart';
import 'pedidos.dart';

/// Catálogo de un comercio (2.5, D85): fotos, precios, "Consultar" y, si
/// tiene precio, sumar al pedido (3.2). Lo ve cualquiera; pedir pide cuenta.
class CatalogoScreen extends ConsumerWidget {
  const CatalogoScreen({required this.negocioId, this.comercio, super.key});

  final String negocioId;

  /// El comercio, si se llega desde su ficha (para "Consultar").
  final Comercio? comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final carrito = ref.watch(carritoProvider(negocioId));
    final catalogo = ref.watch(catalogoDeProvider(negocioId));
    final productos = catalogo.value ?? const <Producto>[];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(comercio?.nombre ?? t.catalogoTitulo),
      ),
      body: switch (catalogo) {
        AsyncData(value: final lista) when lista.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.catalogoVacio, textAlign: TextAlign.center),
          ),
        ),
        AsyncData(value: final lista) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(t.catalogoPagoDirecto),
            ),
            for (final p in lista)
              _TarjetaProducto(
                producto: p,
                negocioId: negocioId,
                comercio: comercio,
              ),
          ],
        ),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: carrito.vacio
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  key: const ValueKey('ver-pedido'),
                  onPressed: () => mostrarPedido(
                    context,
                    ref,
                    negocioId: negocioId,
                    productos: productos,
                    comercio: comercio,
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    t.catalogoVerPedido(
                      carrito.unidades,
                      formatoPrecio(carrito.total(productos)),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _TarjetaProducto extends ConsumerWidget {
  const _TarjetaProducto({
    required this.producto,
    required this.negocioId,
    this.comercio,
  });

  final Producto producto;
  final String negocioId;
  final Comercio? comercio;

  Future<void> _consultar(BuildContext context, WidgetRef ref) =>
      consultarAlComercio(
        context,
        ref,
        negocioId: negocioId,
        comercio: comercio,
        que: producto.nombre,
        evento: Eventos.catalogAsk,
        volverA: Rutas.tienda(negocioId),
      );

  /// Armar un pedido pide sesión desde el primer producto (D93): al ingresar
  /// la app puede recargarse y el carrito se perdería.
  Future<void> _agregar(BuildContext context, WidgetRef ref) async {
    if (await hayCuenta(
      context,
      ref,
      volverA: Rutas.tienda(negocioId),
      motivo: context.t.cuentaParaPedir,
    )) {
      ref.read(carritoProvider(negocioId).notifier).sumar(producto);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final p = producto;
    final cantidad = ref.watch(carritoProvider(negocioId)).cantidad(p.id);
    final url = ref.watch(tiendaRepositorioProvider).urlFoto(p.foto);
    final notificador = ref.read(carritoProvider(negocioId).notifier);
    return Card(
      key: ValueKey('producto-${p.id}'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            height: 112,
            child: url == null
                ? ColoredBox(
                    color: tema.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.inventory_2_outlined),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.inventory_2_outlined),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre, style: tema.textTheme.titleSmall),
                  if (p.descripcion case final d?)
                    Text(d, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    p.precio == null
                        ? t.catalogoConsultarPrecio
                        : formatoPrecio(p.precio!),
                    style: tema.textTheme.titleMedium,
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: () => _consultar(context, ref),
                        child: Text(t.catalogoConsultar),
                      ),
                      if (!p.soloConsultar)
                        if (cantidad == 0)
                          FilledButton.tonal(
                            onPressed: () => _agregar(context, ref),
                            child: Text(t.catalogoAgregar),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.catalogoQuitarUno,
                                onPressed: () => notificador.restar(p.id),
                                icon: const Icon(Icons.remove_outlined),
                              ),
                              Text('$cantidad'),
                              IconButton(
                                tooltip: t.catalogoSumarUno,
                                onPressed: () => notificador.sumar(p),
                                icon: const Icon(Icons.add_outlined),
                              ),
                            ],
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Consultar" por un producto o servicio, con sesión (D93): el chat de la app
/// si el comercio tiene cuenta; si no, su WhatsApp o su teléfono (datos
/// públicos del local). Un visitante ingresa y vuelve a [volverA].
Future<void> consultarAlComercio(
  BuildContext context,
  WidgetRef ref, {
  required String negocioId,
  required Comercio? comercio,
  required String que,
  required String evento,
  required String volverA,
}) async {
  final t = context.t;
  if (!await hayCuenta(
        context,
        ref,
        volverA: volverA,
        motivo: t.cuentaParaConsultar,
      ) ||
      !context.mounted) {
    return;
  }
  ref.read(metricasProvider).track(evento, businessId: negocioId);
  final c = comercio;
  final conChat =
      ref.read(conectadoProvider) &&
      ref.read(funcionalidadActivaProvider(Funcionalidades.chat)) &&
      (c?.tieneDuenio ?? false);
  if (conChat) {
    await abrirChatConNegocio(context, ref, negocioId);
    return;
  }
  if (c?.whatsapp case final w?) {
    if (telefonoInternacionalUy(w) case final numero?) {
      await ref.read(abrirEnlaceProvider)(
        Uri.https('wa.me', '/$numero', {'text': t.catalogoConsultaTexto(que)}),
      );
      return;
    }
  }
  if (c?.telefono case final tel?) {
    await ref.read(abrirEnlaceProvider)(
      Uri(scheme: 'tel', path: tel.replaceAll(' ', '')),
    );
    return;
  }
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.catalogoSinContacto)));
  }
}

/// Resumen del pedido, forma de pago, entrega, nota y "Hacer pedido" (o
/// "Enviar pedido por WhatsApp" si el comercio tiene WhatsApp, D92).
Future<void> mostrarPedido(
  BuildContext context,
  WidgetRef ref, {
  required String negocioId,
  required List<Producto> productos,
  Comercio? comercio,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _HojaPedido(
    negocioId: negocioId,
    productos: productos,
    comercio: comercio,
  ),
);

String textoFormaPago(AppLocalizations t, FormaPago f) => switch (f) {
  FormaPago.efectivo => t.pagoEfectivo,
  FormaPago.transferencia => t.pagoTransferencia,
  FormaPago.tarjeta => t.pagoTarjeta,
  FormaPago.mercadoPago => t.pagoMercadoPago,
};

String textoEntrega(AppLocalizations t, Entrega e) => switch (e) {
  Entrega.retiro => t.entregaRetiro,
  Entrega.envio => t.entregaEnvio,
};

/// El mensaje para el WhatsApp del comercio, con lo que guardó la base.
String mensajePedidoWhatsapp(AppLocalizations t, Pedido p) => [
  t.pedidoMensajeSaludo(p.numero),
  for (final r in p.renglones)
    t.pedidoMensajeRenglon(r.cantidad, r.nombre, formatoPrecio(r.subtotal)),
  if (p.entrega == Entrega.envio)
    t.pedidoMensajeTotales(
      formatoPrecio(p.subtotal),
      p.costoEnvio == 0 ? t.pedidoEnvioGratis : formatoPrecio(p.costoEnvio),
      formatoPrecio(p.total),
    )
  else
    t.pedidoMensajeTotal(formatoPrecio(p.total)),
  if (p.formaPago case final f?) t.pedidoMensajePago(textoFormaPago(t, f)),
  if (p.entrega case final e?) t.pedidoMensajeEntrega(textoEntrega(t, e)),
  if (p.entrega == Entrega.envio) t.pedidoMensajeDireccion,
  if (p.nota case final nota?) t.pedidoNotaDe(nota),
].join('\n');

class _HojaPedido extends ConsumerStatefulWidget {
  const _HojaPedido({
    required this.negocioId,
    required this.productos,
    this.comercio,
  });

  final String negocioId;
  final List<Producto> productos;
  final Comercio? comercio;

  @override
  ConsumerState<_HojaPedido> createState() => _HojaPedidoState();
}

class _HojaPedidoState extends ConsumerState<_HojaPedido> {
  final _nota = TextEditingController();
  var _enviando = false;
  FormaPago? _pago;
  Entrega? _entrega;

  /// Ya guardado, esperando que se abra WhatsApp (con un toque propio, para
  /// que el navegador no bloquee la ventana nueva).
  Pedido? _guardado;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  /// El número del comercio para wa.me, si tiene un WhatsApp válido.
  String? get _whatsapp => switch (widget.comercio?.whatsapp) {
    final w? => telefonoInternacionalUy(w),
    null => null,
  };

  Future<void> _pedir(
    CondicionesPedido? condiciones,
    FormaPago? pago,
    Entrega? entrega,
  ) async {
    final t = context.t;
    final carrito = ref.read(carritoProvider(widget.negocioId));
    final mensajes = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(tiendaRepositorioProvider);
    setState(() => _enviando = true);
    try {
      final id = await repo.hacerPedido(
        widget.negocioId,
        carrito,
        nota: _nota.text.trim().isEmpty ? null : _nota.text.trim(),
        pago: condiciones == null ? null : pago,
        entrega: condiciones == null ? null : entrega,
      );
      ref
        ..read(metricasProvider).track(
          Eventos.orderCreate,
          businessId: widget.negocioId,
          props: {
            'unidades': carrito.unidades,
            if (pago != null) 'pago': pago.base,
            if (entrega != null) 'entrega': entrega.base,
          },
        )
        ..read(carritoProvider(widget.negocioId).notifier).vaciar()
        ..invalidate(misPedidosProvider);
      // Con WhatsApp: el mensaje se arma con lo que guardó la base.
      if (_whatsapp != null) {
        final pedido = (await repo.misPedidos())
            .where((p) => p.id == id)
            .firstOrNull;
        if (pedido != null && mounted) {
          setState(() => _guardado = pedido);
          return;
        }
      }
      if (!mounted) return;
      Navigator.pop(context);
      mensajes.showSnackBar(SnackBar(content: Text(t.pedidoHecho)));
      await router.push(Rutas.misPedidos);
    } on TiendaException catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      mensajes.showSnackBar(
        SnackBar(
          content: Text(switch (e.motivo) {
            ErrorTienda.limite => t.pedidoDemasiados,
            ErrorTienda.noSePuede => t.pedidoCambio,
            ErrorTienda.sinModulo => t.pedidoSinModulo,
            _ => t.errorSinConexion,
          }),
        ),
      );
    } on Exception {
      if (!mounted) return;
      setState(() => _enviando = false);
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
  }

  Future<void> _terminar(Pedido pedido, {required bool conWhatsapp}) async {
    final router = GoRouter.of(context);
    if (conWhatsapp) {
      ref
          .read(metricasProvider)
          .track(
            Eventos.orderWhatsapp,
            businessId: widget.negocioId,
            props: {
              if (pedido.formaPago case final f?) 'pago': f.base,
              if (pedido.entrega case final e?) 'entrega': e.base,
            },
          );
      await ref.read(abrirEnlaceProvider)(
        Uri.https('wa.me', '/$_whatsapp', {
          'text': mensajePedidoWhatsapp(context.t, pedido),
        }),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    await router.push(Rutas.misPedidos);
  }

  Widget _guardadoConWhatsapp(BuildContext context, Pedido pedido) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.pedidoGuardadoTitulo(pedido.numero),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(t.pedidoGuardadoWhatsapp),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('abrir-whatsapp'),
              onPressed: () => _terminar(pedido, conWhatsapp: true),
              icon: const Icon(Icons.chat_outlined),
              label: Text(t.pedidoAbrirWhatsapp),
            ),
            TextButton(
              onPressed: () => _terminar(pedido, conWhatsapp: false),
              child: Text(t.pedidoAhoraNo),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_guardado case final pedido?) {
      return _guardadoConWhatsapp(context, pedido);
    }
    final t = context.t;
    final tema = Theme.of(context);
    final carrito = ref.watch(carritoProvider(widget.negocioId));
    final porId = {for (final p in widget.productos) p.id: p};
    final conectado = ref.watch(conectadoProvider);
    final condicionesAsync = ref.watch(
      condicionesPedidoProvider(widget.negocioId),
    );
    final condiciones = condicionesAsync.value;
    // Si hay una sola opción, ya queda elegida.
    final formas = condiciones?.formasPago ?? const <FormaPago>[];
    final entregas = condiciones?.entregas ?? const <Entrega>[];
    final pago = _pago ?? (formas.length == 1 ? formas.single : null);
    final entrega = _entrega ?? (entregas.length == 1 ? entregas.single : null);
    final subtotal = carrito.total(widget.productos);
    final envio = condiciones?.costoDe(entrega, subtotal) ?? 0;
    final falta =
        condiciones != null &&
        ((formas.isNotEmpty && pago == null) || entrega == null);
    final conWhatsapp = _whatsapp != null;

    Widget fila(String texto, String valor) => Row(
      children: [
        Text(texto, style: tema.textTheme.titleMedium),
        const Spacer(),
        Text(valor, style: tema.textTheme.titleMedium),
      ],
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.pedidoTitulo, style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final MapEntry(key: id, value: cantidad)
                  in carrito.cantidades.entries)
                if (porId[id] case final p?)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.nombre),
                    subtitle: Text(
                      '$cantidad × ${formatoPrecio(p.precio ?? 0)}',
                    ),
                    trailing: Text(formatoPrecio((p.precio ?? 0) * cantidad)),
                  ),
              const Divider(),
              if (condiciones != null) ...[
                if (formas.isNotEmpty) ...[
                  Text(t.pagoTitulo, style: tema.textTheme.titleSmall),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final f in formas)
                        ChoiceChip(
                          key: ValueKey('pago-${f.base}'),
                          label: Text(textoFormaPago(t, f)),
                          selected: pago == f,
                          onSelected: (_) => setState(() => _pago = f),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(t.entregaTitulo, style: tema.textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in entregas)
                      ChoiceChip(
                        key: ValueKey('entrega-${e.base}'),
                        label: Text(textoEntrega(t, e)),
                        selected: entrega == e,
                        onSelected: (_) => setState(() => _entrega = e),
                      ),
                  ],
                ),
                if (condiciones.envio && !condiciones.envioGratis)
                  if (condiciones.envioGratisDesde case final desde?)
                    Text(
                      t.pedidoEnvioGratisDesde(formatoPrecio(desde)),
                      style: tema.textTheme.bodySmall,
                    ),
                if (entrega == Entrega.envio)
                  Text(t.pedidoDireccionAyuda, style: tema.textTheme.bodySmall),
                const Divider(),
                if (entrega == Entrega.envio) ...[
                  fila(t.pedidoSubtotal, formatoPrecio(subtotal)),
                  fila(
                    t.pedidoEnvio,
                    envio == 0 ? t.pedidoEnvioGratis : formatoPrecio(envio),
                  ),
                ],
              ],
              fila(t.pedidoTotal, formatoPrecio(subtotal + envio)),
              const SizedBox(height: 8),
              if (condiciones == null)
                Text(t.catalogoPagoDirecto, style: tema.textTheme.bodySmall),
              const SizedBox(height: 8),
              TextField(
                controller: _nota,
                maxLength: 300,
                decoration: InputDecoration(
                  labelText: t.pedidoNota,
                  hintText: t.pedidoNotaAyuda,
                ),
              ),
              if (falta)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    t.pedidoElegiPagoYEntrega,
                    style: tema.textTheme.bodySmall,
                  ),
                ),
              if (conectado)
                FilledButton.icon(
                  key: const ValueKey('hacer-pedido'),
                  onPressed:
                      _enviando ||
                          carrito.vacio ||
                          falta ||
                          condicionesAsync.isLoading
                      ? null
                      : () => _pedir(condiciones, pago, entrega),
                  icon: Icon(
                    conWhatsapp
                        ? Icons.chat_outlined
                        : Icons.shopping_bag_outlined,
                  ),
                  label: Text(
                    conWhatsapp ? t.pedidoEnviarWhatsapp : t.pedidoHacer,
                  ),
                )
              else
                FilledButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.push(
                      Rutas.ingresarYVolverA(Rutas.tienda(widget.negocioId)),
                    );
                  },
                  child: Text(t.pedidoIngresar),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Atajo para la ficha: si el comercio tiene catálogo, el botón para verlo.
class BotonCatalogo extends ConsumerWidget {
  const BotonCatalogo({required this.comercio, super.key});

  final Comercio comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo los Plus pueden tener catálogo: a los demás no se les pregunta.
    // Lo ve cualquiera, también visitantes (D93).
    if (comercio.plan != PlanComercio.plus) return const SizedBox.shrink();
    final productos = ref.watch(catalogoDeProvider(comercio.id)).value;
    if (productos == null || productos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilledButton.icon(
        onPressed: () {
          ref
              .read(metricasProvider)
              .track(Eventos.catalogOpen, businessId: comercio.id);
          context.push(Rutas.tienda(comercio.id), extra: comercio);
        },
        icon: const Icon(Icons.storefront_outlined),
        label: Text(context.t.catalogoVer(productos.length)),
      ),
    );
  }
}

/// Texto de cada estado de un pedido.
String textoEstadoPedido(AppLocalizations t, EstadoPedido e) => switch (e) {
  EstadoPedido.nuevo => t.pedidoNuevo,
  EstadoPedido.preparando => t.pedidoPreparando,
  EstadoPedido.listo => t.pedidoListo,
  EstadoPedido.entregado => t.pedidoEntregado,
  EstadoPedido.cancelado => t.pedidoCancelado,
};

/// Mis pedidos, con el estado en vivo (D100; también tirando hacia abajo).
class MisPedidosScreen extends ConsumerWidget {
  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    ref.listen(
      pedidosEnVivoProvider(null),
      (_, _) => ref.invalidate(misPedidosProvider),
    );
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.misPedidos),
        actions: const [BotonAyuda()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(misPedidosProvider);
          await ref.read(misPedidosProvider.future);
        },
        child: switch (ref.watch(misPedidosProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(t.misPedidosVacio, textAlign: TextAlign.center),
              ),
            ],
          ),
          AsyncData(value: final lista) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              for (final p in lista)
                TarjetaPedido(
                  pedido: p,
                  titulo: p.negocio ?? '',
                  acciones: [
                    if (p.estado == EstadoPedido.nuevo)
                      TextButton(
                        onPressed: () => cambiarEstadoPedido(
                          context,
                          ref,
                          p,
                          EstadoPedido.cancelado,
                          alTerminar: () => ref.invalidate(misPedidosProvider),
                        ),
                        child: Text(t.pedidoCancelar),
                      ),
                  ],
                ),
            ],
          ),
          AsyncError() => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(t.errorSinConexion, textAlign: TextAlign.center),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
