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
  /// **'Descripción'**
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
  /// **'Reportar'**
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

  /// No description provided for @ajustesNombreTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get ajustesNombreTitulo;

  /// No description provided for @ajustesNombreAyuda.
  ///
  /// In es, this message translates to:
  /// **'Así te ven los demás cuando hablás con ellos'**
  String get ajustesNombreAyuda;

  /// No description provided for @ajustesRadioAvisos.
  ///
  /// In es, this message translates to:
  /// **'Avisarme de mascotas perdidas hasta a {km} km'**
  String ajustesRadioAvisos(int km);

  /// No description provided for @ajustesKm.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String ajustesKm(int km);

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @borrarCuenta.
  ///
  /// In es, this message translates to:
  /// **'Borrar mi cuenta'**
  String get borrarCuenta;

  /// No description provided for @borrarCuentaTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar tu cuenta?'**
  String get borrarCuentaTitulo;

  /// No description provided for @borrarCuentaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Se borran para siempre tu perfil, tus datos de contacto y tus mascotas. No se puede deshacer.'**
  String get borrarCuentaExplicacion;

  /// No description provided for @borrarCuentaConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Sí, borrar todo'**
  String get borrarCuentaConfirmar;

  /// No description provided for @borrarCuentaHecho.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta y tus datos se borraron.'**
  String get borrarCuentaHecho;

  /// No description provided for @mascotaEditarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Editar mascota'**
  String get mascotaEditarTitulo;

  /// No description provided for @mascotaFoto.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get mascotaFoto;

  /// No description provided for @mascotaAgregarFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get mascotaAgregarFoto;

  /// No description provided for @mascotaCambiarFoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get mascotaCambiarFoto;

  /// No description provided for @mascotaSacarFoto.
  ///
  /// In es, this message translates to:
  /// **'Sacar una foto'**
  String get mascotaSacarFoto;

  /// No description provided for @mascotaElegirFoto.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get mascotaElegirFoto;

  /// No description provided for @mascotaFotoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Una foto clara de cuerpo entero ayuda mucho si se pierde. Le quitamos la ubicación antes de subirla.'**
  String get mascotaFotoAyuda;

  /// No description provided for @mascotaFotoInvalida.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer esa imagen. Probá con otra.'**
  String get mascotaFotoInvalida;

  /// No description provided for @mascotaNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get mascotaNombre;

  /// No description provided for @mascotaNombreFalta.
  ///
  /// In es, this message translates to:
  /// **'Escribí el nombre de tu mascota.'**
  String get mascotaNombreFalta;

  /// No description provided for @mascotaEspecie.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get mascotaEspecie;

  /// No description provided for @mascotaEspecieFalta.
  ///
  /// In es, this message translates to:
  /// **'Elegí la especie.'**
  String get mascotaEspecieFalta;

  /// No description provided for @mascotaRaza.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get mascotaRaza;

  /// No description provided for @mascotaRazaOtra.
  ///
  /// In es, this message translates to:
  /// **'Otra / no está en la lista'**
  String get mascotaRazaOtra;

  /// No description provided for @mascotaRazaOtraCampo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué raza es?'**
  String get mascotaRazaOtraCampo;

  /// No description provided for @mascotaSexo.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get mascotaSexo;

  /// No description provided for @sexoMacho.
  ///
  /// In es, this message translates to:
  /// **'Macho'**
  String get sexoMacho;

  /// No description provided for @sexoHembra.
  ///
  /// In es, this message translates to:
  /// **'Hembra'**
  String get sexoHembra;

  /// No description provided for @noSe.
  ///
  /// In es, this message translates to:
  /// **'No sé'**
  String get noSe;

  /// No description provided for @si.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get si;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @mascotaColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get mascotaColor;

  /// No description provided for @mascotaSenas.
  ///
  /// In es, this message translates to:
  /// **'Señas particulares'**
  String get mascotaSenas;

  /// No description provided for @mascotaSenasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Manchas, cicatrices, collar… lo que la distinga.'**
  String get mascotaSenasAyuda;

  /// No description provided for @mascotaNacimiento.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get mascotaNacimiento;

  /// No description provided for @mascotaNacimientoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si no la sabés exacta, una aproximada sirve.'**
  String get mascotaNacimientoAyuda;

  /// No description provided for @mascotaNacimientoElegir.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get mascotaNacimientoElegir;

  /// No description provided for @mascotaMicrochip.
  ///
  /// In es, this message translates to:
  /// **'Microchip'**
  String get mascotaMicrochip;

  /// No description provided for @mascotaMicrochipAyuda.
  ///
  /// In es, this message translates to:
  /// **'15 números. Está en el carné de la veterinaria.'**
  String get mascotaMicrochipAyuda;

  /// No description provided for @mascotaMicrochipInvalido.
  ///
  /// In es, this message translates to:
  /// **'El microchip tiene 15 números.'**
  String get mascotaMicrochipInvalido;

  /// No description provided for @mascotaCastrada.
  ///
  /// In es, this message translates to:
  /// **'¿Está castrada/o?'**
  String get mascotaCastrada;

  /// No description provided for @mascotaNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get mascotaNotas;

  /// No description provided for @mascotaNotasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Carácter, miedos, medicación… (solo lo ves vos).'**
  String get mascotaNotasAyuda;

  /// No description provided for @mascotaBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar mascota'**
  String get mascotaBorrar;

  /// No description provided for @mascotaBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar a {nombre}?'**
  String mascotaBorrarTitulo(String nombre);

  /// No description provided for @mascotaBorrarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Se borran su ficha y su foto. No se puede deshacer.'**
  String get mascotaBorrarExplicacion;

  /// No description provided for @borrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get borrar;

  /// No description provided for @guardando.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get guardando;

  /// No description provided for @mascotasVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaste ninguna mascota. Con su ficha y su foto vas a poder generar su chapita QR y reportarla rápido si se pierde.'**
  String get mascotasVacio;

  /// No description provided for @edadMenosDeUnMes.
  ///
  /// In es, this message translates to:
  /// **'Menos de un mes'**
  String get edadMenosDeUnMes;

  /// No description provided for @edadMeses.
  ///
  /// In es, this message translates to:
  /// **'{meses, plural, =1{1 mes} other{{meses} meses}}'**
  String edadMeses(int meses);

  /// No description provided for @edadAnios.
  ///
  /// In es, this message translates to:
  /// **'{anios, plural, =1{1 año} other{{anios} años}}'**
  String edadAnios(int anios);

  /// No description provided for @edadAniosYMeses.
  ///
  /// In es, this message translates to:
  /// **'{anios, plural, =1{1 año} other{{anios} años}} y {meses, plural, =1{1 mes} other{{meses} meses}}'**
  String edadAniosYMeses(int anios, int meses);

  /// No description provided for @fichaEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get fichaEditar;

  /// No description provided for @fichaEdad.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get fichaEdad;

  /// No description provided for @fichaCastrada.
  ///
  /// In es, this message translates to:
  /// **'Castrada/o'**
  String get fichaCastrada;

  /// No description provided for @fichaMicrochipConsejo.
  ///
  /// In es, this message translates to:
  /// **'Si se pierde, a quien la encuentre le vamos a sugerir llevarla a una veterinaria para leer el chip.'**
  String get fichaMicrochipConsejo;

  /// No description provided for @fichaSinMicrochip.
  ///
  /// In es, this message translates to:
  /// **'Sin microchip cargado'**
  String get fichaSinMicrochip;

  /// No description provided for @fichaQrTitulo.
  ///
  /// In es, this message translates to:
  /// **'Chapita QR'**
  String get fichaQrTitulo;

  /// No description provided for @fichaQrDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Su código para que quien la encuentre pueda avisarte sin ver tu teléfono.'**
  String get fichaQrDescripcion;

  /// No description provided for @qrExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Este es el QR de {nombre}. Quien lo escanee ve su foto y su nombre, y puede avisarte sin ver tu teléfono.'**
  String qrExplicacion(String nombre);

  /// No description provided for @qrDe.
  ///
  /// In es, this message translates to:
  /// **'QR de {nombre}'**
  String qrDe(String nombre);

  /// No description provided for @qrCartelIndicacion.
  ///
  /// In es, this message translates to:
  /// **'¿Me encontraste? Escaneame 🐾'**
  String get qrCartelIndicacion;

  /// No description provided for @qrDescargar.
  ///
  /// In es, this message translates to:
  /// **'Descargar para imprimir'**
  String get qrDescargar;

  /// No description provided for @qrDescargaNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'La descarga llega con la app para celulares. Mientras tanto, usá la versión web.'**
  String get qrDescargaNoDisponible;

  /// No description provided for @qrCopiarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Copiar enlace'**
  String get qrCopiarEnlace;

  /// No description provided for @qrEnlaceCopiado.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado'**
  String get qrEnlaceCopiado;

  /// No description provided for @qrVerPagina.
  ///
  /// In es, this message translates to:
  /// **'Ver la página que ve quien lo escanea'**
  String get qrVerPagina;

  /// No description provided for @qrNotaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nota para quien la encuentre'**
  String get qrNotaTitulo;

  /// No description provided for @qrNotaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: \"Toma medicación\" o \"Es alérgica al pollo\". No pongas tu dirección ni tu teléfono.'**
  String get qrNotaAyuda;

  /// No description provided for @qrNotaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Nota guardada'**
  String get qrNotaGuardada;

  /// No description provided for @qrConsejoChapita.
  ///
  /// In es, this message translates to:
  /// **'Imprimilo en papel adhesivo y protegelo con cinta transparente, o pedí una chapita resistente cuando esté disponible. Si el código circuló donde no querías, podés cambiarlo.'**
  String get qrConsejoChapita;

  /// No description provided for @qrRegenerar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar el código'**
  String get qrRegenerar;

  /// No description provided for @qrRegenerarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Cambiar el código?'**
  String get qrRegenerarTitulo;

  /// No description provided for @qrRegenerarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'El código actual deja de funcionar: vas a tener que imprimir el nuevo y reemplazar la chapita.'**
  String get qrRegenerarExplicacion;

  /// No description provided for @qrRegenerado.
  ///
  /// In es, this message translates to:
  /// **'Listo: el código nuevo ya está activo.'**
  String get qrRegenerado;

  /// No description provided for @avisosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get avisosTitulo;

  /// No description provided for @avisosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés avisos. Si alguien escanea el QR de tu mascota y te deja un mensaje, lo vas a ver acá.'**
  String get avisosVacio;

  /// No description provided for @avisosAntiEstafa.
  ///
  /// In es, this message translates to:
  /// **'Nunca pagues por adelantado ni mandes plata para recuperar a tu mascota. Si te la piden, marcá el aviso como estafa.'**
  String get avisosAntiEstafa;

  /// No description provided for @avisosDe.
  ///
  /// In es, this message translates to:
  /// **'Aviso de {nombre}'**
  String avisosDe(String nombre);

  /// No description provided for @avisosSobre.
  ///
  /// In es, this message translates to:
  /// **'{mascota}: aviso de {nombre}'**
  String avisosSobre(String mascota, String nombre);

  /// No description provided for @avisosNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get avisosNuevo;

  /// No description provided for @avisosMasOpciones.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get avisosMasOpciones;

  /// No description provided for @avisosYaContacte.
  ///
  /// In es, this message translates to:
  /// **'Ya lo contacté'**
  String get avisosYaContacte;

  /// No description provided for @avisosEstafa.
  ///
  /// In es, this message translates to:
  /// **'Es una estafa'**
  String get avisosEstafa;

  /// No description provided for @avisosEstafaTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Marcar como estafa?'**
  String get avisosEstafaTitulo;

  /// No description provided for @avisosEstafaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Esa persona no va a poder mandarte más avisos. No le avisamos que la bloqueaste.'**
  String get avisosEstafaExplicacion;

  /// No description provided for @avisosMarcadoEstafa.
  ///
  /// In es, this message translates to:
  /// **'Marcado como estafa: esa persona ya no puede mandarte avisos.'**
  String get avisosMarcadoEstafa;

  /// No description provided for @avisosContacto.
  ///
  /// In es, this message translates to:
  /// **'Contacto: {contacto}'**
  String avisosContacto(String contacto);

  /// No description provided for @avisosRespondido.
  ///
  /// In es, this message translates to:
  /// **'Ya lo contactaste'**
  String get avisosRespondido;

  /// No description provided for @avisosLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get avisosLlamar;

  /// No description provided for @avisosWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get avisosWhatsapp;

  /// No description provided for @avisosVerUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Ver ubicación'**
  String get avisosVerUbicacion;

  /// No description provided for @qrEscaneosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Últimos escaneos'**
  String get qrEscaneosTitulo;

  /// No description provided for @qrSinEscaneos.
  ///
  /// In es, this message translates to:
  /// **'Todavía nadie escaneó este QR.'**
  String get qrSinEscaneos;

  /// No description provided for @qrEscaneoConUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Compartió su ubicación: tocá para verla'**
  String get qrEscaneoConUbicacion;

  /// No description provided for @qrEscaneoSinUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Abrieron la página'**
  String get qrEscaneoSinUbicacion;

  /// No description provided for @sosPerdi.
  ///
  /// In es, this message translates to:
  /// **'Perdí una mascota'**
  String get sosPerdi;

  /// No description provided for @sosEncontre.
  ///
  /// In es, this message translates to:
  /// **'Encontré una mascota'**
  String get sosEncontre;

  /// No description provided for @sosCualMascota.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál?'**
  String get sosCualMascota;

  /// No description provided for @sosOtraMascota.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get sosOtraMascota;

  /// No description provided for @sosFotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos (al menos una)'**
  String get sosFotos;

  /// No description provided for @sosFotoDeLaFicha.
  ///
  /// In es, this message translates to:
  /// **'Foto de su ficha'**
  String get sosFotoDeLaFicha;

  /// No description provided for @sosFotoN.
  ///
  /// In es, this message translates to:
  /// **'Foto {n}'**
  String sosFotoN(int n);

  /// No description provided for @sosDondePerdida.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la viste por última vez?'**
  String get sosDondePerdida;

  /// No description provided for @sosDondeEncontrada.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la encontraste o la viste?'**
  String get sosDondeEncontrada;

  /// No description provided for @sosUbicacionAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa en el lugar. Al publicar se muestra una zona aproximada, nunca el punto exacto.'**
  String get sosUbicacionAyuda;

  /// No description provided for @sosUbicacionMarcada.
  ///
  /// In es, this message translates to:
  /// **'Lugar marcado ✔'**
  String get sosUbicacionMarcada;

  /// No description provided for @sosNombreSiLoSabes.
  ///
  /// In es, this message translates to:
  /// **'Nombre (si lo sabés, por la chapita o el collar)'**
  String get sosNombreSiLoSabes;

  /// No description provided for @sosDescripcionAyudaPerdida.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se perdió? ¿Tiene collar? ¿Es miedosa?'**
  String get sosDescripcionAyudaPerdida;

  /// No description provided for @sosDescripcionAyudaEncontrada.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo está? ¿La tenés con vos o sigue suelta?'**
  String get sosDescripcionAyudaEncontrada;

  /// No description provided for @sosCuandoPerdida.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo se perdió?'**
  String get sosCuandoPerdida;

  /// No description provided for @sosCuandoEncontrada.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo la encontraste?'**
  String get sosCuandoEncontrada;

  /// No description provided for @sosTieneMicrochip.
  ///
  /// In es, this message translates to:
  /// **'Tiene microchip'**
  String get sosTieneMicrochip;

  /// No description provided for @sosRecompensa.
  ///
  /// In es, this message translates to:
  /// **'Recompensa (opcional)'**
  String get sosRecompensa;

  /// No description provided for @sosRecompensaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si ofrecés una, ponela acá. Nunca pagues antes de tener a tu mascota.'**
  String get sosRecompensaAyuda;

  /// No description provided for @sosPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Tu teléfono no se publica: quien la vea te va a dejar un aviso con su contacto y vos decidís si respondés.'**
  String get sosPrivacidad;

  /// No description provided for @sosPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get sosPublicar;

  /// No description provided for @sosFaltaFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregá al menos una foto.'**
  String get sosFaltaFoto;

  /// No description provided for @sosFaltaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Marcá en el mapa dónde fue.'**
  String get sosFaltaUbicacion;

  /// No description provided for @sosLimiteDiario.
  ///
  /// In es, this message translates to:
  /// **'Ya publicaste 3 reportes hoy. Si es urgente, escribinos a soporte.'**
  String get sosLimiteDiario;

  /// No description provided for @sosDetalleTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reporte'**
  String get sosDetalleTitulo;

  /// No description provided for @sosPublicado.
  ///
  /// In es, this message translates to:
  /// **'¡Publicado! Los vecinos de la zona ya pueden verlo.'**
  String get sosPublicado;

  /// No description provided for @fichaReportarPerdida.
  ///
  /// In es, this message translates to:
  /// **'Se perdió: reportarla'**
  String get fichaReportarPerdida;

  /// No description provided for @sosFiltroTodos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get sosFiltroTodos;

  /// No description provided for @sosFiltroPerdidas.
  ///
  /// In es, this message translates to:
  /// **'Perdidas'**
  String get sosFiltroPerdidas;

  /// No description provided for @sosFiltroEncontradas.
  ///
  /// In es, this message translates to:
  /// **'Encontradas'**
  String get sosFiltroEncontradas;

  /// No description provided for @sosNingunoCerca.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes activos cerca. ¡Ojalá siga así! 🐾'**
  String get sosNingunoCerca;

  /// No description provided for @sosTituloPerdida.
  ///
  /// In es, this message translates to:
  /// **'Se perdió: {nombre}'**
  String sosTituloPerdida(String nombre);

  /// No description provided for @sosTituloEncontrada.
  ///
  /// In es, this message translates to:
  /// **'Encontrada: {especie}'**
  String sosTituloEncontrada(String especie);

  /// No description provided for @sosDistanciaYTiempo.
  ///
  /// In es, this message translates to:
  /// **'A {distancia} · {cuando}'**
  String sosDistanciaYTiempo(String distancia, String cuando);

  /// No description provided for @haceUnMomento.
  ///
  /// In es, this message translates to:
  /// **'hace un momento'**
  String get haceUnMomento;

  /// No description provided for @haceMinutos.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{hace 1 minuto} other{hace {n} minutos}}'**
  String haceMinutos(int n);

  /// No description provided for @haceHoras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{hace 1 hora} other{hace {n} horas}}'**
  String haceHoras(int n);

  /// No description provided for @haceDias.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{hace 1 día} other{hace {n} días}}'**
  String haceDias(int n);

  /// No description provided for @elDia.
  ///
  /// In es, this message translates to:
  /// **'el {dia}/{mes}'**
  String elDia(int dia, int mes);

  /// No description provided for @sosMostrarWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Mostrar mi WhatsApp en este reporte'**
  String get sosMostrarWhatsapp;

  /// No description provided for @sosMostrarWhatsappRiesgo.
  ///
  /// In es, this message translates to:
  /// **'No recomendado: cualquiera vería tu número y es la vía más usada para estafas. Sin esto, igual te llegan los avisos.'**
  String get sosMostrarWhatsappRiesgo;

  /// No description provided for @sosTuWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Tu WhatsApp'**
  String get sosTuWhatsapp;

  /// No description provided for @sosWhatsappInvalido.
  ///
  /// In es, this message translates to:
  /// **'Revisá el número (ej.: 099 123 456).'**
  String get sosWhatsappInvalido;

  /// No description provided for @sosNoEncontrado.
  ///
  /// In es, this message translates to:
  /// **'Este reporte no existe o ya no está disponible.'**
  String get sosNoEncontrado;

  /// No description provided for @sosEnlaceCopiado.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado: pegalo en WhatsApp o Facebook para compartirlo.'**
  String get sosEnlaceCopiado;

  /// No description provided for @sosAvisarMotivoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Para avisar desde la app necesitamos una cuenta (así evitamos avisos falsos). También podés avisar desde la página web del reporte, sin cuenta.'**
  String get sosAvisarMotivoCuenta;

  /// No description provided for @sosAvisoEnviado.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias! Tu aviso le llegó.'**
  String get sosAvisoEnviado;

  /// No description provided for @sosWhatsappAdvertenciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Antes de escribir por WhatsApp'**
  String get sosWhatsappAdvertenciaTitulo;

  /// No description provided for @sosWhatsappAdvertencia.
  ///
  /// In es, this message translates to:
  /// **'Nunca pidas ni mandes plata. Si alguien te pide un pago para devolver una mascota, es una estafa.'**
  String get sosWhatsappAdvertencia;

  /// No description provided for @sosWhatsappAbrir.
  ///
  /// In es, this message translates to:
  /// **'Abrir WhatsApp'**
  String get sosWhatsappAbrir;

  /// No description provided for @sosEstadoResuelto.
  ///
  /// In es, this message translates to:
  /// **'¡Apareció! Este reporte ya está resuelto.'**
  String get sosEstadoResuelto;

  /// No description provided for @sosEstadoArchivado.
  ///
  /// In es, this message translates to:
  /// **'Este reporte está archivado.'**
  String get sosEstadoArchivado;

  /// No description provided for @sosEstadoOculto.
  ///
  /// In es, this message translates to:
  /// **'Este reporte está oculto mientras lo revisamos.'**
  String get sosEstadoOculto;

  /// No description provided for @sosRecompensaValor.
  ///
  /// In es, this message translates to:
  /// **'Recompensa: {valor}'**
  String sosRecompensaValor(String valor);

  /// No description provided for @sosConsejoVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Si la tenés con vos, llevala a una veterinaria: pueden leer si tiene microchip y avisar a su familia.'**
  String get sosConsejoVeterinaria;

  /// No description provided for @sosConsejoVista.
  ///
  /// In es, this message translates to:
  /// **'Si la ves, no la persigas: avisá al dueño con el lugar y la hora. Una foto ayuda mucho.'**
  String get sosConsejoVista;

  /// No description provided for @sosConsejoDuenoRenac.
  ///
  /// In es, this message translates to:
  /// **'Si tiene microchip, marcala como extraviada en el RENAC (consultá en tu veterinaria). Compartí este reporte en los grupos de la zona.'**
  String get sosConsejoDuenoRenac;

  /// No description provided for @sosConsejoEncontradaPropia.
  ///
  /// In es, this message translates to:
  /// **'Si la llevás a una veterinaria, pueden leer si tiene microchip y encontrar a su familia más rápido.'**
  String get sosConsejoEncontradaPropia;

  /// No description provided for @sosZonaAproximada.
  ///
  /// In es, this message translates to:
  /// **'Zona aproximada'**
  String get sosZonaAproximada;

  /// No description provided for @sosAvisarDueno.
  ///
  /// In es, this message translates to:
  /// **'Avisar al dueño'**
  String get sosAvisarDueno;

  /// No description provided for @sosAvisarQuienEncontro.
  ///
  /// In es, this message translates to:
  /// **'Es mía / sé de quién es'**
  String get sosAvisarQuienEncontro;

  /// No description provided for @sosCompartir.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get sosCompartir;

  /// No description provided for @sosPrivacidadDetalle.
  ///
  /// In es, this message translates to:
  /// **'El teléfono del autor no se muestra: tu aviso le llega y decide cómo contactarte. La ubicación del mapa es aproximada.'**
  String get sosPrivacidadDetalle;

  /// No description provided for @sosAvisarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Dejale un aviso'**
  String get sosAvisarTitulo;

  /// No description provided for @sosAvisoMensaje.
  ///
  /// In es, this message translates to:
  /// **'Mensaje (dónde y cuándo la viste)'**
  String get sosAvisoMensaje;

  /// No description provided for @sosAvisoNombre.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get sosAvisoNombre;

  /// No description provided for @sosAvisoContacto.
  ///
  /// In es, this message translates to:
  /// **'Tu teléfono o WhatsApp'**
  String get sosAvisoContacto;

  /// No description provided for @sosAvisoConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Acepto que reciba mi nombre y mi teléfono para contactarme.'**
  String get sosAvisoConsentimiento;

  /// No description provided for @sosAvisoFaltaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Para enviar el aviso tenés que aceptar compartir tu contacto.'**
  String get sosAvisoFaltaConsentimiento;

  /// No description provided for @sosAvisoEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar aviso'**
  String get sosAvisoEnviar;

  /// No description provided for @sosCampoObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Completá este dato.'**
  String get sosCampoObligatorio;

  /// No description provided for @sosAparecio.
  ///
  /// In es, this message translates to:
  /// **'¡Apareció!'**
  String get sosAparecio;

  /// No description provided for @sosAparecioTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Apareció?'**
  String get sosAparecioTitulo;

  /// No description provided for @sosAparecioExplicacion.
  ///
  /// In es, this message translates to:
  /// **'El reporte deja de mostrarse en el mapa y la página de su QR deja de decir \"Estoy perdido\".'**
  String get sosAparecioExplicacion;

  /// No description provided for @sosAparecioGracias.
  ///
  /// In es, this message translates to:
  /// **'¡Qué alegría! 💚 Gracias por avisar.'**
  String get sosAparecioGracias;

  /// No description provided for @sosArchivar.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get sosArchivar;

  /// No description provided for @sosArchivarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Archivar el reporte?'**
  String get sosArchivarTitulo;

  /// No description provided for @sosArchivarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Deja de mostrarse en el mapa y en la lista. Usalo si ya no hace falta, aunque no haya aparecido.'**
  String get sosArchivarExplicacion;

  /// No description provided for @sosMisReportes.
  ///
  /// In es, this message translates to:
  /// **'Mis reportes'**
  String get sosMisReportes;

  /// No description provided for @sosEstadoActivoCorto.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get sosEstadoActivoCorto;

  /// No description provided for @sosEstadoResueltoCorto.
  ///
  /// In es, this message translates to:
  /// **'Apareció'**
  String get sosEstadoResueltoCorto;

  /// No description provided for @sosEstadoArchivadoCorto.
  ///
  /// In es, this message translates to:
  /// **'Archivado'**
  String get sosEstadoArchivadoCorto;

  /// No description provided for @sosEstadoOcultoCorto.
  ///
  /// In es, this message translates to:
  /// **'En revisión'**
  String get sosEstadoOcultoCorto;

  /// No description provided for @sosReportarContenido.
  ///
  /// In es, this message translates to:
  /// **'Reportar publicación'**
  String get sosReportarContenido;

  /// No description provided for @sosReportarContenidoMotivoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Para reportar una publicación necesitás una cuenta: así evitamos reportes falsos.'**
  String get sosReportarContenidoMotivoCuenta;

  /// No description provided for @sosReportarContenidoExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Si varias personas la reportan, se oculta hasta que la revisemos. Quien la publicó no sabe quién la reportó.'**
  String get sosReportarContenidoExplicacion;

  /// No description provided for @sosReportarContenidoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Contanos más (opcional)'**
  String get sosReportarContenidoDetalle;

  /// No description provided for @sosReportarContenidoEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get sosReportarContenidoEnviar;

  /// No description provided for @sosReportarContenidoFaltaMotivo.
  ///
  /// In es, this message translates to:
  /// **'Elegí un motivo.'**
  String get sosReportarContenidoFaltaMotivo;

  /// No description provided for @sosReportarContenidoGracias.
  ///
  /// In es, this message translates to:
  /// **'Gracias, lo vamos a revisar.'**
  String get sosReportarContenidoGracias;

  /// No description provided for @sosReportarContenidoYaReportado.
  ///
  /// In es, this message translates to:
  /// **'Ya habías reportado esta publicación. La estamos revisando.'**
  String get sosReportarContenidoYaReportado;

  /// No description provided for @sosMotivoFalso.
  ///
  /// In es, this message translates to:
  /// **'Es falso'**
  String get sosMotivoFalso;

  /// No description provided for @sosMotivoEstafa.
  ///
  /// In es, this message translates to:
  /// **'Parece una estafa'**
  String get sosMotivoEstafa;

  /// No description provided for @sosMotivoSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o publicidad'**
  String get sosMotivoSpam;

  /// No description provided for @sosMotivoOfensivo.
  ///
  /// In es, this message translates to:
  /// **'Ofensivo'**
  String get sosMotivoOfensivo;

  /// No description provided for @sosMotivoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get sosMotivoOtro;

  /// No description provided for @pushInterruptor.
  ///
  /// In es, this message translates to:
  /// **'Avisos en este dispositivo'**
  String get pushInterruptor;

  /// No description provided for @pushDetalle.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos si alguien encuentra a tu mascota o escanea su QR.'**
  String get pushDetalle;

  /// No description provided for @pushNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Este navegador no admite avisos. En iPhone, primero agregá SOS Mascota a la pantalla de inicio (Compartir → Agregar a inicio) y abrila desde ahí.'**
  String get pushNoDisponible;

  /// No description provided for @pushBloqueado.
  ///
  /// In es, this message translates to:
  /// **'Los avisos están bloqueados en este navegador. Habilitalos desde el candado de la barra de direcciones → Notificaciones.'**
  String get pushBloqueado;

  /// No description provided for @pushSinElegir.
  ///
  /// In es, this message translates to:
  /// **'No se activaron los avisos. Podés hacerlo cuando quieras desde Ajustes.'**
  String get pushSinElegir;

  /// No description provided for @pushTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Activá los avisos para enterarte al instante si alguien encuentra a tu mascota.'**
  String get pushTarjeta;

  /// No description provided for @pushActivar.
  ///
  /// In es, this message translates to:
  /// **'Activar avisos'**
  String get pushActivar;

  /// No description provided for @pushActivados.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Vas a recibir los avisos en este dispositivo.'**
  String get pushActivados;

  /// No description provided for @pushError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos activar los avisos. Revisá tu conexión y probá de nuevo.'**
  String get pushError;

  /// No description provided for @ubicacionDialogoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Te avisamos de mascotas perdidas cerca tuyo?'**
  String get ubicacionDialogoTitulo;

  /// No description provided for @ubicacionDialogoTexto.
  ///
  /// In es, this message translates to:
  /// **'Para eso guardamos una zona aproximada (unos 500 m), nunca tu ubicación exacta. Nadie más la ve y la podés borrar cuando quieras desde Ajustes.'**
  String get ubicacionDialogoTexto;

  /// No description provided for @ubicacionAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get ubicacionAhoraNo;

  /// No description provided for @ubicacionUsar.
  ///
  /// In es, this message translates to:
  /// **'Usar mi zona'**
  String get ubicacionUsar;

  /// No description provided for @ubicacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Zona para avisos de perdidos'**
  String get ubicacionTitulo;

  /// No description provided for @ubicacionGuardada.
  ///
  /// In es, this message translates to:
  /// **'Guardada: una zona aproximada (unos 500 m), nunca tu ubicación exacta.'**
  String get ubicacionGuardada;

  /// No description provided for @ubicacionSinGuardar.
  ///
  /// In es, this message translates to:
  /// **'Sin guardar: no te llegan avisos de mascotas perdidas cerca.'**
  String get ubicacionSinGuardar;

  /// No description provided for @ubicacionBloqueada.
  ///
  /// In es, this message translates to:
  /// **'La ubicación está bloqueada en este navegador. Habilitala desde el candado de la barra de direcciones → Ubicación.'**
  String get ubicacionBloqueada;

  /// No description provided for @ubicacionNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no nos da la ubicación.'**
  String get ubicacionNoDisponible;

  /// No description provided for @ubicacionBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get ubicacionBorrar;

  /// No description provided for @ubicacionGuardadaOk.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Te vamos a avisar de las mascotas perdidas cerca de tu zona.'**
  String get ubicacionGuardadaOk;

  /// No description provided for @ubicacionBorradaOk.
  ///
  /// In es, this message translates to:
  /// **'Borramos tu zona. Ya no te llegan avisos por cercanía.'**
  String get ubicacionBorradaOk;

  /// No description provided for @ubicacionError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos obtener tu ubicación. Revisá tu conexión y probá de nuevo.'**
  String get ubicacionError;

  /// No description provided for @leyendaPerdido.
  ///
  /// In es, this message translates to:
  /// **'Perdido'**
  String get leyendaPerdido;

  /// No description provided for @leyendaEncontrado.
  ///
  /// In es, this message translates to:
  /// **'Encontrado'**
  String get leyendaEncontrado;

  /// No description provided for @leyendaVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Veterinaria'**
  String get leyendaVeterinaria;

  /// No description provided for @leyendaUrgencia.
  ///
  /// In es, this message translates to:
  /// **'Urgencias / 24 h'**
  String get leyendaUrgencia;

  /// No description provided for @comercioAbierto24h.
  ///
  /// In es, this message translates to:
  /// **'Abierto las 24 h'**
  String get comercioAbierto24h;

  /// No description provided for @comercioAbiertoHasta.
  ///
  /// In es, this message translates to:
  /// **'Abierto · cierra a las {hora}'**
  String comercioAbiertoHasta(String hora);

  /// No description provided for @comercioCerradoHoy.
  ///
  /// In es, this message translates to:
  /// **'Cerrado · abre hoy a las {hora}'**
  String comercioCerradoHoy(String hora);

  /// No description provided for @comercioCerradoManana.
  ///
  /// In es, this message translates to:
  /// **'Cerrado · abre mañana a las {hora}'**
  String comercioCerradoManana(String hora);

  /// No description provided for @comercioCerradoDia.
  ///
  /// In es, this message translates to:
  /// **'Cerrado · abre el {dia} a las {hora}'**
  String comercioCerradoDia(String dia, String hora);

  /// No description provided for @comercioSinHorario.
  ///
  /// In es, this message translates to:
  /// **'Horario sin cargar'**
  String get comercioSinHorario;

  /// No description provided for @comercio24h.
  ///
  /// In es, this message translates to:
  /// **'24 h'**
  String get comercio24h;

  /// No description provided for @comercioUrgencias.
  ///
  /// In es, this message translates to:
  /// **'Urgencias'**
  String get comercioUrgencias;

  /// No description provided for @comercioEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo'**
  String get comercioEjemplo;

  /// No description provided for @comercioEjemploAviso.
  ///
  /// In es, this message translates to:
  /// **'Es un dato de ejemplo para probar la app: no es una veterinaria real.'**
  String get comercioEjemploAviso;

  /// No description provided for @comercioAtiende.
  ///
  /// In es, this message translates to:
  /// **'Atiende: {especies}'**
  String comercioAtiende(String especies);

  /// No description provided for @comercioHorarioSemana.
  ///
  /// In es, this message translates to:
  /// **'Horario de la semana'**
  String get comercioHorarioSemana;

  /// No description provided for @comercioDiaCerrado.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get comercioDiaCerrado;

  /// No description provided for @comercioLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get comercioLlamar;

  /// No description provided for @comercioWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get comercioWhatsapp;

  /// No description provided for @comercioComoLlegar.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get comercioComoLlegar;

  /// No description provided for @comercioWeb.
  ///
  /// In es, this message translates to:
  /// **'Web'**
  String get comercioWeb;

  /// No description provided for @comercioInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram'**
  String get comercioInstagram;

  /// No description provided for @diaLunes.
  ///
  /// In es, this message translates to:
  /// **'lunes'**
  String get diaLunes;

  /// No description provided for @diaMartes.
  ///
  /// In es, this message translates to:
  /// **'martes'**
  String get diaMartes;

  /// No description provided for @diaMiercoles.
  ///
  /// In es, this message translates to:
  /// **'miércoles'**
  String get diaMiercoles;

  /// No description provided for @diaJueves.
  ///
  /// In es, this message translates to:
  /// **'jueves'**
  String get diaJueves;

  /// No description provided for @diaViernes.
  ///
  /// In es, this message translates to:
  /// **'viernes'**
  String get diaViernes;

  /// No description provided for @diaSabado.
  ///
  /// In es, this message translates to:
  /// **'sábado'**
  String get diaSabado;

  /// No description provided for @diaDomingo.
  ///
  /// In es, this message translates to:
  /// **'domingo'**
  String get diaDomingo;

  /// No description provided for @ayuda911Titulo.
  ///
  /// In es, this message translates to:
  /// **'¿Hay una persona en riesgo?'**
  String get ayuda911Titulo;

  /// No description provided for @ayuda911Texto.
  ///
  /// In es, this message translates to:
  /// **'Llamá al 911. SOS Mascota es solo para animales.'**
  String get ayuda911Texto;

  /// No description provided for @ayuda911Boton.
  ///
  /// In es, this message translates to:
  /// **'Llamar al 911'**
  String get ayuda911Boton;

  /// No description provided for @ayudaUrgencias.
  ///
  /// In es, this message translates to:
  /// **'Veterinarias de urgencia'**
  String get ayudaUrgencias;

  /// No description provided for @ayudaSinUrgencias.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay veterinarias de urgencia cargadas en tu zona.'**
  String get ayudaSinUrgencias;

  /// No description provided for @ayudaRefugios.
  ///
  /// In es, this message translates to:
  /// **'Refugios y protectoras'**
  String get ayudaRefugios;

  /// No description provided for @ayudaGrupos.
  ///
  /// In es, this message translates to:
  /// **'Grupos para difundir'**
  String get ayudaGrupos;

  /// No description provided for @ayudaOrganismos.
  ///
  /// In es, this message translates to:
  /// **'Organismos'**
  String get ayudaOrganismos;

  /// No description provided for @ayudaAbrir.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get ayudaAbrir;

  /// No description provided for @ayudaDirectorioVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay refugios ni grupos cargados en tu zona.'**
  String get ayudaDirectorioVacio;

  /// No description provided for @ajustesTema.
  ///
  /// In es, this message translates to:
  /// **'Tema de colores'**
  String get ajustesTema;

  /// No description provided for @ajustesTemaPro.
  ///
  /// In es, this message translates to:
  /// **'{nombre} · beneficio de tu plan Pro'**
  String ajustesTemaPro(String nombre);

  /// No description provided for @temaElegirTitulo.
  ///
  /// In es, this message translates to:
  /// **'Elegí cómo se ve la app'**
  String get temaElegirTitulo;

  /// No description provided for @temaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Cambia los colores y las letras de la app solo en este dispositivo. El mapa, la chapita y lo que ven los demás siguen igual.'**
  String get temaExplicacion;

  /// No description provided for @temaCielo.
  ///
  /// In es, this message translates to:
  /// **'Cielo'**
  String get temaCielo;

  /// No description provided for @temaCieloDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Calma y confianza: el de SOS Mascota'**
  String get temaCieloDescripcion;

  /// No description provided for @temaFaro.
  ///
  /// In es, this message translates to:
  /// **'Faro'**
  String get temaFaro;

  /// No description provided for @temaFaroDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Naranja de rescate y azul noche'**
  String get temaFaroDescripcion;

  /// No description provided for @temaVecinos.
  ///
  /// In es, this message translates to:
  /// **'Vecinos'**
  String get temaVecinos;

  /// No description provided for @temaVecinosDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Terracota y mostaza, de barrio'**
  String get temaVecinosDescripcion;

  /// No description provided for @temaPop.
  ///
  /// In es, this message translates to:
  /// **'Pop'**
  String get temaPop;

  /// No description provided for @temaPopDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Violeta y amarillo, tipo sticker'**
  String get temaPopDescripcion;

  /// No description provided for @noDisponibleTitulo.
  ///
  /// In es, this message translates to:
  /// **'Todavía no está disponible'**
  String get noDisponibleTitulo;

  /// No description provided for @noDisponibleTexto.
  ///
  /// In es, this message translates to:
  /// **'Esta función se está probando de a poco y todavía no te llegó. Cuando esté lista para vos, la vas a ver en la app.'**
  String get noDisponibleTexto;

  /// No description provided for @noDisponibleIrAlMapa.
  ///
  /// In es, this message translates to:
  /// **'Ir al mapa'**
  String get noDisponibleIrAlMapa;

  /// No description provided for @instalarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Instalar la app'**
  String get instalarTitulo;

  /// No description provided for @instalarSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Abrila desde la pantalla de inicio, más rápido y con avisos'**
  String get instalarSubtitulo;

  /// No description provided for @instalarTarjetaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Instalá SOS Mascota'**
  String get instalarTarjetaTitulo;

  /// No description provided for @instalarTarjetaTexto.
  ///
  /// In es, this message translates to:
  /// **'Queda en tu pantalla de inicio y te avisa enseguida si se pierde una mascota cerca.'**
  String get instalarTarjetaTexto;

  /// No description provided for @instalarBoton.
  ///
  /// In es, this message translates to:
  /// **'Instalar'**
  String get instalarBoton;

  /// No description provided for @instalarAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get instalarAhoraNo;

  /// No description provided for @instalarGracias.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya podés abrir SOS Mascota desde la pantalla de inicio.'**
  String get instalarGracias;

  /// No description provided for @instalarIphoneTitulo.
  ///
  /// In es, this message translates to:
  /// **'Instalar en el iPhone'**
  String get instalarIphoneTitulo;

  /// No description provided for @instalarIphonePaso1.
  ///
  /// In es, this message translates to:
  /// **'Abrí esta página en Safari.'**
  String get instalarIphonePaso1;

  /// No description provided for @instalarIphonePaso2.
  ///
  /// In es, this message translates to:
  /// **'Tocá Compartir (el cuadrado con la flecha hacia arriba).'**
  String get instalarIphonePaso2;

  /// No description provided for @instalarIphonePaso3.
  ///
  /// In es, this message translates to:
  /// **'Elegí «Agregar a inicio» y después «Agregar».'**
  String get instalarIphonePaso3;

  /// No description provided for @instalarIphoneAvisos.
  ///
  /// In es, this message translates to:
  /// **'En el iPhone, los avisos de mascotas perdidas solo llegan con la app instalada.'**
  String get instalarIphoneAvisos;

  /// No description provided for @instalarEntendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get instalarEntendido;

  /// No description provided for @libretaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Libreta sanitaria'**
  String get libretaTitulo;

  /// No description provided for @libretaVacia.
  ///
  /// In es, this message translates to:
  /// **'Anotá vacunas, desparasitaciones, controles y alergias para tenerlas siempre a mano.'**
  String get libretaVacia;

  /// No description provided for @libretaAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar a la libreta'**
  String get libretaAgregar;

  /// No description provided for @libretaNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo registro'**
  String get libretaNuevoTitulo;

  /// No description provided for @libretaEditarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Editar registro'**
  String get libretaEditarTitulo;

  /// No description provided for @libretaTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get libretaTipo;

  /// No description provided for @libretaTipoVacuna.
  ///
  /// In es, this message translates to:
  /// **'Vacuna'**
  String get libretaTipoVacuna;

  /// No description provided for @libretaTipoDesparasitacion.
  ///
  /// In es, this message translates to:
  /// **'Desparasitación'**
  String get libretaTipoDesparasitacion;

  /// No description provided for @libretaTipoControl.
  ///
  /// In es, this message translates to:
  /// **'Control'**
  String get libretaTipoControl;

  /// No description provided for @libretaTipoAlergia.
  ///
  /// In es, this message translates to:
  /// **'Alergia'**
  String get libretaTipoAlergia;

  /// No description provided for @libretaTipoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get libretaTipoOtro;

  /// No description provided for @libretaGrupoVacunas.
  ///
  /// In es, this message translates to:
  /// **'Vacunas'**
  String get libretaGrupoVacunas;

  /// No description provided for @libretaGrupoDesparasitaciones.
  ///
  /// In es, this message translates to:
  /// **'Desparasitaciones'**
  String get libretaGrupoDesparasitaciones;

  /// No description provided for @libretaGrupoControles.
  ///
  /// In es, this message translates to:
  /// **'Controles'**
  String get libretaGrupoControles;

  /// No description provided for @libretaGrupoAlergias.
  ///
  /// In es, this message translates to:
  /// **'Alergias'**
  String get libretaGrupoAlergias;

  /// No description provided for @libretaGrupoOtros.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get libretaGrupoOtros;

  /// No description provided for @libretaNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get libretaNombre;

  /// No description provided for @libretaNombreAyudaVacuna.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Antirrábica, Séxtuple, Triple felina.'**
  String get libretaNombreAyudaVacuna;

  /// No description provided for @libretaNombreAyudaDesparasitacion.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: pipeta, comprimido, interna o externa.'**
  String get libretaNombreAyudaDesparasitacion;

  /// No description provided for @libretaNombreAyudaControl.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: control anual, análisis de sangre.'**
  String get libretaNombreAyudaControl;

  /// No description provided for @libretaNombreAyudaAlergia.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: pollo, un medicamento, picadura de pulga.'**
  String get libretaNombreAyudaAlergia;

  /// No description provided for @libretaNombreAyudaOtro.
  ///
  /// In es, this message translates to:
  /// **'Cirugía, tratamiento, peso…'**
  String get libretaNombreAyudaOtro;

  /// No description provided for @libretaNombreFalta.
  ///
  /// In es, this message translates to:
  /// **'Escribí qué fue.'**
  String get libretaNombreFalta;

  /// No description provided for @libretaNombreLargo.
  ///
  /// In es, this message translates to:
  /// **'Usá hasta 80 letras.'**
  String get libretaNombreLargo;

  /// No description provided for @libretaFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get libretaFecha;

  /// No description provided for @libretaFechaElegir.
  ///
  /// In es, this message translates to:
  /// **'Elegir'**
  String get libretaFechaElegir;

  /// No description provided for @libretaFechaSin.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get libretaFechaSin;

  /// No description provided for @libretaProxima.
  ///
  /// In es, this message translates to:
  /// **'Próxima dosis o control'**
  String get libretaProxima;

  /// No description provided for @libretaProximaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Opcional. Sirve para recordarte cuándo toca.'**
  String get libretaProximaAyuda;

  /// No description provided for @libretaProximaAntes.
  ///
  /// In es, this message translates to:
  /// **'La próxima fecha no puede ser anterior a la fecha.'**
  String get libretaProximaAntes;

  /// No description provided for @libretaQuitarFecha.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get libretaQuitarFecha;

  /// No description provided for @libretaNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get libretaNotas;

  /// No description provided for @libretaNotasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lote, veterinaria, dosis… (solo lo ves vos).'**
  String get libretaNotasAyuda;

  /// No description provided for @libretaBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar registro'**
  String get libretaBorrar;

  /// No description provided for @libretaBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar «{nombre}»?'**
  String libretaBorrarTitulo(String nombre);

  /// No description provided for @libretaBorrarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Se borra de la libreta y no se puede recuperar.'**
  String get libretaBorrarExplicacion;

  /// No description provided for @libretaProximaEl.
  ///
  /// In es, this message translates to:
  /// **'Próxima: {fecha}'**
  String libretaProximaEl(String fecha);

  /// No description provided for @semaforoVencio.
  ///
  /// In es, this message translates to:
  /// **'Venció hace {dias, plural, =1{1 día} other{{dias} días}}'**
  String semaforoVencio(int dias);

  /// No description provided for @semaforoHoy.
  ///
  /// In es, this message translates to:
  /// **'Vence hoy'**
  String get semaforoHoy;

  /// No description provided for @semaforoFaltan.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{Falta 1 día} other{Faltan {dias} días}}'**
  String semaforoFaltan(int dias);

  /// No description provided for @libretaProximoUrgente.
  ///
  /// In es, this message translates to:
  /// **'Lo próximo de la libreta'**
  String get libretaProximoUrgente;

  /// No description provided for @recordatoriosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get recordatoriosTitulo;

  /// No description provided for @recordatoriosVacio.
  ///
  /// In es, this message translates to:
  /// **'Programá remedios, comidas o vacunas y te avisamos a la hora.'**
  String get recordatoriosVacio;

  /// No description provided for @recordatoriosAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar recordatorio'**
  String get recordatoriosAgregar;

  /// No description provided for @recordatorioNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo recordatorio'**
  String get recordatorioNuevoTitulo;

  /// No description provided for @recordatorioEditarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Editar recordatorio'**
  String get recordatorioEditarTitulo;

  /// No description provided for @recordatorioTipoMedicacion.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get recordatorioTipoMedicacion;

  /// No description provided for @recordatorioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Remedio'**
  String get recordatorioTitulo;

  /// No description provided for @recordatorioTituloAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: antibiótico, antiinflamatorio, gotas para los oídos.'**
  String get recordatorioTituloAyuda;

  /// No description provided for @recordatorioTituloFalta.
  ///
  /// In es, this message translates to:
  /// **'Escribí qué hay que darle.'**
  String get recordatorioTituloFalta;

  /// No description provided for @recordatorioTituloLargo.
  ///
  /// In es, this message translates to:
  /// **'Usá hasta 80 letras.'**
  String get recordatorioTituloLargo;

  /// No description provided for @recordatorioDosis.
  ///
  /// In es, this message translates to:
  /// **'Dosis (opcional)'**
  String get recordatorioDosis;

  /// No description provided for @recordatorioDosisAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: 1/2 comprimido, 5 gotas.'**
  String get recordatorioDosisAyuda;

  /// No description provided for @recordatorioFrecuencia.
  ///
  /// In es, this message translates to:
  /// **'Cada cuánto'**
  String get recordatorioFrecuencia;

  /// No description provided for @recordatorioCadaHoras.
  ///
  /// In es, this message translates to:
  /// **'Cada X horas'**
  String get recordatorioCadaHoras;

  /// No description provided for @recordatorioDiaria.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get recordatorioDiaria;

  /// No description provided for @recordatorioSemanal.
  ///
  /// In es, this message translates to:
  /// **'Algunos días'**
  String get recordatorioSemanal;

  /// No description provided for @recordatorioCadaNHoras.
  ///
  /// In es, this message translates to:
  /// **'{horas, plural, =1{Cada 1 hora} other{Cada {horas} horas}}'**
  String recordatorioCadaNHoras(int horas);

  /// No description provided for @recordatorioPrimeraToma.
  ///
  /// In es, this message translates to:
  /// **'Primera toma'**
  String get recordatorioPrimeraToma;

  /// No description provided for @recordatorioInicio.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get recordatorioInicio;

  /// No description provided for @recordatorioHorarios.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get recordatorioHorarios;

  /// No description provided for @recordatorioAgregarHorario.
  ///
  /// In es, this message translates to:
  /// **'Agregar horario'**
  String get recordatorioAgregarHorario;

  /// No description provided for @recordatorioQuitarHorario.
  ///
  /// In es, this message translates to:
  /// **'Quitar {hora}'**
  String recordatorioQuitarHorario(String hora);

  /// No description provided for @recordatorioSinHorarios.
  ///
  /// In es, this message translates to:
  /// **'Agregá al menos un horario.'**
  String get recordatorioSinHorarios;

  /// No description provided for @recordatorioDias.
  ///
  /// In es, this message translates to:
  /// **'Días'**
  String get recordatorioDias;

  /// No description provided for @recordatorioSinDias.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos un día.'**
  String get recordatorioSinDias;

  /// No description provided for @recordatorioFin.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get recordatorioFin;

  /// No description provided for @recordatorioFinSin.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de fin'**
  String get recordatorioFinSin;

  /// No description provided for @recordatorioFinAntes.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior al inicio.'**
  String get recordatorioFinAntes;

  /// No description provided for @recordatorioActivo.
  ///
  /// In es, this message translates to:
  /// **'Avisarme'**
  String get recordatorioActivo;

  /// No description provided for @recordatorioPausado.
  ///
  /// In es, this message translates to:
  /// **'Pausado'**
  String get recordatorioPausado;

  /// No description provided for @recordatorioTerminado.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get recordatorioTerminado;

  /// No description provided for @recordatorioProxima.
  ///
  /// In es, this message translates to:
  /// **'Próxima: {cuando}'**
  String recordatorioProxima(String cuando);

  /// No description provided for @recordatorioHoyA.
  ///
  /// In es, this message translates to:
  /// **'hoy a las {hora}'**
  String recordatorioHoyA(String hora);

  /// No description provided for @recordatorioMananaA.
  ///
  /// In es, this message translates to:
  /// **'mañana a las {hora}'**
  String recordatorioMananaA(String hora);

  /// No description provided for @recordatorioFechaA.
  ///
  /// In es, this message translates to:
  /// **'{fecha} a las {hora}'**
  String recordatorioFechaA(String fecha, String hora);

  /// No description provided for @recordatorioBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar recordatorio'**
  String get recordatorioBorrar;

  /// No description provided for @recordatorioBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar «{nombre}»?'**
  String recordatorioBorrarTitulo(String nombre);

  /// No description provided for @recordatorioBorrarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Deja de avisarte y no se puede recuperar.'**
  String get recordatorioBorrarExplicacion;

  /// No description provided for @recordatorioAvisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'{titulo} para {mascota}'**
  String recordatorioAvisoTitulo(String titulo, String mascota);

  /// No description provided for @recordatorioAvisoCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Es la hora.'**
  String get recordatorioAvisoCuerpo;

  /// No description provided for @recordatoriosAvisosWeb.
  ///
  /// In es, this message translates to:
  /// **'En la web te avisamos mientras la app esté abierta (aunque esté minimizada). Instalada en Android o iPhone, te va a avisar siempre.'**
  String get recordatoriosAvisosWeb;

  /// No description provided for @recordatoriosActivarAvisos.
  ///
  /// In es, this message translates to:
  /// **'Activar avisos'**
  String get recordatoriosActivarAvisos;

  /// No description provided for @recordatoriosAvisosBloqueados.
  ///
  /// In es, this message translates to:
  /// **'Los avisos están bloqueados en este navegador. Habilitalos en la configuración del sitio.'**
  String get recordatoriosAvisosBloqueados;
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
