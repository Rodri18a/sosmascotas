import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre de la app (pestaña del navegador, lista de apps).
  ///
  /// In es, this message translates to:
  /// **'SOS Mascota'**
  String get appNombre;

  /// Barra inferior y título de la pantalla.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get pestanaMapa;

  /// No description provided for @pestanaSos.
  ///
  /// In es, this message translates to:
  /// **'SOS'**
  String get pestanaSos;

  /// No description provided for @pestanaMascotas.
  ///
  /// In es, this message translates to:
  /// **'Mis mascotas'**
  String get pestanaMascotas;

  /// No description provided for @pestanaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get pestanaAyuda;

  /// No description provided for @mapaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Veterinarias de urgencia y mascotas perdidas cerca tuyo'**
  String get mapaDescripcion;

  /// No description provided for @sosDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Reportá una mascota perdida o encontrada'**
  String get sosDescripcion;

  /// No description provided for @mascotasDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Tus mascotas, su ficha y su chapita QR'**
  String get mascotasDescripcion;

  /// No description provided for @ayudaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Urgencias, refugios y grupos de difusión de tu zona'**
  String get ayudaDescripcion;

  /// Debajo de una pantalla provisoria. {paso} es el número de paso de PROGRESO.md.
  ///
  /// In es, this message translates to:
  /// **'Llega en el paso {paso}'**
  String enConstruccionPaso(String paso);

  /// No description provided for @ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustes;

  /// No description provided for @ajustesPerfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil, avisos y cuenta'**
  String get ajustesPerfil;

  /// No description provided for @ajustesDesarrollo.
  ///
  /// In es, this message translates to:
  /// **'Desarrollo'**
  String get ajustesDesarrollo;

  /// Indicador solo visible en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Conectado a Supabase dev ✅'**
  String get conexionConectado;

  /// No description provided for @conexionSinConfigurar.
  ///
  /// In es, this message translates to:
  /// **'Falta configurar Supabase (config/dev.json) ⚠️'**
  String get conexionSinConfigurar;

  /// No description provided for @conexionSinConexion.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a Supabase ❌'**
  String get conexionSinConexion;

  /// No description provided for @conexionConectando.
  ///
  /// In es, this message translates to:
  /// **'Conectando con Supabase…'**
  String get conexionConectando;

  /// No description provided for @ingresarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get ingresarTitulo;

  /// No description provided for @ingresarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Ingresá o creá tu cuenta con tu correo. Te mandamos un código: no hace falta contraseña.'**
  String get ingresarExplicacion;

  /// No description provided for @ingresarCorreo.
  ///
  /// In es, this message translates to:
  /// **'Tu correo'**
  String get ingresarCorreo;

  /// No description provided for @ingresarEnviarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Enviarme el código'**
  String get ingresarEnviarCodigo;

  /// No description provided for @ingresarRevisaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Te mandamos un correo a {email}. Tocá el enlace del correo o escribí acá el código de 6 números.'**
  String ingresarRevisaCorreo(String email);

  /// No description provided for @ingresarCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get ingresarCodigo;

  /// No description provided for @ingresarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get ingresarConfirmar;

  /// No description provided for @ingresarOtroCorreo.
  ///
  /// In es, this message translates to:
  /// **'Usar otro correo'**
  String get ingresarOtroCorreo;

  /// No description provided for @ingresarEmailInvalido.
  ///
  /// In es, this message translates to:
  /// **'Revisá el correo: parece que le falta algo.'**
  String get ingresarEmailInvalido;

  /// No description provided for @ingresarCodigoInvalido.
  ///
  /// In es, this message translates to:
  /// **'El código tiene 6 números.'**
  String get ingresarCodigoInvalido;

  /// No description provided for @ingresarAvisoTerminos.
  ///
  /// In es, this message translates to:
  /// **'Al crear tu cuenta te vamos a pedir que aceptes los términos y la política de privacidad.'**
  String get ingresarAvisoTerminos;

  /// No description provided for @ingresarOCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ingresar o crear cuenta'**
  String get ingresarOCrearCuenta;

  /// No description provided for @ingresarSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Para reportar, guardar tus mascotas y recibir avisos'**
  String get ingresarSubtitulo;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @errorDemasiadosIntentos.
  ///
  /// In es, this message translates to:
  /// **'Hiciste muchos intentos seguidos. Esperá unos minutos y probá de nuevo.'**
  String get errorDemasiadosIntentos;

  /// No description provided for @errorCodigoInvalido.
  ///
  /// In es, this message translates to:
  /// **'El código no es correcto o ya venció. Pedí uno nuevo.'**
  String get errorCodigoInvalido;

  /// No description provided for @errorSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectarnos. Revisá tu internet y probá de nuevo.'**
  String get errorSinConexion;

  /// No description provided for @errorNoConfigurado.
  ///
  /// In es, this message translates to:
  /// **'El ingreso no está disponible en este momento.'**
  String get errorNoConfigurado;

  /// No description provided for @errorDesconocido.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Probá de nuevo en un rato.'**
  String get errorDesconocido;

  /// No description provided for @ingresarConGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get ingresarConGoogle;

  /// No description provided for @ingresarOConCorreo.
  ///
  /// In es, this message translates to:
  /// **'o con tu correo'**
  String get ingresarOConCorreo;

  /// No description provided for @cuentaNecesariaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Necesitás una cuenta'**
  String get cuentaNecesariaTitulo;

  /// No description provided for @ahoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get ahoraNo;

  /// No description provided for @sosReportar.
  ///
  /// In es, this message translates to:
  /// **'Reportar mascota perdida o encontrada'**
  String get sosReportar;

  /// No description provided for @sosMotivoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Para reportar necesitamos poder avisarte cuando alguien vea a la mascota. Tu teléfono nunca se muestra.'**
  String get sosMotivoCuenta;

  /// No description provided for @sosNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo reporte'**
  String get sosNuevoTitulo;

  /// No description provided for @sosNuevoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Foto, ubicación en el mapa y datos de la mascota'**
  String get sosNuevoDescripcion;

  /// No description provided for @mascotasAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar mascota'**
  String get mascotasAgregar;

  /// No description provided for @mascotasMotivoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Para guardar tus mascotas, su ficha y su chapita QR, y recibir avisos si alguien la encuentra.'**
  String get mascotasMotivoCuenta;

  /// No description provided for @mascotaNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nueva mascota'**
  String get mascotaNuevaTitulo;

  /// No description provided for @mascotaNuevaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Nombre, especie, raza y foto de tu mascota'**
  String get mascotaNuevaDescripcion;

  /// No description provided for @legalTerminos.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get legalTerminos;

  /// No description provided for @legalPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get legalPrivacidad;

  /// No description provided for @consentimientoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Antes de empezar'**
  String get consentimientoTitulo;

  /// No description provided for @consentimientoExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Para usar tu cuenta necesitamos que leas y aceptes cómo funciona SOS Mascota y cómo cuidamos tus datos. En resumen:'**
  String get consentimientoExplicacion;

  /// No description provided for @consentimientoTelefono.
  ///
  /// In es, this message translates to:
  /// **'Tu teléfono nunca se muestra a otras personas.'**
  String get consentimientoTelefono;

  /// No description provided for @consentimientoUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Solo guardamos una zona aproximada, nunca tu ubicación exacta.'**
  String get consentimientoUbicacion;

  /// No description provided for @consentimientoMetricas.
  ///
  /// In es, this message translates to:
  /// **'Medimos el uso de la app de forma anónima. No vendemos tus datos.'**
  String get consentimientoMetricas;

  /// No description provided for @consentimientoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Podés borrar tu cuenta cuando quieras.'**
  String get consentimientoBorrar;

  /// No description provided for @consentimientoCasilla.
  ///
  /// In es, this message translates to:
  /// **'Leí y acepto los términos y la política de privacidad'**
  String get consentimientoCasilla;

  /// No description provided for @consentimientoAceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get consentimientoAceptar;

  /// No description provided for @consentimientoNoAcepto.
  ///
  /// In es, this message translates to:
  /// **'No acepto (cerrar sesión)'**
  String get consentimientoNoAcepto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
