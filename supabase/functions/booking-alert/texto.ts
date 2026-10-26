// Textos de la push de los turnos (3.1, D104), en voseo como la app.

export type AvisoTurno = {
  destino: 'cliente' | 'negocio';
  estado: string;
  negocio: string | null;
  inicio: string;
  servicio: string | null;
  mascota: string | null;
};

const DIAS = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];

/** «el martes 27/10 a las 09:00», con la hora de Uruguay (UTC−3, sin horario de verano). */
export function cuando(inicio: string): string {
  const uy = new Date(new Date(inicio).getTime() - 3 * 60 * 60 * 1000);
  const hh = String(uy.getUTCHours()).padStart(2, '0');
  const mm = String(uy.getUTCMinutes()).padStart(2, '0');
  return `el ${DIAS[uy.getUTCDay()]} ${uy.getUTCDate()}/${uy.getUTCMonth() + 1} a las ${hh}:${mm}`;
}

/** `null` si ese estado no se avisa a ese destino. */
export function textoTurno(a: AvisoTurno): { titulo: string; cuerpo: string; ruta: string } | null {
  const comercio = a.negocio?.trim() || 'El comercio';
  const que = [a.servicio?.trim(), a.mascota?.trim() ? `para ${a.mascota.trim()}` : null].filter(Boolean).join(' ');
  const detalle = `${que ? `${que}, ` : ''}${cuando(a.inicio)}`;
  if (a.destino === 'negocio') {
    const ruta = '/negocio?seccion=agenda';
    switch (a.estado) {
      case 'pending':
        return { titulo: '📅 Turno nuevo', cuerpo: `Te pidieron un turno: ${detalle}. Tocá para confirmarlo.`, ruta };
      case 'cancelled':
        return { titulo: 'Turno cancelado', cuerpo: `Cancelaron el turno de ${detalle}.`, ruta };
      default:
        return null;
    }
  }
  const ruta = '/turnos';
  switch (a.estado) {
    case 'confirmed':
      return { titulo: '✅ Turno confirmado', cuerpo: `${comercio} confirmó tu turno: ${detalle}.`, ruta };
    case 'rejected':
      return { titulo: 'Turno no disponible', cuerpo: `${comercio} no puede atenderte ${cuando(a.inicio)}. Probá con otro horario.`, ruta };
    case 'cancelled':
      return { titulo: 'Turno cancelado', cuerpo: `${comercio} canceló tu turno de ${detalle}.`, ruta };
    default:
      return null;
  }
}

export function textoRecordatorio(a: { negocio: string | null; inicio: string; servicio: string | null; mascota: string | null }) {
  const comercio = a.negocio?.trim() || 'el comercio';
  const para = a.mascota?.trim() ? ` con ${a.mascota.trim()}` : '';
  return {
    titulo: '⏰ Mañana tenés turno',
    cuerpo: `${a.servicio?.trim() ? `${a.servicio.trim()} en ` : ''}${comercio}${para}, ${cuando(a.inicio)}. Si no podés ir, cancelalo desde la app.`,
    ruta: '/turnos',
  };
}
