import 'comercio.dart';

/// Búsqueda de lugares (1.8.7, D97). La base busca por nombre y por el rubro
/// que se reconoce acá, así la app y la métrica `search` clasifican igual.

/// Mínimo de letras para buscar.
const minimoBusqueda = 2;

/// Largo máximo del texto que se guarda en la métrica (solo sin resultados).
const maximoTextoMetrica = 40;

/// Minúsculas, sin tildes y con un solo espacio entre palabras.
String normalizarBusqueda(String texto) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  final b = StringBuffer();
  for (final c in texto.toLowerCase().trim().split('')) {
    final i = conTilde.indexOf(c);
    b.write(i < 0 ? c : sinTilde[i]);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ');
}

/// Palabras (normalizadas, sin tildes) que llevan a cada rubro. Se compara
/// por comienzo de palabra: "pelu" encuentra "peluqueria".
const _sinonimos = <Categoria, List<String>>{
  Categoria.vet: ['veterinari', 'vete', 'clinica', 'urgencia', 'vacuna'],
  Categoria.petshop: [
    'pet shop',
    'petshop',
    'tienda',
    'racion',
    'comida',
    'accesorio',
  ],
  Categoria.pharmacy: ['farmacia', 'medicamento', 'remedio'],
  Categoria.grooming: [
    'peluqueri',
    'pelu',
    'bano',
    'banar',
    'corte',
    'estetica',
    'grooming',
  ],
  Categoria.walker: ['paseador', 'paseo', 'pasear'],
  Categoria.hotel: ['hotel', 'guarderia', 'cuidador', 'pension', 'hospedaje'],
  Categoria.trainer: ['adiestr', 'entrenador', 'educador', 'conducta'],
  Categoria.petFriendly: [
    'pet friendly',
    'petfriendly',
    'aceptan mascota',
    'cafe',
    'restaurante',
  ],
  Categoria.shelter: ['refugio', 'protectora', 'adopcion', 'adoptar'],
  Categoria.agro: [
    'agro',
    'agropecuari',
    'agroveterinari',
    'forraje',
    'semilla',
  ],
};

/// El rubro que se reconoce en [texto], o `null`. Gana el sinónimo más largo
/// ("agroveterinaria" es agro, no veterinaria).
Categoria? rubroDeBusqueda(String texto) {
  final t = normalizarBusqueda(texto);
  if (t.length < minimoBusqueda) return null;
  Categoria? rubro;
  var largo = 0;
  for (final MapEntry(key: categoria, value: palabras) in _sinonimos.entries) {
    for (final p in palabras) {
      final coincide =
          RegExp('(^| )${RegExp.escape(p)}').hasMatch(t) ||
          // Lo que se está escribiendo: "pelu" → peluquería.
          (t.length >= 3 && !t.contains(' ') && p.startsWith(t));
      if (coincide && p.length > largo) {
        rubro = categoria;
        largo = p.length;
      }
    }
  }
  return rubro;
}

/// Texto de una búsqueda sin resultados para la métrica: normalizado, sin
/// números (para que no quede un teléfono ni un documento) y cortado.
/// `null` si no queda nada.
String? textoParaMetrica(String texto) {
  final limpio = normalizarBusqueda(texto.replaceAll(RegExp(r'[0-9@]'), ' '));
  if (limpio.length < minimoBusqueda) return null;
  return limpio.length <= maximoTextoMetrica
      ? limpio
      : limpio.substring(0, maximoTextoMetrica).trimRight();
}
