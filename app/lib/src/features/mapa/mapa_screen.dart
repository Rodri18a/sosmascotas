import 'dart:async';

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
import '../sos/sos_screen.dart';
import 'ficha_comercio.dart';
import 'marcar_lugar.dart';

enum _Vista { mapa, lista, sinLocal }

/// Mapa: perdidos y encontrados, todos los rubros, lugares sin reclamar y
/// eventos, con filtros, lista, "Sin local" y pines agrupados (1.2, D75).
/// Lo que se ve es para todos, también visitantes: prima la información
/// (D84). Las funcionalidades graduales solo frenan las acciones (marcar un
/// lugar, reclamarlo, favoritos).
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
  List<Pin> _sos = const [];

  /// Perdidos y encontrados con sus datos, para la lista (se traen al abrirla).
  List<SosResumen> _sosLista = const [];

  /// Lugares marcados por usuarios sin reclamar (1.3.2), por id de pin.
  Map<String, LugarSinReclamar> _sinReclamar = const {};

  /// Eventos (2.7), por id de pin.
  Map<String, Evento> _eventos = const {};

  /// Lugares cargados, por id (para abrir la ficha al tocar su pin).
  Map<String, Comercio> _comercios = const {};

  var _vista = _Vista.mapa;
  var _filtros = const FiltrosMapa();

  Future<void> _alQuedarQuieto(Limites visible) async {
    setState(() => _visible = visible);
    if (_cargado?.contiene(visible) ?? false) return;
    final zona = visible.agrandado(1.5);
    _cargado = zona;
    if (_vista == _Vista.lista) unawaited(_cargarSosLista());
    final repo = ref.read(comerciosRepositorioProvider);
    try {
      final (sos, comercios, sinReclamar, eventos) = await (
        ref.read(sosRepositorioProvider).enZona(zona),
        repo.enZona(zona),
        repo.sinReclamarEnZona(zona),
        ref.read(eventosRepositorioProvider).enZona(zona),
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

  /// La lista muestra las tarjetas de los SOS: se traen solo al abrirla
  /// (regla de costo) y cuando la zona cargada cambia.
  Future<void> _cargarSosLista() async {
    final centro = _visible?.centro;
    if (centro == null) return;
    try {
      final lista = await ref.read(sosRepositorioProvider).cercanos(centro);
      if (mounted) setState(() => _sosLista = lista);
    } on Exception {
      // Sin conexión: la lista sigue con los lugares.
    }
  }

  List<SosResumen> _sosFiltrados() {
    if (!_filtros.muestraSos) return const [];
    final maximo = _filtros.distancia.metros;
    return [
      for (final r in _sosLista)
        if (maximo == null || r.distanciaMetros <= maximo) r,
    ];
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
  /// Sin sesión no hay mascotas: no se filtra.
  Set<int> _especies() {
    if (!ref.watch(conectadoProvider)) return const {};
    final todas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    if (_filtros.porMascotaActiva) {
      final id = ref.watch(mascotaActivaIdProvider);
      final activa =
          todas.where((m) => m.id == id).firstOrNull ?? todas.firstOrNull;
      if (activa != null) return {activa.especieId};
    }
    return {for (final m in todas) m.especieId};
  }

  /// Mis favoritos (solo con sesión: un visitante no tiene).
  Set<String> _favoritos() => !ref.watch(conectadoProvider)
      ? const {}
      : {
          for (final l
              in (ref.watch(misLugaresProvider).value ?? const {}).values)
            if (l.favorito) l.comercioId,
        };

  List<Comercio> _filtrados() => filtrarComercios(
    _comercios.values,
    _filtros,
    ahora: ref.watch(relojProvider)(),
    desde: _visible?.centro,
    favoritos: _filtros.soloFavoritos ? _favoritos() : const {},
    especies: _especies(),
  );

  List<Pin> _pins() {
    final lugares = [for (final c in _filtrados()) ?c.pin];
    final sinReclamar = [
      for (final l in _sinReclamar.values)
        if (_filtros.muestraCategoria(l.categoria)) l.pin,
    ];
    // Los SOS al final: quedan dibujados encima.
    final todos = [
      ...sinReclamar,
      ...lugares,
      if (_filtros.sinChips)
        for (final e in _eventos.values) e.pin,
      if (_filtros.muestraSos) ..._sos,
    ];
    final visible = _visible;
    return visible == null ? todos : agruparPins(todos, visible);
  }

  void _cambiarVista(_Vista vista) {
    setState(() => _vista = vista);
    if (vista == _Vista.lista) unawaited(_cargarSosLista());
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
    final puedeMarcar =
        ref.watch(conectadoProvider) &&
        ref.watch(funcionalidadActivaProvider(Funcionalidades.comercios));
    final mapa = Stack(
      children: [
        MapaVista(
          centro: ref.watch(miZonaProvider),
          pins: _pins(),
          onCamaraQuieta: _alQuedarQuieto,
          onTocarPin: _alTocarPin,
        ),
        const Positioned(left: 8, bottom: 8, child: _Leyenda()),
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
      body: Column(
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
                  sos: _sosFiltrados(),
                  comercios: ordenarParaLista(
                    _filtrados(),
                    ahora: ref.watch(relojProvider)(),
                    desde: _visible?.centro,
                  ),
                  desde: _visible?.centro,
                ),
                // Se arma (y consulta) solo al abrirla.
                if (_vista == _Vista.sinLocal)
                  _SinLocal(filtros: _filtros, especies: _especies())
                else
                  const SizedBox.shrink(),
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
              selected: filtros.sos,
              onSelected: (si) => onCambiar(filtros.copyWith(sos: si)),
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
                    FiltrosMapa(categorias: _f.categorias, sos: _f.sos),
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
  const _Lista({required this.sos, required this.comercios, this.desde});

  /// Perdidos y encontrados primero (lo más urgente), por cercanía.
  final List<SosResumen> sos;
  final List<Comercio> comercios;
  final Punto? desde;

  @override
  Widget build(BuildContext context) => sos.isEmpty && comercios.isEmpty
      ? Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(context.t.mapaListaVacia, textAlign: TextAlign.center),
          ),
        )
      : ListView(
          children: [
            for (final r in sos) TarjetaSos(reporte: r),
            if (sos.isNotEmpty) const SizedBox(height: 12),
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
  const _Leyenda();

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
              (TipoPin.comercio, t.leyendaComercio),
              (TipoPin.aceptaMascotas, t.leyendaAcepta),
              (TipoPin.sinReclamar, t.leyendaSinReclamar),
              (TipoPin.evento, t.leyendaEvento),
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
