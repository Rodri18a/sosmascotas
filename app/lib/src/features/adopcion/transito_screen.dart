import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../adopcion/adopcion_repositorio.dart';
import '../../adopcion/transito_repositorio.dart';
import '../../mascotas/catalogo.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/volver.dart';

String _textoTamano(AppLocalizations t, String v) => switch (v) {
  'chico' => t.adopcionChico,
  'mediano' => t.adopcionMediano,
  _ => t.adopcionGrande,
};

String textoErrorTransito(AppLocalizations t, ErrorTransito e) => switch (e) {
  ErrorTransito.soloRefugios => t.transitoSoloRefugios,
  ErrorTransito.noDisponible => t.transitoNoDisponible,
  ErrorTransito.noRecibe => t.transitoNoRecibe,
  ErrorTransito.masDias => t.transitoMasDias,
  ErrorTransito.yaHayUno => t.transitoYaHayUno,
  ErrorTransito.limite => t.transitoLimite,
  ErrorTransito.noSePuede => t.errorDesconocido,
  ErrorTransito.sinConexion => t.errorSinConexion,
};

String _especies(List<Especie> todas, List<int> ids) => [
  for (final e in todas)
    if (ids.contains(e.id)) '${e.icono} ${e.nombre}',
].join(', ');

/// Ayuda → Adopción → Hogar de tránsito (3.4b, D106): me anoto, pauso o me
/// borro, y respondo los pedidos de los refugios.
class HogarTransitoScreen extends ConsumerStatefulWidget {
  const HogarTransitoScreen({super.key});

  @override
  ConsumerState<HogarTransitoScreen> createState() => _HogarTransitoState();
}

class _HogarTransitoState extends ConsumerState<HogarTransitoScreen> {
  final _dias = TextEditingController(text: '30');
  final _barrio = TextEditingController();
  final _notas = TextEditingController();
  var _especies = <int>{};
  var _tamanos = {...tamanosTransito};
  var _patio = false;
  var _otros = false;
  var _activo = true;
  var _cargado = false;
  var _existe = false;
  var _ocupado = false;

