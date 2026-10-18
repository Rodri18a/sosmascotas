import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../chat/chat_repositorio.dart';
import '../cuenta/servicio_cuenta.dart';
import '../funcionalidades/funcionalidades_activas.dart';
import '../router.dart';

/// Mensajes del chat (solo con sesión y con la funcionalidad `chat`), con la
/// cantidad sin leer.
class BotonMensajes extends ConsumerWidget {
  const BotonMensajes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(conectadoProvider) ||
        !ref.watch(funcionalidadActivaProvider(Funcionalidades.chat))) {
      return const SizedBox.shrink();
    }
    final sinLeer = (ref.watch(conversacionesProvider).value ?? const [])
        .fold<int>(0, (total, c) => total + c.sinLeer);
    return IconButton(
      tooltip: context.t.chatMensajes,
      onPressed: () => context.push(Rutas.chats),
      icon: Badge(
        isLabelVisible: sinLeer > 0,
        label: Text('$sinLeer'),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}
