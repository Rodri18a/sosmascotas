import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../agenda/cuidados_repositorio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/ilustracion.dart';
import '../../widgets/volver.dart';

String textoTipoCuidado(AppLocalizations t, TipoCuidado x) => switch (x) {
  TipoCuidado.paseo => t.cuidadoPaseo,
  TipoCuidado.guarderia => t.cuidadoGuarderia,
  TipoCuidado.estadia => t.cuidadoEstadia,
  TipoCuidado.visitas => t.cuidadoVisitas,
};

String textoFranja(AppLocalizations t, FranjaCuidado f) => switch (f) {
  FranjaCuidado.manana => t.cuidadoManana,
  FranjaCuidado.tarde => t.cuidadoTarde,
  FranjaCuidado.noche => t.cuidadoNoche,
};

String textoEstadoCuidado(AppLocalizations t, EstadoCuidado e) => switch (e) {
  EstadoCuidado.pendiente => t.cuidadoPendiente,
  EstadoCuidado.aceptado => t.cuidadoAceptado,
  EstadoCuidado.rechazado => t.cuidadoRechazado,
  EstadoCuidado.cancelado => t.cuidadoCanceladoEstado,
  EstadoCuidado.terminado => t.cuidadoTerminado,
};

/// «del 24/12 al 26/12 · mañana», o «el 24/12» si es un solo día.
String textoFechas(BuildContext context, Cuidado c) {
  final l = MaterialLocalizations.of(context);
  final t = context.t;
  final fechas = c.dias == 1
      ? t.cuidadoElDia(l.formatShortMonthDay(c.desde))
      : t.cuidadoDelAl(
          l.formatShortMonthDay(c.desde),
          l.formatShortMonthDay(c.hasta),
        );
  return [fechas, if (c.franja case final f?) textoFranja(t, f)].join(' · ');
}

String textoErrorCuidado(AppLocalizations t, Object e) => switch (e) {
  CuidadosException(motivo: ErrorCuidados.sinLugar) => t.cuidadoSinLugar,
  CuidadosException(motivo: ErrorCuidados.limite) => t.cuidadoLimite,
  CuidadosException(motivo: ErrorCuidados.noSePuede) => t.turnoNoSePuede,
  _ => t.errorSinConexion,
};

/// «Contratar» en la ficha de paseadores y hoteles (3.3, D115): solo si
/// ofrecen algo. Lo ve cualquiera; pedir pide ingresar.
class BotonContratar extends ConsumerWidget {
  const BotonContratar({required this.comercio, super.key});

  final Comercio comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (comercio.plan != PlanComercio.plus ||
        !(comercio.categoria == Categoria.walker ||
            comercio.categoria == Categoria.hotel) ||
        !ref.watch(funcionalidadActivaProvider(Funcionalidades.cuidados))) {
      return const SizedBox.shrink();
    }
    final condiciones = ref.watch(condicionesCuidadosProvider(comercio.id));
    final c = condiciones.value;
    if (c == null) return const SizedBox.shrink();
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FilledButton.icon(
        onPressed: () async {
          final ruta = Rutas.pedirCuidado(comercio.id);
          if (!await hayCuenta(
            context,
            ref,
            volverA: ruta,
            motivo: t.cuidadoIngresar,
          )) {
            return;
          }
          if (context.mounted) await context.push(ruta);
        },
        icon: const Icon(Icons.pets_outlined),
        label: Text(
          t.cuidadoContratar(
            c.tipos.map((x) => textoTipoCuidado(t, x).toLowerCase()).join(', '),
          ),
        ),
      ),
    );
  }
}

class PedirCuidadoScreen extends ConsumerStatefulWidget {
  const PedirCuidadoScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<PedirCuidadoScreen> createState() => _PedirCuidadoState();
}