  @override
  void dispose() {
    _dias.dispose();
    _barrio.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _cargar(HogarTransito? h) {
    _cargado = true;
    if (h == null) return;
    _existe = true;
    _especies = {...h.especies};
    _tamanos = {...h.tamanos};
    _dias.text = '${h.maxDias}';
    _patio = h.patio;
    _otros = h.otrosAnimales;
    _barrio.text = h.barrio ?? '';
    _notas.text = h.notas ?? '';
    _activo = h.activo;
  }

  void _avisar(String texto) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _guardar() async {
    final t = context.t;
    final dias = int.tryParse(_dias.text.trim());
    if (_especies.isEmpty ||
        _tamanos.isEmpty ||
        dias == null ||
        dias < 1 ||
        dias > 365 ||
        _barrio.text.trim().isEmpty) {
      _avisar(t.transitoFaltanDatos);
      return;
    }
    setState(() => _ocupado = true);
    try {
      await ref
          .read(transitoRepositorioProvider)
          .guardarHogar(
            HogarTransito(
              especies: _especies.toList()..sort(),
              tamanos: [
                for (final v in tamanosTransito)
                  if (_tamanos.contains(v)) v,
              ],
              maxDias: dias,
              patio: _patio,
              otrosAnimales: _otros,
              barrio: _barrio.text,
              notas: _notas.text,
              activo: _activo,
            ),
          );
      ref
          .read(metricasProvider)
          .track(Eventos.fosterHomeSave, props: {'activo': _activo});
      ref.invalidate(miHogarTransitoProvider);
      _existe = true;
      _avisar(t.transitoGuardado);
    } on TransitoException catch (e) {
      _avisar(textoErrorTransito(t, e.motivo));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _borrar() async {
    final t = context.t;
    final si = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.transitoBorrarTitulo),
        content: Text(t.transitoBorrarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.transitoBorrar),
          ),
        ],
      ),
    );
    if (!(si ?? false)) return;
    try {
      await ref.read(transitoRepositorioProvider).borrarHogar();
      ref
        ..invalidate(miHogarTransitoProvider)
        ..invalidate(misPedidosTransitoProvider);
      if (mounted) setState(() => _cargado = _existe = false);
    } on TransitoException catch (e) {
      _avisar(textoErrorTransito(t, e.motivo));
    }
  }

  Future<void> _responder(PedidoTransito p, {required bool aceptar}) async {
    final t = context.t;
    try {
      final chat = await ref
          .read(transitoRepositorioProvider)
          .responder(p.id, aceptar: aceptar);
      ref
          .read(metricasProvider)
          .track(
            Eventos.fosterRequestAnswer,
            targetId: p.id,
            businessId: p.refugioId,
            props: {'acepta': aceptar},
          );
      ref.invalidate(misPedidosTransitoProvider);
      if (chat != null && mounted) await context.push(Rutas.chat(chat));
    } on TransitoException catch (e) {
      _avisar(textoErrorTransito(t, e.motivo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final mio = ref.watch(miHogarTransitoProvider);
    if (mio case AsyncData(:final value) when !_cargado) _cargar(value);
    final pedidos =
        ref.watch(misPedidosTransitoProvider).value ?? const <PedidoTransito>[];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.transitoTitulo),
      ),
      body: !_cargado
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t.transitoIntro),
                const SizedBox(height: 8),
                Text(t.transitoPrivacidad, style: tema.textTheme.bodySmall),
                if (pedidos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(t.transitoPedidos, style: tema.textTheme.titleMedium),
                  for (final p in pedidos)
                    _TarjetaPedido(
                      pedido: p,
                      especies: especies,
                      onAceptar: () => _responder(p, aceptar: true),
                      onRechazar: () => _responder(p, aceptar: false),
                    ),
                ],
                const Divider(height: 32),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.transitoActivo),
                  subtitle: Text(t.transitoActivoAyuda),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                ),
                Text(t.transitoEspecies, style: tema.textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in especies)
                      FilterChip(
                        label: Text('${e.icono} ${e.nombre}'),
                        selected: _especies.contains(e.id),
                        onSelected: (v) => setState(
                          () =>
                              v ? _especies.add(e.id) : _especies.remove(e.id),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(t.transitoTamanos, style: tema.textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final v in tamanosTransito)
                      FilterChip(
                        label: Text(_textoTamano(t, v)),
                        selected: _tamanos.contains(v),
                        onSelected: (s) => setState(
                          () => s ? _tamanos.add(v) : _tamanos.remove(v),
                        ),
                      ),
                  ],
                ),
                TextField(
                  controller: _dias,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.transitoMaxDias),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.transitoPatio),
                  value: _patio,
                  onChanged: (v) => setState(() => _patio = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.transitoOtros),
                  value: _otros,
                  onChanged: (v) => setState(() => _otros = v),
                ),
                TextField(
                  controller: _barrio,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: t.transitoBarrio,
                    helperText: t.transitoBarrioAyuda,
                  ),
                ),
                TextField(
                  controller: _notas,
                  maxLength: 300,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: t.transitoNotas),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _ocupado ? null : _guardar,
                  child: Text(_existe ? t.guardar : t.transitoAnotarme),
                ),
                if (_existe)
                  TextButton(
                    onPressed: _ocupado ? null : _borrar,
                    child: Text(t.transitoBorrar),
                  ),
              ],
            ),
    );
  }
}

class _TarjetaPedido extends StatelessWidget {
  const _TarjetaPedido({
    required this.pedido,
    required this.especies,
    required this.onAceptar,
    required this.onRechazar,
  });

  final PedidoTransito pedido;
  final List<Especie> especies;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = pedido;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.transitoPedidoDe(p.refugio ?? '', p.nombreAnimal),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              [
                _especies(especies, [p.especieId]),
                if (p.tamano case final v?) _textoTamano(t, v),
                t.transitoDias(p.dias),
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
            if (p.mensaje case final m?) Text('«$m»'),
            const SizedBox(height: 8),
            switch (p.estado) {
              EstadoTransito.nuevo => Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: onAceptar,
                    child: Text(t.transitoAceptar),
                  ),
                  TextButton(
                    onPressed: onRechazar,
                    child: Text(t.transitoRechazar),
                  ),
                ],
              ),
              EstadoTransito.aceptado => Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(t.transitoAceptado),
                  if (p.conversacionId case final c?)
                    TextButton.icon(
                      onPressed: () => context.push(Rutas.chat(c)),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(t.transitoAbrirChat),
                    ),
                ],
              ),
              EstadoTransito.rechazado => Text(t.transitoRechazado),
              EstadoTransito.cancelado => Text(t.transitoCancelado),
              EstadoTransito.terminado => Text(t.transitoTerminado),
            },
          ],
        ),
      ),
    );
  }
}

