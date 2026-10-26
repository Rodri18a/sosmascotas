import { assertEquals } from 'jsr:@std/assert@1';
import { mesAnterior, textoReporte } from './texto.ts';

const base = {
  business_id: '00000000-0000-0000-0000-000000000001',
  nombre: 'Veterinaria Pando',
  mes: '2026-09-01',
  aperturas: 340,
  personas: 280,
  contactos: 52,
  aperturas_antes: 200,
};

Deno.test('resumen con personas, contactos y comparación', () => {
  const t = textoReporte(base);
  assertEquals(t.titulo, '📊 Veterinaria Pando: tu resumen de septiembre');
  assertEquals(t.cuerpo, '280 personas vieron tu ficha y recibiste 52 contactos (70% más que el mes anterior). Tocá para ver el detalle.');
  assertEquals(t.ruta, '/negocio/estadisticas/00000000-0000-0000-0000-000000000001');
});

Deno.test('singular, sin contactos y con baja', () => {
  const t = textoReporte({ ...base, personas: 1, contactos: 0, aperturas: 1, aperturas_antes: 4 });
  assertEquals(t.cuerpo, '1 persona vio tu ficha (75% menos que el mes anterior). Tocá para ver el detalle.');
});

Deno.test('sin personas cuenta las aperturas y sin mes anterior no compara', () => {
  const t = textoReporte({ ...base, personas: 0, aperturas: 1, contactos: 1, aperturas_antes: 0 });
  assertEquals(t.cuerpo, 'Tu ficha se abrió 1 vez y recibiste 1 contacto. Tocá para ver el detalle.');
});

Deno.test('mes anterior con la hora de Uruguay', () => {
  assertEquals(mesAnterior(new Date('2026-11-01T13:00:00Z')), '2026-10-01');
  assertEquals(mesAnterior(new Date('2027-01-01T13:00:00Z')), '2026-12-01');
  // 1/11 a la 1:00 UTC todavía es 31/10 en Uruguay.
  assertEquals(mesAnterior(new Date('2026-11-01T01:00:00Z')), '2026-09-01');
});
