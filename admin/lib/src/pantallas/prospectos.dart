import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Mini CRM (1.8.6): embudo prospecto → contactado → demo → Socio Fundador →
/// pagando → renovó / perdido, con notas y próximo contacto.
class ProspectosScreen extends ConsumerWidget {
  const ProspectosScreen({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Prospecto? prospecto,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(prospecto: prospecto),
    );
    if (guardado ?? false) ref.invalidate(prospectosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editar(context, ref),
      icon: const Icon(Icons.person_add_alt),
      label: const Text(T.nuevoProspecto),
    ),
    body: switch (ref.watch(prospectosProvider)) {
      AsyncData(value: final lista) when lista.isEmpty => const Center(
        child: Text(T.embudoVacio),
      ),
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          // Resumen del embudo.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final e in etapasProspecto)
                  Chip(
                    label: Text(
                      '${T.etapas[e]}: '
                      '${lista.where((p) => p.etapa == e).length}',
                    ),
                  ),
              ],
            ),
          ),
          for (final p in lista)
            ListTile(
              title: Text(p.nombre),
              subtitle: Text(
                [
                  T.etapas[p.etapa] ?? p.etapa,
                  if (p.rubro case final r?) T.rubros[r] ?? r,
                  if (p.proximoContacto case final f?)
                    '${T.proximoContacto}: '
                        '${MaterialLocalizations.of(context).formatShortDate(f)}',
                  ?p.contacto,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editar(context, ref, p),
            ),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(prospectosProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  );
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.prospecto});

  final Prospecto? prospecto;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final _nombre = TextEditingController(text: widget.prospecto?.nombre);
  late final _contacto = TextEditingController(
    text: widget.prospecto?.contacto,
  );
  late final _notas = TextEditingController(text: widget.prospecto?.notas);
  late var _etapa = widget.prospecto?.etapa ?? 'prospect';
  late String? _rubro = widget.prospecto?.rubro;
  late DateTime? _proximo = widget.prospecto?.proximoContacto;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _contacto.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().length < 2) {
      setState(() => _error = T.datosInvalidos);
      return;
    }
    try {
      await ref
          .read(adminRepositorioProvider)
          .guardarProspecto(
            Prospecto(
              id: widget.prospecto?.id ?? '',
              nombre: _nombre.text,
              rubro: _rubro,
              contacto: _contacto.text,
              etapa: _etapa,
              proximoContacto: _proximo,
              notas: _notas.text,
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) setState(() => _error = T.errorConexion);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.prospecto == null ? T.nuevoProspecto : T.prospectos),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: T.nombre),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _rubro,
              decoration: const InputDecoration(labelText: T.rubro),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                for (final MapEntry(:key, :value) in T.rubros.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (v) => setState(() => _rubro = v),
            ),
            DropdownButtonFormField<String>(
              initialValue: _etapa,
              decoration: const InputDecoration(labelText: T.etapa),
              items: [
                for (final e in etapasProspecto)
                  DropdownMenuItem(value: e, child: Text(T.etapas[e]!)),
              ],
              onChanged: (v) => setState(() => _etapa = v ?? _etapa),
            ),
            TextField(
              controller: _contacto,
              decoration: const InputDecoration(labelText: T.contacto),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(T.proximoContacto),
              subtitle: Text(
                _proximo == null
                    ? T.sinFecha
                    : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(_proximo!),
              ),
              onTap: () async {
                final hoy = DateTime.now();
                final f = await showDatePicker(
                  context: context,
                  initialDate: _proximo ?? hoy,
                  firstDate: DateTime(hoy.year - 1),
                  lastDate: DateTime(hoy.year + 2),
                );
                if (f != null) setState(() => _proximo = f);
              },
            ),
            TextField(
              controller: _notas,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: T.notas),
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
