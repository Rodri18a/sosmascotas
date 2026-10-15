import { assertEquals } from 'jsr:@std/assert@1.0.13';
import { textoAvisoAlDueno, textoEscaneo } from './texto.ts';

Deno.test('escaneo del QR, con y sin nombre', () => {
  assertEquals(textoEscaneo('Toby').titulo, '📍 Escanearon el QR de Toby');
  assertEquals(textoEscaneo(null).titulo, '📍 Escanearon el QR de tu mascota');
});

Deno.test('aviso con mensaje desde el QR y desde un SOS', () => {
  assertEquals(textoAvisoAlDueno('qr', 'Luna').titulo, '💬 Alguien vio a Luna y te dejó un mensaje');
  assertEquals(textoAvisoAlDueno('sos', null).titulo, '💬 Te dejaron un aviso sobre tu reporte');
});
