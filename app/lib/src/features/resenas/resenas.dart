import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/resenas_repositorio.dart';
import '../../metricas/metricas.dart';

/// "4,5 ★ · 12 reseñas".
String textoPromedio(AppLocalizations t, List<Resena> resenas) =>
    t.resenasPromedio(
      (promedioEstrellas(resenas) ?? 0).toStringAsFixed(1).replaceAll('.', ','),
      resenas.length,
    );

/// Reseñas de un comercio (1.7, D78). Con [comoComercio], el dueño las
/// responde (una vez, en público); si no, se pueden escribir (con contacto
/// real) y reportar.
class SeccionResenas extends ConsumerWidget {
  const SeccionResenas({
    required this.comercioId,
    this.comoComercio = false,
    super.key,
  });

  final String comercioId;
  final bool comoComercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final resenas = ref.watch(resenasProvider(comercioId)).value ?? const [];
    final puedo =
        !comoComercio &&
        (ref.watch(puedoResenarProvider(comercioId)).value ?? false);
    final mia = resenas.where((r) => r.mia).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(t.resenasTitulo, style: tema.textTheme.titleMedium),
            if (resenas.isNotEmpty)
              Text(textoPromedio(t, resenas), style: tema.textTheme.bodySmall),
          ],
        ),
        if (resenas.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(t.resenasVacio),
          ),
        for (final r in resenas)
          _Resena(
            resena: r,
            comercioId: comercioId,
            comoComercio: comoComercio,
          ),
        if (puedo)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => _escribir(context, ref, mia),
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(mia == null ? t.resenaEscribir : t.resenaEditar),
            ),
          )
        else if (!comoComercio && mia == null)
          Text(t.resenaSoloConContacto, style: tema.textTheme.bodySmall),
      ],
    );
  }

  Future<void> _escribir(
    BuildContext context,
    WidgetRef ref,
    Resena? mia,
  ) async {
    final t = context.t;
    final resultado = await showDialog<(int, String)>(
      context: context,
      builder: (_) => _DialogoResena(inicial: mia),
    );
    if (resultado == null || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(resenasRepositorioProvider)
          .guardar(
            comercioId,
            resultado.$1,
            resultado.$2.trim().isEmpty ? null : resultado.$2.trim(),
          );
      if (mia == null) {
        ref
            .read(metricasProvider)
            .track(
              Eventos.reviewCreate,
              businessId: comercioId,
              props: {'estrellas': resultado.$1},
            );
      }
      mensajes.showSnackBar(SnackBar(content: Text(t.resenaPublicada)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(resenasProvider(comercioId));
  }
}

class _Resena extends ConsumerWidget {
  const _Resena({
    required this.resena,
    required this.comercioId,
    required this.comoComercio,
  });

  final Resena resena;
  final String comercioId;
  final bool comoComercio;

  Future<void> _responder(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final texto = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.resenaResponder),
        content: TextField(
          controller: texto,
          maxLength: 1000,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(labelText: t.resenaRespuestaCampo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.resenaResponder),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || texto.text.trim().isEmpty || !context.mounted) {
      return;
    }
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(resenasRepositorioProvider)
          .responder(resena.id, texto.text);
      ref
          .read(metricasProvider)
          .track(Eventos.reviewReply, businessId: comercioId);
      mensajes.showSnackBar(SnackBar(content: Text(t.resenaRespondida)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(resenasProvider(comercioId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: t.resenaEstrellas(resena.estrellas),
                child: ExcludeSemantics(
                  child: Text(
                    '★' * resena.estrellas + '☆' * (5 - resena.estrellas),
                    style: TextStyle(color: tema.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resena.mia ? t.resenaMia : t.resenaDe(resena.autor),
                  style: tema.textTheme.bodySmall,
                ),
              ),
              if (!comoComercio && !resena.mia)
                IconButton(
                  tooltip: t.resenaReportar,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  onPressed: () async {
                    final mensajes = ScaffoldMessenger.of(context);
                    try {
                      await ref
                          .read(resenasRepositorioProvider)
                          .reportar(resena.id, 'reseña');
                    } on Exception {
                      // Igual se agradece: ya estaba reportada.
                    }
                    mensajes.showSnackBar(
                      SnackBar(content: Text(t.resenaReportada)),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined),
                ),
            ],
          ),
          if (resena.comentario case final c?) Text(c),
          if (resena.respuesta case final r?)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                '${t.resenaRespuesta}: $r',
                style: tema.textTheme.bodySmall,
              ),
            )
          else if (comoComercio)
            TextButton(
              onPressed: () => _responder(context, ref),
              child: Text(t.resenaResponder),
            ),
        ],
      ),
    );
  }
}

class _DialogoResena extends StatefulWidget {
  const _DialogoResena({this.inicial});

  final Resena? inicial;

  @override
  State<_DialogoResena> createState() => _DialogoResenaState();
}

class _DialogoResenaState extends State<_DialogoResena> {
  late var _estrellas = widget.inicial?.estrellas ?? 5;
  late final _comentario = TextEditingController(
    text: widget.inicial?.comentario,
  );

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.inicial == null ? t.resenaEscribir : t.resenaEditar),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Wrap: en pantallas angostas las 5 estrellas no entran en una fila.
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: t.resenaEstrellas(i),
                  onPressed: () => setState(() => _estrellas = i),
                  icon: Icon(i <= _estrellas ? Icons.star : Icons.star_border),
                ),
            ],
          ),
          TextField(
            controller: _comentario,
            maxLength: 1000,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: t.resenaComentario),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (_estrellas, _comentario.text)),
          child: Text(t.resenaPublicar),
        ),
      ],
    );
  }
}
