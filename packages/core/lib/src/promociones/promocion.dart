import '../mapa/mapa.dart';

/// Promoción de un comercio Destacado o Plus en el muro (plan de mejoras 3.1,
/// D136). En el muro se ve marcada «Promocionado».
class Promocion {
  const Promocion({
    required this.id,
    required this.titulo,
    required this.texto,
    this.negocioId,
    this.negocio,
    this.fotoPath,
    this.punto,
    this.vence,
    this.vigente = true,
  });

  /// De `promociones_cerca()` (muro) o de `mis_promociones()` (panel).
  factory Promocion.fromJson(Map<String, Object?> json) => Promocion(
    id: json['id']! as String,
    titulo: json['title']! as String,
    texto: json['body']! as String,
    negocioId: json['business_id'] as String?,
    negocio: json['negocio'] as String?,
    fotoPath: json['photo_path'] as String?,
    punto: switch ((json['lat'], json['lng'])) {
      (final num lat, final num lng) => Punto(lat.toDouble(), lng.toDouble()),
      _ => null,
    },
    vence: switch (json['ends_at']) {
      final String v => DateTime.parse(v).toLocal(),
      _ => null,
    },
    vigente: json['vigente'] as bool? ?? true,
  );

  /// Topes del plan: Destacado 1 vigente, Plus 2; Gratis, ninguna.
  static int topeDelPlan(String? plan) => switch (plan) {
    'featured' => 1,
    'plus' => 2,
    _ => 0,
  };

  /// Días que puede durar (de 1 a 30).
  static const maxDias = 30;

  final String id;
  final String titulo;
  final String texto;
  final String? negocioId;
  final String? negocio;

  /// Una de las fotos de la ficha del comercio (bucket público).
  final String? fotoPath;

  /// Dónde está el comercio (para abrir su ficha del mapa).
  final Punto? punto;
  final DateTime? vence;
  final bool vigente;
}

/// Mete una promoción cada [cada] elementos del muro, hasta [maximo].
List<Object> intercalarPromociones<T extends Object>(
  List<T> elementos,
  List<Promocion> promociones, {
  int cada = 4,
  int maximo = 3,
}) {
  final resultado = <Object>[];
  var usadas = 0;
  for (var i = 0; i < elementos.length; i++) {
    resultado.add(elementos[i]);
    final toca = (i + 1) % cada == 0;
    if (toca && usadas < promociones.length && usadas < maximo) {
      resultado.add(promociones[usadas++]);
    }
  }
  // Con pocas noticias, igual se ve una (al final).
  if (usadas == 0 && promociones.isNotEmpty && elementos.isNotEmpty) {
    resultado.add(promociones.first);
  }
  return resultado;
}
