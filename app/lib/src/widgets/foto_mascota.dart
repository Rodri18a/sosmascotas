import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mascotas/mascotas_repositorio.dart';

/// Foto redonda de una mascota, o un ícono si no tiene.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(mascotasRepositorioProvider).urlFoto(ruta);
    final colores = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radio,
      backgroundColor: colores.primaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: icono == null
          ? Icon(
              Icons.pets_outlined,
              size: radio,
              color: colores.onPrimaryContainer,
            )
          : Text(icono!, style: TextStyle(fontSize: radio * 0.9)),
    );
  }
}
