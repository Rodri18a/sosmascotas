import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart' show MetricasComercio;

import '../modelos.dart';
import '../propuesta_html.dart';
import '../repositorio.dart';
import '../textos.dart';
import '../utiles/descargar.dart';

/// Descarga la página de la propuesta. Se reemplaza en las pruebas.
final descargarHtmlProvider =
    Provider<void Function(String nombre, String html)>(
      (ref) =>
          (nombre, html) => descargarArchivo(
            utf8.encode(html),
            nombre,
            'text/html;charset=utf-8',
          ),
    );

/// Fecha de hoy (se reemplaza en las pruebas).
final hoyProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Generador de propuestas y casos de éxito (2.4, D102; 05 §5 y §6).
class PropuestasScreen extends ConsumerWidget {
  const PropuestasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(12),
    children: const [_Generador(), SizedBox(height: 16), _Casos()],
  );
}

/// Elegir un comercio del mapa por nombre (también en Planes).
class ElegirLugar extends ConsumerWidget {
  const ElegirLugar({required this.onElegido, super.key});

  final void Function(LugarAdmin? lugar) onElegido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lugares = ref.watch(lugaresProvider('')).value ?? const [];
    return Autocomplete<LugarAdmin>(
      displayStringForOption: (l) => l.comercio.nombre,
      optionsBuilder: (texto) {
        final buscar = texto.text.trim().toLowerCase();
        if (buscar.isEmpty) {
          onElegido(null);
          return const [];
        }
        return lugares
            .where((l) => l.comercio.nombre.toLowerCase().contains(buscar))
            .take(8);
      },
      onSelected: onElegido,
      fieldViewBuilder: (context, control, foco, enviar) => TextField(
        controller: control,
        focusNode: foco,
        decoration: const InputDecoration(labelText: T.comercioOpcional),
      ),
    );
  }
}

class _Generador extends ConsumerStatefulWidget {
  const _Generador();

  @override
  ConsumerState<_Generador> createState() => _GeneradorState();
}

class _GeneradorState extends ConsumerState<_Generador> {
  String? _rubro;
  LugarAdmin? _lugar;
  Propuesta? _propuesta;
  var _cargando = false;
  String? _error;

  String? get _rubroElegido =>
      _rubro ?? _lugar?.datos['business_type'] as String?;

  Future<void> _ver() async {
    final rubro = _rubroElegido;
    if (rubro == null) {
      setState(() => _error = T.faltaRubro);
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final p = await ref
          .read(adminRepositorioProvider)
          .propuesta(rubro: rubro, negocioId: _lugar?.id);
      if (mounted) setState(() => _propuesta = p);
    } on Exception {
      if (mounted) setState(() => _error = T.errorConexion);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _descargar(Propuesta p) async {
    final mensajes = ScaffoldMessenger.of(context);
    final hoy = ref.read(hoyProvider)();
    final nombre = (_lugar?.comercio.nombre ?? T.rubros[p.rubro] ?? p.rubro)
        .toLowerCase()
        .replaceAllMapped(
          RegExp('[áéíóúüñ]'),
          (m) => const {
            'á': 'a',
            'é': 'e',
            'í': 'i',
            'ó': 'o',
            'ú': 'u',
            'ü': 'u',
            'ñ': 'n',
          }[m[0]]!,
        )
        .replaceAll(RegExp('[^a-z0-9]+'), '-');
    ref.read(descargarHtmlProvider)(
      'propuesta-$nombre-${hoy.year}-${hoy.month}-${hoy.day}.html',
      htmlDePropuesta(p, fecha: hoy),
    );
    mensajes.showSnackBar(const SnackBar(content: Text(T.propuestaDescargada)));
    // El registro no frena la descarga.
    try {
      await ref
          .read(adminRepositorioProvider)
          .registrarPropuesta(p.rubro, negocioId: _lugar?.id);
    } on Exception {
      // Sin conexión: la propuesta ya se descargó.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(T.armarPropuesta, style: tema.textTheme.titleMedium),
            const Text(T.propuestaAyuda),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _rubro,
              decoration: const InputDecoration(labelText: T.rubro),
              items: [
                for (final MapEntry(:key, :value) in T.rubros.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() {
                _rubro = v;
                _propuesta = null;
              }),
            ),
            ElegirLugar(
              onElegido: (l) {
                if (l?.id == _lugar?.id) return;
                setState(() {
                  _lugar = l;
                  _propuesta = null;
                });
              },
            ),
            const SizedBox(height: 8),
            if (_error case final e?)
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _cargando ? null : _ver,
                  child: const Text(T.verDatos),
                ),
                if (_propuesta case final p?)
                  OutlinedButton.icon(
                    onPressed: () => _descargar(p),
                    icon: const Icon(Icons.download),
                    label: const Text(T.descargarPropuesta),
                  ),
              ],
            ),
            if (_propuesta case final p?) ...[
              const SizedBox(height: 8),
              Text(T.propuestaResumen(p)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Casos extends ConsumerWidget {
  const _Casos();

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    CasoExito? caso,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioCaso(caso: caso),
    );
    if (guardado ?? false) ref.invalidate(casosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(T.casosExito, style: tema.textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => _editar(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text(T.nuevoCaso),
                ),
              ],
            ),
            const Text(T.casosAyuda),
            switch (ref.watch(casosProvider)) {
              AsyncData(value: final lista) when lista.isEmpty => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(T.sinCasos),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  for (final c in lista)
                    ListTile(
                      title: Text(
                        '${c.comercio} · ${T.rubros[c.rubro] ?? c.rubro}',
                      ),
                      subtitle: Text(['«${c.cita}»', ?c.numeros].join('\n')),
                      trailing: Chip(
                        label: Text(c.publicado ? T.publicado : T.borrador),
                      ),
                      onTap: () => _editar(context, ref, c),
                    ),
                ],
              ),
              AsyncError() => TextButton(
                onPressed: () => ref.invalidate(casosProvider),
                child: const Text(T.reintentar),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ],
        ),
      ),
    );
  }
}

