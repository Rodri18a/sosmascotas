import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../chat/chat_repositorio.dart';
import '../../chat/posicion.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../fotos/elegir_foto.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../recordatorios/recordatorios.dart';

/// Cómo se llama al otro lado de la conversación (D73): a quien publicó un
/// SOS se lo nombra por la mascota, nunca por su nombre de cuenta.
String nombreDelOtro(AppLocalizations t, Conversacion c) {
  if (c.tipo == 'sos' && !c.soyAutor) {
    if (c.sosEncontrada) return t.chatQuienEncontro;
    return switch (c.sosNombre) {
      final n? when n.trim().isNotEmpty => t.chatFamiliaDe(n.trim()),
      _ => t.chatFamiliaSinNombre,
    };
  }
  return switch (c.otroNombre) {
    final n? when n.trim().isNotEmpty => n.trim(),
    _ => t.chatSinNombre,
  };
}

/// Lista de conversaciones (1.4.2).
class ConversacionesScreen extends ConsumerWidget {
  const ConversacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final ahora = ref.watch(relojProvider)();
    final conversaciones = ref.watch(conversacionesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.chatMensajes)),
      body: switch (conversaciones) {
        AsyncData(value: final lista) when lista.isEmpty => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(t.chatVacio, textAlign: TextAlign.center)),
        ),
        AsyncData(value: final lista) => RefreshIndicator(
          onRefresh: () => ref.refresh(conversacionesProvider.future),
          child: ListView(
            children: [
              for (final c in lista)
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      c.tipo == 'sos' ? Icons.pets : Icons.chat_outlined,
                    ),
                  ),
                  title: Text(nombreDelOtro(t, c)),
                  subtitle: Text(
                    c.ultimoMensaje ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        textoCuando(context, c.ultimoMensajeEn, ahora),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (c.sinLeer > 0) Badge(label: Text('${c.sinLeer}')),
                    ],
                  ),
                  onTap: () => context.push(Rutas.chat(c.id)),
                ),
            ],
          ),
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

/// Una conversación (1.4.2 a 1.4.4): mensajes al instante, foto, ubicación,
/// bloquear, reportar y aviso contra estafas.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.conversacionId, super.key});

  final String conversacionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

