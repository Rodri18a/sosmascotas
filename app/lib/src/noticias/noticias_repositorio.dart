import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Noticias (2.8, D83). Se reemplaza en las pruebas.
abstract interface class NoticiasRepositorio {
  /// Las publicadas, de la más nueva a la más vieja (también visitantes).
  Future<List<Noticia>> noticias();
}

class SupabaseNoticiasRepositorio implements NoticiasRepositorio {
  SupabaseNoticiasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Noticia>> noticias() async {
    // Se traen todas (hasta 60) y el filtro por especie se hace en la app:
    // cambiar el chip no vuelve a consultar.
    final filas = await _cliente.rpc<List<dynamic>>('noticias');
    return [
      for (final f in filas)
        Noticia.fromJson((f as Map).cast<String, Object?>()),
    ];
  }
}

class NoticiasSinConfigurar implements NoticiasRepositorio {
  const NoticiasSinConfigurar();

  @override
  Future<List<Noticia>> noticias() async => const [];
}

final noticiasRepositorioProvider = Provider<NoticiasRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const NoticiasSinConfigurar()
      : SupabaseNoticiasRepositorio(cliente);
});

final noticiasProvider = FutureProvider<List<Noticia>>(
  (ref) => ref.watch(noticiasRepositorioProvider).noticias(),
);
