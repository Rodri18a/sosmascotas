import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart' show urlPaginaQr;

import '../repositorio.dart';
import '../textos.dart';
import '../utiles/descargar.dart';

/// Planilla para el productor: un código por fila con el enlace que va en el
/// QR de la chapita (el código también se imprime, para activarla a mano).
String csvDeLote(List<String> codigos, String base) => [
  'codigo,enlace',
  for (final c in codigos) '$c,${urlPaginaQr(c, base: base)}',
].join('\n');

/// Descarga un archivo de texto. Se reemplaza en las pruebas.
final descargarTextoProvider =
    Provider<void Function(String nombre, String contenido)>(
      (ref) =>
          (nombre, contenido) => descargarArchivo(
            utf8.encode(contenido),
            nombre,
            'text/csv;charset=utf-8',
          ),
    );

/// Chapitas físicas (1.8b.1, D95): lotes de códigos pre-codificados para
/// fabricar, con cuántas se activaron y cuántas veces se escanearon.
class ChapitasScreen extends ConsumerWidget {
  const ChapitasScreen({super.key});

  Future<void> _nuevo(BuildContext context, WidgetRef ref) async {
    final creado = await showDialog<bool>(
      context: context,
      builder: (_) => const _Formulario(),
    );
    if (creado ?? false) ref.invalidate(lotesProvider);
  }

  Future<void> _descargar(WidgetRef ref, Map<String, Object?> lote) async {
    final codigos = await ref
        .read(adminRepositorioProvider)
        .codigosLote('${lote['id']}');
    final fecha = '${lote['created_at']}'.split('T').first;
    ref.read(descargarTextoProvider)(
      'chapitas-$fecha-${codigos.length}.csv',
      csvDeLote(codigos, ref.read(urlPublicaProvider)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _nuevo(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(T.nuevoLote),
    ),
    body: switch (ref.watch(lotesProvider)) {
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        children: [
          Text(
            '${T.avisoDireccion}\n${ref.watch(urlPublicaProvider)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          const _Pedidos(),
          const SizedBox(height: 16),
          Text(T.lotes, style: Theme.of(context).textTheme.titleMedium),
          if (lista.isEmpty) const Text(T.sinLotes),
          for (final l in lista)
            Card(
              child: ListTile(
                title: Text(
                  T.resumenLote(
                    (l['quantity'] as num?)?.toInt() ?? 0,
                    (l['activadas'] as num?)?.toInt() ?? 0,
                    (l['escaneos'] as num?)?.toInt() ?? 0,
                  ),
                ),
                subtitle: Text(
                  [
                    '${l['created_at']}'.split('T').first,
                    ?l['producer'] as String?,
                    ?l['material'] as String?,
                    if (l['unit_cost'] case final num c) '\$ $c',
                    ?l['note'] as String?,
                  ].join(' · '),
                ),
                trailing: OutlinedButton.icon(
                  onPressed: () => _descargar(ref, l),
                  icon: const Icon(Icons.download),
                  label: const Text(T.descargarCsv),
                ),
              ),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(lotesProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario();

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _cantidad = TextEditingController(text: '50');
  final _productor = TextEditingController();
  final _material = TextEditingController();
  final _costo = TextEditingController();
  final _nota = TextEditingController();
  String? _error;
  var _creando = false;

  @override
  void dispose() {
    for (final c in [_cantidad, _productor, _material, _costo, _nota]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _texto(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _crear() async {
    final cantidad = int.tryParse(_cantidad.text.trim());
    final costo = _costo.text.trim().isEmpty
        ? null
        : num.tryParse(_costo.text.trim().replaceAll(',', '.'));
    if (cantidad == null ||
        cantidad < 1 ||
        cantidad > 500 ||
        (_costo.text.trim().isNotEmpty && costo == null)) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    setState(() => _creando = true);
    try {
      await ref
          .read(adminRepositorioProvider)
          .crearLote(
            cantidad: cantidad,
            productor: _texto(_productor),
            material: _texto(_material),
            costo: costo,
            nota: _texto(_nota),
          );
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) {
        setState(() {
          _creando = false;
          _error = T.errorConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(T.nuevoLote),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cantidad,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: T.cantidad),
            ),
            TextField(
              controller: _productor,
              decoration: const InputDecoration(labelText: T.productor),
            ),
            TextField(
              controller: _material,
              decoration: const InputDecoration(labelText: T.material),
            ),
            TextField(
              controller: _costo,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: T.costoUnidad),
            ),
            TextField(
              controller: _nota,
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
        onPressed: _creando ? null : _crear,
        child: const Text(T.crear),
      ),
    ],
  );
}

/// Pedidos abiertos: asignar un código y mandarlo, o cancelarlo.
class _Pedidos extends ConsumerWidget {
  const _Pedidos();

  Future<void> _enviar(
    BuildContext context,
    WidgetRef ref,
    Map<String, Object?> p,
  ) async {
    final enviado = await showDialog<bool>(
      context: context,
      builder: (_) => _Enviar(pedidoId: '${p['id']}'),
    );
    if (enviado ?? false) ref.invalidate(pedidosChapitaProvider);
  }

  Future<void> _cancelar(WidgetRef ref, Map<String, Object?> p) async {
    await ref
        .read(adminRepositorioProvider)
        .cancelarPedidoChapita('${p['id']}');
    ref.invalidate(pedidosChapitaProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abiertos = [
      for (final p
          in ref.watch(pedidosChapitaProvider).value ??
              const <Map<String, Object?>>[])
        if (const {'new', 'sent', 'ready'}.contains(p['status'])) p,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(T.pedidosChapita, style: Theme.of(context).textTheme.titleMedium),
        if (abiertos.isEmpty) const Text(T.sinPedidosChapita),
        for (final p in abiertos)
          Card(
            child: ListTile(
              title: Text(
                T.pedidoChapita(
                  (p['number'] as num?)?.toInt() ?? 0,
                  '${p['pet_name']}',
                  '${p['engraving']}',
                ),
              ),
              subtitle: Text(
                [
                  T.estadosPedidoChapita[p['status']] ?? '${p['status']}',
                  '${p['business_name']}',
                  ?p['business_address'] as String?,
                  ?p['code'] as String?,
                ].join(' · '),
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  if (p['status'] == 'new')
                    FilledButton(
                      onPressed: () => _enviar(context, ref, p),
                      child: const Text(T.enviar),
                    ),
                  TextButton(
                    onPressed: () => _cancelar(ref, p),
                    child: const Text(T.cancelarPedido),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Enviar extends ConsumerStatefulWidget {
  const _Enviar({required this.pedidoId});

  final String pedidoId;

  @override
  ConsumerState<_Enviar> createState() => _EnviarState();
}

class _EnviarState extends ConsumerState<_Enviar> {
  final _codigo = TextEditingController();
  String? _error;
  var _enviando = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref
          .read(adminRepositorioProvider)
          .enviarPedidoChapita(widget.pedidoId, _codigo.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.chapitaNoDisponible);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(T.enviarPedidoTitulo),
    content: TextField(
      controller: _codigo,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: T.codigoChapita,
        errorText: _error,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(T.cancelarPedido),
      ),
      FilledButton(
        onPressed: _enviando ? null : _enviar,
        child: const Text(T.enviar),
      ),
    ],
  );
}
