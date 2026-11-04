import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/promociones_repositorio.dart';
import '../../comunidad/comunidad_repositorio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../recorrido/recorrido.dart';
import '../../router.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/volver.dart';
import '../noticias/tarjeta_promocion.dart';
import 'comunidad_screen.dart' show textoErrorComunidad;

String textoTema(AppLocalizations t, TemaPregunta tema) => switch (tema) {
  TemaPregunta.viajes => t.temaViajes,
  TemaPregunta.salud => t.temaSalud,
  TemaPregunta.alimentacion => t.temaAlimentacion,
  TemaPregunta.adopcion => t.temaAdopcion,
  TemaPregunta.tramites => t.temaTramites,
  TemaPregunta.otros => t.temaOtros,
};

IconData iconoTema(TemaPregunta tema) => switch (tema) {
  TemaPregunta.viajes => Icons.flight_outlined,
  TemaPregunta.salud => Icons.medical_services_outlined,
  TemaPregunta.alimentacion => Icons.restaurant_outlined,
  TemaPregunta.adopcion => Icons.volunteer_activism_outlined,
  TemaPregunta.tramites => Icons.description_outlined,
  TemaPregunta.otros => Icons.help_outline,
};

/// Preguntas con un tema y un texto a buscar.
final preguntasProvider = FutureProvider.autoDispose
    .family<List<Publicacion>, ({TemaPregunta? tema, String buscar})>(
      (ref, filtro) => ref
          .watch(comunidadRepositorioProvider)
          .preguntas(tema: filtro.tema, buscar: filtro.buscar),
    );

/// Entrada a las Preguntas desde Inicio → Comunidad (D134).
class TarjetaPreguntas extends StatelessWidget {
  const TarjetaPreguntas({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.contact_support_outlined),
        title: Text(t.preguntasTarjeta),
        subtitle: Text(
          t.preguntasTarjetaAyuda,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () => context.push(Rutas.preguntas),
      ),
    );
  }
}

/// Preguntas de la comunidad (plan de mejoras 2.3, D134): temas, buscador y
/// la lista; tocar una abre la publicación con sus respuestas.
class PreguntasScreen extends ConsumerStatefulWidget {
  const PreguntasScreen({super.key});

