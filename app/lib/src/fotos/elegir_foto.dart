import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import 'selector_foto.dart';

/// Pregunta "sacar una foto / elegir de la galería" y devuelve la foto tal cual
/// (`null` si la persona cancela). Después hay que pasarla por `prepararFoto`
/// (achica y **quita el EXIF**) antes de mostrarla o subirla.
Future<Uint8List?> elegirFoto(BuildContext context, WidgetRef ref) async {
  final t = context.t;
  final origen = await showModalBottomSheet<OrigenFoto>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(t.mascotaSacarFoto),
            onTap: () => Navigator.pop(context, OrigenFoto.camara),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(t.mascotaElegirFoto),
            onTap: () => Navigator.pop(context, OrigenFoto.galeria),
          ),
        ],
      ),
    ),
  );
  if (origen == null) return null;
  return ref.read(selectorFotoProvider)(origen);
}