class _FormularioCaso extends ConsumerStatefulWidget {
  const _FormularioCaso({this.caso});

  final CasoExito? caso;

  @override
  ConsumerState<_FormularioCaso> createState() => _FormularioCasoState();
}

class _FormularioCasoState extends ConsumerState<_FormularioCaso> {
  late final _comercio = TextEditingController(text: widget.caso?.comercio);
  late final _cita = TextEditingController(text: widget.caso?.cita);
  late final _autor = TextEditingController(text: widget.caso?.autor);
  late final _numeros = TextEditingController(text: widget.caso?.numeros);
  late var _rubro = widget.caso?.rubro;
  late var _negocioId = widget.caso?.negocioId;
  late var _zonaId = widget.caso?.zonaId;
  late var _permiso = widget.caso?.permiso ?? false;
  late var _publicado = widget.caso?.publicado ?? false;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_comercio, _cita, _autor, _numeros]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "De X a Y aperturas por mes": el primer mes con movimiento contra el
  /// último (de los resultados que ve el dueño, D101).
  Future<void> _traerNumeros() async {
    final id = _negocioId;
    if (id == null) return;
    try {
      final e = await ref.read(adminRepositorioProvider).resultadosComercio(id);
      final meses = [
        for (final m in e.meses)
          if (m[MetricasComercio.aperturas] > 0) m[MetricasComercio.aperturas],
      ];
      if (meses.length >= 2 && mounted) {
        _numeros.text = T.numerosDeAperturas(meses.first, meses.last);
      }
    } on Exception {
      if (mounted) setState(() => _error = T.errorConexion);
    }
  }

  Future<void> _guardar() async {
    final rubro = _rubro;
    if (_comercio.text.trim().length < 2 ||
        rubro == null ||
        _cita.text.trim().length < 10) {
      setState(() => _error = T.casoIncompleto);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(adminRepositorioProvider)
          .guardarCaso(
            CasoExito(
              id: widget.caso?.id ?? '',
              negocioId: _negocioId,
              comercio: _comercio.text.trim(),
              rubro: rubro,
              zonaId: _zonaId,
              cita: _cita.text.trim(),
              autor: _autor.text.trim().isEmpty ? null : _autor.text.trim(),
              numeros: _numeros.text.trim().isEmpty
                  ? null
                  : _numeros.text.trim(),
              permiso: _permiso,
              publicado: _permiso && _publicado,
            ),
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

  Future<void> _borrar() async {
    final id = widget.caso?.id;
    if (id == null) return;
    await ref.read(adminRepositorioProvider).borrarCaso(id);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.caso == null ? T.nuevoCaso : T.editarCaso),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElegirLugar(
              onElegido: (l) {
                if (l == null) return;
                setState(() {
                  _negocioId = l.id;
                  _zonaId = (l.datos['zone_id'] as num?)?.toInt();
                  _comercio.text = l.comercio.nombre;
                  _rubro = l.datos['business_type'] as String? ?? _rubro;
                });
              },
            ),
            TextField(
              controller: _comercio,
              decoration: const InputDecoration(labelText: T.nombre),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(_rubro),
              initialValue: _rubro,
              decoration: const InputDecoration(labelText: T.rubro),
              items: [
                for (final MapEntry(:key, :value) in T.rubros.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _rubro = v),
            ),
            TextField(
              controller: _cita,
              minLines: 2,
              maxLines: 4,
              maxLength: 600,
              decoration: const InputDecoration(labelText: T.cita),
            ),
            TextField(
              controller: _autor,
              decoration: const InputDecoration(labelText: T.autorCita),
            ),
            TextField(
              controller: _numeros,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: T.numerosCaso,
                suffixIcon: _negocioId == null
                    ? null
                    : IconButton(
                        tooltip: T.traerNumeros,
                        onPressed: _traerNumeros,
                        icon: const Icon(Icons.insights_outlined),
                      ),
              ),
            ),
            CheckboxListTile(
              title: const Text(T.permisoCaso),
              value: _permiso,
              onChanged: (v) => setState(() {
                _permiso = v ?? false;
                if (!_permiso) _publicado = false;
              }),
            ),
            SwitchListTile(
              title: const Text(T.publicadoCaso),
              value: _publicado,
              onChanged: _permiso
                  ? (v) => setState(() => _publicado = v)
                  : null,
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
      if (widget.caso != null)
        TextButton(onPressed: _borrar, child: const Text(T.borrar)),
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
