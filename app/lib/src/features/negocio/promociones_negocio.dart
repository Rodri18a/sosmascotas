import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/promociones_repositorio.dart';
import '../../metricas/metricas.dart';

/// «Promoción en el muro» en la ficha del panel (plan de mejoras 3.1, D136):
/// Destacado tiene 1 vigente y Plus 2; con Gratis se explica qué incluye.
class SeccionPromociones extends ConsumerWidget {
  const SeccionPromociones({required this.negocio, super.key});

  final MiNegocio negocio;

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Promocion? promocion,
  ]) async {
    final guardada = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(negocio: negocio, promocion: promocion),
    );
    if (guardada ?? false) ref.invalidate(misPromocionesProvider(negocio.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    final tope = Promocion.topeDelPlan(negocio.comercio.plan.name);
    if (tope == 0) {
      return Card(
        margin: const EdgeInsets.only(top: 16),
        child: ListTile(
          leading: const Icon(Icons.campaign_outlined),
          title: Text(t.promoPanelTitulo),
          subtitle: Text(t.promoSoloPlanes),
        ),
      );
    }
    final lista = ref.watch(misPromocionesProvider(negocio.id));
    final vigentes = [
      for (final p in lista.value ?? const <Promocion>[])
        if (p.vigente) p,
    ];
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: Text(t.promoPanelTitulo),
              subtitle: Text(t.promoPanelAyuda(tope)),
            ),
            for (final p in vigentes)
              ListTile(
                title: Text(p.titulo),
                subtitle: Text(
                  [
                    p.texto,
                    if (p.vence case final v?)
                      t.promoHasta(fechas.formatMediumDate(v)),
                  ].join('\n'),
                ),
                isThreeLine: true,
                onTap: () => _editar(context, ref, p),
                trailing: TextButton(
                  onPressed: () async {
                    await ref
                        .read(promocionesRepositorioProvider)
                        .terminar(p.id);
                    ref.invalidate(misPromocionesProvider(negocio.id));
                  },
                  child: Text(
                    t.promoTerminar,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
                ),
              ),
            if (vigentes.length < tope)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () => _editar(context, ref),
                  icon: const Icon(Icons.add_outlined),
                  label: Text(t.promoNueva),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.negocio, this.promocion});

  final MiNegocio negocio;
  final Promocion? promocion;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _titulo = TextEditingController(text: widget.promocion?.titulo);
  late final _texto = TextEditingController(text: widget.promocion?.texto);
  late String? _foto = widget.promocion?.fotoPath;
  var _dias = 7;
  var _guardando = false;
  String? _error;

  @override
  void dispose() {
    _titulo.dispose();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = context.t;
    if (_titulo.text.trim().length < 3 || _texto.text.trim().length < 3) {
      setState(() => _error = t.promoFaltan);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(promocionesRepositorioProvider)
          .guardar(
            id: widget.promocion?.id,
            negocioId: widget.negocio.id,
            titulo: _titulo.text.trim(),
            texto: _texto.text.trim(),
            dias: _dias,
            fotoPath: _foto,
          );
      if (widget.promocion == null) {
        ref
            .read(metricasProvider)
            .track(Eventos.promoCreate, businessId: widget.negocio.id);
      }
      if (mounted) Navigator.pop(context, true);
    } on PromocionException catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = switch (e.motivo) {
            ErrorPromocion.tope => t.promoTope,
            ErrorPromocion.sinPlan => t.promoSoloPlanes,
            ErrorPromocion.otro => t.errorSinConexion,
          };
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = t.errorSinConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final fotos = widget.negocio.comercio.fotos;
    final repo = ref.read(comerciosRepositorioProvider);
    return AlertDialog(
      title: Text(widget.promocion == null ? t.promoNueva : t.promoEditar),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titulo,
                maxLength: 60,
                decoration: InputDecoration(labelText: t.promoTitulo),
              ),
              TextField(
                controller: _texto,
                maxLength: 200,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: t.promoTexto),
              ),
              Text(t.promoDuracion, style: tema.textTheme.titleSmall),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                segments: [
                  for (final d in const [7, 15, 30])
                    ButtonSegment(value: d, label: Text(t.promoDias(d))),
                ],
                selected: {_dias},
                onSelectionChanged: (s) => setState(() => _dias = s.first),
              ),
              if (fotos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(t.promoFoto, style: tema.textTheme.titleSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(t.promoSinFoto),
                      selected: _foto == null,
                      onSelected: (_) => setState(() => _foto = null),
                    ),
                    for (final f in fotos)
                      ChoiceChip(
                        avatar: ClipOval(
                          child: Image.network(
                            repo.urlFoto(f),
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            // Si la foto no carga, el chip queda igual.
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.image_outlined, size: 18),
                          ),
                        ),
                        label: Text(t.promoFotoN(fotos.indexOf(f) + 1)),
                        selected: _foto == f,
                        onSelected: (_) => setState(() => _foto = f),
                      ),
                  ],
                ),
              ],
              if (_error case final e?) ...[
                const SizedBox(height: 8),
                Text(e, style: TextStyle(color: tema.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(t.promoPublicar),
        ),
      ],
    );
  }
}
