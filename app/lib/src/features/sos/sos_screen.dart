import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/con_cuenta.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../theme/paleta.dart';
import '../../utiles/tiempo.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/boton_mensajes.dart';
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
    return Scaffold(
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        title: Text(t.pestanaSos),
        actions: const [BotonMensajes(), BotonAvisos(), BotonAjustes()],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(sosCercanosProvider.future),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            const _MisReportes(),
            ...switch (reportes) {
              AsyncData(value: final lista) => _tarjetas(context, lista),
              AsyncError() => [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(t.errorSinConexion, textAlign: TextAlign.center),
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
    );
  }

  List<Widget> _tarjetas(BuildContext context, List<SosResumen> lista) {
    final filtrada = lista
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

/// Los reportes propios (para cerrarlos cuando aparece la mascota).
class _MisReportes extends ConsumerWidget {
  const _MisReportes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mios = ref.watch(misSosProvider).value ?? const <MiSos>[];
    if (mios.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      leading: const Icon(Icons.person_pin_circle_outlined),
      title: Text(t.sosMisReportes),
      initiallyExpanded: mios.any((s) => s.estado == EstadoSos.activo),
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
    );
  }
}
