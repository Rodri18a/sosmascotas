import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../fotos/elegir_foto.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';

/// Alta (sin [mascotaId]) o edición de una mascota.
class MascotaFormScreen extends ConsumerWidget {
  const MascotaFormScreen({this.mascotaId, super.key});

  final String? mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = mascotaId;
    if (id == null) {
      return _Formulario(titulo: t.mascotaNuevaTitulo);
    }
    return switch (ref.watch(mascotaProvider(id))) {
      AsyncData(value: final mascota?) => _Formulario(
        titulo: t.mascotaEditarTitulo,
        original: mascota,
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
  const _Formulario({required this.titulo, this.original});

  final String titulo;
  final Mascota? original;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

/// Valor especial del desplegable de razas: "Otra / no está en la lista".
const _razaOtra = -1;

class _FormularioState extends ConsumerState<_Formulario> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.original?.nombre);
  late final _razaOtraTexto = TextEditingController(
    text: widget.original?.razaOtra,
  );
  late final _color = TextEditingController(text: widget.original?.color);
  late final _senas = TextEditingController(text: widget.original?.senas);
  late final _microchip = TextEditingController(
    text: widget.original?.microchip,
  );
  late final _notas = TextEditingController(text: widget.original?.notas);

  late int? _especieId = widget.original?.especieId;
  late int? _razaId =
      widget.original?.razaId ??
      (widget.original?.razaOtra == null ? null : _razaOtra);
  late Sexo _sexo = widget.original?.sexo ?? Sexo.unknown;
  late DateTime? _nacimiento = widget.original?.nacimiento;
  late bool? _castrada = widget.original?.castrada;

  Uint8List? _fotoNueva;
  bool _procesandoFoto = false;
  bool _guardando = false;
  String? _error;

  bool get _esNueva => widget.original == null;

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _razaOtraTexto,
      _color,
      _senas,
      _microchip,
      _notas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final t = context.t;
    final original = await elegirFoto(context, ref);
    if (original == null || !mounted) return;
    setState(() => _procesandoFoto = true);
    // Achica y quita la ubicación (EXIF) antes de mostrarla o subirla.
    final preparada = prepararFoto(original);
    if (!mounted) return;
    setState(() {
      _procesandoFoto = false;
      _fotoNueva = preparada ?? _fotoNueva;
      _error = preparada == null ? t.mascotaFotoInvalida : null;
    });
  }

