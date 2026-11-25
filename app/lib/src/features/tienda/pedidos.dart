import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../fotos/elegir_foto.dart';
import '../../metricas/metricas.dart';
import '../../tienda/tienda_repositorio.dart';
import 'catalogo_screen.dart';
import 'planilla_catalogo.dart';

/// Un pedido con sus renglones, el total, el estado y [acciones].
class TarjetaPedido extends StatelessWidget {
  const TarjetaPedido({
    required this.pedido,
    required this.titulo,
    this.acciones = const [],
    super.key,
  });

  final Pedido pedido;
  final String titulo;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    final p = pedido;
    final hora = l.formatTimeOfDay(
      TimeOfDay.fromDateTime(p.creado),
      alwaysUse24HourFormat: true,
    );
    return Card(
      key: ValueKey('pedido-${p.id}'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.pedidoNumero(p.numero)} · $titulo',
                    style: tema.textTheme.titleSmall,
                  ),
                ),
                Chip(
                  label: Text(textoEstadoPedido(t, p.estado)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              '${l.formatMediumDate(p.creado)} $hora',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final r in p.renglones)
              Row(
                children: [
                  Expanded(child: Text('${r.cantidad} × ${r.nombre}')),
                  Text(formatoPrecio(r.subtotal)),
                ],
              ),
            if (p.entrega == Entrega.envio)
              Row(
                children: [
                  Expanded(child: Text(t.pedidoEnvio)),
                  Text(
                    p.costoEnvio == 0
                        ? t.pedidoEnvioGratis
                        : formatoPrecio(p.costoEnvio),
                  ),
                ],
              ),
            const Divider(),
            Row(
              children: [
                Text(t.pedidoTotal, style: tema.textTheme.titleSmall),
                const Spacer(),
                Text(formatoPrecio(p.total), style: tema.textTheme.titleSmall),
              ],
            ),
            if (p.formaPago != null || p.entrega != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (p.formaPago case final f?)
                    t.pedidoMensajePago(textoFormaPago(t, f)),
                  if (p.entrega case final e?)
                    t.pedidoMensajeEntrega(textoEntrega(t, e)),
                ].join(' · '),
              ),
            ],
            if (p.nota case final nota?) ...[
              const SizedBox(height: 8),
              Text(t.pedidoNotaDe(nota)),
            ],
            if (acciones.isNotEmpty)
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.end,
                children: acciones,
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> cambiarEstadoPedido(
  BuildContext context,
  WidgetRef ref,
  Pedido pedido,
  EstadoPedido estado, {
  required VoidCallback alTerminar,
}) async {
  final t = context.t;
  final mensajes = ScaffoldMessenger.of(context);
  try {
    await ref.read(tiendaRepositorioProvider).cambiarEstado(pedido.id, estado);
    ref
        .read(metricasProvider)
        .track(Eventos.orderStatus, props: {'estado': estado.base});
  } on Exception {
    mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
  }
  alTerminar();
}

/// Modo comercio → Catálogo: prender el módulo y cargar productos.
class CatalogoNegocio extends ConsumerWidget {
  const CatalogoNegocio({
    required this.negocioId,
    required this.prendido,
    required this.onPrender,
    super.key,
  });

