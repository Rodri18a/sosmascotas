import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../redireccion.dart';
import '../../router.dart';

/// Ingresar o crear cuenta con el correo (sin contraseñas).
/// Al iniciar sesión vuelve a [volver] (o al mapa).
class IngresarScreen extends ConsumerStatefulWidget {
  const IngresarScreen({this.volver, super.key});

  final String? volver;

  @override
  ConsumerState<IngresarScreen> createState() => _IngresarScreenState();
}

class _IngresarScreenState extends ConsumerState<IngresarScreen> {
  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _email = TextEditingController();
  final _codigo = TextEditingController();
  String? _emailEnviado;
  bool _ocupado = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _codigo.dispose();
    super.dispose();
  }

  /// En la web, el enlace del correo vuelve a esta misma pantalla.
  String? get _redirigirA => kIsWeb
      ? '${Uri.base.origin}${Rutas.ingresarYVolverA(volverSeguro(widget.volver))}'
      : null;

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
    } on CuentaException catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(context.t, e.tipo));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _enviar() async {
    final email = _email.text.trim().toLowerCase();
    if (!_formatoEmail.hasMatch(email)) {
      setState(() => _error = context.t.ingresarEmailInvalido);
      return;
    }
    await _ejecutar(() async {
      await ref
          .read(servicioCuentaProvider)
          .enviarCodigo(email, redirigirA: _redirigirA);
      if (mounted) setState(() => _emailEnviado = email);
    });
  }

  Future<void> _verificar() async {
    final codigo = _codigo.text.trim();
    if (codigo.length != 6) {
      setState(() => _error = context.t.ingresarCodigoInvalido);
      return;
    }
    await _ejecutar(
      () => ref
          .read(servicioCuentaProvider)
          .verificarCodigo(_emailEnviado!, codigo),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Al iniciar sesión (con el código, el enlace o Google), volver a la acción.
    ref.listen(conectadoProvider, (_, conectado) {
      if (conectado) context.go(volverSeguro(widget.volver));
    });
    final t = context.t;
    final tema = Theme.of(context);
    final emailEnviado = _emailEnviado;

    return Scaffold(
      appBar: AppBar(title: Text(t.ingresarTitulo)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (emailEnviado == null) ...[
                  Text(t.ingresarExplicacion, style: tema.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    enabled: !_ocupado,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _enviar(),
                    decoration: InputDecoration(labelText: t.ingresarCorreo),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _ocupado ? null : _enviar,
                    child: Text(t.ingresarEnviarCodigo),
                  ),
                ] else ...[
                  Text(
                    t.ingresarRevisaCorreo(emailEnviado),
                    style: tema.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codigo,
                    enabled: !_ocupado,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _verificar(),
                    decoration: InputDecoration(labelText: t.ingresarCodigo),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _ocupado ? null : _verificar,
                    child: Text(t.ingresarConfirmar),
                  ),
                  TextButton(
                    onPressed: _ocupado
                        ? null
                        : () => setState(() {
                            _emailEnviado = null;
                            _codigo.clear();
                            _error = null;
                          }),
                    child: Text(t.ingresarOtroCorreo),
                  ),
                ],
                if (_ocupado) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: TextStyle(color: tema.colorScheme.error),
                    semanticsLabel: error,
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  t.ingresarAvisoTerminos,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensaje para la persona según el tipo de error.
String mensajeDeError(AppLocalizations t, ErrorCuenta tipo) => switch (tipo) {
  ErrorCuenta.demasiadosIntentos => t.errorDemasiadosIntentos,
  ErrorCuenta.codigoInvalido => t.errorCodigoInvalido,
  ErrorCuenta.sinConexion => t.errorSinConexion,
  ErrorCuenta.noConfigurado => t.errorNoConfigurado,
  ErrorCuenta.desconocido => t.errorDesconocido,
};
