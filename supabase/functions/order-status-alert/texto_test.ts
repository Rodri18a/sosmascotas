import { assertEquals } from 'jsr:@std/assert@1';
import { textoPedido } from './texto.ts';

Deno.test('pedido nuevo, al comercio', () => {
  const t = textoPedido({ destino: 'negocio', numero: 12, estado: 'new', negocio: 'Pet Shop' });
  assertEquals(t?.titulo, '🛍️ Pedido nuevo #12');
  assertEquals(t?.ruta, '/negocio?seccion=pedidos');
});

Deno.test('listo, a quien pidió', () => {
  const t = textoPedido({ destino: 'cliente', numero: 7, estado: 'ready', negocio: 'Pet Shop' });
  assertEquals(t?.titulo, '✅ ¡Tu pedido #7 está listo!');
  assertEquals(t?.cuerpo, 'Pet Shop ya lo tiene listo.');
  assertEquals(t?.ruta, '/pedidos');
});

Deno.test('sin nombre del comercio', () => {
  assertEquals(
    textoPedido({ destino: 'cliente', numero: 7, estado: 'preparing', negocio: ' ' })?.cuerpo,
    'El comercio está preparando tu pedido.',
  );
});

Deno.test('lo que no se avisa', () => {
  assertEquals(textoPedido({ destino: 'negocio', numero: 1, estado: 'ready', negocio: null }), null);
  assertEquals(textoPedido({ destino: 'cliente', numero: 1, estado: 'new', negocio: null }), null);
});