  Future<void> _elegirNacimiento() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _nacimiento ?? DateTime(hoy.year - 1, hoy.month, hoy.day),
      firstDate: DateTime(1981),
      lastDate: hoy,
      helpText: context.t.mascotaNacimiento,
    );
    if (fecha != null) setState(() => _nacimiento = fecha);
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final t = context.t;
    final especieId = _especieId;
    final valido = _form.currentState!.validate();
    if (especieId == null) {
      setState(() => _error = t.mascotaEspecieFalta);
      return;
    }
    if (!valido) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    final repo = ref.read(mascotasRepositorioProvider);
    try {
      var fotoPath = widget.original?.fotoPath;
      if (_fotoNueva case final foto?) fotoPath = await repo.subirFoto(foto);

      final mascota = Mascota(
        id: widget.original?.id ?? '',
        nombre: _nombre.text,
        especieId: especieId,
        razaId: _razaId == _razaOtra ? null : _razaId,
        razaOtra: _razaId == _razaOtra || _razaId == null
            ? _razaOtraTexto.text
            : null,
        sexo: _sexo,
        color: _color.text,
        senas: _senas.text,
        nacimiento: _nacimiento,
        fotoPath: fotoPath,
        microchip: normalizarMicrochip(_microchip.text),
        castrada: _castrada,
        notas: _notas.text,
      );
      final guardada = _esNueva
          ? await repo.crear(mascota)
          : await repo.actualizar(mascota);
      if (_esNueva) ref.read(metricasProvider).track(Eventos.petCreate);
      ref.invalidate(misMascotasProvider);
      if (mounted) context.go(Rutas.fichaMascota(guardada.id));
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
        title: Text(t.mascotaBorrarTitulo(original.nombre)),
        content: Text(t.mascotaBorrarExplicacion),
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
      await ref.read(mascotasRepositorioProvider).borrar(original.id);
      ref.invalidate(misMascotasProvider);
      if (mounted) context.go(Rutas.mascotas);
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
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final especieId = _especieId;
    final razas = especieId == null
        ? const <Raza>[]
        : ref.watch(razasProvider(especieId)).value ?? const <Raza>[];
    final mostrarRazaOtra =
        especieId != null && (razas.isEmpty || _razaId == _razaOtra);

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: SafeArea(
        child: Form(
          key: _form,
          // SingleChildScrollView (no ListView): todos los campos quedan
          // construidos, así el formulario valida también los que no se ven.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      _fotoNueva != null
                          ? CircleAvatar(
                              radius: 56,
                              backgroundImage: MemoryImage(_fotoNueva!),
                            )
                          : FotoMascota(
                              ruta: widget.original?.fotoPath,
                              radio: 56,
                            ),
                      TextButton.icon(
                        onPressed: _procesandoFoto || _guardando
                            ? null
                            : _elegirFoto,
                        icon: _procesandoFoto
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add_a_photo_outlined),
                        label: Text(
                          _fotoNueva == null &&
                                  widget.original?.fotoPath == null
                              ? t.mascotaAgregarFoto
                              : t.mascotaCambiarFoto,
                        ),
                      ),
                      Text(
                        t.mascotaFotoAyuda,
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombre,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: t.mascotaNombre),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? t.mascotaNombreFalta : null,
                ),
                const SizedBox(height: 8),
                Text(t.mascotaEspecie, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final especie in especies)
                      ChoiceChip(
                        label: Text('${especie.icono} ${especie.nombre}'),
                        selected: especie.id == especieId,
                        onSelected: (_) => setState(() {
                          _especieId = especie.id;
                          _razaId = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (razas.isNotEmpty)
                  DropdownButtonFormField<int>(
                    key: ValueKey('raza-$especieId'),
                    initialValue: _razaId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: t.mascotaRaza),
                    items: [
                      for (final raza in razas)
                        DropdownMenuItem(
                          value: raza.id,
                          child: Text(raza.nombre),
                        ),
                      DropdownMenuItem(
                        value: _razaOtra,
                        child: Text(t.mascotaRazaOtra),
                      ),
                    ],
                    onChanged: (v) => setState(() => _razaId = v),
                  ),
                if (mostrarRazaOtra) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _razaOtraTexto,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: razas.isEmpty
                          ? t.mascotaRaza
                          : t.mascotaRazaOtraCampo,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(t.mascotaSexo, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<Sexo>(
                  segments: [
                    ButtonSegment(value: Sexo.male, label: Text(t.sexoMacho)),
                    ButtonSegment(
                      value: Sexo.female,
                      label: Text(t.sexoHembra),
                    ),
                    ButtonSegment(value: Sexo.unknown, label: Text(t.noSe)),
                  ],
                  selected: {_sexo},
                  onSelectionChanged: (s) => setState(() => _sexo = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _color,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.mascotaColor),
                ),
                TextFormField(
                  controller: _senas,
                  maxLength: 300,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: t.mascotaSenas,
                    helperText: t.mascotaSenasAyuda,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined),
                  title: Text(t.mascotaNacimiento),
                  subtitle: Text(
                    _nacimiento == null
                        ? t.mascotaNacimientoAyuda
                        : MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(_nacimiento!),
                  ),
                  trailing: TextButton(
                    onPressed: _elegirNacimiento,
                    child: Text(t.mascotaNacimientoElegir),
                  ),
                ),
                TextFormField(
                  controller: _microchip,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: t.mascotaMicrochip,
                    helperText: t.mascotaMicrochipAyuda,
                  ),
                  validator: (v) =>
                      validarMicrochip(v) ==
                          ValidacionMicrochip.noSonQuinceNumeros
                      ? t.mascotaMicrochipInvalido
                      : null,
                ),
                const SizedBox(height: 16),
                Text(t.mascotaCastrada, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 1, label: Text(t.si)),
                    ButtonSegment(value: 0, label: Text(t.no)),
                    ButtonSegment(value: -1, label: Text(t.noSe)),
                  ],
                  selected: {
                    switch (_castrada) {
                      true => 1,
                      false => 0,
                      null => -1,
                    },
                  },
                  onSelectionChanged: (s) => setState(
                    () => _castrada = switch (s.first) {
                      1 => true,
                      0 => false,
                      _ => null,
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notas,
                  maxLength: 1000,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: t.mascotaNotas,
                    helperText: t.mascotaNotasAyuda,
                  ),
                ),
                if (_error case final error?) ...[
                  const SizedBox(height: 8),
                  Text(error, style: TextStyle(color: tema.colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _guardando || _procesandoFoto ? null : _guardar,
                  child: Text(_guardando ? t.guardando : t.guardar),
                ),
                // Borrar la mascota es solo del dueño (D69).
                if (!_esNueva &&
                    widget.original!.esDe(
                      ref.watch(usuarioActualProvider).value?.id,
                    )) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _guardando ? null : _borrar,
                    icon: Icon(
                      Icons.delete_outline,
                      color: tema.colorScheme.error,
                    ),
                    label: Text(
                      t.mascotaBorrar,
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
