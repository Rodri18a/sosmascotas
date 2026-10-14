import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mapa/mapa_vista.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';

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

  Future<void> _alQuedarQuieto(Limites visible) async {
    if (_cargado?.contiene(visible) ?? false) return;
    final zona = visible.agrandado(1.5);
    _cargado = zona;
    try {
      final pins = await ref.read(sosRepositorioProvider).enZona(zona);
      if (mounted) setState(() => _pins = pins);
    } on Exception {
      _cargado = null; // Se reintenta en el próximo movimiento.
    }
  }

  void _alTocarPin(Pin pin) {
    if (pin.tipo == TipoPin.perdido || pin.tipo == TipoPin.encontrado) {
      context.push(Rutas.detalleSos(pin.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.pestanaMapa),
      actions: const [BotonAvisos(), BotonAjustes()],
    ),
    body: MapaVista(
      centro: ref.watch(miZonaProvider),
      pins: _pins,
      onCamaraQuieta: _alQuedarQuieto,
      onTocarPin: _alTocarPin,
    ),
  );
}
