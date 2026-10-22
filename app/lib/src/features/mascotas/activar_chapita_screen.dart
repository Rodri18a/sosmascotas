import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../router.dart';
import '../../widgets/volver.dart';
import 'qr_mascota_screen.dart';

/// `/activar/<código>` (1.8b.2, D95): adonde lleva la página de una chapita
/// sin activar. El dueño elige la mascota que la va a llevar.
class ActivarChapitaScreen extends ConsumerStatefulWidget {
  const ActivarChapitaScreen({required this.codigo, super.key});

  final String codigo;

  @override
  ConsumerState<ActivarChapitaScreen> createState() =>
      _ActivarChapitaScreenState();
}

class _ActivarChapitaScreenState extends ConsumerState<ActivarChapitaScreen> {
  String? _elegida;
  String? _error;
  bool _activando = false;

  Future<void> _activar(String codigo, Mascota mascota) async {
    final t = context.t;
    setState(() {
      _activando = true;
      _error = null;
    });
    final error = await activarChapita(
      ref,
      codigo: codigo,
      mascotaId: mascota.id,
      origen: 'enlace',
    );
    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.chapitaActivada(mascota.nombre))),
      );
      context.go(Rutas.qrMascota(mascota.id));
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
    final tema = Theme.of(context);
    final codigo = codigoChapita(widget.codigo);
    final yo = ref.watch(usuarioActualProvider).value?.id;
    final mascotas = ref.watch(misMascotasProvider);
    // Solo las propias: activar es del dueño, no del hogar (D69).
    final propias = [
      for (final m in mascotas.value ?? const <Mascota>[])
        if (m.esDe(yo)) m,
    ];
    final elegida =
        propias.where((m) => m.id == _elegida).firstOrNull ??
        (propias.length == 1 ? propias.single : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.activarChapitaTitulo),
        leading: volverSiNoHayAtras(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.qr_code_2, size: 64),
          if (codigo != null)
            Center(
              child: Text(
                codigo,
                style: tema.textTheme.titleLarge?.copyWith(letterSpacing: 4),
              ),
            ),
          const SizedBox(height: 16),
          if (codigo == null)
            Text(
              t.chapitaCodigoInvalido,
              style: TextStyle(color: tema.colorScheme.error),
            )
          else if (mascotas.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (mascotas.hasError && !mascotas.hasValue)
            Text(t.errorSinConexion)
          else if (propias.isEmpty) ...[
            Text(t.activarChapitaSinMascotas),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go(Rutas.mascotaNueva),
              icon: const Icon(Icons.add),
              label: Text(t.mascotasAgregar),
            ),
          ] else ...[
            Text(t.activarChapitaTexto),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: elegida?.id,
              onChanged: (id) => setState(() => _elegida = id),
              child: Column(
                children: [
                  for (final m in propias)
                    RadioListTile<String>(value: m.id, title: Text(m.nombre)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: elegida == null || _activando
                  ? null
                  : () => _activar(codigo, elegida),
              child: Text(t.activarChapitaBoton),
            ),
          ],
          if (_error case final error?) ...[
            const SizedBox(height: 12),
            Text(error, style: TextStyle(color: tema.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
