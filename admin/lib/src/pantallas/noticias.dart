import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';

/// Noticias de la app (2.8, D83): borradores, publicadas y ocultas. Las
/// patrocinadas llevan la marca y en la app se ven "Promocionado · marca".
class NoticiasScreen extends ConsumerWidget {
  const NoticiasScreen({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Map<String, Object?>? noticia,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(noticia: noticia),
    );
    if (guardado ?? false) ref.invalidate(noticiasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context, ref),
      icon: const Icon(Icons.add),
      label: const Text(T.nuevaNoticia),
    ),
    body: switch (ref.watch(noticiasProvider)) {
      AsyncData(value: final lista) when lista.isEmpty => const Center(
        child: Text(T.sinNoticias),
      ),
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          for (final n in lista)
            ListTile(
              title: Text('${n['title']}'),
              subtitle: Text(
                [
                  T.estadosNoticia[n['status']] ?? '${n['status']}',
                  if (n['sponsored'] == true) '💲 ${n['sponsor_name']}',
                  _especies(n['species_ids']),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editar(context, ref, n),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(noticiasProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

String _especies(Object? ids) {
  final lista = [
    for (final e in (ids as List?) ?? const []) (e as num).toInt(),
  ];
  return lista.isEmpty
      ? T.todasLasEspecies
      : lista.map((e) => T.especies[e] ?? '$e').join(', ');
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.noticia});

  final Map<String, Object?>? noticia;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  Map<String, Object?> get _n => widget.noticia ?? const {};

  late final _titulo = TextEditingController(text: _n['title'] as String?);
  late final _cuerpo = TextEditingController(text: _n['body'] as String?);
  late final _fuente = TextEditingController(text: _n['source'] as String?);
  late final _enlace = TextEditingController(text: _n['link'] as String?);
  late final _marca = TextEditingController(
    text: _n['sponsor_name'] as String?,
  );
  late final _especies = <int>{
    for (final e in (_n['species_ids'] as List?) ?? const [])
      (e as num).toInt(),
  };
  late var _patrocinada = _n['sponsored'] == true;
  late var _estado = (_n['status'] as String?) ?? 'draft';
  String? _error;

  @override
  void dispose() {
    for (final c in [_titulo, _cuerpo, _fuente, _enlace, _marca]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _o(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _guardar() async {
    if (_titulo.text.trim().length < 3 || _cuerpo.text.trim().length < 10) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    if (_patrocinada && _o(_marca) == null) {
      setState(() => _error = T.faltaMarca);
      return;
    }
    try {
      await ref.read(adminRepositorioProvider).guardarNoticia({
        'id': ?_n['id'],
        'title': _titulo.text.trim(),
        'body': _cuerpo.text.trim(),
        'source': _o(_fuente),
        'link': _o(_enlace),
        'species_ids': (_especies.toList()..sort()),
        'sponsored': _patrocinada,
        'sponsor_name': _patrocinada ? _o(_marca) : null,
        'status': _estado,
      });
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.datosInvalidos);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.noticia == null ? T.nuevaNoticia : T.noticias),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: T.estado),
              items: [
                for (final MapEntry(:key, :value) in T.estadosNoticia.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _estado = v ?? _estado),
            ),
            TextField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: T.tituloNoticia),
            ),
            TextField(
              controller: _cuerpo,
              minLines: 4,
              maxLines: 12,
              decoration: const InputDecoration(labelText: T.cuerpo),
            ),
            TextField(
              controller: _fuente,
              decoration: const InputDecoration(labelText: T.fuente),
            ),
            TextField(
              controller: _enlace,
              decoration: const InputDecoration(labelText: T.enlace),
            ),
            const SizedBox(height: 12),
            const Text(T.especiesNoticia),
            Wrap(
              spacing: 6,
              children: [
                for (final MapEntry(:key, :value) in T.especies.entries)
                  FilterChip(
                    label: Text(value),
                    selected: _especies.contains(key),
                    onSelected: (si) => setState(
                      () => si ? _especies.add(key) : _especies.remove(key),
                    ),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(T.patrocinada),
              value: _patrocinada,
              onChanged: (v) => setState(() => _patrocinada = v),
            ),
            if (_patrocinada)
              TextField(
                controller: _marca,
                decoration: const InputDecoration(labelText: T.marca),
              ),
            if (_error case final e?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  e,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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
