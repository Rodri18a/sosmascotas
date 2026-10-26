import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';
import 'propuestas.dart' show ElegirLugar, hoyProvider;

/// Planes y cobros (2.2, D103; 05 §7): planes pagos de los comercios con cobro
/// manual, vencimientos e ingresos por mes y por plan.
class PlanesScreen extends ConsumerWidget {
  const PlanesScreen({super.key});

  void _refrescar(WidgetRef ref) => ref
    ..invalidate(suscripcionesProvider)
    ..invalidate(ingresosProvider)
    ..invalidate(lugaresProvider);

  Future<void> _nuevo(BuildContext context, WidgetRef ref) async {
    final creado = await showDialog<bool>(
      context: context,
      builder: (_) => const _NuevoPlan(),
    );
    if (creado ?? false) _refrescar(ref);
  }

  Future<void> _pago(BuildContext context, WidgetRef ref, Suscripcion s) async {
    final hecho = await showDialog<bool>(
      context: context,
      builder: (_) => _RegistrarPago(suscripcion: s),
    );
    if (hecho ?? false) _refrescar(ref);
  }

  Future<void> _baja(BuildContext context, WidgetRef ref, Suscripcion s) async {
    final motivo = TextEditingController();
    final si = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${T.darDeBaja} · ${s.comercio}'),
        content: TextField(
          controller: motivo,
          decoration: const InputDecoration(labelText: T.motivo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(T.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(T.darDeBaja),
          ),
        ],
      ),
    );
    if (si ?? false) {
      await ref
          .read(adminRepositorioProvider)
          .cancelarSuscripcion(s.id, motivo: motivo.text.trim());
      _refrescar(ref);
    }
    motivo.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _nuevo(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(T.nuevoPlan),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      children: [
        const Text(T.planesAyuda),
        const SizedBox(height: 8),
        if (ref.watch(ingresosProvider).value case final i?)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(T.resumenIngresos(i)),
                  for (final f in i.porMes.reversed)
                    Text(
                      '${f.mes.month}/${f.mes.year} · '
                      '${T.planes[f.plan] ?? f.plan}: '
                      '\$ ${f.total.toStringAsFixed(0)} (${f.pagos})',
                    ),
                ],
              ),
            ),
          ),
        switch (ref.watch(suscripcionesProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text(T.sinSuscripciones)),
          ),
          AsyncData(value: final lista) => Column(
            children: [
              for (final s in lista)
                Card(
                  child: ListTile(
                    title: Text(s.comercio),
                    subtitle: Text(T.suscripcionDetalle(s)),
                    isThreeLine: true,
                    trailing: s.vigente
                        ? Wrap(
                            spacing: 4,
                            children: [
                              FilledButton.tonal(
                                onPressed: () => _pago(context, ref, s),
                                child: const Text(T.registrarPago),
                              ),
                              if (s.estado != 'cancelled')
                                TextButton(
                                  onPressed: () => _baja(context, ref, s),
                                  child: const Text(T.darDeBaja),
                                ),
                            ],
                          )
                        : null,
                  ),
                ),
            ],
          ),
          AsyncError() => TextButton(
            onPressed: () => _refrescar(ref),
            child: const Text(T.reintentar),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    ),
  );
}

class _NuevoPlan extends ConsumerStatefulWidget {
  const _NuevoPlan();

  @override
  ConsumerState<_NuevoPlan> createState() => _NuevoPlanState();
}

