import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';
import '../utiles/descargar.dart';
import 'chapitas.dart' show descargarTextoProvider;

/// Abre el selector de imágenes del navegador. Se reemplaza en las pruebas.
final elegirImagenProvider = Provider<Future<ImagenElegida?> Function()>(
  (ref) => elegirImagen,
);

int _n(Object? v) => (v as num?)?.toInt() ?? 0;

/// El reporte para el sponsor como planilla: una fila por lote.
String csvReporteSponsor(Map<String, Object?> reporte) => [
  'lote,chapitas,material,activadas,escaneos,reencuentros',
  for (final l in (reporte['lotes'] as List?) ?? const [])
    if (l case final Map<String, Object?> l)
      [
        '${l['created_at']}'.split('T').first,
        _n(l['quantity']),
        '"${'${l['material'] ?? ''}'.replaceAll('"', '""')}"',
        _n(l['activadas']),
        _n(l['escaneos']),
        _n(l['reencuentros']),
      ].join(','),
].join('\n');

/// Sponsors de lotes (2.9, D105): alta, logo y el reporte para mandarles.
class SponsorsSeccion extends ConsumerWidget {
  const SponsorsSeccion({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Map<String, Object?>? sponsor,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioSponsor(sponsor: sponsor),
    );
    if (guardado ?? false) {
      ref
        ..invalidate(sponsorsProvider)
        ..invalidate(lotesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista =
        ref.watch(sponsorsProvider).value ?? const <Map<String, Object?>>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                T.sponsors,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => _editar(context, ref),
              icon: const Icon(Icons.add),
              label: const Text(T.nuevoSponsor),
            ),
          ],
        ),
        Text(T.sponsorsAyuda, style: Theme.of(context).textTheme.bodySmall),
        if (lista.isEmpty) const Text(T.sinSponsors),
        for (final s in lista)
          Card(
            child: ListTile(
              title: Text(
                s['active'] == false
                    ? '${s['name']} (${T.inactivo})'
                    : '${s['name']}',
              ),
              subtitle: Text(
                [
                  T.resumenSponsor(_n(s['lotes']), _n(s['chapitas'])),
                  if (s['logo_path'] == null) T.sinLogo,
                ].join(' · '),
              ),
              onTap: () => _editar(context, ref, s),
              trailing: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      _Reporte(sponsorId: '${s['id']}', nombre: '${s['name']}'),
                ),
                child: const Text(T.reporte),
              ),
            ),
          ),
      ],
    );
  }
}

class _FormularioSponsor extends ConsumerStatefulWidget {
  const _FormularioSponsor({this.sponsor});

  final Map<String, Object?>? sponsor;

  @override
  ConsumerState<_FormularioSponsor> createState() => _FormularioSponsorState();
}

class _FormularioSponsorState extends ConsumerState<_FormularioSponsor> {
  late final _nombre = TextEditingController(
    text: widget.sponsor?['name'] as String?,
  );
  late final _notas = TextEditingController(
    text: widget.sponsor?['notes'] as String?,
  );
  late var _activo = widget.sponsor?['active'] != false;
  late final String? _logoActual = widget.sponsor?['logo_path'] as String?;
  ImagenElegida? _logoNuevo;
  String? _error;
  var _guardando = false;

