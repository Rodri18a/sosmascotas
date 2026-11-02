import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../mascotas/transferencias_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';

String _textoError(AppLocalizations t, Object e) => switch (e) {
  TransferenciaException(motivo: ErrorTransferencia.sosAbierto) =>
    t.pasarSosAbierto,
  TransferenciaException(motivo: ErrorTransferencia.codigoInvalido) =>
    t.pasarCodigoInvalido,
  _ => t.errorSinConexion,
};

/// «Pasar a otra persona» en la ficha (2.2, D132): solo el dueño.
class TarjetaPasarMascota extends StatelessWidget {
  const TarjetaPasarMascota({required this.mascota, super.key});

  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.swap_horiz_outlined),
        title: Text(t.pasarTitulo),
        subtitle: Text(t.pasarSubtitulo),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _HojaPasar(mascota: mascota),
        ),
      ),
    );
  }
}

class _HojaPasar extends ConsumerStatefulWidget {
  const _HojaPasar({required this.mascota});

  final Mascota mascota;

  @override
  ConsumerState<_HojaPasar> createState() => _HojaPasarState();
}

class _HojaPasarState extends ConsumerState<_HojaPasar> {
  var _ocupado = false;
  String? _error;

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
      ref.invalidate(codigoAbiertoProvider(widget.mascota.id));
    } on Exception catch (e) {
      if (mounted) setState(() => _error = _textoError(context.t, e));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _generar() => _hacer(() async {
    await ref.read(transferenciasRepositorioProvider).crear(widget.mascota.id);
    ref.read(metricasProvider).track(Eventos.petTransferCreate);
  });

  Future<void> _cancelar() => _hacer(
    () =>
        ref.read(transferenciasRepositorioProvider).cancelar(widget.mascota.id),
  );

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    final abierto = ref.watch(codigoAbiertoProvider(widget.mascota.id));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.pasarHojaTitulo(widget.mascota.nombre),
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(t.pasarExplicacion),
            const SizedBox(height: 16),
            switch (abierto) {
              AsyncData(value: final c?) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    c.codigo,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    t.pasarVence(fechas.formatMediumDate(c.vence)),
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final mensajes = ScaffoldMessenger.of(context);
                      final copiado = t.pasarCopiado;
                      await Clipboard.setData(
                        ClipboardData(
                          text: t.pasarMensaje(widget.mascota.nombre, c.codigo),
                        ),
                      );
                      mensajes.showSnackBar(SnackBar(content: Text(copiado)));
                    },
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(t.pasarCopiar),
                  ),
                  TextButton(
                    onPressed: _ocupado ? null : _cancelar,
                    child: Text(t.pasarCancelar),
                  ),
                ],
              ),
              AsyncData() => FilledButton.icon(
                onPressed: _ocupado ? null : _generar,
                icon: const Icon(Icons.key_outlined),
                label: Text(t.pasarGenerar),
              ),
              AsyncError() => Text(t.errorSinConexion),
              _ => const Center(child: CircularProgressIndicator()),
            },
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

/// «Tengo un código»: recibir una mascota que me pasaron (D132).
Future<void> recibirMascota(BuildContext context, WidgetRef ref) async {
  final mascotaId = await showDialog<String>(
    context: context,
    builder: (_) => const _DialogoRecibir(),
  );
  if (mascotaId == null || !context.mounted) return;
  ref.invalidate(misMascotasProvider);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.t.pasarRecibida)));
  await context.push(Rutas.fichaMascota(mascotaId));
}

class _DialogoRecibir extends ConsumerStatefulWidget {
  const _DialogoRecibir();

  @override
  ConsumerState<_DialogoRecibir> createState() => _DialogoRecibirState();
}

class _DialogoRecibirState extends ConsumerState<_DialogoRecibir> {
  final _codigo = TextEditingController();
  VistaTransferencia? _vista;
  var _ocupado = false;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final vista = await ref
          .read(transferenciasRepositorioProvider)
          .ver(_codigo.text);
      if (!mounted) return;
      setState(() {
        _vista = vista;
        if (vista == null) _error = context.t.pasarCodigoInvalido;
      });
    } on Exception catch (e) {
      if (mounted) setState(() => _error = _textoError(context.t, e));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _aceptar() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(transferenciasRepositorioProvider)
          .aceptar(_codigo.text);
      ref.read(metricasProvider).track(Eventos.petTransferAccept);
      if (mounted) Navigator.pop(context, id);
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _ocupado = false;
          _error = _textoError(context.t, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final vista = _vista;
    final especie = vista == null
        ? null
        : (ref.watch(especiesProvider).value ?? const <Especie>[])
              .where((e) => e.id == vista.especieId)
              .firstOrNull;
    return AlertDialog(
      title: Text(t.pasarRecibirTitulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vista == null) ...[
            Text(t.pasarRecibirExplicacion),
            const SizedBox(height: 8),
            TextField(
              controller: _codigo,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              decoration: InputDecoration(labelText: t.pasarCodigo),
              onSubmitted: (_) => _buscar(),
            ),
          ] else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: FotoMascota(ruta: vista.fotoPath, icono: especie?.icono),
              title: Text(vista.nombre),
              subtitle: Text(t.pasarRecibirConfirmar),
            ),
          if (_error case final e?)
            Text(e, style: TextStyle(color: tema.colorScheme.error)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _ocupado
              ? null
              : vista == null
              ? _buscar
              : _aceptar,
          child: Text(vista == null ? t.pasarBuscar : t.pasarAceptar),
        ),
      ],
    );
  }
}
