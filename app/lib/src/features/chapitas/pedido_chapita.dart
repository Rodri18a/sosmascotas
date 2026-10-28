import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/mis_lugares.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../qr/pedidos_chapita_repositorio.dart';
import '../../router.dart';
import '../../widgets/volver.dart';

String textoErrorPedido(AppLocalizations t, ErrorPedidoChapita e) =>
    switch (e) {
      ErrorPedidoChapita.yaHayUno => t.pedidoChapitaYaHayUno,
      ErrorPedidoChapita.demasiados => t.pedidoChapitaDemasiados(
        maximoPedidosChapitaAbiertos,
      ),
      ErrorPedidoChapita.noEsPunto => t.pedidoChapitaNoEsPunto,
      ErrorPedidoChapita.soloVerificadas => t.retiroSoloVerificadas,
      ErrorPedidoChapita.noEstaEnStock => t.stockNoEsTuya,
      ErrorPedidoChapita.noSePuede => t.errorDesconocido,
      ErrorPedidoChapita.sinConexion => t.errorSinConexion,
    };

/// Estado del pedido como lo ve el dueño.
String textoEstadoPedido(AppLocalizations t, PedidoChapita p) =>
    switch (p.estado) {
      EstadoPedidoChapita.nuevo => t.pedidoChapitaNuevo,
      EstadoPedidoChapita.enviado => t.pedidoChapitaEnviado(
        p.negocioNombre ?? '',
      ),
      EstadoPedidoChapita.listo => t.pedidoChapitaListo(
        p.negocioNombre ?? '',
        p.numero,
      ),
      EstadoPedidoChapita.entregado => t.pedidoChapitaEntregado,
      EstadoPedidoChapita.cancelado => t.pedidoChapitaCancelado,
    };

/// En Chapita QR → Chapitas físicas (solo el dueño): el pedido abierto de
/// esta mascota o el botón para pedir una.
class TarjetaPedidoChapita extends ConsumerWidget {
  const TarjetaPedidoChapita({required this.mascota, super.key});

  final Mascota mascota;

  Future<void> _cancelar(
    BuildContext context,
    WidgetRef ref,
    PedidoChapita p,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(pedidosChapitaRepositorioProvider).cancelar(p.id);
      ref.read(metricasProvider).track(Eventos.tagOrderCancel);
      ref.invalidate(misPedidosChapitaProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.pedidoChapitaCancelado)));
    } on PedidoChapitaException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorPedido(t, e.motivo))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final abierto = (ref.watch(misPedidosChapitaProvider).value ?? const [])
        .where((p) => p.mascotaId == mascota.id && p.estado.abierto)
        .firstOrNull;
    if (abierto == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => context.push(Rutas.pedirChapita(mascota.id)),
          icon: const Icon(Icons.local_shipping_outlined),
          label: Text(t.pedidoChapitaPedir),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Icon(
          abierto.estado == EstadoPedidoChapita.listo
              ? Icons.storefront
              : Icons.local_shipping_outlined,
        ),
        title: Text(t.pedidoChapitaNumero(abierto.numero, abierto.grabado)),
        subtitle: Text(textoEstadoPedido(t, abierto)),
        trailing: abierto.estado == EstadoPedidoChapita.nuevo
            ? TextButton(
                onPressed: () => _cancelar(context, ref, abierto),
                child: Text(t.cancelar),
              )
            : null,
      ),
    );
  }
}

