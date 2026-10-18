import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sesion.dart';
import '../textos.dart';

class IngresoScreen extends ConsumerStatefulWidget {
  const IngresoScreen({super.key});

  @override
  ConsumerState<IngresoScreen> createState() => _IngresoScreenState();
}

class _IngresoScreenState extends ConsumerState<IngresoScreen> {
  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  var _enviado = false;
  var _ocupado = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await accion();
    } on Exception {
      if (mounted) setState(() => _error = T.noSePudo);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = ref.read(sesionProvider);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  T.titulo,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _correo,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: T.correo),
                ),
                const SizedBox(height: 12),
                if (!_enviado)
                  FilledButton(
                    onPressed: _ocupado
                        ? null
                        : () => _hacer(() async {
                            await sesion.enviarCodigo(_correo.text);
                            if (mounted) setState(() => _enviado = true);
                          }),
                    child: const Text(T.enviarCodigo),
                  )
                else ...[
                  const Text(T.codigoEnviado),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codigo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: T.codigo),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _ocupado
                        ? null
                        : () => _hacer(
                            () => sesion.verificar(_correo.text, _codigo.text),
                          ),
                    child: const Text(T.entrar),
                  ),
                ],
                if (_error case final e?) ...[
                  const SizedBox(height: 12),
                  Text(
                    e,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
