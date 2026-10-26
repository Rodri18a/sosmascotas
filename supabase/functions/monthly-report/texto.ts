// Texto de la push del reporte mensual (2.3, D101), en voseo como la app.

export type ReporteMensual = {
  business_id: string;
  nombre: string;
  /** Primer día del mes, `AAAA-MM-DD`. */
  mes: string;
  aperturas: number;
  personas: number;
  contactos: number;
  aperturas_antes: number;
};

const MESES = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

const veces = (n: number, una: string, varias: string) => `${n} ${n === 1 ? una : varias}`;

/** Primer día del mes anterior a [hoy] (en Uruguay), `AAAA-MM-DD`. */
export function mesAnterior(hoy: Date): string {
  const uy = new Date(hoy.getTime() - 3 * 60 * 60 * 1000); // Uruguay: UTC−3, sin horario de verano
  const anio = uy.getUTCMonth() === 0 ? uy.getUTCFullYear() - 1 : uy.getUTCFullYear();
  const mes = uy.getUTCMonth() === 0 ? 12 : uy.getUTCMonth();
  return `${anio}-${String(mes).padStart(2, '0')}-01`;
}

export function textoReporte(r: ReporteMensual): { titulo: string; cuerpo: string; ruta: string } {
  const mes = MESES[Number(r.mes.slice(5, 7)) - 1];
  const vista = r.personas > 0
    ? `${veces(r.personas, 'persona vio', 'personas vieron')} tu ficha`
    : `Tu ficha se abrió ${veces(r.aperturas, 'vez', 'veces')}`;
  const contacto = r.contactos > 0
    ? ` y recibiste ${veces(r.contactos, 'contacto', 'contactos')}`
    : '';
  let comparacion = '';
  if (r.aperturas_antes > 0 && r.aperturas !== r.aperturas_antes) {
    const cambio = Math.round(((r.aperturas - r.aperturas_antes) / r.aperturas_antes) * 100);
    comparacion = cambio > 0 ? ` (${cambio}% más que el mes anterior)` : ` (${-cambio}% menos que el mes anterior)`;
  }
  return {
    titulo: `📊 ${r.nombre.trim() || 'Tu comercio'}: tu resumen de ${mes}`,
    cuerpo: `${vista}${contacto}${comparacion}. Tocá para ver el detalle.`,
    ruta: `/negocio/estadisticas/${r.business_id}`,
  };
}