class _NuevoPlanState extends ConsumerState<_NuevoPlan> {
  final _precio = TextEditingController(text: '0');
  final _notas = TextEditingController();
  LugarAdmin? _lugar;
  String _plan = 'featured';
  DateTime? _hasta;
  var _fundador = false;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _precio.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final lugar = _lugar;
    final hasta = _hasta;
    final precio = double.tryParse(_precio.text.replaceAll(',', '.'));
    if (lugar == null || hasta == null || precio == null || precio < 0) {
      setState(() => _error = T.faltanDatosPlan);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(adminRepositorioProvider)
          .crearSuscripcion(
            negocioId: lugar.id,
            plan: _plan,
            precio: precio,
            hasta: hasta,
            fundador: _fundador,
            notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = T.errorConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasta = _hasta;
    return AlertDialog(
      title: const Text(T.nuevoPlan),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElegirLugar(onElegido: (l) => _lugar = l),
              DropdownButtonFormField<String>(
                initialValue: _plan,
                decoration: const InputDecoration(labelText: T.plan),
                items: [
                  for (final p in ['featured', 'plus'])
                    DropdownMenuItem(value: p, child: Text(T.planes[p]!)),
                ],
                onChanged: (v) => setState(() => _plan = v ?? _plan),
              ),
              TextField(
                controller: _precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: T.precioMes),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  hasta == null
                      ? T.venceEl
                      : '${T.venceEl} ${hasta.day}/${hasta.month}/${hasta.year}',
                ),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final hoy = ref.read(hoyProvider)();
                  final elegido = await showDatePicker(
                    context: context,
                    initialDate: DateTime(hoy.year, hoy.month + 1, hoy.day),
                    firstDate: hoy,
                    lastDate: DateTime(hoy.year + 2),
                  );
                  if (elegido != null) setState(() => _hasta = elegido);
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(T.esFundador),
                value: _fundador,
                onChanged: (v) => setState(() => _fundador = v ?? false),
              ),
              TextField(
                controller: _notas,
                decoration: const InputDecoration(labelText: T.notas),
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
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(T.cancelar),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: const Text(T.guardar),
        ),
      ],
    );
  }
}

class _RegistrarPago extends ConsumerStatefulWidget {
  const _RegistrarPago({required this.suscripcion});

  final Suscripcion suscripcion;

  @override
  ConsumerState<_RegistrarPago> createState() => _RegistrarPagoState();
}

class _RegistrarPagoState extends ConsumerState<_RegistrarPago> {
  late final _monto = TextEditingController(
    text: widget.suscripcion.precio > 0
        ? widget.suscripcion.precio.toStringAsFixed(0)
        : '',
  );
  final _referencia = TextEditingController();
  String _metodo = 'transfer';
  int _meses = 1;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _monto.dispose();
    _referencia.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final monto = double.tryParse(_monto.text.replaceAll(',', '.'));
    if (monto == null || monto <= 0) {
      setState(() => _error = T.montoInvalido);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final hasta = await ref
          .read(adminRepositorioProvider)
          .registrarPago(
            widget.suscripcion.id,
            monto: monto,
            metodo: _metodo,
            referencia: _referencia.text.trim(),
            meses: _meses,
          );
      mensajes.showSnackBar(SnackBar(content: Text(T.pagoRegistrado(hasta))));
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = T.errorConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('${T.registrarPago} · ${widget.suscripcion.comercio}'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _monto,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: T.monto),
          ),
          DropdownButtonFormField<String>(
            initialValue: _metodo,
            decoration: const InputDecoration(labelText: T.metodo),
            items: [
              for (final MapEntry(:key, :value) in T.metodos.entries)
                DropdownMenuItem(value: key, child: Text(value)),
            ],
            onChanged: (v) => setState(() => _metodo = v ?? _metodo),
          ),
          DropdownButtonFormField<int>(
            initialValue: _meses,
            decoration: const InputDecoration(labelText: T.mesesPagados),
            items: [
              for (final m in [1, 2, 3, 6, 12])
                DropdownMenuItem(value: m, child: Text('$m')),
            ],
            onChanged: (v) => setState(() => _meses = v ?? _meses),
          ),
          TextField(
            controller: _referencia,
            decoration: const InputDecoration(labelText: T.referencia),
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
        onPressed: () => Navigator.pop(context, false),
        child: const Text(T.cancelar),
      ),
      FilledButton(
        onPressed: _guardando ? null : _guardar,
        child: const Text(T.registrarPago),
      ),
    ],
  );
}