/// Pedir una chapita: dónde retirarla y qué grabarle.
class PedirChapitaScreen extends ConsumerStatefulWidget {
  const PedirChapitaScreen({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  ConsumerState<PedirChapitaScreen> createState() => _PedirChapitaState();
}

class _PedirChapitaState extends ConsumerState<PedirChapitaScreen> {
  final _grabado = TextEditingController();
  String? _punto;
  bool _enviando = false;
  bool _iniciado = false;

  @override
  void dispose() {
    _grabado.dispose();
    super.dispose();
  }

  Future<void> _pedir(Mascota mascota) async {
    final punto = _punto;
    if (punto == null) return;
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      await ref
          .read(pedidosChapitaRepositorioProvider)
          .pedir(
            mascota.id,
            punto,
            textoGrabado(_grabado.text, mascota.nombre),
          );
      ref.read(metricasProvider).track(Eventos.tagOrderCreate);
      ref.invalidate(misPedidosChapitaProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.pedidoChapitaHecho)));
      if (mounted) context.pop();
    } on PedidoChapitaException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorPedido(t, e.motivo))),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final mascota = ref.watch(mascotaProvider(widget.mascotaId)).value;
    final miVeterinaria = (ref.watch(misLugaresProvider).value ?? const {})
        .values
        .where((l) => l.miVeterinaria)
        .firstOrNull
        ?.comercioId;
    final puntos = ref.watch(puntosDeRetiroProvider);
    if (mascota != null && !_iniciado) {
      _iniciado = true;
      _grabado.text = textoGrabado(null, mascota.nombre);
    }
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.pedidoChapitaTitulo),
      ),
      body: mascota == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t.pedidoChapitaExplicacion(mascota.nombre)),
                const SizedBox(height: 8),
                Text(t.pedidoChapitaPrecio, style: tema.textTheme.bodySmall),
                const SizedBox(height: 16),
                TextField(
                  controller: _grabado,
                  maxLength: maximoGrabado,
                  decoration: InputDecoration(
                    labelText: t.pedidoChapitaGrabado,
                    helperText: t.pedidoChapitaGrabadoAyuda,
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.pedidoChapitaDonde, style: tema.textTheme.titleMedium),
                switch (puntos) {
                  AsyncData(value: final lista) when lista.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(t.pedidoChapitaSinPuntos),
                  ),
                  AsyncData(value: final lista) => RadioGroup<String>(
                    groupValue: _punto,
                    onChanged: (v) => setState(() => _punto = v),
                    child: Column(
                      children: [
                        for (final p in conMiVeterinariaPrimero(
                          lista,
                          miVeterinaria,
                        ))
                          RadioListTile<String>(
                            value: p.id,
                            contentPadding: EdgeInsets.zero,
                            title: Text(p.nombre),
                            subtitle: Text(
                              [
                                if (p.id == miVeterinaria)
                                  t.pedidoChapitaTuVeterinaria,
                                ?p.direccion,
                              ].join(' · '),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AsyncError() => Text(t.errorSinConexion),
                  _ => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                },
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _punto == null || _enviando
                      ? null
                      : () => _pedir(mascota),
                  child: Text(
                    _enviando
                        ? t.pedidoChapitaPidiendo
                        : t.pedidoChapitaConfirmar,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Modo comercio → Chapitas (solo veterinarias): ser punto de retiro y los
/// pedidos que llegan. La veterinaria ve el primer nombre de quien pidió, la
/// mascota y el texto grabado; nunca un contacto.
class ChapitasNegocioScreen extends ConsumerStatefulWidget {
  const ChapitasNegocioScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<ChapitasNegocioScreen> createState() => _ChapitasNegocioState();
}

class _ChapitasNegocioState extends ConsumerState<ChapitasNegocioScreen> {
  bool _ocupado = false;

  Future<void> _hacer(Future<void> Function() accion) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _ocupado = true);
    try {
      await accion();
      ref.invalidate(pedidosChapitaNegocioProvider(widget.negocioId));
    } on PedidoChapitaException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorPedido(t, e.motivo))),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _avanzar(PedidoChapita p) async {
    final t = context.t;
    if (p.estado == EstadoPedidoChapita.listo) {
      final si = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.retiroEntregarTitulo),
          content: Text(t.retiroEntregarTexto(p.numero, p.nombreMascota)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.retiroEntregada),
            ),
          ],
        ),
      );
      if (!(si ?? false)) return;
    }
    await _hacer(() async {
      final nuevo = await ref
          .read(pedidosChapitaRepositorioProvider)
          .avanzar(p.id);
      ref
          .read(metricasProvider)
          .track(
            Eventos.tagOrderStatus,
            businessId: widget.negocioId,
            props: {'estado': nuevo.valor},
          );
    });
  }

  Future<void> _entregarDeStock(PedidoChapita p) async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => _CodigoDeStock(pedido: p),
    );
    if (codigo == null || codigo.trim().isEmpty) return;
    await _hacer(() async {
      await ref
          .read(pedidosChapitaRepositorioProvider)
          .entregarDeStock(p.id, codigo.trim());
      ref
          .read(metricasProvider)
          .track(Eventos.tagStockDeliver, businessId: widget.negocioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.retiroTitulo),
      ),
      body: switch (ref.watch(
        pedidosChapitaNegocioProvider(widget.negocioId),
      )) {
        AsyncData(value: final d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ser punto de retiro lo decide el dueño; el equipo entrega (D117).
            if (ref.watch(esTitularProvider(widget.negocioId)))
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.retiroSerPunto),
                subtitle: Text(
                  d.puedeSer ? t.retiroSerPuntoAyuda : t.retiroSoloVerificadas,
                ),
                value: d.puntoRetiro,
                onChanged: !d.puedeSer || _ocupado
                    ? null
                    : (v) => _hacer(() async {
                        await ref
                            .read(pedidosChapitaRepositorioProvider)
                            .prenderPuntoRetiro(widget.negocioId, prender: v);
                        ref
                            .read(metricasProvider)
                            .track(
                              Eventos.tagPickupToggle,
                              businessId: widget.negocioId,
                              props: {'prendido': v},
                            );
                      }),
              ),
            if (d.stockDisponibles + d.stockActivadas > 0)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    t.stockResumen(d.stockDisponibles, d.stockActivadas),
                  ),
                  subtitle: Text(t.stockAyuda),
                ),
              ),
            const Divider(height: 24),
            Text(t.retiroPedidos, style: tema.textTheme.titleMedium),
            if (d.pedidos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(t.retiroSinPedidos),
              ),
            for (final p in d.pedidos)
              Card(
                child: ListTile(
                  title: Text(t.pedidoChapitaNumero(p.numero, p.nombreMascota)),
                  subtitle: Text(
                    [
                      if (p.cliente case final c?) t.retiroPara(c),
                      t.retiroGrabado(p.grabado),
                      if (p.codigo case final c?) t.retiroCodigo(c),
                      switch (p.estado) {
                        EstadoPedidoChapita.nuevo => t.retiroEnPreparacion,
                        EstadoPedidoChapita.enviado => t.retiroEnCamino,
                        EstadoPedidoChapita.listo => t.retiroEsperando,
                        EstadoPedidoChapita.entregado => t.retiroEntregadaYa,
                        EstadoPedidoChapita.cancelado =>
                          t.pedidoChapitaCancelado,
                      },
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: switch (p.estado) {
                    EstadoPedidoChapita.enviado => FilledButton.tonal(
                      onPressed: _ocupado ? null : () => _avanzar(p),
                      child: Text(t.retiroLlego),
                    ),
                    EstadoPedidoChapita.listo => FilledButton(
                      onPressed: _ocupado ? null : () => _avanzar(p),
                      child: Text(t.retiroEntregada),
                    ),
                    _ => null,
                  },
                ),
              ),
            // Un pedido nuevo se puede entregar con una chapita del stock.
            for (final p in d.pedidos)
              if (p.estado == EstadoPedidoChapita.nuevo &&
                  d.stockDisponibles > 0)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.tonalIcon(
                    onPressed: _ocupado ? null : () => _entregarDeStock(p),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(t.stockEntregarNumero(p.numero)),
                  ),
                ),
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

/// Pide el código de la chapita del stock que se entrega para el pedido.
class _CodigoDeStock extends StatefulWidget {
  const _CodigoDeStock({required this.pedido});

  final PedidoChapita pedido;

  @override
  State<_CodigoDeStock> createState() => _CodigoDeStockState();
}

class _CodigoDeStockState extends State<_CodigoDeStock> {
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.stockEntregarTitulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.stockEntregarTexto(
              widget.pedido.numero,
              widget.pedido.nombreMascota,
              widget.pedido.grabado,
            ),
          ),
          TextField(
            controller: _codigo,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: t.stockCodigo),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _codigo.text),
          child: Text(t.retiroEntregada),
        ),
      ],
    );
  }
}

/// En el panel del modo comercio (solo veterinarias).
class TarjetaRetiroChapitas extends StatelessWidget {
  const TarjetaRetiroChapitas({required this.negocio, super.key});

  final MiNegocio negocio;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.qr_code_2),
      title: Text(context.t.retiroTitulo),
      subtitle: Text(context.t.retiroTarjetaAyuda),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Rutas.chapitasNegocio(negocio.id)),
    ),
  );
}
