import 'dart:math' as math;

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

/// Ícono de línea de cada rubro: en la ficha y en los chips (D82, D122).
IconData iconoCategoria(Categoria c) => switch (c) {
  Categoria.vet => Icons.local_hospital_outlined,
  Categoria.petshop => Icons.storefront_outlined,
  Categoria.pharmacy => Icons.medication_outlined,
  Categoria.grooming => Icons.content_cut_outlined,
  Categoria.walker => Icons.directions_walk_outlined,
  Categoria.hotel => Icons.hotel_outlined,
  Categoria.trainer => Icons.school_outlined,
  Categoria.petFriendly => Icons.pets_outlined,
  Categoria.shelter => Icons.house_outlined,
  Categoria.agro => Icons.agriculture_outlined,
};

/// El mismo ícono, relleno: en el pin chico del mapa se lee mejor.
IconData iconoPinCategoria(Categoria c) => switch (c) {
  Categoria.vet => Icons.local_hospital,
  Categoria.petshop => Icons.storefront,
  Categoria.pharmacy => Icons.medication,
  Categoria.grooming => Icons.content_cut,
  Categoria.walker => Icons.directions_walk,
  Categoria.hotel => Icons.hotel,
  Categoria.trainer => Icons.school,
  Categoria.petFriendly => Icons.pets,
  Categoria.shelter => Icons.house,
  Categoria.agro => Icons.agriculture,
};

/// Ícono del pin (D82, guía de marca D122): huella en los SOS (roja o verde),
/// calendario en los eventos, el del rubro en los lugares y ninguno en los
/// grupos (llevan el número). Las urgencias llevan «24» en vez de ícono.
IconData? iconoDePin(Pin pin) => switch (pin.tipo) {
  TipoPin.grupo => null,
  TipoPin.perdido || TipoPin.encontrado => Icons.pets,
  TipoPin.evento => Icons.event,
  TipoPin.veterinaria || TipoPin.urgencia => Icons.local_hospital,
  TipoPin.aceptaMascotas => Icons.pets,
  _ => switch (pin.categoria) {
    final c? => iconoPinCategoria(c),
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
    this.texto,
  });

  final Color fondo;
  final Color borde;
  final Color colorIcono;
  final IconData icono;

  /// En puntos lógicos (sin la densidad de la pantalla).
  final double diametro;
  final double grosorBorde;

  /// En lugar del ícono (el «24» de las urgencias).
  final String? texto;

  /// Los pines son gotas (guía de marca, D122): la cabeza redonda y la punta
  /// abajo, en el lugar exacto.
  double get alto => diametro * 1.3;

  String get clave =>
      'pin-${fondo.toARGB32()}-${borde.toARGB32()}-${colorIcono.toARGB32()}'
      '-${icono.codePoint}-${diametro.round()}-${grosorBorde.round()}'
      '-${texto ?? ''}';
}

/// Contorno de gota de un pin de [diametro] (y [AspectoPin.alto] de alto),
/// con lugar para un borde de [grosor].
Path gotaPin(double diametro, double grosor) {
  final r = diametro / 2;
  final radio = r - grosor / 2;
  final punta = Offset(r, diametro * 1.3 - grosor / 2);
  // Puntos donde las rectas que salen de la punta tocan el círculo.
  final distancia = punta.dy - r;
  final cos = radio / distancia;
  final sen = math.sqrt(1 - cos * cos);
  return Path()
    ..moveTo(punta.dx, punta.dy)
    ..lineTo(r + radio * sen, r + radio * cos)
    ..arcToPoint(
      Offset(r - radio * sen, r + radio * cos),
      radius: Radius.circular(radio),
      largeArc: true,
      clockwise: false,
    )
    ..close();
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
    texto: pin.tipo == TipoPin.urgencia ? '24' : null,
  );
}

/// Un pin con su ícono como widget (leyenda del mapa).
class MarcaPin extends StatelessWidget {
  const MarcaPin(this.aspecto, {this.tamanio = 18, super.key});

  final AspectoPin aspecto;
  final double tamanio;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: tamanio,
    height: tamanio * 1.3,
    child: CustomPaint(
      painter: _PintorGota(aspecto),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox.square(
          dimension: tamanio,
          child: Center(
            child: switch (aspecto.texto) {
              final texto? => Text(
                texto,
                style: TextStyle(
                  fontSize: tamanio * 0.42,
                  fontWeight: FontWeight.w700,
                  color: aspecto.colorIcono,
                  height: 1,
                ),
              ),
              null => Icon(
                aspecto.icono,
                size: tamanio * 0.58,
                color: aspecto.colorIcono,
              ),
            },
          ),
        ),
      ),
    ),
  );
}

class _PintorGota extends CustomPainter {
  const _PintorGota(this.aspecto);

  final AspectoPin aspecto;

  @override
  void paint(Canvas canvas, Size size) {
    final gota = gotaPin(size.width, 1.5);
    canvas
      ..drawPath(gota, Paint()..color = aspecto.fondo)
      ..drawPath(
        gota,
        Paint()
          ..color = aspecto.borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_PintorGota anterior) =>
      anterior.aspecto.clave != aspecto.clave;
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
