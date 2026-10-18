import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/textos_comercio.dart';
import '../../mapa/mapa_vista.dart';
import '../../mascotas/catalogo.dart';
import '../../sos/sos_repositorio.dart';
import '../mapa/ficha_comercio.dart';

/// Datos con los que arranca un alta (por ejemplo, desde un lugar marcado).
typedef PrecargaNegocio = ({Categoria? rubro, Punto? punto});

String _hhmm(TimeOfDay h) =>
    '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

TimeOfDay _hora(int minutos) =>
    TimeOfDay(hour: (minutos ~/ 60) % 24, minute: minutos % 60);

/// Formulario de un negocio (alta y edición, 1.3.3 y 1.3.5). Devuelve los
/// datos con los nombres de columna que esperan `alta_negocio()` y
/// `editar_mi_negocio()`. El horario es de una franja por día (un horario
/// partido se carga desde el portal de administración).
class FormularioNegocio extends ConsumerStatefulWidget {
  const FormularioNegocio({
    required this.textoBoton,
    required this.onGuardar,
    this.original,
    this.precarga,
    super.key,
  });

  final String textoBoton;
  final Future<void> Function(Map<String, Object?> datos) onGuardar;
  final MiNegocio? original;
  final PrecargaNegocio? precarga;

  @override
  ConsumerState<FormularioNegocio> createState() => _FormularioNegocioState();
}

class _FormularioNegocioState extends ConsumerState<FormularioNegocio> {
  late final Comercio? _c = widget.original?.comercio;
  late final _nombre = TextEditingController(text: _c?.nombre);
  late final _telefono = TextEditingController(text: _c?.telefono);
  late final _whatsapp = TextEditingController(text: _c?.whatsapp);
  late final _web = TextEditingController(text: _c?.web);
  late final _instagram = TextEditingController(text: _c?.instagram);
  late final _facebook = TextEditingController(text: _c?.facebook);
  late final _descripcion = TextEditingController(text: _c?.descripcion);
  late final _cobertura = TextEditingController(text: _c?.cobertura);
  late final _promo = TextEditingController(text: _c?.promo);
  late final _direccion = TextEditingController(text: _c?.direccion);

  late var _rubro = _c?.categoria ?? widget.precarga?.rubro ?? Categoria.vet;
  late var _modalidad = _c?.modalidad ?? Modalidad.local;
  late Punto? _punto = _c?.punto ?? widget.precarga?.punto;
  late var _es24h = _c?.es24h ?? false;
  late var _urgencias = _c?.urgencias ?? false;
  late var _visible = widget.original?.visible ?? true;
  late final Set<int> _especies = {...?_c?.especieIds};

  /// Una franja por día (0 = lunes); `null` = cerrado.
  late final Map<int, (TimeOfDay, TimeOfDay)?> _horario = {
    for (var d = 0; d < 7; d++)
      d: switch (_c?.horario.delDia(d) ?? const <Franja>[]) {
        [] =>
          _c == null && d < 5
              ? (
                  const TimeOfDay(hour: 9, minute: 0),
                  const TimeOfDay(hour: 19, minute: 0),
                )
              : null,
        final franjas => (
          _hora(franjas.first.desde),
          _hora(franjas.last.hasta),
        ),
      },
  };
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _telefono,
      _whatsapp,
      _web,
      _instagram,
      _facebook,
      _descripcion,
      _cobertura,
      _promo,
      _direccion,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _o(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _elegirHora(int dia, {required bool desde}) async {
    final actual =
        _horario[dia] ??
        (
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 19, minute: 0),
        );
    final h = await showTimePicker(
      context: context,
      initialTime: desde ? actual.$1 : actual.$2,
    );
    if (h == null) return;
    setState(() => _horario[dia] = desde ? (h, actual.$2) : (actual.$1, h));
  }

