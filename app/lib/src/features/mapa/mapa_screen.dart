import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../mapa/mapa_vista.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/boton_mensajes.dart';
import '../instalar/instalar.dart';
import 'ficha_comercio.dart';

/// Mapa (Fase 0): perdidos, encontrados y veterinarias de urgencia de la zona.
///
/// Regla de costo: se traen solo los pines de la zona visible (agrandada 1,5×)
/// y no se vuelve a consultar mientras la vista quede dentro de lo ya cargado.
class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  Limites? _cargado;
  List<Pin> _pins = const [];

  /// Veterinarias cargadas, por id (para abrir la ficha al tocar su pin).
  Map<String, Comercio> _comercios = const {};

  Future<void> _alQuedarQuieto(Limites visible) async {
    if (_cargado?.contiene(visible) ?? false) return;
    final zona = visible.agrandado(1.5);
    _cargado = zona;
    try {
      final (sos, comercios) = await (
        ref.read(sosRepositorioProvider).enZona(zona),
        ref.read(comerciosRepositorioProvider).enZona(zona),
      ).wait;
      if (!mounted) return;
      setState(() {
        // Las veterinarias primero: los SOS quedan dibujados encima.
        _pins = [for (final c in comercios) c.pin, ...sos];
        _comercios = {for (final c in comercios) c.id: c};
      });
    } on Exception {
      _cargado = null; // Se reintenta en el próximo movimiento.
    } on ParallelWaitError<dynamic, dynamic> {
      _cargado = null;
    }
  }

  void _alTocarPin(Pin pin) {
    if (pin.tipo == TipoPin.perdido || pin.tipo == TipoPin.encontrado) {
      context.push(Rutas.detalleSos(pin.id));
    } else if (_comercios[pin.id] case final comercio?) {
      mostrarFichaComercio(context, ref, comercio);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaMapa),
      actions: const [BotonMensajes(), BotonAvisos(), BotonAjustes()],
    ),
    body: Stack(
      children: [
        MapaVista(
          centro: ref.watch(miZonaProvider),
          pins: _pins,
          onCamaraQuieta: _alQuedarQuieto,
          onTocarPin: _alTocarPin,
        ),
        const Positioned(left: 8, bottom: 8, child: _Leyenda()),
        const Positioned(
          left: 8,
          right: 8,
          top: 8,
          child: SafeArea(child: TarjetaInstalarApp()),
        ),
      ],
    ),
  );
}

/// Qué significa cada color de pin.
class _Leyenda extends StatelessWidget {
  const _Leyenda();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (tipo, texto) in [
              (TipoPin.perdido, t.leyendaPerdido),
              (TipoPin.encontrado, t.leyendaEncontrado),
              (TipoPin.urgencia, t.leyendaUrgencia),
              (TipoPin.veterinaria, t.leyendaVeterinaria),
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: coloresPin[tipo],
                      shape: BoxShape.circle,
                      border: Border.all(color: bordePin, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(texto, style: tema.textTheme.labelSmall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
