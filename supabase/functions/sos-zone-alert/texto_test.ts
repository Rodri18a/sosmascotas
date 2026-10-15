import { assertEquals } from 'jsr:@std/assert@1.0.13';
import { distanciaEnTexto, textoDelAviso } from './texto.ts';

Deno.test('la distancia se redondea (nunca da metros exactos)', () => {
  assertEquals(distanciaEnTexto(320), 'a menos de 1 km');
  assertEquals(distanciaEnTexto(1490), 'a unos 1 km');
  assertEquals(distanciaEnTexto(2600), 'a unos 3 km');
});

Deno.test('mascota perdida, con nombre', () => {
  assertEquals(textoDelAviso('lost', 'dog', 'Luna', 2100), {
    titulo: '🐾 Se perdió un perro cerca tuyo',
    cuerpo: 'Luna, a unos 2 km. Tocá para ver la foto.',
  });
});

Deno.test('mascota encontrada, sin nombre y especie "otro"', () => {
  assertEquals(textoDelAviso('found', 'other', null, 400), {
    titulo: '🐾 Encontraron una mascota cerca tuyo',
    cuerpo: 'A menos de 1 km. ¿Sabés de quién es?',
  });
});
