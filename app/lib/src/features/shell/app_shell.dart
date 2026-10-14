import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Estructura con la barra inferior. Cada pestaña conserva su estado al cambiar.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      // Tocar la pestaña activa vuelve a su pantalla inicial.
      onDestinationSelected: (indice) => navigationShell.goBranch(
        indice,
        initialLocation: indice == navigationShell.currentIndex,
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(icon: Icon(Icons.sos), label: 'SOS'),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'Mis mascotas',
        ),
        NavigationDestination(
          icon: Icon(Icons.health_and_safety_outlined),
          selectedIcon: Icon(Icons.health_and_safety),
          label: 'Ayuda',
        ),
      ],
    ),
  );
}
