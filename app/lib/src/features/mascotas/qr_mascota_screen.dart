import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../qr/cartel_qr.dart';
import '../../qr/qr_repositorio.dart';
import '../../utiles/descargar.dart';
import '../chapitas/pedido_chapita.dart';

/// QR de la mascota: verlo, descargarlo para imprimir, la nota pública y
/// regenerarlo si hace falta.
class QrMascotaScreen extends ConsumerWidget {
  const QrMascotaScreen({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mascota = ref.watch(mascotaProvider(mascotaId)).value;
    final qr = ref.watch(qrActivoProvider(mascotaId));
    return Scaffold(
      appBar: AppBar(title: Text(t.fichaQrTitulo)),
      body: switch (qr) {
        AsyncData(value: final tag?) when mascota != null => _Contenido(
          mascota: mascota,
          tag: tag,
        ),
        AsyncData() || AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Contenido extends ConsumerStatefulWidget {
  const _Contenido({required this.mascota, required this.tag});

  final Mascota mascota;
  final QrTag tag;

  @override
  ConsumerState<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends ConsumerState<_Contenido> {
  late final _nota = TextEditingController(text: widget.tag.notaPublica);
  bool _ocupado = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  String get _url =>
      urlPaginaQr(widget.tag.codigo, base: ref.read(appEnvProvider).urlPublica);

  void _avisar(String mensaje) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(mensaje)));

  Future<void> _descargar() async {
    final t = context.t;
    setState(() => _ocupado = true);
    try {
      final png = await cartelQrPng(
        url: _url,
        nombre: widget.mascota.nombre,
        indicacion: t.qrCartelIndicacion,
        codigo: widget.tag.codigo,
      );
      final ok = descargarArchivo(
        png,
        'qr-${widget.mascota.nombre.toLowerCase()}-${widget.tag.codigo}.png',
        'image/png',
      );
      if (!ok) _avisar(t.qrDescargaNoDisponible);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _url));
    if (mounted) _avisar(context.t.qrEnlaceCopiado);
  }

  Future<void> _guardarNota() async {
    final t = context.t;
    FocusScope.of(context).unfocus();
    setState(() => _ocupado = true);
    try {
      await ref
          .read(qrRepositorioProvider)
          .guardarNota(widget.tag.id, _nota.text);
      ref.invalidate(qrActivoProvider(widget.mascota.id));
      _avisar(t.qrNotaGuardada);
    } on Exception {
      _avisar(t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _regenerar() async {
    final t = context.t;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.qrRegenerarTitulo),
        content: Text(t.qrRegenerarExplicacion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.qrRegenerar),
          ),
        ],
      ),
    );
    if (!(confirmado ?? false) || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await ref.read(qrRepositorioProvider).regenerar(widget.mascota.id);
      ref.invalidate(qrActivoProvider(widget.mascota.id));
      _avisar(t.qrRegenerado);
    } on Exception {
      _avisar(t.errorSinConexion);
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esDueno = widget.mascota.esDe(
      ref.watch(usuarioActualProvider).value?.id,
    );
    final t = context.t;
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t.qrExplicacion(widget.mascota.nombre),
          style: tema.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: DecoratedBox(
            // Fondo blanco siempre (también en modo oscuro): el QR necesita contraste.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: _url,
                size: 240,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                semanticsLabel: t.qrDe(widget.mascota.nombre),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SelectableText(
            widget.tag.codigo,
            style: tema.textTheme.titleLarge?.copyWith(letterSpacing: 4),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _ocupado ? null : _descargar,
          icon: const Icon(Icons.download_outlined),
          label: Text(t.qrDescargar),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _copiar,
          icon: const Icon(Icons.link_outlined),
          label: Text(t.qrCopiarEnlace),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => launchUrl(Uri.parse(_url)),
          icon: const Icon(Icons.open_in_new_outlined),
          label: Text(t.qrVerPagina),
        ),
        if (esDueno) ...[
          const SizedBox(height: 24),
          Text(t.qrNotaTitulo, style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nota,
            maxLength: 200,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(helperText: t.qrNotaAyuda),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _ocupado ? null : _guardarNota,
              child: Text(t.guardar),
            ),
          ),
        ],
        const Divider(height: 32),
        Text(t.qrEscaneosTitulo, style: tema.textTheme.titleMedium),
        _Escaneos(mascotaId: widget.mascota.id),
        const Divider(height: 32),
        _Chapitas(mascota: widget.mascota, esDueno: esDueno),
        const Divider(height: 32),
        Text(t.qrConsejoChapita, style: tema.textTheme.bodySmall),
        // Cambiar el QR (deja inservible la chapita) es solo del dueño (D69).
        if (esDueno) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _ocupado ? null : _regenerar,
            icon: const Icon(Icons.autorenew_outlined),
            label: Text(t.qrRegenerar),
          ),
        ],
      ],
    );
  }
}

