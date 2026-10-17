import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mascotas/libreta_repositorio.dart';
import '../../mascotas/textos_mascota.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../theme/paleta.dart';
import '../../utiles/enlaces.dart';

IconData iconoRegistro(TipoRegistroSalud tipo) => switch (tipo) {
  TipoRegistroSalud.vaccine => Icons.vaccines_outlined,
  TipoRegistroSalud.deworming => Icons.bug_report_outlined,
  TipoRegistroSalud.checkup => Icons.medical_services_outlined,
  TipoRegistroSalud.allergy => Icons.warning_amber_outlined,
  TipoRegistroSalud.other => Icons.notes,
};

/// Libreta sanitaria dentro de la ficha de la mascota (paso 1.5.1).
class TarjetaLibreta extends ConsumerWidget {
  const TarjetaLibreta({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final libreta = ref.watch(libretaProvider(mascotaId));
    final hoy = ref.watch(relojProvider)();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(t.libretaTitulo, style: tema.textTheme.titleMedium),
            ),
            switch (libreta) {
              AsyncData(value: final grupos) when grupos.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.libretaVacia),
              ),
              AsyncData(value: final grupos) => _Registros(
                mascotaId: mascotaId,
                grupos: grupos,
                hoy: hoy,
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
                    context.push(Rutas.nuevoRegistroSalud(mascotaId)),
                icon: const Icon(Icons.add),
                label: Text(t.libretaAgregar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Texto del semáforo: "Venció hace 3 días", "Vence hoy", "Faltan 5 días".
String textoSemaforo(AppLocalizations t, DateTime proxima, DateTime hoy) {
  final dias = diasHasta(proxima, hoy);
  if (dias < 0) return t.semaforoVencio(-dias);
  if (dias == 0) return t.semaforoHoy;
  return t.semaforoFaltan(dias);
}

/// Color del semáforo. Siempre va con su texto: el color solo no alcanza.
Color colorSemaforo(BuildContext context, Semaforo semaforo) =>
    switch (semaforo) {
      Semaforo.vencido || Semaforo.rojo => Theme.of(context).colorScheme.error,
      Semaforo.amarillo => context.marca.urgencia,
      Semaforo.verde => context.marca.exito,
    };

class _Registros extends StatelessWidget {
  const _Registros({
    required this.mascotaId,
    required this.grupos,
    required this.hoy,
  });

  final String mascotaId;
  final Map<TipoRegistroSalud, List<RegistroSalud>> grupos;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    final vigentes = proximosVigentes(grupos.values.expand((l) => l));
    final idsVigentes = {for (final v in vigentes) v.id};
    final urgente = vigentes
        .where((v) => semaforoDe(v.proxima!, hoy).index <= Semaforo.rojo.index)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (urgente != null) _AvisoUrgente(registro: urgente, hoy: hoy),
        for (final MapEntry(key: tipo, value: registros) in grupos.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              textoGrupoLibreta(t, tipo),
              style: tema.textTheme.labelLarge,
            ),
          ),
          for (final r in registros)
            ListTile(
              leading: Icon(iconoRegistro(tipo)),
              title: Text(r.nombre),
              subtitle: _subtitulo(
                context,
                fechas,
                r,
                vigente: idsVigentes.contains(r.id),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push(Rutas.editarRegistroSalud(mascotaId, r.id)),
            ),
        ],
      ],
    );
  }

  Widget? _subtitulo(
    BuildContext context,
    MaterialLocalizations fechas,
    RegistroSalud r, {
    required bool vigente,
  }) {
    final t = context.t;
    final partes = [
      if (r.fecha case final f?) fechas.formatMediumDate(f),
      if (r.proxima case final p?)
        t.libretaProximaEl(fechas.formatMediumDate(p)),
    ];
    final proxima = r.proxima;
    final estado = vigente && proxima != null
        ? Text(
            textoSemaforo(t, proxima, hoy),
            style: TextStyle(
              color: colorSemaforo(context, semaforoDe(proxima, hoy)),
              fontWeight: FontWeight.w600,
            ),
          )
        : null;
    if (partes.isEmpty && estado == null) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [if (partes.isNotEmpty) Text(partes.join(' · ')), ?estado],
    );
  }
}

/// Lo vencido o lo que toca en 7 días o menos, arriba de todo.
class _AvisoUrgente extends StatelessWidget {
  const _AvisoUrgente({required this.registro, required this.hoy});

