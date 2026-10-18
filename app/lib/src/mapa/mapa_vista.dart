import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'mapa_maplibre.dart';

/// Capa propia del mapa ("MapView", ver docs/08-arquitectura.md): las pantallas
/// usan esto y nunca el proveedor directo, así se puede cambiar de motor o de
/// proveedor de teselas (o usar un mapa falso en las pruebas) sin tocarlas.
class MapaVista extends ConsumerWidget {
  const MapaVista({
    required this.centro,
    this.zoom = 13,
    this.pins = const [],
    this.seleccion,
    this.onCamaraQuieta,
    this.onTocarPin,
    this.onTocarMapa,
    super.key,
  });

  final Punto centro;
  final double zoom;
  final List<Pin> pins;

  /// Punto marcado por la persona (por ejemplo, dónde se perdió la mascota).
  final Punto? seleccion;

  /// Cuando el mapa deja de moverse: trae los pines de la zona visible.
  final ValueChanged<Limites>? onCamaraQuieta;
  final ValueChanged<Pin>? onTocarPin;

  /// La ubicación se marca tocando el mapa (sin geocodificación: regla de costo).
  final ValueChanged<Punto>? onTocarMapa;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(constructorMapaProvider)(this);
}

/// Color de cada tipo de pin (el mapa y la leyenda usan los mismos). Son
/// iguales en todos los temas y se distinguen también por luminosidad, para
/// quien no distingue colores (D62). Como texto, usar `context.marca.urgencia`.
const coloresPin = <TipoPin, Color>{
  TipoPin.perdido: Color(0xFFD62839),
  TipoPin.encontrado: Color(0xFF1F9E8E),
  TipoPin.veterinaria: Color(0xFF0B3D52),
  TipoPin.urgencia: Color(0xFFFFB238),
  // Etapa 1.2 (D75): los demás rubros en violeta, quienes aceptan mascotas en
  // verde muy claro y los grupos casi negros (con el número blanco adentro).
  // Elegidos para que también se distingan por luminosidad (≥ 1,5:1).
  TipoPin.comercio: Color(0xFF673CA3),
  TipoPin.aceptaMascotas: Color(0xFFE2F5C4),
  TipoPin.grupo: Color(0xFF141414),
};

/// Borde de los pines: contrasta con el mapa claro y con el pin ámbar.
const bordePin = Color(0xFF102A35);

typedef ConstructorMapa = Widget Function(MapaVista config);

/// Motor del mapa. En la Fase 0 (web) es MapLibre con OpenFreeMap; en la Fase 1
/// se suma Google Maps nativo en Android/iPhone (paso 1.2.2).
final constructorMapaProvider = Provider<ConstructorMapa>(
  (ref) =>
      (config) => MapaMapLibre(config: config),
);
