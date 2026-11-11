import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../agenda/agenda_repositorio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/ilustracion.dart';
import '../../widgets/volver.dart';

/// Texto de cada estado de un turno.
String textoEstadoTurno(AppLocalizations t, EstadoTurno e) => switch (e) {
  EstadoTurno.pendiente => t.turnoPendiente,
  EstadoTurno.confirmado => t.turnoConfirmado,
  EstadoTurno.rechazado => t.turnoRechazado,
  EstadoTurno.cancelado => t.turnoCanceladoEstado,
  EstadoTurno.atendido => t.turnoAtendido,
};

/// «martes 27 de oct. · 09:00».
String textoCuando(BuildContext context, DateTime inicio) {
  final l = MaterialLocalizations.of(context);
  return context.t.turnoCuando(
    l.formatFullDate(inicio).split(',').take(2).join(','),
    l.formatTimeOfDay(
      TimeOfDay.fromDateTime(inicio),
      alwaysUse24HourFormat: true,
    ),
  );
}

String textoError(AppLocalizations t, Object e) => switch (e) {
  AgendaException(motivo: ErrorAgenda.ocupado) => t.turnoOcupado,
  AgendaException(motivo: ErrorAgenda.limite) => t.turnoLimite,
  AgendaException(motivo: ErrorAgenda.noSePuede) => t.turnoNoSePuede,
  _ => t.errorSinConexion,
};

/// «Reservar turno» en la ficha (3.1, D104): solo si el comercio toma turnos.
/// Lo ve cualquiera; reservar pide ingresar.
class BotonReservar extends ConsumerWidget {
  const BotonReservar({required this.comercio, super.key});

  final Comercio comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (comercio.plan != PlanComercio.plus ||
        !ref.watch(funcionalidadActivaProvider(Funcionalidades.agenda))) {
      return const SizedBox.shrink();
    }
    if (ref.watch(condicionesAgendaProvider(comercio.id)).value == null) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilledButton.icon(
        onPressed: () async {
          final ruta = Rutas.reservarTurno(comercio.id);
          if (!await hayCuenta(
            context,
            ref,
            volverA: ruta,
            motivo: t.turnoIngresar,
          )) {
            return;
          }
          if (context.mounted) await context.push(ruta);
        },
        icon: const Icon(Icons.event_available_outlined),
        label: Text(t.turnoReservar),
      ),
    );
  }
}

class ReservarTurnoScreen extends ConsumerStatefulWidget {
  const ReservarTurnoScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<ReservarTurnoScreen> createState() =>
      _ReservarTurnoScreenState();
}

