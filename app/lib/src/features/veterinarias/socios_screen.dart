import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../mascotas/catalogo.dart';
import '../../metricas/metricas.dart';
import '../../utiles/enlaces.dart';
import '../../veterinarias/veterinarias_repositorio.dart';
import '../../widgets/explicacion_corta.dart';

/// Modo comercio de una veterinaria (2.6, D81): el módulo Socios (plan Plus),
/// sus mascotas socias con "Recordar" y "Busco veterinaria".
class SociosScreen extends ConsumerWidget {
  const SociosScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final negocio = (ref.watch(misNegociosProvider).value ?? const [])
        .where((n) => n.id == negocioId)
        .firstOrNull;
    if (negocio == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.sociosTitulo)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final c = negocio.comercio;
    final prendido =
        ref
            .watch(modulosPrendidosProvider(negocioId))
            .value
            ?.contains(Modulo.socios) ??
        false;
    final esPlus = c.plan == PlanComercio.plus;
    final activo = moduloActivo(
      c.categoria,
      c.modalidad,
      c.plan,
      Modulo.socios,
      prendido: prendido,
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.sociosTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: Text(t.sociosModulo),
              subtitle: Text(esPlus ? t.sociosModuloAyuda : t.sociosSoloPlus),
              value: activo,
              // Prender el módulo es del dueño; el equipo atiende (D117).
              onChanged: esPlus && negocio.esTitular
                  ? (si) async {
                      final mensajes = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(veterinariasRepositorioProvider)
                            .prenderModulo(negocioId, Modulo.socios, si);
                        ref.read(metricasProvider).track(Eventos.moduleToggle);
                      } on Object {
                        mensajes.showSnackBar(
                          SnackBar(content: Text(t.errorDesconocido)),
                        );
                      }
                      ref.invalidate(modulosPrendidosProvider(negocioId));
                    }
                  : null,
            ),
          ),
          if (activo) ...[
            const SizedBox(height: 12),
            _Socios(negocioId: negocioId),
            if (negocio.esTitular) ...[
              const SizedBox(height: 12),
              _Demanda(negocioId: negocioId),
            ],
          ],
        ],
      ),
    );
  }
}

class _Socios extends ConsumerWidget {
  const _Socios({required this.negocioId});

  final String negocioId;

  Future<void> _recordar(
    BuildContext context,
    WidgetRef ref,
    Socio socio,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final hoy = ref.read(relojProvider)();
    final datos = await showDialog<(String, DateTime)>(
      context: context,
      builder: (_) => _DialogoRecordar(
        socio: socio,
        inicial: DateTime(hoy.year, hoy.month, hoy.day + 7, 10),
        hoy: hoy,
      ),
    );
    if (datos == null) return;
    try {
      await ref
          .read(veterinariasRepositorioProvider)
          .recordar(negocioId, socio.mascotaId, datos.$1, datos.$2);
      ref.read(metricasProvider).track(Eventos.vetRemind);
      mensajes.showSnackBar(SnackBar(content: Text(t.sociosRecordado)));
    } on VeterinariasException catch (e) {
      mensajes.showSnackBar(
        SnackBar(
          content: Text(
            e.tipo == ErrorVeterinarias.limite
                ? t.sociosDemasiados
                : t.errorDesconocido,
          ),
        ),
      );
    } on Object {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorDesconocido)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(t.sociosTitulo, style: tema.textTheme.titleMedium),
            ),
            switch (ref.watch(sociosProvider(negocioId))) {
              AsyncData(value: final lista) when lista.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.sociosVacio),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  for (final s in lista)
                    ListTile(
                      leading: Text(
                        especies
                                .where((e) => e.id == s.especieId)
                                .firstOrNull
                                ?.icono ??
                            '',
                        style: tema.textTheme.titleLarge,
                      ),
                      title: Text(s.nombre),
                      subtitle: Text(
                        [
                          if (s.duenio case final d?) t.sociosDeDuenio(d),
                          switch ((s.proximo, s.proximoQue)) {
                            (final f?, final q?) => t.sociosProximo(
                              q,
                              l.formatMediumDate(f),
                            ),
                            _ => t.sociosSinProximo,
                          },
                        ].join(' · '),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: t.sociosRecordar,
                        icon: const Icon(Icons.notification_add_outlined),
                        onPressed: () => _recordar(context, ref, s),
                      ),
                    ),
                ],
              ),
              AsyncLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              _ => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.errorSinConexion),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _DialogoRecordar extends StatefulWidget {
  const _DialogoRecordar({
    required this.socio,
    required this.inicial,
    required this.hoy,
  });

  final Socio socio;
  final DateTime inicial;
  final DateTime hoy;

  @override
  State<_DialogoRecordar> createState() => _DialogoRecordarState();
}

