import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../mascotas/textos_mascota.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../theme/paleta.dart';
import '../../widgets/foto_mascota.dart';
import '../hogar/tareas.dart';
import '../libreta/libreta.dart';
import '../recordatorios/recordatorios.dart';
import '../renac/renac.dart';
import '../veterinarias/tarjeta_veterinaria.dart';

/// Ficha de una mascota propia.
class FichaMascotaScreen extends ConsumerWidget {
  const FichaMascotaScreen({required this.mascotaId, super.key});

  final String mascotaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return switch (ref.watch(mascotaProvider(mascotaId))) {
      AsyncData(value: final mascota?) => _Ficha(mascota: mascota),
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.errorDesconocido)),
      ),
    };
  }
}

class _Ficha extends ConsumerWidget {
  const _Ficha({required this.mascota});

  final Mascota mascota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final esDueno = mascota.esDe(ref.watch(usuarioActualProvider).value?.id);
    final nombres = ref.watch(nombresDelHogarProvider);
    final especie = (ref.watch(especiesProvider).value ?? const <Especie>[])
        .where((e) => e.id == mascota.especieId)
        .firstOrNull;
    final raza =
        mascota.razaOtra ??
        (ref.watch(razasProvider(mascota.especieId)).value ?? const <Raza>[])
            .where((r) => r.id == mascota.razaId)
            .firstOrNull
            ?.nombre;

    final datos = <(IconData, String, String)>[
      if (especie != null)
        (
          Icons.category_outlined,
          t.mascotaEspecie,
          '${especie.icono} ${especie.nombre}',
        ),
      if (raza != null) (Icons.pets_outlined, t.mascotaRaza, raza),
      (Icons.wc_outlined, t.mascotaSexo, textoSexo(t, mascota.sexo)),
      if (mascota.nacimiento case final n?)
        (Icons.cake_outlined, t.fichaEdad, textoEdad(t, n)),
      if (mascota.castrada case final c?)
        (Icons.healing_outlined, t.fichaCastrada, c ? t.si : t.no),
      if (mascota.color case final c?)
        (Icons.palette_outlined, t.mascotaColor, c),
      if (mascota.senas case final s?) (Icons.search, t.mascotaSenas, s),
      if (mascota.notas case final n?) (Icons.notes, t.mascotaNotas, n),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(mascota.nombre),
        actions: [
          IconButton(
            tooltip: t.fichaEditar,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Rutas.editarMascota(mascota.id)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: FotoMascota(
              ruta: mascota.fotoPath,
              radio: 72,
              icono: especie?.icono,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(mascota.nombre, style: tema.textTheme.headlineSmall),
          ),
          if (!esDueno)
            Center(
              child: Text(switch (nombres[mascota.duenoId]) {
                final n? => t.mascotaCompartidaDe(n),
                null => t.mascotaCompartida,
              }, style: tema.textTheme.bodySmall),
            ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final (icono, etiqueta, valor) in datos)
                  ListTile(
                    leading: Icon(icono),
                    title: Text(valor),
                    subtitle: Text(etiqueta),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory_outlined),
              title: Text(mascota.microchip ?? t.fichaSinMicrochip),
              subtitle: Text(
                mascota.microchip == null
                    ? t.mascotaMicrochipAyuda
                    : t.fichaMicrochipConsejo,
              ),
            ),
          ),
          if (seRegistraEnRenac(especie?.slug))
            SiFuncionalidad(
              Funcionalidades.renac,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TarjetaRenac(
                  mascota: mascota,
                  slugEspecie: especie?.slug,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Reportar un SOS es del dueño (D69): quien comparte lo ve en
          // la ficha pero no lo dispara.
          if (esDueno) ...[
            // Con un reporte de perdida abierto, se va a ese reporte en vez de
            // hacer otro (la base tampoco deja repetirlo).
            if ((ref.watch(misSosProvider).value ?? const <MiSos>[])
                    .where(
                      (s) =>
                          s.mascotaId == mascota.id &&
                          s.tipo == TipoSos.perdida &&
                          (s.estado == EstadoSos.activo ||
                              s.estado == EstadoSos.oculto),
                    )
                    .firstOrNull
                case final abierto?)
              FilledButton.icon(
                onPressed: () => context.push(Rutas.detalleSos(abierto.id)),
                icon: const Icon(Icons.sos),
                label: Text(t.fichaVerReportePerdida),
              )
            else
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.marca.acento,
                  foregroundColor: context.marca.sobreAcento,
                ),
                onPressed: () =>
                    context.push(Rutas.reportarMascota(mascota.id)),
                icon: const Icon(Icons.sos),
                label: Text(t.fichaReportarPerdida),
              ),
            const SizedBox(height: 12),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: Text(t.fichaQrTitulo),
              subtitle: Text(t.fichaQrDescripcion),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Rutas.qrMascota(mascota.id)),
            ),
          ),
          SiFuncionalidad(
            Funcionalidades.libreta,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TarjetaLibreta(mascotaId: mascota.id),
            ),
          ),
          SiFuncionalidad(
            Funcionalidades.hogar,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TarjetaTareas(mascota: mascota),
            ),
          ),
          SiFuncionalidad(
            Funcionalidades.recordatorios,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TarjetaRecordatorios(mascotaId: mascota.id),
            ),
          ),
          // Compartirla con su veterinaria y "Busco veterinaria" (2.6): decide
          // el dueño.
          if (esDueno)
            SiFuncionalidad(
              Funcionalidades.veterinarias,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TarjetaVeterinaria(mascota: mascota),
              ),
            ),
        ],
      ),
    );
  }
}
