import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/ilustracion.dart';

const _claveVista = 'bienvenida.vista';

/// Si este dispositivo ya vio la bienvenida.
bool bienvenidaVista(SharedPreferences prefs) =>
    prefs.getBool(_claveVista) ?? false;

/// Bienvenida de la primera vez, a pantalla completa: Ami y Mishi, qué es
/// Huellamy y dos caminos (crear cuenta o mirar sin cuenta). Sale una sola
/// vez: se marca vista apenas se muestra. Antes estaba arriba del Inicio de
/// los visitantes y ocupaba mucho lugar.
class BienvenidaScreen extends ConsumerStatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  ConsumerState<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends ConsumerState<BienvenidaScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(metricasProvider).track(Eventos.welcomeView);
    SharedPreferences.getInstance().then(
      (p) => p.setBool(_claveVista, true),
      onError: (Object e) => debugPrint('No se pudo guardar la bienvenida: $e'),
    );
  }

  void _seguir({required bool conCuenta}) {
    ref
        .read(metricasProvider)
        .track(conCuenta ? Eventos.welcomeSignup : Eventos.welcomeSkip);
    final router = GoRouter.of(context)..go(Rutas.inicio);
    if (conCuenta) router.push(Rutas.ingresarYVolverA(Rutas.inicio));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      key: const Key('bienvenida'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ImagenIlustracion(Ilustracion.bienvenida, alto: 220),
                  const SizedBox(height: 24),
                  Text(
                    t.inicioBienvenidaTitulo,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      color: tema.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.inicioBienvenidaTexto,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.inicioBienvenidaAyuda,
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => _seguir(conCuenta: true),
                    child: Text(t.inicioBienvenidaCuenta),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _seguir(conCuenta: false),
                    child: Text(t.inicioBienvenidaSinCuenta),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
