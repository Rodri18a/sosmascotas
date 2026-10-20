import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascota_activa.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../mascotas/textos_mascota.dart';
import '../../router.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/boton_mensajes.dart';
import '../../widgets/en_construccion.dart';
import '../../widgets/foto_mascota.dart';
import '../menu/menu_principal.dart';

class MascotasScreen extends ConsumerWidget {
  const MascotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final conectado = ref.watch(conectadoProvider);
    final mascotas = ref.watch(misMascotasProvider);

    Widget agregar() => FilledButton.icon(
      onPressed: () => abrirConCuenta(
        context,
        ref,
        destino: Rutas.mascotaNueva,
        motivo: t.mascotasMotivoCuenta,
      ),
      icon: const Icon(Icons.add),
      label: Text(t.mascotasAgregar),
    );

    final cuerpo = switch (mascotas) {
      _ when !conectado => EnConstruccion.vacio(
        icono: Icons.pets,
        descripcion: t.mascotasDescripcion,
        accion: agregar(),
      ),
      AsyncData(value: final lista) when lista.isEmpty => EnConstruccion.vacio(
        icono: Icons.pets,
        descripcion: t.mascotasVacio,
        accion: agregar(),
      ),
      AsyncData(value: final lista) => _Lista(mascotas: lista),
      AsyncError() => Center(child: Text(t.errorSinConexion)),
      _ => const Center(child: CircularProgressIndicator()),
    };

    final hayLista = conectado && (mascotas.value?.isNotEmpty ?? false);
    return Scaffold(
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        title: Text(t.pestanaMascotas),
        actions: const [BotonMensajes(), BotonAvisos(), BotonAjustes()],
      ),
      body: cuerpo,
      floatingActionButton: hayLista
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Rutas.mascotaNueva),
              icon: const Icon(Icons.add),
              label: Text(t.mascotasAgregar),
            )
          : null,
    );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.mascotas});

  final List<Mascota> mascotas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activa = ref.watch(mascotaActivaProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        // Fila superior: elegir la mascota activa con un toque.
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final m in mascotas)
                _AvatarActivo(mascota: m, activa: m.id == activa?.id),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final m in mascotas) _FilaMascota(mascota: m),
      ],
    );
  }
}

class _AvatarActivo extends ConsumerWidget {
  const _AvatarActivo({required this.mascota, required this.activa});

  final Mascota mascota;
  final bool activa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () =>
            ref.read(mascotaActivaIdProvider.notifier).elegir(mascota.id),
        child: Semantics(
          selected: activa,
          button: true,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: activa ? colores.primary : Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: FotoMascota(ruta: mascota.fotoPath, radio: 28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mascota.nombre,
                style: TextStyle(
                  fontWeight: activa ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaMascota extends ConsumerWidget {
  const _FilaMascota({required this.mascota});

  final Mascota mascota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final especie = (ref.watch(especiesProvider).value ?? const <Especie>[])
        .where((e) => e.id == mascota.especieId)
        .firstOrNull;
    final raza =
        mascota.razaOtra ??
        (ref.watch(razasProvider(mascota.especieId)).value ?? const <Raza>[])
            .where((r) => r.id == mascota.razaId)
            .firstOrNull
            ?.nombre;
    final yo = ref.watch(usuarioActualProvider).value?.id;
    final detalle = [
      ?especie?.nombre,
      ?raza,
      if (mascota.nacimiento case final n?) textoEdad(t, n),
      if (!mascota.esDe(yo))
        switch (ref.watch(nombresDelHogarProvider)[mascota.duenoId]) {
          final n? => t.mascotaCompartidaDe(n),
          null => t.mascotaCompartida,
        },
    ].join(' · ');

    return ListTile(
      leading: FotoMascota(ruta: mascota.fotoPath, icono: especie?.icono),
      title: Text(mascota.nombre),
      subtitle: detalle.isEmpty ? null : Text(detalle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Rutas.fichaMascota(mascota.id)),
    );
  }
}
