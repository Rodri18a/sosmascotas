import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee y escribe como la base, con sus adjuntos', () {
    final a = AcontecimientoVida.fromJson({
      'id': 'e1',
      'pet_id': 'p1',
      'kind': 'surgery',
      'title': 'Castración',
      'date': '2026-03-14',
      'notes': '  Todo bien  ',
      'files': ['p1/a.jpg', 'p1/b.pdf'],
    });
    expect(a.tipo, TipoAcontecimiento.surgery);
    expect(a.fecha, DateTime(2026, 3, 14));
    expect(a.adjuntos, ['p1/a.jpg', 'p1/b.pdf']);
    expect(AcontecimientoVida.esPdf(a.adjuntos.last), isTrue);
    expect(a.toJson(), {
      'pet_id': 'p1',
      'kind': 'surgery',
      'title': 'Castración',
      'date': '2026-03-14',
      'notes': 'Todo bien',
      'files': ['p1/a.jpg', 'p1/b.pdf'],
    });
  });

  test('un tipo desconocido queda como «otro»', () {
    final a = AcontecimientoVida.fromJson({
      'id': 'e1',
      'pet_id': 'p1',
      'kind': 'nuevo',
      'title': 'x',
      'date': '2026-03-14',
    });
    expect(a.tipo, TipoAcontecimiento.other);
    expect(a.adjuntos, isEmpty);
  });

  test('valida título, nota, fecha y hasta 4 adjuntos', () {
    final hoy = DateTime(2026, 11, 2, 15);
    ValidacionAcontecimiento v({
      String titulo = 'Fractura',
      DateTime? fecha,
      String? notas,
      int adjuntos = 0,
    }) => validarAcontecimiento(
      titulo: titulo,
      fecha: fecha ?? DateTime(2026, 11, 2),
      hoy: hoy,
      notas: notas,
      adjuntos: adjuntos,
    );
    expect(v(), ValidacionAcontecimiento.valido);
    expect(v(titulo: '  '), ValidacionAcontecimiento.sinTitulo);
    expect(v(titulo: 'x' * 81), ValidacionAcontecimiento.tituloLargo);
    expect(v(notas: 'x' * 1001), ValidacionAcontecimiento.notasLargas);
    expect(
      v(fecha: DateTime(2026, 11, 5)),
      ValidacionAcontecimiento.fechaFutura,
    );
    expect(v(adjuntos: 5), ValidacionAcontecimiento.muchosAdjuntos);
  });

  test('el historial va de lo más nuevo a lo más viejo', () {
    AcontecimientoVida de(String id, DateTime f) => AcontecimientoVida(
      id: id,
      mascotaId: 'p1',
      tipo: TipoAcontecimiento.other,
      titulo: id,
      fecha: f,
    );
    final lista = ordenarHistorial([
      de('viejo', DateTime(2020)),
      de('nuevo', DateTime(2026)),
      de('medio', DateTime(2023)),
    ]);
    expect(lista.map((a) => a.id), ['nuevo', 'medio', 'viejo']);
  });
}
