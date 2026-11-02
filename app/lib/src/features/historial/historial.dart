import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../fotos/elegir_foto.dart';
import '../../fotos/selector_documento.dart';
import '../../mascotas/historial_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/volver.dart';

IconData iconoAcontecimiento(TipoAcontecimiento tipo) => switch (tipo) {
  TipoAcontecimiento.surgery => Icons.healing_outlined,
  TipoAcontecimiento.accident => Icons.personal_injury_outlined,
  TipoAcontecimiento.illness => Icons.sick_outlined,
  TipoAcontecimiento.treatment => Icons.medication_outlined,
  TipoAcontecimiento.diagnosis => Icons.biotech_outlined,
  TipoAcontecimiento.other => Icons.notes_outlined,
};

String textoAcontecimiento(AppLocalizations t, TipoAcontecimiento tipo) =>
    switch (tipo) {
      TipoAcontecimiento.surgery => t.vidaTipoOperacion,
      TipoAcontecimiento.accident => t.vidaTipoAccidente,
      TipoAcontecimiento.illness => t.vidaTipoEnfermedad,
      TipoAcontecimiento.treatment => t.vidaTipoTratamiento,
      TipoAcontecimiento.diagnosis => t.vidaTipoDiagnostico,
      TipoAcontecimiento.other => t.vidaTipoOtro,
    };

/// Abre un adjunto con un enlace que vence (el bucket es privado).
Future<void> abrirAdjunto(
  BuildContext context,
  WidgetRef ref,
  String ruta,
) async {
  final mensajes = ScaffoldMessenger.of(context);
  final error = context.t.errorSinConexion;
  final url = await ref.read(historialRepositorioProvider).urlAdjunto(ruta);
  if (url == null) {
    mensajes.showSnackBar(SnackBar(content: Text(error)));
    return;
  }
  await ref.read(abrirEnlaceProvider)(Uri.parse(url));
}

