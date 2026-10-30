import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/descuentos_repositorio.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/volver.dart';

String textoErrorDescuento(AppLocalizations t, ErrorDescuento e) => switch (e) {
  ErrorDescuento.sinPro => t.descuentoSinPro,
  ErrorDescuento.soloVerificados => t.descuentoSoloVerificados,
  ErrorDescuento.demasiados => t.descuentoDemasiados,
  ErrorDescuento.noDisponible => t.descuentoNoDisponible,
  ErrorDescuento.codigoInexistente => t.packCodigoInexistente,
  ErrorDescuento.usadoHoy => t.descuentoUsadoHoy,
  ErrorDescuento.vencido => t.descuentoVencido,
  ErrorDescuento.sinConexion => t.errorSinConexion,
};

/// Mi plan → Descuentos Pro (2.11, D113): los de los comercios de la zona.
/// Cualquiera los ve; el código lo pide quien tiene Pro o Familia.
class DescuentosProScreen extends ConsumerWidget {
  const DescuentosProScreen({super.key});

  Future<void> _pedir(
    BuildContext context,
    WidgetRef ref,
    DescuentoPro d,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(descuentosRepositorioProvider).pedir(d.id);
      ref
          .read(metricasProvider)
          .track(
            Eventos.discountClaim,
            businessId: d.negocioId,
            targetId: d.id,
          );
      ref.invalidate(descuentosParaMiProvider);
    } on DescuentoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorDescuento(t, e.motivo))),
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
        title: Text(t.descuentosTitulo),
      ),
      body: switch (ref.watch(descuentosParaMiProvider)) {
        AsyncData(value: (:final pro, :final descuentos)) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(pro ? t.descuentosIntroPro : t.descuentosIntroGratis),
            if (!pro)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => context.push(Rutas.miPlan),
                  child: Text(t.miPlanVerPlanes),
                ),
              ),
            if (descuentos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.descuentosSinDescuentos),
              ),
            for (final d in descuentos)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.titulo, style: tema.textTheme.titleMedium),
                      Text([?d.negocio, ?d.direccion].join(' · ')),
                      if (d.descripcion case final texto?) Text(texto),
                      if (pro) ...[
                        const SizedBox(height: 8),
                        switch (d.codigo) {
                          final c? => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.packTuCodigo),
                              SelectableText(
                                c,
                                style: tema.textTheme.headlineMedium,
                              ),
                              Text(
                                t.descuentoMostralo,
                                style: tema.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          null => FilledButton.tonal(
                            onPressed: () => _pedir(context, ref, d),
                            child: Text(t.descuentoQuiero),
                          ),
                        },
                      ],
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

/// Modo comercio → Descuentos Pro: cargarlos y canjear los códigos.
class DescuentosNegocioScreen extends ConsumerStatefulWidget {
  const DescuentosNegocioScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<DescuentosNegocioScreen> createState() =>
      _DescuentosNegocioState();
}

class _DescuentosNegocioState extends ConsumerState<DescuentosNegocioScreen> {
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
          .read(descuentosRepositorioProvider)
          .canjear(widget.negocioId, _codigo.text.trim());
      ref
          .read(metricasProvider)
          .track(Eventos.discountRedeem, businessId: widget.negocioId);
      ref.invalidate(descuentosNegocioProvider(widget.negocioId));
      _codigo.clear();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.descuentoCanjeado),
          content: Text(
            [
              canje.titulo,
              if (canje.cliente case final c?) t.packPara(c),
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
    } on DescuentoException catch (e) {
      _avisar(textoErrorDescuento(t, e.motivo));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _editar([DescuentoPro? d]) async {
    final datos = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (_) => _FormularioDescuento(descuento: d),
    );
    if (datos == null || !mounted) return;
    await _guardar(datos);
  }

  Future<void> _guardar(Map<String, Object?> datos) async {
    final t = context.t;
    try {
      await ref
          .read(descuentosRepositorioProvider)
          .guardar(widget.negocioId, datos);
      ref
          .read(metricasProvider)
          .track(
            Eventos.discountSave,
            businessId: widget.negocioId,
            props: {'activo': datos['active'] != false},
          );
      ref.invalidate(descuentosNegocioProvider(widget.negocioId));
    } on DescuentoException catch (e) {
      _avisar(textoErrorDescuento(t, e.motivo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.descuentosTitulo),
      ),
      body: switch (ref.watch(descuentosNegocioProvider(widget.negocioId))) {
        AsyncData(value: (:final puede, :final descuentos)) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.descuentosNegocioAyuda, style: tema.textTheme.bodySmall),
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
                    t.descuentosTuyos,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                if (puede)
                  TextButton.icon(
                    onPressed: _editar,
                    icon: const Icon(Icons.add_outlined),
                    label: Text(t.descuentoNuevo),
                  ),
              ],
            ),
            // Cargarlos es del dueño; el equipo solo canjea (D117).
            if (!puede && ref.watch(esTitularProvider(widget.negocioId)))
              Text(t.descuentoSoloVerificados),
            if (puede && descuentos.isEmpty) Text(t.descuentosSinPropios),
            for (final d in descuentos)
              Card(
                child: SwitchListTile(
                  title: Text(d.titulo),
                  subtitle: Text(
                    [
                      ?d.descripcion,
                      t.descuentoResumen(d.pedidos, d.usados),
                    ].join('\n'),
                  ),
                  value: d.activo,
                  onChanged: puede
                      ? (v) => _guardar({
                          'id': d.id,
                          'title': d.titulo,
                          'description': d.descripcion,
                          'active': v,
                        })
                      : null,
                  secondary: IconButton(
                    tooltip: t.descuentoEditar,
                    onPressed: puede ? () => _editar(d) : null,
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

class _FormularioDescuento extends StatefulWidget {
  const _FormularioDescuento({this.descuento});

  final DescuentoPro? descuento;

  @override
  State<_FormularioDescuento> createState() => _FormularioDescuentoState();
}

class _FormularioDescuentoState extends State<_FormularioDescuento> {
  late final _titulo = TextEditingController(text: widget.descuento?.titulo);
  late final _descripcion = TextEditingController(
    text: widget.descuento?.descripcion,
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
      title: Text(
        widget.descuento == null ? t.descuentoNuevo : t.descuentoEditar,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titulo,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: t.packTituloCampo,
              hintText: t.descuentoTituloEjemplo,
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
              if (widget.descuento case final d?) 'id': d.id,
              'title': _titulo.text.trim(),
              'description': _descripcion.text.trim(),
              'active': widget.descuento?.activo ?? true,
            });
          },
          child: Text(t.guardar),
        ),
      ],
    );
  }
}

/// En el panel del modo comercio.
class TarjetaDescuentosNegocio extends StatelessWidget {
  const TarjetaDescuentosNegocio({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.local_offer_outlined),
      title: Text(context.t.descuentosTitulo),
      subtitle: Text(context.t.descuentosTarjetaNegocio),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(Rutas.descuentosNegocio(negocioId)),
    ),
  );
}