  static const _tipos = {'image/png', 'image/jpeg', 'image/webp'};

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirLogo() async {
    final imagen = await ref.read(elegirImagenProvider)();
    if (imagen == null || !mounted) return;
    if (!_tipos.contains(imagen.tipo) || imagen.bytes.length > 512 * 1024) {
      setState(() => _error = T.logoGrande);
      return;
    }
    setState(() {
      _logoNuevo = imagen;
      _error = null;
    });
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      setState(() => _error = T.faltaNombre);
      return;
    }
    setState(() => _guardando = true);
    final repo = ref.read(adminRepositorioProvider);
    try {
      final logo = switch (_logoNuevo) {
        final l? => await repo.subirLogo(l.bytes, l.tipo),
        null => _logoActual,
      };
      await repo.guardarSponsor({
        if (widget.sponsor?['id'] case final String id) 'id': id,
        'name': _nombre.text.trim(),
        'notes': _notas.text.trim(),
        'active': _activo,
        'logo_path': logo,
        'business_id': widget.sponsor?['business_id'],
      });
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
    title: Text(widget.sponsor == null ? T.nuevoSponsor : T.editarSponsor),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombre,
              maxLength: 80,
              decoration: const InputDecoration(labelText: T.nombreSponsor),
            ),
            TextField(
              controller: _notas,
              maxLength: 500,
              decoration: const InputDecoration(labelText: T.notasSponsor),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(T.sponsorActivo),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
            ),
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _elegirLogo,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _logoActual == null && _logoNuevo == null
                        ? T.elegirLogo
                        : T.cambiarLogo,
                  ),
                ),
                Text(
                  _logoActual == null && _logoNuevo == null
                      ? T.sinLogo
                      : T.logoListo,
                ),
              ],
            ),
            if (_error case final e?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  e,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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

class _Reporte extends ConsumerStatefulWidget {
  const _Reporte({required this.sponsorId, required this.nombre});

  final String sponsorId;
  final String nombre;

  @override
  ConsumerState<_Reporte> createState() => _ReporteState();
}

class _ReporteState extends ConsumerState<_Reporte> {
  late final _reporte = ref
      .read(adminRepositorioProvider)
      .reporteSponsor(widget.sponsorId);

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _reporte,
    builder: (context, foto) {
      final reporte = foto.data;
      final lotes = [
        for (final l in (reporte?['lotes'] as List?) ?? const [])
          if (l case final Map<String, Object?> l) l,
      ];
      return AlertDialog(
        title: Text(T.reporteTitulo(widget.nombre)),
        content: SizedBox(
          width: 480,
          child: switch (foto) {
            AsyncSnapshot(hasError: true) => const Text(T.errorConexion),
            AsyncSnapshot(hasData: false) => const LinearProgressIndicator(),
            _ => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lotes.isEmpty) const Text(T.sinLotesSponsor),
                for (final l in lotes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SelectableText(
                      T.lineaReporte(
                        '${l['created_at']}'.split('T').first,
                        _n(l['quantity']),
                        _n(l['activadas']),
                        _n(l['escaneos']),
                        _n(l['reencuentros']),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  T.reporteAyuda,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(T.cerrar),
          ),
          if (reporte != null && lotes.isNotEmpty)
            FilledButton.icon(
              onPressed: () => ref.read(descargarTextoProvider)(
                'reporte-${widget.nombre.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-')}.csv',
                csvReporteSponsor(reporte),
              ),
              icon: const Icon(Icons.download),
              label: const Text(T.descargarCsv),
            ),
        ],
      );
    },
  );
}

/// Elige el sponsor de un lote. Devuelve el id, '' para quitarlo o null si
/// se canceló.
Future<String?> elegirSponsor(BuildContext context, WidgetRef ref) async {
  final lista = await ref.read(sponsorsProvider.future);
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text(T.ponerSponsor),
      children: [
        for (final s in lista)
          if (s['active'] != false)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, '${s['id']}'),
              child: Text('${s['name']}'),
            ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text(T.sinSponsor),
        ),
      ],
    ),
  );
}

/// Pasa chapitas libres de un lote al stock de una veterinaria verificada y
/// muestra los códigos que hay que entregarle.
class AsignarStock extends ConsumerStatefulWidget {
  const AsignarStock({required this.loteId, super.key});

  final String loteId;

  @override
  ConsumerState<AsignarStock> createState() => _AsignarStockState();
}

class _AsignarStockState extends ConsumerState<AsignarStock> {
  final _cantidad = TextEditingController(text: '10');
  String? _negocio;
  List<String>? _codigos;
  String? _error;
  var _pasando = false;

  @override
  void dispose() {
    _cantidad.dispose();
    super.dispose();
  }

