import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';

int _n(Object? v) => (v as num?)?.toInt() ?? 0;

/// Espacios de publicidad (plan de mejoras 3.2, D137): vistas, personas y
/// toques de cada promoción del muro y de cada banner del carrusel, para
/// vender y para rendirle cuentas a cada patrocinador.
class EspaciosScreen extends ConsumerStatefulWidget {
  const EspaciosScreen({super.key});

  @override
  ConsumerState<EspaciosScreen> createState() => _EspaciosScreenState();
}

class _EspaciosScreenState extends ConsumerState<EspaciosScreen> {
  var _dias = 30;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(T.espaciosAyuda, style: tema.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<int>(
            segments: [
              for (final d in const [7, 30, 90])
                ButtonSegment(value: d, label: Text(T.ultimosDias(d))),
            ],
            selected: {_dias},
            onSelectionChanged: (s) => setState(() => _dias = s.first),
          ),
        ),
        const SizedBox(height: 12),
        switch (ref.watch(espaciosProvider(_dias))) {
          AsyncData(value: final filas) when filas.isEmpty => const Padding(
            padding: EdgeInsets.all(24),
            child: Text(T.sinEspacios),
          ),
          AsyncData(value: final filas) => Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text(T.tipo)),
                  DataColumn(label: Text(T.tituloEspacio)),
                  DataColumn(label: Text(T.deQuien)),
                  DataColumn(label: Text(T.estado)),
                  DataColumn(label: Text(T.vistas), numeric: true),
                  DataColumn(label: Text(T.personas), numeric: true),
                  DataColumn(label: Text(T.toques), numeric: true),
                  DataColumn(label: Text(T.tasaToques), numeric: true),
                ],
                rows: [
                  for (final f in filas)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            f['tipo'] == 'promo' ? T.promocionMuro : T.banner,
                          ),
                        ),
                        DataCell(Text('${f['titulo'] ?? ''}')),
                        DataCell(Text('${f['de_quien'] ?? '—'}')),
                        DataCell(
                          Text(
                            T.estadosEspacio[f['estado']] ?? '${f['estado']}',
                          ),
                        ),
                        DataCell(Text('${_n(f['vistas'])}')),
                        DataCell(Text('${_n(f['personas'])}')),
                        DataCell(Text('${_n(f['toques'])}')),
                        DataCell(
                          Text(
                            _n(f['vistas']) == 0
                                ? '—'
                                : '${(100 * _n(f['toques']) / _n(f['vistas'])).toStringAsFixed(1)} %',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          AsyncError() => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(espaciosProvider(_dias)),
              child: const Text(T.reintentar),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}