  final String negocioId;
  final bool prendido;
  final ValueChanged<bool> onPrender;

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Producto? producto,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) =>
          FormularioProducto(negocioId: negocioId, producto: producto),
    );
    if (guardado ?? false) {
      ref
        ..invalidate(miCatalogoProvider(negocioId))
        ..invalidate(catalogoDeProvider(negocioId));
    }
  }

  Future<void> _planilla(BuildContext context, WidgetRef ref) async {
    final cargado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CargaPlanilla(
        negocioId: negocioId,
        existentes: ref.read(miCatalogoProvider(negocioId)).value ?? const [],
      ),
    );
    if (cargado ?? false) {
      ref
        ..invalidate(miCatalogoProvider(negocioId))
        ..invalidate(catalogoDeProvider(negocioId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final repo = ref.watch(tiendaRepositorioProvider);
    // El equipo carga productos; prender y las condiciones son del dueño (D117).
    final titular = ref.watch(esTitularProvider(negocioId));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(context, ref),
        icon: const Icon(Icons.add_outlined),
        label: Text(t.productoNuevo),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (titular) ...[
            SwitchListTile(
              title: Text(t.catalogoPrender),
              subtitle: Text(
                prendido ? t.catalogoPrendidoAyuda : t.catalogoApagadoAyuda,
              ),
              value: prendido,
              onChanged: onPrender,
            ),
            _CondicionesNegocio(negocioId: negocioId),
          ],
          // Carga masiva (portal de empresas, 2.10, D114).
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: Text(t.planillaTitulo),
            subtitle: Text(t.planillaTarjeta),
            trailing: const Icon(Icons.chevron_right_outlined),
            onTap: () => _planilla(context, ref),
          ),
          const Divider(height: 1),
          switch (ref.watch(miCatalogoProvider(negocioId))) {
            AsyncData(value: final lista) when lista.isEmpty => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(t.catalogoSinProductos, textAlign: TextAlign.center),
            ),
            AsyncData(value: final lista) => Column(
              children: [
                for (final p in lista)
                  ListTile(
                    key: ValueKey('mi-producto-${p.id}'),
                    leading: CircleAvatar(
                      backgroundImage: switch (repo.urlFoto(p.foto)) {
                        final url? => NetworkImage(url),
                        null => null,
                      },
                      child: p.foto == null
                          ? const Icon(Icons.inventory_2_outlined)
                          : null,
                    ),
                    title: Text(p.nombre),
                    subtitle: Text(
                      [
                        if (p.precio case final precio?)
                          formatoPrecio(precio)
                        else
                          t.catalogoConsultarPrecio,
                        if (!p.disponible) t.productoNoDisponible,
                      ].join(' · '),
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _editar(context, ref, p),
                  ),
              ],
            ),
            AsyncError() => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(t.errorSinConexion, textAlign: TextAlign.center),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ],
      ),
    );
  }
}

class FormularioProducto extends ConsumerStatefulWidget {
  const FormularioProducto({required this.negocioId, this.producto, super.key});

  final String negocioId;
  final Producto? producto;

  @override
  ConsumerState<FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends ConsumerState<FormularioProducto> {
  late final _nombre = TextEditingController(text: widget.producto?.nombre);
  late final _descripcion = TextEditingController(
    text: widget.producto?.descripcion,
  );
  late final _precio = TextEditingController(
    text: switch (widget.producto?.precio) {
      final p? when p == p.roundToDouble() => p.toInt().toString(),
      final p? => p.toStringAsFixed(2).replaceAll('.', ','),
      null => '',
    },
  );
  late var _disponible = widget.producto?.disponible ?? true;
  late String? _foto = widget.producto?.foto;
  String? _error;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _precio]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final original = await elegirFoto(context, ref);
    if (original == null) return;
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    try {
      final ruta = await ref
          .read(tiendaRepositorioProvider)
          .subirFoto(widget.negocioId, preparada);
      setState(() => _foto = ruta);
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
  }

  Future<void> _guardar() async {
    final t = context.t;
    final precio = leerPrecio(_precio.text);
    if (_nombre.text.trim().length < 2 ||
        (_precio.text.trim().isNotEmpty && (precio == null || precio < 0))) {
      setState(() => _error = t.productoDatosInvalidos);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref
          .read(tiendaRepositorioProvider)
          .guardarProducto(
            widget.negocioId,
            Producto(
              id: widget.producto?.id ?? '',
              nombre: _nombre.text.trim(),
              descripcion: _descripcion.text.trim().isEmpty
                  ? null
                  : _descripcion.text.trim(),
              precio: precio,
              foto: _foto,
              disponible: _disponible,
              orden: widget.producto?.orden ?? 0,
            ),
          );
      ref
          .read(metricasProvider)
          .track(Eventos.productSave, businessId: widget.negocioId);
      if (mounted) Navigator.pop(context, true);
    } on TiendaException catch (e) {
      setState(() {
        _guardando = false;
        _error = switch (e.motivo) {
          ErrorTienda.soloPlus => t.moduloSoloPlus,
          ErrorTienda.limite => t.productoLimite,
          _ => t.productoDatosInvalidos,
        };
      });
    } on Exception {
      setState(() {
        _guardando = false;
        _error = t.errorSinConexion;
      });
    }
  }

