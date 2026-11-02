import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../metricas/metricas.dart';

/// Una línea de explicación con «Ver más», que despliega el texto completo
/// en el mismo lugar (plan de mejoras 1.4): la pantalla queda corta y no se
/// pierde nada. [id] dice cuál se abrió en la métrica `more_info_open`.
class ExplicacionCorta extends ConsumerStatefulWidget {
  const ExplicacionCorta({
    required this.id,
    required this.corta,
    required this.larga,
    this.estilo,
    super.key,
  });

  final String id;
  final String corta;
  final String larga;
  final TextStyle? estilo;

  @override
  ConsumerState<ExplicacionCorta> createState() => _ExplicacionCortaState();
}

class _ExplicacionCortaState extends ConsumerState<ExplicacionCorta> {
  var _abierta = false;

  void _cambiar() {
    setState(() => _abierta = !_abierta);
    if (_abierta) {
      ref
          .read(metricasProvider)
          .track(Eventos.moreInfoOpen, props: {'item': widget.id});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_abierta ? widget.larga : widget.corta, style: widget.estilo),
        TextButton(
          onPressed: _cambiar,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(48, 32),
            visualDensity: VisualDensity.compact,
          ),
          child: Text(_abierta ? t.explicacionVerMenos : t.explicacionVerMas),
        ),
      ],
    );
  }
}
