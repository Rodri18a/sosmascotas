import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../adopcion/pack_repositorio.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/explicacion_corta.dart';
import '../../widgets/volver.dart';

String textoErrorPack(AppLocalizations t, ErrorPack e) => switch (e) {
  ErrorPack.sinAdopcion => t.packSinAdopcion,
  ErrorPack.soloVerificados => t.packSoloVerificados,
  ErrorPack.demasiados => t.packDemasiados,
  ErrorPack.noDisponible => t.packNoDisponible,
  ErrorPack.codigoInexistente => t.packCodigoInexistente,
  ErrorPack.codigoUsado => t.packCodigoUsado,
  ErrorPack.sinConexion => t.errorSinConexion,
};

/// Adopción → Pack adopción (3.4b, D107): los beneficios de los comercios de
/// la zona para quien adoptó por la app.
class PackAdopcionScreen extends ConsumerWidget {
  const PackAdopcionScreen({super.key});

  Future<void> _pedir(
    BuildContext context,
    WidgetRef ref,
    BeneficioAdopcion b,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(packAdopcionRepositorioProvider).pedir(b.id);
      ref
          .read(metricasProvider)
          .track(Eventos.perkClaim, businessId: b.negocioId, targetId: b.id);
      ref.invalidate(beneficiosAdopcionProvider);
    } on PackException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorPack(t, e.motivo))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.packTitulo),
      ),
      body: switch (ref.watch(beneficiosAdopcionProvider)) {
        AsyncData(value: (puede: false, beneficios: _)) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.packSinAdopcion, textAlign: TextAlign.center),
          ),
        ),
        AsyncData(value: (puede: true, :final beneficios)) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.packIntro),
            if (beneficios.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.packSinBeneficios),
              ),
            for (final b in beneficios)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.titulo, style: tema.textTheme.titleMedium),
                      Text([?b.negocio, ?b.direccion].join(' · ')),
                      if (b.descripcion case final d?) Text(d),
                      const SizedBox(height: 8),
                      switch (b.codigo) {
                        final c? when b.usado => Text(t.packUsado(c)),
                        final c? => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.packTuCodigo),
                            SelectableText(
                              c,
                              style: tema.textTheme.headlineMedium,
                            ),
                            Text(
                              t.packMostralo,
                              style: tema.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        null => FilledButton.tonal(
                          onPressed: () => _pedir(context, ref, b),
                          child: Text(t.packQuiero),
                        ),
                      },
                    ],
                  ),
                ),
              ),
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

/// Modo comercio → Pack adopción: cargar beneficios y canjear los códigos.
class PackNegocioScreen extends ConsumerStatefulWidget {
  const PackNegocioScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<PackNegocioScreen> createState() => _PackNegocioState();
}

