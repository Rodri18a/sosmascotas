import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../mascotas/enlaces_historial_repositorio.dart';
import '../../metricas/metricas.dart';

/// «Compartir historial» en la ficha (2.2, D133): un enlace de solo lectura
/// que vence, para la veterinaria o un cuidador. Solo el dueño.
class TarjetaCompartirHistorial extends StatelessWidget {
  const TarjetaCompartirHistorial({required this.mascota, super.key});

  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.share_outlined),
        title: Text(t.compartirHistorialTitulo),
        subtitle: Text(t.compartirHistorialSubtitulo),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _HojaCompartir(mascota: mascota),
        ),
      ),
    );
  }
}

class _HojaCompartir extends ConsumerStatefulWidget {
  const _HojaCompartir({required this.mascota});

  final Mascota mascota;

  @override
  ConsumerState<_HojaCompartir> createState() => _HojaCompartirState();
}

class _HojaCompartirState extends ConsumerState<_HojaCompartir> {
  var _dias = 7;
  var _ocupado = false;
  String? _error;

  String _url(String token) =>
      urlHistorialCompartido(token, base: ref.read(appEnvProvider).urlPublica);

  Future<void> _copiar(String token) async {
    final mensajes = ScaffoldMessenger.of(context);
    final copiado = context.t.compartirHistorialCopiado;
    await Clipboard.setData(ClipboardData(text: _url(token)));
    mensajes.showSnackBar(SnackBar(content: Text(copiado)));
  }

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
      ref.invalidate(enlacesHistorialProvider(widget.mascota.id));
    } on Exception {
      if (mounted) setState(() => _error = context.t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _crear() => _hacer(() async {
    final token = await ref
        .read(enlacesHistorialRepositorioProvider)
        .crear(widget.mascota.id, _dias);
    ref
        .read(metricasProvider)
        .track(Eventos.historyShareCreate, props: {'days': _dias});
    await _copiar(token);
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    final enlaces = ref.watch(enlacesHistorialProvider(widget.mascota.id));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.compartirHistorialHoja(widget.mascota.nombre),
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(t.compartirHistorialExplicacion),
            const SizedBox(height: 16),
            Text(
              t.compartirHistorialDuracion,
              style: tema.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (final d in const [1, 7, 30])
                  ButtonSegment(
                    value: d,
                    label: Text(t.compartirHistorialDias(d)),
                  ),
              ],
              selected: {_dias},
              onSelectionChanged: (s) => setState(() => _dias = s.first),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _ocupado ? null : _crear,
              icon: const Icon(Icons.link_outlined),
              label: Text(t.compartirHistorialCrear),
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            if (enlaces case AsyncData(
              value: final lista,
            ) when lista.isNotEmpty) ...[
              Text(
                t.compartirHistorialVigentes,
                style: tema.textTheme.titleSmall,
              ),
              for (final e in lista)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.link_outlined),
                  title: Text(
                    t.compartirHistorialVence(fechas.formatMediumDate(e.vence)),
                  ),
                  subtitle: Text(t.compartirHistorialVistas(e.vistas)),
                  onTap: () => _copiar(e.token),
                  trailing: TextButton(
                    onPressed: _ocupado
                        ? null
                        : () => _hacer(
                            () => ref
                                .read(enlacesHistorialRepositorioProvider)
                                .cortar(e.id),
                          ),
                    child: Text(t.compartirHistorialCortar),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
