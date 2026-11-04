import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mapa/mapa_vista.dart';
import '../../mascotas/textos_mascota.dart';
import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../router.dart';
import '../../sos/cartel_sos_pdf.dart';
import '../../sos/sos_repositorio.dart';
import '../../utiles/descargar.dart';
import '../../widgets/boton_ayuda.dart';
import '../chat/chat_screen.dart';

/// Detalle de un SOS: fotos, datos, zona aproximada y cómo ayudar.
class SosDetalleScreen extends ConsumerWidget {
  const SosDetalleScreen({required this.sosId, super.key});

  final String sosId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.sosDetalleTitulo),
        actions: const [BotonAyuda()],
      ),
      body: switch (ref.watch(sosDetalleProvider(sosId))) {
        AsyncData(value: final detalle?) => _Detalle(detalle: detalle),
        AsyncData() => Center(child: Text(t.sosNoEncontrado)),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.detalle});

  final SosDetalle detalle;

  String _url(WidgetRef ref) =>
      urlPaginaSos(detalle.id, base: ref.read(appEnvProvider).urlPublica);

  Future<void> _compartir(BuildContext context, WidgetRef ref) async {
    await Clipboard.setData(ClipboardData(text: _url(ref)));
    ref.read(metricasProvider).track(Eventos.sosShare, targetId: detalle.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.sosEnlaceCopiado)));
    }
  }

  Future<void> _cartel(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final perdida = detalle.tipo == TipoSos.perdida;
    final donde = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoCartel(perdida: perdida),
    );
    if (donde == null || !context.mounted) return;
    final fecha = DateFormat("d 'de' MMMM", 'es').format(detalle.cuando);
    final lugar = donde.trim().isEmpty ? null : donde.trim();
    final url = _url(ref);
    final Uint8List pdf;
    try {
      pdf = await cartelSosPdf(
        url: url,
        perdida: perdida,
        foto: await _bajarFoto(ref.read(sosRepositorioProvider)),
        logo: (await rootBundle.load(
          'assets/marca/isotipo.png',
        )).buffer.asUint8List(),
        normal: await rootBundle.load('assets/fuentes/NunitoSans-Regular.ttf'),
        negrita: await rootBundle.load('assets/fuentes/NunitoSans-Bold.ttf'),
        textos: (
          titulo: perdida ? t.sosCartelSeBusca : t.sosCartelSeEncontro,
          subtitulo: perdida
              ? (detalle.nombre ?? detalle.especie)
              : t.sosCartelEsTuyo,
          datos: [
            detalle.especie,
            ?detalle.raza,
            if (detalle.sexo != Sexo.unknown) textoSexo(t, detalle.sexo),
            ?detalle.color,
          ].join(' · '),
          senas: detalle.senas == null
              ? null
              : t.sosCartelSenas(detalle.senas!),
          descripcion: detalle.descripcion,
          cuando: perdida
              ? t.sosCartelFaltaDesde(fecha)
              : t.sosCartelEncontradaEl(fecha),
          donde: lugar == null
              ? null
              : (perdida
                    ? t.sosCartelVistaEn(lugar)
                    : t.sosCartelEncontradaEn(lugar)),
          escanea: perdida
              ? t.sosCartelEscaneaPerdida
              : t.sosCartelEscaneaEncontrada,
          privacidad: perdida
              ? t.sosCartelPrivacidadPerdida
              : t.sosCartelPrivacidadEncontrada,
          pie: t.sosCartelPie(url.replaceFirst(RegExp('^https?://'), '')),
        ),
      );
    } on Object {
      // Sin esto, una falla al armarlo no mostraba nada (29/10).
      mensajes.showSnackBar(SnackBar(content: Text(t.errorDesconocido)));
      return;
    }
    final ok = descargarArchivo(
      pdf,
      'cartel-${(detalle.nombre ?? detalle.especie).toLowerCase()}.pdf',
      'application/pdf',
    );
    if (ok) {
      ref.read(metricasProvider).track(Eventos.sosPoster, targetId: detalle.id);
    } else {
      mensajes.showSnackBar(SnackBar(content: Text(t.historialNoDisponible)));
    }
  }

  /// La primera foto del reporte, o nada si no se puede bajar (el cartel sale
  /// igual, sin foto).
  Future<Uint8List?> _bajarFoto(SosRepositorio repo) async {
    final url = detalle.fotos.isEmpty
        ? null
        : repo.urlFoto(detalle.fotos.first);
    if (url == null) return null;
    try {
      final r = await http.get(Uri.parse(url));
      return r.statusCode == 200 ? r.bodyBytes : null;
    } on Exception {
      return null;
    }
  }

  Future<void> _avisar(BuildContext context, WidgetRef ref) async {
    if (!ref.read(conectadoProvider)) {
      await abrirConCuenta(
        context,
        ref,
        destino: Rutas.detalleSos(detalle.id),
        motivo: context.t.sosAvisarMotivoCuenta,
      );
      return;
    }
    final enviado = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioAviso(sosId: detalle.id),
    );
    if ((enviado ?? false) && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.sosAvisoEnviado)));
    }
  }

  Future<void> _reportar(BuildContext context, WidgetRef ref) async {
    if (!ref.read(conectadoProvider)) {
      await abrirConCuenta(
        context,
        ref,
        destino: Rutas.detalleSos(detalle.id),
        motivo: context.t.sosReportarContenidoMotivoCuenta,
      );
      return;
    }
    final nuevo = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioReporte(sosId: detalle.id),
    );
    if (nuevo != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevo
                ? context.t.sosReportarContenidoGracias
                : context.t.sosReportarContenidoYaReportado,
          ),
        ),
      );
    }
  }

  Future<void> _cerrar(
    BuildContext context,
    WidgetRef ref, {
    required bool resuelto,
  }) async {
    final t = context.t;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resuelto ? t.sosAparecioTitulo : t.sosArchivarTitulo),
        content: Text(
          resuelto ? t.sosAparecioExplicacion : t.sosArchivarExplicacion,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(resuelto ? t.sosAparecio : t.sosArchivar),
          ),
        ],
      ),
    );
    if (!(confirmado ?? false) || !context.mounted) return;
    try {
      await ref
          .read(sosRepositorioProvider)
          .cerrar(detalle.id, resuelto: resuelto);
      ref
        ..invalidate(sosDetalleProvider(detalle.id))
        ..invalidate(sosCercanosProvider)
        ..invalidate(misSosProvider);
      if (context.mounted && resuelto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.sosAparecioGracias)));
        await ofrecerCompartirReencuentro(context, ref, detalle.id);
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
      }
    }
  }

  Future<void> _abrirWhatsapp(BuildContext context, String numero) async {
    final t = context.t;
    final seguir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(t.sosWhatsappAdvertenciaTitulo),
        content: Text(t.sosWhatsappAdvertencia),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.sosWhatsappAbrir),
          ),
        ],
      ),
    );
    final internacional = telefonoInternacionalUy(numero);
    if ((seguir ?? false) && internacional != null) {
      await launchUrl(
        Uri.https('wa.me', '/$internacional'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final repo = ref.watch(sosRepositorioProvider);
    final perdida = detalle.tipo == TipoSos.perdida;
    final activo = detalle.estado == EstadoSos.activo;
    final titulo = perdida
        ? t.sosTituloPerdida(detalle.nombre ?? detalle.especie)
        : t.sosTituloEncontrada(detalle.especie);
    final datos = [
      '${detalle.especieIcono} ${detalle.especie}',
      ?detalle.raza,
      if (detalle.sexo != Sexo.unknown) textoSexo(t, detalle.sexo),
      ?detalle.color,
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (detalle.fotos.isNotEmpty)
          SizedBox(
            height: 280,
            child: PageView(
              children: [
                for (final foto in detalle.fotos)
                  if (repo.urlFoto(foto) case final url?)
                    Image.network(url, fit: BoxFit.cover)
                  else
                    ColoredBox(
                      color: tema.colorScheme.primaryContainer,
                      child: Center(
                        child: Text(
                          detalle.especieIcono,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!activo)
                Card(
                  color: tema.colorScheme.secondaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(switch (detalle.estado) {
                      EstadoSos.resuelto => t.sosEstadoResuelto,
                      EstadoSos.oculto => t.sosEstadoOculto,
                      _ => t.sosEstadoArchivado,
                    }),
                  ),
                ),
              Text(
                titulo,
                style: tema.textTheme.headlineSmall?.copyWith(
                  color: perdida
                      ? tema.colorScheme.error
                      : tema.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(datos, style: tema.textTheme.bodyLarge),
              Text(
                '${perdida ? t.sosCuandoPerdida : t.sosCuandoEncontrada} '
                '${DateFormat("d 'de' MMMM", 'es').format(detalle.cuando)}',
                style: tema.textTheme.bodySmall,
              ),
              if (detalle.senas case final senas?) ...[
                const SizedBox(height: 12),
                Text(t.mascotaSenas, style: tema.textTheme.titleSmall),
                Text(senas),
              ],
              if (detalle.descripcion case final descripcion?) ...[
                const SizedBox(height: 12),
                Text(descripcion),
              ],
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(
                    detalle.esMio
                        ? (perdida
                              ? t.sosConsejoDuenoRenac
                              : t.sosConsejoEncontradaPropia)
                        : (detalle.tieneMicrochip || !perdida
                              ? t.sosConsejoVeterinaria
                              : t.sosConsejoVista),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(t.sosZonaAproximada, style: tema.textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapaVista(
                    centro: detalle.zona,
                    zoom: 15,
                    pins: [
                      Pin(
                        id: detalle.id,
                        tipo: perdida ? TipoPin.perdido : TipoPin.encontrado,
                        punto: detalle.zona,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (detalle.esMio &&
                  (activo || detalle.estado == EstadoSos.oculto)) ...[
                FilledButton.icon(
                  onPressed: () => _cerrar(context, ref, resuelto: true),
                  icon: const Icon(Icons.celebration_outlined),
                  label: Text(t.sosAparecio),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _cerrar(context, ref, resuelto: false),
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(t.sosArchivar),
                ),
                const SizedBox(height: 8),
              ],
              if (detalle.esMio && detalle.estado == EstadoSos.resuelto)
                _InterruptorReencuentro(sosId: detalle.id),
              if (activo && !detalle.esMio) ...[
                // Chat interno (1.4.3, D73), con la funcionalidad `chat`.
                if (ref.watch(conectadoProvider) &&
                    ref.watch(
                      funcionalidadActivaProvider(Funcionalidades.chat),
                    )) ...[
                  FilledButton.icon(
                    onPressed: () => abrirChatDeSos(context, ref, detalle.id),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(t.chatEscribirPorChat),
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton.icon(
                  onPressed: () => _avisar(context, ref),
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(
                    perdida ? t.sosAvisarDueno : t.sosAvisarQuienEncontro,
                  ),
                ),
                if (detalle.whatsapp case final numero?) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _abrirWhatsapp(context, numero),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(t.avisosWhatsapp),
                  ),
                ],
                const SizedBox(height: 8),
                // Seguir el reporte (1.4.5, D74), con la funcionalidad `chat`.
                if (ref.watch(conectadoProvider) &&
                    ref.watch(
                      funcionalidadActivaProvider(Funcionalidades.chat),
                    )) ...[
                  _BotonSeguir(sosId: detalle.id),
                  const SizedBox(height: 8),
                ],
              ],
              OutlinedButton.icon(
                onPressed: () => _compartir(context, ref),
                icon: const Icon(Icons.share_outlined),
                label: Text(t.sosCompartir),
              ),
              // Cartel para pegar en el barrio (D119): lo puede imprimir
              // cualquiera, no solo quien reportó.
              if (activo) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _cartel(context, ref),
                  icon: const Icon(Icons.print_outlined),
                  label: Text(t.sosCartel),
                ),
              ],
              const SizedBox(height: 8),
              Text(t.sosPrivacidadDetalle, style: tema.textTheme.bodySmall),
              if (activo && !detalle.esMio) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _reportar(context, ref),
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(t.sosReportarContenido),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Antes de armar el cartel: dónde la vieron (o la encontraron), opcional.
/// Devuelve el texto (puede ser vacío) o `null` si se canceló.
class _DialogoCartel extends StatefulWidget {
  const _DialogoCartel({required this.perdida});

  final bool perdida;

  @override
  State<_DialogoCartel> createState() => _DialogoCartelState();
}

class _DialogoCartelState extends State<_DialogoCartel> {
  final _donde = TextEditingController();

  @override
  void dispose() {
    _donde.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.sosCartel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.sosCartelExplicacion),
          const SizedBox(height: 12),
          TextField(
            controller: _donde,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.perdida
                  ? t.sosCartelDondePerdida
                  : t.sosCartelDondeEncontrada,
              helperText: t.sosCartelDondeAyuda,
              helperMaxLines: 2,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _donde.text),
          child: Text(t.sosCartelArmar),
        ),
      ],
    );
  }
}

/// Motivos para reportar un SOS (se guardan en `flags.reason`).
enum _MotivoReporte { falso, estafa, spam, ofensivo, otro }

/// Reportar un SOS a moderación: motivo + detalle opcional.
/// Devuelve `true` si se registró, `false` si ya lo había reportado.
class _FormularioReporte extends ConsumerStatefulWidget {
  const _FormularioReporte({required this.sosId});

  final String sosId;

  @override
  ConsumerState<_FormularioReporte> createState() => _FormularioReporteState();
}

class _FormularioReporteState extends ConsumerState<_FormularioReporte> {
  final _detalle = TextEditingController();
  _MotivoReporte? _motivo;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _detalle.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = context.t;
    final motivo = _motivo;
    if (motivo == null) {
      setState(() => _error = t.sosReportarContenidoFaltaMotivo);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    final detalle = _detalle.text.trim();
    try {
      final nuevo = await ref
          .read(sosRepositorioProvider)
          .reportarContenido(
            widget.sosId,
            motivo: detalle.isEmpty ? motivo.name : '${motivo.name}: $detalle',
          );
      if (nuevo) {
        ref
            .read(metricasProvider)
            .track(
              Eventos.contentFlag,
              props: {'target_type': 'sos', 'reason': motivo.name},
              targetId: widget.sosId,
            );
      }
      if (mounted) Navigator.pop(context, nuevo);
    } on SosException {
      if (mounted) setState(() => _error = t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    String texto(_MotivoReporte m) => switch (m) {
      _MotivoReporte.falso => t.sosMotivoFalso,
      _MotivoReporte.estafa => t.sosMotivoEstafa,
      _MotivoReporte.spam => t.sosMotivoSpam,
      _MotivoReporte.ofensivo => t.sosMotivoOfensivo,
      _MotivoReporte.otro => t.sosMotivoOtro,
    };
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.sosReportarContenido, style: tema.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(t.sosReportarContenidoExplicacion),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _MotivoReporte.values)
                    ChoiceChip(
                      label: Text(texto(m)),
                      selected: _motivo == m,
                      onSelected: (_) => setState(() => _motivo = m),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detalle,
                maxLength: 200,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: t.sosReportarContenidoDetalle,
                ),
              ),
              if (_error case final error?)
                Text(error, style: TextStyle(color: tema.colorScheme.error)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _enviando ? null : _enviar,
                child: Text(
                  _enviando ? t.guardando : t.sosReportarContenidoEnviar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Avisar al dueño" desde la app: mensaje + nombre y contacto de quien avisa.
class _FormularioAviso extends ConsumerStatefulWidget {
  const _FormularioAviso({required this.sosId});

  final String sosId;

  @override
  ConsumerState<_FormularioAviso> createState() => _FormularioAvisoState();
}

class _FormularioAvisoState extends ConsumerState<_FormularioAviso> {
  final _form = GlobalKey<FormState>();
  final _mensaje = TextEditingController();
  late final _nombre = TextEditingController(
    text: ref.read(perfilProvider).value?.nombre,
  );
  final _contacto = TextEditingController();
  bool _acepto = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _mensaje.dispose();
    _nombre.dispose();
    _contacto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    if (!_acepto) {
      setState(() => _error = t.sosAvisoFaltaConsentimiento);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref
          .read(sosRepositorioProvider)
          .avisarAlDueno(
            sosId: widget.sosId,
            mensaje: _mensaje.text.trim(),
            nombre: _nombre.text.trim(),
            contacto: _contacto.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } on SosException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.tipo == ErrorSos.demasiadosAvisos
              ? t.errorDemasiadosIntentos
              : t.errorSinConexion,
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    String? requerido(String? v) =>
        (v ?? '').trim().isEmpty ? t.sosCampoObligatorio : null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.sosAvisarTitulo, style: tema.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mensaje,
                  maxLength: 1000,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(labelText: t.sosAvisoMensaje),
                  validator: requerido,
                ),
                TextFormField(
                  controller: _nombre,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.sosAvisoNombre),
                  validator: requerido,
                ),
                TextFormField(
                  controller: _contacto,
                  maxLength: 80,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: t.sosAvisoContacto),
                  validator: (v) => (v ?? '').trim().length < 6
                      ? t.sosCampoObligatorio
                      : null,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _acepto,
                  onChanged: (v) => setState(() => _acepto = v ?? false),
                  title: Text(t.sosAvisoConsentimiento),
                ),
                if (_error case final error?)
                  Text(error, style: TextStyle(color: tema.colorScheme.error)),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _enviando ? null : _enviar,
                  child: Text(_enviando ? t.guardando : t.sosAvisoEnviar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonSeguir extends ConsumerWidget {
  const _BotonSeguir({required this.sosId});

  final String sosId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final sigo = ref.watch(sigoSosProvider(sosId)).value ?? false;
    Future<void> cambiar() async {
      final mensajes = ScaffoldMessenger.of(context);
      try {
        await ref.read(sosRepositorioProvider).seguir(sosId, seguir: !sigo);
        if (!sigo) {
          ref.read(metricasProvider).track(Eventos.sosFollow, targetId: sosId);
          mensajes.showSnackBar(SnackBar(content: Text(t.sosSiguiendo)));
        }
      } on Exception {
        mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
      }
      ref.invalidate(sigoSosProvider(sosId));
    }

    return sigo
        ? TextButton.icon(
            onPressed: cambiar,
            icon: const Icon(Icons.notifications_off_outlined),
            label: Text(t.sosDejarDeSeguir),
          )
        : OutlinedButton.icon(
            onPressed: cambiar,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(t.sosSeguir),
          );
  }
}

/// Después de "¡Apareció!": ofrece compartir la buena noticia en Comunidad
/// (D86). Sin respuesta, no se comparte.
Future<void> ofrecerCompartirReencuentro(
  BuildContext context,
  WidgetRef ref,
  String sosId,
) async {
  final t = context.t;
  final compartir = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.celebration_outlined),
      title: Text(t.comunidadCompartirTitulo),
      content: Text(t.comunidadCompartirExplicacion),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.ahoraNo),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.comunidadCompartir),
        ),
      ],
    ),
  );
  if (!(compartir ?? false) || !context.mounted) return;
  await _compartirReencuentro(context, ref, sosId, compartir: true);
}

Future<void> _compartirReencuentro(
  BuildContext context,
  WidgetRef ref,
  String sosId, {
  required bool compartir,
}) async {
  final t = context.t;
  final mensajes = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(noticiasRepositorioProvider)
        .compartirReencuentro(sosId, compartir: compartir);
    // Compartir lo registra la base; quitarlo, la app.
    if (compartir) {
      mensajes.showSnackBar(SnackBar(content: Text(t.comunidadCompartida)));
    } else {
      ref
          .read(metricasProvider)
          .track(Eventos.communityUnshare, targetId: sosId);
    }
  } on Exception {
    mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
  }
  ref
    ..invalidate(reencuentroCompartidoProvider(sosId))
    ..invalidate(novedadesProvider);
}

/// En un SOS mío ya resuelto: compartir o quitar el reencuentro de Comunidad.
class _InterruptorReencuentro extends ConsumerWidget {
  const _InterruptorReencuentro({required this.sosId});

  final String sosId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final compartido = ref.watch(reencuentroCompartidoProvider(sosId)).value;
    // Cuántos reaccionaron (D87): solo el total, nunca quiénes.
    final reacciones = (compartido ?? false)
        ? ref.watch(reaccionesDeMiReencuentroProvider(sosId)).value ?? 0
        : 0;
    return SwitchListTile(
      secondary: const Icon(Icons.diversity_3_outlined),
      title: Text(t.comunidadInterruptor),
      subtitle: Text(
        [
          t.comunidadInterruptorDetalle,
          if (reacciones > 0) t.comunidadReaccionesTuyo(reacciones),
        ].join('\n'),
      ),
      value: compartido ?? false,
      onChanged: compartido == null
          ? null
          : (v) => _compartirReencuentro(context, ref, sosId, compartir: v),
    );
  }
}
