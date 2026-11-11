import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../recordatorios/avisador.dart';
import '../../recordatorios/recordatorios_repositorio.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/ilustracion.dart';
import '../../widgets/volver.dart';

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

IconData iconoRecordatorio(TipoRecordatorio tipo) => switch (tipo) {
  TipoRecordatorio.medication => Icons.medication_outlined,
  TipoRecordatorio.food => Icons.restaurant_outlined,
  TipoRecordatorio.vaccine => Icons.vaccines_outlined,
  TipoRecordatorio.checkup => Icons.medical_services_outlined,
};

String textoTipoRecordatorio(AppLocalizations t, TipoRecordatorio tipo) =>
    switch (tipo) {
      TipoRecordatorio.medication => t.recordatorioTipoMedicacion,
      TipoRecordatorio.food => t.recordatorioTipoComida,
      TipoRecordatorio.vaccine => t.recordatorioTipoVacuna,
      TipoRecordatorio.checkup => t.recordatorioTipoControl,
    };

/// Recordatorios dentro de la ficha de la mascota (pasos 1.5.3 y 1.5.4).
class TarjetaRecordatorios extends ConsumerWidget {
  const TarjetaRecordatorios({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final ahora = ref.watch(relojProvider)();
    final recordatorios = ref.watch(recordatoriosDeMascotaProvider(mascotaId));
    final hechas = ref.watch(tomasHechasProvider).value ?? const <TomaHecha>[];

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
                child: Center(
                  child: VacioIlustrado(
                    Ilustracion.salud,
                    t.recordatoriosVacio,
                    alto: 100,
                  ),
                ),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  const _PermisoAvisos(),
                  for (final r in lista) ...[
                    ListTile(
                      leading: Icon(
                        r.activo
                            ? iconoRecordatorio(r.tipo)
                            : Icons.pause_circle_outline,
                      ),
                      title: Text(r.titulo),
                      subtitle: Text(_estado(context, r, ahora)),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      onTap: () => context.push(
                        Rutas.editarRecordatorio(mascotaId, r.id),
                      ),
                    ),
                    if (tomaPendiente(r, ahora, hechas) case final toma?)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                        child: _BotonYaSeLaDi(recordatorio: r, toma: toma),
                      ),
                  ],
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
      else if (r.frecuencia is UnaVez)
        t.recordatorioYaPaso
      else
        t.recordatorioTerminado,
    ];
    return partes.join(' · ');
  }
}

/// "✅ Ya se la di" (paso 1.5.5): marca la toma y deja deshacerlo.
class _BotonYaSeLaDi extends ConsumerStatefulWidget {
  const _BotonYaSeLaDi({required this.recordatorio, required this.toma});

  final Recordatorio recordatorio;
  final DateTime toma;

  @override
  ConsumerState<_BotonYaSeLaDi> createState() => _BotonYaSeLaDiState();
}

class _BotonYaSeLaDiState extends ConsumerState<_BotonYaSeLaDi> {
  bool _marcando = false;

  Future<void> _marcar() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final repo = ref.read(recordatoriosRepositorioProvider);
    // El botón desaparece al marcar: lo que sigue (deshacer) usa el
    // contenedor, que no depende de este widget.
    final contenedor = ProviderScope.containerOf(context, listen: false);
    final id = widget.recordatorio.id;
    void releer() => contenedor
      ..invalidate(tomasHechasProvider)
      ..invalidate(historialProvider(id));
    setState(() => _marcando = true);
    try {
      final hecha = await repo.marcar(id, widget.toma);
      contenedor
          .read(metricasProvider)
          .track(
            Eventos.reminderDone,
            props: {'tipo': widget.recordatorio.tipo.name},
          );
      mensajes.showSnackBar(
        SnackBar(
          content: Text(t.recordatorioMarcado),
          action: SnackBarAction(
            label: t.recordatorioDeshacer,
            onPressed: () async {
              try {
                await repo.desmarcar(hecha.id);
              } on Exception {
                mensajes.showSnackBar(
                  SnackBar(content: Text(t.errorSinConexion)),
                );
              }
              releer();
            },
          ),
        ),
      );
    } on Exception {
      // Puede que ya estuviera marcada: se vuelve a leer igual.
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    } finally {
      if (mounted) setState(() => _marcando = false);
      releer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hora = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(widget.toma),
      alwaysUse24HourFormat: true,
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FilledButton.tonal(
        onPressed: _marcando ? null : _marcar,
        child: Text(switch (widget.recordatorio.tipo) {
          TipoRecordatorio.medication => t.recordatorioYaSeLaDi(hora),
          TipoRecordatorio.food => t.recordatorioYaComio(hora),
          TipoRecordatorio.vaccine ||
          TipoRecordatorio.checkup => t.recordatorioHecho(hora),
        }),
      ),
    );
  }
}