class _ReservarTurnoScreenState extends ConsumerState<ReservarTurnoScreen> {
  // '' = sin servicio (consulta general).
  String? _servicio;
  DateTime? _dia;
  HorarioLibre? _horario;
  String? _mascota;
  final _nota = TextEditingController();
  var _enviando = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  Future<void> _reservar() async {
    final t = context.t;
    final horario = _horario;
    final mascota = _mascota;
    if (horario == null || mascota == null) return;
    setState(() => _enviando = true);
    final mensajes = ScaffoldMessenger.of(context);
    final servicio = (_servicio?.isEmpty ?? true) ? null : _servicio;
    try {
      await ref
          .read(agendaRepositorioProvider)
          .reservar(
            negocioId: widget.negocioId,
            mascotaId: mascota,
            inicio: horario.inicio,
            servicioId: servicio,
            nota: _nota.text.trim().isEmpty ? null : _nota.text.trim(),
          );
      ref
        ..read(metricasProvider).track(
          Eventos.bookingCreate,
          businessId: widget.negocioId,
          props: {'con_servicio': servicio != null},
        )
        ..invalidate(misTurnosProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.turnoPedido)));
      if (mounted) context.go(Rutas.misTurnos);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoError(t, e))));
      if (e case AgendaException(motivo: ErrorAgenda.ocupado)) {
        ref.invalidate(horariosLibresProvider);
        setState(() => _horario = null);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final condiciones = ref.watch(condicionesAgendaProvider(widget.negocioId));
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.turnoReservarTitulo),
      ),
      body: switch (condiciones) {
        AsyncData(value: final c?) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.turnoServicio, style: tema.textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(t.turnoSinServicio),
                  selected: _servicio == '',
                  onSelected: (_) => setState(() {
                    _servicio = '';
                    _horario = null;
                  }),
                ),
                for (final s in c.servicios)
                  ChoiceChip(
                    label: Text(
                      '${s.nombre} · ${t.turnoDuracion(s.duracionMinutos)}',
                    ),
                    selected: _servicio == s.id,
                    onSelected: (_) => setState(() {
                      _servicio = s.id;
                      _horario = null;
                    }),
                  ),
              ],
            ),
            if (_servicio != null) ...[
              const SizedBox(height: 16),
              Text(t.turnoDia, style: tema.textTheme.titleMedium),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final d in c.diasReservables(
                      ref.watch(relojProvider)(),
                    ))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            MaterialLocalizations.of(
                              context,
                            ).formatShortMonthDay(d),
                          ),
                          selected: _dia == d,
                          onSelected: (_) => setState(() {
                            _dia = d;
                            _horario = null;
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (_dia case final dia?) ...[
              const SizedBox(height: 16),
              Text(t.turnoHorario, style: tema.textTheme.titleMedium),
              switch (ref.watch(
                horariosLibresProvider((
                  widget.negocioId,
                  dia,
                  (_servicio?.isEmpty ?? true) ? null : _servicio,
                )),
              )) {
                AsyncData(value: final libres) when libres.isEmpty => Text(
                  t.turnoSinHorarios,
                ),
                AsyncData(value: final libres) => Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final h in libres)
                      ChoiceChip(
                        label: Text(
                          MaterialLocalizations.of(context).formatTimeOfDay(
                            TimeOfDay.fromDateTime(h.inicio),
                            alwaysUse24HourFormat: true,
                          ),
                        ),
                        selected: _horario?.inicio == h.inicio,
                        onSelected: (_) => setState(() => _horario = h),
                      ),
                  ],
                ),
                AsyncError() => Text(t.errorSinConexion),
                _ => const LinearProgressIndicator(),
              },
            ],
            if (_horario != null) ...[
              const SizedBox(height: 16),
              Text(t.turnoMascota, style: tema.textTheme.titleMedium),
              switch (ref.watch(misMascotasProvider)) {
                AsyncData(value: final mascotas) when mascotas.isEmpty => Text(
                  t.turnoSinMascotas,
                ),
                AsyncData(value: final mascotas) => Wrap(
                  spacing: 8,
                  children: [
                    for (final m in mascotas)
                      ChoiceChip(
                        label: Text(m.nombre),
                        selected: _mascota == m.id,
                        onSelected: (_) => setState(() => _mascota = m.id),
                      ),
                  ],
                ),
                _ => const LinearProgressIndicator(),
              },
              const SizedBox(height: 16),
              TextField(
                controller: _nota,
                maxLength: 300,
                maxLines: 2,
                decoration: InputDecoration(labelText: t.turnoNota),
              ),
              FilledButton(
                onPressed: _mascota == null || _enviando ? null : _reservar,
                child: Text(t.turnoConfirmar),
              ),
            ],
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.moduloNoAplica, textAlign: TextAlign.center),
          ),
        ),
      },
    );
  }
}

/// Mis turnos, con el estado en vivo (también tirando hacia abajo).
class MisTurnosScreen extends ConsumerWidget {
  const MisTurnosScreen({super.key});

  Future<void> _cancelar(BuildContext context, WidgetRef ref, Turno x) async {
    final t = context.t;
    final si = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.turnoCancelar),
        content: Text(t.turnoCancelarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.turnoCancelar),
          ),
        ],
      ),
    );
    if (!(si ?? false) || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(agendaRepositorioProvider)
          .cambiarEstado(x.id, EstadoTurno.cancelado);
      ref
          .read(metricasProvider)
          .track(
            Eventos.bookingStatus,
            businessId: x.negocioId,
            props: {'estado': 'cancelled', 'quien': 'cliente'},
          );
      mensajes.showSnackBar(SnackBar(content: Text(t.turnoCancelado)));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoError(t, e))));
    }
    ref.invalidate(misTurnosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    ref.listen(turnosEnVivoProvider(null), (_, _) {
      ref.invalidate(misTurnosProvider);
    });
    final ahora = ref.watch(relojProvider)();
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.misTurnos),
        actions: const [BotonAyuda()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misTurnosProvider.future),
        child: switch (ref.watch(misTurnosProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => ListView(
            padding: const EdgeInsets.all(24),
            children: [VacioIlustrado(Ilustracion.salud, t.misTurnosVacio)],
          ),
          AsyncData(value: final lista) => ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final x in lista)
                Card(
                  child: ListTile(
                    title: Text([x.negocio, x.servicio].nonNulls.join(' · ')),
                    subtitle: Text(
                      [
                        textoCuando(context, x.inicio),
                        ?x.mascota,
                        textoEstadoTurno(t, x.estado),
                      ].join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: x.estado.vigente && x.inicio.isAfter(ahora)
                        ? TextButton(
                            onPressed: x.puedeCancelar(ahora)
                                ? () => _cancelar(context, ref, x)
                                : () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(t.turnoNoCancelable),
                                        ),
                                      ),
                            child: Text(t.cancelar),
                          )
                        : null,
                  ),
                ),
            ],
          ),
          AsyncError() => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.errorSinConexion),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
