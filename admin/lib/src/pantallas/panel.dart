import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';

/// Panel general (1.8.2): indicadores de `05-portal-admin.md`.
class PanelScreen extends ConsumerWidget {
  const PanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(diasPanelProvider);
    return switch (ref.watch(panelProvider)) {
      AsyncData(value: final p) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text(T.ultimos),
              const SizedBox(width: 8),
              SegmentedButton<int>(
                segments: [
                  for (final d in const [7, 30, 90])
                    ButtonSegment(value: d, label: Text('$d días')),
                ],
                selected: {dias},
                onSelectionChanged: (s) =>
                    ref.read(diasPanelProvider.notifier).elegir(s.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (clave, texto) in const [
                ('usuarios', T.usuarios),
                ('usuarios_nuevos', T.usuariosNuevos),
                ('activos_dia', T.activosDia),
                ('activos_semana', T.activosSemana),
                ('activos_mes', T.activosMes),
                ('mascotas', T.mascotas),
                ('hogares', T.hogares),
                ('sos_activos', T.sosActivos),
                ('sos_publicados', T.sosPublicados),
                ('sos_resueltos', T.sosResueltos),
                ('escaneos_qr', T.escaneos),
                ('avisos', T.avisos),
                ('pendientes_moderacion', T.pendientes),
              ])
                _Numero(texto: texto, valor: '${p.entero(clave)}'),
              _Numero(
                texto: T.diasHastaResolver,
                valor: switch (p.decimal('sos_dias_hasta_resolver')) {
                  final d? => d.toStringAsFixed(1).replaceAll('.', ','),
                  null => '—',
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Conteos(
            titulo: T.comerciosPorRubro,
            datos: p.conteos('comercios_por_rubro'),
            nombres: T.rubros,
          ),
          const SizedBox(height: 16),
          _Conteos(
            titulo: T.comerciosPorEstado,
            datos: p.conteos('comercios_por_estado'),
            nombres: T.estadosVerificacion,
          ),
          const SizedBox(height: 16),
          const _Demanda(),
        ],
      ),
      AsyncError() => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(panelProvider),
          child: const Text(T.reintentar),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.texto, required this.valor});

  final String texto;
  final String valor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 170,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor, style: Theme.of(context).textTheme.headlineMedium),
            Text(texto),
          ],
        ),
      ),
    ),
  );
}

class _Conteos extends StatelessWidget {
  const _Conteos({
    required this.titulo,
    required this.datos,
    required this.nombres,
  });

  final String titulo;
  final Map<String, int> datos;
  final Map<String, String> nombres;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          if (datos.isEmpty)
            const Text(T.sinDatos)
          else
            for (final MapEntry(:key, :value) in datos.entries)
              Text('${nombres[key] ?? key}: $value'),
        ],
      ),
    ),
  );
}

/// Demanda sin cubrir (05, 1.8.7): lo que la gente busca y no encuentra.
class _Demanda extends ConsumerWidget {
  const _Demanda();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final d = ref.watch(demandaProvider).value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(T.demandaSinCubrir, style: tema.textTheme.titleMedium),
            Text(T.demandaExplicacion, style: tema.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (d == null || (d.porRubro.isEmpty && d.textos.isEmpty))
              const Text(T.sinDatos)
            else ...[
              for (final r in d.porRubro)
                Text(
                  T.demandaRubro(
                    T.rubros[r.rubro] ?? r.rubro,
                    r.busquedas,
                    r.sinResultados,
                    r.lugares,
                  ),
                ),
              if (d.textos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(T.demandaTextos, style: tema.textTheme.titleSmall),
                for (final x in d.textos)
                  Text(T.demandaTexto(x.texto, x.veces)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
