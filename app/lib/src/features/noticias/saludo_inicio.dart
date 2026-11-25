import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../dos_apps/dos_apps.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';

/// Arriba del Inicio (D162). Con sesión: «¡Hola, …!» y las caritas de sus
/// mascotas (tocar una abre su ficha). Visitante: nada (la bienvenida es
/// una pantalla aparte que sale una sola vez, `BienvenidaScreen`).
class SaludoInicio extends ConsumerWidget {
  const SaludoInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // En Huellamy Comercios el Inicio es del negocio, no de las mascotas.
    if (ref.watch(esAppComercioProvider)) return const SizedBox.shrink();
    final usuario = ref.watch(usuarioActualProvider).value;
    if (usuario == null) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: _Hola(),
    );
  }
}

class _Hola extends ConsumerWidget {
  const _Hola();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final nombre = ref.watch(perfilProvider).value?.nombre.trim() ?? '';
    final mascotas = ref.watch(misMascotasProvider).value ?? const [];
    final iconos = {
      for (final e in ref.watch(especiesProvider).value ?? const <Especie>[])
        e.id: e,
    };
    final primerNombre = nombre.split(' ').first;
    return Card(
      key: const Key('saludo-inicio'),
      margin: EdgeInsets.zero,
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primerNombre.isEmpty
                  ? t.inicioHolaSinNombre
                  : t.inicioHola(primerNombre),
              style: tema.textTheme.titleLarge?.copyWith(
                color: tema.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final m in mascotas)
                    _Carita(
                      etiqueta: m.nombre,
                      onTap: () => context.push(Rutas.fichaMascota(m.id)),
                      child: FotoMascota(
                        ruta: m.fotoPath,
                        radio: 28,
                        icono: iconos[m.especieId]?.icono,
                      ),
                    ),
                  _Carita(
                    etiqueta: t.inicioSumarMascota,
                    onTap: () => context.push(Rutas.mascotaNueva),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: tema.colorScheme.surface,
                      child: Icon(
                        Icons.add_outlined,
                        color: tema.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carita extends StatelessWidget {
  const _Carita({
    required this.etiqueta,
    required this.onTap,
    required this.child,
  });

  final String etiqueta;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            child,
            const SizedBox(height: 4),
            Text(
              etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
