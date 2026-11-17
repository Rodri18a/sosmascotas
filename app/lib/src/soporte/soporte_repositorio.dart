import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Correo de soporte si la base no responde (el mismo que carga la migración).
const correoSoporteDefecto = 'soporte@huellamy.com';

/// Cómo contactar a soporte (0.8.6b, D160). Sale de `app_settings`, así el
/// WhatsApp se suma más adelante sin compilar: si no está, no se muestra.
class ContactoSoporte {
  const ContactoSoporte({this.correo = correoSoporteDefecto, this.whatsapp});

  final String correo;

  /// Número de WhatsApp de soporte, solo dígitos con el código de país
  /// (por ejemplo 598…). Es el de la empresa, no el de una persona.
  final String? whatsapp;
}

enum ErrorSoporte { muyCorto, demasiados, otro }

class SoporteException implements Exception {
  const SoporteException(this.tipo);

  final ErrorSoporte tipo;
}

abstract interface class SoporteRepositorio {
  Future<ContactoSoporte> contacto();

  /// «Escribinos»: el mensaje queda en el portal → Contactos, con el nombre y
  /// el correo de la cuenta (los pone la base).
  Future<void> enviar(String mensaje);
}

class SupabaseSoporteRepositorio implements SoporteRepositorio {
  SupabaseSoporteRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<ContactoSoporte> contacto() async {
    final filas = await _cliente
        .from('app_settings')
        .select('key, value')
        .inFilter('key', ['support_email', 'support_whatsapp']);
    final valores = {
      for (final f in filas) f['key'] as String: (f['value'] as String).trim(),
    };
    final whatsapp = (valores['support_whatsapp'] ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    );
    return ContactoSoporte(
      correo: (valores['support_email'] ?? '').contains('@')
          ? valores['support_email']!
          : correoSoporteDefecto,
      whatsapp: whatsapp.length >= 8 ? whatsapp : null,
    );
  }

  @override
  Future<void> enviar(String mensaje) async {
    try {
      await _cliente.rpc<void>(
        'enviar_soporte',
        params: {'p_mensaje': mensaje.trim()},
      );
    } on PostgrestException catch (e) {
      throw SoporteException(switch (e.code) {
        '22023' => ErrorSoporte.muyCorto,
        'P0001' when e.message.contains('demasiados') =>
          ErrorSoporte.demasiados,
        _ => ErrorSoporte.otro,
      });
    }
  }
}

class SoporteSinConfigurar implements SoporteRepositorio {
  const SoporteSinConfigurar();

  @override
  Future<ContactoSoporte> contacto() async => const ContactoSoporte();

  @override
  Future<void> enviar(String mensaje) async =>
      throw const SoporteException(ErrorSoporte.otro);
}

final soporteRepositorioProvider = Provider<SoporteRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const SoporteSinConfigurar()
      : SupabaseSoporteRepositorio(cliente);
});

/// Si la base no responde, igual se muestra el correo de siempre.
final contactoSoporteProvider = FutureProvider<ContactoSoporte>((ref) async {
  try {
    return await ref.watch(soporteRepositorioProvider).contacto();
  } on Exception {
    return const ContactoSoporte();
  }
});
