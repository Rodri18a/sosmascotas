// Textos de la push de los pedidos (3.2, D100), en voseo como la app.

export type AvisoPedido = {
  destino: 'cliente' | 'negocio';
  numero: number;
  estado: string;
  negocio: string | null;
};

/** `null` si ese estado no se avisa a ese destino. */
export function textoPedido(a: AvisoPedido): { titulo: string; cuerpo: string; ruta: string } | null {
  const n = `#${a.numero}`;
  const comercio = a.negocio?.trim() || 'El comercio';
  if (a.destino === 'negocio') {
    const ruta = '/negocio?seccion=pedidos';
    switch (a.estado) {
      case 'new':
        return { titulo: `🛍️ Pedido nuevo ${n}`, cuerpo: 'Te hicieron un pedido. Tocá para verlo.', ruta };
      case 'cancelled':
        return { titulo: `Pedido ${n} cancelado`, cuerpo: 'Quien lo hizo lo canceló.', ruta };
      default:
        return null;
    }
  }
  const ruta = '/pedidos';
  switch (a.estado) {
    case 'preparing':
      return { titulo: `Pedido ${n}: en preparación`, cuerpo: `${comercio} está preparando tu pedido.`, ruta };
    case 'ready':
      return { titulo: `✅ ¡Tu pedido ${n} está listo!`, cuerpo: `${comercio} ya lo tiene listo.`, ruta };
    case 'delivered':
      return { titulo: `Pedido ${n} entregado`, cuerpo: `Gracias por comprar en ${comercio}.`, ruta };
    case 'cancelled':
      return { titulo: `Pedido ${n} cancelado`, cuerpo: `${comercio} canceló tu pedido. Tocá para ver el detalle.`, ruta };
    default:
      return null;
  }
}