class _DialogoRecordarState extends State<_DialogoRecordar> {
  late final _titulo = TextEditingController(text: widget.socio.proximoQue);
  late var _cuando = widget.inicial;

  @override
  void dispose() {
    _titulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final l = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(t.sociosRecordarTitulo(widget.socio.nombre)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titulo,
            maxLength: 60,
            decoration: InputDecoration(labelText: t.sociosRecordarQue),
            onChanged: (_) => setState(() {}),
          ),
          Text(t.sociosRecordarFecha(l.formatMediumDate(_cuando))),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () async {
                final dia = await showDatePicker(
                  context: context,
                  initialDate: _cuando,
                  firstDate: widget.hoy,
                  lastDate: widget.hoy.add(const Duration(days: 360)),
                );
                if (dia != null) {
                  setState(
                    () => _cuando = DateTime(dia.year, dia.month, dia.day, 10),
                  );
                }
              },
              child: Text(t.sociosElegirFecha),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _titulo.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop((_titulo.text.trim(), _cuando)),
          child: Text(t.sociosRecordar),
        ),
      ],
    );
  }
}

class _Demanda extends ConsumerStatefulWidget {
  const _Demanda({required this.negocioId});

  final String negocioId;

  @override
  ConsumerState<_Demanda> createState() => _DemandaState();
}

class _DemandaState extends ConsumerState<_Demanda> {
  final _mensaje = TextEditingController();
  var _enviando = false;

  @override
  void dispose() {
    _mensaje.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      final n = await ref
          .read(veterinariasRepositorioProvider)
          .enviarPropuesta(widget.negocioId, _mensaje.text.trim());
      ref.read(metricasProvider).track(Eventos.vetProposalSend);
      _mensaje.clear();
      mensajes.showSnackBar(SnackBar(content: Text(t.propuestaEnviada(n))));
    } on VeterinariasException catch (e) {
      mensajes.showSnackBar(
        SnackBar(
          content: Text(
            e.tipo == ErrorVeterinarias.limite
                ? t.propuestaLimite
                : t.errorDesconocido,
          ),
        ),
      );
    } on Object {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorDesconocido)));
    }
    ref.invalidate(resultadosPropuestasProvider(widget.negocioId));
    if (mounted) setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final demanda =
        ref.watch(demandaProvider(widget.negocioId)).value ?? const [];
    final resultados =
        ref.watch(resultadosPropuestasProvider(widget.negocioId)).value ??
        const [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.demandaTitulo, style: tema.textTheme.titleMedium),
            ExplicacionCorta(
              id: 'demanda_ayuda',
              corta: t.demandaAyudaCorta,
              larga: t.demandaAyuda,
              estilo: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (demanda.isEmpty) Text(t.demandaVacia),
            for (final d in demanda)
              Text(
                t.demandaFila(
                  especies
                          .where((e) => e.id == d.especieId)
                          .firstOrNull
                          ?.nombre ??
                      '',
                  d.cantidad,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _mensaje,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: t.propuestaMensaje),
              onChanged: (_) => setState(() {}),
            ),
            FilledButton(
              onPressed: _enviando || _mensaje.text.trim().length < 5
                  ? null
                  : _enviar,
              child: Text(t.propuestaEnviar),
            ),
            for (final r in resultados)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(r.mensaje),
                subtitle: Text(
                  t.propuestaResultado(r.enviadas, r.vistas, r.aceptadas),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
