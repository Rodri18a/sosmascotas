import 'dart:math' as math;

/// Un punto en el mapa.
class Punto {
  const Punto(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is Punto && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'Punto($lat, $lng)';
}

/// Centro de Pando (zona inicial).
const centroPando = Punto(-34.7171, -55.9581);

/// Rectángulo visible del mapa.
class Limites {
  const Limites({
    required this.minLat,
    required this.minLng,
    required this.maxLat,
    required this.maxLng,
  });

  final double minLat;
  final double minLng;
  final double maxLat;
  final double maxLng;

  Punto get centro => Punto((minLat + maxLat) / 2, (minLng + maxLng) / 2);

  bool contiene(Limites otros) =>
      otros.minLat >= minLat &&
      otros.maxLat <= maxLat &&
      otros.minLng >= minLng &&
      otros.maxLng <= maxLng;

  /// El mismo rectángulo agrandado un [factor] (para traer un poco más y no
  /// volver a consultar con cada movimiento chico: regla de costo del mapa).
  Limites agrandado(double factor) {
    final dLat = (maxLat - minLat) * (factor - 1) / 2;
    final dLng = (maxLng - minLng) * (factor - 1) / 2;
    return Limites(
      minLat: math.max(-90, minLat - dLat),
      minLng: math.max(-180, minLng - dLng),
      maxLat: math.min(90, maxLat + dLat),
      maxLng: math.min(180, maxLng + dLng),
    );
  }
}

/// Qué representa un pin (define el color).
enum TipoPin { perdido, encontrado, veterinaria, urgencia }

/// Un pin del mapa: datos mínimos (el detalle se trae al tocarlo).
class Pin {
  const Pin({required this.id, required this.tipo, required this.punto});

  final String id;
  final TipoPin tipo;
  final Punto punto;

  @override
  bool operator ==(Object other) =>
      other is Pin &&
      other.id == id &&
      other.tipo == tipo &&
      other.punto == punto;

  @override
  int get hashCode => Object.hash(id, tipo, punto);
}

/// Distancia en metros entre dos puntos (fórmula de haversine).
double distanciaMetros(Punto a, Punto b) {
  const radioTierra = 6371000.0;
  double rad(double g) => g * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLng = rad(b.lng - a.lng);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * radioTierra * math.asin(math.sqrt(h));
}
