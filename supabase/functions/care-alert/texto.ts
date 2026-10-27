// Textos de la push de paseos y estadías (3.3, D115), en voseo como la app.

export type AvisoCuidado = {
  destino: 'cliente' | 'negocio';
  estado: string;
  tipo: string;
  negocio: string | null;
  desde: string;
  hasta: string;
  mascotas: string | null;
};

const TIPOS: Record<string, string> = {
  walk: 'paseo',
  daycare: 'guardería',
  boarding: 'estadía',
  home_visit: 'visitas a domicilio',
};

/** «el 24/12» o «del 24/12 al 26/12» (las fechas vienen como AAAA-MM-DD). */
export function fechas(desde: string, hasta: string): string {
  const corta = (d: string) => {
    const [, m, dia] = d.split('-').map(Number);
    return `${dia}/${m}`;
  };
  return desde === hasta ? `el ${corta(desde)}` : `del ${corta(desde)} al ${corta(hasta)}`;
}

/** `null` si ese estado no se avisa a ese destino. */
export function textoCuidado(a: AvisoCuidado): { titulo: string; cuerpo: string; ruta: string } | null {
  const prestador = a.negocio?.trim() || 'El prestador';
  const que = TIPOS[a.tipo] ?? 'cuidado';
  const para = a.mascotas?.trim() ? ` para ${a.mascotas.trim()}` : '';
  const detalle = `${que}${para}, ${fechas(a.desde, a.hasta)}`;
  if (a.destino === 'negocio') {
    const ruta = '/negocio?seccion=agenda';
    switch (a.estado) {
      case 'pending':
        return { titulo: '🐾 Pedido nuevo', cuerpo: `Te pidieron ${detalle}. Tocá para responder.`, ruta };
      case 'cancelled':
        return { titulo: 'Pedido cancelado', cuerpo: `Cancelaron ${detalle}.`, ruta };
      default:
        return null;
    }
  }
  const ruta = '/cuidados';
  switch (a.estado) {
    case 'accepted':
      return { titulo: '✅ Pedido aceptado', cuerpo: `${prestador} aceptó: ${detalle}. Coordinen por el chat.`, ruta };
    case 'rejected':
      return { titulo: 'Pedido no disponible', cuerpo: `${prestador} no puede ${fechas(a.desde, a.hasta)}. Probá con otras fechas.`, ruta };
    case 'cancelled':
      return { titulo: 'Pedido cancelado', cuerpo: `${prestador} canceló: ${detalle}.`, ruta };
    default:
      return null;
  }
}
