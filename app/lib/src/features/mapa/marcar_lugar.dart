import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mapa/mapa_vista.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/volver.dart';

/// Marcar un lugar que no está en el mapa (1.3.2): solo el rubro y el punto.
class MarcarLugarScreen extends ConsumerStatefulWidget {
  const MarcarLugarScreen({super.key});

  @override
  ConsumerState<MarcarLugarScreen> createState() => _MarcarLugarScreenState();
}

class _MarcarLugarScreenState extends ConsumerState<MarcarLugarScreen> {
  final _enlace = TextEditingController();
  var _rubro = Categoria.vet;
  Punto? _punto;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _enlace.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = context.t;
    final punto = _punto;
    if (punto == null) {
      setState(() => _error = t.marcarFaltaPunto);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(comerciosRepositorioProvider)
          .marcar(
            _rubro,
            punto,
            enlaceGoogle: _enlace.text.trim().isEmpty
                ? null
                : _enlace.text.trim(),
          );
      ref
          .read(metricasProvider)
          .track(Eventos.placeMark, props: {'tipo': _rubro.valor});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.marcarListo)));
      context.pop(true);
    } on LugarException catch (e) {
      setState(
        () => _error = switch (e.motivo) {
          ErrorLugar.yaMarcado => t.marcarYa,
          ErrorLugar.demasiados => t.marcarDemasiados,
          ErrorLugar.invalido => t.marcarInvalido,
          ErrorLugar.sinConexion => t.errorSinConexion,
        },
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.marcarLugar),
      ),
      // Todo construido de una vez (formulario corto): el botón siempre existe.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.marcarExplicacion),
            const SizedBox(height: 16),
            Text(t.marcarRubro, style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in Categoria.values)
                  ChoiceChip(
                    avatar: Icon(iconoCategoria(c), size: 18),
                    label: Text(textoCategoria(t, c)),
                    selected: c == _rubro,
                    onSelected: (_) => setState(() => _rubro = c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(t.marcarToca),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MapaVista(
                  centro: ref.watch(miZonaProvider),
                  zoom: 15,
                  seleccion: _punto,
                  onTocarMapa: (p) => setState(() => _punto = p),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _enlace,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: t.marcarEnlace,
                helperText: t.marcarEnlaceAyuda,
              ),
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(t.marcarGuardar),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hoja de un lugar marcado por usuarios que nadie reclamó todavía.
Future<void> mostrarSinReclamar(
  BuildContext context,
  WidgetRef ref,
  LugarSinReclamar lugar,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (context) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.sinReclamarTitulo(textoCategoria(t, lugar.categoria)),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(t.sinReclamarMarcas(lugar.marcas)),
            const SizedBox(height: 16),
            if (lugar.enlaceGoogle case final enlace?)
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(abrirEnlaceProvider)(Uri.parse(enlace)),
                icon: const Icon(Icons.map_outlined),
                label: Text(t.sinReclamarVerGoogle),
              ),
            // Reclamarlo es una acción: con sesión y la funcionalidad
            // `comercios` (verlo es para todos, D84).
            if (ref.read(conectadoProvider) &&
                ref.read(
                  funcionalidadActivaProvider(Funcionalidades.comercios),
                ))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      Rutas.altaNegocio(
                        rubro: lugar.categoria,
                        punto: lugar.punto,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_business_outlined),
                  label: Text(t.sinReclamarEsTuyo),
                ),
              ),
          ],
        ),
      ),
    );
  },
);

/// "¿Es tu negocio? Reclamalo" (1.3.4).
Future<void> reclamarLugar(
  BuildContext context,
  WidgetRef ref,
  Comercio comercio,
) async {
  final t = context.t;
  final rut = TextEditingController();
  final nota = TextEditingController();
  final enviar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.reclamarTitulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.reclamarTexto),
            TextField(
              controller: rut,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.reclamarRut),
            ),
            TextField(
              controller: nota,
              maxLength: 500,
              decoration: InputDecoration(labelText: t.reclamarNota),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.reclamarEnviar),
        ),
      ],
    ),
  );
  if (!(enviar ?? false) || !context.mounted) return;
  final mensajes = ScaffoldMessenger.of(context);
  if (rut.text.trim().isNotEmpty && !rutValido(rut.text)) {
    mensajes.showSnackBar(SnackBar(content: Text(t.reclamarRutInvalido)));
    return;
  }
  try {
    await ref
        .read(comerciosRepositorioProvider)
        .reclamar(
          comercio.id,
          rut: rut.text.trim().isEmpty ? null : rut.text,
          nota: nota.text.trim().isEmpty ? null : nota.text.trim(),
        );
    ref
        .read(metricasProvider)
        .track(Eventos.businessClaim, businessId: comercio.id);
    mensajes.showSnackBar(SnackBar(content: Text(t.reclamarListo)));
  } on LugarException {
    mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
  }
}
