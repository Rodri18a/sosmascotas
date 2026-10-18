// Texto de la push a quienes seguían un SOS (en voseo, como la app).

/** El autor marcó "¡Apareció!". */
export const textoReencuentro = (nombre: string | null) => ({
  titulo: `🎉 ¡${nombre?.trim() ? nombre.trim() : 'La mascota que seguías'} volvió a casa!`,
  cuerpo: 'Gracias por estar atento. Tocá para ver el reporte.',
});