enum _Menu { bloquear, desbloquear }

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _texto = TextEditingController();
  bool _enviando = false;

  String get _id => widget.conversacionId;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _hacer(
    Future<void> Function(ChatRepositorio repo) accion,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      await accion(ref.read(chatRepositorioProvider));
      ref.read(metricasProvider).track(Eventos.chatMessage);
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    } finally {
      ref
        ..invalidate(mensajesProvider(_id))
        ..invalidate(conversacionesProvider);
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _enviarTexto() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty) return;
    _texto.clear();
    await _hacer((repo) => repo.enviarTexto(_id, texto));
  }

  Future<void> _enviarFoto() async {
    final original = await elegirFoto(context, ref);
    if (original == null || !mounted) return;
    // Sin la ubicación de la foto (EXIF) y achicada, como en las mascotas.
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    await _hacer((repo) => repo.enviarFoto(_id, preparada));
  }

  Future<void> _enviarUbicacion() async {
    final t = context.t;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.chatUbicacionTitulo),
        content: Text(t.chatUbicacionTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.chatUbicacionMandar),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    final posicion = await ref.read(posicionActualProvider)();
    if (posicion == null) {
      mensajes.showSnackBar(
        SnackBar(content: Text(t.chatUbicacionNoDisponible)),
      );
      return;
    }
    await _hacer(
      (repo) => repo.enviarUbicacion(_id, posicion.lat, posicion.lng),
    );
  }

  Future<void> _bloquear({required bool bloquear}) async {
    final t = context.t;
    if (bloquear) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.chatBloquearTitulo),
          content: Text(t.chatBloquearTexto),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.chatBloquear),
            ),
          ],
        ),
      );
      if (!(ok ?? false)) return;
    }
    try {
      await ref.read(chatRepositorioProvider).bloquear(_id, bloquear: bloquear);
      if (bloquear) ref.read(metricasProvider).track(Eventos.chatBlock);
    } on Exception {
      // Se vuelve a leer igual.
    }
    ref.invalidate(conversacionesProvider);
  }

  Future<void> _reportar(Mensaje mensaje) async {
    final t = context.t;
    final motivo = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (clave, texto) in [
              ('estafa', t.chatMotivoEstafa),
              ('ofensivo', t.chatMotivoOfensivo),
              ('otro', t.chatMotivoOtro),
            ])
              ListTile(
                title: Text(texto),
                onTap: () => Navigator.pop(context, clave),
              ),
          ],
        ),
      ),
    );
    if (motivo == null || !mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(chatRepositorioProvider).reportar(mensaje.id, motivo);
      ref
          .read(metricasProvider)
          .track(
            Eventos.contentFlag,
            props: {'target_type': 'message', 'motivo': motivo},
          );
      mensajes.showSnackBar(SnackBar(content: Text(t.chatReportado)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.chatReportado)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final yo = ref.watch(usuarioActualProvider).value?.id;
    final conversacion = (ref.watch(conversacionesProvider).value ?? const [])
        .where((c) => c.id == _id)
        .firstOrNull;
    final mensajes = ref.watch(mensajesProvider(_id));

    // Al ver mensajes nuevos, se marcan leídos.
    ref.listen(mensajesProvider(_id), (_, siguiente) {
      if (siguiente.hasValue) {
        unawaited(
          ref
              .read(chatRepositorioProvider)
              .marcarLeido(_id)
              .then((_) => ref.invalidate(conversacionesProvider))
              .catchError((Object _) {}),
        );
      }
    });

    final bloqueada = conversacion?.bloqueada ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          conversacion == null
              ? t.chatMensajes
              : nombreDelOtro(t, conversacion),
        ),
        actions: [
          if (conversacion != null)
            PopupMenuButton<_Menu>(
              onSelected: (opcion) =>
                  _bloquear(bloquear: opcion == _Menu.bloquear),
              itemBuilder: (_) => [
                if (conversacion.bloqueadaPorMi)
                  PopupMenuItem(
                    value: _Menu.desbloquear,
                    child: Text(t.chatDesbloquear),
                  )
                else
                  PopupMenuItem(
                    value: _Menu.bloquear,
                    child: Text(t.chatBloquear),
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Aviso de seguridad fijo (1.4.4).
          Material(
            color: tema.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: tema.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.chatSeguridad,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: switch (mensajes) {
              AsyncData(value: final lista) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final m = lista[lista.length - 1 - i];
                  return _Burbuja(
                    mensaje: m,
                    mio: m.remitenteId == yo,
                    alReportar: () => _reportar(m),
                  );
                },
              ),
              AsyncLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              _ => Center(child: Text(t.errorSinConexion)),
            },
          ),
          if (bloqueada)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                (conversacion?.bloqueadaPorMi ?? false)
                    ? t.chatBloqueadaPorVos
                    : t.chatBloqueadaPorOtro,
                textAlign: TextAlign.center,
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: t.chatFoto,
                      onPressed: _enviando ? null : _enviarFoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                    IconButton(
                      tooltip: t.chatUbicacion,
                      onPressed: _enviando ? null : _enviarUbicacion,
                      icon: const Icon(Icons.location_on_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _texto,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 2000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: t.chatEscribir,
                          counterText: '',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _enviarTexto(),
                      ),
                    ),
                    IconButton(
                      tooltip: t.chatEnviar,
                      onPressed: _enviando ? null : _enviarTexto,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Burbuja extends ConsumerWidget {
  const _Burbuja({
    required this.mensaje,
    required this.mio,
    required this.alReportar,
  });

  final Mensaje mensaje;
  final bool mio;
  final VoidCallback alReportar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final ahora = ref.watch(relojProvider)();
    final fondo = mio ? colores.primaryContainer : colores.surfaceContainerHigh;
    final texto = mio ? colores.onPrimaryContainer : colores.onSurface;
    final estafa = !mio && pareceEstafa(mensaje.texto ?? '');

    return Align(
      alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: mio ? null : alReportar,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mensaje.foto case final ruta?) _FotoChat(ruta: ruta),
              if (mensaje.conUbicacion)
                TextButton.icon(
                  onPressed: () => ref.read(abrirEnlaceProvider)(
                    Uri.https('www.google.com', '/maps/search/', {
                      'api': '1',
                      'query': '${mensaje.lat},${mensaje.lng}',
                    }),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: Text(t.chatVerEnMapa),
                ),
              if (mensaje.texto case final cuerpo?)
                Text(cuerpo, style: TextStyle(color: texto)),
              if (estafa) ...[
                const SizedBox(height: 6),
                Text(
                  t.chatPosibleEstafa,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: colores.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    textoCuando(context, mensaje.creado, ahora),
                    style: tema.textTheme.labelSmall?.copyWith(color: texto),
                  ),
                  if (!mio)
                    IconButton(
                      tooltip: t.chatReportar,
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: alReportar,
                      icon: Icon(Icons.flag_outlined, color: texto),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FotoChat extends ConsumerWidget {
  const _FotoChat({required this.ruta});

  final String ruta;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<String?>(
    future: ref.read(chatRepositorioProvider).urlFoto(ruta),
    builder: (context, url) => switch (url.data) {
      final u? => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(u, width: 240, fit: BoxFit.cover),
      ),
      _ => const SizedBox(
        width: 240,
        height: 160,
        child: Center(child: Icon(Icons.photo_outlined)),
      ),
    },
  );
}

/// Abre el chat con quien publicó un SOS (1.4.3).
Future<void> abrirChatDeSos(
  BuildContext context,
  WidgetRef ref,
  String sosId,
) async {
  final t = context.t;
  final mensajes = ScaffoldMessenger.of(context);
  try {
    final id = await ref.read(chatRepositorioProvider).iniciarDesdeSos(sosId);
    ref
      ..read(metricasProvider).track(Eventos.chatStart, props: {'tipo': 'sos'})
      ..invalidate(conversacionesProvider);
    if (context.mounted) await context.push(Rutas.chat(id));
  } on Exception catch (e) {
    final demasiados = e.toString().contains('54000');
    mensajes.showSnackBar(
      SnackBar(content: Text(demasiados ? t.chatDemasiados : t.chatNoPuedo)),
    );
  }
}