/// Las últimas tomas marcadas de un recordatorio.
class _Historial extends ConsumerWidget {
  const _Historial({required this.recordatorioId});

  final String recordatorioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final ahora = ref.watch(relojProvider)();
    final historial = ref.watch(historialProvider(recordatorioId));
    final nombres = ref.watch(nombresDelHogarProvider);
    final yo = ref.watch(usuarioActualProvider).value?.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(t.recordatorioHistorial, style: tema.textTheme.titleSmall),
        switch (historial) {
          AsyncData(value: final tomas) when tomas.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(t.recordatorioHistorialVacio),
          ),
          AsyncData(value: final tomas) => Column(
            children: [
              for (final toma in tomas)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(textoCuando(context, toma.prevista, ahora)),
                  subtitle: Text(switch (nombres[toma.hechaPor]) {
                    // En un hogar compartido se ve quién la dio (D69).
                    final n? when toma.hechaPor != yo =>
                      t.recordatorioMarcadaPor(
                        n,
                        textoCuando(context, toma.hecha, ahora),
                      ),
                    _ => t.recordatorioHistorialMarcada(
                      textoCuando(context, toma.hecha, ahora),
                    ),
                  }),
                ),
            ],
          ),
          AsyncLoading() => const Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()),
          ),
          _ => Text(t.errorSinConexion),
        },
      ],
    );
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
    this.precarga,
    super.key,
  });

  /// Lee la precarga de la dirección (`?tipo=vaccine&titulo=…&fecha=2027-09-01`),
  /// por ejemplo desde "Recordarme" en la libreta.
  static Precarga? precargaDe(Map<String, String> parametros) {
    final tipo = TipoRecordatorio.values.asNameMap()[parametros['tipo']];
    if (tipo == null) return null;
    return (
      tipo: tipo,
      titulo: parametros['titulo'],
      fecha: DateTime.tryParse(parametros['fecha'] ?? ''),
    );
  }

  final String mascotaId;
  final String? recordatorioId;
  final Precarga? precarga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = recordatorioId;
    if (id == null) {
      return _Formulario(mascotaId: mascotaId, precarga: precarga);
    }
    return switch (ref.watch(recordatorioProvider(id))) {
      AsyncData(value: final r?) => _Formulario(
        mascotaId: mascotaId,
        original: r,
      ),
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => Scaffold(
        appBar: AppBar(
          leading: volverSiNoHayAtras(context, Rutas.fichaMascota(mascotaId)),
        ),
        body: Center(child: Text(t.errorDesconocido)),
      ),
    };
  }
}

/// Datos con los que arranca un recordatorio nuevo.
typedef Precarga = ({TipoRecordatorio tipo, String? titulo, DateTime? fecha});

enum _Modo { cadaHoras, diaria, semanal, unaVez }

/// Las frecuencias que tienen sentido para cada tipo (la primera es la de
/// arranque).
List<_Modo> _modosDe(TipoRecordatorio tipo) => switch (tipo) {
  TipoRecordatorio.medication => const [
    _Modo.cadaHoras,
    _Modo.diaria,
    _Modo.semanal,
  ],
  TipoRecordatorio.food => const [_Modo.diaria, _Modo.semanal],
  TipoRecordatorio.vaccine || TipoRecordatorio.checkup => const [_Modo.unaVez],
};

