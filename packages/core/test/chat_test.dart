import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee una conversación de mis_conversaciones()', () {
    final c = Conversacion.fromJson({
      'id': 'c1',
      'kind': 'sos',
      'context_id': 's1',
      'last_message_at': '2026-10-18T12:00:00Z',
      'otro_id': 'u1',
      'otro_nombre': null,
      'soy_autor': false,
      'sos_kind': 'lost',
      'sos_nombre': 'Luna',
      'ultimo_mensaje': 'Hola',
      'sin_leer': 2,
      'bloqueada': false,
      'bloqueada_por_mi': false,
    });
    expect(c.sosNombre, 'Luna');
    expect(c.sosEncontrada, isFalse);
    expect(c.sinLeer, 2);
    expect(c.otroNombre, isNull);
  });

  test('lee un mensaje con ubicación', () {
    final m = Mensaje.fromJson({
      'id': 'x',
      'conversation_id': 'c1',
      'sender_id': 'u1',
      'body': null,
      'attachment_path': null,
      'lat': -34.7,
      'lng': -55.9,
      'created_at': '2026-10-18T12:00:00Z',
    });
    expect(m.conUbicacion, isTrue);
  });

  test('suma mensajes sin repetir y en orden', () {
    Mensaje m(String id, int minuto) => Mensaje(
      id: id,
      conversacionId: 'c1',
      creado: DateTime(2026, 10, 18, 12, minuto),
    );
    expect(
      sumarMensajes(
        [m('a', 1), m('b', 3)],
        [m('b', 3), m('c', 2)],
      ).map((x) => x.id),
      ['a', 'c', 'b'],
    );
  });

  test('detecta pedidos de plata o códigos', () {
    expect(pareceEstafa('Tengo a tu perro, transferime 2000'), isTrue);
    expect(pareceEstafa('Pasame el código que te llegó por SMS'), isTrue);
    expect(pareceEstafa('La vi en la plaza a las 8'), isFalse);
  });

  test('reseñas: lee y promedia', () {
    Resena r(int e) => Resena(id: '$e', estrellas: e, creada: DateTime(2026));
    expect(promedioEstrellas([r(5), r(4), r(4)]), 4.3);
    expect(promedioEstrellas(const []), isNull);
    final leida = Resena.fromJson({
      'id': 'r1',
      'estrellas': 5,
      'comentario': 'Excelente',
      'respuesta': '¡Gracias!',
      'respondida': '2026-10-18T12:00:00Z',
      'creada': '2026-10-17T12:00:00Z',
      'autor': 'Beto',
      'mia': false,
    });
    expect(leida.respuesta, '¡Gracias!');
    expect(leida.autor, 'Beto');
  });
}
