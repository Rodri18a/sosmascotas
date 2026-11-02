import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositorio.dart';
import '../textos.dart';
import '../utiles/descargar.dart';
import 'sponsors.dart' show elegirImagenProvider;

int _n(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _fecha(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

String _dia(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Banners del carrusel de Inicio (D128): imagen, a dónde lleva, fechas y
/// orden. Los patrocinados se ven "Promocionado · marca" en la app.
class BannersSeccion extends ConsumerWidget {
  const BannersSeccion({super.key});

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    Map<String, Object?>? banner,
  ]) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _Formulario(banner: banner),
    );
    if (guardado ?? false) ref.invalidate(bannersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(adminRepositorioProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(T.nuevoBanner),
      ),
      body: switch (ref.watch(bannersProvider)) {
        AsyncData(value: final lista) when lista.isEmpty => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(T.sinBanners, textAlign: TextAlign.center),
          ),
        ),
        AsyncData(value: final lista) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(T.ayudaBanners),
            ),
            for (final b in lista)
              ListTile(
                leading: SizedBox(
                  width: 96,
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        repo.urlBanner('${b['image_path']}'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                ),
                title: Text('${b['title']}'),
                subtitle: Text(
                  [
                    T.resumenBanner(
                      T.estadosBanner[b['status']] ?? '${b['status']}',
                      _n(b['sort_order']),
                      [
                        if (_fecha(b['starts_at']) case final d?) _dia(d),
                        if (_fecha(b['ends_at']) case final d?)
                          _dia(d)
                        else
                          T.sinFin,
                      ].join(' → '),
                    ),
                    if (b['sponsored'] == true) '💲 ${b['sponsor_name']}',
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editar(context, ref, b),
              ),
          ],
        ),
        AsyncError() => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(bannersProvider),
            child: const Text(T.reintentar),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({this.banner});

  final Map<String, Object?>? banner;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  Map<String, Object?> get _b => widget.banner ?? const {};

  late final _titulo = TextEditingController(text: _b['title'] as String?);
  late final _enlace = TextEditingController(text: _b['link'] as String?);
  late final _marca = TextEditingController(
    text: _b['sponsor_name'] as String?,
  );
  late final _orden = TextEditingController(text: '${_n(_b['sort_order'])}');
  late var _estado = (_b['status'] as String?) ?? 'draft';
  late var _destino = _b['news_id'] != null
      ? 'noticia'
      : _b['link'] != null
      ? 'enlace'
      : 'nada';
  late String? _noticia = _b['news_id'] as String?;
  late var _patrocinado = _b['sponsored'] == true;
  late var _desde = _fecha(_b['starts_at']) ?? DateTime.now();
  late DateTime? _hasta = _fecha(_b['ends_at']);
  late final String? _imagenActual = _b['image_path'] as String?;
  ImagenElegida? _imagenNueva;
  String? _error;
  var _guardando = false;

  static const _tipos = {'image/png', 'image/jpeg', 'image/webp'};

  @override
  void dispose() {
    for (final c in [_titulo, _enlace, _marca, _orden]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirImagen() async {
    final imagen = await ref.read(elegirImagenProvider)();
    if (imagen == null || !mounted) return;
    if (!_tipos.contains(imagen.tipo) || imagen.bytes.length > 1024 * 1024) {
      setState(() => _error = T.imagenBannerGrande);
      return;
    }
    setState(() {
      _imagenNueva = imagen;
      _error = null;
    });
  }

  Future<void> _elegirFecha({required bool hasta}) async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: (hasta ? _hasta : _desde) ?? _desde,
      firstDate: DateTime(2026),
      lastDate: DateTime(2036),
    );
    if (elegida == null || !mounted) return;
    setState(() {
      if (hasta) {
        // Hasta el final de ese día.
        _hasta = elegida.add(const Duration(hours: 23, minutes: 59));
      } else {
        _desde = elegida;
      }
    });
  }

  String? _validar() {
    final enlace = _enlace.text.trim();
    if (_titulo.text.trim().length < 3) return T.datosInvalidos;
    if (_imagenActual == null && _imagenNueva == null) return T.sinImagenBanner;
    if (_destino == 'enlace' && !enlace.startsWith('https://')) {
      return T.faltaDestinoBanner;
    }
    if (_destino == 'noticia' && _noticia == null) return T.faltaDestinoBanner;
    if (_patrocinado && _marca.text.trim().isEmpty) return T.faltaMarcaBanner;
    if (_hasta case final h? when !h.isAfter(_desde)) return T.datosInvalidos;
    return null;
  }

  Future<void> _guardar() async {
    if (_validar() case final error?) {
      setState(() => _error = error);
      return;
    }
    setState(() => _guardando = true);
    final repo = ref.read(adminRepositorioProvider);
    try {
      final imagen = switch (_imagenNueva) {
        final i? => await repo.subirBanner(i.bytes, i.tipo),
        null => _imagenActual,
      };
      await repo.guardarBanner({
        'id': ?_b['id'],
        'title': _titulo.text.trim(),
        'image_path': imagen,
        'link': _destino == 'enlace' ? _enlace.text.trim() : null,
        'news_id': _destino == 'noticia' ? _noticia : null,
        'sponsored': _patrocinado,
        'sponsor_name': _patrocinado ? _marca.text.trim() : null,
        'sort_order': int.tryParse(_orden.text.trim()) ?? 0,
        'status': _estado,
        'starts_at': _desde.toUtc().toIso8601String(),
        'ends_at': _hasta?.toUtc().toIso8601String(),
      });
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = T.errorConexion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicadas = [
      for (final n
          in ref.watch(noticiasProvider).value ??
              const <Map<String, Object?>>[])
        if (n['status'] == 'published' || n['id'] == _noticia) n,
    ];
    final sinImagen = _imagenActual == null && _imagenNueva == null;
    return AlertDialog(
      title: Text(widget.banner == null ? T.nuevoBanner : T.editarBanner),
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
                  for (final MapEntry(:key, :value) in T.estadosBanner.entries)
                    DropdownMenuItem(value: key, child: Text(value)),
                ],
                onChanged: (v) => setState(() => _estado = v ?? _estado),
              ),
              TextField(
                controller: _titulo,
                maxLength: 80,
                decoration: const InputDecoration(labelText: T.tituloBanner),
              ),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _elegirImagen,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      sinImagen ? T.elegirImagenBanner : T.cambiarImagenBanner,
                    ),
                  ),
                  Text(sinImagen ? T.sinImagenBanner : T.imagenBannerLista),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _destino,
                decoration: const InputDecoration(labelText: T.destinoBanner),
                items: [
                  for (final MapEntry(:key, :value) in T.destinosBanner.entries)
                    DropdownMenuItem(value: key, child: Text(value)),
                ],
                onChanged: (v) => setState(() => _destino = v ?? _destino),
              ),
              if (_destino == 'enlace')
                TextField(
                  controller: _enlace,
                  decoration: const InputDecoration(labelText: T.enlaceBanner),
                ),
              if (_destino == 'noticia')
                DropdownButtonFormField<String>(
                  initialValue: _noticia,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: T.noticiaBanner),
                  items: [
                    for (final n in publicadas)
                      DropdownMenuItem(
                        value: '${n['id']}',
                        child: Text(
                          '${n['title']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _noticia = v),
                ),
              TextField(
                controller: _orden,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: T.ordenBanner),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _elegirFecha(hasta: false),
                    child: Text('${T.desde}: ${_dia(_desde)}'),
                  ),
                  OutlinedButton(
                    onPressed: () => _elegirFecha(hasta: true),
                    child: Text(
                      '${T.hasta}: ${switch (_hasta) {
                        final h? => _dia(h),
                        null => T.sinFin,
                      }}',
                    ),
                  ),
                  if (_hasta != null)
                    IconButton(
                      tooltip: T.sinFin,
                      onPressed: () => setState(() => _hasta = null),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(T.patrocinado),
                value: _patrocinado,
                onChanged: (v) => setState(() => _patrocinado = v),
              ),
              if (_patrocinado)
                TextField(
                  controller: _marca,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: T.marca),
                ),
              if (_error case final e?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    e,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: const Text(T.guardar),
        ),
      ],
    );
  }
}
