import 'package:flutter/material.dart';
import 'package:sosmascota/src/mapa/mapa_vista.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Mapa de mentira para las pruebas: muestra cuántos pines tiene y permite
/// simular toques y movimientos.
class MapaFalso extends StatelessWidget {
  const MapaFalso(this.config, {super.key});

  final MapaVista config;

  static const limitesPando = Limites(
    minLat: -34.75,
    minLng: -56.0,
    maxLat: -34.68,
    maxLng: -55.9,
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('mapa: ${config.pins.length} pines'),
      if (config.seleccion case final s?) Text('marcado: ${s.lat},${s.lng}'),
      for (final pin in config.pins)
        TextButton(
          key: ValueKey('pin-${pin.id}'),
          onPressed: () => config.onTocarPin?.call(pin),
          child: Text('pin ${pin.id}'),
        ),
      TextButton(
        key: const ValueKey('mapa-tocar'),
        onPressed: () => config.onTocarMapa?.call(const Punto(-34.72, -55.95)),
        child: const Text('tocar mapa'),
      ),
      TextButton(
        key: const ValueKey('mapa-mover'),
        onPressed: () => config.onCamaraQuieta?.call(limitesPando),
        child: const Text('mover mapa'),
      ),
    ],
  );
}
