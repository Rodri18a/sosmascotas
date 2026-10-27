import { assertEquals } from 'jsr:@std/assert@1';
import { fechas, textoCuidado } from './texto.ts';

const base = {
  negocio: 'Hotel Canino',
  tipo: 'boarding',
  desde: '2026-12-24',
  hasta: '2026-12-26',
  mascotas: 'Luna, Rocco',
};

Deno.test('fechas cortas', () => {
  assertEquals(fechas('2026-12-24', '2026-12-24'), 'el 24/12');
  assertEquals(fechas('2026-12-24', '2027-01-02'), 'del 24/12 al 2/1');
});

Deno.test('pedido nuevo, al prestador', () => {
  const t = textoCuidado({ ...base, destino: 'negocio', estado: 'pending' });
  assertEquals(t?.titulo, '🐾 Pedido nuevo');
  assertEquals(t?.cuerpo, 'Te pidieron estadía para Luna, Rocco, del 24/12 al 26/12. Tocá para responder.');
  assertEquals(t?.ruta, '/negocio?seccion=agenda');
});

Deno.test('aceptado y rechazado, a quien pidió', () => {
  assertEquals(
    textoCuidado({ ...base, destino: 'cliente', estado: 'accepted' })?.cuerpo,
    'Hotel Canino aceptó: estadía para Luna, Rocco, del 24/12 al 26/12. Coordinen por el chat.',
  );
  const r = textoCuidado({ ...base, destino: 'cliente', estado: 'rejected', tipo: 'walk', hasta: '2026-12-24' });
  assertEquals(r?.cuerpo, 'Hotel Canino no puede el 24/12. Probá con otras fechas.');
  assertEquals(r?.ruta, '/cuidados');
});

Deno.test('lo que no se avisa', () => {
  assertEquals(textoCuidado({ ...base, destino: 'negocio', estado: 'accepted' }), null);
  assertEquals(textoCuidado({ ...base, destino: 'cliente', estado: 'pending' }), null);
  assertEquals(textoCuidado({ ...base, destino: 'cliente', estado: 'done' }), null);
});
