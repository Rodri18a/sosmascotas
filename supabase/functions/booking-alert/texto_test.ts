import { assertEquals } from 'jsr:@std/assert@1';
import { cuando, textoRecordatorio, textoTurno } from './texto.ts';

const base = {
  negocio: 'Peluquería Luna',
  inicio: '2026-10-27T12:00:00Z',
  servicio: 'Baño y corte',
  mascota: 'Toby',
};

Deno.test('fecha y hora de Uruguay', () => {
  assertEquals(cuando('2026-10-27T12:00:00Z'), 'el martes 27/10 a las 09:00');
  // 01:30 UTC del 28 todavía es el 27 en Uruguay.
  assertEquals(cuando('2026-10-28T01:30:00Z'), 'el martes 27/10 a las 22:30');
});

Deno.test('turno nuevo, al comercio', () => {
  const t = textoTurno({ ...base, destino: 'negocio', estado: 'pending' });
  assertEquals(t?.titulo, '📅 Turno nuevo');
  assertEquals(t?.cuerpo, 'Te pidieron un turno: Baño y corte para Toby, el martes 27/10 a las 09:00. Tocá para confirmarlo.');
  assertEquals(t?.ruta, '/negocio?seccion=agenda');
});

Deno.test('confirmado y rechazado, a quien reservó', () => {
  assertEquals(
    textoTurno({ ...base, destino: 'cliente', estado: 'confirmed' })?.cuerpo,
    'Peluquería Luna confirmó tu turno: Baño y corte para Toby, el martes 27/10 a las 09:00.',
  );
  const r = textoTurno({ ...base, destino: 'cliente', estado: 'rejected', servicio: null, mascota: null });
  assertEquals(r?.cuerpo, 'Peluquería Luna no puede atenderte el martes 27/10 a las 09:00. Probá con otro horario.');
  assertEquals(r?.ruta, '/turnos');
});

Deno.test('lo que no se avisa', () => {
  assertEquals(textoTurno({ ...base, destino: 'negocio', estado: 'confirmed' }), null);
  assertEquals(textoTurno({ ...base, destino: 'cliente', estado: 'pending' }), null);
  assertEquals(textoTurno({ ...base, destino: 'cliente', estado: 'done' }), null);
});

Deno.test('recordatorio del día anterior', () => {
  assertEquals(
    textoRecordatorio(base).cuerpo,
    'Baño y corte en Peluquería Luna con Toby, el martes 27/10 a las 09:00. Si no podés ir, cancelalo desde la app.',
  );
  assertEquals(
    textoRecordatorio({ ...base, servicio: null, mascota: ' ', negocio: null }).cuerpo,
    'el comercio, el martes 27/10 a las 09:00. Si no podés ir, cancelalo desde la app.',
  );
});
