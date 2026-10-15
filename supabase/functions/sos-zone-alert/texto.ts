// Textos de la push de un SOS cercano (en voseo, como la app).

// "un perro", "una tortuga"… (slugs de public.species).
const ANIMAL: Record<string, string> = {
  dog: 'un perro', cat: 'un gato', bird: 'un ave', rabbit: 'un conejo',
  rodent: 'un roedor', turtle: 'una tortuga', reptile: 'un reptil',
  fish: 'un pez', horse: 'un caballo',
};

export const distanciaEnTexto = (metros: number) =>
  metros < 1000 ? 'a menos de 1 km' : `a unos ${Math.round(metros / 1000)} km`;

export function textoDelAviso(
  tipo: 'lost' | 'found',
  especie: string | null,
  nombre: string | null,
  metros: number,
): { titulo: string; cuerpo: string } {
  const animal = ANIMAL[especie ?? ''] ?? 'una mascota';
  const distancia = distanciaEnTexto(metros);
  if (tipo === 'lost') {
    return {
      titulo: `🐾 Se perdió ${animal} cerca tuyo`,
      cuerpo: `${nombre ? `${nombre}, ` : ''}${distancia}. Tocá para ver la foto.`,
    };
  }
  return {
    titulo: `🐾 Encontraron ${animal} cerca tuyo`,
    cuerpo: `${distancia[0].toUpperCase()}${distancia.slice(1)}. ¿Sabés de quién es?`,
  };
}
