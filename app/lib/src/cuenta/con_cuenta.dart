import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../router.dart';
import 'servicio_cuenta.dart';

/// Abre [destino] si hay sesión. Si es visitante, explica por qué necesita una
/// cuenta ([motivo]) y, si acepta, lo lleva a ingresar y después a [destino].
Future<void> abrirConCuenta(
  BuildContext context,
  WidgetRef ref, {
  required String destino,
  required String motivo,
}) async {
  if (ref.read(conectadoProvider)) {
    await context.push(destino);
    return;
  }
  final ingresar = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    // Toma la altura que necesite (pantallas bajas o letra grande).
    isScrollControlled: true,
    builder: (context) => _PedirCuenta(motivo: motivo),
  );
  if ((ingresar ?? false) && context.mounted) {
    await context.push(Rutas.ingresarYVolverA(destino));
  }
}

class _PedirCuenta extends StatelessWidget {
  const _PedirCuenta({required this.motivo});

  final String motivo;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.cuentaNecesariaTitulo, style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(motivo, style: tema.textTheme.bodyLarge),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.ingresarOCrearCuenta),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.ahoraNo),
            ),
          ],
        ),
      ),
    );
  }
}