  final RegistroSalud registro;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final proxima = registro.proxima!;
    final color = colorSemaforo(context, semaforoDe(proxima, hoy));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Semantics(
        container: true,
        label: t.libretaProximoUrgente,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.event_busy_outlined, color: color),
            title: Text(registro.nombre),
            subtitle: Text(
              textoSemaforo(t, proxima, hoy),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alta (sin [registroId]) o edición de un registro de la libreta.
class RegistroSaludScreen extends ConsumerWidget {
  const RegistroSaludScreen({
    required this.mascotaId,
    this.registroId,
    super.key,
  });

  final String mascotaId;
  final String? registroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = registroId;
    if (id == null) return _Formulario(mascotaId: mascotaId);
    return switch (ref.watch(
      registroSaludProvider((mascotaId: mascotaId, id: id)),
    )) {
      AsyncData(value: final registro?) => _Formulario(
        mascotaId: mascotaId,
        original: registro,
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

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.mascotaId, this.original});

  final String mascotaId;
  final RegistroSalud? original;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.original?.nombre);
  late final _notas = TextEditingController(text: widget.original?.notas);
  late TipoRegistroSalud _tipo =
      widget.original?.tipo ?? TipoRegistroSalud.vaccine;
  late DateTime? _fecha =
      widget.original?.fecha ??
      (widget.original == null ? DateUtils.dateOnly(DateTime.now()) : null);
  late DateTime? _proxima = widget.original?.proxima;
  bool _guardando = false;
  String? _error;

  bool get _esNuevo => widget.original == null;

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha({required bool proxima}) async {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final inicial = proxima
        ? _proxima ?? DateTime(hoy.year + 1, hoy.month, hoy.day)
        : _fecha ?? hoy;
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: proxima ? (_fecha ?? DateTime(1981)) : DateTime(1981),
      lastDate: proxima ? DateTime(hoy.year + 10) : hoy,
      helpText: proxima ? context.t.libretaProxima : context.t.libretaFecha,
    );
    if (elegida == null) return;
    setState(() {
      if (proxima) {
        _proxima = elegida;
      } else {
        _fecha = elegida;
      }
    });
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    final fecha = _tipo.llevaFecha ? _fecha : null;
    final proxima = _tipo.llevaFecha ? _proxima : null;
    if (validarRegistroSalud(
          nombre: _nombre.text,
          fecha: fecha,
          proxima: proxima,
        ) ==
        ValidacionRegistroSalud.proximaAntes) {
      setState(() => _error = t.libretaProximaAntes);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    final registro = RegistroSalud(
      id: widget.original?.id ?? '',
      mascotaId: widget.mascotaId,
      tipo: _tipo,
      nombre: _nombre.text,
      fecha: fecha,
      proxima: proxima,
      notas: _notas.text,
    );
    final repo = ref.read(libretaRepositorioProvider);
    try {
      if (_esNuevo) {
        await repo.crear(registro);
        ref
            .read(metricasProvider)
            .track(Eventos.healthRecordCreate, props: {'tipo': _tipo.name});
      } else {
        await repo.actualizar(registro);
      }
      ref.invalidate(libretaProvider(widget.mascotaId));
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
        title: Text(t.libretaBorrarTitulo(original.nombre)),
        content: Text(t.libretaBorrarExplicacion),
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
      await ref.read(libretaRepositorioProvider).borrar(original.id);
      ref.invalidate(libretaProvider(widget.mascotaId));
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
    final fechas = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_esNuevo ? t.libretaNuevoTitulo : t.libretaEditarTitulo),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.libretaTipo, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tipo in TipoRegistroSalud.values)
                      ChoiceChip(
                        avatar: Icon(iconoRegistro(tipo), size: 18),
                        label: Text(textoTipoRegistro(t, tipo)),
                        selected: tipo == _tipo,
                        onSelected: (_) => setState(() => _tipo = tipo),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombre,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.libretaNombre,
                    helperText: ayudaNombreRegistro(t, _tipo),
                  ),
                  validator: (v) => switch (validarRegistroSalud(
                    nombre: v ?? '',
                  )) {
                    ValidacionRegistroSalud.sinNombre => t.libretaNombreFalta,
                    ValidacionRegistroSalud.nombreLargo => t.libretaNombreLargo,
                    _ => null,
                  },
                ),
                if (_tipo.llevaFecha) ...[
                  _CampoFecha(
                    icono: Icons.event_outlined,
                    titulo: t.libretaFecha,
                    valor: _fecha == null
                        ? t.libretaFechaSin
                        : fechas.formatMediumDate(_fecha!),
                    alElegir: () => _elegirFecha(proxima: false),
                    alQuitar: _fecha == null
                        ? null
                        : () => setState(() => _fecha = null),
                  ),
                  _CampoFecha(
                    icono: Icons.event_repeat_outlined,
                    titulo: t.libretaProxima,
                    valor: _proxima == null
                        ? t.libretaProximaAyuda
                        : fechas.formatMediumDate(_proxima!),
                    alElegir: () => _elegirFecha(proxima: true),
                    alQuitar: _proxima == null
                        ? null
                        : () => setState(() => _proxima = null),
                  ),
                ],
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notas,
                  maxLength: 500,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: t.libretaNotas,
                    helperText: t.libretaNotasAyuda,
                  ),
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
                      t.libretaBorrar,
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

class _CampoFecha extends StatelessWidget {
  const _CampoFecha({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.alElegir,
    this.alQuitar,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final VoidCallback alElegir;
  final VoidCallback? alQuitar;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: Text(valor),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alQuitar != null)
            TextButton(onPressed: alQuitar, child: Text(t.libretaQuitarFecha)),
          TextButton(onPressed: alElegir, child: Text(t.libretaFechaElegir)),
        ],
      ),
    );
  }
}
