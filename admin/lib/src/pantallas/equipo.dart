import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';

int _n(Object? v) => (v as num?)?.toInt() ?? 0;

String _fecha(Object? v) => switch (v) {
  final String f => f.replaceFirst('T', ' ').split('.').first,
  _ => '',
};

/// El texto del error de la base que corresponde, o el genérico.
String _errorDe(Object e, Map<String, String> textos) =>
    textos.entries.where((t) => '$e'.contains(t.key)).firstOrNull?.value ??
    T.errorConexion;

/// Equipo (3.6, D109): quién tiene qué rol en el portal.
class EquipoScreen extends ConsumerWidget {
  const EquipoScreen({super.key});

  Future<void> _poner(
    BuildContext context,
    WidgetRef ref, {
    String? correo,
    String? rol,
  }) async {
    final hecho = await showDialog<bool>(
      context: context,
      builder: (_) => _PonerRol(correo: correo, rol: rol),
    );
    if (hecho ?? false) ref.invalidate(equipoProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _poner(context, ref),
      icon: const Icon(Icons.person_add_alt),
      label: const Text(T.sumarAlEquipo),
    ),
    body: switch (ref.watch(equipoProvider)) {
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        children: [
          Text(T.equipoAyuda, style: Theme.of(context).textTheme.bodySmall),
          for (final p in lista)
            Card(
              child: ListTile(
                title: Text(
                  [
                    '${p['email']}',
                    if (p['yo'] == true) '(${T.vos})',
                  ].join(' '),
                ),
                subtitle: Text(
                  [
                    T.rolesEquipo[p['rol']] ?? '${p['rol']}',
                    switch (p['ultima_accion']) {
                      final String f => T.ultimaAccion(_fecha(f)),
                      _ => T.sinAcciones,
                    },
                  ].join(' · '),
                ),
                trailing: p['yo'] == true
                    ? null
                    : IconButton(
                        tooltip: T.sumarAlEquipo,
                        onPressed: () => _poner(
                          context,
                          ref,
                          correo: '${p['email']}',
                          rol: '${p['rol']}',
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
              ),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(equipoProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _PonerRol extends ConsumerStatefulWidget {
  const _PonerRol({this.correo, this.rol});

  final String? correo;
  final String? rol;

  @override
  ConsumerState<_PonerRol> createState() => _PonerRolState();
}

class _PonerRolState extends ConsumerState<_PonerRol> {
  late final _correo = TextEditingController(text: widget.correo);
  late var _rol = widget.rol ?? 'moderator';
  String? _error;
  var _guardando = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar(String rol) async {
    if (!_correo.text.contains('@')) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(adminRepositorioProvider)
          .ponerRol(_correo.text.trim(), rol);
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = _errorDe(e, T.errorRol));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(T.sumarAlEquipo),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _correo,
            enabled: widget.correo == null,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: T.correoCuenta),
          ),
          DropdownButtonFormField<String>(
            initialValue: _rol,
            isExpanded: true,
            decoration: const InputDecoration(labelText: T.rol),
            items: [
              for (final MapEntry(:key, :value) in T.rolesEquipo.entries)
                DropdownMenuItem(value: key, child: Text(value)),
            ],
            onChanged: (v) => setState(() => _rol = v ?? _rol),
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
      if (widget.correo != null)
        TextButton(
          onPressed: _guardando ? null : () => _guardar('user'),
          child: const Text(T.sacarDelEquipo),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(T.cancelar),
      ),
      FilledButton(
        onPressed: _guardando ? null : () => _guardar(_rol),
        child: const Text(T.guardar),
      ),
    ],
  );
}

/// Zonas (3.6, D109): sus números, alta con un rectángulo y prender o apagar.
class ZonasScreen extends ConsumerWidget {
  const ZonasScreen({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Map<String, Object?>? zona,
  ]) async {
    final hecho = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioZona(zona: zona),
    );
    if (hecho ?? false) ref.invalidate(zonasProvider);
  }

  Future<void> _prender(
    WidgetRef ref,
    Map<String, Object?> zona,
    bool activa,
  ) async {
    await ref.read(adminRepositorioProvider).guardarZona({
      'id': zona['id'],
      'active': activa,
    });
    ref.invalidate(zonasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context, ref),
      icon: const Icon(Icons.add_location_alt_outlined),
      label: const Text(T.nuevaZona),
    ),
    body: switch (ref.watch(zonasProvider)) {
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        children: [
          Text(T.zonasAyuda, style: Theme.of(context).textTheme.bodySmall),
          for (final z in lista)
            Card(
              child: SwitchListTile(
                title: Text(
                  z['active'] == true
                      ? '${z['name']}'
                      : '${z['name']} (${T.apagada})',
                ),
                subtitle: Text(
                  T.resumenZona(
                    _n(z['usuarios']),
                    _n(z['mascotas']),
                    _n(z['lugares']),
                    _n(z['sos_activos']),
                  ),
                ),
                value: z['active'] == true,
                onChanged: (v) => _prender(ref, z, v),
                secondary: IconButton(
                  tooltip: T.editarZona,
                  onPressed: () => _editar(context, ref, z),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(zonasProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _FormularioZona extends ConsumerStatefulWidget {
  const _FormularioZona({this.zona});

  final Map<String, Object?>? zona;

  @override
  ConsumerState<_FormularioZona> createState() => _FormularioZonaState();
}

class _FormularioZonaState extends ConsumerState<_FormularioZona> {
  late final _slug = TextEditingController(
    text: widget.zona?['slug'] as String?,
  );
  late final _nombre = TextEditingController(
    text: widget.zona?['name'] as String?,
  );
  late final _esquinas = {
    for (final clave in ['lat_min', 'lat_max', 'lng_min', 'lng_max'])
      clave: TextEditingController(
        text: switch (widget.zona?[clave]) {
          final num v => '$v',
          _ => '',
        },
      ),
  };
  String? _error;
  var _guardando = false;

  @override
  void dispose() {
    _slug.dispose();
    _nombre.dispose();
    for (final c in _esquinas.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final esquinas = {
      for (final MapEntry(:key, :value) in _esquinas.entries)
        key: double.tryParse(value.text.trim().replaceAll(',', '.')),
    };
    if (_nombre.text.trim().isEmpty ||
        (widget.zona == null &&
            !RegExp(r'^[a-z0-9-]{2,40}$').hasMatch(_slug.text.trim())) ||
        esquinas.values.any((v) => v == null)) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(adminRepositorioProvider).guardarZona({
        'id': ?widget.zona?['id'],
        if (widget.zona == null) 'slug': _slug.text.trim(),
        'name': _nombre.text.trim(),
        ...esquinas,
      });
      if (mounted) Navigator.pop(context, true);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = _errorDe(e, const {'area_invalida': T.areaInvalida});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.zona == null ? T.nuevaZona : T.editarZona),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.zona == null)
              TextField(
                controller: _slug,
                decoration: const InputDecoration(labelText: T.slugZona),
              ),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: T.nombreZona),
            ),
            for (final (clave, texto) in const [
              ('lat_min', T.latMin),
              ('lat_max', T.latMax),
              ('lng_min', T.lngMin),
              ('lng_max', T.lngMax),
            ])
              TextField(
                controller: _esquinas[clave],
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: texto),
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

/// Auditoría (3.6, D109): quién hizo qué y cuándo.
class AuditoriaScreen extends ConsumerStatefulWidget {
  const AuditoriaScreen({super.key});

  @override
  ConsumerState<AuditoriaScreen> createState() => _AuditoriaState();
}

class _AuditoriaState extends ConsumerState<AuditoriaScreen> {
  var _dias = 7;
  String? _accion;
  late Future<List<Map<String, Object?>>> _registro = _cargar();

  Future<List<Map<String, Object?>>> _cargar() => ref
      .read(adminRepositorioProvider)
      .auditoria(dias: _dias, accion: _accion);

  void _filtrar({int? dias, String? accion, bool todas = false}) =>
      setState(() {
        _dias = dias ?? _dias;
        _accion = todas ? null : accion ?? _accion;
        _registro = _cargar();
      });

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _registro,
    builder: (context, foto) {
      final filas = foto.data ?? const <Map<String, Object?>>[];
      final acciones = {for (final f in filas) '${f['action']}'};
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(T.auditoriaAyuda, style: Theme.of(context).textTheme.bodySmall),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1 día')),
                  ButtonSegment(value: 7, label: Text('7 días')),
                  ButtonSegment(value: 30, label: Text('30 días')),
                ],
                selected: {_dias},
                onSelectionChanged: (s) => _filtrar(dias: s.first),
              ),
              DropdownButton<String?>(
                value: _accion,
                hint: const Text(T.todasLasAcciones),
                items: [
                  const DropdownMenuItem(child: Text(T.todasLasAcciones)),
                  for (final a in {...acciones, ?_accion}.toList()..sort())
                    DropdownMenuItem(value: a, child: Text(a)),
                ],
                onChanged: (a) =>
                    a == null ? _filtrar(todas: true) : _filtrar(accion: a),
              ),
            ],
          ),
          if (foto.hasError) const Text(T.errorConexion),
          if (foto.connectionState == ConnectionState.waiting)
            const LinearProgressIndicator(),
          if (foto.hasData && filas.isEmpty) const Text(T.sinRegistro),
          for (final f in filas)
            ListTile(
              dense: true,
              title: Text('${f['action']} · ${f['quien']}'),
              subtitle: Text(
                [
                  _fecha(f['created_at']),
                  if (f['target_type'] case final String t)
                    '$t ${f['target_id'] ?? ''}',
                  if (f['detail'] case final Map<String, Object?> d
                      when d.isNotEmpty)
                    jsonEncode(d),
                ].join(' · '),
              ),
            ),
        ],
      );
    },
  );
}
