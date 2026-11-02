/// Insignias de «Tus huellas» (plan de mejoras 3.3, D138), con la clave que
/// usa la base (`mis_huellas()`). Se ganan solas por cuidar y ayudar.
enum Insignia { perfil, libreta, chapita, difusor, respuesta, reencuentro }

/// Lo que devuelve `mis_huellas()`: cuántas veces ayudé y qué insignias tengo.
/// Solo lo ve la propia persona; no hay rankings.
class Huellas {
  const Huellas({this.ayudas = 0, this.ganadas = const {}});

  factory Huellas.fromJson(Map<String, Object?> json) {
    final insignias = (json['insignias'] as Map?)?.cast<String, Object?>();
    return Huellas(
      ayudas: (json['ayudas'] as num?)?.toInt() ?? 0,
      ganadas: {
        for (final i in Insignia.values)
          if (insignias?[i.name] == true) i,
      },
    );
  }

  final int ayudas;
  final Set<Insignia> ganadas;
}
