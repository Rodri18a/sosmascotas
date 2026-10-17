import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../metricas/metricas.dart';
import '../../recordatorios/avisador.dart';
import '../../recordatorios/recordatorios_repositorio.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';

/// "hoy a las 20:00", "mañana a las 8:00", "sáb., 24 oct. a las 9:30".
String textoCuando(BuildContext context, DateTime cuando, DateTime ahora) {
  final t = context.t;
  final l = MaterialLocalizations.of(context);
  final hora = l.formatTimeOfDay(
    TimeOfDay.fromDateTime(cuando),
    alwaysUse24HourFormat: true,
  );
  final dias = diasHasta(cuando, ahora);
  if (dias == 0) return t.recordatorioHoyA(hora);
  if (dias == 1) return t.recordatorioMananaA(hora);
  return t.recordatorioFechaA(l.formatMediumDate(cuando), hora);
}

/// Recordatorios dentro de la ficha de la mascota (paso 1.5.3).
class TarjetaRecordatorios extends ConsumerWidget {
  const TarjetaRecordatorios({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final ahora = ref.watch(relojProvider)();
    final recordatorios = ref.watch(recordatoriosDeMascotaProvider(mascotaId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.alarm_outlined),
              title: Text(
                t.recordatoriosTitulo,
                style: tema.textTheme.titleMedium,
              ),
            ),
            switch (recordatorios) {
              AsyncData(value: final lista) when lista.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.recordatoriosVacio),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  const _PermisoAvisos(),
                  for (final r in lista)
                    ListTile(
                      leading: Icon(
                        r.activo
                            ? Icons.medication_outlined
                            : Icons.pause_circle_outline,
                      ),
                      title: Text(r.titulo),
                      subtitle: Text(_estado(context, r, ahora)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        Rutas.editarRecordatorio(mascotaId, r.id),
                      ),
                    ),
                ],
              ),
              AsyncLoading() => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              _ => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.errorSinConexion),
              ),
            },
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push(Rutas.nuevoRecordatorio(mascotaId)),
                icon: const Icon(Icons.add_alarm_outlined),
                label: Text(t.recordatoriosAgregar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _estado(BuildContext context, Recordatorio r, DateTime ahora) {
    final t = context.t;
    final partes = [
      ?r.dosis,
      if (!r.activo)
        t.recordatorioPausado
      else if (r.proximaToma(ahora) case final p?)
        t.recordatorioProxima(textoCuando(context, p, ahora))
      else
        t.recordatorioTerminado,
    ];
    return partes.join(' · ');
  }
}

/// Pide el permiso de avisos del navegador, si falta, y explica cuándo suenan.
class _PermisoAvisos extends ConsumerStatefulWidget {
  const _PermisoAvisos();

  @override
  ConsumerState<_PermisoAvisos> createState() => _PermisoAvisosState();
}

class _PermisoAvisosState extends ConsumerState<_PermisoAvisos> {
  PermisoAvisos? _permiso;

  @override
  void initState() {
    super.initState();
    ref.read(avisadorRecordatoriosProvider).permiso().then((p) {
      if (mounted) setState(() => _permiso = p);
    });
  }

  Future<void> _pedir() async {
    final p = await ref.read(avisadorRecordatoriosProvider).pedirPermiso();
    if (mounted) setState(() => _permiso = p);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return switch (_permiso) {
      null || PermisoAvisos.noDisponible => const SizedBox.shrink(),
      PermisoAvisos.concedido => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(t.recordatoriosAvisosWeb, style: tema.textTheme.bodySmall),
      ),
      PermisoAvisos.sinPedir => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.recordatoriosAvisosWeb, style: tema.textTheme.bodySmall),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _pedir,
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(t.recordatoriosActivarAvisos),
            ),
          ],
        ),
      ),
      PermisoAvisos.bloqueado => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          t.recordatoriosAvisosBloqueados,
          style: TextStyle(color: tema.colorScheme.error),
        ),
      ),
    };
  }
}

/// Alta (sin [recordatorioId]) o edición de un recordatorio.
class RecordatorioScreen extends ConsumerWidget {
  const RecordatorioScreen({
    required this.mascotaId,
    this.recordatorioId,
    super.key,
  });

  final String mascotaId;
  final String? recordatorioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = recordatorioId;
    if (id == null) return _Formulario(mascotaId: mascotaId);
    return switch (ref.watch(recordatorioProvider(id))) {
      AsyncData(value: final r?) => _Formulario(
        mascotaId: mascotaId,
        original: r,
      ),
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.errorDesconocido)),
      ),
    };
  }
}

enum _Modo { cadaHoras, diaria, semanal }

