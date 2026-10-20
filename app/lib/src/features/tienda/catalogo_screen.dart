import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../tienda/tienda_repositorio.dart';
import '../../utiles/enlaces.dart';
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
      appBar: AppBar(title: Text(comercio?.nombre ?? t.catalogoTitulo)),
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

  Future<void> _consultar(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    ref.read(metricasProvider).track(Eventos.catalogAsk, businessId: negocioId);
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
          Uri.https('wa.me', '/$numero', {
            'text': t.catalogoConsultaTexto(producto.nombre),
          }),
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
                            onPressed: () => notificador.sumar(p),
                            child: Text(t.catalogoAgregar),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.catalogoQuitarUno,
                                onPressed: () => notificador.restar(p.id),
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$cantidad'),
                              IconButton(
                                tooltip: t.catalogoSumarUno,
                                onPressed: () => notificador.sumar(p),
                                icon: const Icon(Icons.add),
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

/// Resumen del pedido, nota y "Hacer pedido".
Future<void> mostrarPedido(
  BuildContext context,
  WidgetRef ref, {
  required String negocioId,
  required List<Producto> productos,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _HojaPedido(negocioId: negocioId, productos: productos),
);

class _HojaPedido extends ConsumerStatefulWidget {
  const _HojaPedido({required this.negocioId, required this.productos});

  final String negocioId;
  final List<Producto> productos;

  @override
  ConsumerState<_HojaPedido> createState() => _HojaPedidoState();
}

class _HojaPedidoState extends ConsumerState<_HojaPedido> {
  final _nota = TextEditingController();
  var _enviando = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  Future<void> _pedir() async {
    final t = context.t;
    final carrito = ref.read(carritoProvider(widget.negocioId));
    final mensajes = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _enviando = true);
    try {
      await ref
          .read(tiendaRepositorioProvider)
          .hacerPedido(
            widget.negocioId,
            carrito,
            nota: _nota.text.trim().isEmpty ? null : _nota.text.trim(),
          );
      ref
        ..read(metricasProvider).track(
          Eventos.orderCreate,
          businessId: widget.negocioId,
          props: {'unidades': carrito.unidades},
        )
        ..read(carritoProvider(widget.negocioId).notifier).vaciar()
        ..invalidate(misPedidosProvider);
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

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final carrito = ref.watch(carritoProvider(widget.negocioId));
    final porId = {for (final p in widget.productos) p.id: p};
    final conectado = ref.watch(conectadoProvider);
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
              Row(
                children: [
                  Text(t.pedidoTotal, style: tema.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    formatoPrecio(carrito.total(widget.productos)),
                    style: tema.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
              if (conectado)
                FilledButton(
                  onPressed: _enviando || carrito.vacio ? null : _pedir,
                  child: Text(t.pedidoHacer),
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
    if (comercio.plan != PlanComercio.plus ||
        !ref.watch(funcionalidadActivaProvider(Funcionalidades.catalogo))) {
      return const SizedBox.shrink();
    }
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

/// Mis pedidos, con el estado (se actualiza al volver o tirando hacia abajo).
class MisPedidosScreen extends ConsumerWidget {
  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.misPedidos)),
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