  Future<void> _borrar() async {
    final id = widget.producto?.id;
    if (id == null) return;
    try {
      await ref.read(tiendaRepositorioProvider).borrarProducto(id);
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      setState(() => _error = context.t.errorSinConexion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final url = ref.watch(tiendaRepositorioProvider).urlFoto(_foto);
    return AlertDialog(
      title: Text(widget.producto == null ? t.productoNuevo : t.productoEditar),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombre,
                maxLength: 80,
                decoration: InputDecoration(labelText: t.productoNombre),
              ),
              TextField(
                controller: _descripcion,
                maxLength: 500,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(labelText: t.productoDescripcion),
              ),
              TextField(
                controller: _precio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: t.productoPrecio,
                  helperText: t.productoPrecioAyuda,
                  prefixText: r'$ ',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.productoDisponible),
                value: _disponible,
                onChanged: (v) => setState(() => _disponible = v),
              ),
              Row(
                children: [
                  if (url != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.network(
                        url,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  // Flexible: con letra grande (Moderno) no entraba en el
                  // diálogo angosto.
                  Flexible(
                    child: TextButton.icon(
                      onPressed: _elegirFoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        _foto == null ? t.productoFoto : t.productoCambiarFoto,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error case final e?)
                Text(
                  e,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.producto != null)
          TextButton(onPressed: _borrar, child: Text(t.productoBorrar)),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(t.guardar),
        ),
      ],
    );
  }
}

/// "Cómo cobrás y entregás" (2.10c, D92): resumen y acceso al formulario.
class _CondicionesNegocio extends ConsumerWidget {
  const _CondicionesNegocio({required this.negocioId});

  final String negocioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final condiciones = ref.watch(condicionesPedidoProvider(negocioId));
    return ListTile(
      key: const ValueKey('condiciones-pedido'),
      leading: const Icon(Icons.local_shipping_outlined),
      title: Text(t.condicionesTitulo),
      subtitle: Text(switch (condiciones) {
        AsyncData(value: final c?) => [
          if (c.formasPago.isNotEmpty)
            c.formasPago.map((f) => textoFormaPago(t, f)).join(', '),
          if (c.retiro) t.entregaRetiro,
          if (c.envio)
            c.envioGratis
                ? t.condicionesEnvioGratis
                : t.condicionesEnvioCosto(formatoPrecio(c.costoEnvio!)),
        ].join(' · '),
        AsyncData() => t.condicionesSinConfigurar,
        _ => '',
      }),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final guardado = await showDialog<bool>(
          context: context,
          builder: (_) => FormularioCondiciones(
            negocioId: negocioId,
            condiciones: condiciones.value,
          ),
        );
        if (guardado ?? false) {
          ref.invalidate(condicionesPedidoProvider(negocioId));
        }
      },
    );
  }
}

class FormularioCondiciones extends ConsumerStatefulWidget {
  const FormularioCondiciones({
    required this.negocioId,
    this.condiciones,
    super.key,
  });

  final String negocioId;
  final CondicionesPedido? condiciones;

  @override
  ConsumerState<FormularioCondiciones> createState() =>
      _FormularioCondicionesState();
}

class _FormularioCondicionesState extends ConsumerState<FormularioCondiciones> {
  late final _actual = widget.condiciones ?? const CondicionesPedido();
  late var _formas = {..._actual.formasPago};
  late var _retiro = _actual.retiro;
  late var _envio = _actual.envio;
  late final _costo = TextEditingController(text: _monto(_actual.costoEnvio));
  late final _desde = TextEditingController(
    text: _monto(_actual.envioGratisDesde),
  );
  String? _error;
  var _guardando = false;

  static String _monto(double? v) => switch (v) {
    null || 0 => '',
    final m when m == m.roundToDouble() => m.toInt().toString(),
    final m => m.toStringAsFixed(2).replaceAll('.', ','),
  };

