import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Lugares (1.8.4 y 1.8.5): cargar, editar, verificar, marcar Operador RENAC
/// y ocultar. Muestra las aperturas de ficha y los favoritos de cada uno.
class LugaresScreen extends ConsumerStatefulWidget {
  const LugaresScreen({super.key});

  @override
  ConsumerState<LugaresScreen> createState() => _LugaresScreenState();
}

class _LugaresScreenState extends ConsumerState<LugaresScreen> {
  var _buscar = '';

  Future<void> _editar([LugarAdmin? lugar]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => FormularioLugar(lugar: lugar),
    );
    if (guardado ?? false) ref.invalidate(lugaresProvider);
  }

  @override
  Widget build(BuildContext context) {
    final lugares = ref.watch(lugaresProvider(_buscar));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editar,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text(T.nuevoLugar),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: T.buscar,
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) => setState(() => _buscar = v),
            ),
          ),
          Expanded(
            child: switch (lugares) {
              AsyncData(value: final lista) => ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  for (final l in lista)
                    ListTile(
                      title: Text(l.comercio.nombre),
                      subtitle: Text(
                        [
                          T.rubros[l.comercio.tipo] ?? l.comercio.tipo,
                          T.modalidades[l.datos['kind']] ?? '',
                          T.estadosVerificacion[l.verificacion] ?? '',
                          if (l.comercio.operadorRenac) 'RENAC',
                          if (l.estado == 'hidden') 'oculto',
                          if (l.comercio.esEjemplo) T.ejemplo,
                          '${l.aperturas30d} ${T.aperturas}',
                          '${l.favoritos} ${T.favoritos}',
                        ].where((x) => x.isNotEmpty).join(' · '),
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editar(l),
                    ),
                ],
              ),
              AsyncError() => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(lugaresProvider),
                  child: const Text(T.reintentar),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class FormularioLugar extends ConsumerStatefulWidget {
  const FormularioLugar({this.lugar, super.key});

  final LugarAdmin? lugar;

  @override
  ConsumerState<FormularioLugar> createState() => _FormularioLugarState();
}

class _FormularioLugarState extends ConsumerState<FormularioLugar> {
  late final Map<String, Object?> _d = {...?widget.lugar?.datos};
  late final _campos = {
    for (final c in [
      'name',
      'address',
      'phone',
      'whatsapp',
      'web',
      'instagram',
      'description',
    ])
      c: TextEditingController(text: _d[c] as String?),
    'lat': TextEditingController(text: _d['lat']?.toString()),
    'lng': TextEditingController(text: _d['lng']?.toString()),
    'hours': TextEditingController(
      text: _d['hours'] == null ? '{}' : jsonEncode(_d['hours']),
    ),
  };
  late var _rubro = (_d['business_type'] as String?) ?? 'vet';
  late var _modalidad = (_d['kind'] as String?) ?? 'local';
  late var _es24h = _d['is_24h'] == true;
  late var _urgencias = _d['emergencies'] == true;
  late var _verificado = _d['verification'] == 'verified';
  late var _renac = _d['renac_operator'] == true;
  late var _visible = _d['status'] != 'hidden';
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final horas = () {
      try {
        final h = jsonDecode(_campos['hours']!.text);
        return h is Map ? h : null;
      } on FormatException {
        return null;
      }
    }();
    final lat = double.tryParse(_campos['lat']!.text.replaceAll(',', '.'));
    final lng = double.tryParse(_campos['lng']!.text.replaceAll(',', '.'));
    if (horas == null ||
        _campos['name']!.text.trim().length < 2 ||
        (_modalidad == 'local' && (lat == null || lng == null))) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    final datos = <String, Object?>{
      if (widget.lugar != null) 'id': widget.lugar!.id,
      for (final c in [
        'name',
        'address',
        'phone',
        'whatsapp',
        'web',
        'instagram',
        'description',
      ])
        c: _campos[c]!.text.trim(),
      'lat': lat,
      'lng': lng,
      'business_type': _rubro,
      'kind': _modalidad,
      'hours': horas,
      'is_24h': _es24h,
      'emergencies': _urgencias,
      'verification': _verificado ? 'verified' : 'unverified',
      'renac_operator': _renac,
      'status': _visible ? 'active' : 'hidden',
    };
    try {
      await ref.read(adminRepositorioProvider).guardarLugar(datos);
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = T.datosInvalidos;
        });
      }
    }
  }

  Widget _campo(
    String clave,
    String etiqueta, {
    String? ayuda,
    int lineas = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: _campos[clave],
      minLines: lineas,
      maxLines: lineas,
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.lugar == null ? T.nuevoLugar : T.editarLugar),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campo('name', T.nombre),
            DropdownButtonFormField<String>(
              initialValue: _rubro,
              decoration: const InputDecoration(labelText: T.rubro),
              items: [
                for (final MapEntry(:key, :value) in T.rubros.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _rubro = v ?? _rubro),
            ),
            DropdownButtonFormField<String>(
              initialValue: _modalidad,
              decoration: const InputDecoration(labelText: T.modalidad),
              items: [
                for (final MapEntry(:key, :value) in T.modalidades.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _modalidad = v ?? _modalidad),
            ),
            const SizedBox(height: 8),
            _campo('address', T.direccion),
            Row(
              children: [
                Expanded(child: _campo('lat', T.lat)),
                const SizedBox(width: 8),
                Expanded(child: _campo('lng', T.lng)),
              ],
            ),
            const Text(T.latLngAyuda),
            const SizedBox(height: 8),
            _campo('phone', T.telefono),
            _campo('whatsapp', T.whatsapp),
            _campo('web', T.web),
            _campo('instagram', T.instagram),
            _campo('description', T.descripcion, lineas: 3),
            _campo('hours', T.horario, ayuda: T.horarioAyuda, lineas: 3),
            SwitchListTile(
              title: const Text(T.es24h),
              value: _es24h,
              onChanged: (v) => setState(() => _es24h = v),
            ),
            SwitchListTile(
              title: const Text(T.urgencias),
              value: _urgencias,
              onChanged: (v) => setState(() => _urgencias = v),
            ),
            SwitchListTile(
              title: const Text(T.verificado),
              value: _verificado,
              onChanged: (v) => setState(() => _verificado = v),
            ),
            SwitchListTile(
              title: const Text(T.renac),
              value: _renac,
              onChanged: (v) => setState(() => _renac = v),
            ),
            SwitchListTile(
              title: const Text(T.visible),
              value: _visible,
              onChanged: (v) => setState(() => _visible = v),
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
      if (widget.lugar case final l?)
        TextButton(
          onPressed: () async {
            final hoy = DateTime.now();
            final hasta = await showDatePicker(
              context: context,
              initialDate: DateTime(hoy.year, hoy.month + 6, hoy.day),
              firstDate: hoy,
              lastDate: DateTime(hoy.year + 2),
              helpText: T.socioFundador,
            );
            if (hasta == null) return;
            await ref.read(adminRepositorioProvider).socioFundador(l.id, hasta);
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text(T.socioFundador),
        ),
      if (widget.lugar case final l?)
        PopupMenuButton<String>(
          tooltip: T.plan,
          onSelected: (plan) async {
            await ref.read(adminRepositorioProvider).planComercio(l.id, plan);
            if (context.mounted) Navigator.pop(context, true);
          },
          itemBuilder: (_) => [
            for (final MapEntry(:key, :value) in T.planes.entries)
              PopupMenuItem(value: key, child: Text(value)),
          ],
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(T.plan),
          ),
        ),
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
