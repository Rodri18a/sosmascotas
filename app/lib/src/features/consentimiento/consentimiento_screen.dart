import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../legal/legal.dart';
import '../../metricas/metricas.dart';
import '../../redireccion.dart';
import '../../router.dart';

/// Consentimiento informado (Ley 18.331): se pide al crear la cuenta y cada vez
/// que cambia la versión de los términos. Sin aceptar no se puede seguir.
class ConsentimientoScreen extends ConsumerStatefulWidget {
  const ConsentimientoScreen({this.volver, super.key});

  final String? volver;

  @override
  ConsumerState<ConsentimientoScreen> createState() =>
      _ConsentimientoScreenState();
}

class _ConsentimientoScreenState extends ConsumerState<ConsentimientoScreen> {
  bool _acepto = false;
  bool _ocupado = false;
  bool _error = false;

  Future<void> _aceptar() async {
    final usuario = ref.read(usuarioActualProvider).value;
    if (usuario == null) return;
    final esNueva = ref.read(perfilProvider).value?.terminosAceptadosEn == null;
    setState(() {
      _ocupado = true;
      _error = false;
    });
    try {
      await ref
          .read(perfilRepositorioProvider)
          .aceptarTerminos(usuario.id, versionTerminos);
      if (esNueva) ref.read(metricasProvider).track(Eventos.signup);
      ref.invalidate(perfilProvider);
      await ref.read(perfilProvider.future);
      if (mounted) context.go(volverSeguro(widget.volver));
    } on Exception {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.consentimientoTitulo),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  t.consentimientoExplicacion,
                  style: tema.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                for (final (icono, texto) in [
                  (Icons.phone_disabled_outlined, t.consentimientoTelefono),
                  (
                    Icons.location_searching_outlined,
                    t.consentimientoUbicacion,
                  ),
                  (Icons.query_stats_outlined, t.consentimientoMetricas),
                  (Icons.delete_outline, t.consentimientoBorrar),
                ])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(icono, color: tema.colorScheme.primary),
                    title: Text(texto),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => context.push(Rutas.terminos),
                      child: Text(t.legalTerminos),
                    ),
                    TextButton(
                      onPressed: () => context.push(Rutas.privacidad),
                      child: Text(t.legalPrivacidad),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _acepto,
                  onChanged: _ocupado
                      ? null
                      : (v) => setState(() => _acepto = v ?? false),
                  title: Text(t.consentimientoCasilla),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _acepto && !_ocupado ? _aceptar : null,
                  child: Text(t.consentimientoAceptar),
                ),
                TextButton(
                  onPressed: _ocupado
                      ? null
                      : () => ref.read(servicioCuentaProvider).salir(),
                  child: Text(t.consentimientoNoAcepto),
                ),
                if (_error)
                  Text(
                    t.errorSinConexion,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