  Future<void> _guardar() async {
    final t = context.t;
    if (_nombre.text.trim().length < 2) {
      setState(() => _error = t.negocioNombreFalta);
      return;
    }
    if (_modalidad == Modalidad.local && _punto == null) {
      setState(() => _error = t.negocioFaltaUbicacion);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    final punto = _modalidad == Modalidad.local ? _punto : null;
    final datos = <String, Object?>{
      'business_type': _rubro.valor,
      'kind': _modalidad.name,
      'name': _nombre.text.trim(),
      'address': _modalidad == Modalidad.local ? _o(_direccion) : null,
      'lat': punto?.lat,
      'lng': punto?.lng,
      'coverage': _modalidad == Modalidad.local ? null : _o(_cobertura),
      'phone': _o(_telefono),
      'whatsapp': _o(_whatsapp),
      'web': _o(_web),
      'instagram': _o(_instagram)?.replaceAll('@', ''),
      'facebook': _o(_facebook),
      'description': _o(_descripcion),
      'is_24h': _es24h,
      'emergencies': _rubro == Categoria.vet && _urgencias,
      'species_ids': _especies.toList()..sort(),
      'hours': _es24h
          ? <String, Object?>{}
          : {
              for (final MapEntry(key: d, value: f) in _horario.entries)
                if (f != null)
                  diasHorario[d]: [
                    [_hhmm(f.$1), _hhmm(f.$2)],
                  ],
            },
      if (widget.original != null) ...{
        'status': _visible ? 'active' : 'hidden',
        if (widget.original!.comercio.plan != PlanComercio.basic)
          'promo': _o(_promo),
      },
    };
    try {
      await widget.onGuardar(datos);
    } on Exception {
      if (mounted) setState(() => _error = t.negocioDatosInvalidos);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _texto(
    TextEditingController c,
    String etiqueta, {
    String? ayuda,
    int lineas = 1,
    TextInputType? teclado,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      minLines: lineas,
      maxLines: lineas,
      keyboardType: teclado,
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    ),
  );

  String _dia(AppLocalizations t, int d) => switch (d) {
    0 => t.diaLunes,
    1 => t.diaMartes,
    2 => t.diaMiercoles,
    3 => t.diaJueves,
    4 => t.diaViernes,
    5 => t.diaSabado,
    _ => t.diaDomingo,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _texto(_nombre, t.negocioNombre),
        Text(t.marcarRubro, style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in Categoria.values)
              ChoiceChip(
                avatar: Icon(iconoCategoria(c), size: 18),
                label: Text(textoCategoria(t, c)),
                selected: c == _rubro,
                onSelected: (_) => setState(() => _rubro = c),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(t.negocioModalidad, style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<Modalidad>(
          segments: [
            ButtonSegment(
              value: Modalidad.local,
              label: Text(t.negocioModalidadLocal),
            ),
            ButtonSegment(
              value: Modalidad.online,
              label: Text(t.negocioModalidadOnline),
            ),
            ButtonSegment(
              value: Modalidad.domicilio,
              label: Text(t.negocioModalidadDomicilio),
            ),
          ],
          selected: {_modalidad},
          onSelectionChanged: (s) => setState(() => _modalidad = s.first),
        ),
        const SizedBox(height: 12),
        if (_modalidad == Modalidad.local) ...[
          Text(t.negocioUbicacionToca),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapaVista(
                centro: _punto ?? ref.watch(miZonaProvider),
                zoom: 15,
                seleccion: _punto,
                onTocarMapa: (p) => setState(() => _punto = p),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _texto(_direccion, t.negocioDireccion),
        ] else
          _texto(
            _cobertura,
            t.negocioCobertura,
            ayuda: t.negocioCoberturaAyuda,
          ),
        _texto(_telefono, t.negocioTelefono, teclado: TextInputType.phone),
        _texto(_whatsapp, t.negocioWhatsapp, teclado: TextInputType.phone),
        _texto(_web, t.negocioWeb, teclado: TextInputType.url),
        _texto(_instagram, t.negocioInstagram),
        _texto(_facebook, t.negocioFacebook),
        _texto(_descripcion, t.negocioDescripcion, lineas: 3),
        if (widget.original != null &&
            widget.original!.comercio.plan != PlanComercio.basic)
          _texto(_promo, t.negocioPromo)
        else if (widget.original != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              t.negocioPromoSoloPago,
              style: tema.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 8),
        Text(t.negocioEspecies, style: tema.textTheme.titleSmall),
        Text(t.negocioEspeciesAyuda, style: tema.textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in especies)
              FilterChip(
                label: Text('${e.icono} ${e.nombre}'),
                selected: _especies.contains(e.id),
                onSelected: (si) => setState(
                  () => si ? _especies.add(e.id) : _especies.remove(e.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(t.negocioHorario, style: tema.textTheme.titleSmall),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.negocio24h),
          value: _es24h,
          onChanged: (v) => setState(() => _es24h = v),
        ),
        if (!_es24h)
          for (var d = 0; d < 7; d++)
            Row(
              children: [
                SizedBox(width: 92, child: Text(_dia(t, d))),
                Switch(
                  value: _horario[d] != null,
                  onChanged: (abierto) => setState(
                    () => _horario[d] = abierto
                        ? (
                            const TimeOfDay(hour: 9, minute: 0),
                            const TimeOfDay(hour: 19, minute: 0),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: switch (_horario[d]) {
                    null => Text(t.negocioCerrado),
                    final f => Wrap(
                      children: [
                        TextButton(
                          onPressed: () => _elegirHora(d, desde: true),
                          child: Text(_hhmm(f.$1)),
                        ),
                        TextButton(
                          onPressed: () => _elegirHora(d, desde: false),
                          child: Text(_hhmm(f.$2)),
                        ),
                      ],
                    ),
                  },
                ),
              ],
            ),
        if (_rubro == Categoria.vet)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.negocioUrgencias),
            value: _urgencias,
            onChanged: (v) => setState(() => _urgencias = v),
          ),
        if (widget.original != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.negocioVisible),
            value: _visible,
            onChanged: (v) => setState(() => _visible = v),
          ),
        if (_error case final e?) ...[
          const SizedBox(height: 8),
          Text(e, style: TextStyle(color: tema.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(widget.textoBoton),
        ),
      ],
    );
  }
}
