import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('un grupo de raza de la lista', () {
    final g = Grupo.fromJson({
      'id': 'g1',
      'kind': 'breed',
      'name': 'Bulldog Francés',
      'icon': '🐶',
      'species_id': 1,
      'breed_id': 30,
      'miembros': 12,
      'publicaciones_semana': 3,
      'soy_miembro': true,
    });
    expect(g.tipo, TipoGrupo.raza);
    expect(g.razaId, 30);
    expect(g.miembros, 12);
    expect(g.soyMiembro, isTrue);
  });

  test('una publicación en la lista y en el detalle', () {
    final lista = Publicacion.fromJson({
      'id': 'p1',
      'kind': 'tip',
      'body': 'Probá con juguetes de goma',
      'photo_paths': ['u1/a.jpg'],
      'autor': 'Ana',
      'es_mio': false,
      'comentarios': 4,
      'created_at': '2026-10-28T12:00:00Z',
    });
    expect(lista.tipo, TipoPublicacion.consejo);
    expect(lista.cantidadComentarios, 4);
    expect(lista.fotos, ['u1/a.jpg']);

    final detalle = Publicacion.fromJson({
      'id': 'p1',
      'group_id': 'g1',
      'group_name': 'Perros',
      'kind': 'question',
      'body': '¿Cada cuánto lo baño?',
      'photo_paths': <String>[],
      'autor': 'Ana',
      'es_mio': true,
      'soy_miembro': true,
      'created_at': '2026-10-28T12:00:00Z',
      'comentarios': [
        {
          'id': 'c1',
          'body': 'Una vez al mes',
          'autor': 'Leo',
          'es_mio': false,
          'created_at': '2026-10-28T13:00:00Z',
        },
      ],
    });
    expect(detalle.esMia, isTrue);
    expect(detalle.grupoNombre, 'Perros');
    expect(detalle.cantidadComentarios, 1);
    expect(detalle.comentarios.single.autor, 'Leo');
  });

  test('un saludo recibido', () {
    final s = Saludo.fromJson({
      'id': 's1',
      'recibido': true,
      'persona': 'Leo',
      'message': '¡Hola! Mi perro también es bulldog',
      'post_id': 'p1',
      'post_texto': '¿Cada cuánto lo baño?',
      'status': 'pending',
      'conversation_id': null,
      'created_at': '2026-10-28T13:00:00Z',
    });
    expect(s.estado, EstadoSaludo.pendiente);
    expect(s.recibido, isTrue);
    expect(s.chatId, isNull);
  });

  test('venta y cruza, con la misma regla que la base', () {
    for (final t in [
      'Vendo cachorros de bulldog',
      'Busco novia para mi perro',
      'Venta de gatitos persas',
      'Mi perra está en celo, ¿la cruzo?',
      'Quiero cruzar a mi caniche',
      'Se venden perritos',
      'Ofrezco servicio de monta',
    ]) {
      expect(textoProhibidoComunidad(t), isTrue, reason: t);
    }
    for (final t in [
      '¿Alguien sabe dónde castrar barato?',
      '¿Qué alimento vende la veterinaria?',
      'La montaña es linda para pasear',
      'Es un mestizo, cruza de labrador',
    ]) {
      expect(textoProhibidoComunidad(t), isFalse, reason: t);
    }
  });
}
