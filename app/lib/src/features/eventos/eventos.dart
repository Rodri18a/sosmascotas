import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../eventos/eventos_repositorio.dart';
import '../../fotos/elegir_foto.dart';
import '../../mapa/mapa_vista.dart';
import '../../metricas/metricas.dart';
import '../../sos/sos_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/volver.dart';
import '../adopcion/apadrinamiento_screen.dart';
import '../legal/legal_screen.dart';

String textoTipoEvento(AppLocalizations t, TipoEvento e) => switch (e) {
  TipoEvento.castracion => t.eventoCastracion,
  TipoEvento.adopcion => t.eventoAdopcion,
  TipoEvento.encuentro => t.eventoEncuentro,
  TipoEvento.otro => t.eventoOtro,
};

String textoFechas(BuildContext context, Evento e) {
  final l = MaterialLocalizations.of(context);
  String f(DateTime d) =>
      '${l.formatMediumDate(d)} ${l.formatTimeOfDay(TimeOfDay.fromDateTime(d), alwaysUse24HourFormat: true)}';
  return context.t.eventoCuando(f(e.desde), f(e.hasta));
}

/// Ficha de un evento (al tocar su pin o en Ayuda).
Future<void> mostrarEvento(BuildContext context, WidgetRef ref, Evento e) {
  ref.read(metricasProvider).track(Eventos.eventOpen, targetId: e.id);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final t = context.t;
      final tema = Theme.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(e.titulo, style: tema.textTheme.titleLarge),
              Text(textoTipoEvento(t, e.tipo)),
              const SizedBox(height: 8),
              Text(textoFechas(context, e)),
              if (e.enCurso(ref.read(relojProvider)()))
                Text(
                  t.eventoEnCurso,
                  style: TextStyle(color: tema.colorScheme.primary),
                ),
              if (e.organizador case final o?) Text(t.eventoOrganiza(o)),
              LineaPadrinos(eventoId: e.id),
              if (e.direccion case final d?) Text(d),
              if (e.descripcion case final d?) ...[
                const SizedBox(height: 8),
                Text(d),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => ref.read(abrirEnlaceProvider)(
                      Uri.https('www.google.com', '/maps/dir/', {
                        'api': '1',
                        'destination': '${e.punto.lat},${e.punto.lng}',
                      }),
                    ),
                    icon: const Icon(Icons.directions_outlined),
                    label: Text(t.comercioComoLlegar),
                  ),
                  if (e.enlace case final link?)
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(abrirEnlaceProvider)(Uri.parse(link)),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(t.eventoMasInfo),
                    ),
                  if (e.mio)
                    TextButton(
                      onPressed: () async {
                        final mensajes = ScaffoldMessenger.of(context);
                        await ref
                            .read(eventosRepositorioProvider)
                            .cancelar(e.id);
                        ref.invalidate(eventosCercanosProvider);
                        if (context.mounted) Navigator.pop(context);
                        mensajes.showSnackBar(
                          SnackBar(content: Text(t.eventoCancelado)),
                        );
                      },
                      child: Text(t.eventoCancelar),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Próximos eventos (sección de Ayuda).
class SeccionEventos extends ConsumerWidget {
  const SeccionEventos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final eventos =
        ref.watch(eventosCercanosProvider).value ?? const <Evento>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.eventosProximos, style: Theme.of(context).textTheme.titleMedium),
        if (eventos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(t.eventosVacio),
          ),
        for (final e in eventos.take(5))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_outlined),
            title: Text(e.titulo),
            subtitle: Text(textoFechas(context, e)),
            onTap: () => mostrarEvento(context, ref, e),
          ),
      ],
    );
  }
}

/// Publicar un evento (comercios y refugios verificados).
class EventoFormScreen extends ConsumerStatefulWidget {
  const EventoFormScreen({required this.comercioId, this.punto, super.key});

  final String comercioId;
  final Punto? punto;

  @override
  ConsumerState<EventoFormScreen> createState() => _EventoFormState();
}

