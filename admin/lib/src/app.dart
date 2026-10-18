import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pantallas/ayuda.dart';
import 'pantallas/comercios.dart';
import 'pantallas/ingreso.dart';
import 'pantallas/lugares.dart';
import 'pantallas/moderacion.dart';
import 'pantallas/panel.dart';
import 'pantallas/prospectos.dart';
import 'repositorio.dart';
import 'sesion.dart';
import 'textos.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: T.titulo,
    debugShowCheckedModeBanner: false,
    locale: const Locale('es', 'UY'),
    supportedLocales: const [Locale('es', 'UY'), Locale('es')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF0F5E7A),
      useMaterial3: true,
    ),
    home: const _Puerta(),
  );
}

/// Sin sesión: ingresar. Con sesión pero sin rol admin: no hay nada que ver
/// (y la base igual rechazaría cada consulta).
class _Puerta extends ConsumerWidget {
  const _Puerta();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(correoProvider);
    return switch (correo) {
      AsyncData(value: null) => const IngresoScreen(),
      AsyncData() => switch (ref.watch(esAdminProvider)) {
        AsyncData(value: true) => const Portal(),
        AsyncData(value: false) => const _SinPermiso(),
        AsyncError() => _Error(
          onReintentar: () => ref.invalidate(esAdminProvider),
        ),
        _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
      },
      AsyncError() => const IngresoScreen(),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _SinPermiso extends ConsumerWidget {
  const _SinPermiso();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            const Text(T.sinPermiso, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.read(sesionProvider).salir(),
              child: const Text(T.salir),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.onReintentar});

  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(T.errorConexion),
          TextButton(onPressed: onReintentar, child: const Text(T.reintentar)),
        ],
      ),
    ),
  );
}

/// Las secciones del portal v1 (05-portal-admin.md).
class Portal extends ConsumerStatefulWidget {
  const Portal({super.key});

  @override
  ConsumerState<Portal> createState() => _PortalState();
}

class _PortalState extends ConsumerState<Portal> {
  var _seccion = 0;

  static const _secciones = [
    (Icons.dashboard_outlined, T.panel),
    (Icons.shield_outlined, T.moderacion),
    (Icons.storefront_outlined, T.lugares),
    (Icons.verified_outlined, T.comercios),
    (Icons.handshake_outlined, T.prospectos),
    (Icons.volunteer_activism_outlined, T.ayuda),
  ];

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width >= 800;
    final contenido = switch (_seccion) {
      0 => const PanelScreen(),
      1 => const ModeracionScreen(),
      2 => const LugaresScreen(),
      3 => const ComerciosScreen(),
      4 => const ProspectosScreen(),
      _ => const AyudaScreen(),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(_secciones[_seccion].$2),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text(ref.watch(correoProvider).value ?? '')),
          ),
          IconButton(
            tooltip: T.salir,
            onPressed: () => ref.read(sesionProvider).salir(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ancho
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _seccion,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (i) => setState(() => _seccion = i),
                  destinations: [
                    for (final (icono, texto) in _secciones)
                      NavigationRailDestination(
                        icon: Icon(icono),
                        label: Text(texto),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: contenido),
              ],
            )
          : contenido,
      bottomNavigationBar: ancho
          ? null
          : NavigationBar(
              selectedIndex: _seccion,
              onDestinationSelected: (i) => setState(() => _seccion = i),
              destinations: [
                for (final (icono, texto) in _secciones)
                  NavigationDestination(icon: Icon(icono), label: texto),
              ],
            ),
    );
  }
}
