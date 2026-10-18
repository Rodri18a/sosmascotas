import 'package:sosmascota/src/veterinarias/veterinarias_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Socios y "Busco veterinaria" en memoria para las pruebas.
class VeterinariasFalsas implements VeterinariasRepositorio {
  VeterinariasFalsas({
    Set<Modulo>? prendidos,
    List<Socio>? socios,
    this.demandaLista = const [],
    List<VeterinariaCompartible>? compartibles,
    this.estado = const EstadoBusqueda(),
    List<Propuesta>? propuestas,
    this.llegan = 4,
  }) : prendidos = {...?prendidos},
       sociosLista = [...?socios],
       compartiblesLista = [...?compartibles],
       propuestasLista = [...?propuestas];

  final Set<Modulo> prendidos;
  final List<Socio> sociosLista;
  final List<Demanda> demandaLista;
  final List<VeterinariaCompartible> compartiblesLista;
  EstadoBusqueda estado;
  final List<Propuesta> propuestasLista;
  final int llegan;
  ErrorVeterinarias? fallarCon;

  final recordados = <(String, String, DateTime)>[];
  final enviadas = <String>[];
  final compartidos = <(String, bool)>[];
  final respuestas = <(String, bool)>[];
  var ahoraNoVeces = 0;

  void _quizasFallar() {
    if (fallarCon case final e?) throw VeterinariasException(e);
  }

  @override
  Future<Set<Modulo>> modulosPrendidos(String negocioId) async =>
      Set.of(prendidos);

  @override
  Future<void> prenderModulo(
    String negocioId,
    Modulo modulo,
    bool prendido,
  ) async => prendido ? prendidos.add(modulo) : prendidos.remove(modulo);

  @override
  Future<List<Socio>> socios(String negocioId) async => List.of(sociosLista);

  @override
  Future<void> recordar(
    String negocioId,
    String mascotaId,
    String titulo,
    DateTime cuando,
  ) async {
    _quizasFallar();
    recordados.add((mascotaId, titulo, cuando));
  }

  @override
  Future<List<Demanda>> demanda(String negocioId) async => demandaLista;

  @override
  Future<int> enviarPropuesta(String negocioId, String mensaje) async {
    _quizasFallar();
    enviadas.add(mensaje);
    return llegan;
  }

  @override
  Future<List<ResultadoPropuesta>> resultados(String negocioId) async => [
    for (final (i, m) in enviadas.indexed)
      ResultadoPropuesta(
        id: 'r$i',
        mensaje: m,
        enviada: DateTime(2026, 10, 20),
        enviadas: llegan,
        vistas: 0,
        aceptadas: 0,
      ),
  ];

  @override
  Future<List<VeterinariaCompartible>> compartibles(String mascotaId) async =>
      List.of(compartiblesLista);

  @override
  Future<void> compartir(
    String mascotaId,
    String negocioId,
    bool compartir,
  ) async {
    compartidos.add((negocioId, compartir));
    final i = compartiblesLista.indexWhere((v) => v.id == negocioId);
    if (i >= 0) {
      final v = compartiblesLista[i];
      compartiblesLista[i] = VeterinariaCompartible(
        id: v.id,
        nombre: v.nombre,
        compartida: compartir,
      );
    }
  }

  @override
  Future<EstadoBusqueda> estadoBusqueda(String mascotaId) async => estado;

  @override
  Future<void> buscar(String mascotaId, bool quiero) async =>
      estado = EstadoBusqueda(buscando: quiero);

  @override
  Future<void> ahoraNo(String mascotaId) async {
    ahoraNoVeces++;
    estado = const EstadoBusqueda();
  }

  @override
  Future<List<Propuesta>> propuestas(String mascotaId) async =>
      List.of(propuestasLista);

  @override
  Future<void> responder(
    String propuestaId,
    String mascotaId,
    bool acepto,
  ) async {
    respuestas.add((propuestaId, acepto));
    final i = propuestasLista.indexWhere((p) => p.id == propuestaId);
    final p = propuestasLista[i];
    propuestasLista[i] = Propuesta(
      id: p.id,
      negocioId: p.negocioId,
      negocio: p.negocio,
      mensaje: p.mensaje,
      estado: acepto ? EstadoPropuesta.aceptada : EstadoPropuesta.rechazada,
      recibida: p.recibida,
    );
  }
}
