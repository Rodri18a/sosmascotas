import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../recorrido/pasos.dart';
import '../../recorrido/recorrido.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../utiles/tiempo.dart';
import '../../widgets/boton_ayuda.dart';
import '../menu/menu_principal.dart';

/// Pestaña SOS: reportes activos ordenados por cercanía, y botón para reportar.
class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  TipoSos? _filtro;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final reportes = ref.watch(sosCercanosProvider);
    return ZonaRecorrido(
      pantalla: PantallaRecorrido.sos,
      pasos: PasosRecorrido.sos,
      child: Scaffold(
        drawer: const MenuPrincipal(),
        appBar: AppBar(
          leading: botonMenu,
          title: Text(t.pestanaSos),
          actions: accionesPestana(),
        ),
        floatingActionButton: MarcaRecorrido(
          'reportar',
          child: FloatingActionButton.extended(
            backgroundColor: context.marca.acento,
            foregroundColor: context.marca.sobreAcento,
            onPressed: () => abrirConCuenta(
              context,
              ref,
              destino: Rutas.sosNuevo,
              motivo: t.sosMotivoCuenta,
            ),
            icon: const Icon(Icons.add_outlined),
            label: Text(t.sosReportar),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(sosCercanosProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: MarcaRecorrido(
                  'filtros',
                  child: Wrap(
                    spacing: 8,
                    children: [
                      for (final (valor, etiqueta) in [
                        (null, t.sosFiltroTodos),
                        (TipoSos.perdida, t.sosFiltroPerdidas),
                        (TipoSos.encontrada, t.sosFiltroEncontradas),
                      ])
                        ChoiceChip(
                          label: Text(etiqueta),
                          selected: _filtro == valor,
                          onSelected: (_) => setState(() => _filtro = valor),
                        ),
                    ],
                  ),
                ),
              ),
              const _MisReportes(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  t.sosOtrosCerca,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...switch (reportes) {
                AsyncData(value: final lista) => _tarjetas(context, lista),
                AsyncError() => [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      t.errorSinConexion,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                _ => const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _tarjetas(BuildContext context, List<SosResumen> lista) {
    // Los míos ya están arriba, en «Mis reportes» (D150).
    final mios = {
      for (final s in ref.watch(misSosProvider).value ?? const <MiSos>[]) s.id,
    };
    final filtrada = lista
        .where((r) => !mios.contains(r.id))
        .where((r) => _filtro == null || r.tipo == _filtro)
        .toList();
    if (filtrada.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(context.t.sosNingunoCerca, textAlign: TextAlign.center),
        ),
      ];
    }
    return [for (final r in filtrada) TarjetaSos(reporte: r)];
  }
}

/// Tarjeta de un SOS en la lista.
class TarjetaSos extends ConsumerWidget {
  const TarjetaSos({required this.reporte, super.key});

  final SosResumen reporte;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final url = ref.watch(sosRepositorioProvider).urlFoto(reporte.foto);
    final perdida = reporte.tipo == TipoSos.perdida;
    final titulo = perdida
        ? t.sosTituloPerdida(reporte.nombre ?? reporte.especie)
        : t.sosTituloEncontrada(reporte.especie);
    final detalle = [?reporte.raza, ?reporte.color].join(' · ');
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Rutas.detalleSos(reporte.id)),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: url == null
                  ? ColoredBox(
                      color: tema.colorScheme.primaryContainer,
                      child: Center(
                        child: Text(
                          reporte.especieIcono,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    )
                  : Image.network(url, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: perdida
                            ? tema.colorScheme.error
                            : tema.colorScheme.primary,
                      ),
                    ),
                    if (detalle.isNotEmpty) Text(detalle),
                    const SizedBox(height: 4),
                    Text(
                      t.sosDistanciaYTiempo(
                        textoDistancia(reporte.distanciaMetros),
                        textoHace(t, reporte.cuando),
                      ),
                      style: tema.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los reportes propios (para cerrarlos cuando aparece la mascota). Arranca
/// cerrado y va en otro color, para que no se confunda con los de los
/// vecinos de abajo (D150).
class _MisReportes extends ConsumerWidget {
  const _MisReportes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mios = ref.watch(misSosProvider).value ?? const <MiSos>[];
    if (mios.isEmpty) return const SizedBox.shrink();
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final activos = mios.where((s) => s.estado == EstadoSos.activo).length;
    return Card(
      key: const ValueKey('mis-reportes'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      // Crema de la guía de marca; en oscuro, un marrón que contrasta.
      color: oscuro ? const Color(0xFF3A2A16) : const Color(0xFFFFF1DC),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.marca.acento, width: 1.5),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.person_pin_circle_outlined),
        title: Text(
          t.sosMisReportes,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(t.sosMisReportesActivos(mios.length, activos)),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          for (final s in mios)
            ListTile(
              title: Text(
                s.tipo == TipoSos.perdida
                    ? t.sosTituloPerdida(s.nombre ?? '')
                    : t.sosTituloEncontrada(s.nombre ?? ''),
              ),
              subtitle: Text(switch (s.estado) {
                EstadoSos.activo => t.sosEstadoActivoCorto,
                EstadoSos.resuelto => t.sosEstadoResueltoCorto,
                EstadoSos.archivado => t.sosEstadoArchivadoCorto,
                EstadoSos.oculto => t.sosEstadoOcultoCorto,
              }),
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () => context.push(Rutas.detalleSos(s.id)),
            ),
        ],
      ),
    );
  }
}
