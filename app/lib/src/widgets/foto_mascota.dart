import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mascotas/mascotas_repositorio.dart';
import 'ilustracion.dart';

/// Foto redonda de una mascota. Sin foto: la carita de Ami (perros) o de
/// Mishi (gatos) (D162), o el emoji de la especie para las demás.
class FotoMascota extends ConsumerWidget {
  const FotoMascota({
    required this.ruta,
    this.radio = 24,
    this.icono,
    super.key,
  });

  final String? ruta;
  final double radio;

  /// Emoji de la especie, para cuando no hay foto.
  final String? icono;

  /// Carita ilustrada para el emoji de la especie, si hay una.
  static Ilustracion? caritaDe(String? icono) => switch (icono) {
    '🐶' || '🐕' => Ilustracion.caritaPerro,
    '🐱' || '🐈' => Ilustracion.caritaGato,
    _ => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(mascotasRepositorioProvider).urlFoto(ruta);
    final colores = Theme.of(context).colorScheme;
    final carita = url == null ? caritaDe(icono) : null;
    return CircleAvatar(
      radius: radio,
      backgroundColor: colores.primaryContainer,
      foregroundImage: url != null
          ? NetworkImage(url)
          : carita != null
          ? AssetImage(carita.ruta)
          : null,
      child: switch (icono) {
        null => Icon(
          Icons.pets_outlined,
          size: radio,
          color: colores.onPrimaryContainer,
        ),
        final emoji => Text(emoji, style: TextStyle(fontSize: radio * 0.9)),
      },
    );
  }
}