/// Últimos escaneos: cuándo abrieron la página y, si la compartieron, dónde.
class _Escaneos extends ConsumerWidget {
  const _Escaneos({required this.mascotaId});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final escaneos = ref.watch(escaneosProvider(mascotaId)).value ?? const [];
    if (escaneos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t.qrSinEscaneos),
      );
    }
    final formato = DateFormat("d 'de' MMMM, HH:mm", 'es');
    return Column(
      children: [
        for (final e in escaneos)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              e.conUbicacion
                  ? Icons.place_outlined
                  : Icons.qr_code_scanner_outlined,
            ),
            title: Text(formato.format(e.creado)),
            subtitle: Text(
              e.conUbicacion
                  ? t.qrEscaneoConUbicacion
                  : t.qrEscaneoSinUbicacion,
            ),
            onTap: e.conUbicacion
                ? () => launchUrl(
                    Uri.https('www.google.com', '/maps/search/', {
                      'api': '1',
                      'query': '${e.lat},${e.lng}',
                    }),
                    mode: LaunchMode.externalApplication,
                  )
                : null,
          ),
      ],
    );
  }
}

/// Chapitas físicas vinculadas (1.8b.2, D95): activar una escribiendo su
/// código y desvincularla si se perdió. Las acciones son solo del dueño.
class _Chapitas extends ConsumerWidget {
  const _Chapitas({required this.mascota, required this.esDueno});

  final Mascota mascota;
  final bool esDueno;

  Future<void> _activar(BuildContext context, WidgetRef ref) async {
    final activada = await showDialog<bool>(
      context: context,
      builder: (_) => ActivarChapitaDialogo(mascota: mascota),
    );
    if ((activada ?? false) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.chapitaActivada(mascota.nombre))),
      );
    }
  }

  Future<void> _desvincular(
    BuildContext context,
    WidgetRef ref,
    QrTag chapita,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.chapitaDesvincularTitulo),
        content: Text(
          t.chapitaDesvincularTexto(chapita.codigo, mascota.nombre),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.chapitaDesvincular),
          ),
        ],
      ),
    );
    if (!(confirmado ?? false)) return;
    try {
      await ref.read(qrRepositorioProvider).desvincularChapita(chapita.id);
      ref.read(metricasProvider).track(Eventos.tagUnlink);
      ref.invalidate(chapitasProvider(mascota.id));
      mensajes.showSnackBar(SnackBar(content: Text(t.chapitaDesvinculada)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final chapitas = ref.watch(chapitasProvider(mascota.id)).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.chapitasTitulo, style: tema.textTheme.titleMedium),
        if (esDueno) ...[
          const SizedBox(height: 4),
          Text(t.chapitasExplicacion(mascota.nombre)),
        ],
        if (chapitas.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(t.chapitasNinguna),
          ),
        for (final c in chapitas)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.qr_code_2_outlined),
            title: Text(c.codigo),
            trailing: esDueno
                ? TextButton(
                    onPressed: () => _desvincular(context, ref, c),
                    child: Text(t.chapitaDesvincular),
                  )
                : null,
          ),
        if (esDueno) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _activar(context, ref),
              icon: const Icon(Icons.add_link_outlined),
              label: Text(t.chapitaActivar),
            ),
          ),
          SiFuncionalidad(
            Funcionalidades.pedidoChapitas,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TarjetaPedidoChapita(mascota: mascota),
            ),
          ),
        ],
      ],
    );
  }
}

/// Escribir el código impreso en la chapita (o pegar su enlace).
class ActivarChapitaDialogo extends ConsumerStatefulWidget {
  const ActivarChapitaDialogo({required this.mascota, super.key});

  final Mascota mascota;

  @override
  ConsumerState<ActivarChapitaDialogo> createState() =>
      _ActivarChapitaDialogoState();
}

class _ActivarChapitaDialogoState extends ConsumerState<ActivarChapitaDialogo> {
  final _codigo = TextEditingController();
  String? _error;
  bool _activando = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _activar() async {
    final t = context.t;
    final codigo = codigoChapita(_codigo.text);
    if (codigo == null) {
      setState(() => _error = t.chapitaCodigoInvalido);
      return;
    }
    setState(() {
      _activando = true;
      _error = null;
    });
    final error = await activarChapita(
      ref,
      codigo: codigo,
      mascotaId: widget.mascota.id,
      origen: 'codigo',
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _activando = false;
        _error = textoErrorChapita(context, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.chapitaActivar),
      content: TextField(
        controller: _codigo,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: t.chapitaCodigo,
          helperText: t.chapitaCodigoAyuda,
          errorText: _error,
          errorMaxLines: 3,
        ),
        onSubmitted: (_) => _activando ? null : _activar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _activando ? null : _activar,
          child: Text(t.activarChapitaBoton),
        ),
      ],
    );
  }
}

/// Activa la chapita, registra la métrica y refresca la lista. Devuelve el
/// motivo si no se pudo (`null` si salió bien).
Future<ErrorChapita?> activarChapita(
  WidgetRef ref, {
  required String codigo,
  required String mascotaId,
  required String origen,
}) async {
  try {
    await ref.read(qrRepositorioProvider).activarChapita(codigo, mascotaId);
  } on ChapitaFallida catch (e) {
    return e.motivo;
  }
  ref
      .read(metricasProvider)
      .track(Eventos.tagActivate, props: {'origen': origen});
  ref.invalidate(chapitasProvider(mascotaId));
  return null;
}

String textoErrorChapita(BuildContext context, ErrorChapita error) =>
    switch (error) {
      ErrorChapita.inexistente => context.t.chapitaInexistente,
      ErrorChapita.usada => context.t.chapitaUsada,
      ErrorChapita.limite => context.t.chapitaLimite,
      ErrorChapita.sinConexion => context.t.errorSinConexion,
    };