class _PedirCuidadoState extends ConsumerState<PedirCuidadoScreen> {
  TipoCuidado? _tipo;
  DateTimeRange? _fechas;
  FranjaCuidado? _franja;
  final _mascotas = <String>{};
  final _nota = TextEditingController();
  var _enviando = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  Future<void> _elegirFechas(CondicionesCuidados c) async {
    final t = context.t;
    final ahora = ref.read(relojProvider)();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final ultimo = DateTime(hoy.year, hoy.month, hoy.day + c.diasAdelante);
    if (c.maximoDias == 1) {
      final dia = await showDatePicker(
        context: context,
        // Arranca en el día del reloj de la app (no en DateTime.now()).
        initialDate: hoy,
        currentDate: ahora,
        firstDate: hoy,
        lastDate: ultimo,
        helpText: t.cuidadoFechas,
      );
      if (dia != null) {
        setState(() => _fechas = DateTimeRange(start: dia, end: dia));
      }
      return;
    }
    final rango = await showDateRangePicker(
      context: context,
      currentDate: ahora,
      firstDate: hoy,
      lastDate: ultimo,
      helpText: t.cuidadoFechas,
      initialDateRange: _fechas,
    );
    if (rango != null) setState(() => _fechas = rango);
  }

  Future<void> _pedir() async {
    final t = context.t;
    final tipo = _tipo;
    final fechas = _fechas;
    if (tipo == null || fechas == null || _mascotas.isEmpty) return;
    setState(() => _enviando = true);
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(cuidadosRepositorioProvider)
          .pedir(
            negocioId: widget.negocioId,
            tipo: tipo,
            desde: fechas.start,
            hasta: fechas.end,
            mascotaIds: [..._mascotas],
            franja: _franja,
            nota: _nota.text.trim().isEmpty ? null : _nota.text.trim(),
          );
      ref
        ..read(metricasProvider).track(
          Eventos.careRequest,
          businessId: widget.negocioId,
          props: {
            'tipo': tipo.base,
            'dias': fechas.duration.inDays + 1,
            'mascotas': _mascotas.length,
          },
        )
        ..invalidate(misCuidadosProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.cuidadoPedido)));
      if (mounted) context.go(Rutas.misCuidados);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorCuidado(t, e))));
      if (e case CuidadosException(motivo: ErrorCuidados.sinLugar)) {
        ref.invalidate(condicionesCuidadosProvider(widget.negocioId));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    final condiciones = ref.watch(
      condicionesCuidadosProvider(widget.negocioId),
    );
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.cuidadoTitulo),
      ),
      body: switch (condiciones) {
        AsyncData(value: final c?) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (c.condiciones case final texto?) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(t.cuidadoCondiciones),
                  subtitle: Text(texto),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(t.cuidadoQue, style: tema.textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                for (final x in c.tipos)
                  ChoiceChip(
                    label: Text(textoTipoCuidado(t, x)),
                    selected: _tipo == x,
                    onSelected: (_) => setState(() {
                      _tipo = x;
                      _fechas = null;
                    }),
                  ),
              ],
            ),
            if (_tipo case final tipo?) ...[
              const SizedBox(height: 16),
              Text(t.cuidadoFechas, style: tema.textTheme.titleMedium),
              Text(
                t.cuidadoMaximoDias(c.maximoDias),
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: () => _elegirFechas(c),
                icon: const Icon(Icons.date_range_outlined),
                label: Text(switch (_fechas) {
                  null => t.cuidadoElegirFechas,
                  final f when f.start == f.end => t.cuidadoElDia(
                    l.formatShortMonthDay(f.start),
                  ),
                  final f => t.cuidadoDelAl(
                    l.formatShortMonthDay(f.start),
                    l.formatShortMonthDay(f.end),
                  ),
                }),
              ),
              if (_fechas case final f?)
                if (c.revisar(tipo, f.start, f.end, ref.watch(relojProvider)())
                    case final problema?)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(switch (problema) {
                      ProblemaFechas.sinLugar => t.cuidadoSinLugar,
                      ProblemaFechas.muyLargo => t.cuidadoMaximoDias(
                        c.maximoDias,
                      ),
                      ProblemaFechas.fueraDeRango => t.cuidadoFueraDeRango,
                    }, style: TextStyle(color: tema.colorScheme.error)),
                  ),
              const SizedBox(height: 16),
              Text(t.cuidadoFranja, style: tema.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(t.cuidadoSinFranja),
                    selected: _franja == null,
                    onSelected: (_) => setState(() => _franja = null),
                  ),
                  for (final f in FranjaCuidado.values)
                    ChoiceChip(
                      label: Text(textoFranja(t, f)),
                      selected: _franja == f,
                      onSelected: (_) => setState(() => _franja = f),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(t.cuidadoMascotas, style: tema.textTheme.titleMedium),
              switch (ref.watch(misMascotasProvider)) {
                AsyncData(value: final mascotas) when mascotas.isEmpty => Text(
                  t.turnoSinMascotas,
                ),
                AsyncData(value: final mascotas) => Wrap(
                  spacing: 8,
                  children: [
                    for (final m in mascotas)
                      FilterChip(
                        label: Text(m.nombre),
                        selected: _mascotas.contains(m.id),
                        onSelected: (si) => setState(() {
                          if (!si) {
                            _mascotas.remove(m.id);
                          } else if (_mascotas.length < 5) {
                            _mascotas.add(m.id);
                          }
                        }),
                      ),
                  ],
                ),
                _ => const LinearProgressIndicator(),
              },
              const SizedBox(height: 16),
              TextField(
                controller: _nota,
                maxLength: 300,
                maxLines: 3,
                decoration: InputDecoration(labelText: t.cuidadoNota),
              ),
              Text(t.cuidadoComoSigue, style: tema.textTheme.bodySmall),
              const SizedBox(height: 8),
              FilledButton(
                onPressed:
                    _fechas == null ||
                        _mascotas.isEmpty ||
                        _enviando ||
                        c.revisar(
                              tipo,
                              _fechas!.start,
                              _fechas!.end,
                              ref.watch(relojProvider)(),
                            ) !=
                            null
                    ? null
                    : _pedir,
                child: Text(t.cuidadoEnviar),
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

/// Mis cuidados: lo pedido a paseadores, hoteles y cuidadores, con el estado
/// en vivo y el chat una vez aceptado.
class MisCuidadosScreen extends ConsumerWidget {
  const MisCuidadosScreen({super.key});

  Future<void> _cancelar(BuildContext context, WidgetRef ref, Cuidado x) async {
    final t = context.t;
    final si = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.cuidadoCancelar),
        content: Text(t.cuidadoCancelarTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.cuidadoCancelar),
          ),
        ],
      ),
    );
    if (!(si ?? false) || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(cuidadosRepositorioProvider)
          .cambiarEstado(x.id, EstadoCuidado.cancelado);
      ref
          .read(metricasProvider)
          .track(
            Eventos.careStatus,
            businessId: x.negocioId,
            props: {'estado': 'cancelled', 'quien': 'cliente'},
          );
      mensajes.showSnackBar(SnackBar(content: Text(t.cuidadoCancelado)));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorCuidado(t, e))));
    }
    ref.invalidate(misCuidadosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    ref.listen(cuidadosEnVivoProvider(null), (_, _) {
      ref.invalidate(misCuidadosProvider);
    });
    final hoy = ref.watch(relojProvider)();
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.barraCuidados),
        actions: const [BotonAyuda()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misCuidadosProvider.future),
        child: switch (ref.watch(misCuidadosProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              VacioIlustrado(Ilustracion.amiPaseando, t.misCuidadosVacio),
            ],
          ),
          AsyncData(value: final lista) => ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final x in lista)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            x.negocio,
                            textoTipoCuidado(t, x.tipo),
                          ].nonNulls.join(' · '),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          [
                            textoFechas(context, x),
                            x.mascotas.join(', '),
                            textoEstadoCuidado(t, x.estado),
                          ].join('\n'),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (x.chatId case final chat?)
                              FilledButton.tonalIcon(
                                onPressed: () => context.push(Rutas.chat(chat)),
                                icon: const Icon(Icons.chat_outlined),
                                label: Text(t.cuidadoChat),
                              ),
                            if (x.estado.vigente)
                              TextButton(
                                onPressed: x.puedeCancelar(hoy)
                                    ? () => _cancelar(context, ref, x)
                                    : () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                t.cuidadoNoCancelable,
                                              ),
                                            ),
                                          ),
                                child: Text(t.cancelar),
                              ),
                          ],
                        ),
                      ],
                    ),
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