class _EventoFormState extends ConsumerState<EventoFormScreen> {
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _direccion = TextEditingController();
  final _enlace = TextEditingController();
  var _tipo = TipoEvento.castracion;
  late Punto? _punto = widget.punto;
  late DateTime _desde;
  late DateTime _hasta;
  var _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final hoy = ref.read(relojProvider)();
    _desde = DateTime(hoy.year, hoy.month, hoy.day + 7, 10);
    _hasta = DateTime(hoy.year, hoy.month, hoy.day + 7, 17);
  }

  @override
  void dispose() {
    for (final c in [_titulo, _descripcion, _direccion, _enlace]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _elegir(DateTime inicial) async {
    final dia = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(inicial.year - 1),
      lastDate: DateTime(inicial.year + 2),
    );
    if (dia == null || !mounted) return null;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(inicial),
    );
    if (hora == null) return null;
    return DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);
  }

  Future<void> _publicar() async {
    final t = context.t;
    final punto = _punto;
    if (_titulo.text.trim().length < 3 ||
        punto == null ||
        !_hasta.isAfter(_desde)) {
      setState(() => _error = t.eventoDatos);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref.read(eventosRepositorioProvider).publicar({
        'business_id': widget.comercioId,
        'kind': _tipo.name,
        'title': _titulo.text.trim(),
        'description': _descripcion.text.trim(),
        'starts_at': _desde.toUtc().toIso8601String(),
        'ends_at': _hasta.toUtc().toIso8601String(),
        'lat': punto.lat,
        'lng': punto.lng,
        'address': _direccion.text.trim(),
        'link': _enlace.text.trim().isEmpty ? null : _enlace.text.trim(),
      });
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.eventPublish, props: {'tipo': _tipo.name})
        ..invalidate(eventosCercanosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.eventoPublicado)));
      context.pop();
    } on Exception {
      setState(() => _error = t.eventoDatos);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    String f(DateTime d) =>
        '${l.formatMediumDate(d)} ${l.formatTimeOfDay(TimeOfDay.fromDateTime(d), alwaysUse24HourFormat: true)}';
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.eventoPublicar),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.eventoSoloVerificados, style: tema.textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final e in TipoEvento.values)
                  ChoiceChip(
                    label: Text(textoTipoEvento(t, e)),
                    selected: e == _tipo,
                    onSelected: (_) => setState(() => _tipo = e),
                  ),
              ],
            ),
            TextField(
              controller: _titulo,
              maxLength: 80,
              decoration: InputDecoration(labelText: t.eventoTitulo),
            ),
            TextField(
              controller: _descripcion,
              maxLength: 1000,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.eventoDescripcion),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.eventoDesde),
              subtitle: Text(f(_desde)),
              onTap: () async {
                final d = await _elegir(_desde);
                if (d != null) setState(() => _desde = d);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.eventoHasta),
              subtitle: Text(f(_hasta)),
              onTap: () async {
                final d = await _elegir(_hasta);
                if (d != null) setState(() => _hasta = d);
              },
            ),
            Text(t.eventoLugar),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MapaVista(
                  centro: _punto ?? ref.watch(miZonaProvider),
                  zoom: 15,
                  seleccion: _punto,
                  onTocarMapa: (p) => setState(() => _punto = p),
                ),
              ),
            ),
            TextField(
              controller: _direccion,
              decoration: InputDecoration(labelText: t.eventoDireccion),
            ),
            TextField(
              controller: _enlace,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: t.eventoEnlace),
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enviando ? null : _publicar,
              child: Text(t.eventoPublicar),
            ),
          ],
        ),
      ),
    );
  }
}

/// Denunciar maltrato (2.7): privada (la ve el equipo) y con la información
/// de a quién recurrir. No reemplaza la denuncia oficial.
class DenunciaScreen extends ConsumerStatefulWidget {
  const DenunciaScreen({super.key});

  @override
  ConsumerState<DenunciaScreen> createState() => _DenunciaState();
}

class _DenunciaState extends ConsumerState<DenunciaScreen> {
  final _descripcion = TextEditingController();
  final _direccion = TextEditingController();
  final _fotos = <String>[];
  Punto? _punto;
  var _enviando = false;
  String? _error;

  @override
  void dispose() {
    _descripcion.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _foto() async {
    final original = await elegirFoto(context, ref);
    if (original == null) return;
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    final ruta = await ref
        .read(eventosRepositorioProvider)
        .subirFotoDenuncia(preparada);
    setState(() => _fotos.add(ruta));
  }

  Future<void> _enviar() async {
    final t = context.t;
    if (_descripcion.text.trim().length < 10) {
      setState(() => _error = t.denunciaDescripcionCorta);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref
          .read(eventosRepositorioProvider)
          .denunciar(
            _descripcion.text.trim(),
            punto: _punto,
            direccion: _direccion.text.trim().isEmpty
                ? null
                : _direccion.text.trim(),
            fotos: _fotos,
          );
      ref
        ..read(metricasProvider).track(Eventos.abuseReport)
        ..invalidate(misDenunciasProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.denunciaEnviada)));
      context.pop();
    } on Exception catch (e) {
      setState(
        () => _error = e.toString().contains('54000')
            ? t.denunciaDemasiadas
            : t.errorSinConexion,
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final mias = ref.watch(misDenunciasProvider).value ?? const <Denuncia>[];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.denunciaTitulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: 150,
                  child: TextoMarkdown(t.denunciaInfo),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcion,
              maxLength: 2000,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: t.denunciaDescripcion),
            ),
            Text(t.denunciaUbicacion),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MapaVista(
                  centro: _punto ?? ref.watch(miZonaProvider),
                  zoom: 14,
                  seleccion: _punto,
                  onTocarMapa: (p) => setState(() => _punto = p),
                ),
              ),
            ),
            TextField(
              controller: _direccion,
              decoration: InputDecoration(labelText: t.denunciaDireccion),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final _ in _fotos) const Chip(label: Icon(Icons.photo)),
                if (_fotos.length < 6)
                  ActionChip(
                    avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(t.denunciaFoto),
                    onPressed: _foto,
                  ),
              ],
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: Text(t.denunciaEnviar),
            ),
            if (mias.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(t.denunciaMias, style: tema.textTheme.titleMedium),
              for (final d in mias)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    d.descripcion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(switch (d.estado) {
                    EstadoDenuncia.nueva => t.denunciaNueva,
                    EstadoDenuncia.derivada => t.denunciaDerivada,
                    EstadoDenuncia.cerrada => t.denunciaCerrada,
                  }),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