/// Modo comercio → Hogares de tránsito (solo refugios verificados): los
/// hogares de la zona y los pedidos que hizo el refugio.
class TransitoRefugioScreen extends ConsumerStatefulWidget {
  const TransitoRefugioScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<TransitoRefugioScreen> createState() => _TransitoRefugioState();
}

class _TransitoRefugioState extends ConsumerState<TransitoRefugioScreen> {
  var _ocupado = false;

  void _refrescar() => ref
    ..invalidate(hogaresTransitoProvider(widget.negocioId))
    ..invalidate(pedidosTransitoRefugioProvider(widget.negocioId));

  Future<void> _pedir(HogarDisponible h, List<Especie> especies) async {
    final pedido = await showDialog<_Pedido>(
      context: context,
      builder: (_) => _PedirTransito(hogar: h, especies: especies),
    );
    if (pedido == null || !mounted) return;
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _ocupado = true);
    try {
      await ref
          .read(transitoRepositorioProvider)
          .pedir(
            refugioId: widget.negocioId,
            hogarId: h.id,
            dias: pedido.dias,
            nombre: pedido.nombre,
            especieId: pedido.especieId,
            tamano: pedido.tamano,
            mensaje: pedido.mensaje,
          );
      ref
          .read(metricasProvider)
          .track(Eventos.fosterRequestCreate, businessId: widget.negocioId);
      _refrescar();
      mensajes.showSnackBar(SnackBar(content: Text(t.transitoPedidoEnviado)));
    } on TransitoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorTransito(t, e.motivo))),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cerrar(PedidoTransito p) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final nuevo = await ref.read(transitoRepositorioProvider).cerrar(p.id);
      ref
          .read(metricasProvider)
          .track(
            Eventos.fosterRequestClose,
            businessId: widget.negocioId,
            targetId: p.id,
            props: {'estado': nuevo.valor},
          );
      _refrescar();
    } on TransitoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorTransito(t, e.motivo))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final pedidos =
        ref.watch(pedidosTransitoRefugioProvider(widget.negocioId)).value ??
        const <PedidoTransito>[];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.transitoRefugioTitulo),
      ),
      body: switch (ref.watch(hogaresTransitoProvider(widget.negocioId))) {
        AsyncData(value: final hogares) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.transitoRefugioAyuda, style: tema.textTheme.bodySmall),
            if (pedidos.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(t.transitoTusPedidos, style: tema.textTheme.titleMedium),
              for (final p in pedidos)
                Card(
                  child: ListTile(
                    title: Text(
                      t.transitoPedidoA(p.nombreAnimal, p.hogar ?? ''),
                    ),
                    subtitle: Text(
                      [
                        t.transitoDias(p.dias),
                        ?p.barrio,
                        switch (p.estado) {
                          EstadoTransito.nuevo => t.transitoEsperando,
                          EstadoTransito.aceptado => t.transitoAceptado,
                          EstadoTransito.rechazado => t.transitoRechazado,
                          EstadoTransito.cancelado => t.transitoCancelado,
                          EstadoTransito.terminado => t.transitoTerminado,
                        },
                      ].join(' · '),
                    ),
                  ),
                ),
              for (final p in pedidos)
                if (p.estado.abierto)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (p.conversacionId case final c?)
                          TextButton.icon(
                            onPressed: () => context.push(Rutas.chat(c)),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(t.transitoChatCon(p.hogar ?? '')),
                          ),
                        TextButton(
                          onPressed: () => _cerrar(p),
                          child: Text(
                            p.estado == EstadoTransito.nuevo
                                ? t.transitoCancelarPedido(p.nombreAnimal)
                                : t.transitoTerminar(p.nombreAnimal),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
            const SizedBox(height: 16),
            Text(t.transitoHogares, style: tema.textTheme.titleMedium),
            if (hogares.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(t.transitoSinHogares),
              ),
            for (final h in hogares)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [h.nombre, ?h.barrio].join(' · '),
                        style: tema.textTheme.titleSmall,
                      ),
                      Text(
                        [
                          _especies(especies, h.especies),
                          h.tamanos.map((v) => _textoTamano(t, v)).join(', '),
                          t.transitoHasta(h.maxDias),
                          if (h.patio) t.transitoConPatio,
                          if (h.otrosAnimales) t.transitoConOtros,
                        ].where((s) => s.isNotEmpty).join(' · '),
                      ),
                      if (h.notas case final n?) Text('«$n»'),
                      if (h.conAnimal) Text(t.transitoConAnimal),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: h.pedidoAbierto
                            ? Text(t.transitoYaPediste)
                            : FilledButton.tonal(
                                onPressed: _ocupado
                                    ? null
                                    : () => _pedir(h, especies),
                                child: Text(t.transitoPedir),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is TransitoException
                  ? textoErrorTransito(t, error.motivo)
                  : t.errorSinConexion,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      },
    );
  }
}

