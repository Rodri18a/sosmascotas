import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../tienda/tienda_repositorio.dart';
import 'catalogo_screen.dart';

/// Duración legible: "45 min", "1 h", "1 h 30 min".
String textoDuracion(AppLocalizations t, int minutos) {
  final h = minutos ~/ 60;
  final m = minutos % 60;
  if (h == 0) return t.duracionMinutos(m);
  if (m == 0) return t.duracionHoras(h);
  return t.duracionHorasMinutos(h, m);
}

/// "$ 600", "desde $ 600" o "Consultar precio".
String textoPrecioServicio(AppLocalizations t, Servicio s) =>
    switch (s.precio) {
      final p? when s.desde => t.servicioDesde(formatoPrecio(p)),
      final p? => formatoPrecio(p),
      null => t.catalogoConsultarPrecio,
    };

/// Sección "Servicios" de la ficha (2.10a, D90): solo comercios con plan Plus
/// y con la funcionalidad `catalogo`. Cada servicio se "Consulta".
class SeccionServicios extends ConsumerWidget {
  const SeccionServicios({required this.comercio, super.key});

  final Comercio comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo los Plus pueden tener servicios: a los demás no se les pregunta.
    if (comercio.plan != PlanComercio.plus ||
        !ref.watch(funcionalidadActivaProvider(Funcionalidades.catalogo))) {
      return const SizedBox.shrink();
    }
    final servicios = ref.watch(serviciosDeProvider(comercio.id)).value;
    if (servicios == null || servicios.isEmpty) return const SizedBox.shrink();
    final t = context.t;
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.serviciosTitulo, style: tema.textTheme.titleMedium),
          for (final s in servicios)
            ListTile(
              key: ValueKey('servicio-${s.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(s.nombre),
              subtitle: Text(
                [
                  ?s.descripcion,
                  [
                    if (s.duracionMinutos case final m?) textoDuracion(t, m),
                    textoPrecioServicio(t, s),
                  ].join(' · '),
                ].join('\n'),
              ),
              isThreeLine: s.descripcion != null,
              trailing: TextButton(
                onPressed: () {
                  ref
                      .read(metricasProvider)
                      .track(Eventos.serviceAsk, businessId: comercio.id);
                  consultarAlComercio(
                    context,
                    ref,
                    negocioId: comercio.id,
                    comercio: comercio,
                    que: s.nombre,
                  );
                },
                child: Text(t.catalogoConsultar),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modo comercio → Negocio → Servicios: cargar, editar y ocultar servicios.
class ServiciosNegocioScreen extends ConsumerWidget {
  const ServiciosNegocioScreen({required this.negocioId, super.key});

  final String negocioId;

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Servicio? servicio,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) =>
          FormularioServicio(negocioId: negocioId, servicio: servicio),
    );
    if (guardado ?? false) {
      ref
        ..invalidate(misServiciosProvider(negocioId))
        ..invalidate(serviciosDeProvider(negocioId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final negocio = ref
        .watch(misNegociosProvider)
        .value
        ?.where((n) => n.id == negocioId)
        .firstOrNull;
    final esPlus = negocio?.comercio.plan == PlanComercio.plus;
    return Scaffold(
      appBar: AppBar(title: Text(t.serviciosTitulo)),
      floatingActionButton: esPlus
          ? FloatingActionButton.extended(
              onPressed: () => _editar(context, ref),
              icon: const Icon(Icons.add),
              label: Text(t.servicioNuevo),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(esPlus ? t.serviciosAyuda : t.serviciosSoloPlus),
          ),
          const Divider(height: 1),
          switch (ref.watch(misServiciosProvider(negocioId))) {
            AsyncData(value: final lista) when lista.isEmpty =>
              esPlus
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t.serviciosSinCargar,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            AsyncData(value: final lista) => Column(
              children: [
                for (final s in lista)
                  ListTile(
                    key: ValueKey('mi-servicio-${s.id}'),
                    leading: const Icon(Icons.design_services_outlined),
                    title: Text(s.nombre),
                    subtitle: Text(
                      [
                        if (s.duracionMinutos case final m?)
                          textoDuracion(t, m),
                        textoPrecioServicio(t, s),
                        if (!s.disponible) t.servicioOculto,
                      ].join(' · '),
                    ),
                    trailing: esPlus ? const Icon(Icons.edit_outlined) : null,
                    onTap: esPlus ? () => _editar(context, ref, s) : null,
                  ),
              ],
            ),
            AsyncError() => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(t.errorSinConexion, textAlign: TextAlign.center),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ],
      ),
    );
  }
}

/// Duraciones que se ofrecen al cargar un servicio (en minutos).
const _duraciones = [15, 30, 45, 60, 90, 120, 180, 240, 480, 1440];

class FormularioServicio extends ConsumerStatefulWidget {
  const FormularioServicio({required this.negocioId, this.servicio, super.key});

  final String negocioId;
  final Servicio? servicio;

  @override
  ConsumerState<FormularioServicio> createState() => _FormularioServicioState();
}

class _FormularioServicioState extends ConsumerState<FormularioServicio> {
  late final _nombre = TextEditingController(text: widget.servicio?.nombre);
  late final _descripcion = TextEditingController(
    text: widget.servicio?.descripcion,
  );
  late final _precio = TextEditingController(
    text: switch (widget.servicio?.precio) {
      final p? when p == p.roundToDouble() => p.toInt().toString(),
      final p? => p.toStringAsFixed(2).replaceAll('.', ','),
      null => '',
    },
  );
  late var _desde = widget.servicio?.desde ?? false;
  late int? _duracion = widget.servicio?.duracionMinutos;
  late var _disponible = widget.servicio?.disponible ?? true;
  String? _error;
  var _guardando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _precio]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "1.780,50" o "1780.5" → 1780.5; vacío → sin precio ("Consultar").
  double? _leerPrecio() {
    final texto = _precio.text.trim().replaceAll(r'$', '').replaceAll(' ', '');
    if (texto.isEmpty) return null;
    final normal = texto.contains(',')
        ? texto.replaceAll('.', '').replaceAll(',', '.')
        : texto;
    return double.tryParse(normal);
  }

  Future<void> _guardar() async {
    final t = context.t;
    final precio = _leerPrecio();
    if (_nombre.text.trim().length < 2 ||
        (_precio.text.trim().isNotEmpty && (precio == null || precio < 0))) {
      setState(() => _error = t.productoDatosInvalidos);
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref
          .read(tiendaRepositorioProvider)
          .guardarServicio(
            widget.negocioId,
            Servicio(
              id: widget.servicio?.id ?? '',
              nombre: _nombre.text.trim(),
              descripcion: _descripcion.text.trim().isEmpty
                  ? null
                  : _descripcion.text.trim(),
              precio: precio,
              desde: _desde,
              duracionMinutos: _duracion,
              disponible: _disponible,
              orden: widget.servicio?.orden ?? 0,
            ),
          );
      ref
          .read(metricasProvider)
          .track(Eventos.serviceSave, businessId: widget.negocioId);
      if (mounted) Navigator.pop(context, true);
    } on TiendaException catch (e) {
      setState(() {
        _guardando = false;
        _error = switch (e.motivo) {
          ErrorTienda.soloPlus => context.t.serviciosSoloPlus,
          ErrorTienda.limite => context.t.servicioLimite,
          _ => context.t.productoDatosInvalidos,
        };
      });
    } on Exception {
      setState(() {
        _guardando = false;
        _error = context.t.errorSinConexion;
      });
    }
  }

  Future<void> _borrar() async {
    final id = widget.servicio?.id;
    if (id == null) return;
    try {
      await ref.read(tiendaRepositorioProvider).borrarServicio(id);
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      setState(() => _error = context.t.errorSinConexion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final conPrecio = _precio.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.servicio == null ? t.servicioNuevo : t.servicioEditar),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nombre,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: t.productoNombre,
                  hintText: t.servicioNombreAyuda,
                ),
              ),
              TextField(
                controller: _descripcion,
                maxLength: 500,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(labelText: t.productoDescripcion),
              ),
              TextField(
                controller: _precio,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: t.productoPrecio,
                  helperText: t.servicioPrecioAyuda,
                  prefixText: r'$ ',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(t.servicioPrecioDesde),
                value: _desde && conPrecio,
                onChanged: conPrecio
                    ? (v) => setState(() => _desde = v ?? false)
                    : null,
              ),
              DropdownButtonFormField<int?>(
                initialValue: _duracion,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.servicioDuracion),
                items: [
                  DropdownMenuItem(child: Text(t.servicioSinDuracion)),
                  for (final m in {..._duraciones, ?_duracion})
                    DropdownMenuItem(
                      value: m,
                      child: Text(textoDuracion(t, m)),
                    ),
                ],
                onChanged: (v) => setState(() => _duracion = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.servicioVisible),
                value: _disponible,
                onChanged: (v) => setState(() => _disponible = v),
              ),
              if (_error case final e?)
                Text(
                  e,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.servicio != null)
          TextButton(onPressed: _borrar, child: Text(t.productoBorrar)),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(t.guardar),
        ),
      ],
    );
  }
}