const _opcionesHoras = [4, 6, 8, 12, 24, 48, 72];

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.mascotaId, this.original, this.precarga});

  final String mascotaId;
  final Recordatorio? original;
  final Precarga? precarga;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(
    text: widget.original?.titulo ?? widget.precarga?.titulo,
  );
  late final _dosis = TextEditingController(text: widget.original?.dosis);

  late TipoRecordatorio _tipo =
      widget.original?.tipo ??
      widget.precarga?.tipo ??
      TipoRecordatorio.medication;
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

  bool get _llevaDosis =>
      _tipo == TipoRecordatorio.medication || _tipo == TipoRecordatorio.food;

  @override
  void initState() {
    super.initState();
    final ahora = ref.read(relojProvider)();
    // Por defecto: la próxima hora en punto.
    _inicio =
        widget.original?.inicio ??
        DateTime(ahora.year, ahora.month, ahora.day, ahora.hour + 1);
    _modo = _modosDe(_tipo).first;
    _horas = 8;
    // Vacunas y controles de la libreta: ese día a las 9.
    if (widget.precarga?.fecha case final f? when widget.original == null) {
      _inicio = DateTime(f.year, f.month, f.day, 9);
    }
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
      case UnaVez():
        _modo = _Modo.unaVez;
      case null:
    }
  }

  void _cambiarTipo(TipoRecordatorio tipo) => setState(() {
    _tipo = tipo;
    if (!_modosDe(tipo).contains(_modo)) _modo = _modosDe(tipo).first;
  });

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
    _Modo.unaVez => const UnaVez(),
  };

  Future<void> _elegirInicio() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _inicio,
      firstDate: DateTime(_inicio.year - 1),
      lastDate: DateTime(_inicio.year + 2),
    );
    if (dia == null || !mounted) return;
    final hora = _modo == _Modo.cadaHoras || _modo == _Modo.unaVez
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
        fin: _modo == _Modo.unaVez ? null : _fin,
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
      tipo: _tipo,
      titulo: _titulo.text,
      dosis: _llevaDosis ? _dosis.text : null,
      frecuencia: _frecuencia,
      inicio: _inicio,
      fin: _modo == _Modo.unaVez ? null : _fin,
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
        leading: volverSiNoHayAtras(
          context,
          Rutas.fichaMascota(widget.mascotaId),
        ),
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
                Text(t.recordatorioTipo, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tipo in TipoRecordatorio.values)
                      ChoiceChip(
                        avatar: Icon(iconoRecordatorio(tipo), size: 18),
                        label: Text(textoTipoRecordatorio(t, tipo)),
                        selected: tipo == _tipo,
                        onSelected: (_) => _cambiarTipo(tipo),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titulo,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: switch (_tipo) {
                      TipoRecordatorio.medication => t.recordatorioTitulo,
                      TipoRecordatorio.food => t.recordatorioTituloComida,
                      TipoRecordatorio.vaccine => t.recordatorioTituloVacuna,
                      TipoRecordatorio.checkup => t.recordatorioTituloControl,
                    },
                    helperText: switch (_tipo) {
                      TipoRecordatorio.medication => t.recordatorioTituloAyuda,
                      TipoRecordatorio.food => t.recordatorioTituloComidaAyuda,
                      TipoRecordatorio.vaccine =>
                        t.recordatorioTituloVacunaAyuda,
                      TipoRecordatorio.checkup =>
                        t.recordatorioTituloControlAyuda,
                    },
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
                if (_llevaDosis)
                  TextFormField(
                    controller: _dosis,
                    maxLength: 80,
                    decoration: InputDecoration(
                      labelText: _tipo == TipoRecordatorio.food
                          ? t.recordatorioPorcion
                          : t.recordatorioDosis,
                      helperText: _tipo == TipoRecordatorio.food
                          ? t.recordatorioPorcionAyuda
                          : t.recordatorioDosisAyuda,
                    ),
                  ),
                if (_modosDe(_tipo).length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    t.recordatorioFrecuencia,
                    style: tema.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<_Modo>(
                    segments: [
                      for (final modo in _modosDe(_tipo))
                        ButtonSegment(
                          value: modo,
                          label: Text(switch (modo) {
                            _Modo.cadaHoras => t.recordatorioCadaHoras,
                            _Modo.diaria => t.recordatorioDiaria,
                            _Modo.semanal => t.recordatorioSemanal,
                            _Modo.unaVez => t.recordatorioCuando,
                          }),
                        ),
                    ],
                    selected: {_modo},
                    onSelectionChanged: (s) => setState(() => _modo = s.first),
                  ),
                  const SizedBox(height: 16),
                ],
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
                if (_modo == _Modo.diaria || _modo == _Modo.semanal) ...[
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
                        avatar: const Icon(Icons.add_outlined, size: 18),
                        label: Text(t.recordatorioAgregarHorario),
                        onPressed: _agregarHorario,
                      ),
                    ],
                  ),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(switch (_modo) {
                    _Modo.cadaHoras => t.recordatorioPrimeraToma,
                    _Modo.unaVez => t.recordatorioCuando,
                    _ => t.recordatorioInicio,
                  }),
                  subtitle: Text(
                    _modo == _Modo.cadaHoras || _modo == _Modo.unaVez
                        ? textoCuando(context, _inicio, ahora)
                        : l.formatMediumDate(_inicio),
                  ),
                  trailing: TextButton(
                    onPressed: _elegirInicio,
                    child: Text(t.libretaFechaElegir),
                  ),
                ),
                if (_modo != _Modo.unaVez)
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
                  _Historial(recordatorioId: widget.original!.id),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