class _PackNegocioState extends ConsumerState<PackNegocioScreen> {
  final _codigo = TextEditingController();
  var _ocupado = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _avisar(String texto) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _canjear() async {
    final t = context.t;
    if (_codigo.text.trim().isEmpty) return;
    setState(() => _ocupado = true);
    try {
      final canje = await ref
          .read(packAdopcionRepositorioProvider)
          .canjear(widget.negocioId, _codigo.text.trim());
      ref
          .read(metricasProvider)
          .track(Eventos.perkRedeem, businessId: widget.negocioId);
      ref.invalidate(beneficiosNegocioProvider(widget.negocioId));
      _codigo.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.packCanjeado),
          content: Text(
            [
              canje.titulo,
              if (canje.cliente case final c?) t.packPara(c),
              if (canje.animal case final a?) t.packAnimal(a),
            ].join('\n'),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.listo),
            ),
          ],
        ),
      );
    } on PackException catch (e) {
      _avisar(textoErrorPack(t, e.motivo));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _editar([BeneficioAdopcion? b]) async {
    final datos = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (_) => _FormularioBeneficio(beneficio: b),
    );
    if (datos == null || !mounted) return;
    await _guardar(datos);
  }

  Future<void> _guardar(Map<String, Object?> datos) async {
    final t = context.t;
    try {
      await ref
          .read(packAdopcionRepositorioProvider)
          .guardar(widget.negocioId, datos);
      ref
          .read(metricasProvider)
          .track(
            Eventos.perkSave,
            businessId: widget.negocioId,
            props: {'activo': datos['active'] != false},
          );
      ref.invalidate(beneficiosNegocioProvider(widget.negocioId));
    } on PackException catch (e) {
      _avisar(textoErrorPack(t, e.motivo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.packTitulo),
      ),
      body: switch (ref.watch(beneficiosNegocioProvider(widget.negocioId))) {
        AsyncData(value: (:final puede, :final beneficios)) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExplicacionCorta(
              id: 'pack_negocio_ayuda',
              corta: t.packNegocioAyudaCorta,
              larga: t.packNegocioAyuda,
              estilo: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(t.packCanjear, style: tema.textTheme.titleMedium),
            TextField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: t.packCodigo),
              onSubmitted: (_) => _canjear(),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: _ocupado ? null : _canjear,
                child: Text(t.packCanjearBoton),
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.packTusBeneficios,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                if (puede)
                  TextButton.icon(
                    onPressed: _editar,
                    icon: const Icon(Icons.add_outlined),
                    label: Text(t.packNuevo),
                  ),
              ],
            ),
            // Cargarlos es del dueño; el equipo solo canjea (D117).
            if (!puede && ref.watch(esTitularProvider(widget.negocioId)))
              Text(t.packSoloVerificados),
            if (puede && beneficios.isEmpty) Text(t.packSinPropios),
            for (final b in beneficios)
              Card(
                child: SwitchListTile(
                  title: Text(b.titulo),
                  subtitle: Text(
                    [
                      ?b.descripcion,
                      t.packResumen(b.pedidos, b.usados),
                    ].join('\n'),
                  ),
                  value: b.activo,
                  onChanged: puede
                      ? (v) => _guardar({
                          'id': b.id,
                          'title': b.titulo,
                          'description': b.descripcion,
                          'active': v,
                        })
                      : null,
                  secondary: IconButton(
                    tooltip: t.packEditar,
                    onPressed: puede ? () => _editar(b) : null,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              ),
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

class _FormularioBeneficio extends StatefulWidget {
  const _FormularioBeneficio({this.beneficio});

  final BeneficioAdopcion? beneficio;

  @override
  State<_FormularioBeneficio> createState() => _FormularioBeneficioState();
}

class _FormularioBeneficioState extends State<_FormularioBeneficio> {
  late final _titulo = TextEditingController(text: widget.beneficio?.titulo);
  late final _descripcion = TextEditingController(
    text: widget.beneficio?.descripcion,
  );

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(widget.beneficio == null ? t.packNuevo : t.packEditar),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titulo,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: t.packTituloCampo,
              hintText: t.packTituloEjemplo,
            ),
          ),
          TextField(
            controller: _descripcion,
            maxLength: 300,
            maxLines: 2,
            decoration: InputDecoration(labelText: t.packDescripcion),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () {
            if (_titulo.text.trim().isEmpty) return;
            Navigator.pop<Map<String, Object?>>(context, {
              if (widget.beneficio case final b?) 'id': b.id,
              'title': _titulo.text.trim(),
              'description': _descripcion.text.trim(),
              'active': widget.beneficio?.activo ?? true,
            });
          },
          child: Text(t.guardar),
        ),
      ],
    );
  }
}

/// En "Mis solicitudes", cuando ya adoptó por la app.
class TarjetaPackAdopcion extends StatelessWidget {
  const TarjetaPackAdopcion({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.card_giftcard_outlined),
      title: Text(context.t.packTitulo),
      subtitle: Text(context.t.packTarjeta),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(Rutas.packAdopcion),
    ),
  );
}

/// En el panel del modo comercio (rubros que pueden dar un beneficio).
class TarjetaPackNegocio extends StatelessWidget {
  const TarjetaPackNegocio({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.card_giftcard_outlined),
      title: Text(context.t.packTitulo),
      subtitle: Text(context.t.packTarjetaNegocio),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(Rutas.packNegocio(negocioId)),
    ),
  );
}
