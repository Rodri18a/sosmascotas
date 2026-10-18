import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

AnimalAdopcion _animal({
  bool patio = false,
  bool? ninos,
  bool? perros,
  String? energia,
  String? necesidades,
}) => AnimalAdopcion(
  id: 'a1',
  publicacionId: 'p1',
  especieId: 1,
  fotos: const ['u/x.jpg'],
  necesitaPatio: patio,
  conNinos: ninos,
  conPerros: perros,
  energia: energia,
  necesidades: necesidades,
);

void main() {
  test('compatibilidad: orienta sin bloquear', () {
    const depto = PerfilAdoptante(
      vivienda: 'apartamento',
      patio: false,
      horasSolo: 9,
      ninos: true,
      otrosAnimales: true,
      experiencia: 'ninguna',
      casaDeAcuerdo: false,
    );
    expect(compatibilidad(depto, _animal()), [
      AvisoCompatibilidad.casaNoDeAcuerdo,
    ]);
    expect(
      compatibilidad(
        depto,
        _animal(
          patio: true,
          ninos: false,
          perros: false,
          energia: 'alta',
          necesidades: 'Medicación diaria',
        ),
      ),
      [
        AvisoCompatibilidad.necesitaPatio,
        AvisoCompatibilidad.noConNinos,
        AvisoCompatibilidad.noConOtrosAnimales,
        AvisoCompatibilidad.muchoTiempoSolo,
        AvisoCompatibilidad.casaNoDeAcuerdo,
        AvisoCompatibilidad.sinExperienciaConNecesidades,
      ],
    );
  });

  test('etapas: la siguiente y cuándo terminó', () {
    expect(EtapaAdopcion.interest.siguiente, EtapaAdopcion.questionnaire);
    expect(EtapaAdopcion.visit.siguiente, EtapaAdopcion.agreement);
    expect(EtapaAdopcion.agreement.siguiente, isNull);
    expect(EtapaAdopcion.adopted.terminada, isTrue);
  });

  test('lee un animal de adopciones_disponibles()', () {
    final a = AnimalAdopcion.fromJson({
      'animal_id': 'a1',
      'adoption_id': 'p1',
      'name': 'Pelusa',
      'species_id': 2,
      'breed': '',
      'photos': ['u/x.jpg'],
      'publisher_kind': 'shelter',
      'shelter_name': 'Refugio Patitas',
      'contribution_amount': 800,
      'contribution_covers': 'castración y vacunas',
    });
    expect(a.raza, isNull);
    expect(a.deRefugio, isTrue);
    expect(a.aporte, 800);
  });

  test('perfil completo y su JSON', () {
    const p = PerfilAdoptante(
      vivienda: 'casa',
      patio: true,
      horasSolo: 4,
      ninos: false,
    );
    expect(p.completo, isTrue);
    expect(p.toJson()['housing'], 'casa');
    expect(const PerfilAdoptante().completo, isFalse);
  });

  test('calculadora: suma lo mensual y prorratea lo anual', () {
    final total = totalCostos(const [
      ItemCosto(clave: 'comida', monto: 1500),
      ItemCosto(clave: 'vacunas', monto: 1200, anual: true),
    ]);
    expect(total.mes, 1600);
    expect(total.anio, 19200);
  });

  test('seguimiento disponible desde su fecha', () {
    final s = Seguimiento(
      id: 's1',
      dia: 7,
      vence: DateTime(2026, 10, 25),
      respondido: false,
    );
    expect(s.disponible(DateTime(2026, 10, 24)), isFalse);
    expect(s.disponible(DateTime(2026, 10, 25, 9)), isTrue);
  });

  test('solicitud recibida con el perfil y el seguimiento', () {
    final r = SolicitudRecibida.fromJson({
      'id': 'r1',
      'animal_id': 'a1',
      'animal': 'Pelusa',
      'stage': 'visit',
      'adoptante': 'Beto',
      'perfil': {'housing': 'apartamento', 'has_yard': false},
      'seguimiento': [
        {'day': 7, 'answer': 'Muy bien', 'photo': null},
      ],
    });
    expect(r.etapa, EtapaAdopcion.visit);
    expect(r.perfil!.vivienda, 'apartamento');
    expect(r.seguimiento.single.respuesta, 'Muy bien');
  });
}
