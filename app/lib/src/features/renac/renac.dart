import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/volver.dart';
import '../legal/legal_screen.dart';

/// Consulta pública oficial del RENAC. Solo se enlaza: no se automatizan
/// consultas (06 · RENAC, D33).
final consultaRenac = Uri.parse(
  'https://www.snig.gub.uy/renac/animalciainfoext.aspx',
);

/// Registra la métrica (sin datos de la mascota) y abre la consulta oficial.
void verificarEnRenac(WidgetRef ref) {
  ref.read(metricasProvider).track(Eventos.renacVerifyClick);
  ref.read(abrirEnlaceProvider)(consultaRenac);
}

/// Estado RENAC en la ficha (1.5.2b, D96): lo declara el dueño. Si no está
/// registrada (o no se sabe), funciona de recordatorio con la guía.
class TarjetaRenac extends ConsumerStatefulWidget {
  const TarjetaRenac({
    required this.mascota,
    required this.slugEspecie,
    super.key,
  });

  final Mascota mascota;
  final String? slugEspecie;

  @override
  ConsumerState<TarjetaRenac> createState() => _TarjetaRenacState();
}

class _TarjetaRenacState extends ConsumerState<TarjetaRenac> {
  bool _guardando = false;

  Future<void> _marcarRegistrada() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    try {
      await ref
          .read(mascotasRepositorioProvider)
          .actualizar(widget.mascota.copyWith(renac: EstadoRenac.registered));
      ref
          .read(metricasProvider)
          .track(
            Eventos.renacStatusSet,
            props: {'estado': EstadoRenac.registered.valor},
          );
      ref.invalidate(misMascotasProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.renacGuardado)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final mascota = widget.mascota;
    final estado = mascota.renac;
    final avisar = avisarRenac(
      mascota,
      slugEspecie: widget.slugEspecie,
      hoy: ref.watch(relojProvider)(),
    );
    final registrada = estado == EstadoRenac.registered;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  registrada ? Icons.verified_outlined : Icons.badge_outlined,
                  color: avisar ? tema.colorScheme.error : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(switch (estado) {
                    EstadoRenac.registered => t.renacRegistrada,
                    EstadoRenac.notRegistered => t.renacNoRegistrada,
                    EstadoRenac.unknown => t.renacNoSabe,
                    null => t.renacSinResponder,
                  }, style: tema.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              registrada
                  ? t.renacDeclarado
                  : avisar
                  ? t.renacAviso(mascota.nombre)
                  : t.renacCachorro,
              style: tema.textTheme.bodySmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                if (!registrada) ...[
                  TextButton(
                    onPressed: () => context.push(Rutas.guiaRenac),
                    child: Text(t.renacComoRegistrar),
                  ),
                  TextButton(
                    onPressed: _guardando ? null : _marcarRegistrada,
                    child: Text(t.renacYaLaRegistre),
                  ),
                ],
                TextButton(
                  onPressed: () => verificarEnRenac(ref),
                  child: Text(t.renacVerificar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Guía "Cómo registrar a tu mascota" (1.5.2b): texto orientativo, el mapa con
/// las veterinarias "Operador RENAC" y la consulta oficial.
class GuiaRenacScreen extends ConsumerStatefulWidget {
  const GuiaRenacScreen({super.key});

  @override
  ConsumerState<GuiaRenacScreen> createState() => _GuiaRenacScreenState();
}

class _GuiaRenacScreenState extends ConsumerState<GuiaRenacScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(metricasProvider).track(Eventos.renacGuideOpen);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.renacGuiaTitulo),
      ),
      body: Column(
        children: [
          Expanded(child: TextoMarkdown(t.renacGuiaTexto)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(Rutas.mapaColocaMicrochip),
                    icon: const Icon(Icons.local_hospital_outlined),
                    label: Text(t.renacVerVeterinarias),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => verificarEnRenac(ref),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: Text(t.renacVerificar),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.renacVerificarAyuda,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
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
