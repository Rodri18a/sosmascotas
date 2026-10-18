import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Directorio de Ayuda (1.8.8): refugios, protectoras, grupos y organismos,
/// con el enlace a las adopciones de cada refugio.
class AyudaScreen extends ConsumerWidget {
  const AyudaScreen({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    EntradaAyuda? entrada,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(entrada: entrada),
    );
    if (guardado ?? false) ref.invalidate(ayudaProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(T.nuevaEntrada),
    ),
    body: switch (ref.watch(ayudaProvider)) {
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          for (final e in lista)
            ListTile(
              title: Text(e.nombre),
              subtitle: Text(
                [
                  T.tiposAyuda[e.tipo] ?? e.tipo,
                  if (!e.activa) 'oculta',
                  ?e.enlace,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editar(context, ref, e),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(ayudaProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.entrada});

  final EntradaAyuda? entrada;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _nombre = TextEditingController(text: widget.entrada?.nombre);
  late final _descripcion = TextEditingController(
    text: widget.entrada?.descripcion,
  );
  late final _telefono = TextEditingController(text: widget.entrada?.telefono);
  late final _whatsapp = TextEditingController(text: widget.entrada?.whatsapp);
  late final _enlace = TextEditingController(text: widget.entrada?.enlace);
  late var _tipo = widget.entrada?.tipo ?? 'refugio';
  late var _activa = widget.entrada?.activa ?? true;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _telefono, _whatsapp, _enlace]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _o(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _guardar() async {
    if (_nombre.text.trim().length < 2) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    try {
      await ref.read(adminRepositorioProvider).guardarAyuda({
        'id': ?widget.entrada?.id,
        'kind': _tipo,
        'name': _nombre.text.trim(),
        'description': _o(_descripcion),
        'phone': _o(_telefono),
        'whatsapp': _o(_whatsapp),
        'link': _o(_enlace),
        'status': _activa ? 'active' : 'hidden',
      });
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.datosInvalidos);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.entrada == null ? T.nuevaEntrada : T.ayuda),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: T.tipo),
              items: [
                for (final MapEntry(:key, :value) in T.tiposAyuda.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            for (final (c, etiqueta) in [
              (_nombre, T.nombre),
              (_descripcion, T.descripcion),
              (_telefono, T.telefono),
              (_whatsapp, T.whatsapp),
              (_enlace, T.enlace),
            ])
              TextField(
                controller: c,
                decoration: InputDecoration(labelText: etiqueta),
              ),
            SwitchListTile(
              title: const Text(T.activa),
              value: _activa,
              onChanged: (v) => setState(() => _activa = v),
            ),
            if (_error case final e?)
              Text(
                e,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text(T.cancelar),
      ),
      FilledButton(onPressed: _guardar, child: const Text(T.guardar)),
    ],
  );
}
