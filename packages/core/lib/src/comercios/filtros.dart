import '../mapa/mapa.dart';
import 'comercio.dart';

/// Distancias del filtro del mapa (03 §5), en metros; `null` = todo.
enum Distancia {
  m300(300),
  m800(800),
  km2(2500),
  todo(null);

  const Distancia(this.metros);

  final int? metros;
}

/// Filtros del mapa integral (1.2.3, D75). Se aplican sobre lo ya traído de la
/// zona visible: cambiar un filtro no hace otra consulta (regla de costo).
class FiltrosMapa {
  const FiltrosMapa({
    this.categorias = const {},
    this.sos = false,
    this.distancia = Distancia.todo,
    this.abiertoAhora = false,
    this.soloFavoritos = false,
    this.colocaMicrochip = false,
    this.porMascotaActiva = true,
  });

  /// Chips de rubros elegidos. Con [sos], son los chips de arriba del mapa:
  /// sin ninguno elegido se ve todo; si hay alguno, solo lo elegido (D84).
  final Set<Categoria> categorias;

  /// Chip "Perdidos y encontrados" elegido.
  final bool sos;

  /// Ningún chip elegido: se ve todo (también los eventos).
  bool get sinChips => categorias.isEmpty && !sos;

  /// "Solo mis favoritos" deja solo los favoritos: ni SOS, ni eventos, ni
  /// lugares sin reclamar (antes se seguían viendo y parecía no filtrar).
  bool get muestraSos => !soloFavoritos && (sos || categorias.isEmpty);

  bool get muestraEventos => sinChips && !soloFavoritos;

  /// Los lugares sin reclamar no tienen horario, insignias ni favoritos: con
  /// esos filtros no se ven.
  bool muestraSinReclamar(Categoria c) =>
      !soloFavoritos &&
      !abiertoAhora &&
      !colocaMicrochip &&
      muestraCategoria(c);

  /// Las agropecuarias también salen al elegir "Pet shop" (D89).
  bool muestraCategoria(Categoria c) => categorias.isEmpty
      ? !sos
      : categorias.contains(c) ||
            (c == Categoria.agro && categorias.contains(Categoria.petshop));
  final Distancia distancia;
  final bool abiertoAhora;
  final bool soloFavoritos;

  /// Solo veterinarias "Operador RENAC".
  final bool colocaMicrochip;

  /// Especies: las de la mascota activa (`true`) o las de todas mis mascotas.
  final bool porMascotaActiva;

  /// Cuántos filtros están cambiados (para el número del botón "Filtros").
  int get activos => [
    distancia != Distancia.todo,
    abiertoAhora,
    soloFavoritos,
    colocaMicrochip,
    !porMascotaActiva,
  ].where((x) => x).length;

  FiltrosMapa copyWith({
    Set<Categoria>? categorias,
    bool? sos,
    Distancia? distancia,
    bool? abiertoAhora,
    bool? soloFavoritos,
    bool? colocaMicrochip,
    bool? porMascotaActiva,
  }) => FiltrosMapa(
    categorias: categorias ?? this.categorias,
    sos: sos ?? this.sos,
    distancia: distancia ?? this.distancia,
    abiertoAhora: abiertoAhora ?? this.abiertoAhora,
    soloFavoritos: soloFavoritos ?? this.soloFavoritos,
    colocaMicrochip: colocaMicrochip ?? this.colocaMicrochip,
    porMascotaActiva: porMascotaActiva ?? this.porMascotaActiva,
  );
}

/// Regla de coincidencia por especie (06): coincide si atiende alguna de
/// [especies]. Un lugar sin especies cargadas atiende a todas, y sin
/// mascotas no se filtra.
bool coincideConEspecies(Comercio c, Set<int> especies) =>
    especies.isEmpty ||
    c.especieIds.isEmpty ||
    c.especieIds.any(especies.contains);

/// Aplica los filtros a los lugares traídos.
List<Comercio> filtrarComercios(
  Iterable<Comercio> comercios,
  FiltrosMapa filtros, {
  required DateTime ahora,
  Punto? desde,
  Set<String> favoritos = const {},
  Set<int> especies = const {},
}) => [
  for (final c in comercios)
    if (filtros.muestraCategoria(c.categoria) &&
        coincideConEspecies(c, especies) &&
        (!filtros.abiertoAhora || c.estadoEn(ahora).abierto) &&
        (!filtros.soloFavoritos || favoritos.contains(c.id)) &&
        (!filtros.colocaMicrochip || c.operadorRenac) &&
        _dentro(c, filtros.distancia, desde))
      c,
];

bool _dentro(Comercio c, Distancia distancia, Punto? desde) {
  final maximo = distancia.metros;
  final punto = c.punto;
  if (maximo == null || desde == null || punto == null) return true;
  return distanciaMetros(desde, punto) <= maximo;
}

/// Orden de la lista (06 "Abierto ahora"): abiertos, después sin horario,
/// después cerrados; dentro de cada grupo, por cercanía a [desde].
List<Comercio> ordenarParaLista(
  Iterable<Comercio> comercios, {
  required DateTime ahora,
  Punto? desde,
}) {
  int grupo(Comercio c) {
    final estado = c.estadoEn(ahora);
    if (estado.abierto) return 0;
    if (c.horario.vacio) return 1;
    return 2;
  }

  double distancia(Comercio c) => switch ((desde, c.punto)) {
    (final d?, final p?) => distanciaMetros(d, p),
    _ => double.infinity,
  };

  return comercios.toList()..sort((a, b) {
    final g = grupo(a).compareTo(grupo(b));
    if (g != 0) return g;
    final d = distancia(a).compareTo(distancia(b));
    return d != 0 ? d : a.nombre.compareTo(b.nombre);
  });
}
