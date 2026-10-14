import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../qr/cartel_qr.dart';
import '../../qr/qr_repositorio.dart';
import '../../utiles/descargar.dart';

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
          icon: const Icon(Icons.download),
          label: Text(t.qrDescargar),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _copiar,
          icon: const Icon(Icons.link),
          label: Text(t.qrCopiarEnlace),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => launchUrl(Uri.parse(_url)),
          icon: const Icon(Icons.open_in_new),
          label: Text(t.qrVerPagina),
        ),
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
        const Divider(height: 32),
        Text(t.qrConsejoChapita, style: tema.textTheme.bodySmall),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _ocupado ? null : _regenerar,
          icon: const Icon(Icons.autorenew),
          label: Text(t.qrRegenerar),
        ),
      ],
    );
  }
}
