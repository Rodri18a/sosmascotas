import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/volver.dart';
import 'mapa_screen.dart';

/// Búsqueda de lugares por nombre o rubro (1.8.7, D97), cerca de [desde]
/// (el centro del mapa). Consulta la base, no Google (regla de costo).
class BuscarLugaresScreen extends ConsumerStatefulWidget {
  const BuscarLugaresScreen({required this.desde, super.key});

  final Punto desde;

  @override
  ConsumerState<BuscarLugaresScreen> createState() => _BuscarLugaresState();
}

class _BuscarLugaresState extends ConsumerState<BuscarLugaresScreen> {
  /// Espera entre letras antes de consultar.
  static const _pausaConsulta = Duration(milliseconds: 400);

  /// Una búsqueda cuenta para la métrica cuando se deja de escribir.
  static const _pausaMetrica = Duration(milliseconds: 1500);

  final _texto = TextEditingController();
  late final Metricas _metricas;
  Timer? _consulta;
  Timer? _metrica;
  void Function()? _registrarPendiente;

  String _buscado = '';
  Categoria? _rubro;
  List<Comercio>? _lugares;
  bool _buscando = false;
  bool _sinConexion = false;

  @override
  void initState() {
    super.initState();
    // Se lee acá porque dispose() puede registrar la última búsqueda.
    _metricas = ref.read(metricasProvider);
  }

  @override
  void dispose() {
    _consulta?.cancel();
    _metrica?.cancel();
    // Si salió apenas vio el resultado, la búsqueda igual cuenta.
    _registrarPendiente?.call();
    _texto.dispose();
    super.dispose();
  }

  void _alEscribir(String texto) {
    _consulta?.cancel();
    if (normalizarBusqueda(texto).length < minimoBusqueda) {
      _metrica?.cancel();
      _registrarPendiente = null;
      setState(() {
        _buscado = '';
        _lugares = null;
        _buscando = false;
        _sinConexion = false;
      });
      return;
    }
    setState(() => _buscando = true);
    _consulta = Timer(_pausaConsulta, () => unawaited(_buscar(texto)));
  }

  Future<void> _buscar(String texto) async {
    final rubro = rubroDeBusqueda(texto);
    try {
      final r = await ref
          .read(comerciosRepositorioProvider)
          .buscar(texto, desde: widget.desde, rubro: rubro);
      if (!mounted || texto != _texto.text) return;
      setState(() {
        _buscado = texto;
        _rubro = rubro;
        _lugares = r.lugares;
        _buscando = false;
        _sinConexion = false;
      });
      _programarMetrica(texto, rubro, r.lugares.length, r.zona);
    } on Exception {
      if (mounted) {
        setState(() {
          _buscando = false;
          _sinConexion = true;
        });
      }
    }
  }

  /// Métrica `search`: rubro, zona y cantidad. El texto solo si no hubo
  /// resultados ni rubro, limpio de números y cortado (D97).
  void _programarMetrica(String texto, Categoria? rubro, int n, int? zona) {
    _metrica?.cancel();
    void registrar() {
      _registrarPendiente = null;
      _metricas.track(
        Eventos.search,
        zoneId: zona,
        props: {
          'rubro': ?rubro?.valor,
          'resultados': n,
          if (n == 0 && rubro == null) 'texto': ?textoParaMetrica(texto),
        },
      );
    }

    _registrarPendiente = registrar;
    _metrica = Timer(_pausaMetrica, registrar);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lugares = _lugares;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: TextField(
          controller: _texto,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: t.buscarPista,
            border: InputBorder.none,
          ),
          onChanged: _alEscribir,
        ),
        actions: [
          if (_texto.text.isNotEmpty)
            IconButton(
              tooltip: t.buscarBorrar,
              icon: const Icon(Icons.close_outlined),
              onPressed: () {
                _texto.clear();
                _alEscribir('');
              },
            ),
        ],
        bottom: _buscando
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: switch (lugares) {
        _ when _sinConexion => _Mensaje(t.errorSinConexion),
        null => _Mensaje(t.buscarAyuda),
        [] => _SinResultados(texto: _buscado, rubro: _rubro),
        _ => ListView(
          children: [
            if (_rubro case final r?)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  t.buscarIncluyeRubro(textoCategorias(t, r).toLowerCase()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            for (final c in lugares)
              FilaLugar(comercio: c, desde: widget.desde),
          ],
        ),
      },
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Text(texto, textAlign: TextAlign.center),
  );
}

/// Sin resultados: si tiene cuenta (y los comercios prendidos), puede marcar
/// el lugar que conoce.
class _SinResultados extends ConsumerWidget {
  const _SinResultados({required this.texto, this.rubro});

  final String texto;
  final Categoria? rubro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final puedeMarcar =
        ref.watch(conectadoProvider) &&
        ref.watch(funcionalidadActivaProvider(Funcionalidades.comercios));
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(switch (rubro) {
            final r? => t.buscarSinRubro(textoCategorias(t, r).toLowerCase()),
            null => t.buscarSinResultados(texto),
          }, textAlign: TextAlign.center),
          if (puedeMarcar) ...[
            const SizedBox(height: 16),
            Text(t.buscarConocesUno, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.push(Rutas.marcarLugar),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(t.marcarLugar),
            ),
          ],
        ],
      ),
    );
  }
}
