import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'pantallas/ayuda.dart';
import 'pantallas/chapitas.dart';
import 'pantallas/comercios.dart';
import 'pantallas/denuncias.dart';
import 'pantallas/equipo.dart';
import 'pantallas/grupos.dart';
import 'pantallas/ingreso.dart';
import 'pantallas/lugares.dart';
import 'pantallas/moderacion.dart';
import 'pantallas/noticias.dart';
import 'pantallas/panel.dart';
import 'pantallas/planes.dart';
import 'pantallas/propuestas.dart';
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
    // El mismo tema que la app: paleta y tipografías de la guía de marca
    // (D122, D125).
    theme: AppTheme.claro,
    darkTheme: AppTheme.oscuro,
    home: const _Puerta(),
  );
}

/// Sin sesión: ingresar. Con sesión pero sin rol del equipo: no hay nada que
/// ver (y la base igual rechazaría cada consulta).
class _Puerta extends ConsumerWidget {
  const _Puerta();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(correoProvider);
    return switch (correo) {
      AsyncData(value: null) => const IngresoScreen(),
      AsyncData() => switch (ref.watch(rolEquipoProvider)) {
        AsyncData(value: final String rol) => Portal(rol: rol),
        AsyncData() => const _SinPermiso(),
        AsyncError() => _Error(
          onReintentar: () => ref.invalidate(rolEquipoProvider),
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

/// Las secciones del portal (05-portal-admin.md). Cada rol ve las suyas
/// (3.6, D109): moderación y denuncias, o lugares, prospectos y propuestas;
/// la administración, todas.
class Portal extends ConsumerStatefulWidget {
  const Portal({this.rol = 'admin', super.key});

  final String rol;

  @override
  ConsumerState<Portal> createState() => _PortalState();
}

class _PortalState extends ConsumerState<Portal> {
  var _seccion = 0;

  /// (ícono, título, pantalla, roles además de `admin`).
  static const _todas = <(IconData, String, Widget, Set<String>)>[
    (Icons.dashboard_outlined, T.panel, PanelScreen(), {}),
    (Icons.shield_outlined, T.moderacion, ModeracionScreen(), {'moderator'}),
    (Icons.report_outlined, T.denuncias, DenunciasScreen(), {'moderator'}),
    (Icons.forum_outlined, T.grupos, GruposScreen(), {'moderator'}),
    (Icons.storefront_outlined, T.lugares, LugaresScreen(), {'sales'}),
    (Icons.verified_outlined, T.comercios, ComerciosScreen(), {}),
    (Icons.handshake_outlined, T.prospectos, ProspectosScreen(), {'sales'}),
    (Icons.description_outlined, T.propuestas, PropuestasScreen(), {'sales'}),
    (Icons.payments_outlined, T.planesCobros, PlanesScreen(), {}),
    (Icons.volunteer_activism_outlined, T.ayuda, AyudaScreen(), {}),
    (Icons.newspaper_outlined, T.noticias, NoticiasScreen(), {}),
    (Icons.qr_code_2, T.chapitas, ChapitasScreen(), {}),
    (Icons.groups_outlined, T.equipo, EquipoScreen(), {}),
    (Icons.map_outlined, T.zonas, ZonasScreen(), {}),
    (Icons.history, T.auditoria, AuditoriaScreen(), {}),
  ];

  late final _secciones = [
    for (final s in _todas)
      if (widget.rol == 'admin' || s.$4.contains(widget.rol))
        (s.$1, s.$2, s.$3),
  ];

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width >= 800;
    final seccion = _secciones[_seccion].$3;
    // Moderación y ventas ven solo lo de sus zonas (D110): se lo recuerda.
    final contenido = widget.rol == 'admin'
        ? seccion
        : Column(
            children: [
              switch (ref.watch(misZonasProvider)) {
                AsyncData(value: final zonas?) => _AvisoZonas(zonas),
                _ => const SizedBox.shrink(),
              },
              Expanded(child: seccion),
            ],
          );
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Isotipo(tinta: context.marca.sobreBarra),
        ),
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
                // Con muchas secciones, el menú se desplaza en pantallas bajas.
                LayoutBuilder(
                  builder: (context, lugar) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: lugar.maxHeight),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          selectedIndex: _seccion,
                          labelType: NavigationRailLabelType.all,
                          onDestinationSelected: (i) =>
                              setState(() => _seccion = i),
                          destinations: [
                            for (final (icono, texto, _) in _secciones)
                              NavigationRailDestination(
                                icon: Icon(icono),
                                label: Text(texto),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                for (final (icono, texto, _) in _secciones)
                  NavigationDestination(icon: Icon(icono), label: texto),
              ],
            ),
    );
  }
}

class _AvisoZonas extends StatelessWidget {
  const _AvisoZonas(this.zonas);

  final List<String> zonas;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Material(
      color: zonas.isEmpty
          ? colores.errorContainer
          : colores.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(zonas.isEmpty ? T.sinTusZonas : T.tusZonas(zonas)),
            ),
          ],
        ),
      ),
    );
  }
}
