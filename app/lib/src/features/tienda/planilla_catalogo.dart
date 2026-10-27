import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../metricas/metricas.dart';
import '../../tienda/tienda_repositorio.dart';
import '../../utiles/descargar.dart';

String _textoError(AppLocalizations t, ErrorFilaCatalogo e) => switch (e) {
  ErrorFilaCatalogo.sinNombre => t.planillaSinNombre,
  ErrorFilaCatalogo.nombreLargo => t.planillaNombreLargo,
  ErrorFilaCatalogo.precioInvalido => t.planillaPrecioInvalido,
  ErrorFilaCatalogo.repetido => t.planillaRepetido,
};

/// Cargar el catálogo desde una planilla (2.10, portal de empresas, D114):
/// se pega lo copiado de Excel o Google Sheets, se revisa y se confirma.
/// Un producto con el mismo nombre se actualiza (conserva la foto); los demás
/// se suman. Devuelve `true` si cargó algo.
class CargaPlanilla extends ConsumerStatefulWidget {
  const CargaPlanilla({
    required this.negocioId,
    required this.existentes,
    super.key,
  });

  final String negocioId;
  final List<Producto> existentes;

  @override
  ConsumerState<CargaPlanilla> createState() => _CargaPlanillaState();
}

class _CargaPlanillaState extends ConsumerState<CargaPlanilla> {
  final _texto = TextEditingController();
  PlanillaCatalogo? _revisada;
  var _cargando = false;
  var _hechos = 0;
  String? _error;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Producto? _existente(FilaCatalogo f) => widget.existentes
      .where((p) => p.nombre.toLowerCase() == f.nombre.toLowerCase())
      .firstOrNull;

  void _descargarModelo() {
    final ok = descargarArchivo(
      utf8.encode(modeloPlanillaCatalogo),
      'modelo-catalogo.csv',
      'text/csv',
    );
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.historialNoDisponible)));
    }
  }

  Future<void> _cargar(List<FilaCatalogo> filas) async {
    final t = context.t;
    final repo = ref.read(tiendaRepositorioProvider);
    setState(() {
      _cargando = true;
      _error = null;
      _hechos = 0;
    });
    try {
      for (final f in filas) {
        final previo = _existente(f);
        await repo.guardarProducto(
          widget.negocioId,
          Producto(
            id: previo?.id ?? '',
            nombre: f.nombre,
            descripcion: f.descripcion,
            precio: f.precio,
            foto: previo?.foto,
            especieIds: previo?.especieIds ?? const [],
            disponible: f.disponible,
            orden: previo?.orden ?? 0,
          ),
        );
        if (mounted) setState(() => _hechos++);
      }
      ref
          .read(metricasProvider)
          .track(
            Eventos.catalogImport,
            businessId: widget.negocioId,
            props: {'productos': filas.length},
          );
      if (mounted) Navigator.pop(context, true);
    } on TiendaException catch (e) {
      setState(() {
        _cargando = false;
        _error = switch (e.motivo) {
          ErrorTienda.soloPlus => t.moduloSoloPlus,
          ErrorTienda.limite => t.planillaLimite(_hechos),
          _ => t.productoDatosInvalidos,
        };
      });
    } on Exception {
      setState(() {
        _cargando = false;
        _error = t.errorSinConexion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final revisada = _revisada;
    final nuevos = revisada?.filas.where((f) => _existente(f) == null).length;
    return AlertDialog(
      title: Text(t.planillaTitulo),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.planillaAyuda, style: tema.textTheme.bodySmall),
              TextButton.icon(
                onPressed: _descargarModelo,
                icon: const Icon(Icons.download_outlined),
                label: Text(t.planillaModelo),
              ),
              TextField(
                controller: _texto,
                minLines: 6,
                maxLines: 12,
                enabled: !_cargando,
                decoration: InputDecoration(
                  labelText: t.planillaPegar,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _revisada = null),
              ),
              if (revisada != null) ...[
                const SizedBox(height: 12),
                Text(
                  t.planillaResumen(
                    nuevos!,
                    revisada.filas.length - nuevos,
                    revisada.errores.length,
                  ),
                  style: tema.textTheme.titleSmall,
                ),
                for (final (fila, error) in revisada.errores)
                  Text(
                    t.planillaErrorFila(fila, _textoError(t, error)),
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
              ],
              if (_cargando)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(
                    value: revisada == null || revisada.filas.isEmpty
                        ? null
                        : _hechos / revisada.filas.length,
                  ),
                ),
              if (_error case final e?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    e,
                    style: TextStyle(color: tema.colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando
              ? null
              : () => Navigator.pop(context, _hechos > 0),
          child: Text(t.cancelar),
        ),
        if (revisada == null)
          FilledButton(
            onPressed: () =>
                setState(() => _revisada = leerPlanillaCatalogo(_texto.text)),
            child: Text(t.planillaRevisar),
          )
        else
          FilledButton(
            onPressed: _cargando || revisada.filas.isEmpty
                ? null
                : () => _cargar(revisada.filas),
            child: Text(t.planillaCargar(revisada.filas.length)),
          ),
      ],
    );
  }
}
