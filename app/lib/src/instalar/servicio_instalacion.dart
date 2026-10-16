import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../metricas/metricas.dart';
import 'instalacion_otro.dart'
    if (dart.library.js_interop) 'instalacion_web.dart'
    as plataforma;

/// Instalar la web como app (PWA, paso 0.8.1). Se reemplaza en las pruebas.
abstract interface class ServicioInstalacion {
  /// Ya se abre desde el ícono (o es la app nativa).
  bool get yaInstalada;

  /// El navegador ofrece su propio aviso de instalación (Chrome, Edge, Android).
  bool get puedeMostrarAviso;

  /// En el iPhone no hay aviso: se instala con Compartir → Agregar a inicio.
  bool get esIphone;

  /// Muestra el aviso del navegador. `true` si la persona aceptó.
  Future<bool> mostrarAviso();

  /// Cambió algo (llegó el aviso o se instaló).
  Stream<void> get cambios;
}

class InstalacionNoDisponible implements ServicioInstalacion {
  const InstalacionNoDisponible();

  @override
  bool get yaInstalada => true;

  @override
  bool get puedeMostrarAviso => false;

  @override
  bool get esIphone => false;

  @override
  Future<bool> mostrarAviso() async => false;

  @override
  Stream<void> get cambios => const Stream.empty();
}

final servicioInstalacionProvider = Provider<ServicioInstalacion>(
  (ref) => plataforma.crearServicioInstalacion(),
);

/// Cómo se le puede ofrecer instalar a esta persona.
enum FormaDeInstalar {
  /// Botón que abre el aviso del navegador.
  aviso,

  /// Instrucciones para el iPhone (ahí las notificaciones solo andan instalada).
  iphone,

  /// Ya está instalada, o este navegador no lo permite: no se ofrece nada.
  ninguna,
}

FormaDeInstalar _forma(ServicioInstalacion s) {
  if (s.yaInstalada) return FormaDeInstalar.ninguna;
  if (s.puedeMostrarAviso) return FormaDeInstalar.aviso;
  if (s.esIphone) return FormaDeInstalar.iphone;
  return FormaDeInstalar.ninguna;
}

final formaDeInstalarProvider =
    NotifierProvider<FormaDeInstalarNotifier, FormaDeInstalar>(
      FormaDeInstalarNotifier.new,
    );

class FormaDeInstalarNotifier extends Notifier<FormaDeInstalar> {
  @override
  FormaDeInstalar build() {
    final servicio = ref.watch(servicioInstalacionProvider);
    final suscripcion = servicio.cambios.listen((_) {
      final antes = state;
      state = _forma(servicio);
      if (antes != FormaDeInstalar.ninguna && servicio.yaInstalada) {
        ref.read(metricasProvider).track(Eventos.pwaInstalled);
      }
    });
    ref.onDispose(suscripcion.cancel);
    return _forma(servicio);
  }

  /// Ofrece instalar desde [origen] (`ajustes` o `mapa`). Con el aviso del
  /// navegador devuelve si aceptó; en el iPhone, la pantalla muestra los pasos.
  Future<bool> ofrecer(String origen) async {
    final metricas = ref.read(metricasProvider);
    if (state == FormaDeInstalar.iphone) {
      metricas.track(
        Eventos.pwaPrompt,
        props: {'origen': origen, 'forma': 'iphone', 'resultado': 'pasos'},
      );
      return false;
    }
    final servicio = ref.read(servicioInstalacionProvider);
    final acepto = await servicio.mostrarAviso();
    metricas.track(
      Eventos.pwaPrompt,
      props: {
        'origen': origen,
        'forma': 'aviso',
        'resultado': acepto ? 'aceptada' : 'rechazada',
      },
    );
    state = _forma(servicio);
    return acepto;
  }
}

/// Recuerda cuántas veces se abrió la app y si se descartó la tarjeta.
abstract interface class AlmacenInstalacion {
  /// Suma una apertura y devuelve el total.
  Future<int> sumarApertura();
  Future<bool> descartada();
  Future<void> descartar();
}

class AlmacenInstalacionLocal implements AlmacenInstalacion {
  const AlmacenInstalacionLocal();

  static const _aperturas = 'instalar.aperturas';
  static const _descartada = 'instalar.descartada';

  @override
  Future<int> sumarApertura() async {
    final prefs = await SharedPreferences.getInstance();
    final total = (prefs.getInt(_aperturas) ?? 0) + 1;
    await prefs.setInt(_aperturas, total);
    return total;
  }

  @override
  Future<bool> descartada() async =>
      (await SharedPreferences.getInstance()).getBool(_descartada) ?? false;

  @override
  Future<void> descartar() async =>
      (await SharedPreferences.getInstance()).setBool(_descartada, true);
}

final almacenInstalacionProvider = Provider<AlmacenInstalacion>(
  (ref) => const AlmacenInstalacionLocal(),
);

/// La tarjeta del mapa aparece desde la 2.ª apertura, hasta que se descarta.
const aperturasParaInvitar = 2;

final tarjetaInstalarProvider = NotifierProvider<TarjetaInstalar, bool>(
  TarjetaInstalar.new,
);

class TarjetaInstalar extends Notifier<bool> {
  @override
  bool build() {
    unawaited(_cargar());
    return false;
  }

  Future<void> _cargar() async {
    final almacen = ref.read(almacenInstalacionProvider);
    try {
      final aperturas = await almacen.sumarApertura();
      final descartada = await almacen.descartada();
      state = aperturas >= aperturasParaInvitar && !descartada;
    } on Exception {
      state = false;
    }
  }

  Future<void> descartar() async {
    state = false;
    await ref.read(almacenInstalacionProvider).descartar();
  }
}
