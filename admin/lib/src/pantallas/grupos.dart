import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Grupos de la comunidad (3.4, D116): crear los de especie y tema, editar y
/// ocultar cualquiera. Lo que se publica se modera en Moderación.
class GruposScreen extends ConsumerWidget {
  const GruposScreen({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    GrupoAdmin? grupo,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(grupo: grupo),
    );
    if (guardado ?? false) ref.invalidate(gruposProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(T.nuevoGrupo),
    ),
    body: switch (ref.watch(gruposProvider)) {
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          const ListTile(subtitle: Text(T.gruposAyuda)),
          for (final g in lista)
            ListTile(
              leading: CircleAvatar(child: Text(g.icono ?? '🐾')),
              title: Text(g.nombre),
              subtitle: Text(
                [
                  T.tiposGrupo[g.tipo] ?? g.tipo,
                  if (!g.activo) 'oculto',
                  T.grupoResumen(g.miembros, g.publicaciones, g.ocultas),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editar(context, ref, g),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(gruposProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.grupo});

  final GrupoAdmin? grupo;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _nombre = TextEditingController(text: widget.grupo?.nombre);
  late final _descripcion = TextEditingController(
    text: widget.grupo?.descripcion,
  );
  late final _icono = TextEditingController(text: widget.grupo?.icono);
  late var _activo = widget.grupo?.activo ?? true;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _icono]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().length < 3) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    try {
      await ref.read(adminRepositorioProvider).guardarGrupo({
        'id': ?widget.grupo?.id,
        if (widget.grupo == null) 'kind': 'topic',
        'name': _nombre.text.trim(),
        'description': _descripcion.text.trim(),
        'icon': _icono.text.trim(),
        'status': _activo ? 'active' : 'hidden',
      });
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.datosInvalidos);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.grupo?.nombre ?? T.nuevoGrupo),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (c, etiqueta) in [
              (_nombre, T.grupoNombre),
              (_descripcion, T.grupoDescripcion),
              (_icono, T.grupoIcono),
            ])
              TextField(
                controller: c,
                decoration: InputDecoration(labelText: etiqueta),
              ),
            SwitchListTile(
              title: const Text(T.grupoActivo),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
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
