import 'package:flutter/material.dart';
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

/// Lugares sin reclamar (1.3.2): grises con el ícono de su rubro (D82), así
/// se entiende qué son y que nadie los confirmó todavía. Con el ícono blanco
/// encima contrasta ≥ 3:1.
const colorSinReclamar = Color(0xFF7A7A7A);

/// Eventos (2.7): centro blanco, borde e ícono coral; se distinguen por la forma.
const colorEvento = Color(0xFFFF7A59);

/// Ícono del pin de evento: coral más oscuro, para que contraste sobre blanco.
const colorIconoEvento = Color(0xFFC4462A);

/// Color de un pin (los sin reclamar y los eventos van aparte).
Color colorDePin(TipoPin tipo) =>
    coloresPin[tipo] ??
    (tipo == TipoPin.evento ? colorEvento : colorSinReclamar);

/// Ícono de cada rubro: en el pin del mapa, en la ficha y en los chips (D82).
IconData iconoCategoria(Categoria c) => switch (c) {
  Categoria.vet => Icons.local_hospital,
  Categoria.petshop => Icons.shopping_cart,
  Categoria.pharmacy => Icons.medication,
  Categoria.grooming => Icons.content_cut,
  Categoria.walker => Icons.directions_walk,
  Categoria.hotel => Icons.hotel,
  Categoria.trainer => Icons.school,
  Categoria.petFriendly => Icons.pets,
  Categoria.shelter => Icons.house,
};

/// Ícono del pin (D82): lupa en los SOS (roja o verde), calendario en los
/// eventos, el del rubro en los lugares y ninguno en los grupos (llevan el
/// número).
IconData? iconoDePin(Pin pin) => switch (pin.tipo) {
  TipoPin.grupo => null,
  TipoPin.perdido || TipoPin.encontrado => Icons.search,
  TipoPin.evento => Icons.event,
  TipoPin.veterinaria || TipoPin.urgencia => Icons.local_hospital,
  TipoPin.aceptaMascotas => Icons.pets,
  _ => switch (pin.categoria) {
    final c? => iconoCategoria(c),
    null => Icons.storefront,
  },
};

/// Cómo se dibuja un pin con ícono. [clave] identifica la imagen, para
/// dibujarla una sola vez aunque haya muchos pines iguales.
class AspectoPin {
  const AspectoPin({
    required this.fondo,
    required this.borde,
    required this.colorIcono,
    required this.icono,
    required this.diametro,
    this.grosorBorde = 2,
  });

  final Color fondo;
  final Color borde;
  final Color colorIcono;
  final IconData icono;

  /// En puntos lógicos (sin la densidad de la pantalla).
  final double diametro;
  final double grosorBorde;

  String get clave =>
      'pin-${fondo.toARGB32()}-${borde.toARGB32()}-${colorIcono.toARGB32()}'
      '-${icono.codePoint}-${diametro.round()}-${grosorBorde.round()}';
}

/// Aspecto de un pin, o `null` si no lleva ícono (los grupos).
AspectoPin? aspectoDePin(Pin pin) {
  final icono = iconoDePin(pin);
  if (icono == null) return null;
  if (pin.tipo == TipoPin.evento) {
    return AspectoPin(
      fondo: const Color(0xFFFFFFFF),
      borde: colorEvento,
      colorIcono: colorIconoEvento,
      icono: icono,
      diametro: 26,
      grosorBorde: 3,
    );
  }
  final fondo = colorDePin(pin.tipo);
  final sinReclamar = pin.tipo == TipoPin.sinReclamar;
  return AspectoPin(
    fondo: fondo,
    // Los sin reclamar con borde blanco y un poco más chicos: no compiten con
    // los lugares confirmados.
    borde: sinReclamar ? const Color(0xFFFFFFFF) : bordePin,
    colorIcono: colorIconoSobre(fondo),
    icono: icono,
    diametro: pin.esSos ? 30 : (sinReclamar ? 22 : 26),
  );
}

/// Un pin con su ícono como widget (leyenda del mapa).
class MarcaPin extends StatelessWidget {
  const MarcaPin(this.aspecto, {this.tamanio = 18, super.key});

  final AspectoPin aspecto;
  final double tamanio;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanio,
    height: tamanio,
    decoration: BoxDecoration(
      color: aspecto.fondo,
      shape: BoxShape.circle,
      border: Border.all(color: aspecto.borde, width: 1.5),
    ),
    child: Icon(aspecto.icono, size: tamanio * 0.62, color: aspecto.colorIcono),
  );
}

/// Ícono blanco sobre los pines oscuros y tinta sobre los claros (ámbar y
/// verde claro).
Color colorIconoSobre(Color fondo) =>
    fondo.computeLuminance() > 0.4 ? bordePin : const Color(0xFFFFFFFF);

/// Borde de los pines: contrasta con el mapa claro y con el pin ámbar.
const bordePin = Color(0xFF102A35);

typedef ConstructorMapa = Widget Function(MapaVista config);

/// Motor del mapa. En la Fase 0 (web) es MapLibre con OpenFreeMap; en la Fase 1
/// se suma Google Maps nativo en Android/iPhone (paso 1.2.2).
final constructorMapaProvider = Provider<ConstructorMapa>(
  (ref) =>
      (config) => MapaMapLibre(config: config),
);
