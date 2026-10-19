import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/mis_lugares.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../eventos/eventos_repositorio.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mapa/mapa_vista.dart';
import '../../mascotas/mascota_activa.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/boton_mensajes.dart';
import '../eventos/eventos.dart';
import '../instalar/instalar.dart';
import 'ficha_comercio.dart';
import 'marcar_lugar.dart';

enum _Vista { mapa, lista, sinLocal }

/// Mapa. Fase 0: perdidos, encontrados y veterinarias. Con la funcionalidad
/// `mapa_completo` (etapa 1.2, D75): todos los rubros, filtros, lista,
/// "Sin local" y pines agrupados.
///
/// Regla de costo: se traen solo los pines de la zona visible (agrandada 1,5×)
/// y no se vuelve a consultar mientras la vista quede dentro de lo ya cargado.
/// Los filtros se aplican sobre lo traído, sin otra consulta.
class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  Limites? _cargado;
  Limites? _visible;
  bool? _completoCargado;
  List<Pin> _sos = const [];

  /// Lugares marcados por usuarios sin reclamar (1.3.2), por id de pin.
  Map<String, LugarSinReclamar> _sinReclamar = const {};

  /// Eventos (2.7), por id de pin.
  Map<String, Evento> _eventos = const {};
  bool? _eventosCargado;
  bool? _comerciosCargado;

  /// Lugares cargados, por id (para abrir la ficha al tocar su pin).
  Map<String, Comercio> _comercios = const {};

  var _vista = _Vista.mapa;
  var _filtros = const FiltrosMapa();

  bool get _completo =>
      ref.read(funcionalidadActivaProvider(Funcionalidades.mapaCompleto));

  bool get _conComercios =>
      ref.read(funcionalidadActivaProvider(Funcionalidades.comercios));

  bool get _conEventos =>
      ref.read(funcionalidadActivaProvider(Funcionalidades.eventos));

  Future<void> _alQuedarQuieto(Limites visible) async {
    setState(() => _visible = visible);
    final completo = _completo;
    final conComercios = _conComercios;
    final conEventos = _conEventos;
    if ((_cargado?.contiene(visible) ?? false) &&
        _completoCargado == completo &&
        _comerciosCargado == conComercios &&
        _eventosCargado == conEventos) {
      return;
    }
    _eventosCargado = conEventos;
    final zona = visible.agrandado(1.5);
    _cargado = zona;
    _completoCargado = completo;
    _comerciosCargado = conComercios;
    final repo = ref.read(comerciosRepositorioProvider);
    try {
      final (sos, comercios, sinReclamar, eventos) = await (
        ref.read(sosRepositorioProvider).enZona(zona),
        repo.enZona(zona, categorias: completo ? null : const {Categoria.vet}),
        conComercios
            ? repo.sinReclamarEnZona(zona)
            : Future.value(const <LugarSinReclamar>[]),
        conEventos
            ? ref.read(eventosRepositorioProvider).enZona(zona)
            : Future.value(const <Evento>[]),
      ).wait;
      if (!mounted) return;
      setState(() {
        _sos = sos;
        _comercios = {for (final c in comercios) c.id: c};
        _sinReclamar = {for (final l in sinReclamar) l.pin.id: l};
        _eventos = {for (final e in eventos) e.pin.id: e};
      });
    } on Exception {
      _cargado = null; // Se reintenta en el próximo movimiento.
    } on ParallelWaitError<dynamic, dynamic> {
      _cargado = null;
    }
  }

  void _alTocarPin(Pin pin) {
    if (pin.esSos) {
      context.push(Rutas.detalleSos(pin.id));
    } else if (_eventos[pin.id] case final evento?) {
      mostrarEvento(context, ref, evento);
    } else if (_sinReclamar[pin.id] case final lugar?) {
      mostrarSinReclamar(context, ref, lugar);
    } else if (_comercios[pin.id] case final comercio?) {
      mostrarFichaComercio(context, ref, comercio);
    }
  }

  /// Especies para la regla de coincidencia: la mascota activa o todas.
  Set<int> _especies() {
    if (_filtros.porMascotaActiva) {
      final activa = ref.watch(mascotaActivaProvider);
      if (activa != null) return {activa.especieId};
    }
    final todas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    return {for (final m in todas) m.especieId};
  }

  List<Comercio> _filtrados() => filtrarComercios(
    _comercios.values,
    _filtros,
    ahora: ref.watch(relojProvider)(),
    desde: _visible?.centro,
    favoritos: {
      for (final l in (ref.watch(misLugaresProvider).value ?? const {}).values)
        if (l.favorito) l.comercioId,
    },
    especies: _especies(),
  );

  List<Pin> _pins(bool completo) {
    if (!completo) {
      // Las veterinarias primero: los SOS quedan dibujados encima.
      return [
        for (final c in _comercios.values) ?c.pin,
        for (final e in _eventos.values) e.pin,
        ..._sos,
      ];
    }
    final lugares = [for (final c in _filtrados()) ?c.pin];
    final sinReclamar = [
      for (final l in _sinReclamar.values)
        if (_filtros.categorias.isEmpty ||
            _filtros.categorias.contains(l.categoria))
          l.pin,
    ];
    final todos = [
      ...sinReclamar,
      ...lugares,
      for (final e in _eventos.values) e.pin,
      if (_filtros.mostrarSos) ..._sos,
    ];
    final visible = _visible;
    return visible == null ? todos : agruparPins(todos, visible);
  }

  void _cambiarVista(_Vista vista) {
    setState(() => _vista = vista);
    ref
        .read(metricasProvider)
        .track(Eventos.mapView, props: {'vista': vista.name});
  }

  Future<void> _abrirFiltros() async {
    final nuevos = await showModalBottomSheet<FiltrosMapa>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _HojaFiltros(filtros: _filtros),
    );
    if (nuevos != null) setState(() => _filtros = nuevos);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final completo = ref.watch(
      funcionalidadActivaProvider(Funcionalidades.mapaCompleto),
    );
    final puedeMarcar =
        completo &&
        ref.watch(conectadoProvider) &&
        ref.watch(funcionalidadActivaProvider(Funcionalidades.comercios));
    final mapa = Stack(
      children: [
        MapaVista(
          centro: ref.watch(miZonaProvider),
          pins: _pins(completo),
          onCamaraQuieta: _alQuedarQuieto,
          onTocarPin: _alTocarPin,
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: _Leyenda(
            completo: completo,
            conComercios: ref.watch(
              funcionalidadActivaProvider(Funcionalidades.comercios),
            ),
            conEventos: ref.watch(
              funcionalidadActivaProvider(Funcionalidades.eventos),
            ),
          ),
        ),
        if (puedeMarcar)
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton.extended(
              heroTag: 'marcar-lugar',
              onPressed: () async {
                final marcado = await context.push<bool>(Rutas.marcarLugar);
                // Para ver la marca nueva se vuelve a traer la zona.
                if (marcado ?? false) setState(() => _cargado = null);
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(t.marcarLugar),
            ),
          ),
        const Positioned(
          left: 8,
          right: 8,
          top: 8,
          child: SafeArea(child: TarjetaInstalarApp()),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.pestanaMapa),
        actions: const [BotonMensajes(), BotonAvisos(), BotonAjustes()],
      ),
      body: !completo
          ? mapa
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: SegmentedButton<_Vista>(
                    segments: [
                      ButtonSegment(
                        value: _Vista.mapa,
                        icon: const Icon(Icons.map_outlined),
                        label: Text(t.mapaVistaMapa),
                      ),
                      ButtonSegment(
                        value: _Vista.lista,
                        icon: const Icon(Icons.list),
                        label: Text(t.mapaVistaLista),
                      ),
                      ButtonSegment(
                        value: _Vista.sinLocal,
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: Text(t.mapaVistaSinLocal),
                      ),
                    ],
                    selected: {_vista},
                    onSelectionChanged: (s) => _cambiarVista(s.first),
                  ),
                ),
                _BarraFiltros(
                  filtros: _filtros,
                  sinLocal: _vista == _Vista.sinLocal,
                  onCambiar: (f) => setState(() => _filtros = f),
                  onMasFiltros: _abrirFiltros,
                ),
                Expanded(
                  // El mapa queda creado aunque se vea la lista: se crea una
                  // sola vez por sesión (regla de costo 5).
                  child: IndexedStack(
                    index: _vista.index,
                    children: [
                      mapa,
                      _Lista(
                        comercios: ordenarParaLista(
                          _filtrados(),
                          ahora: ref.watch(relojProvider)(),
                          desde: _visible?.centro,
                        ),
                        desde: _visible?.centro,
                      ),
                      _SinLocal(filtros: _filtros, especies: _especies()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Rubros (chips) y el botón "Filtros".
class _BarraFiltros extends StatelessWidget {
  const _BarraFiltros({
    required this.filtros,
    required this.sinLocal,
    required this.onCambiar,
    required this.onMasFiltros,
  });

  final FiltrosMapa filtros;
  final bool sinLocal;
  final ValueChanged<FiltrosMapa> onCambiar;
  final VoidCallback onMasFiltros;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final activos = filtros.activos;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          ActionChip(
            avatar: Badge(
              isLabelVisible: activos > 0,
              label: Text('$activos'),
              child: const Icon(Icons.tune, size: 18),
            ),
            label: Text(t.mapaFiltros),
            onPressed: onMasFiltros,
          ),
          if (!sinLocal) ...[
            const SizedBox(width: 6),
            FilterChip(
              label: Text(t.mapaPerdidos),
              selected: filtros.mostrarSos,
              onSelected: (si) => onCambiar(filtros.copyWith(mostrarSos: si)),
            ),
          ],
          for (final c in Categoria.values) ...[
            const SizedBox(width: 6),
            FilterChip(
              label: Text(textoCategorias(t, c)),
              selected: filtros.categorias.contains(c),
              onSelected: (si) => onCambiar(
                filtros.copyWith(
                  categorias: si
                      ? {...filtros.categorias, c}
                      : ({...filtros.categorias}..remove(c)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HojaFiltros extends ConsumerStatefulWidget {
  const _HojaFiltros({required this.filtros});

  final FiltrosMapa filtros;

  @override
  ConsumerState<_HojaFiltros> createState() => _HojaFiltrosState();
}

class _HojaFiltrosState extends ConsumerState<_HojaFiltros> {
  late var _f = widget.filtros;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final activa = ref.watch(mascotaActivaProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.mapaFiltros, style: tema.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(t.mapaDistancia, style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Distancia>(
              segments: [
                for (final (d, texto) in [
                  (Distancia.m300, t.mapaDist300),
                  (Distancia.m800, t.mapaDist800),
                  (Distancia.km2, t.mapaDist2500),
                  (Distancia.todo, t.mapaDistTodo),
                ])
                  ButtonSegment(value: d, label: Text(texto)),
              ],
              selected: {_f.distancia},
              onSelectionChanged: (s) =>
                  setState(() => _f = _f.copyWith(distancia: s.first)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.mapaAbiertoAhora),
              value: _f.abiertoAhora,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(abiertoAhora: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.mapaSoloFavoritos),
              value: _f.soloFavoritos,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(soloFavoritos: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.mapaColocaMicrochip),
              value: _f.colocaMicrochip,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(colocaMicrochip: v)),
            ),
            const SizedBox(height: 8),
            Text(t.mapaEspecie, style: tema.textTheme.titleSmall),
            RadioGroup<bool>(
              groupValue: _f.porMascotaActiva,
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(porMascotaActiva: v ?? true)),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    title: Text(
                      activa == null
                          ? t.mapaEspecieActivaSinNombre
                          : t.mapaEspecieActiva(activa.nombre),
                    ),
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    title: Text(t.mapaEspecieTodas),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    FiltrosMapa(
                      categorias: _f.categorias,
                      mostrarSos: _f.mostrarSos,
                    ),
                  ),
                  child: Text(t.mapaFiltrosLimpiar),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _f),
                  child: Text(t.mapaFiltrosListo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaLugar extends ConsumerWidget {
  const _FilaLugar({required this.comercio, this.desde});

  final Comercio comercio;
  final Punto? desde;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final estado = comercio.estadoEn(ref.watch(relojProvider)());
    final punto = comercio.punto;
    final mio = (ref.watch(misLugaresProvider).value ?? const {})[comercio.id];
    final detalle = [
      textoCategoria(t, comercio.categoria),
      switch (comercio.modalidad) {
        Modalidad.online => t.modalidadOnline,
        Modalidad.domicilio => t.modalidadDomicilio,
        Modalidad.local => null,
      },
      if (desde != null && punto != null)
        t.mapaA(textoDistancia(distanciaMetros(desde!, punto))),
      if (comercio.modalidad == Modalidad.local || !comercio.horario.vacio)
        textoApertura(t, estado),
    ].nonNulls.join(' · ');
    return ListTile(
      leading: CircleAvatar(child: Icon(iconoCategoria(comercio.categoria))),
      title: Text(comercio.nombre),
      subtitle: Text(detalle),
      trailing: (mio?.favorito ?? false)
          ? const Icon(Icons.favorite, size: 20)
          : null,
      onTap: () => mostrarFichaComercio(context, ref, comercio),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.comercios, this.desde});

  final List<Comercio> comercios;
  final Punto? desde;

  @override
  Widget build(BuildContext context) => comercios.isEmpty
      ? Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(context.t.mapaListaVacia, textAlign: TextAlign.center),
          ),
        )
      : ListView(
          children: [
            for (final c in comercios) _FilaLugar(comercio: c, desde: desde),
          ],
        );
}

class _SinLocal extends ConsumerWidget {
  const _SinLocal({required this.filtros, required this.especies});

  final FiltrosMapa filtros;
  final Set<int> especies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return switch (ref.watch(sinLocalProvider)) {
      AsyncData(:final value) => () {
        final lista = ordenarParaLista(
          filtrarComercios(
            value,
            filtros,
            ahora: ref.watch(relojProvider)(),
            favoritos: {
              for (final l
                  in (ref.watch(misLugaresProvider).value ?? const {}).values)
                if (l.favorito) l.comercioId,
            },
            especies: especies,
          ),
          ahora: ref.watch(relojProvider)(),
        );
        return lista.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(t.mapaSinLocalVacio, textAlign: TextAlign.center),
                ),
              )
            : ListView(
                children: [for (final c in lista) _FilaLugar(comercio: c)],
              );
      }(),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      _ => Center(child: Text(t.errorSinConexion)),
    };
  }
}

/// Qué significa cada color de pin.
class _Leyenda extends StatelessWidget {
  const _Leyenda({
    required this.completo,
    required this.conComercios,
    required this.conEventos,
  });

  final bool completo;
  final bool conComercios;
  final bool conEventos;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (tipo, texto) in [
              (TipoPin.perdido, t.leyendaPerdido),
              (TipoPin.encontrado, t.leyendaEncontrado),
              (TipoPin.urgencia, t.leyendaUrgencia),
              (TipoPin.veterinaria, t.leyendaVeterinaria),
              if (completo) (TipoPin.comercio, t.leyendaComercio),
              if (completo) (TipoPin.aceptaMascotas, t.leyendaAcepta),
              if (completo && conComercios)
                (TipoPin.sinReclamar, t.leyendaSinReclamar),
              if (conEventos) (TipoPin.evento, t.leyendaEvento),
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarcaPin(
                    aspectoDePin(
                      Pin(id: '', tipo: tipo, punto: const Punto(0, 0)),
                    )!,
                  ),
                  const SizedBox(width: 6),
                  Text(texto, style: tema.textTheme.labelSmall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