/// Historial de vida dentro de la ficha (plan de mejoras 2.1, D131): una
/// línea de tiempo con lo más nuevo arriba.
class TarjetaHistorial extends ConsumerWidget {
  const TarjetaHistorial({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.timeline_outlined),
              title: Text(t.vidaVida, style: tema.textTheme.titleMedium),
            ),
            switch (ref.watch(historialProvider(mascotaId))) {
              AsyncData(value: final lista) when lista.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.vidaVacio),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  for (final (i, a) in lista.indexed)
                    _Linea(
                      acontecimiento: a,
                      fecha: fechas.formatMediumDate(a.fecha),
                      ultima: i == lista.length - 1,
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
                    context.push(Rutas.nuevoAcontecimiento(mascotaId)),
                icon: const Icon(Icons.add_outlined),
                label: Text(t.vidaAgregar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un punto de la línea de tiempo: ícono, fecha y tipo, título, nota y
/// adjuntos. Tocarlo abre la edición.
class _Linea extends ConsumerWidget {
  const _Linea({
    required this.acontecimiento,
    required this.fecha,
    required this.ultima,
  });

  final AcontecimientoVida acontecimiento;
  final String fecha;
  final bool ultima;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final a = acontecimiento;
    return InkWell(
      onTap: () => context.push(Rutas.editarAcontecimiento(a.mascotaId, a.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    child: Icon(
                      iconoAcontecimiento(a.tipo),
                      size: 18,
                      color: tema.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (!ultima)
                    Expanded(
                      child: VerticalDivider(
                        width: 2,
                        thickness: 2,
                        color: tema.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$fecha · ${textoAcontecimiento(t, a.tipo)}',
                        style: tema.textTheme.labelMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(a.titulo, style: tema.textTheme.titleSmall),
                      if (a.notas case final n? when n.isNotEmpty)
                        Text(
                          n,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodySmall,
                        ),
                      if (a.adjuntos.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final (i, ruta) in a.adjuntos.indexed)
                              ActionChip(
                                avatar: Icon(
                                  AcontecimientoVida.esPdf(ruta)
                                      ? Icons.picture_as_pdf_outlined
                                      : Icons.image_outlined,
                                  size: 18,
                                ),
                                label: Text(t.vidaAdjuntoN(i + 1)),
                                onPressed: () =>
                                    abrirAdjunto(context, ref, ruta),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alta (sin [acontecimientoId]) o edición de un acontecimiento.
class AcontecimientoScreen extends ConsumerWidget {
  const AcontecimientoScreen({
    required this.mascotaId,
    this.acontecimientoId,
    super.key,
  });

  final String mascotaId;
  final String? acontecimientoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final id = acontecimientoId;
    if (id == null) return _Formulario(mascotaId: mascotaId);
    return switch (ref.watch(
      acontecimientoProvider((mascotaId: mascotaId, id: id)),
    )) {
      AsyncData(value: final a?) => _Formulario(
        mascotaId: mascotaId,
        original: a,
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

/// Un adjunto todavía sin subir.
typedef _Nuevo = ({Uint8List bytes, bool pdf});

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.mascotaId, this.original});

  final String mascotaId;
  final AcontecimientoVida? original;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _form = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.original?.titulo);
  late final _notas = TextEditingController(text: widget.original?.notas);
  late var _tipo = widget.original?.tipo ?? TipoAcontecimiento.illness;
  late var _fecha =
      widget.original?.fecha ?? DateUtils.dateOnly(DateTime.now());

  /// Los que ya estaban guardados y siguen (los quitados se borran al guardar).
  late final _guardados = [...?widget.original?.adjuntos];
  final _nuevos = <_Nuevo>[];
  bool _guardando = false;
  String? _error;

  bool get _esNuevo => widget.original == null;
  int get _cantidad => _guardados.length + _nuevos.length;

  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(1981),
      lastDate: DateUtils.dateOnly(DateTime.now()),
      helpText: context.t.vidaFecha,
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  void _sumar(_Nuevo nuevo) {
    setState(() {
      _nuevos.add(nuevo);
      _error = null;
    });
    ref
        .read(metricasProvider)
        .track(
          Eventos.lifeEventFileAdd,
          props: {'type': nuevo.pdf ? 'pdf' : 'photo'},
        );
  }

  Future<void> _agregarFoto() async {
    final original = await elegirFoto(context, ref);
    if (original == null || !mounted) return;
    // Achica y quita la ubicación (EXIF), como todas las fotos (D28).
    final preparada = prepararFoto(original);
    if (preparada == null) {
      setState(() => _error = context.t.vidaAdjuntoInvalido);
      return;
    }
    _sumar((bytes: preparada, pdf: false));
  }

  Future<void> _agregarPdf() async {
    final bytes = await ref.read(selectorDocumentoProvider)();
    if (bytes == null || !mounted) return;
    if (!esPdfValido(bytes)) {
      setState(() => _error = context.t.vidaAdjuntoInvalido);
      return;
    }
    if (bytes.length > AcontecimientoVida.maxBytesAdjunto) {
      setState(() => _error = context.t.vidaAdjuntoGrande);
      return;
    }
    _sumar((bytes: bytes, pdf: true));
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    final repo = ref.read(historialRepositorioProvider);
    final subidos = <String>[];
    try {
      for (final n in _nuevos) {
        subidos.add(
          await repo.subirAdjunto(widget.mascotaId, n.bytes, pdf: n.pdf),
        );
      }
      final acontecimiento = AcontecimientoVida(
        id: widget.original?.id ?? '',
        mascotaId: widget.mascotaId,
        tipo: _tipo,
        titulo: _titulo.text,
        fecha: _fecha,
        notas: _notas.text,
        adjuntos: [..._guardados, ...subidos],
      );
      if (_esNuevo) {
        await repo.crear(acontecimiento);
        ref
            .read(metricasProvider)
            .track(Eventos.lifeEventCreate, props: {'kind': _tipo.name});
      } else {
        await repo.actualizar(acontecimiento);
        // Los adjuntos quitados ya no los usa nadie.
        final quitados = [
          for (final r in widget.original!.adjuntos)
            if (!_guardados.contains(r)) r,
        ];
        await repo.borrarAdjuntos(quitados);
      }
      ref.invalidate(historialProvider(widget.mascotaId));
      if (mounted) context.pop();
    } on Exception {
      // Lo que se llegó a subir sin guardarse no queda suelto.
      try {
        await repo.borrarAdjuntos(subidos);
      } on Exception catch (e) {
        debugPrint('No se pudieron borrar los adjuntos sin usar: $e');
      }
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
        title: Text(t.vidaBorrarTitulo(original.titulo)),
        content: Text(t.vidaBorrarExplicacion),
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
    final repo = ref.read(historialRepositorioProvider);
    try {
      await repo.borrar(original.id);
      await repo.borrarAdjuntos(original.adjuntos);
      ref.invalidate(historialProvider(widget.mascotaId));
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
    final lleno = _cantidad >= AcontecimientoVida.maxAdjuntos;

    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(
          context,
          Rutas.fichaMascota(widget.mascotaId),
        ),
        title: Text(_esNuevo ? t.vidaNuevo : t.vidaEditar),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.vidaTipo, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tipo in TipoAcontecimiento.values)
                      ChoiceChip(
                        avatar: Icon(iconoAcontecimiento(tipo), size: 18),
                        label: Text(textoAcontecimiento(t, tipo)),
                        selected: tipo == _tipo,
                        onSelected: (_) => setState(() => _tipo = tipo),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titulo,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.vidaTitulo,
                    helperText: t.vidaTituloAyuda,
                  ),
                  validator: (v) => switch (validarAcontecimiento(
                    titulo: v ?? '',
                    fecha: _fecha,
                    hoy: DateTime.now(),
                  )) {
                    ValidacionAcontecimiento.sinTitulo => t.vidaTituloFalta,
                    ValidacionAcontecimiento.tituloLargo =>
                      t.libretaNombreLargo,
                    _ => null,
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(t.vidaFecha),
                  subtitle: Text(fechas.formatMediumDate(_fecha)),
                  trailing: TextButton(
                    onPressed: _elegirFecha,
                    child: Text(t.libretaFechaElegir),
                  ),
                ),
                TextFormField(
                  controller: _notas,
                  maxLength: 1000,
                  maxLines: 6,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: t.libretaNotas,
                    helperText: t.vidaNotasAyuda,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.vidaAdjuntos(_cantidad),
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                for (final (i, ruta) in _guardados.indexed)
                  _FilaAdjunto(
                    pdf: AcontecimientoVida.esPdf(ruta),
                    texto: t.vidaAdjuntoN(i + 1),
                    alAbrir: () => abrirAdjunto(context, ref, ruta),
                    alQuitar: () => setState(() => _guardados.remove(ruta)),
                  ),
                for (final (i, n) in _nuevos.indexed)
                  _FilaAdjunto(
                    pdf: n.pdf,
                    texto: t.vidaAdjuntoNuevo(_guardados.length + i + 1),
                    alQuitar: () => setState(() => _nuevos.removeAt(i)),
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: lleno || _guardando ? null : _agregarFoto,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(t.vidaAgregarFoto),
                    ),
                    OutlinedButton.icon(
                      onPressed: lleno || _guardando ? null : _agregarPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(t.vidaAgregarPdf),
                    ),
                  ],
                ),
                if (lleno)
                  Text(t.vidaAdjuntosTope, style: tema.textTheme.bodySmall),
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
                      t.vidaBorrar,
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

class _FilaAdjunto extends StatelessWidget {
  const _FilaAdjunto({
    required this.pdf,
    required this.texto,
    required this.alQuitar,
    this.alAbrir,
  });

  final bool pdf;
  final String texto;
  final VoidCallback alQuitar;
  final VoidCallback? alAbrir;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(pdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
    title: Text(texto),
    onTap: alAbrir,
    trailing: IconButton(
      tooltip: context.t.vidaQuitarAdjunto,
      icon: const Icon(Icons.close),
      onPressed: alQuitar,
    ),
  );
}
