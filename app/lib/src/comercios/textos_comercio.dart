import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';

/// Nombre del rubro en plural (chips del mapa).
String textoCategorias(AppLocalizations t, Categoria c) => switch (c) {
  Categoria.vet => t.catVeterinarias,
  Categoria.petshop => t.catPetshops,
  Categoria.pharmacy => t.catFarmacias,
  Categoria.grooming => t.catPeluquerias,
  Categoria.walker => t.catPaseadores,
  Categoria.hotel => t.catHoteles,
  Categoria.trainer => t.catAdiestradores,
  Categoria.petFriendly => t.catAceptan,
  Categoria.shelter => t.catRefugios,
  Categoria.agro => t.catAgros,
};

/// Nombre del rubro en singular (ficha y lista).
String textoCategoria(AppLocalizations t, Categoria c) => switch (c) {
  Categoria.vet => t.catVeterinaria,
  Categoria.petshop => t.catPetshop,
  Categoria.pharmacy => t.catFarmacia,
  Categoria.grooming => t.catPeluqueria,
  Categoria.walker => t.catPaseador,
  Categoria.hotel => t.catHotel,
  Categoria.trainer => t.catAdiestrador,
  Categoria.petFriendly => t.catAcepta,
  Categoria.shelter => t.catRefugio,
  Categoria.agro => t.catAgro,
};
