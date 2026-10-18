import { assertEquals } from 'jsr:@std/assert@1';
import { textoReencuentro } from './texto.ts';

Deno.test('con nombre', () => {
  assertEquals(textoReencuentro('Luna').titulo, '🎉 ¡Luna volvió a casa!');
});

Deno.test('sin nombre', () => {
  assertEquals(textoReencuentro(null).titulo, '🎉 ¡La mascota que seguías volvió a casa!');
  assertEquals(textoReencuentro('  ').titulo, '🎉 ¡La mascota que seguías volvió a casa!');
});
