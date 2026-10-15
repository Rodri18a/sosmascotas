// Textos de las push al dueño (en voseo, como la app).

/** Alguien abrió la página del QR de su mascota. */
export const textoEscaneo = (mascota: string | null) => ({
  titulo: `📍 Escanearon el QR de ${mascota ?? 'tu mascota'}`,
  cuerpo: 'Tocá para ver si compartió su ubicación.',
});

/** Alguien dejó un aviso con mensaje (desde el QR o desde un SOS). */
export const textoAvisoAlDueno = (tipo: 'qr' | 'sos', nombre: string | null) => ({
  titulo: tipo === 'qr'
    ? `💬 Alguien vio a ${nombre ?? 'tu mascota'} y te dejó un mensaje`
    : `💬 Te dejaron un aviso sobre ${nombre ?? 'tu reporte'}`,
  cuerpo: 'Tocá para leerlo y decidir cómo responder.',
});