typedef _Pedido = ({
  String nombre,
  int especieId,
  String? tamano,
  int dias,
  String? mensaje,
});

class _PedirTransito extends ConsumerStatefulWidget {
  const _PedirTransito({required this.hogar, required this.especies});

  final HogarDisponible hogar;
  final List<Especie> especies;

  @override
  ConsumerState<_PedirTransito> createState() => _PedirTransitoState();
}

class _PedirTransitoState extends ConsumerState<_PedirTransito> {
  final _nombre = TextEditingController();
  final _mensaje = TextEditingController();
  late final _dias = TextEditingController(
    text: '${widget.hogar.maxDias < 15 ? widget.hogar.maxDias : 15}',
  );
  late int? _especie = widget.hogar.especies.firstOrNull;
  String? _tamano;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _mensaje.dispose();
    _dias.dispose();
    super.dispose();
  }

  void _listo() {
    final t = context.t;
    final dias = int.tryParse(_dias.text.trim());
    if (_nombre.text.trim().isEmpty || _especie == null || dias == null) {
      setState(() => _error = t.transitoFaltanDatos);
      return;
    }
    if (dias < 1 || dias > widget.hogar.maxDias) {
      setState(() => _error = t.transitoMasDias);
      return;
    }
    Navigator.pop<_Pedido>(context, (
      nombre: _nombre.text.trim(),
      especieId: _especie!,
      tamano: _tamano,
      dias: dias,
      mensaje: _mensaje.text.trim().isEmpty ? null : _mensaje.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final h = widget.hogar;
    // Si el refugio publicó animales, puede elegir uno (nombre, especie, tamaño).
    final mios = [
      for (final a
          in ref.watch(disponiblesProvider).value ?? const <AnimalAdopcion>[])
        if (a.mio && h.especies.contains(a.especieId)) a,
    ];
    return AlertDialog(
      title: Text(t.transitoPedirA(h.nombre)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mios.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  for (final a in mios)
                    ActionChip(
                      label: Text(a.nombre ?? '🐾'),
                      onPressed: () => setState(() {
                        _nombre.text = a.nombre ?? '';
                        _especie = a.especieId;
                        _tamano = h.tamanos.contains(a.tamano)
                            ? a.tamano
                            : null;
                      }),
                    ),
                ],
              ),
            TextField(
              controller: _nombre,
              maxLength: 40,
              decoration: InputDecoration(labelText: t.transitoNombreAnimal),
            ),
            DropdownButtonFormField<int>(
              key: ValueKey(_especie),
              initialValue: _especie,
              decoration: InputDecoration(labelText: t.transitoEspecie),
              items: [
                for (final e in widget.especies)
                  if (h.especies.contains(e.id))
                    DropdownMenuItem(
                      value: e.id,
                      child: Text('${e.icono} ${e.nombre}'),
                    ),
              ],
              onChanged: (v) => setState(() => _especie = v),
            ),
            DropdownButtonFormField<String?>(
              key: ValueKey(_tamano),
              initialValue: _tamano,
              decoration: InputDecoration(labelText: t.transitoTamano),
              items: [
                DropdownMenuItem(child: Text(t.transitoTamanoSinDecir)),
                for (final v in h.tamanos)
                  DropdownMenuItem(value: v, child: Text(_textoTamano(t, v))),
              ],
              onChanged: (v) => setState(() => _tamano = v),
            ),
            TextField(
              controller: _dias,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.transitoCuantosDias(h.maxDias),
              ),
            ),
            TextField(
              controller: _mensaje,
              maxLength: 500,
              maxLines: 2,
              decoration: InputDecoration(labelText: t.transitoMensaje),
            ),
            if (_error case final e?)
              Text(
                e,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(onPressed: _listo, child: Text(t.transitoPedir)),
      ],
    );
  }
}

/// En el panel del modo comercio (solo refugios verificados).
class TarjetaTransitoRefugio extends StatelessWidget {
  const TarjetaTransitoRefugio({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.house_outlined),
      title: Text(context.t.transitoRefugioTitulo),
      subtitle: Text(context.t.transitoRefugioTarjeta),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(Rutas.transitoRefugio(negocioId)),
    ),
  );
}
