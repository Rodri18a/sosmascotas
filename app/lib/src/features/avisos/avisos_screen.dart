import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/l10n.dart';
import '../../avisos/avisos_repositorio.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../push/control_push.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/ilustracion.dart';
import '../../widgets/volver.dart';

/// Bandeja "Avisos": lo que dejaron quienes encontraron o vieron a tu mascota.
/// Vos decidís si los contactás; tu teléfono nunca se les mostró.
class AvisosScreen extends ConsumerStatefulWidget {
  const AvisosScreen({super.key});

  @override
  ConsumerState<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends ConsumerState<AvisosScreen> {
  bool _marcados = false;

  /// Al abrir la bandeja, los avisos nuevos pasan a "vistos".
  Future<void> _marcarVistos(List<Aviso> avisos) async {
    if (_marcados) return;
    _marcados = true;
    final nuevos = avisos.where((a) => a.estado == EstadoAviso.nuevo);
    if (nuevos.isEmpty) return;
    final repo = ref.read(avisosRepositorioProvider);
    try {
      await Future.wait(
        nuevos.map((a) => repo.cambiarEstado(a.id, EstadoAviso.visto)),
      );
    } on Exception {
      return; // Se vuelve a intentar la próxima vez que se abra.
    }
    ref.invalidate(avisosProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final avisos = ref.watch(avisosProvider);
    if (avisos case AsyncData(:final value)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _marcarVistos(value));
    }
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.avisosTitulo),
        actions: const [BotonAyuda()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(avisosProvider.future),
        child: switch (avisos) {
          AsyncData(value: final lista) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TarjetaActivarPush(),
              const _ConsejoAntiEstafa(),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: VacioIlustrado(
                    Ilustracion.amiSaludando,
                    t.avisosVacio,
                  ),
                )
              else
                for (final aviso in lista) _TarjetaAviso(aviso: aviso),
            ],
          ),
          AsyncError() => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(t.errorSinConexion, textAlign: TextAlign.center),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _ConsejoAntiEstafa extends StatelessWidget {
  const _ConsejoAntiEstafa();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Card(
      color: colores.errorContainer,
      child: ListTile(
        leading: Icon(Icons.shield_outlined, color: colores.onErrorContainer),
        title: Text(
          context.t.avisosAntiEstafa,
          style: TextStyle(color: colores.onErrorContainer),
        ),
      ),
    );
  }
}

class _TarjetaAviso extends ConsumerWidget {
  const _TarjetaAviso({required this.aviso});

  final Aviso aviso;

  Future<void> _cambiar(WidgetRef ref, EstadoAviso estado) async {
    await ref.read(avisosRepositorioProvider).cambiarEstado(aviso.id, estado);
    if (estado == EstadoAviso.respondido) {
      ref.read(metricasProvider).track(Eventos.alertReply);
    }
    ref.invalidate(avisosProvider);
  }

  Future<void> _reportarEstafa(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.avisosEstafaTitulo),
        content: Text(t.avisosEstafaExplicacion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.avisosEstafa),
          ),
        ],
      ),
    );
    if (confirmado ?? false) await _cambiar(ref, EstadoAviso.estafa);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    final mascota = mascotas.where((m) => m.id == aviso.mascotaId).firstOrNull;
    final whatsapp = telefonoInternacionalUy(aviso.contactoRemitente);
    final telefono = aviso.contactoRemitente.replaceAll(RegExp(r'[^0-9+]'), '');
    final esEstafa = aviso.estado == EstadoAviso.estafa;
    final fecha = DateFormat("d 'de' MMMM, HH:mm", 'es').format(aviso.creado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mascota == null
                        ? t.avisosDe(aviso.nombreRemitente)
                        : t.avisosSobre(mascota.nombre, aviso.nombreRemitente),
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                if (aviso.estado == EstadoAviso.nuevo)
                  Chip(label: Text(t.avisosNuevo)),
                PopupMenuButton<String>(
                  tooltip: t.avisosMasOpciones,
                  onSelected: (opcion) => switch (opcion) {
                    'respondido' => _cambiar(ref, EstadoAviso.respondido),
                    'estafa' => _reportarEstafa(context, ref),
                    _ =>
                      ref
                          .read(avisosRepositorioProvider)
                          .borrar(aviso.id)
                          .then((_) => ref.invalidate(avisosProvider)),
                  },
                  itemBuilder: (context) => [
                    if (aviso.estado != EstadoAviso.respondido && !esEstafa)
                      PopupMenuItem(
                        value: 'respondido',
                        child: Text(t.avisosYaContacte),
                      ),
                    if (!esEstafa)
                      PopupMenuItem(
                        value: 'estafa',
                        child: Text(t.avisosEstafa),
                      ),
                    PopupMenuItem(value: 'borrar', child: Text(t.borrar)),
                  ],
                ),
              ],
            ),
            Text(fecha, style: tema.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(aviso.mensaje, style: tema.textTheme.bodyLarge),
            const SizedBox(height: 8),
            if (esEstafa)
              Text(
                t.avisosMarcadoEstafa,
                style: TextStyle(color: tema.colorScheme.error),
              )
            else ...[
              Text(t.avisosContacto(aviso.contactoRemitente)),
              if (aviso.estado == EstadoAviso.respondido)
                Text(t.avisosRespondido, style: tema.textTheme.bodySmall),
              Wrap(
                spacing: 4,
                children: [
                  if (telefono.length >= 6)
                    TextButton.icon(
                      onPressed: () =>
                          launchUrl(Uri(scheme: 'tel', path: telefono)),
                      icon: const Icon(Icons.call_outlined),
                      label: Text(t.avisosLlamar),
                    ),
                  if (whatsapp != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.https('wa.me', '/$whatsapp'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(t.avisosWhatsapp),
                    ),
                  if (aviso.tieneUbicacion)
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.https('www.google.com', '/maps/search/', {
                          'api': '1',
                          'query': '${aviso.lat},${aviso.lng}',
                        }),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.place_outlined),
                      label: Text(t.avisosVerUbicacion),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