const _opcionesHoras = [4, 6, 8, 12, 24, 48, 72];

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.mascotaId, this.original});

  final String mascotaId;
  final Recordatorio? original;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.original?.titulo);
  late final _dosis = TextEditingController(text: widget.original?.dosis);

  late _Modo _modo;
  late int _horas;
  late List<HoraDelDia> _horarios;
  late Set<int> _dias;
  late DateTime _inicio;
  late DateTime? _fin = widget.original?.fin;
  late bool _activo = widget.original?.activo ?? true;
  bool _guardando = false;
  String? _error;

  bool get _esNuevo => widget.original == null;

  @override
  void initState() {
    super.initState();
    final ahora = ref.read(relojProvider)();
    // Por defecto: la próxima hora en punto.
    _inicio =
        widget.original?.inicio ??
        DateTime(ahora.year, ahora.month, ahora.day, ahora.hour + 1);
    _modo = _Modo.cadaHoras;
    _horas = 8;
    _horarios = const [HoraDelDia(8, 0), HoraDelDia(20, 0)];
    _dias = {ahora.weekday};
    switch (widget.original?.frecuencia) {
      case CadaHoras(:final horas):
        _horas = horas;
      case Diaria(:final horarios):
        _modo = _Modo.diaria;
        _horarios = horarios;
      case Semanal(:final dias, :final horarios):
        _modo = _Modo.semanal;
        _dias = dias;
        _horarios = horarios;
      case UnaVez() || null:
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _dosis.dispose();
    super.dispose();
  }

  Frecuencia get _frecuencia => switch (_modo) {
    _Modo.cadaHoras => CadaHoras(_horas),
    _Modo.diaria => Diaria(_horarios),
    _Modo.semanal => Semanal(_dias, _horarios),
  };

  Future<void> _elegirInicio() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _inicio,
      firstDate: DateTime(_inicio.year - 1),
      lastDate: DateTime(_inicio.year + 2),
    );
    if (dia == null || !mounted) return;
    final hora = _modo == _Modo.cadaHoras
        ? await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_inicio),
          )
        : TimeOfDay.fromDateTime(_inicio);
    if (hora == null) return;
    setState(
      () => _inicio = DateTime(
        dia.year,
        dia.month,
        dia.day,
        hora.hour,
        hora.minute,
      ),
    );
  }

  Future<void> _elegirFin() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _fin ?? _inicio.add(const Duration(days: 7)),
      firstDate: DateTime(_inicio.year, _inicio.month, _inicio.day),
      lastDate: DateTime(_inicio.year + 2),
    );
    if (dia != null) setState(() => _fin = dia);
  }

  Future<void> _agregarHorario() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (hora == null) return;
    setState(() {
      _horarios = ({..._horarios, HoraDelDia(hora.hour, hora.minute)}.toList())
        ..sort();
    });
  }

  String? _mensaje(ValidacionRecordatorio v) {
    final t = context.t;
    return switch (v) {
      ValidacionRecordatorio.valido => null,
      ValidacionRecordatorio.sinTitulo => t.recordatorioTituloFalta,
      ValidacionRecordatorio.tituloLargo => t.recordatorioTituloLargo,
      ValidacionRecordatorio.sinHorarios => t.recordatorioSinHorarios,
      ValidacionRecordatorio.sinDias => t.recordatorioSinDias,
      ValidacionRecordatorio.finAntesDelInicio => t.recordatorioFinAntes,
    };
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    final error = _mensaje(
      validarRecordatorio(
        titulo: _titulo.text,
        frecuencia: _frecuencia,
        inicio: _inicio,
        fin: _fin,
      ),
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    final recordatorio = Recordatorio(
      id: widget.original?.id ?? '',
      mascotaId: widget.mascotaId,
      tipo: widget.original?.tipo ?? TipoRecordatorio.medication,
      titulo: _titulo.text,
      dosis: _dosis.text,
      frecuencia: _frecuencia,
      inicio: _inicio,
      fin: _fin,
      activo: _activo,
    );
    final repo = ref.read(recordatoriosRepositorioProvider);
    try {
      if (_esNuevo) {
        await repo.crear(recordatorio);
        ref
            .read(metricasProvider)
            .track(
              Eventos.reminderCreate,
              props: {'tipo': recordatorio.tipo.name},
            );
      } else {
        await repo.actualizar(recordatorio);
      }
      ref.invalidate(misRecordatoriosProvider);
      if (mounted) context.pop();
    } on Exception {
      if (mounted) setState(() => _error = t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _borrar() async {
    final t = context.t;
    final original = widget.original!;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.recordatorioBorrarTitulo(original.titulo)),
        content: Text(t.recordatorioBorrarExplicacion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.borrar),
          ),
        ],
      ),
    );
    if (!(confirmado ?? false) || !mounted) return;
    setState(() => _guardando = true);
    try {
      await ref.read(recordatoriosRepositorioProvider).borrar(original.id);
      ref.invalidate(misRecordatoriosProvider);
      if (mounted) context.pop();
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = t.errorSinConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    String hora(HoraDelDia h) => l.formatTimeOfDay(
      TimeOfDay(hour: h.hora, minute: h.minuto),
      alwaysUse24HourFormat: true,
    );
    final ahora = ref.watch(relojProvider)();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esNuevo ? t.recordatorioNuevoTitulo : t.recordatorioEditarTitulo,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titulo,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.recordatorioTitulo,
                    helperText: t.recordatorioTituloAyuda,
                  ),
                  validator: (v) => switch (validarRecordatorio(
                    titulo: v ?? '',
                    frecuencia: const UnaVez(),
                    inicio: _inicio,
                  )) {
                    ValidacionRecordatorio.sinTitulo =>
                      t.recordatorioTituloFalta,
                    ValidacionRecordatorio.tituloLargo =>
                      t.recordatorioTituloLargo,
                    _ => null,
                  },
                ),
                TextFormField(
                  controller: _dosis,
                  maxLength: 80,
                  decoration: InputDecoration(
                    labelText: t.recordatorioDosis,
                    helperText: t.recordatorioDosisAyuda,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.recordatorioFrecuencia,
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<_Modo>(
                  segments: [
                    ButtonSegment(
                      value: _Modo.cadaHoras,
                      label: Text(t.recordatorioCadaHoras),
                    ),
                    ButtonSegment(
                      value: _Modo.diaria,
                      label: Text(t.recordatorioDiaria),
                    ),
                    ButtonSegment(
                      value: _Modo.semanal,
                      label: Text(t.recordatorioSemanal),
                    ),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) => setState(() => _modo = s.first),
                ),
                const SizedBox(height: 16),
                if (_modo == _Modo.cadaHoras)
                  DropdownButtonFormField<int>(
                    initialValue: _horas,
                    decoration: InputDecoration(
                      labelText: t.recordatorioFrecuencia,
                    ),
                    items: [
                      for (final h in {
                        ..._opcionesHoras,
                        _horas,
                      }.toList()..sort())
                        DropdownMenuItem(
                          value: h,
                          child: Text(t.recordatorioCadaNHoras(h)),
                        ),
                    ],
                    onChanged: (h) => setState(() => _horas = h ?? _horas),
                  ),
                if (_modo == _Modo.semanal) ...[
                  Text(t.recordatorioDias, style: tema.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: [
                      // 1 = lunes … 7 = domingo; narrowWeekdays empieza en domingo.
                      for (final dia in [1, 2, 3, 4, 5, 6, 7])
                        FilterChip(
                          label: Text(l.narrowWeekdays[dia % 7]),
                          selected: _dias.contains(dia),
                          onSelected: (si) => setState(
                            () => _dias = si
                                ? {..._dias, dia}
                                : ({..._dias}..remove(dia)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (_modo != _Modo.cadaHoras) ...[
                  Text(
                    t.recordatorioHorarios,
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final h in _horarios)
                        InputChip(
                          label: Text(hora(h)),
                          deleteButtonTooltipMessage: t
                              .recordatorioQuitarHorario(hora(h)),
                          onDeleted: () => setState(
                            () => _horarios = [
                              for (final x in _horarios)
                                if (x != h) x,
                            ],
                          ),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(t.recordatorioAgregarHorario),
                        onPressed: _agregarHorario,
                      ),
                    ],
                  ),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    _modo == _Modo.cadaHoras
                        ? t.recordatorioPrimeraToma
                        : t.recordatorioInicio,
                  ),
                  subtitle: Text(
                    _modo == _Modo.cadaHoras
                        ? textoCuando(context, _inicio, ahora)
                        : l.formatMediumDate(_inicio),
                  ),
                  trailing: TextButton(
                    onPressed: _elegirInicio,
                    child: Text(t.libretaFechaElegir),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(t.recordatorioFin),
                  subtitle: Text(
                    _fin == null
                        ? t.recordatorioFinSin
                        : l.formatMediumDate(_fin!),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_fin != null)
                        TextButton(
                          onPressed: () => setState(() => _fin = null),
                          child: Text(t.libretaQuitarFecha),
                        ),
                      TextButton(
                        onPressed: _elegirFin,
                        child: Text(t.libretaFechaElegir),
                      ),
                    ],
                  ),
                ),
                if (!_esNuevo)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.recordatorioActivo),
                    value: _activo,
                    onChanged: (v) => setState(() => _activo = v),
                  ),
                if (_error case final error?) ...[
                  const SizedBox(height: 8),
                  Text(error, style: TextStyle(color: tema.colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: Text(_guardando ? t.guardando : t.guardar),
                ),
                if (!_esNuevo) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _guardando ? null : _borrar,
                    icon: Icon(
                      Icons.delete_outline,
                      color: tema.colorScheme.error,
                    ),
                    label: Text(
                      t.recordatorioBorrar,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
