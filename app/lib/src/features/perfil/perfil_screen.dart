import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';
import '../../widgets/volver.dart';
import '../ajustes/ajustes_screen.dart';
import '../hogar/hogar_screen.dart';

/// "Mi perfil" (D70): quién soy en la app, qué mascotas tengo a cargo y con
/// quién comparto el cuidado. Solo lo ve la propia persona.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final usuario = ref.watch(usuarioActualProvider).value;
    final perfil = ref.watch(perfilProvider).value;
    final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    final integrantes =
        ref.watch(integrantesProvider).value ?? const <Integrante>[];
    final nombres = ref.watch(nombresDelHogarProvider);
    final yo = usuario?.id;
    final propias = mascotas.where((m) => m.esDe(yo)).toList();
    final compartidas = mascotas.where((m) => !m.esDe(yo)).toList();
    final otros = {
      for (final i in integrantes)
        if (i.usuarioId != yo) i.usuarioId: i,
    }.values.toList();
    final nombre = perfil?.nombre.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.perfilTitulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              child: Text(
                nombre.isEmpty ? '?' : nombre.characters.first.toUpperCase(),
                style: tema.textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // El nombre también se cambia desde acá, no solo en Ajustes (CU-05).
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (nombre.isNotEmpty)
                Flexible(
                  child: Text(nombre, style: tema.textTheme.headlineSmall),
                ),
              if (perfil != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: t.ajustesNombreTitulo,
                  onPressed: () => editarNombre(context, ref, perfil),
                ),
            ],
          ),
          if (usuario?.email case final email?)
            Center(child: Text(email, style: tema.textTheme.bodySmall)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(switch (perfil?.rol) {
                    RolCuenta.admin => t.perfilRolAdmin,
                    _ => t.perfilRolDueno,
                  }),
                  subtitle: Text(t.perfilRol),
                ),
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(switch (perfil?.plan) {
                    Plan.pro => t.perfilPlanPro,
                    Plan.family => t.perfilPlanFamilia,
                    _ => t.perfilPlanGratis,
                  }),
                  subtitle: Text(t.perfilPlan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t.perfilMascotas, style: tema.textTheme.titleMedium),
          if (mascotas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(t.perfilSinMascotas),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                [
                  if (propias.isNotEmpty) t.perfilPropias(propias.length),
                  if (compartidas.isNotEmpty)
                    t.perfilCompartidas(compartidas.length),
                ].join(' · '),
                style: tema.textTheme.bodySmall,
              ),
            ),
            for (final m in [...propias, ...compartidas])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: FotoMascota(ruta: m.fotoPath),
                title: Text(m.nombre),
                subtitle: m.esDe(yo)
                    ? null
                    : Text(switch (nombres[m.duenoId]) {
                        final n? => t.mascotaCompartidaDe(n),
                        null => t.mascotaCompartida,
                      }),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Rutas.fichaMascota(m.id)),
              ),
          ],
          const SizedBox(height: 16),
          Text(t.perfilCuidado, style: tema.textTheme.titleMedium),
          if (otros.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(t.perfilSinHogar),
            )
          else
            for (final i in otros)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(
                    nombreIntegrante(t, i).characters.first.toUpperCase(),
                  ),
                ),
                title: Text(nombreIntegrante(t, i)),
                subtitle: Text(switch (i.rol) {
                  RolHogar.owner => t.hogarCreador,
                  RolHogar.member => t.hogarIntegrante,
                  RolHogar.tempCaregiver => t.hogarCuidadorHasta(
                    i.accesoHasta == null
                        ? ''
                        : MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(i.accesoHasta!),
                  ),
                }),
              ),
          SiFuncionalidad(
            Funcionalidades.hogar,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => context.push(Rutas.hogar),
                icon: const Icon(Icons.family_restroom),
                label: Text(t.perfilVerHogar),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