  @override
  void dispose() {
    _costo.dispose();
    _desde.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = context.t;
    final costo = leerPrecio(_costo.text);
    final desde = leerPrecio(_desde.text);
    if (!_retiro && !_envio) {
      setState(() => _error = t.condicionesUnaEntrega);
      return;
    }
    if ((_costo.text.trim().isNotEmpty && (costo == null || costo < 0)) ||
        (_desde.text.trim().isNotEmpty && (desde == null || desde < 0))) {
      setState(() => _error = t.condicionesMontosInvalidos);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref
          .read(tiendaRepositorioProvider)
          .guardarCondicionesPedido(
            widget.negocioId,
            CondicionesPedido(
              formasPago: [
                for (final f in FormaPago.values)
                  if (_formas.contains(f)) f,
              ],
              retiro: _retiro,
              envio: _envio,
              costoEnvio: costo,
              envioGratisDesde: desde,
            ),
          );
      ref
          .read(metricasProvider)
          .track(Eventos.orderSettingsSave, businessId: widget.negocioId);
      if (mounted) Navigator.pop(context, true);
    } on TiendaException catch (e) {
      setState(() {
        _guardando = false;
        _error = e.motivo == ErrorTienda.soloPlus
            ? t.moduloSoloPlus
            : t.condicionesMontosInvalidos;
      });
    } on Exception {
      setState(() {
        _guardando = false;
        _error = t.errorSinConexion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return AlertDialog(
      title: Text(t.condicionesTitulo),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.condicionesPagos, style: tema.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in FormaPago.values)
                    FilterChip(
                      key: ValueKey('acepta-${f.base}'),
                      label: Text(textoFormaPago(t, f)),
                      selected: _formas.contains(f),
                      onSelected: (si) => setState(
                        () => _formas = si
                            ? {..._formas, f}
                            : ({..._formas}..remove(f)),
                      ),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.condicionesRetiro),
                value: _retiro,
                onChanged: (v) => setState(() => _retiro = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.condicionesEnvio),
                value: _envio,
                onChanged: (v) => setState(() => _envio = v),
              ),
              if (_envio) ...[
                TextField(
                  controller: _costo,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t.condicionesCosto,
                    helperText: t.condicionesCostoAyuda,
                    prefixText: r'$ ',
                  ),
                ),
                TextField(
                  controller: _desde,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: t.condicionesGratisDesde,
                    prefixText: r'$ ',
                  ),
                ),
              ],
              if (_error case final e?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    e,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(t.guardar),
        ),
      ],
    );
  }
}

/// Modo comercio → Pedidos: los abiertos primero, de a un paso. Los nuevos y
/// las cancelaciones aparecen solos (D100).
class PedidosNegocio extends ConsumerWidget {
  const PedidosNegocio({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    void recargar() => ref.invalidate(pedidosDelNegocioProvider(negocioId));
    ref.listen(pedidosEnVivoProvider(negocioId), (_, _) => recargar());
    return RefreshIndicator(
      onRefresh: () async {
        recargar();
        await ref.read(pedidosDelNegocioProvider(negocioId).future);
      },
      child: switch (ref.watch(pedidosDelNegocioProvider(negocioId))) {
        AsyncData(value: final lista) when lista.isEmpty => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(t.pedidosNegocioVacio, textAlign: TextAlign.center),
            ),
          ],
        ),
        AsyncData(value: final lista) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final p in lista)
              TarjetaPedido(
                pedido: p,
                titulo: p.cliente ?? '',
                acciones: [
                  if (p.estado.abierto)
                    TextButton(
                      onPressed: () => cambiarEstadoPedido(
                        context,
                        ref,
                        p,
                        EstadoPedido.cancelado,
                        alTerminar: recargar,
                      ),
                      child: Text(t.pedidoCancelar),
                    ),
                  if (p.estado.siguiente case final siguiente?)
                    FilledButton(
                      onPressed: () => cambiarEstadoPedido(
                        context,
                        ref,
                        p,
                        siguiente,
                        alTerminar: recargar,
                      ),
                      child: Text(
                        t.pedidoPasarA(textoEstadoPedido(t, siguiente)),
                      ),
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
    );
  }
}