  @override
  ConsumerState<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends ConsumerState<PreguntasScreen> {
  final _buscar = TextEditingController();
  TemaPregunta? _tema;
  var _texto = '';

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  void _buscarAhora(String texto) {
    setState(() => _texto = texto.trim());
    if (_texto.isNotEmpty) {
      ref
          .read(metricasProvider)
          .track(Eventos.questionSearch, props: {'topic': ?_tema?.base});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final lista = ref.watch(preguntasProvider((tema: _tema, buscar: _texto)));
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.preguntasTitulo),
        actions: const [BotonAyuda()],
      ),
      floatingActionButton: MarcaRecorrido(
        'accion',
        child: FloatingActionButton.extended(
          onPressed: () => abrirConCuenta(
            context,
            ref,
            destino: Rutas.nuevaPregunta,
            motivo: t.preguntasMotivoCuenta,
          ),
          icon: const Icon(Icons.add_comment_outlined),
          label: Text(t.preguntasPreguntar),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(preguntasProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _buscar,
                textInputAction: TextInputAction.search,
                onSubmitted: _buscarAhora,
                decoration: InputDecoration(
                  hintText: t.preguntasBuscar,
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: _texto.isEmpty
                      ? null
                      : IconButton(
                          tooltip: t.buscarBorrar,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _buscar.clear();
                            _buscarAhora('');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  ChoiceChip(
                    label: Text(t.preguntasTodas),
                    selected: _tema == null,
                    onSelected: (_) => setState(() => _tema = null),
                  ),
                  for (final tm in TemaPregunta.values) ...[
                    const SizedBox(width: 6),
                    ChoiceChip(
                      avatar: Icon(iconoTema(tm), size: 18),
                      label: Text(textoTema(t, tm)),
                      selected: _tema == tm,
                      onSelected: (_) => setState(() => _tema = tm),
                    ),
                  ],
                ],
              ),
            ),
            switch (lista) {
              AsyncData(value: final ps) when ps.isEmpty => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _texto.isEmpty ? t.preguntasVacio : t.preguntasSinResultados,
                  textAlign: TextAlign.center,
                ),
              ),
              AsyncData(value: final ps) => Column(
                children: [
                  // Una promoción cada 8 preguntas (3.2, D137).
                  for (final x in intercalarPromociones(
                    ps,
                    ref.watch(
                          funcionalidadActivaProvider(
                            Funcionalidades.promociones,
                          ),
                        )
                        ? ref.watch(promocionesCercaProvider).value ??
                              const <Promocion>[]
                        : const <Promocion>[],
                    cada: 8,
                  ))
                    if (x case final Promocion promo)
                      TarjetaPromocion(
                        key: ValueKey('promo-p-${promo.id}'),
                        promocion: promo,
                      )
                    else if (x case final Publicacion p)
                      ListTile(
                        leading: Icon(
                          iconoTema(p.tema ?? TemaPregunta.otros),
                          color: tema.colorScheme.primary,
                        ),
                        title: Text(
                          p.texto,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            if (p.tema case final tm?) textoTema(t, tm),
                            t.preguntasRespuestas(p.cantidadComentarios),
                            if (p.resuelta) '✓ ${t.preguntasResuelta}',
                            if (p.conProfesional) t.preguntasConProfesional,
                          ].join(' · '),
                        ),
                        onTap: () =>
                            context.push(Rutas.publicacionComunidad(p.id)),
                      ),
                ],
              ),
              AsyncError() => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(t.errorSinConexion, textAlign: TextAlign.center),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

/// Hacer una pregunta: tema, texto y en qué grupo (por defecto «Preguntas
/// generales»).
class NuevaPreguntaScreen extends ConsumerStatefulWidget {
  const NuevaPreguntaScreen({super.key});

  @override
  ConsumerState<NuevaPreguntaScreen> createState() =>
      _NuevaPreguntaScreenState();
}

class _NuevaPreguntaScreenState extends ConsumerState<NuevaPreguntaScreen> {
  final _texto = TextEditingController();
  TemaPregunta? _tema;
  String? _grupoId;
  var _enviando = false;
  String? _error;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = context.t;
    final texto = _texto.text.trim();
    final temaElegido = _tema;
    if (temaElegido == null || texto.isEmpty) {
      setState(() => _error = t.preguntasFaltan);
      return;
    }
    if (textoProhibidoComunidad(texto)) {
      setState(() => _error = t.comunidadProhibido);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(comunidadRepositorioProvider)
          .preguntar(tema: temaElegido, texto: texto, grupoId: _grupoId);
      ref
          .read(metricasProvider)
          .track(Eventos.questionCreate, props: {'topic': temaElegido.base});
      ref
        ..invalidate(preguntasProvider)
        ..invalidate(gruposProvider);
      if (mounted) context.pushReplacement(Rutas.publicacionComunidad(id));
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _error = textoErrorComunidad(t, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final misGrupos = [
      for (final g in ref.watch(gruposProvider).value ?? const <Grupo>[])
        if (g.soyMiembro) g,
    ];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context, Rutas.preguntas),
        title: Text(t.preguntasNueva),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.preguntasTema, style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tm in TemaPregunta.values)
                  ChoiceChip(
                    avatar: Icon(iconoTema(tm), size: 18),
                    label: Text(textoTema(t, tm)),
                    selected: _tema == tm,
                    onSelected: (_) => setState(() => _tema = tm),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _texto,
              maxLength: 2000,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.preguntasTexto,
                helperText: t.preguntasTextoAyuda,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _grupoId,
              isExpanded: true,
              decoration: InputDecoration(labelText: t.preguntasDonde),
              items: [
                DropdownMenuItem(child: Text(t.preguntasGenerales)),
                for (final g in misGrupos)
                  DropdownMenuItem(
                    value: g.id,
                    child: Text(g.nombre, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _grupoId = v),
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enviando ? null : _enviar,
              child: Text(_enviando ? t.guardando : t.preguntasPublicar),
            ),
          ],
        ),
      ),
    );
  }
}