  Future<void> _pasar() async {
    final cantidad = int.tryParse(_cantidad.text.trim());
    if (_negocio == null ||
        cantidad == null ||
        cantidad < 1 ||
        cantidad > 200) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    setState(() {
      _pasando = true;
      _error = null;
    });
    try {
      final codigos = await ref
          .read(adminRepositorioProvider)
          .asignarStock(widget.loteId, _negocio!, cantidad);
      ref
        ..invalidate(stockProvider)
        ..invalidate(lotesProvider);
      if (mounted) setState(() => _codigos = codigos);
    } on Exception catch (e) {
      if (mounted) {
        setState(
          () => _error = '$e'.contains('no_alcanzan')
              ? T.noAlcanzan
              : T.errorConexion,
        );
      }
    } finally {
      if (mounted) setState(() => _pasando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vetes = [
      for (final l
          in ref.watch(lugaresProvider('')).value ?? const <LugarAdmin>[])
        if (l.datos['business_type'] == 'vet' &&
            l.verificacion == 'verified' &&
            l.estado == 'active')
          l,
    ];
    if (_codigos case final codigos?) {
      return AlertDialog(
        title: const Text(T.pasarAStock),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(T.codigosParaEntregar(codigos.length)),
              const SizedBox(height: 8),
              SelectableText(codigos.join('\n')),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(T.cerrar),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text(T.pasarAStock),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vetes.isEmpty)
              const Text(T.sinVeterinarias)
            else
              DropdownButtonFormField<String>(
                initialValue: _negocio,
                isExpanded: true,
                decoration: const InputDecoration(labelText: T.veterinaria),
                items: [
                  for (final v in vetes)
                    DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.datos['name']}'),
                    ),
                ],
                onChanged: (v) => setState(() => _negocio = v),
              ),
            TextField(
              controller: _cantidad,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: T.cantidadStock),
            ),
            if (_error case final e?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  e,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(T.cancelar),
        ),
        FilledButton(
          onPressed: _pasando || vetes.isEmpty ? null : _pasar,
          child: const Text(T.asignar),
        ),
      ],
    );
  }
}

/// Stock por veterinaria, con la opción de sacar una chapita que no se usó.
class StockSeccion extends ConsumerWidget {
  const StockSeccion({super.key});

  Future<void> _quitar(BuildContext context, WidgetRef ref) async {
    final quitada = await showDialog<bool>(
      context: context,
      builder: (_) => const _QuitarStock(),
    );
    if (quitada ?? false) {
      ref
        ..invalidate(stockProvider)
        ..invalidate(lotesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista =
        ref.watch(stockProvider).value ?? const <Map<String, Object?>>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(T.stockTitulo, style: Theme.of(context).textTheme.titleMedium),
        Text(T.stockAyuda, style: Theme.of(context).textTheme.bodySmall),
        if (lista.isEmpty) const Text(T.sinStock),
        for (final v in lista)
          Card(
            child: ListTile(
              title: Text('${v['business_name']}'),
              subtitle: Text(
                [
                  T.resumenStock(
                    _n(v['recibidas']),
                    _n(v['disponibles']),
                    _n(v['activadas']),
                  ),
                  ?v['address'] as String?,
                ].join(' · '),
              ),
              trailing: TextButton(
                onPressed: () => _quitar(context, ref),
                child: const Text(T.quitarUna),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuitarStock extends ConsumerStatefulWidget {
  const _QuitarStock();

  @override
  ConsumerState<_QuitarStock> createState() => _QuitarStockState();
}

class _QuitarStockState extends ConsumerState<_QuitarStock> {
  final _codigo = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _quitar() async {
    try {
      await ref.read(adminRepositorioProvider).quitarStock(_codigo.text.trim());
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.chapitaNoDisponible);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(T.quitarStockTitulo),
    content: TextField(
      controller: _codigo,
      autofocus: true,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(labelText: T.codigoStock, errorText: _error),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(T.cancelar),
      ),
      FilledButton(onPressed: _quitar, child: const Text(T.quitar)),
    ],
  );
}
