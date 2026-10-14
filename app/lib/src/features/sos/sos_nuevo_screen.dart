import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../fotos/elegir_foto.dart';
import '../../mapa/mapa_vista.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../router.dart';
import '../../sos/sos_repositorio.dart';
import '../../widgets/foto_mascota.dart';

/// Reportar una mascota perdida o encontrada.
/// Con [mascotaId], arranca como "perdí a mi mascota" con sus datos cargados.
class SosNuevoScreen extends ConsumerStatefulWidget {
  const SosNuevoScreen({this.mascotaId, super.key});

  final String? mascotaId;

  @override
  ConsumerState<SosNuevoScreen> createState() => _SosNuevoScreenState();
}

const _razaOtra = -1;
const _maximoFotos = 5;

class _SosNuevoScreenState extends ConsumerState<SosNuevoScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _razaOtraTexto = TextEditingController();
  final _color = TextEditingController();
  final _senas = TextEditingController();
  final _descripcion = TextEditingController();
  final _recompensa = TextEditingController();
  final _whatsapp = TextEditingController();
  bool _mostrarWhatsapp = false;

  TipoSos _tipo = TipoSos.perdida;
  Mascota? _mascota;
  int? _especieId;
  int? _razaId;
  Sexo _sexo = Sexo.unknown;
  bool _tieneMicrochip = false;
  DateTime _cuando = DateTime.now();
  Punto? _ubicacion;
  final _fotosNuevas = <Uint8List>[];
  bool _usarFotoDeLaFicha = false;
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.mascotaId case final id?) {
      final mascota = ref
          .read(misMascotasProvider)
          .value
          ?.where((m) => m.id == id)
          .firstOrNull;
      if (mascota != null) _precargar(mascota);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _razaOtraTexto,
      _color,
      _senas,
      _descripcion,
      _recompensa,
      _whatsapp,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "Perdí a mi mascota": se completan sus datos de la ficha.
  void _precargar(Mascota? mascota) {
    _mascota = mascota;
    if (mascota == null) return;
    _tipo = TipoSos.perdida;
    _especieId = mascota.especieId;
    _razaId = mascota.razaId ?? (mascota.razaOtra == null ? null : _razaOtra);
    _razaOtraTexto.text = mascota.razaOtra ?? '';
    _nombre.text = mascota.nombre;
    _sexo = mascota.sexo;
    _color.text = mascota.color ?? '';
    _senas.text = mascota.senas ?? '';
    _tieneMicrochip = mascota.microchip != null;
    _usarFotoDeLaFicha = mascota.fotoPath != null;
  }

  Future<void> _agregarFoto() async {
    final t = context.t;
    final original = await elegirFoto(context, ref);
    if (original == null || !mounted) return;
    setState(() => _procesando = true);
    final preparada = prepararFoto(original);
    if (!mounted) return;
    setState(() {
      _procesando = false;
      if (preparada != null) _fotosNuevas.add(preparada);
      _error = preparada == null ? t.mascotaFotoInvalida : null;
    });
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _cuando,
      firstDate: hoy.subtract(const Duration(days: 365)),
      lastDate: hoy,
    );
    if (fecha != null) setState(() => _cuando = fecha);
  }

  int get _cantidadFotos => _fotosNuevas.length + (_usarFotoDeLaFicha ? 1 : 0);

  String? _validar(AppLocalizations t) {
    if (_especieId == null) return t.mascotaEspecieFalta;
    if (_cantidadFotos == 0) return t.sosFaltaFoto;
    if (_ubicacion == null) return t.sosFaltaUbicacion;
    return null;
  }

  Future<void> _publicar() async {
    FocusScope.of(context).unfocus();
    final t = context.t;
    final problema = _validar(t);
    final valido = _form.currentState!.validate();
    if (problema != null || !valido) {
      setState(() => _error = problema);
      return;
    }
    setState(() {
      _procesando = true;
      _error = null;
    });
    final repo = ref.read(sosRepositorioProvider);
    try {
      final fotos = [
        if (_usarFotoDeLaFicha && _mascota?.fotoPath != null)
          'pet-photos/${_mascota!.fotoPath}',
        for (final foto in _fotosNuevas) await repo.subirFoto(foto),
      ];
      final id = await repo.crear(
        NuevoSos(
          tipo: _tipo,
          especieId: _especieId!,
          ubicacion: _ubicacion!,
          fotos: fotos,
          mascotaId: _tipo == TipoSos.perdida ? _mascota?.id : null,
          razaId: _razaId == _razaOtra ? null : _razaId,
          razaOtra: _razaId == _razaOtra || _razaId == null
              ? _razaOtraTexto.text
              : null,
          nombre: _nombre.text,
          sexo: _sexo,
          color: _color.text,
          senas: _senas.text,
          descripcion: _descripcion.text,
          recompensa: _recompensa.text,
          tieneMicrochip: _tieneMicrochip,
          cuando: _cuando,
        ),
      );
      if (_mostrarWhatsapp) {
        try {
          await repo.mostrarWhatsapp(id, numero: _whatsapp.text, activo: true);
        } on Exception {
          // El SOS ya se publicó; el WhatsApp se puede activar desde el detalle.
        }
      }
      ref.invalidate(misSosProvider);
      if (mounted) context.go(Rutas.detalleSos(id));
    } on SosException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = switch (e.tipo) {
          ErrorSos.limiteDiario => t.sosLimiteDiario,
          ErrorSos.datosInvalidos => t.errorDesconocido,
          ErrorSos.demasiadosAvisos => t.errorDemasiadosIntentos,
          ErrorSos.sinConexion => t.errorSinConexion,
        },
      );
    } on Exception {
      if (mounted) setState(() => _error = t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final misMascotas =
        ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    final especieId = _especieId;
    final razas = especieId == null
        ? const <Raza>[]
        : ref.watch(razasProvider(especieId)).value ?? const <Raza>[];
    final perdida = _tipo == TipoSos.perdida;

    return Scaffold(
      appBar: AppBar(title: Text(t.sosNuevoTitulo)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TipoSos>(
                  segments: [
                    ButtonSegment(
                      value: TipoSos.perdida,
                      label: Text(t.sosPerdi),
                    ),
                    ButtonSegment(
                      value: TipoSos.encontrada,
                      label: Text(t.sosEncontre),
                    ),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (s) => setState(() {
                    _tipo = s.first;
                    if (_tipo == TipoSos.encontrada) {
                      _mascota = null;
                      _usarFotoDeLaFicha = false;
                    }
                  }),
                ),
                if (perdida && misMascotas.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(t.sosCualMascota, style: tema.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in misMascotas)
                        ChoiceChip(
                          avatar: FotoMascota(ruta: m.fotoPath, radio: 12),
                          label: Text(m.nombre),
                          selected: _mascota?.id == m.id,
                          onSelected: (_) => setState(() => _precargar(m)),
                        ),
                      ChoiceChip(
                        label: Text(t.sosOtraMascota),
                        selected: _mascota == null,
                        onSelected: (_) => setState(() {
                          _mascota = null;
                          _usarFotoDeLaFicha = false;
                        }),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(t.sosFotos, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_usarFotoDeLaFicha && _mascota?.fotoPath != null)
                      InputChip(
                        avatar: FotoMascota(
                          ruta: _mascota!.fotoPath,
                          radio: 12,
                        ),
                        label: Text(t.sosFotoDeLaFicha),
                        onDeleted: () =>
                            setState(() => _usarFotoDeLaFicha = false),
                      ),
                    for (final (i, foto) in _fotosNuevas.indexed)
                      InputChip(
                        avatar: CircleAvatar(
                          backgroundImage: MemoryImage(foto),
                        ),
                        label: Text(t.sosFotoN(i + 1)),
                        onDeleted: () =>
                            setState(() => _fotosNuevas.removeAt(i)),
                      ),
                    if (_cantidadFotos < _maximoFotos)
                      ActionChip(
                        avatar: const Icon(Icons.add_a_photo_outlined),
                        label: Text(t.mascotaAgregarFoto),
                        onPressed: _procesando ? null : _agregarFoto,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  perdida ? t.sosDondePerdida : t.sosDondeEncontrada,
                  style: tema.textTheme.titleSmall,
                ),
                Text(t.sosUbicacionAyuda, style: tema.textTheme.bodySmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapaVista(
                      centro: _ubicacion ?? centroPando,
                      zoom: 14,
                      seleccion: _ubicacion,
                      onTocarMapa: (punto) =>
                          setState(() => _ubicacion = punto),
                    ),
                  ),
                ),
                if (_ubicacion != null)
                  Text(t.sosUbicacionMarcada, style: tema.textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(t.mascotaEspecie, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final especie in especies)
                      ChoiceChip(
                        label: Text('${especie.icono} ${especie.nombre}'),
                        selected: especie.id == especieId,
                        onSelected: (_) => setState(() {
                          _especieId = especie.id;
                          _razaId = null;
                        }),
                      ),
                  ],
                ),
                if (razas.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('raza-$especieId-${_mascota?.id}'),
                    initialValue: _razaId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: t.mascotaRaza),
                    items: [
                      for (final raza in razas)
                        DropdownMenuItem(
                          value: raza.id,
                          child: Text(raza.nombre),
                        ),
                      DropdownMenuItem(
                        value: _razaOtra,
                        child: Text(t.mascotaRazaOtra),
                      ),
                    ],
                    onChanged: (v) => setState(() => _razaId = v),
                  ),
                ],
                if (especieId != null &&
                    (razas.isEmpty || _razaId == _razaOtra))
                  TextFormField(
                    controller: _razaOtraTexto,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: t.mascotaRazaOtraCampo,
                    ),
                  ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombre,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: perdida ? t.mascotaNombre : t.sosNombreSiLoSabes,
                  ),
                ),
                SegmentedButton<Sexo>(
                  segments: [
                    ButtonSegment(value: Sexo.male, label: Text(t.sexoMacho)),
                    ButtonSegment(
                      value: Sexo.female,
                      label: Text(t.sexoHembra),
                    ),
                    ButtonSegment(value: Sexo.unknown, label: Text(t.noSe)),
                  ],
                  selected: {_sexo},
                  onSelectionChanged: (s) => setState(() => _sexo = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _color,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: t.mascotaColor),
                ),
                TextFormField(
                  controller: _senas,
                  maxLength: 300,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: t.mascotaSenas,
                    helperText: t.mascotaSenasAyuda,
                  ),
                ),
                TextFormField(
                  controller: _descripcion,
                  maxLength: 1000,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: t.sosDescripcion,
                    helperText: perdida
                        ? t.sosDescripcionAyudaPerdida
                        : t.sosDescripcionAyudaEncontrada,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    perdida ? t.sosCuandoPerdida : t.sosCuandoEncontrada,
                  ),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatMediumDate(_cuando),
                  ),
                  trailing: TextButton(
                    onPressed: _elegirFecha,
                    child: Text(t.mascotaNacimientoElegir),
                  ),
                ),
                if (perdida) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t.sosTieneMicrochip),
                    value: _tieneMicrochip,
                    onChanged: (v) => setState(() => _tieneMicrochip = v),
                  ),
                  TextFormField(
                    controller: _recompensa,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: t.sosRecompensa,
                      helperText: t.sosRecompensaAyuda,
                    ),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.sosMostrarWhatsapp),
                  subtitle: Text(t.sosMostrarWhatsappRiesgo),
                  value: _mostrarWhatsapp,
                  onChanged: (v) => setState(() => _mostrarWhatsapp = v),
                ),
                if (_mostrarWhatsapp)
                  TextFormField(
                    controller: _whatsapp,
                    keyboardType: TextInputType.phone,
                    maxLength: 20,
                    decoration: InputDecoration(labelText: t.sosTuWhatsapp),
                    validator: (v) =>
                        _mostrarWhatsapp &&
                            telefonoInternacionalUy(v ?? '') == null
                        ? t.sosWhatsappInvalido
                        : null,
                  ),
                const SizedBox(height: 8),
                Text(t.sosPrivacidad, style: tema.textTheme.bodySmall),
                if (_error case final error?) ...[
                  const SizedBox(height: 8),
                  Text(error, style: TextStyle(color: tema.colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _procesando ? null : _publicar,
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(_procesando ? t.guardando : t.sosPublicar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
