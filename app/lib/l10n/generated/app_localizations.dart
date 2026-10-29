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

  /// Nombre corto de la pestaña Mis mascotas en la barra inferior (D94).
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get barraMascotas;

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

  /// No description provided for @cuentaParaPedir.
  ///
  /// In es, this message translates to:
  /// **'Para armar un pedido necesitás una cuenta: así el comercio sabe quién le pide y vos lo seguís en «Mis pedidos».'**
  String get cuentaParaPedir;

  /// No description provided for @cuentaParaConsultar.
  ///
  /// In es, this message translates to:
  /// **'Para consultarle al comercio necesitás una cuenta: así evitamos mensajes falsos y te puede responder.'**
  String get cuentaParaConsultar;

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

  /// No description provided for @mascotaSalirTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Salir sin guardar?'**
  String get mascotaSalirTitulo;

  /// No description provided for @mascotaSalirExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Si salís ahora, se pierden los cambios (también la foto). Para que queden, tocá Guardar.'**
  String get mascotaSalirExplicacion;

  /// No description provided for @mascotaSalirSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get mascotaSalirSeguir;

  /// No description provided for @mascotaSalirDescartar.
  ///
  /// In es, this message translates to:
  /// **'Salir sin guardar'**
  String get mascotaSalirDescartar;

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
  /// **'Descargar la etiqueta para el collar'**
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

  /// No description provided for @chapitasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Chapitas físicas'**
  String get chapitasTitulo;

  /// No description provided for @chapitasExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Si tenés una chapita de SOS Mascota, vinculala con {nombre}: escaneala con la cámara del celular o escribí el código que tiene impreso.'**
  String chapitasExplicacion(Object nombre);

  /// No description provided for @chapitasNinguna.
  ///
  /// In es, this message translates to:
  /// **'Todavía no vinculaste ninguna chapita.'**
  String get chapitasNinguna;

  /// No description provided for @chapitaActivar.
  ///
  /// In es, this message translates to:
  /// **'Activar una chapita'**
  String get chapitaActivar;

  /// No description provided for @chapitaCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código de la chapita'**
  String get chapitaCodigo;

  /// No description provided for @chapitaCodigoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Son 8 letras y números, impresos en la chapita.'**
  String get chapitaCodigoAyuda;

  /// No description provided for @chapitaCodigoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Revisá el código: son 8 letras y números.'**
  String get chapitaCodigoInvalido;

  /// No description provided for @chapitaActivada.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Quien escanee la chapita va a ver a {nombre}.'**
  String chapitaActivada(Object nombre);

  /// No description provided for @chapitaInexistente.
  ///
  /// In es, this message translates to:
  /// **'No encontramos una chapita con ese código. Revisá que esté bien escrito.'**
  String get chapitaInexistente;

  /// No description provided for @chapitaUsada.
  ///
  /// In es, this message translates to:
  /// **'Esta chapita ya está vinculada o se dio de baja, y no se puede volver a usar.'**
  String get chapitaUsada;

  /// No description provided for @chapitaLimite.
  ///
  /// In es, this message translates to:
  /// **'Activaste muchas chapitas hoy. Probá de nuevo mañana.'**
  String get chapitaLimite;

  /// No description provided for @chapitaDesvincular.
  ///
  /// In es, this message translates to:
  /// **'Desvincular'**
  String get chapitaDesvincular;

  /// No description provided for @chapitaDesvincularTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Desvincular la chapita?'**
  String get chapitaDesvincularTitulo;

  /// No description provided for @chapitaDesvincularTexto.
  ///
  /// In es, this message translates to:
  /// **'La chapita {codigo} deja de mostrar a {nombre} y no se puede volver a usar. Hacelo si la perdiste o la vas a reemplazar.'**
  String chapitaDesvincularTexto(Object codigo, Object nombre);

  /// No description provided for @chapitaDesvinculada.
  ///
  /// In es, this message translates to:
  /// **'Chapita desvinculada.'**
  String get chapitaDesvinculada;

  /// No description provided for @activarChapitaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Activar chapita'**
  String get activarChapitaTitulo;

  /// No description provided for @activarChapitaTexto.
  ///
  /// In es, this message translates to:
  /// **'Elegí qué mascota va a llevar esta chapita. Quien la escanee va a ver su foto y su nombre, y va a poder avisarte sin ver tu teléfono.'**
  String get activarChapitaTexto;

  /// No description provided for @activarChapitaSinMascotas.
  ///
  /// In es, this message translates to:
  /// **'Primero cargá a tu mascota y después volvé a escanear la chapita.'**
  String get activarChapitaSinMascotas;

  /// No description provided for @activarChapitaBoton.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get activarChapitaBoton;

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
  /// **'Nunca pagues por adelantado ni mandes plata para recuperar a tu mascota. Si te la piden, marcá el aviso como estafa. Si encontraste una mascota y alguien dice que es suya, antes de entregarla pedile fotos de antes con ella o el carné de vacunas y una seña que no publicaste, y encuéntrense en un lugar público.'**
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

  /// No description provided for @fichaVerReportePerdida.
  ///
  /// In es, this message translates to:
  /// **'Ver su reporte de perdida'**
  String get fichaVerReportePerdida;

  /// No description provided for @sosYaReportada.
  ///
  /// In es, this message translates to:
  /// **'Esta mascota ya tiene un reporte de perdida abierto. Lo encontrás en su ficha o en SOS.'**
  String get sosYaReportada;

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

  /// No description provided for @sosSenasAyudaEncontrada.
  ///
  /// In es, this message translates to:
  /// **'Guardate una seña sin publicar: te sirve para comprobar quién es su familia.'**
  String get sosSenasAyudaEncontrada;

  /// No description provided for @sosCartel.
  ///
  /// In es, this message translates to:
  /// **'Imprimir cartel'**
  String get sosCartel;

  /// No description provided for @sosCartelExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Un cartel A4 para pegar en el barrio, con la foto y un QR: quien la vea avisa desde el celular, sin la app. No lleva tu teléfono.'**
  String get sosCartelExplicacion;

  /// No description provided for @sosCartelDondePerdida.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la vieron por última vez? (opcional)'**
  String get sosCartelDondePerdida;

  /// No description provided for @sosCartelDondeEncontrada.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la encontraste? (opcional)'**
  String get sosCartelDondeEncontrada;

  /// No description provided for @sosCartelDondeAyuda.
  ///
  /// In es, this message translates to:
  /// **'Un barrio o una referencia, por ejemplo: Centro, cerca de la plaza. Nunca tu dirección.'**
  String get sosCartelDondeAyuda;

  /// No description provided for @sosCartelArmar.
  ///
  /// In es, this message translates to:
  /// **'Armar el cartel'**
  String get sosCartelArmar;

  /// No description provided for @sosCartelSeBusca.
  ///
  /// In es, this message translates to:
  /// **'SE BUSCA'**
  String get sosCartelSeBusca;

  /// No description provided for @sosCartelSeEncontro.
  ///
  /// In es, this message translates to:
  /// **'SE ENCONTRÓ'**
  String get sosCartelSeEncontro;

  /// No description provided for @sosCartelEsTuyo.
  ///
  /// In es, this message translates to:
  /// **'¿Es tuyo?'**
  String get sosCartelEsTuyo;

  /// No description provided for @sosCartelSenas.
  ///
  /// In es, this message translates to:
  /// **'Señas: {senas}'**
  String sosCartelSenas(String senas);

  /// No description provided for @sosCartelFaltaDesde.
  ///
  /// In es, this message translates to:
  /// **'Falta desde el {fecha}'**
  String sosCartelFaltaDesde(String fecha);

  /// No description provided for @sosCartelEncontradaEl.
  ///
  /// In es, this message translates to:
  /// **'Encontrada el {fecha}'**
  String sosCartelEncontradaEl(String fecha);

  /// No description provided for @sosCartelVistaEn.
  ///
  /// In es, this message translates to:
  /// **'Vista por última vez: {lugar}'**
  String sosCartelVistaEn(String lugar);

  /// No description provided for @sosCartelEncontradaEn.
  ///
  /// In es, this message translates to:
  /// **'Encontrada en: {lugar}'**
  String sosCartelEncontradaEn(String lugar);

  /// No description provided for @sosCartelEscaneaPerdida.
  ///
  /// In es, this message translates to:
  /// **'¿La viste? Escaneá el QR con la cámara del celular.'**
  String get sosCartelEscaneaPerdida;

  /// No description provided for @sosCartelEscaneaEncontrada.
  ///
  /// In es, this message translates to:
  /// **'¿Es tuyo o sabés de quién es? Escaneá el QR con la cámara del celular.'**
  String get sosCartelEscaneaEncontrada;

  /// No description provided for @sosCartelPrivacidadPerdida.
  ///
  /// In es, this message translates to:
  /// **'Vas a ver su reporte y podés dejarle un mensaje a su familia con dónde y cuándo la viste. SOS Mascota es la comunidad que armamos entre todos, con las mascotas en el centro.'**
  String get sosCartelPrivacidadPerdida;

  /// No description provided for @sosCartelPrivacidadEncontrada.
  ///
  /// In es, this message translates to:
  /// **'Vas a ver el reporte y podés dejarle un mensaje a quien lo encontró. SOS Mascota es la comunidad que armamos entre todos, con las mascotas en el centro.'**
  String get sosCartelPrivacidadEncontrada;

  /// No description provided for @sosCartelPie.
  ///
  /// In es, this message translates to:
  /// **'SOS Mascota · la comunidad que tu mascota necesita: encontrar, adoptar, eventos y servicios · {enlace}'**
  String sosCartelPie(String enlace);

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

  /// No description provided for @temaBlancoNegro.
  ///
  /// In es, this message translates to:
  /// **'Blanco y negro'**
  String get temaBlancoNegro;

  /// No description provided for @temaBlancoNegroDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Sin colores, con las barras blancas'**
  String get temaBlancoNegroDescripcion;

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
  /// **'Escribí de qué es el recordatorio.'**
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

  /// No description provided for @recordatorioTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get recordatorioTipo;

  /// No description provided for @recordatorioTipoComida.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get recordatorioTipoComida;

  /// No description provided for @recordatorioTipoVacuna.
  ///
  /// In es, this message translates to:
  /// **'Vacuna'**
  String get recordatorioTipoVacuna;

  /// No description provided for @recordatorioTipoControl.
  ///
  /// In es, this message translates to:
  /// **'Control'**
  String get recordatorioTipoControl;

  /// No description provided for @recordatorioTituloComida.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get recordatorioTituloComida;

  /// No description provided for @recordatorioTituloComidaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: balanceado, comida húmeda.'**
  String get recordatorioTituloComidaAyuda;

  /// No description provided for @recordatorioTituloVacuna.
  ///
  /// In es, this message translates to:
  /// **'Vacuna'**
  String get recordatorioTituloVacuna;

  /// No description provided for @recordatorioTituloVacunaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Antirrábica, Séxtuple, Triple felina.'**
  String get recordatorioTituloVacunaAyuda;

  /// No description provided for @recordatorioTituloControl.
  ///
  /// In es, this message translates to:
  /// **'Control'**
  String get recordatorioTituloControl;

  /// No description provided for @recordatorioTituloControlAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: control anual, análisis de sangre.'**
  String get recordatorioTituloControlAyuda;

  /// No description provided for @recordatorioPorcion.
  ///
  /// In es, this message translates to:
  /// **'Porción (opcional)'**
  String get recordatorioPorcion;

  /// No description provided for @recordatorioPorcionAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: 1 taza, 150 g.'**
  String get recordatorioPorcionAyuda;

  /// No description provided for @recordatorioCuando.
  ///
  /// In es, this message translates to:
  /// **'Cuándo'**
  String get recordatorioCuando;

  /// No description provided for @recordatorioYaPaso.
  ///
  /// In es, this message translates to:
  /// **'Ya pasó'**
  String get recordatorioYaPaso;

  /// No description provided for @libretaRecordarmeDe.
  ///
  /// In es, this message translates to:
  /// **'Recordarme {nombre}'**
  String libretaRecordarmeDe(String nombre);

  /// No description provided for @recordatorioYaSeLaDi.
  ///
  /// In es, this message translates to:
  /// **'✅ Ya se la di ({hora})'**
  String recordatorioYaSeLaDi(String hora);

  /// No description provided for @recordatorioYaComio.
  ///
  /// In es, this message translates to:
  /// **'✅ Ya comió ({hora})'**
  String recordatorioYaComio(String hora);

  /// No description provided for @recordatorioHecho.
  ///
  /// In es, this message translates to:
  /// **'✅ Hecho ({hora})'**
  String recordatorioHecho(String hora);

  /// No description provided for @recordatorioMarcado.
  ///
  /// In es, this message translates to:
  /// **'Listo, quedó anotado.'**
  String get recordatorioMarcado;

  /// No description provided for @recordatorioDeshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get recordatorioDeshacer;

  /// No description provided for @recordatorioHistorial.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get recordatorioHistorial;

  /// No description provided for @recordatorioHistorialVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no marcaste ninguna toma.'**
  String get recordatorioHistorialVacio;

  /// No description provided for @recordatorioHistorialMarcada.
  ///
  /// In es, this message translates to:
  /// **'Marcada {cuando}'**
  String recordatorioHistorialMarcada(String cuando);

  /// No description provided for @hogarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi hogar'**
  String get hogarTitulo;

  /// No description provided for @hogarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Compartí tus mascotas con tu familia: ven y editan la ficha, la libreta y los recordatorios, marcan «Ya se la di» y reciben los avisos del QR. Hasta 5 personas además de vos.'**
  String get hogarExplicacion;

  /// No description provided for @hogarInvitar.
  ///
  /// In es, this message translates to:
  /// **'Invitar a alguien'**
  String get hogarInvitar;

  /// No description provided for @hogarInvitacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Invitación lista'**
  String get hogarInvitacionTitulo;

  /// No description provided for @hogarInvitacionTexto.
  ///
  /// In es, this message translates to:
  /// **'Mandale este enlace por WhatsApp o como quieras. Sirve una sola vez y vence en 7 días.'**
  String get hogarInvitacionTexto;

  /// No description provided for @hogarCopiar.
  ///
  /// In es, this message translates to:
  /// **'Copiar enlace'**
  String get hogarCopiar;

  /// No description provided for @hogarCopiado.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado.'**
  String get hogarCopiado;

  /// No description provided for @hogarMensajeInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Te invito a cuidar a mis mascotas en SOS Mascota: {enlace}'**
  String hogarMensajeInvitacion(String enlace);

  /// No description provided for @hogarCreador.
  ///
  /// In es, this message translates to:
  /// **'Creó el hogar'**
  String get hogarCreador;

  /// No description provided for @hogarIntegrante.
  ///
  /// In es, this message translates to:
  /// **'Integrante'**
  String get hogarIntegrante;

  /// No description provided for @hogarCuidadorHasta.
  ///
  /// In es, this message translates to:
  /// **'Cuidador temporal hasta el {fecha}'**
  String hogarCuidadorHasta(String fecha);

  /// No description provided for @hogarVos.
  ///
  /// In es, this message translates to:
  /// **'{nombre} (vos)'**
  String hogarVos(String nombre);

  /// No description provided for @hogarSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get hogarSinNombre;

  /// No description provided for @hogarSacar.
  ///
  /// In es, this message translates to:
  /// **'Sacar del hogar'**
  String get hogarSacar;

  /// No description provided for @hogarSacarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Sacar a {nombre}?'**
  String hogarSacarTitulo(String nombre);

  /// No description provided for @hogarSacarTexto.
  ///
  /// In es, this message translates to:
  /// **'Deja de ver tus mascotas en ese momento.'**
  String get hogarSacarTexto;

  /// No description provided for @hogarIrme.
  ///
  /// In es, this message translates to:
  /// **'Salir de este hogar'**
  String get hogarIrme;

  /// No description provided for @hogarIrmeTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del hogar?'**
  String get hogarIrmeTitulo;

  /// No description provided for @hogarIrmeTexto.
  ///
  /// In es, this message translates to:
  /// **'Dejás de ver sus mascotas. Para volver, te tienen que invitar de nuevo.'**
  String get hogarIrmeTexto;

  /// No description provided for @hogarSalir.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get hogarSalir;

  /// No description provided for @hogarLleno.
  ///
  /// In es, this message translates to:
  /// **'Ya son 5 integrantes: es el máximo.'**
  String get hogarLleno;

  /// No description provided for @hogarMio.
  ///
  /// In es, this message translates to:
  /// **'Tu hogar'**
  String get hogarMio;

  /// No description provided for @hogarDe.
  ///
  /// In es, this message translates to:
  /// **'Hogar de {nombre}'**
  String hogarDe(String nombre);

  /// No description provided for @hogarSoloVos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no invitaste a nadie.'**
  String get hogarSoloVos;

  /// No description provided for @unirmeTitulo.
  ///
  /// In es, this message translates to:
  /// **'Invitación a un hogar'**
  String get unirmeTitulo;

  /// No description provided for @unirmeTexto.
  ///
  /// In es, this message translates to:
  /// **'Te invitaron a cuidar mascotas en SOS Mascota. Vas a poder ver y editar sus fichas, la libreta y los recordatorios, y vas a recibir los avisos del QR. Las personas del hogar van a ver tu nombre (nunca tu correo).'**
  String get unirmeTexto;

  /// No description provided for @unirmeBoton.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get unirmeBoton;

  /// No description provided for @unirmeListo.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya ves sus mascotas en «Mis mascotas».'**
  String get unirmeListo;

  /// No description provided for @unirmeNoSirve.
  ///
  /// In es, this message translates to:
  /// **'Esta invitación no existe, ya se usó o venció. Pedí una nueva.'**
  String get unirmeNoSirve;

  /// No description provided for @unirmePropia.
  ///
  /// In es, this message translates to:
  /// **'Este enlace es de tu propio hogar: mandáselo a quien quieras invitar.'**
  String get unirmePropia;

  /// No description provided for @unirmeYaSos.
  ///
  /// In es, this message translates to:
  /// **'Ya sos parte de este hogar.'**
  String get unirmeYaSos;

  /// No description provided for @unirmeLleno.
  ///
  /// In es, this message translates to:
  /// **'Ese hogar ya tiene 5 integrantes.'**
  String get unirmeLleno;

  /// No description provided for @mascotaCompartidaDe.
  ///
  /// In es, this message translates to:
  /// **'Compartida por {nombre}'**
  String mascotaCompartidaDe(String nombre);

  /// No description provided for @mascotaCompartida.
  ///
  /// In es, this message translates to:
  /// **'Compartida con vos'**
  String get mascotaCompartida;

  /// No description provided for @recordatorioMarcadaPor.
  ///
  /// In es, this message translates to:
  /// **'Marcada por {nombre} {cuando}'**
  String recordatorioMarcadaPor(String nombre, String cuando);

  /// No description provided for @perfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get perfilTitulo;

  /// No description provided for @perfilAbrir.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get perfilAbrir;

  /// No description provided for @perfilAbrirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tu rol, tus mascotas y con quién compartís el cuidado.'**
  String get perfilAbrirAyuda;

  /// No description provided for @perfilRol.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get perfilRol;

  /// No description provided for @perfilRolDueno.
  ///
  /// In es, this message translates to:
  /// **'Dueño o dueña de mascotas'**
  String get perfilRolDueno;

  /// No description provided for @perfilRolAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administración de SOS Mascota'**
  String get perfilRolAdmin;

  /// No description provided for @perfilPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get perfilPlan;

  /// No description provided for @perfilPlanGratis.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get perfilPlanGratis;

  /// No description provided for @perfilPlanPro.
  ///
  /// In es, this message translates to:
  /// **'Pro'**
  String get perfilPlanPro;

  /// No description provided for @perfilPlanFamilia.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get perfilPlanFamilia;

  /// No description provided for @perfilMascotas.
  ///
  /// In es, this message translates to:
  /// **'Mascotas a tu cargo'**
  String get perfilMascotas;

  /// No description provided for @perfilSinMascotas.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés mascotas cargadas ni compartidas.'**
  String get perfilSinMascotas;

  /// No description provided for @perfilPropias.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 tuya} other{{cantidad} tuyas}}'**
  String perfilPropias(int cantidad);

  /// No description provided for @perfilCompartidas.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 compartida con vos} other{{cantidad} compartidas con vos}}'**
  String perfilCompartidas(int cantidad);

  /// No description provided for @perfilCuidado.
  ///
  /// In es, this message translates to:
  /// **'Con quién compartís el cuidado'**
  String get perfilCuidado;

  /// No description provided for @perfilSinHogar.
  ///
  /// In es, this message translates to:
  /// **'Por ahora cuidás solo/a. Podés invitar a tu familia desde «Mi hogar».'**
  String get perfilSinHogar;

  /// No description provided for @perfilVerHogar.
  ///
  /// In es, this message translates to:
  /// **'Ver «Mi hogar»'**
  String get perfilVerHogar;

  /// No description provided for @ajustesHogar.
  ///
  /// In es, this message translates to:
  /// **'Mi hogar'**
  String get ajustesHogar;

  /// No description provided for @ajustesHogarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Compartí tus mascotas con tu familia.'**
  String get ajustesHogarAyuda;

  /// No description provided for @tareasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tareas de hoy'**
  String get tareasTitulo;

  /// No description provided for @tareasVacio.
  ///
  /// In es, this message translates to:
  /// **'Repartan el paseo, la comida o el baño: cada uno ve qué le toca y quién lo hizo.'**
  String get tareasVacio;

  /// No description provided for @tareasAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get tareasAgregar;

  /// No description provided for @tareaNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get tareaNueva;

  /// No description provided for @tareaPaseo.
  ///
  /// In es, this message translates to:
  /// **'Paseo'**
  String get tareaPaseo;

  /// No description provided for @tareaComida.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get tareaComida;

  /// No description provided for @tareaBano.
  ///
  /// In es, this message translates to:
  /// **'Baño'**
  String get tareaBano;

  /// No description provided for @tareaVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Veterinaria'**
  String get tareaVeterinaria;

  /// No description provided for @tareaOtra.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get tareaOtra;

  /// No description provided for @tareaNota.
  ///
  /// In es, this message translates to:
  /// **'Detalle (opcional)'**
  String get tareaNota;

  /// No description provided for @tareaNotaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: a la plaza, media porción.'**
  String get tareaNotaAyuda;

  /// No description provided for @tareaCuando.
  ///
  /// In es, this message translates to:
  /// **'Cuándo'**
  String get tareaCuando;

  /// No description provided for @tareaHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get tareaHoy;

  /// No description provided for @tareaManana.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tareaManana;

  /// No description provided for @tareaAsignar.
  ///
  /// In es, this message translates to:
  /// **'Le toca a'**
  String get tareaAsignar;

  /// No description provided for @tareaNadie.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get tareaNadie;

  /// No description provided for @tareaLeToca.
  ///
  /// In es, this message translates to:
  /// **'Le toca a {nombre}'**
  String tareaLeToca(String nombre);

  /// No description provided for @tareaTeToca.
  ///
  /// In es, this message translates to:
  /// **'Te toca a vos'**
  String get tareaTeToca;

  /// No description provided for @tareaSinAsignar.
  ///
  /// In es, this message translates to:
  /// **'Cualquiera la puede hacer'**
  String get tareaSinAsignar;

  /// No description provided for @tareaHechaPor.
  ///
  /// In es, this message translates to:
  /// **'Hecha por {nombre} {cuando}'**
  String tareaHechaPor(String nombre, String cuando);

  /// No description provided for @tareaHechaPorVos.
  ///
  /// In es, this message translates to:
  /// **'La hiciste vos {cuando}'**
  String tareaHechaPorVos(String cuando);

  /// No description provided for @tareaMarcar.
  ///
  /// In es, this message translates to:
  /// **'Marcar hecha'**
  String get tareaMarcar;

  /// No description provided for @tareaDesmarcar.
  ///
  /// In es, this message translates to:
  /// **'Marcar pendiente'**
  String get tareaDesmarcar;

  /// No description provided for @tareaBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar tarea'**
  String get tareaBorrar;

  /// No description provided for @tareaCrear.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get tareaCrear;

  /// No description provided for @hogarInvitarCuidador.
  ///
  /// In es, this message translates to:
  /// **'Invitar a un cuidador temporal'**
  String get hogarInvitarCuidador;

  /// No description provided for @cuidadorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cuidador temporal'**
  String get cuidadorTitulo;

  /// No description provided for @cuidadorExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Para vacaciones o guardería: solo ve las mascotas que elijas y durante los días que digas. Después deja de verlas solo.'**
  String get cuidadorExplicacion;

  /// No description provided for @cuidadorMascotas.
  ///
  /// In es, this message translates to:
  /// **'Qué mascotas cuida'**
  String get cuidadorMascotas;

  /// No description provided for @cuidadorDias.
  ///
  /// In es, this message translates to:
  /// **'Durante'**
  String get cuidadorDias;

  /// No description provided for @cuidadorNDias.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{1 día} other{{dias} días}}'**
  String cuidadorNDias(int dias);

  /// No description provided for @cuidadorSinMascotas.
  ///
  /// In es, this message translates to:
  /// **'Primero cargá una mascota.'**
  String get cuidadorSinMascotas;

  /// No description provided for @cuidadorInvitar.
  ///
  /// In es, this message translates to:
  /// **'Crear invitación'**
  String get cuidadorInvitar;

  /// No description provided for @chatMensajes.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get chatMensajes;

  /// No description provided for @chatVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tenés conversaciones. Desde un reporte de mascota perdida o encontrada podés escribirle a quien lo publicó.'**
  String get chatVacio;

  /// No description provided for @chatFamiliaDe.
  ///
  /// In es, this message translates to:
  /// **'Familia de {nombre}'**
  String chatFamiliaDe(String nombre);

  /// No description provided for @chatFamiliaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Familia de la mascota perdida'**
  String get chatFamiliaSinNombre;

  /// No description provided for @chatQuienEncontro.
  ///
  /// In es, this message translates to:
  /// **'Quien la encontró'**
  String get chatQuienEncontro;

  /// No description provided for @chatSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Persona de SOS Mascota'**
  String get chatSinNombre;

  /// No description provided for @chatSobreReporte.
  ///
  /// In es, this message translates to:
  /// **'Sobre el reporte de {nombre}'**
  String chatSobreReporte(String nombre);

  /// No description provided for @chatEscribir.
  ///
  /// In es, this message translates to:
  /// **'Escribí un mensaje'**
  String get chatEscribir;

  /// No description provided for @chatEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get chatEnviar;

  /// No description provided for @chatFoto.
  ///
  /// In es, this message translates to:
  /// **'Mandar una foto'**
  String get chatFoto;

  /// No description provided for @chatUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Mandar mi ubicación'**
  String get chatUbicacion;

  /// No description provided for @chatUbicacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Mandar tu ubicación exacta?'**
  String get chatUbicacionTitulo;

  /// No description provided for @chatUbicacionTexto.
  ///
  /// In es, this message translates to:
  /// **'La otra persona va a ver en el mapa dónde estás ahora. Mandala solo si hace falta, por ejemplo para encontrarse con la mascota.'**
  String get chatUbicacionTexto;

  /// No description provided for @chatUbicacionMandar.
  ///
  /// In es, this message translates to:
  /// **'Mandar'**
  String get chatUbicacionMandar;

  /// No description provided for @chatUbicacionNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'No pudimos saber tu ubicación. Revisá los permisos del navegador.'**
  String get chatUbicacionNoDisponible;

  /// No description provided for @chatVerEnMapa.
  ///
  /// In es, this message translates to:
  /// **'Ver en el mapa'**
  String get chatVerEnMapa;

  /// No description provided for @chatEscribirPorChat.
  ///
  /// In es, this message translates to:
  /// **'Escribir por chat'**
  String get chatEscribirPorChat;

  /// No description provided for @chatSeguridad.
  ///
  /// In es, this message translates to:
  /// **'Seguridad: nunca pagues por adelantado ni pases códigos, contraseñas o datos de tarjetas. Si alguien pide plata para devolver una mascota, reportalo.'**
  String get chatSeguridad;

  /// No description provided for @chatPosibleEstafa.
  ///
  /// In es, this message translates to:
  /// **'Ojo: este mensaje habla de plata o códigos. Nunca pagues por adelantado.'**
  String get chatPosibleEstafa;

  /// No description provided for @chatBloquear.
  ///
  /// In es, this message translates to:
  /// **'Bloquear'**
  String get chatBloquear;

  /// No description provided for @chatDesbloquear.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get chatDesbloquear;

  /// No description provided for @chatBloquearTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Bloquear esta conversación?'**
  String get chatBloquearTitulo;

  /// No description provided for @chatBloquearTexto.
  ///
  /// In es, this message translates to:
  /// **'No van a poder escribirse más. Podés desbloquearla después.'**
  String get chatBloquearTexto;

  /// No description provided for @chatBloqueadaPorVos.
  ///
  /// In es, this message translates to:
  /// **'Bloqueaste esta conversación.'**
  String get chatBloqueadaPorVos;

  /// No description provided for @chatBloqueadaPorOtro.
  ///
  /// In es, this message translates to:
  /// **'Esta conversación ya no recibe mensajes.'**
  String get chatBloqueadaPorOtro;

  /// No description provided for @chatReportar.
  ///
  /// In es, this message translates to:
  /// **'Reportar mensaje'**
  String get chatReportar;

  /// No description provided for @chatReportado.
  ///
  /// In es, this message translates to:
  /// **'Gracias. Lo vamos a revisar.'**
  String get chatReportado;

  /// No description provided for @chatMotivoEstafa.
  ///
  /// In es, this message translates to:
  /// **'Me pide plata o datos'**
  String get chatMotivoEstafa;

  /// No description provided for @chatMotivoOfensivo.
  ///
  /// In es, this message translates to:
  /// **'Es ofensivo o me acosa'**
  String get chatMotivoOfensivo;

  /// No description provided for @chatMotivoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get chatMotivoOtro;

  /// No description provided for @chatNoPuedo.
  ///
  /// In es, this message translates to:
  /// **'Este reporte ya no está activo o es tuyo.'**
  String get chatNoPuedo;

  /// No description provided for @chatDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Abriste muchos chats hoy. Probá mañana.'**
  String get chatDemasiados;

  /// No description provided for @sosSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir este reporte'**
  String get sosSeguir;

  /// No description provided for @sosDejarDeSeguir.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir'**
  String get sosDejarDeSeguir;

  /// No description provided for @sosSiguiendo.
  ///
  /// In es, this message translates to:
  /// **'Te vamos a avisar cuando vuelva a casa.'**
  String get sosSiguiendo;

  /// No description provided for @catVeterinarias.
  ///
  /// In es, this message translates to:
  /// **'Veterinarias'**
  String get catVeterinarias;

  /// No description provided for @catPetshops.
  ///
  /// In es, this message translates to:
  /// **'Petshops'**
  String get catPetshops;

  /// No description provided for @catFarmacias.
  ///
  /// In es, this message translates to:
  /// **'Farmacias'**
  String get catFarmacias;

  /// No description provided for @catPeluquerias.
  ///
  /// In es, this message translates to:
  /// **'Peluquerías'**
  String get catPeluquerias;

  /// No description provided for @catPaseadores.
  ///
  /// In es, this message translates to:
  /// **'Paseadores'**
  String get catPaseadores;

  /// No description provided for @catHoteles.
  ///
  /// In es, this message translates to:
  /// **'Hoteles y guarderías'**
  String get catHoteles;

  /// No description provided for @catAdiestradores.
  ///
  /// In es, this message translates to:
  /// **'Adiestradores'**
  String get catAdiestradores;

  /// No description provided for @catAceptan.
  ///
  /// In es, this message translates to:
  /// **'Aceptan mascotas'**
  String get catAceptan;

  /// No description provided for @catRefugios.
  ///
  /// In es, this message translates to:
  /// **'Refugios'**
  String get catRefugios;

  /// No description provided for @catAgros.
  ///
  /// In es, this message translates to:
  /// **'Agropecuarias'**
  String get catAgros;

  /// No description provided for @catVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Veterinaria'**
  String get catVeterinaria;

  /// No description provided for @catPetshop.
  ///
  /// In es, this message translates to:
  /// **'Petshop'**
  String get catPetshop;

  /// No description provided for @catFarmacia.
  ///
  /// In es, this message translates to:
  /// **'Farmacia veterinaria'**
  String get catFarmacia;

  /// No description provided for @catPeluqueria.
  ///
  /// In es, this message translates to:
  /// **'Peluquería'**
  String get catPeluqueria;

  /// No description provided for @catPaseador.
  ///
  /// In es, this message translates to:
  /// **'Paseador'**
  String get catPaseador;

  /// No description provided for @catHotel.
  ///
  /// In es, this message translates to:
  /// **'Hotel o guardería'**
  String get catHotel;

  /// No description provided for @catAdiestrador.
  ///
  /// In es, this message translates to:
  /// **'Adiestrador'**
  String get catAdiestrador;

  /// No description provided for @catAcepta.
  ///
  /// In es, this message translates to:
  /// **'Acepta mascotas'**
  String get catAcepta;

  /// No description provided for @catRefugio.
  ///
  /// In es, this message translates to:
  /// **'Refugio'**
  String get catRefugio;

  /// No description provided for @catAgro.
  ///
  /// In es, this message translates to:
  /// **'Agropecuaria / agroveterinaria'**
  String get catAgro;

  /// No description provided for @mapaVistaMapa.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapaVistaMapa;

  /// No description provided for @mapaVistaLista.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get mapaVistaLista;

  /// No description provided for @mapaVistaSinLocal.
  ///
  /// In es, this message translates to:
  /// **'Sin local'**
  String get mapaVistaSinLocal;

  /// No description provided for @mapaPerdidos.
  ///
  /// In es, this message translates to:
  /// **'Perdidos y encontrados'**
  String get mapaPerdidos;

  /// No description provided for @mapaFiltros.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get mapaFiltros;

  /// No description provided for @mapaDistancia.
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get mapaDistancia;

  /// No description provided for @mapaDist300.
  ///
  /// In es, this message translates to:
  /// **'300 m'**
  String get mapaDist300;

  /// No description provided for @mapaDist800.
  ///
  /// In es, this message translates to:
  /// **'800 m'**
  String get mapaDist800;

  /// No description provided for @mapaDist2500.
  ///
  /// In es, this message translates to:
  /// **'2,5 km'**
  String get mapaDist2500;

  /// No description provided for @mapaDistTodo.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get mapaDistTodo;

  /// No description provided for @mapaAbiertoAhora.
  ///
  /// In es, this message translates to:
  /// **'Abierto ahora'**
  String get mapaAbiertoAhora;

  /// No description provided for @mapaSoloFavoritos.
  ///
  /// In es, this message translates to:
  /// **'Solo mis favoritos'**
  String get mapaSoloFavoritos;

  /// No description provided for @mapaGrupoSalud.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get mapaGrupoSalud;

  /// No description provided for @mapaGrupoTiendas.
  ///
  /// In es, this message translates to:
  /// **'Tiendas'**
  String get mapaGrupoTiendas;

  /// No description provided for @mapaGrupoCuidado.
  ///
  /// In es, this message translates to:
  /// **'Cuidado'**
  String get mapaGrupoCuidado;

  /// No description provided for @mapaGrupoSalidas.
  ///
  /// In es, this message translates to:
  /// **'Salidas'**
  String get mapaGrupoSalidas;

  /// No description provided for @mapaGrupoRefugios.
  ///
  /// In es, this message translates to:
  /// **'Refugios'**
  String get mapaGrupoRefugios;

  /// No description provided for @mapaGrupoQuitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get mapaGrupoQuitar;

  /// No description provided for @mapaGrupoParcial.
  ///
  /// In es, this message translates to:
  /// **'{grupo} · {cantidad}'**
  String mapaGrupoParcial(String grupo, int cantidad);

  /// No description provided for @leyendaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Referencias'**
  String get leyendaTitulo;

  /// No description provided for @leyendaMostrar.
  ///
  /// In es, this message translates to:
  /// **'Mostrar las referencias'**
  String get leyendaMostrar;

  /// No description provided for @leyendaOcultar.
  ///
  /// In es, this message translates to:
  /// **'Ocultar las referencias'**
  String get leyendaOcultar;

  /// No description provided for @mapaColocaMicrochip.
  ///
  /// In es, this message translates to:
  /// **'Coloca microchip (Operador RENAC)'**
  String get mapaColocaMicrochip;

  /// No description provided for @mapaEspecie.
  ///
  /// In es, this message translates to:
  /// **'Para qué mascota'**
  String get mapaEspecie;

  /// No description provided for @mapaEspecieActiva.
  ///
  /// In es, this message translates to:
  /// **'Para {nombre}'**
  String mapaEspecieActiva(String nombre);

  /// No description provided for @mapaEspecieActivaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Para mi mascota activa'**
  String get mapaEspecieActivaSinNombre;

  /// No description provided for @mapaEspecieTodas.
  ///
  /// In es, this message translates to:
  /// **'Para todas mis mascotas'**
  String get mapaEspecieTodas;

  /// No description provided for @mapaFiltrosLimpiar.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get mapaFiltrosLimpiar;

  /// No description provided for @mapaFiltrosListo.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get mapaFiltrosListo;

  /// No description provided for @mapaListaVacia.
  ///
  /// In es, this message translates to:
  /// **'No hay nada con estos filtros en esta zona. Mové el mapa o cambiá los filtros.'**
  String get mapaListaVacia;

  /// No description provided for @mapaSinLocalVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay tiendas online ni servicios a domicilio cargados.'**
  String get mapaSinLocalVacio;

  /// No description provided for @mapaA.
  ///
  /// In es, this message translates to:
  /// **'a {distancia}'**
  String mapaA(String distancia);

  /// No description provided for @modalidadOnline.
  ///
  /// In es, this message translates to:
  /// **'Tienda online'**
  String get modalidadOnline;

  /// No description provided for @modalidadDomicilio.
  ///
  /// In es, this message translates to:
  /// **'A domicilio'**
  String get modalidadDomicilio;

  /// No description provided for @leyendaComercio.
  ///
  /// In es, this message translates to:
  /// **'Comercios y servicios'**
  String get leyendaComercio;

  /// No description provided for @leyendaAcepta.
  ///
  /// In es, this message translates to:
  /// **'Aceptan mascotas'**
  String get leyendaAcepta;

  /// No description provided for @fichaFavorito.
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get fichaFavorito;

  /// No description provided for @fichaQuitarFavorito.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get fichaQuitarFavorito;

  /// No description provided for @fichaFui.
  ///
  /// In es, this message translates to:
  /// **'Fui'**
  String get fichaFui;

  /// No description provided for @fichaFuiEl.
  ///
  /// In es, this message translates to:
  /// **'Fuiste el {fecha}'**
  String fichaFuiEl(String fecha);

  /// No description provided for @fichaMiVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Es mi veterinaria'**
  String get fichaMiVeterinaria;

  /// No description provided for @fichaEsTuVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Tu veterinaria'**
  String get fichaEsTuVeterinaria;

  /// No description provided for @comercioRenac.
  ///
  /// In es, this message translates to:
  /// **'Operador RENAC · coloca microchip'**
  String get comercioRenac;

  /// No description provided for @marcarLugar.
  ///
  /// In es, this message translates to:
  /// **'Marcar un lugar'**
  String get marcarLugar;

  /// No description provided for @marcarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'¿Conocés un lugar que no está en el mapa? Elegí el rubro y tocá dónde queda. No hace falta el nombre: si varias personas lo marcan, se suma.'**
  String get marcarExplicacion;

  /// No description provided for @marcarRubro.
  ///
  /// In es, this message translates to:
  /// **'Rubro'**
  String get marcarRubro;

  /// No description provided for @marcarToca.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa donde queda el lugar.'**
  String get marcarToca;

  /// No description provided for @marcarEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enlace de Google Maps (opcional)'**
  String get marcarEnlace;

  /// No description provided for @marcarEnlaceAyuda.
  ///
  /// In es, this message translates to:
  /// **'Pegalo si lo tenés: ayuda a confirmar el lugar.'**
  String get marcarEnlaceAyuda;

  /// No description provided for @marcarGuardar.
  ///
  /// In es, this message translates to:
  /// **'Marcar'**
  String get marcarGuardar;

  /// No description provided for @marcarListo.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias! Quedó marcado.'**
  String get marcarListo;

  /// No description provided for @marcarYa.
  ///
  /// In es, this message translates to:
  /// **'Ya marcaste este lugar.'**
  String get marcarYa;

  /// No description provided for @marcarDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Marcaste muchos lugares hoy. Probá mañana.'**
  String get marcarDemasiados;

  /// No description provided for @marcarInvalido.
  ///
  /// In es, this message translates to:
  /// **'Revisá el enlace: tiene que ser de Google Maps.'**
  String get marcarInvalido;

  /// No description provided for @marcarFaltaPunto.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa para marcar dónde queda.'**
  String get marcarFaltaPunto;

  /// No description provided for @sinReclamarTitulo.
  ///
  /// In es, this message translates to:
  /// **'{rubro} sin reclamar'**
  String sinReclamarTitulo(String rubro);

  /// No description provided for @sinReclamarMarcas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Marcado por 1 persona} other{Marcado por {n} personas}}'**
  String sinReclamarMarcas(int n);

  /// No description provided for @sinReclamarEsTuyo.
  ///
  /// In es, this message translates to:
  /// **'¿Es tu negocio? Dalo de alta'**
  String get sinReclamarEsTuyo;

  /// No description provided for @sinReclamarVerGoogle.
  ///
  /// In es, this message translates to:
  /// **'Ver en Google Maps'**
  String get sinReclamarVerGoogle;

  /// No description provided for @leyendaSinReclamar.
  ///
  /// In es, this message translates to:
  /// **'Sin reclamar'**
  String get leyendaSinReclamar;

  /// No description provided for @reclamarEsTuyo.
  ///
  /// In es, this message translates to:
  /// **'¿Es tu negocio? Reclamalo'**
  String get reclamarEsTuyo;

  /// No description provided for @reclamarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reclamar este lugar'**
  String get reclamarTitulo;

  /// No description provided for @reclamarTexto.
  ///
  /// In es, this message translates to:
  /// **'Contanos que es tuyo. Para la insignia ✔️ el equipo valida el RUT. Si ya tiene a alguien a cargo, se revisa como disputa.'**
  String get reclamarTexto;

  /// No description provided for @reclamarRut.
  ///
  /// In es, this message translates to:
  /// **'RUT (12 números)'**
  String get reclamarRut;

  /// No description provided for @reclamarRutInvalido.
  ///
  /// In es, this message translates to:
  /// **'El RUT tiene 12 números.'**
  String get reclamarRutInvalido;

  /// No description provided for @reclamarNota.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo lo podemos comprobar? (opcional)'**
  String get reclamarNota;

  /// No description provided for @reclamarEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar reclamo'**
  String get reclamarEnviar;

  /// No description provided for @reclamarListo.
  ///
  /// In es, this message translates to:
  /// **'Recibimos tu reclamo. Te avisamos cuando lo revisemos.'**
  String get reclamarListo;

  /// No description provided for @fichaPromo.
  ///
  /// In es, this message translates to:
  /// **'Promoción'**
  String get fichaPromo;

  /// No description provided for @fichaFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook'**
  String get fichaFacebook;

  /// No description provided for @fichaCobertura.
  ///
  /// In es, this message translates to:
  /// **'Trabaja en: {zona}'**
  String fichaCobertura(String zona);

  /// No description provided for @negocioMi.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio'**
  String get negocioMi;

  /// No description provided for @negocioMiAyuda.
  ///
  /// In es, this message translates to:
  /// **'Sumá tu comercio o servicio al mapa (gratis).'**
  String get negocioMiAyuda;

  /// No description provided for @negocioAltaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sumar mi negocio'**
  String get negocioAltaTitulo;

  /// No description provided for @negocioAltaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Aparece al instante en el mapa como «no verificado». Para la insignia ✔️ pedís la verificación con tu RUT.'**
  String get negocioAltaExplicacion;

  /// No description provided for @negocioNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio'**
  String get negocioNombre;

  /// No description provided for @negocioNombreFalta.
  ///
  /// In es, this message translates to:
  /// **'Escribí el nombre (2 letras o más).'**
  String get negocioNombreFalta;

  /// No description provided for @negocioModalidad.
  ///
  /// In es, this message translates to:
  /// **'Cómo atendés'**
  String get negocioModalidad;

  /// No description provided for @negocioModalidadLocal.
  ///
  /// In es, this message translates to:
  /// **'Con local'**
  String get negocioModalidadLocal;

  /// No description provided for @negocioModalidadOnline.
  ///
  /// In es, this message translates to:
  /// **'Online'**
  String get negocioModalidadOnline;

  /// No description provided for @negocioModalidadDomicilio.
  ///
  /// In es, this message translates to:
  /// **'A domicilio'**
  String get negocioModalidadDomicilio;

  /// No description provided for @negocioUbicacionToca.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa donde está tu local.'**
  String get negocioUbicacionToca;

  /// No description provided for @negocioCobertura.
  ///
  /// In es, this message translates to:
  /// **'Zona donde trabajás'**
  String get negocioCobertura;

  /// No description provided for @negocioCoberturaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Pando y alrededores.'**
  String get negocioCoberturaAyuda;

  /// No description provided for @negocioTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get negocioTelefono;

  /// No description provided for @negocioWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp (opcional)'**
  String get negocioWhatsapp;

  /// No description provided for @negocioDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get negocioDescripcion;

  /// No description provided for @negocioWeb.
  ///
  /// In es, this message translates to:
  /// **'Web (https://…)'**
  String get negocioWeb;

  /// No description provided for @negocioInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram (sin @)'**
  String get negocioInstagram;

  /// No description provided for @negocioFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook (opcional)'**
  String get negocioFacebook;

  /// No description provided for @negocioCrear.
  ///
  /// In es, this message translates to:
  /// **'Sumar al mapa'**
  String get negocioCrear;

  /// No description provided for @negocioCreado.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Tu negocio ya está en el mapa.'**
  String get negocioCreado;

  /// No description provided for @negocioFaltaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa para marcar dónde está.'**
  String get negocioFaltaUbicacion;

  /// No description provided for @negocioDatosInvalidos.
  ///
  /// In es, this message translates to:
  /// **'Revisá los datos (teléfono, web o Instagram).'**
  String get negocioDatosInvalidos;

  /// No description provided for @modoComercio.
  ///
  /// In es, this message translates to:
  /// **'Modo comercio'**
  String get modoComercio;

  /// No description provided for @volverModoDueno.
  ///
  /// In es, this message translates to:
  /// **'Volver al modo dueño'**
  String get volverModoDueno;

  /// No description provided for @negocioPanel.
  ///
  /// In es, this message translates to:
  /// **'Panel'**
  String get negocioPanel;

  /// No description provided for @negocioAgenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get negocioAgenda;

  /// No description provided for @negocioCatalogo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get negocioCatalogo;

  /// No description provided for @negocioPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get negocioPedidos;

  /// No description provided for @negocioFicha.
  ///
  /// In es, this message translates to:
  /// **'Negocio'**
  String get negocioFicha;

  /// No description provided for @moduloNoAplica.
  ///
  /// In es, this message translates to:
  /// **'No aplica para tu tipo de negocio.'**
  String get moduloNoAplica;

  /// No description provided for @moduloSoloPlus.
  ///
  /// In es, this message translates to:
  /// **'Llega con el plan Plus (Fase 3).'**
  String get moduloSoloPlus;

  /// No description provided for @planBasico.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get planBasico;

  /// No description provided for @planDestacado.
  ///
  /// In es, this message translates to:
  /// **'Destacado'**
  String get planDestacado;

  /// No description provided for @planPlus.
  ///
  /// In es, this message translates to:
  /// **'Plus'**
  String get planPlus;

  /// No description provided for @verifNo.
  ///
  /// In es, this message translates to:
  /// **'No verificado'**
  String get verifNo;

  /// No description provided for @verifPendiente.
  ///
  /// In es, this message translates to:
  /// **'Verificación pendiente'**
  String get verifPendiente;

  /// No description provided for @verifSi.
  ///
  /// In es, this message translates to:
  /// **'Verificado ✔️'**
  String get verifSi;

  /// No description provided for @socioFundadorHasta.
  ///
  /// In es, this message translates to:
  /// **'Socio Fundador hasta el {fecha}'**
  String socioFundadorHasta(String fecha);

  /// No description provided for @panelAperturas.
  ///
  /// In es, this message translates to:
  /// **'Aperturas de tu ficha'**
  String get panelAperturas;

  /// No description provided for @panelAntes.
  ///
  /// In es, this message translates to:
  /// **'{n} en los 30 días anteriores'**
  String panelAntes(int n);

  /// No description provided for @panelContactos.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get panelContactos;

  /// No description provided for @panelFavoritos.
  ///
  /// In es, this message translates to:
  /// **'Te guardaron en favoritos'**
  String get panelFavoritos;

  /// No description provided for @panelVisitas.
  ///
  /// In es, this message translates to:
  /// **'Dijeron «Fui»'**
  String get panelVisitas;

  /// No description provided for @panelSocios.
  ///
  /// In es, this message translates to:
  /// **'Te eligieron como su veterinaria'**
  String get panelSocios;

  /// No description provided for @panelUltimos30.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get panelUltimos30;

  /// No description provided for @panelSinContactos.
  ///
  /// In es, this message translates to:
  /// **'Todavía nadie tocó un contacto.'**
  String get panelSinContactos;

  /// No description provided for @clicLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get clicLlamar;

  /// No description provided for @clicWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get clicWhatsapp;

  /// No description provided for @clicComoLlegar.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get clicComoLlegar;

  /// No description provided for @clicWeb.
  ///
  /// In es, this message translates to:
  /// **'Web'**
  String get clicWeb;

  /// No description provided for @clicInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram'**
  String get clicInstagram;

  /// No description provided for @negocioGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get negocioGuardar;

  /// No description provided for @negocioGuardado.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get negocioGuardado;

  /// No description provided for @negocioVisible.
  ///
  /// In es, this message translates to:
  /// **'Visible en el mapa'**
  String get negocioVisible;

  /// No description provided for @negocioPromo.
  ///
  /// In es, this message translates to:
  /// **'Promoción'**
  String get negocioPromo;

  /// No description provided for @negocioPromoSoloPago.
  ///
  /// In es, this message translates to:
  /// **'La promoción se muestra con los planes Destacado y Plus.'**
  String get negocioPromoSoloPago;

  /// No description provided for @negocioFotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get negocioFotos;

  /// No description provided for @negocioAgregarFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get negocioAgregarFoto;

  /// No description provided for @negocioFotosTope.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de fotos de tu plan.'**
  String get negocioFotosTope;

  /// No description provided for @negocioQuitarFoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get negocioQuitarFoto;

  /// No description provided for @negocioPedirVerificacion.
  ///
  /// In es, this message translates to:
  /// **'Pedir la insignia ✔️'**
  String get negocioPedirVerificacion;

  /// No description provided for @negocioPedirVerificacionTexto.
  ///
  /// In es, this message translates to:
  /// **'Ingresá el RUT del negocio. El equipo lo valida y te avisa.'**
  String get negocioPedirVerificacionTexto;

  /// No description provided for @negocioVerificacionPedida.
  ///
  /// In es, this message translates to:
  /// **'Pedido enviado. Te avisamos cuando lo revisemos.'**
  String get negocioVerificacionPedida;

  /// No description provided for @negocioPedirRenac.
  ///
  /// In es, this message translates to:
  /// **'Pedir la insignia Operador RENAC'**
  String get negocioPedirRenac;

  /// No description provided for @negocioRenacTexto.
  ///
  /// In es, this message translates to:
  /// **'Si colocás microchip y estás en el listado oficial del MGAP, aparece la insignia y el filtro «Coloca microchip».'**
  String get negocioRenacTexto;

  /// No description provided for @negocioRenacPedido.
  ///
  /// In es, this message translates to:
  /// **'Insignia RENAC pedida.'**
  String get negocioRenacPedido;

  /// No description provided for @negocioHorario.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get negocioHorario;

  /// No description provided for @negocioCerrado.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get negocioCerrado;

  /// No description provided for @negocio24h.
  ///
  /// In es, this message translates to:
  /// **'Abierto 24 h'**
  String get negocio24h;

  /// No description provided for @negocioUrgencias.
  ///
  /// In es, this message translates to:
  /// **'Atiende urgencias'**
  String get negocioUrgencias;

  /// No description provided for @negocioDe.
  ///
  /// In es, this message translates to:
  /// **'De {desde} a {hasta}'**
  String negocioDe(String desde, String hasta);

  /// No description provided for @negocioEspecies.
  ///
  /// In es, this message translates to:
  /// **'Especies que atendés'**
  String get negocioEspecies;

  /// No description provided for @negocioEspeciesAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si no elegís ninguna, se entiende que atendés a todas.'**
  String get negocioEspeciesAyuda;

  /// No description provided for @negocioOtro.
  ///
  /// In es, this message translates to:
  /// **'Sumar otro negocio'**
  String get negocioOtro;

  /// No description provided for @negocioDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección (opcional)'**
  String get negocioDireccion;

  /// No description provided for @resenasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reseñas'**
  String get resenasTitulo;

  /// No description provided for @resenasVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tiene reseñas.'**
  String get resenasVacio;

  /// No description provided for @resenasPromedio.
  ///
  /// In es, this message translates to:
  /// **'{promedio} ★ · {n, plural, =1{1 reseña} other{{n} reseñas}}'**
  String resenasPromedio(String promedio, int n);

  /// No description provided for @resenaEscribir.
  ///
  /// In es, this message translates to:
  /// **'Escribir una reseña'**
  String get resenaEscribir;

  /// No description provided for @resenaEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar mi reseña'**
  String get resenaEditar;

  /// No description provided for @resenaSoloConContacto.
  ///
  /// In es, this message translates to:
  /// **'Podés dejar una reseña después de escribirle, llamar o ir.'**
  String get resenaSoloConContacto;

  /// No description provided for @resenaEstrellas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 estrella} other{{n} estrellas}}'**
  String resenaEstrellas(int n);

  /// No description provided for @resenaComentario.
  ///
  /// In es, this message translates to:
  /// **'Contá cómo te fue (opcional)'**
  String get resenaComentario;

  /// No description provided for @resenaPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get resenaPublicar;

  /// No description provided for @resenaPublicada.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu reseña!'**
  String get resenaPublicada;

  /// No description provided for @resenaRespuesta.
  ///
  /// In es, this message translates to:
  /// **'Respuesta del comercio'**
  String get resenaRespuesta;

  /// No description provided for @resenaResponder.
  ///
  /// In es, this message translates to:
  /// **'Responder'**
  String get resenaResponder;

  /// No description provided for @resenaRespuestaCampo.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta (es pública y se puede dar una sola vez)'**
  String get resenaRespuestaCampo;

  /// No description provided for @resenaRespondida.
  ///
  /// In es, this message translates to:
  /// **'Respuesta publicada.'**
  String get resenaRespondida;

  /// No description provided for @resenaReportar.
  ///
  /// In es, this message translates to:
  /// **'Reportar reseña'**
  String get resenaReportar;

  /// No description provided for @resenaReportada.
  ///
  /// In es, this message translates to:
  /// **'Gracias. La vamos a revisar.'**
  String get resenaReportada;

  /// No description provided for @resenaMia.
  ///
  /// In es, this message translates to:
  /// **'Tu reseña'**
  String get resenaMia;

  /// No description provided for @resenaDe.
  ///
  /// In es, this message translates to:
  /// **'{autor}'**
  String resenaDe(String autor);

  /// No description provided for @fichaEscribirChat.
  ///
  /// In es, this message translates to:
  /// **'Escribir por chat'**
  String get fichaEscribirChat;

  /// No description provided for @panelResenas.
  ///
  /// In es, this message translates to:
  /// **'Reseñas'**
  String get panelResenas;

  /// No description provided for @panelPromedio.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get panelPromedio;

  /// No description provided for @panelSinResponder.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Todas respondidas} =1{1 sin responder} other{{n} sin responder}}'**
  String panelSinResponder(int n);

  /// No description provided for @panelChats.
  ///
  /// In es, this message translates to:
  /// **'Chats nuevos'**
  String get panelChats;

  /// No description provided for @adopcionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Adopción responsable'**
  String get adopcionTitulo;

  /// No description provided for @catalogoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo'**
  String get catalogoTitulo;

  /// No description provided for @catalogoVacio.
  ///
  /// In es, this message translates to:
  /// **'Este comercio todavía no cargó productos.'**
  String get catalogoVacio;

  /// No description provided for @catalogoPagoDirecto.
  ///
  /// In es, this message translates to:
  /// **'El pago y la entrega los arreglás directo con el comercio.'**
  String get catalogoPagoDirecto;

  /// No description provided for @catalogoVerPedido.
  ///
  /// In es, this message translates to:
  /// **'Ver pedido · {cantidad} · {total}'**
  String catalogoVerPedido(int cantidad, String total);

  /// No description provided for @catalogoConsultaTexto.
  ///
  /// In es, this message translates to:
  /// **'Hola, te escribo desde SOS Mascota. Quería consultar por: {producto}'**
  String catalogoConsultaTexto(String producto);

  /// No description provided for @catalogoSinContacto.
  ///
  /// In es, this message translates to:
  /// **'Este comercio no dejó cómo contactarlo.'**
  String get catalogoSinContacto;

  /// No description provided for @catalogoConsultarPrecio.
  ///
  /// In es, this message translates to:
  /// **'Consultar precio'**
  String get catalogoConsultarPrecio;

  /// No description provided for @catalogoConsultar.
  ///
  /// In es, this message translates to:
  /// **'Consultar'**
  String get catalogoConsultar;

  /// No description provided for @catalogoAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get catalogoAgregar;

  /// No description provided for @catalogoQuitarUno.
  ///
  /// In es, this message translates to:
  /// **'Quitar uno'**
  String get catalogoQuitarUno;

  /// No description provided for @catalogoSumarUno.
  ///
  /// In es, this message translates to:
  /// **'Sumar uno'**
  String get catalogoSumarUno;

  /// No description provided for @catalogoVer.
  ///
  /// In es, this message translates to:
  /// **'Ver catálogo ({cantidad})'**
  String catalogoVer(int cantidad);

  /// No description provided for @catalogoPrender.
  ///
  /// In es, this message translates to:
  /// **'Catálogo y pedidos'**
  String get catalogoPrender;

  /// No description provided for @catalogoPrendidoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Prendido: tus productos se ven en tu ficha y te pueden hacer pedidos.'**
  String get catalogoPrendidoAyuda;

  /// No description provided for @catalogoApagadoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Apagado: podés cargar productos; nadie los ve hasta que lo prendas.'**
  String get catalogoApagadoAyuda;

  /// No description provided for @catalogoSinProductos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaste productos. Tocá «Agregar producto».'**
  String get catalogoSinProductos;

  /// No description provided for @pedidoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu pedido'**
  String get pedidoTitulo;

  /// No description provided for @pedidoTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get pedidoTotal;

  /// No description provided for @pedidoNota.
  ///
  /// In es, this message translates to:
  /// **'Nota para el comercio (opcional)'**
  String get pedidoNota;

  /// No description provided for @pedidoNotaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: paso a retirarlo a las 18'**
  String get pedidoNotaAyuda;

  /// No description provided for @pedidoHacer.
  ///
  /// In es, this message translates to:
  /// **'Hacer pedido'**
  String get pedidoHacer;

  /// No description provided for @pedidoIngresar.
  ///
  /// In es, this message translates to:
  /// **'Ingresá para hacer el pedido'**
  String get pedidoIngresar;

  /// No description provided for @pedidoHecho.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! El comercio recibió tu pedido.'**
  String get pedidoHecho;

  /// No description provided for @pedidoDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Hiciste muchos pedidos hoy. Probá mañana.'**
  String get pedidoDemasiados;

  /// No description provided for @pedidoCambio.
  ///
  /// In es, this message translates to:
  /// **'Algún producto cambió o ya no está. Revisá el catálogo y probá de nuevo.'**
  String get pedidoCambio;

  /// No description provided for @pedidoSinModulo.
  ///
  /// In es, this message translates to:
  /// **'Este comercio ya no está tomando pedidos.'**
  String get pedidoSinModulo;

  /// No description provided for @pedidoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get pedidoNuevo;

  /// No description provided for @pedidoPreparando.
  ///
  /// In es, this message translates to:
  /// **'Preparando'**
  String get pedidoPreparando;

  /// No description provided for @pedidoListo.
  ///
  /// In es, this message translates to:
  /// **'Listo para retirar'**
  String get pedidoListo;

  /// No description provided for @pedidoEntregado.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get pedidoEntregado;

  /// No description provided for @pedidoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get pedidoCancelado;

  /// No description provided for @pedidoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar pedido'**
  String get pedidoCancelar;

  /// No description provided for @pedidoNumero.
  ///
  /// In es, this message translates to:
  /// **'Pedido #{numero}'**
  String pedidoNumero(int numero);

  /// No description provided for @pedidoNotaDe.
  ///
  /// In es, this message translates to:
  /// **'Nota: {nota}'**
  String pedidoNotaDe(String nota);

  /// No description provided for @pedidoPasarA.
  ///
  /// In es, this message translates to:
  /// **'Pasar a «{estado}»'**
  String pedidoPasarA(String estado);

  /// No description provided for @misPedidos.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get misPedidos;

  /// No description provided for @misPedidosAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lo que pediste a los comercios y en qué estado está.'**
  String get misPedidosAyuda;

  /// No description provided for @misPedidosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hiciste pedidos. Los comercios con catálogo tienen el botón «Ver catálogo» en su ficha.'**
  String get misPedidosVacio;

  /// No description provided for @pedidosNegocioVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no te hicieron pedidos.'**
  String get pedidosNegocioVacio;

  /// No description provided for @pagoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get pagoTitulo;

  /// No description provided for @pagoEfectivo.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get pagoEfectivo;

  /// No description provided for @pagoTransferencia.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get pagoTransferencia;

  /// No description provided for @pagoTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Débito o crédito'**
  String get pagoTarjeta;

  /// No description provided for @pagoMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago'**
  String get pagoMercadoPago;

  /// No description provided for @entregaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get entregaTitulo;

  /// No description provided for @entregaRetiro.
  ///
  /// In es, this message translates to:
  /// **'Retiro en el local'**
  String get entregaRetiro;

  /// No description provided for @entregaEnvio.
  ///
  /// In es, this message translates to:
  /// **'Envío a domicilio'**
  String get entregaEnvio;

  /// No description provided for @pedidoSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get pedidoSubtotal;

  /// No description provided for @pedidoEnvio.
  ///
  /// In es, this message translates to:
  /// **'Envío'**
  String get pedidoEnvio;

  /// No description provided for @pedidoEnvioGratis.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get pedidoEnvioGratis;

  /// No description provided for @pedidoDireccionAyuda.
  ///
  /// In es, this message translates to:
  /// **'La dirección se la pasás directo al comercio: no la guardamos en la app.'**
  String get pedidoDireccionAyuda;

  /// No description provided for @pedidoElegiPagoYEntrega.
  ///
  /// In es, this message translates to:
  /// **'Elegí la forma de pago y la entrega.'**
  String get pedidoElegiPagoYEntrega;

  /// No description provided for @pedidoEnviarWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Enviar pedido por WhatsApp'**
  String get pedidoEnviarWhatsapp;

  /// No description provided for @pedidoGuardadoWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Ahora mandale el mensaje al comercio por WhatsApp para que lo vea enseguida. También le queda en la app.'**
  String get pedidoGuardadoWhatsapp;

  /// No description provided for @pedidoAbrirWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Abrir WhatsApp'**
  String get pedidoAbrirWhatsapp;

  /// No description provided for @pedidoAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get pedidoAhoraNo;

  /// No description provided for @pedidoMensajeDireccion.
  ///
  /// In es, this message translates to:
  /// **'Te paso la dirección por acá.'**
  String get pedidoMensajeDireccion;

  /// No description provided for @condicionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cómo cobrás y entregás'**
  String get condicionesTitulo;

  /// No description provided for @condicionesSinConfigurar.
  ///
  /// In es, this message translates to:
  /// **'Sin configurar: quien pide arregla el pago y la entrega con vos.'**
  String get condicionesSinConfigurar;

  /// No description provided for @condicionesPagos.
  ///
  /// In es, this message translates to:
  /// **'Formas de pago que aceptás'**
  String get condicionesPagos;

  /// No description provided for @condicionesRetiro.
  ///
  /// In es, this message translates to:
  /// **'Retiro en el local'**
  String get condicionesRetiro;

  /// No description provided for @condicionesEnvio.
  ///
  /// In es, this message translates to:
  /// **'Hacés envíos'**
  String get condicionesEnvio;

  /// No description provided for @condicionesCosto.
  ///
  /// In es, this message translates to:
  /// **'Costo del envío'**
  String get condicionesCosto;

  /// No description provided for @condicionesCostoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Vacío o 0: envío gratis.'**
  String get condicionesCostoAyuda;

  /// No description provided for @condicionesGratisDesde.
  ///
  /// In es, this message translates to:
  /// **'Envío gratis desde (opcional)'**
  String get condicionesGratisDesde;

  /// No description provided for @condicionesUnaEntrega.
  ///
  /// In es, this message translates to:
  /// **'Elegí al menos retiro o envío.'**
  String get condicionesUnaEntrega;

  /// No description provided for @condicionesMontosInvalidos.
  ///
  /// In es, this message translates to:
  /// **'Revisá los montos.'**
  String get condicionesMontosInvalidos;

  /// No description provided for @condicionesEnvioGratis.
  ///
  /// In es, this message translates to:
  /// **'Envío gratis'**
  String get condicionesEnvioGratis;

  /// No description provided for @pedidoEnvioGratisDesde.
  ///
  /// In es, this message translates to:
  /// **'Envío gratis desde {monto}'**
  String pedidoEnvioGratisDesde(String monto);

  /// No description provided for @pedidoGuardadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¡Pedido #{numero} guardado!'**
  String pedidoGuardadoTitulo(int numero);

  /// No description provided for @pedidoMensajeSaludo.
  ///
  /// In es, this message translates to:
  /// **'Hola, te hago un pedido desde SOS Mascota (#{numero}):'**
  String pedidoMensajeSaludo(int numero);

  /// No description provided for @pedidoMensajeRenglon.
  ///
  /// In es, this message translates to:
  /// **'• {cantidad} × {producto} — {precio}'**
  String pedidoMensajeRenglon(int cantidad, String producto, String precio);

  /// No description provided for @pedidoMensajeTotales.
  ///
  /// In es, this message translates to:
  /// **'Subtotal: {subtotal} · Envío: {envio} · Total: {total}'**
  String pedidoMensajeTotales(String subtotal, String envio, String total);

  /// No description provided for @pedidoMensajeTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: {total}'**
  String pedidoMensajeTotal(String total);

  /// No description provided for @pedidoMensajePago.
  ///
  /// In es, this message translates to:
  /// **'Pago: {pago}'**
  String pedidoMensajePago(String pago);

  /// No description provided for @pedidoMensajeEntrega.
  ///
  /// In es, this message translates to:
  /// **'Entrega: {entrega}'**
  String pedidoMensajeEntrega(String entrega);

  /// No description provided for @condicionesEnvioCosto.
  ///
  /// In es, this message translates to:
  /// **'Envío {costo}'**
  String condicionesEnvioCosto(String costo);

  /// No description provided for @productoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get productoNuevo;

  /// No description provided for @productoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get productoEditar;

  /// No description provided for @productoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get productoNombre;

  /// No description provided for @productoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get productoDescripcion;

  /// No description provided for @productoPrecio.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get productoPrecio;

  /// No description provided for @productoPrecioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Vacío: se muestra «Consultar precio» y no se puede pedir.'**
  String get productoPrecioAyuda;

  /// No description provided for @productoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get productoDisponible;

  /// No description provided for @productoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get productoNoDisponible;

  /// No description provided for @productoFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get productoFoto;

  /// No description provided for @productoCambiarFoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get productoCambiarFoto;

  /// No description provided for @productoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get productoBorrar;

  /// No description provided for @productoDatosInvalidos.
  ///
  /// In es, this message translates to:
  /// **'Revisá el nombre (2 letras o más) y el precio.'**
  String get productoDatosInvalidos;

  /// No description provided for @productoLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de 200 productos.'**
  String get productoLimite;

  /// No description provided for @serviciosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get serviciosTitulo;

  /// No description provided for @paginaCompartir.
  ///
  /// In es, this message translates to:
  /// **'Compartir mi página'**
  String get paginaCompartir;

  /// No description provided for @paginaCompartirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tu página con fotos, servicios, productos y horario, para poner en Instagram, Facebook o WhatsApp.'**
  String get paginaCompartirAyuda;

  /// No description provided for @paginaEnlaceCopiado.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado: pegalo en tus redes o en WhatsApp.'**
  String get paginaEnlaceCopiado;

  /// No description provided for @paginaVer.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get paginaVer;

  /// No description provided for @serviciosAbrir.
  ///
  /// In es, this message translates to:
  /// **'Tus servicios'**
  String get serviciosAbrir;

  /// No description provided for @serviciosAbrirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Baño, consulta, paseo… con precio o «Consultar precio».'**
  String get serviciosAbrirAyuda;

  /// No description provided for @serviciosAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lo que cargues acá se ve en tu ficha, con «Consultar». Si tu plan deja de ser Plus, se ocultan (no se borran).'**
  String get serviciosAyuda;

  /// No description provided for @serviciosSoloPlus.
  ///
  /// In es, this message translates to:
  /// **'Los servicios se publican con el plan Plus.'**
  String get serviciosSoloPlus;

  /// No description provided for @serviciosSinCargar.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaste servicios. Tocá «Agregar servicio».'**
  String get serviciosSinCargar;

  /// No description provided for @servicioNuevo.
  ///
  /// In es, this message translates to:
  /// **'Agregar servicio'**
  String get servicioNuevo;

  /// No description provided for @servicioEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar servicio'**
  String get servicioEditar;

  /// No description provided for @servicioNombreAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: Baño y corte'**
  String get servicioNombreAyuda;

  /// No description provided for @servicioPrecioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Vacío: se muestra «Consultar precio».'**
  String get servicioPrecioAyuda;

  /// No description provided for @servicioPrecioDesde.
  ///
  /// In es, this message translates to:
  /// **'Es un precio «desde» (cambia según el caso)'**
  String get servicioPrecioDesde;

  /// No description provided for @servicioDuracion.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get servicioDuracion;

  /// No description provided for @servicioSinDuracion.
  ///
  /// In es, this message translates to:
  /// **'Sin indicar'**
  String get servicioSinDuracion;

  /// No description provided for @servicioVisible.
  ///
  /// In es, this message translates to:
  /// **'Se ve en mi ficha'**
  String get servicioVisible;

  /// No description provided for @servicioOculto.
  ///
  /// In es, this message translates to:
  /// **'Oculto'**
  String get servicioOculto;

  /// No description provided for @servicioLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de 50 servicios.'**
  String get servicioLimite;

  /// No description provided for @servicioDesde.
  ///
  /// In es, this message translates to:
  /// **'desde {precio}'**
  String servicioDesde(String precio);

  /// No description provided for @duracionMinutos.
  ///
  /// In es, this message translates to:
  /// **'{minutos} min'**
  String duracionMinutos(int minutos);

  /// No description provided for @duracionHoras.
  ///
  /// In es, this message translates to:
  /// **'{horas} h'**
  String duracionHoras(int horas);

  /// No description provided for @duracionHorasMinutos.
  ///
  /// In es, this message translates to:
  /// **'{horas} h {minutos} min'**
  String duracionHorasMinutos(int horas, int minutos);

  /// No description provided for @noticiasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get noticiasTitulo;

  /// No description provided for @noticiasEntradaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Novedades, campañas y consejos para tus mascotas.'**
  String get noticiasEntradaAyuda;

  /// No description provided for @noticiasTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get noticiasTodas;

  /// No description provided for @noticiasVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay noticias para mostrarte.'**
  String get noticiasVacio;

  /// No description provided for @noticiasLeerMas.
  ///
  /// In es, this message translates to:
  /// **'Leer más'**
  String get noticiasLeerMas;

  /// No description provided for @noticiasPromocionado.
  ///
  /// In es, this message translates to:
  /// **'Promocionado · {marca}'**
  String noticiasPromocionado(String marca);

  /// No description provided for @noticiasSeccionNoticias.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get noticiasSeccionNoticias;

  /// No description provided for @noticiasSeccionComunidad.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get noticiasSeccionComunidad;

  /// No description provided for @comunidadExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Se arma sola con lo que pasa en la app. Nunca mostramos ubicaciones ni datos de personas.'**
  String get comunidadExplicacion;

  /// No description provided for @comunidadVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay novedades. Cuando una mascota vuelva a casa o haya un evento cerca, lo vas a ver acá.'**
  String get comunidadVacio;

  /// No description provided for @comunidadResumenTitulo.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días en la comunidad'**
  String get comunidadResumenTitulo;

  /// No description provided for @comunidadResumenReencuentros.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 mascota volvió a casa} other{{n} mascotas volvieron a casa}}'**
  String comunidadResumenReencuentros(int n);

  /// No description provided for @comunidadResumenAdopciones.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 adopción concretada} other{{n} adopciones concretadas}}'**
  String comunidadResumenAdopciones(int n);

  /// No description provided for @comunidadResumenPerdidas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 mascota perdida sigue buscando su casa} other{{n} mascotas perdidas siguen buscando su casa}}'**
  String comunidadResumenPerdidas(int n);

  /// No description provided for @comunidadResumenLugares.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 lugar verificado en el mapa} other{{n} lugares verificados en el mapa}}'**
  String comunidadResumenLugares(int n);

  /// No description provided for @comunidadVolvioACasa.
  ///
  /// In es, this message translates to:
  /// **'¡{nombre} volvió a casa! 🎉'**
  String comunidadVolvioACasa(String nombre);

  /// No description provided for @comunidadVolvioACasaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'¡Una mascota perdida volvió a casa! 🎉'**
  String get comunidadVolvioACasaSinNombre;

  /// No description provided for @comunidadDiasPerdida.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =0{La encontraron el mismo día.} =1{Estuvo 1 día perdida.} other{Estuvo {dias} días perdida.}}'**
  String comunidadDiasPerdida(int dias);

  /// No description provided for @comunidadVolvioConSuFamilia.
  ///
  /// In es, this message translates to:
  /// **'¡{nombre} volvió con su familia! 🏡'**
  String comunidadVolvioConSuFamilia(String nombre);

  /// No description provided for @comunidadVolvioConSuFamiliaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Una mascota encontrada volvió con su familia 🏡'**
  String get comunidadVolvioConSuFamiliaSinNombre;

  /// No description provided for @comunidadGracias.
  ///
  /// In es, this message translates to:
  /// **'Gracias a todos los que ayudaron a difundir.'**
  String get comunidadGracias;

  /// No description provided for @comunidadAdoptado.
  ///
  /// In es, this message translates to:
  /// **'¡{nombre} encontró un hogar! 💛'**
  String comunidadAdoptado(String nombre);

  /// No description provided for @comunidadAdoptados.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Una mascota encontró un hogar 💛} other{{n} mascotas encontraron un hogar 💛}}'**
  String comunidadAdoptados(int n);

  /// No description provided for @comunidadAdopcionDetalle.
  ///
  /// In es, this message translates to:
  /// **'Adopción responsable en SOS Mascota.'**
  String get comunidadAdopcionDetalle;

  /// No description provided for @comunidadLugarNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo lugar verificado: {nombre}'**
  String comunidadLugarNuevo(String nombre);

  /// No description provided for @comunidadEvento.
  ///
  /// In es, this message translates to:
  /// **'Evento: {nombre}'**
  String comunidadEvento(String nombre);

  /// No description provided for @comunidadCompartirTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Compartís la buena noticia?'**
  String get comunidadCompartirTitulo;

  /// No description provided for @comunidadCompartirExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Se publica en Noticias → Comunidad con el nombre, la especie y la primera foto del reporte. Nunca la ubicación ni tus datos. La podés quitar cuando quieras.'**
  String get comunidadCompartirExplicacion;

  /// No description provided for @comunidadCompartir.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get comunidadCompartir;

  /// No description provided for @comunidadCompartida.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya está en Comunidad.'**
  String get comunidadCompartida;

  /// No description provided for @comunidadInterruptor.
  ///
  /// In es, this message translates to:
  /// **'Compartido en Comunidad'**
  String get comunidadInterruptor;

  /// No description provided for @comunidadInterruptorDetalle.
  ///
  /// In es, this message translates to:
  /// **'Nombre, especie y foto; nunca la ubicación ni tus datos.'**
  String get comunidadInterruptorDetalle;

  /// No description provided for @menuAbrir.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get menuAbrir;

  /// No description provided for @menuIngresar.
  ///
  /// In es, this message translates to:
  /// **'Ingresá o creá tu cuenta'**
  String get menuIngresar;

  /// No description provided for @menuIngresarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Para cargar tus mascotas y recibir avisos.'**
  String get menuIngresarAyuda;

  /// No description provided for @menuVerPara.
  ///
  /// In es, this message translates to:
  /// **'Ver todo para'**
  String get menuVerPara;

  /// No description provided for @menuTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get menuTodas;

  /// No description provided for @menuTodasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Noticias y adopción muestran lo de todas tus mascotas.'**
  String get menuTodasAyuda;

  /// No description provided for @menuElegidaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Noticias y adopción se muestran para la especie de {nombre}.'**
  String menuElegidaAyuda(String nombre);

  /// No description provided for @menuFicha.
  ///
  /// In es, this message translates to:
  /// **'Ver su ficha'**
  String get menuFicha;

  /// No description provided for @menuReportarPerdida.
  ///
  /// In es, this message translates to:
  /// **'Reportar que se perdió'**
  String get menuReportarPerdida;

  /// No description provided for @comunidadReaccionesTuyo.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{A 1 persona le alegró la noticia ❤️} other{A {n} personas les alegró la noticia ❤️}}'**
  String comunidadReaccionesTuyo(int n);

  /// No description provided for @comunidadSeBusca.
  ///
  /// In es, this message translates to:
  /// **'Se busca a {nombre}'**
  String comunidadSeBusca(String nombre);

  /// No description provided for @comunidadSeBuscaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'Se busca una mascota perdida'**
  String get comunidadSeBuscaSinNombre;

  /// No description provided for @comunidadPerdidaDias.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =0{Se perdió hoy.} =1{Lleva 1 día perdida.} other{Lleva {dias} días perdida.}}'**
  String comunidadPerdidaDias(int dias);

  /// No description provided for @comunidadPerdidaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Entrá al reporte para avisar si la viste o seguirlo.'**
  String get comunidadPerdidaAyuda;

  /// No description provided for @comunidadVerReporte.
  ///
  /// In es, this message translates to:
  /// **'Ver el reporte'**
  String get comunidadVerReporte;

  /// No description provided for @reaccionAlegra.
  ///
  /// In es, this message translates to:
  /// **'Me alegra'**
  String get reaccionAlegra;

  /// No description provided for @reaccionFestejo.
  ///
  /// In es, this message translates to:
  /// **'¡Qué bueno!'**
  String get reaccionFestejo;

  /// No description provided for @reaccionGracias.
  ///
  /// In es, this message translates to:
  /// **'Gracias'**
  String get reaccionGracias;

  /// No description provided for @reaccionesMotivoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Para reaccionar a las noticias necesitás una cuenta.'**
  String get reaccionesMotivoCuenta;

  /// No description provided for @reaccionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te pareció?'**
  String get reaccionesTitulo;

  /// No description provided for @adopcionEntrada.
  ///
  /// In es, this message translates to:
  /// **'Adoptar o dar en adopción'**
  String get adopcionEntrada;

  /// No description provided for @adopcionEntradaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Siempre gratis. Con guía, compatibilidad y seguimiento.'**
  String get adopcionEntradaAyuda;

  /// No description provided for @adopcionAdoptar.
  ///
  /// In es, this message translates to:
  /// **'Adoptar'**
  String get adopcionAdoptar;

  /// No description provided for @adopcionMias.
  ///
  /// In es, this message translates to:
  /// **'Mis solicitudes'**
  String get adopcionMias;

  /// No description provided for @adopcionPublicar.
  ///
  /// In es, this message translates to:
  /// **'Dar en adopción'**
  String get adopcionPublicar;

  /// No description provided for @adopcionGuia.
  ///
  /// In es, this message translates to:
  /// **'¿Estoy listo para adoptar?'**
  String get adopcionGuia;

  /// No description provided for @adopcionCalculadora.
  ///
  /// In es, this message translates to:
  /// **'Calculadora de costos'**
  String get adopcionCalculadora;

  /// No description provided for @adopcionMiPerfil.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil de adoptante'**
  String get adopcionMiPerfil;

  /// No description provided for @adopcionVacio.
  ///
  /// In es, this message translates to:
  /// **'No hay animales en adopción con este filtro.'**
  String get adopcionVacio;

  /// No description provided for @adopcionTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get adopcionTodas;

  /// No description provided for @adopcionEdad.
  ///
  /// In es, this message translates to:
  /// **'{meses, plural, =0{Menos de 1 mes} =1{1 mes} other{{meses} meses}}'**
  String adopcionEdad(int meses);

  /// No description provided for @adopcionEdadAnios.
  ///
  /// In es, this message translates to:
  /// **'{anios, plural, =1{1 año} other{{anios} años}}'**
  String adopcionEdadAnios(int anios);

  /// No description provided for @adopcionChico.
  ///
  /// In es, this message translates to:
  /// **'Chico'**
  String get adopcionChico;

  /// No description provided for @adopcionMediano.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get adopcionMediano;

  /// No description provided for @adopcionGrande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get adopcionGrande;

  /// No description provided for @adopcionEnergiaBaja.
  ///
  /// In es, this message translates to:
  /// **'Tranquilo'**
  String get adopcionEnergiaBaja;

  /// No description provided for @adopcionEnergiaMedia.
  ///
  /// In es, this message translates to:
  /// **'Energía media'**
  String get adopcionEnergiaMedia;

  /// No description provided for @adopcionEnergiaAlta.
  ///
  /// In es, this message translates to:
  /// **'Mucha energía'**
  String get adopcionEnergiaAlta;

  /// No description provided for @adopcionCastrado.
  ///
  /// In es, this message translates to:
  /// **'Castrado'**
  String get adopcionCastrado;

  /// No description provided for @adopcionVacunado.
  ///
  /// In es, this message translates to:
  /// **'Vacunado'**
  String get adopcionVacunado;

  /// No description provided for @adopcionConChip.
  ///
  /// In es, this message translates to:
  /// **'Con microchip'**
  String get adopcionConChip;

  /// No description provided for @adopcionConNinos.
  ///
  /// In es, this message translates to:
  /// **'Se lleva bien con niños'**
  String get adopcionConNinos;

  /// No description provided for @adopcionConPerros.
  ///
  /// In es, this message translates to:
  /// **'Se lleva bien con perros'**
  String get adopcionConPerros;

  /// No description provided for @adopcionConGatos.
  ///
  /// In es, this message translates to:
  /// **'Se lleva bien con gatos'**
  String get adopcionConGatos;

  /// No description provided for @adopcionNecesitaPatio.
  ///
  /// In es, this message translates to:
  /// **'Necesita patio'**
  String get adopcionNecesitaPatio;

  /// No description provided for @adopcionNecesidades.
  ///
  /// In es, this message translates to:
  /// **'Necesidades especiales'**
  String get adopcionNecesidades;

  /// No description provided for @adopcionRequisitos.
  ///
  /// In es, this message translates to:
  /// **'Requisitos'**
  String get adopcionRequisitos;

  /// No description provided for @adopcionAporte.
  ///
  /// In es, this message translates to:
  /// **'Aporte: \${monto} — cubre {cubre}'**
  String adopcionAporte(String monto, String cubre);

  /// No description provided for @adopcionAporteAyuda.
  ///
  /// In es, this message translates to:
  /// **'Es un aporte transparente del refugio, no una venta. Los particulares no pueden pedir dinero.'**
  String get adopcionAporteAyuda;

  /// No description provided for @adopcionRefugio.
  ///
  /// In es, this message translates to:
  /// **'Refugio verificado: {nombre}'**
  String adopcionRefugio(String nombre);

  /// No description provided for @adopcionParticular.
  ///
  /// In es, this message translates to:
  /// **'Lo da en adopción un particular'**
  String get adopcionParticular;

  /// No description provided for @adopcionCamada.
  ///
  /// In es, this message translates to:
  /// **'Parte de una camada'**
  String get adopcionCamada;

  /// No description provided for @adopcionMeInteresa.
  ///
  /// In es, this message translates to:
  /// **'Me interesa'**
  String get adopcionMeInteresa;

  /// No description provided for @adopcionMensaje.
  ///
  /// In es, this message translates to:
  /// **'Contale algo de vos (opcional)'**
  String get adopcionMensaje;

  /// No description provided for @adopcionEnviado.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Quien lo publicó va a ver tu solicitud.'**
  String get adopcionEnviado;

  /// No description provided for @adopcionLimite.
  ///
  /// In es, this message translates to:
  /// **'Ya tenés 3 solicitudes activas. Retirá alguna para pedir otra.'**
  String get adopcionLimite;

  /// No description provided for @adopcionNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Ya no está disponible.'**
  String get adopcionNoDisponible;

  /// No description provided for @adopcionPerfilPrimero.
  ///
  /// In es, this message translates to:
  /// **'Completalo una vez: se usa para orientarte sobre la compatibilidad con cada animal y lo ve quien publica cuando le escribís.'**
  String get adopcionPerfilPrimero;

  /// No description provided for @compatBuena.
  ///
  /// In es, this message translates to:
  /// **'Buena compatibilidad con tu perfil.'**
  String get compatBuena;

  /// No description provided for @compatPatio.
  ///
  /// In es, this message translates to:
  /// **'Ojo: necesita patio y vos indicaste que no tenés.'**
  String get compatPatio;

  /// No description provided for @compatNinos.
  ///
  /// In es, this message translates to:
  /// **'Ojo: no se lleva bien con niños y en tu casa hay.'**
  String get compatNinos;

  /// No description provided for @compatAnimales.
  ///
  /// In es, this message translates to:
  /// **'Ojo: no se lleva bien con otros animales y vos tenés.'**
  String get compatAnimales;

  /// No description provided for @compatSolo.
  ///
  /// In es, this message translates to:
  /// **'Ojo: tiene mucha energía y estaría muchas horas solo.'**
  String get compatSolo;

  /// No description provided for @compatCasa.
  ///
  /// In es, this message translates to:
  /// **'Ojo: indicaste que no todos en tu casa están de acuerdo.'**
  String get compatCasa;

  /// No description provided for @compatExperiencia.
  ///
  /// In es, this message translates to:
  /// **'Ojo: tiene necesidades especiales y no tenés experiencia.'**
  String get compatExperiencia;

  /// No description provided for @compatNota.
  ///
  /// In es, this message translates to:
  /// **'Es una orientación: la decisión es de quien adopta y de quien lo da.'**
  String get compatNota;

  /// No description provided for @perfilVivienda.
  ///
  /// In es, this message translates to:
  /// **'Vivienda'**
  String get perfilVivienda;

  /// No description provided for @perfilCasa.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get perfilCasa;

  /// No description provided for @perfilApartamento.
  ///
  /// In es, this message translates to:
  /// **'Apartamento'**
  String get perfilApartamento;

  /// No description provided for @perfilOtra.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get perfilOtra;

  /// No description provided for @perfilPatio.
  ///
  /// In es, this message translates to:
  /// **'Tengo patio'**
  String get perfilPatio;

  /// No description provided for @perfilHorasSolo.
  ///
  /// In es, this message translates to:
  /// **'Horas que estaría solo por día'**
  String get perfilHorasSolo;

  /// No description provided for @perfilHoras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 hora} other{{n} horas}}'**
  String perfilHoras(int n);

  /// No description provided for @perfilExperiencia.
  ///
  /// In es, this message translates to:
  /// **'Experiencia con mascotas'**
  String get perfilExperiencia;

  /// No description provided for @perfilExpNinguna.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get perfilExpNinguna;

  /// No description provided for @perfilExpAlguna.
  ///
  /// In es, this message translates to:
  /// **'Alguna'**
  String get perfilExpAlguna;

  /// No description provided for @perfilExpMucha.
  ///
  /// In es, this message translates to:
  /// **'Mucha'**
  String get perfilExpMucha;

  /// No description provided for @perfilOtrosAnimales.
  ///
  /// In es, this message translates to:
  /// **'Tengo otros animales'**
  String get perfilOtrosAnimales;

  /// No description provided for @perfilNinos.
  ///
  /// In es, this message translates to:
  /// **'Hay niños en casa'**
  String get perfilNinos;

  /// No description provided for @perfilCasaDeAcuerdo.
  ///
  /// In es, this message translates to:
  /// **'Todos en casa están de acuerdo'**
  String get perfilCasaDeAcuerdo;

  /// No description provided for @perfilGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar perfil'**
  String get perfilGuardar;

  /// No description provided for @perfilGuardado.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado.'**
  String get perfilGuardado;

  /// No description provided for @etapaInterest.
  ///
  /// In es, this message translates to:
  /// **'Me interesa'**
  String get etapaInterest;

  /// No description provided for @etapaQuestionnaire.
  ///
  /// In es, this message translates to:
  /// **'Cuestionario'**
  String get etapaQuestionnaire;

  /// No description provided for @etapaInterview.
  ///
  /// In es, this message translates to:
  /// **'Chat / entrevista'**
  String get etapaInterview;

  /// No description provided for @etapaVisit.
  ///
  /// In es, this message translates to:
  /// **'Visita'**
  String get etapaVisit;

  /// No description provided for @etapaAgreement.
  ///
  /// In es, this message translates to:
  /// **'Compromiso'**
  String get etapaAgreement;

  /// No description provided for @etapaAdopted.
  ///
  /// In es, this message translates to:
  /// **'Adoptado'**
  String get etapaAdopted;

  /// No description provided for @etapaRejected.
  ///
  /// In es, this message translates to:
  /// **'No avanzó'**
  String get etapaRejected;

  /// No description provided for @etapaWithdrawn.
  ///
  /// In es, this message translates to:
  /// **'Retirada'**
  String get etapaWithdrawn;

  /// No description provided for @adopcionAvanzarA.
  ///
  /// In es, this message translates to:
  /// **'Pasar a «{etapa}»'**
  String adopcionAvanzarA(String etapa);

  /// No description provided for @adopcionRechazar.
  ///
  /// In es, this message translates to:
  /// **'No avanzar'**
  String get adopcionRechazar;

  /// No description provided for @adopcionRetirar.
  ///
  /// In es, this message translates to:
  /// **'Retirar mi solicitud'**
  String get adopcionRetirar;

  /// No description provided for @adopcionNotaPrivada.
  ///
  /// In es, this message translates to:
  /// **'Nota privada (solo la ves vos)'**
  String get adopcionNotaPrivada;

  /// No description provided for @adopcionNotaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Nota guardada.'**
  String get adopcionNotaGuardada;

  /// No description provided for @adopcionSinSolicitudes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no pediste adoptar.'**
  String get adopcionSinSolicitudes;

  /// No description provided for @adopcionSinRecibidas.
  ///
  /// In es, this message translates to:
  /// **'Todavía no recibiste solicitudes.'**
  String get adopcionSinRecibidas;

  /// No description provided for @adopcionRecibidas.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes recibidas'**
  String get adopcionRecibidas;

  /// No description provided for @adopcionDe.
  ///
  /// In es, this message translates to:
  /// **'De {nombre}'**
  String adopcionDe(String nombre);

  /// No description provided for @adopcionVerCompromiso.
  ///
  /// In es, this message translates to:
  /// **'Ver y aceptar el compromiso'**
  String get adopcionVerCompromiso;

  /// No description provided for @adopcionCompromisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Compromiso de adopción'**
  String get adopcionCompromisoTitulo;

  /// No description provided for @adopcionAcepto.
  ///
  /// In es, this message translates to:
  /// **'Leí y acepto el compromiso'**
  String get adopcionAcepto;

  /// No description provided for @adopcionAceptar.
  ///
  /// In es, this message translates to:
  /// **'Adoptar'**
  String get adopcionAceptar;

  /// No description provided for @adopcionBienvenida.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenida a casa! Ya está en «Mis mascotas» con sus recordatorios.'**
  String get adopcionBienvenida;

  /// No description provided for @adopcionSeguimiento.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento: ¿cómo va {nombre}?'**
  String adopcionSeguimiento(String nombre);

  /// No description provided for @adopcionSeguimientoDia.
  ///
  /// In es, this message translates to:
  /// **'A los {dia} días'**
  String adopcionSeguimientoDia(int dia);

  /// No description provided for @adopcionSeguimientoTexto.
  ///
  /// In es, this message translates to:
  /// **'Contale a quien te lo dio en adopción cómo va (y si querés, mandá una foto).'**
  String get adopcionSeguimientoTexto;

  /// No description provided for @adopcionSeguimientoEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get adopcionSeguimientoEnviar;

  /// No description provided for @adopcionSeguimientoListo.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por contar cómo va!'**
  String get adopcionSeguimientoListo;

  /// No description provided for @adopcionSeguimientoRespuestas.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento'**
  String get adopcionSeguimientoRespuestas;

  /// No description provided for @adopcionSeguimientoSin.
  ///
  /// In es, this message translates to:
  /// **'Sin respuesta todavía'**
  String get adopcionSeguimientoSin;

  /// No description provided for @publicarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Dar en adopción'**
  String get publicarTitulo;

  /// No description provided for @publicarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Es gratis y nunca es una venta. Como particular podés tener hasta 2 publicaciones activas; una camada cuenta como una.'**
  String get publicarExplicacion;

  /// No description provided for @publicarAnimal.
  ///
  /// In es, this message translates to:
  /// **'Animal {n}'**
  String publicarAnimal(int n);

  /// No description provided for @publicarAgregarAnimal.
  ///
  /// In es, this message translates to:
  /// **'Sumar otro de la camada'**
  String get publicarAgregarAnimal;

  /// No description provided for @publicarNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre (opcional)'**
  String get publicarNombre;

  /// No description provided for @publicarEdadMeses.
  ///
  /// In es, this message translates to:
  /// **'Edad aproximada en meses'**
  String get publicarEdadMeses;

  /// No description provided for @publicarTamano.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get publicarTamano;

  /// No description provided for @publicarEnergia.
  ///
  /// In es, this message translates to:
  /// **'Energía'**
  String get publicarEnergia;

  /// No description provided for @publicarFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get publicarFoto;

  /// No description provided for @publicarFaltaFoto.
  ///
  /// In es, this message translates to:
  /// **'Cada animal necesita al menos una foto.'**
  String get publicarFaltaFoto;

  /// No description provided for @publicarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get publicarDescripcion;

  /// No description provided for @publicarRequisitos.
  ///
  /// In es, this message translates to:
  /// **'Requisitos (opcional)'**
  String get publicarRequisitos;

  /// No description provided for @publicarComoRefugio.
  ///
  /// In es, this message translates to:
  /// **'Publicar como refugio verificado'**
  String get publicarComoRefugio;

  /// No description provided for @publicarAporteMonto.
  ///
  /// In es, this message translates to:
  /// **'Aporte (pesos, opcional)'**
  String get publicarAporteMonto;

  /// No description provided for @publicarAporteCubre.
  ///
  /// In es, this message translates to:
  /// **'Qué cubre el aporte'**
  String get publicarAporteCubre;

  /// No description provided for @publicarEnviar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicarEnviar;

  /// No description provided for @publicarListo.
  ///
  /// In es, this message translates to:
  /// **'¡Publicado! Te avisamos cuando alguien se interese.'**
  String get publicarListo;

  /// No description provided for @publicarLimite.
  ///
  /// In es, this message translates to:
  /// **'Ya tenés 2 publicaciones activas. Marcá alguna como adoptada o pausala.'**
  String get publicarLimite;

  /// No description provided for @publicarRevision.
  ///
  /// In es, this message translates to:
  /// **'Publicaste dos camadas en un año: la publicación queda en revisión. Castrar evita camadas no deseadas.'**
  String get publicarRevision;

  /// No description provided for @publicarDatos.
  ///
  /// In es, this message translates to:
  /// **'Revisá los datos.'**
  String get publicarDatos;

  /// No description provided for @guiaTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Estoy listo para adoptar?'**
  String get guiaTitulo;

  /// No description provided for @guiaTexto.
  ///
  /// In es, this message translates to:
  /// **'Adoptar es un compromiso de muchos años. Antes de decidir, pensá en:\n\n• **Tiempo:** paseos, juego y compañía todos los días.\n• **Espacio:** que tenga lugar para moverse y descansar.\n• **Acuerdo de toda la casa:** que todos quieran y se comprometan.\n• **Vacaciones y mudanzas:** quién lo cuida y si podés llevarlo.\n• **Costos:** comida, vacunas, antiparasitarios, castración y veterinaria (probá la calculadora).\n• **Paciencia:** al principio puede tener miedo o romper cosas.\n\nSi todo esto te cierra, ¡adelante! Y si dudás, también podés ayudar como hogar de tránsito o apadrinando en un refugio.'**
  String get guiaTexto;

  /// No description provided for @calcExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Poné cuánto pensás gastar en cada cosa (los precios cambian según la zona y el tamaño). La app suma y te da el total.'**
  String get calcExplicacion;

  /// No description provided for @calcComida.
  ///
  /// In es, this message translates to:
  /// **'Comida (por mes)'**
  String get calcComida;

  /// No description provided for @calcArena.
  ///
  /// In es, this message translates to:
  /// **'Arena o piedritas (por mes)'**
  String get calcArena;

  /// No description provided for @calcAntiparasitarios.
  ///
  /// In es, this message translates to:
  /// **'Antiparasitarios (por mes)'**
  String get calcAntiparasitarios;

  /// No description provided for @calcVacunas.
  ///
  /// In es, this message translates to:
  /// **'Vacunas (por año)'**
  String get calcVacunas;

  /// No description provided for @calcCastracion.
  ///
  /// In es, this message translates to:
  /// **'Castración (una vez, la dividimos en 12 meses)'**
  String get calcCastracion;

  /// No description provided for @calcVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Consultas veterinarias (por año)'**
  String get calcVeterinaria;

  /// No description provided for @calcImprevistos.
  ///
  /// In es, this message translates to:
  /// **'Imprevistos (por mes)'**
  String get calcImprevistos;

  /// No description provided for @calcTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: \${mes} por mes · \${anio} por año'**
  String calcTotal(String mes, String anio);

  /// No description provided for @eventoCastracion.
  ///
  /// In es, this message translates to:
  /// **'Jornada de castración'**
  String get eventoCastracion;

  /// No description provided for @eventoAdopcion.
  ///
  /// In es, this message translates to:
  /// **'Feria de adopción'**
  String get eventoAdopcion;

  /// No description provided for @eventoEncuentro.
  ///
  /// In es, this message translates to:
  /// **'Encuentro'**
  String get eventoEncuentro;

  /// No description provided for @eventoOtro.
  ///
  /// In es, this message translates to:
  /// **'Evento'**
  String get eventoOtro;

  /// No description provided for @eventosProximos.
  ///
  /// In es, this message translates to:
  /// **'Próximos eventos'**
  String get eventosProximos;

  /// No description provided for @eventosVacio.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos próximos en la zona.'**
  String get eventosVacio;

  /// No description provided for @eventoCuando.
  ///
  /// In es, this message translates to:
  /// **'{desde} a {hasta}'**
  String eventoCuando(String desde, String hasta);

  /// No description provided for @eventoOrganiza.
  ///
  /// In es, this message translates to:
  /// **'Organiza: {nombre}'**
  String eventoOrganiza(String nombre);

  /// No description provided for @eventoEnCurso.
  ///
  /// In es, this message translates to:
  /// **'¡Está pasando ahora!'**
  String get eventoEnCurso;

  /// No description provided for @eventoMasInfo.
  ///
  /// In es, this message translates to:
  /// **'Más información'**
  String get eventoMasInfo;

  /// No description provided for @eventoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar el evento'**
  String get eventoCancelar;

  /// No description provided for @eventoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Evento cancelado.'**
  String get eventoCancelado;

  /// No description provided for @eventoPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar un evento'**
  String get eventoPublicar;

  /// No description provided for @eventoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get eventoTitulo;

  /// No description provided for @eventoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get eventoDescripcion;

  /// No description provided for @eventoTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get eventoTipo;

  /// No description provided for @eventoDesde.
  ///
  /// In es, this message translates to:
  /// **'Empieza'**
  String get eventoDesde;

  /// No description provided for @eventoHasta.
  ///
  /// In es, this message translates to:
  /// **'Termina'**
  String get eventoHasta;

  /// No description provided for @eventoLugar.
  ///
  /// In es, this message translates to:
  /// **'Tocá el mapa donde es (o queda en tu local).'**
  String get eventoLugar;

  /// No description provided for @eventoDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección (opcional)'**
  String get eventoDireccion;

  /// No description provided for @eventoEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enlace con más información (https://…, opcional)'**
  String get eventoEnlace;

  /// No description provided for @eventoPublicado.
  ///
  /// In es, this message translates to:
  /// **'¡Evento publicado! Ya aparece en el mapa.'**
  String get eventoPublicado;

  /// No description provided for @eventoSoloVerificados.
  ///
  /// In es, this message translates to:
  /// **'Los eventos los publican comercios y refugios verificados ✔️.'**
  String get eventoSoloVerificados;

  /// No description provided for @eventoDatos.
  ///
  /// In es, this message translates to:
  /// **'Revisá los datos: el evento dura como máximo 14 días y el título lleva 3 letras o más.'**
  String get eventoDatos;

  /// No description provided for @leyendaEvento.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get leyendaEvento;

  /// No description provided for @denunciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Denunciar maltrato'**
  String get denunciaTitulo;

  /// No description provided for @denunciaEntradaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Contanos qué pasa; la revisa el equipo y te orienta.'**
  String get denunciaEntradaAyuda;

  /// No description provided for @denunciaInfo.
  ///
  /// In es, this message translates to:
  /// **'Esta denuncia **no reemplaza la denuncia oficial**. Podés hacerla ante el **INBA** (Instituto Nacional de Bienestar Animal) o en la seccional policial. Si hay una persona en riesgo, llamá al **911**.'**
  String get denunciaInfo;

  /// No description provided for @denunciaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Qué pasa (cuanto más detalle, mejor)'**
  String get denunciaDescripcion;

  /// No description provided for @denunciaDescripcionCorta.
  ///
  /// In es, this message translates to:
  /// **'Contá un poco más (10 letras o más).'**
  String get denunciaDescripcionCorta;

  /// No description provided for @denunciaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Ubicación (opcional, solo la ve el equipo): tocá el mapa.'**
  String get denunciaUbicacion;

  /// No description provided for @denunciaDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección o referencia (opcional)'**
  String get denunciaDireccion;

  /// No description provided for @denunciaFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get denunciaFoto;

  /// No description provided for @denunciaEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar denuncia'**
  String get denunciaEnviar;

  /// No description provided for @denunciaEnviada.
  ///
  /// In es, this message translates to:
  /// **'Recibimos tu denuncia. La vamos a revisar.'**
  String get denunciaEnviada;

  /// No description provided for @denunciaMias.
  ///
  /// In es, this message translates to:
  /// **'Mis denuncias'**
  String get denunciaMias;

  /// No description provided for @denunciaNueva.
  ///
  /// In es, this message translates to:
  /// **'Recibida'**
  String get denunciaNueva;

  /// No description provided for @denunciaDerivada.
  ///
  /// In es, this message translates to:
  /// **'Derivada'**
  String get denunciaDerivada;

  /// No description provided for @denunciaCerrada.
  ///
  /// In es, this message translates to:
  /// **'Cerrada'**
  String get denunciaCerrada;

  /// No description provided for @denunciaDemasiadas.
  ///
  /// In es, this message translates to:
  /// **'Hiciste muchas denuncias hoy. Probá mañana.'**
  String get denunciaDemasiadas;

  /// No description provided for @vetTitulo.
  ///
  /// In es, this message translates to:
  /// **'Su veterinaria'**
  String get vetTitulo;

  /// No description provided for @vetCompartirCon.
  ///
  /// In es, this message translates to:
  /// **'Compartir con {negocio}'**
  String vetCompartirCon(String negocio);

  /// No description provided for @vetCompartirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ve el nombre, la especie, tu primer nombre y el próximo control de la libreta; nunca tu teléfono. Te puede mandar recordatorios. Lo podés dejar de compartir cuando quieras.'**
  String get vetCompartirAyuda;

  /// No description provided for @vetSinMiVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Si marcás tu veterinaria en el mapa (ficha → «Es mi veterinaria»), le vas a poder compartir a {nombre}.'**
  String vetSinMiVeterinaria(String nombre);

  /// No description provided for @vetBuscasPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Buscás veterinaria para {nombre}?'**
  String vetBuscasPregunta(String nombre);

  /// No description provided for @vetBuscasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Las veterinarias cercanas te pueden mandar propuestas (como máximo 3 por mes). No saben quién sos hasta que aceptás una.'**
  String get vetBuscasAyuda;

  /// No description provided for @vetBuscarSi.
  ///
  /// In es, this message translates to:
  /// **'Sí, quiero propuestas'**
  String get vetBuscarSi;

  /// No description provided for @vetAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get vetAhoraNo;

  /// No description provided for @vetBuscando.
  ///
  /// In es, this message translates to:
  /// **'Estás recibiendo propuestas de veterinarias cercanas.'**
  String get vetBuscando;

  /// No description provided for @vetDejarDeBuscar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de buscar'**
  String get vetDejarDeBuscar;

  /// No description provided for @vetPropuestaDe.
  ///
  /// In es, this message translates to:
  /// **'Propuesta de {negocio}'**
  String vetPropuestaDe(String negocio);

  /// No description provided for @vetAceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get vetAceptar;

  /// No description provided for @vetRechazar.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get vetRechazar;

  /// No description provided for @vetAceptada.
  ///
  /// In es, this message translates to:
  /// **'Aceptada: ahora {negocio} es su veterinaria.'**
  String vetAceptada(String negocio);

  /// No description provided for @vetRechazada.
  ///
  /// In es, this message translates to:
  /// **'La rechazaste.'**
  String get vetRechazada;

  /// No description provided for @sociosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Socios'**
  String get sociosTitulo;

  /// No description provided for @sociosAbrir.
  ///
  /// In es, this message translates to:
  /// **'Socios y «Busco veterinaria»'**
  String get sociosAbrir;

  /// No description provided for @sociosModulo.
  ///
  /// In es, this message translates to:
  /// **'Módulo Socios'**
  String get sociosModulo;

  /// No description provided for @sociosModuloAyuda.
  ///
  /// In es, this message translates to:
  /// **'Tus clientes te comparten su mascota y les podés recordar los controles.'**
  String get sociosModuloAyuda;

  /// No description provided for @sociosSoloPlus.
  ///
  /// In es, this message translates to:
  /// **'Socios necesita el plan Plus.'**
  String get sociosSoloPlus;

  /// No description provided for @sociosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía nadie te compartió su mascota.'**
  String get sociosVacio;

  /// No description provided for @sociosProximo.
  ///
  /// In es, this message translates to:
  /// **'Próximo: {que} · {fecha}'**
  String sociosProximo(String que, String fecha);

  /// No description provided for @sociosSinProximo.
  ///
  /// In es, this message translates to:
  /// **'Sin controles próximos en la libreta'**
  String get sociosSinProximo;

  /// No description provided for @sociosDeDuenio.
  ///
  /// In es, this message translates to:
  /// **'De {nombre}'**
  String sociosDeDuenio(String nombre);

  /// No description provided for @sociosRecordar.
  ///
  /// In es, this message translates to:
  /// **'Recordar'**
  String get sociosRecordar;

  /// No description provided for @sociosRecordarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio para {nombre}'**
  String sociosRecordarTitulo(String nombre);

  /// No description provided for @sociosRecordarQue.
  ///
  /// In es, this message translates to:
  /// **'¿Qué hay que recordar?'**
  String get sociosRecordarQue;

  /// No description provided for @sociosRecordarFecha.
  ///
  /// In es, this message translates to:
  /// **'Día: {fecha}'**
  String sociosRecordarFecha(String fecha);

  /// No description provided for @sociosElegirFecha.
  ///
  /// In es, this message translates to:
  /// **'Cambiar día'**
  String get sociosElegirFecha;

  /// No description provided for @sociosRecordado.
  ///
  /// In es, this message translates to:
  /// **'Listo: le va a sonar en el celular del dueño.'**
  String get sociosRecordado;

  /// No description provided for @sociosDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Ya le mandaste muchos recordatorios esta semana.'**
  String get sociosDemasiados;

  /// No description provided for @demandaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Busco veterinaria'**
  String get demandaTitulo;

  /// No description provided for @demandaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Mascotas a menos de 2 km cuyos dueños buscan veterinaria. Solo se muestran grupos de 5 o más, y nunca quiénes son.'**
  String get demandaAyuda;

  /// No description provided for @demandaVacia.
  ///
  /// In es, this message translates to:
  /// **'Por ahora no hay suficientes mascotas buscando cerca.'**
  String get demandaVacia;

  /// No description provided for @demandaFila.
  ///
  /// In es, this message translates to:
  /// **'{especie}: {cantidad}'**
  String demandaFila(String especie, int cantidad);

  /// No description provided for @propuestaMensaje.
  ///
  /// In es, this message translates to:
  /// **'Tu propuesta (por ejemplo: primera consulta sin cargo)'**
  String get propuestaMensaje;

  /// No description provided for @propuestaEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar propuesta'**
  String get propuestaEnviar;

  /// No description provided for @propuestaEnviada.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{No le llegó a nadie: este mes ya recibieron sus 3 propuestas.} =1{Le llegó a 1 mascota.} other{Le llegó a {n} mascotas.}}'**
  String propuestaEnviada(int n);

  /// No description provided for @propuestaLimite.
  ///
  /// In es, this message translates to:
  /// **'Como máximo podés mandar 2 propuestas por semana.'**
  String get propuestaLimite;

  /// No description provided for @propuestaResultado.
  ///
  /// In es, this message translates to:
  /// **'{enviadas} enviadas · {vistas} vistas · {aceptadas} aceptadas'**
  String propuestaResultado(int enviadas, int vistas, int aceptadas);

  /// No description provided for @mascotaRenac.
  ///
  /// In es, this message translates to:
  /// **'¿Está registrada en el RENAC?'**
  String get mascotaRenac;

  /// No description provided for @mascotaRenacAyuda.
  ///
  /// In es, this message translates to:
  /// **'Es el registro oficial de perros y gatos con microchip. Si no sabés, elegí \"No sé\".'**
  String get mascotaRenacAyuda;

  /// No description provided for @renacTitulo.
  ///
  /// In es, this message translates to:
  /// **'Registro RENAC'**
  String get renacTitulo;

  /// No description provided for @renacRegistrada.
  ///
  /// In es, this message translates to:
  /// **'Registrada en el RENAC'**
  String get renacRegistrada;

  /// No description provided for @renacNoRegistrada.
  ///
  /// In es, this message translates to:
  /// **'No está registrada en el RENAC'**
  String get renacNoRegistrada;

  /// No description provided for @renacNoSabe.
  ///
  /// In es, this message translates to:
  /// **'No sabés si está registrada en el RENAC'**
  String get renacNoSabe;

  /// No description provided for @renacSinResponder.
  ///
  /// In es, this message translates to:
  /// **'¿Está registrada en el RENAC?'**
  String get renacSinResponder;

  /// No description provided for @renacDeclarado.
  ///
  /// In es, this message translates to:
  /// **'Lo indicaste vos: la app no lo verifica.'**
  String get renacDeclarado;

  /// No description provided for @renacAviso.
  ///
  /// In es, this message translates to:
  /// **'Registrar a {nombre} con microchip es obligatorio por ley y ayuda a que vuelva a casa si se pierde.'**
  String renacAviso(String nombre);

  /// No description provided for @renacCachorro.
  ///
  /// In es, this message translates to:
  /// **'Se registra a partir de los 90 días de vida.'**
  String get renacCachorro;

  /// No description provided for @renacComoRegistrar.
  ///
  /// In es, this message translates to:
  /// **'Cómo registrarla'**
  String get renacComoRegistrar;

  /// No description provided for @renacVerificar.
  ///
  /// In es, this message translates to:
  /// **'Verificar en el RENAC'**
  String get renacVerificar;

  /// No description provided for @renacYaLaRegistre.
  ///
  /// In es, this message translates to:
  /// **'Ya la registré'**
  String get renacYaLaRegistre;

  /// No description provided for @renacGuardado.
  ///
  /// In es, this message translates to:
  /// **'Listo, quedó como registrada.'**
  String get renacGuardado;

  /// No description provided for @renacGuiaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cómo registrar a tu mascota'**
  String get renacGuiaTitulo;

  /// No description provided for @renacGuiaTexto.
  ///
  /// In es, this message translates to:
  /// **'## Qué es el RENAC\nEs el **Registro Nacional de Animales de Compañía** del MGAP (Ley 18.471). Los perros y gatos se identifican con un **microchip** y se registran a nombre de quien los tiene a cargo. Es obligatorio.\n## Cuándo\nA partir de los **90 días de vida**.\n## Cómo se hace\n- Andá a una veterinaria que sea **operador RENAC** (veterinarios acreditados por el INBA).\n- Te coloca el microchip, si no tiene, y carga los datos de tu mascota y los tuyos.\n- Te dan una **constancia** con esos datos. Guardala.\n- El costo lo fija cada veterinaria: preguntá antes.\n## Si se muda o cambia de dueño\nPedile a tu veterinaria que actualice los datos en el RENAC.\n## Si se pierde\nAdemás de publicar el SOS en la app, pedí que la marquen como **extraviada** en el RENAC.\n## Chip y chapita QR\nEl chip solo lo lee una veterinaria con un lector. La chapita QR la lee cualquier celular. **Se complementan.**\n> SOS Mascota no es parte del RENAC ni del MGAP. Esta guía es orientativa: ante cualquier duda, consultá con tu veterinaria o con el INBA.'**
  String get renacGuiaTexto;

  /// No description provided for @renacVerVeterinarias.
  ///
  /// In es, this message translates to:
  /// **'Ver veterinarias que colocan microchip'**
  String get renacVerVeterinarias;

  /// No description provided for @renacVerificarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Para consultar necesitás el número de chip y tu documento. Se abre la página oficial.'**
  String get renacVerificarAyuda;

  /// No description provided for @buscarLugares.
  ///
  /// In es, this message translates to:
  /// **'Buscar lugares'**
  String get buscarLugares;

  /// No description provided for @buscarPista.
  ///
  /// In es, this message translates to:
  /// **'Nombre o rubro…'**
  String get buscarPista;

  /// No description provided for @buscarBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get buscarBorrar;

  /// No description provided for @buscarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Buscá por nombre o por rubro: veterinaria, peluquería, guardería, refugio…'**
  String get buscarAyuda;

  /// No description provided for @buscarIncluyeRubro.
  ///
  /// In es, this message translates to:
  /// **'Incluye {rubro} cerca'**
  String buscarIncluyeRubro(String rubro);

  /// No description provided for @buscarSinRubro.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay {rubro} cerca en SOS Mascota.'**
  String buscarSinRubro(String rubro);

  /// No description provided for @buscarSinResultados.
  ///
  /// In es, this message translates to:
  /// **'No encontramos lugares con «{texto}».'**
  String buscarSinResultados(String texto);

  /// No description provided for @buscarConocesUno.
  ///
  /// In es, this message translates to:
  /// **'¿Conocés uno? Marcalo en el mapa y lo sumamos.'**
  String get buscarConocesUno;

  /// No description provided for @pedidoChapitaPedir.
  ///
  /// In es, this message translates to:
  /// **'Pedir una chapita'**
  String get pedidoChapitaPedir;

  /// No description provided for @pedidoChapitaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pedir una chapita'**
  String get pedidoChapitaTitulo;

  /// No description provided for @pedidoChapitaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Te hacemos una chapita con el QR de {nombre} y la retirás en una veterinaria. Cuando te la den, queda vinculada sola.'**
  String pedidoChapitaExplicacion(String nombre);

  /// No description provided for @pedidoChapitaPrecio.
  ///
  /// In es, this message translates to:
  /// **'Sin cargo durante el lanzamiento.'**
  String get pedidoChapitaPrecio;

  /// No description provided for @pedidoChapitaGrabado.
  ///
  /// In es, this message translates to:
  /// **'Texto grabado'**
  String get pedidoChapitaGrabado;

  /// No description provided for @pedidoChapitaGrabadoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lo que va escrito en la chapita (hasta 20 letras).'**
  String get pedidoChapitaGrabadoAyuda;

  /// No description provided for @pedidoChapitaDonde.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la retirás?'**
  String get pedidoChapitaDonde;

  /// No description provided for @pedidoChapitaSinPuntos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay veterinarias de retiro cerca. Probá más adelante.'**
  String get pedidoChapitaSinPuntos;

  /// No description provided for @pedidoChapitaTuVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Tu veterinaria'**
  String get pedidoChapitaTuVeterinaria;

  /// No description provided for @pedidoChapitaConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Pedirla'**
  String get pedidoChapitaConfirmar;

  /// No description provided for @pedidoChapitaPidiendo.
  ///
  /// In es, this message translates to:
  /// **'Pidiendo…'**
  String get pedidoChapitaPidiendo;

  /// No description provided for @pedidoChapitaHecho.
  ///
  /// In es, this message translates to:
  /// **'Listo, la pediste. Te avisamos acá cuando esté para retirar.'**
  String get pedidoChapitaHecho;

  /// No description provided for @pedidoChapitaNumero.
  ///
  /// In es, this message translates to:
  /// **'Pedido N.º {numero} · {nombre}'**
  String pedidoChapitaNumero(int numero, String nombre);

  /// No description provided for @pedidoChapitaNuevo.
  ///
  /// In es, this message translates to:
  /// **'Pedida: la estamos preparando.'**
  String get pedidoChapitaNuevo;

  /// No description provided for @pedidoChapitaEnviado.
  ///
  /// In es, this message translates to:
  /// **'En camino a {veterinaria}.'**
  String pedidoChapitaEnviado(String veterinaria);

  /// No description provided for @pedidoChapitaListo.
  ///
  /// In es, this message translates to:
  /// **'¡Lista para retirar en {veterinaria}! Decí el pedido N.º {numero}.'**
  String pedidoChapitaListo(String veterinaria, int numero);

  /// No description provided for @pedidoChapitaEntregado.
  ///
  /// In es, this message translates to:
  /// **'Entregada y vinculada.'**
  String get pedidoChapitaEntregado;

  /// No description provided for @pedidoChapitaCancelado.
  ///
  /// In es, this message translates to:
  /// **'Pedido cancelado.'**
  String get pedidoChapitaCancelado;

  /// No description provided for @pedidoChapitaYaHayUno.
  ///
  /// In es, this message translates to:
  /// **'Ya hay un pedido abierto para esta mascota.'**
  String get pedidoChapitaYaHayUno;

  /// No description provided for @pedidoChapitaDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Podés tener hasta {n} pedidos abiertos a la vez.'**
  String pedidoChapitaDemasiados(int n);

  /// No description provided for @pedidoChapitaNoEsPunto.
  ///
  /// In es, this message translates to:
  /// **'Esa veterinaria ya no entrega chapitas. Elegí otra.'**
  String get pedidoChapitaNoEsPunto;

  /// No description provided for @retiroTitulo.
  ///
  /// In es, this message translates to:
  /// **'Chapitas: punto de retiro'**
  String get retiroTitulo;

  /// No description provided for @retiroTarjetaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Entregá chapitas QR a tus clientes.'**
  String get retiroTarjetaAyuda;

  /// No description provided for @retiroSerPunto.
  ///
  /// In es, this message translates to:
  /// **'Ser punto de retiro de chapitas'**
  String get retiroSerPunto;

  /// No description provided for @retiroSerPuntoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Los dueños eligen tu veterinaria para retirar la chapita de su mascota. Te la mandamos nosotros.'**
  String get retiroSerPuntoAyuda;

  /// No description provided for @retiroSoloVerificadas.
  ///
  /// In es, this message translates to:
  /// **'Solo para veterinarias verificadas.'**
  String get retiroSoloVerificadas;

  /// No description provided for @retiroPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get retiroPedidos;

  /// No description provided for @retiroSinPedidos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay pedidos.'**
  String get retiroSinPedidos;

  /// No description provided for @retiroPara.
  ///
  /// In es, this message translates to:
  /// **'Para {nombre}'**
  String retiroPara(String nombre);

  /// No description provided for @retiroGrabado.
  ///
  /// In es, this message translates to:
  /// **'Grabado: {texto}'**
  String retiroGrabado(String texto);

  /// No description provided for @retiroCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código {codigo}'**
  String retiroCodigo(String codigo);

  /// No description provided for @retiroEnPreparacion.
  ///
  /// In es, this message translates to:
  /// **'La estamos preparando.'**
  String get retiroEnPreparacion;

  /// No description provided for @retiroEnCamino.
  ///
  /// In es, this message translates to:
  /// **'En camino: marcá «Llegó» cuando la recibas.'**
  String get retiroEnCamino;

  /// No description provided for @retiroEsperando.
  ///
  /// In es, this message translates to:
  /// **'Esperando que la retiren.'**
  String get retiroEsperando;

  /// No description provided for @retiroEntregadaYa.
  ///
  /// In es, this message translates to:
  /// **'Entregada.'**
  String get retiroEntregadaYa;

  /// No description provided for @retiroLlego.
  ///
  /// In es, this message translates to:
  /// **'Llegó'**
  String get retiroLlego;

  /// No description provided for @retiroEntregada.
  ///
  /// In es, this message translates to:
  /// **'Entregada'**
  String get retiroEntregada;

  /// No description provided for @retiroEntregarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿La entregaste?'**
  String get retiroEntregarTitulo;

  /// No description provided for @retiroEntregarTexto.
  ///
  /// In es, this message translates to:
  /// **'Pedido N.º {numero}: la chapita queda vinculada a {nombre}.'**
  String retiroEntregarTexto(int numero, String nombre);

  /// No description provided for @stockResumen.
  ///
  /// In es, this message translates to:
  /// **'Tu stock: {disponibles} {disponibles, plural, =1{chapita} other{chapitas}} sin usar · {activadas} {activadas, plural, =1{activada} other{activadas}}'**
  String stockResumen(int disponibles, int activadas);

  /// No description provided for @stockAyuda.
  ///
  /// In es, this message translates to:
  /// **'Chapitas en blanco para tus clientes: la activan con la app escaneándola, o se la das a quien la pidió para retirar acá.'**
  String get stockAyuda;

  /// No description provided for @stockEntregarNumero.
  ///
  /// In es, this message translates to:
  /// **'Entregar el N.º {numero} de mi stock'**
  String stockEntregarNumero(int numero);

  /// No description provided for @stockEntregarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Entregar una chapita de tu stock'**
  String get stockEntregarTitulo;

  /// No description provided for @stockEntregarTexto.
  ///
  /// In es, this message translates to:
  /// **'Pedido N.º {numero} para {nombre} (grabado «{grabado}»). Escribí el código que viene en la chapita: queda vinculada a {nombre} al tocar Entregada.'**
  String stockEntregarTexto(int numero, String nombre, String grabado);

  /// No description provided for @stockCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código de la chapita'**
  String get stockCodigo;

  /// No description provided for @transitoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Hogar de tránsito'**
  String get transitoTitulo;

  /// No description provided for @transitoIntro.
  ///
  /// In es, this message translates to:
  /// **'Cuidá por un tiempo a un animal de un refugio hasta que encuentre familia. Vos decidís qué animales recibís, por cuánto tiempo y a qué pedido decís que sí.'**
  String get transitoIntro;

  /// No description provided for @transitoPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Solo los refugios y protectoras verificados de tu zona ven tu primer nombre, tu barrio y lo que recibís. Nunca tu dirección ni tu teléfono: si aceptás un pedido, se abre un chat con el refugio.'**
  String get transitoPrivacidad;

  /// No description provided for @transitoPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos que te llegaron'**
  String get transitoPedidos;

  /// No description provided for @transitoActivo.
  ///
  /// In es, this message translates to:
  /// **'Puedo recibir animales ahora'**
  String get transitoActivo;

  /// No description provided for @transitoActivoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Apagado, los refugios no te ven.'**
  String get transitoActivoAyuda;

  /// No description provided for @transitoEspecies.
  ///
  /// In es, this message translates to:
  /// **'Qué animales recibís'**
  String get transitoEspecies;

  /// No description provided for @transitoTamanos.
  ///
  /// In es, this message translates to:
  /// **'De qué tamaño'**
  String get transitoTamanos;

  /// No description provided for @transitoMaxDias.
  ///
  /// In es, this message translates to:
  /// **'Por cuántos días como máximo (1 a 365)'**
  String get transitoMaxDias;

  /// No description provided for @transitoPatio.
  ///
  /// In es, this message translates to:
  /// **'Tengo patio'**
  String get transitoPatio;

  /// No description provided for @transitoOtros.
  ///
  /// In es, this message translates to:
  /// **'Hay otros animales en casa'**
  String get transitoOtros;

  /// No description provided for @transitoBarrio.
  ///
  /// In es, this message translates to:
  /// **'Tu barrio'**
  String get transitoBarrio;

  /// No description provided for @transitoBarrioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Solo el barrio, sin calle ni número.'**
  String get transitoBarrioAyuda;

  /// No description provided for @transitoNotas.
  ///
  /// In es, this message translates to:
  /// **'Algo más que quieras contar (opcional)'**
  String get transitoNotas;

  /// No description provided for @transitoAnotarme.
  ///
  /// In es, this message translates to:
  /// **'Anotarme como hogar de tránsito'**
  String get transitoAnotarme;

  /// No description provided for @transitoGuardado.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya figurás para los refugios de tu zona.'**
  String get transitoGuardado;

  /// No description provided for @transitoFaltanDatos.
  ///
  /// In es, this message translates to:
  /// **'Completá qué animales recibís, el tamaño, los días y tu barrio.'**
  String get transitoFaltanDatos;

  /// No description provided for @transitoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Dejar de ser hogar de tránsito'**
  String get transitoBorrar;

  /// No description provided for @transitoBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Dejás de ser hogar de tránsito?'**
  String get transitoBorrarTitulo;

  /// No description provided for @transitoBorrarTexto.
  ///
  /// In es, this message translates to:
  /// **'Se borran tus datos y los pedidos que te llegaron. Los chats con los refugios quedan.'**
  String get transitoBorrarTexto;

  /// No description provided for @transitoPedidoDe.
  ///
  /// In es, this message translates to:
  /// **'{refugio} te pide recibir a {nombre}'**
  String transitoPedidoDe(String refugio, String nombre);

  /// No description provided for @transitoDias.
  ///
  /// In es, this message translates to:
  /// **'{dias, plural, =1{1 día} other{{dias} días}}'**
  String transitoDias(int dias);

  /// No description provided for @transitoAceptar.
  ///
  /// In es, this message translates to:
  /// **'Puedo recibirlo'**
  String get transitoAceptar;

  /// No description provided for @transitoRechazar.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get transitoRechazar;

  /// No description provided for @transitoAceptado.
  ///
  /// In es, this message translates to:
  /// **'Aceptado'**
  String get transitoAceptado;

  /// No description provided for @transitoAbrirChat.
  ///
  /// In es, this message translates to:
  /// **'Abrir el chat'**
  String get transitoAbrirChat;

  /// No description provided for @transitoRechazado.
  ///
  /// In es, this message translates to:
  /// **'Dijiste que ahora no.'**
  String get transitoRechazado;

  /// No description provided for @transitoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get transitoCancelado;

  /// No description provided for @transitoTerminado.
  ///
  /// In es, this message translates to:
  /// **'Terminó el tránsito. ¡Gracias!'**
  String get transitoTerminado;

  /// No description provided for @transitoEnUno.
  ///
  /// In es, this message translates to:
  /// **'En un hogar de tránsito'**
  String get transitoEnUno;

  /// No description provided for @transitoRefugioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Hogares de tránsito'**
  String get transitoRefugioTitulo;

  /// No description provided for @transitoRefugioTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Personas de tu zona que cuidan animales hasta que se adopten.'**
  String get transitoRefugioTarjeta;

  /// No description provided for @transitoRefugioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ves solo el primer nombre y el barrio. Si el hogar acepta, se abre un chat para coordinar.'**
  String get transitoRefugioAyuda;

  /// No description provided for @transitoTusPedidos.
  ///
  /// In es, this message translates to:
  /// **'Tus pedidos'**
  String get transitoTusPedidos;

  /// No description provided for @transitoPedidoA.
  ///
  /// In es, this message translates to:
  /// **'{nombre} → {hogar}'**
  String transitoPedidoA(String nombre, String hogar);

  /// No description provided for @transitoEsperando.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta'**
  String get transitoEsperando;

  /// No description provided for @transitoChatCon.
  ///
  /// In es, this message translates to:
  /// **'Chat con {nombre}'**
  String transitoChatCon(String nombre);

  /// No description provided for @transitoCancelarPedido.
  ///
  /// In es, this message translates to:
  /// **'Cancelar el de {nombre}'**
  String transitoCancelarPedido(String nombre);

  /// No description provided for @transitoTerminar.
  ///
  /// In es, this message translates to:
  /// **'Terminó el de {nombre}'**
  String transitoTerminar(String nombre);

  /// No description provided for @transitoHogares.
  ///
  /// In es, this message translates to:
  /// **'Hogares de tu zona'**
  String get transitoHogares;

  /// No description provided for @transitoSinHogares.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay hogares de tránsito en tu zona.'**
  String get transitoSinHogares;

  /// No description provided for @transitoHasta.
  ///
  /// In es, this message translates to:
  /// **'hasta {dias} días'**
  String transitoHasta(int dias);

  /// No description provided for @transitoConPatio.
  ///
  /// In es, this message translates to:
  /// **'con patio'**
  String get transitoConPatio;

  /// No description provided for @transitoConOtros.
  ///
  /// In es, this message translates to:
  /// **'con otros animales'**
  String get transitoConOtros;

  /// No description provided for @transitoConAnimal.
  ///
  /// In es, this message translates to:
  /// **'Ahora tiene un animal en tránsito.'**
  String get transitoConAnimal;

  /// No description provided for @transitoYaPediste.
  ///
  /// In es, this message translates to:
  /// **'Ya le pediste'**
  String get transitoYaPediste;

  /// No description provided for @transitoPedir.
  ///
  /// In es, this message translates to:
  /// **'Pedir'**
  String get transitoPedir;

  /// No description provided for @transitoPedirA.
  ///
  /// In es, this message translates to:
  /// **'Pedirle a {nombre}'**
  String transitoPedirA(String nombre);

  /// No description provided for @transitoNombreAnimal.
  ///
  /// In es, this message translates to:
  /// **'Nombre del animal'**
  String get transitoNombreAnimal;

  /// No description provided for @transitoEspecie.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get transitoEspecie;

  /// No description provided for @transitoTamano.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get transitoTamano;

  /// No description provided for @transitoTamanoSinDecir.
  ///
  /// In es, this message translates to:
  /// **'Sin decir'**
  String get transitoTamanoSinDecir;

  /// No description provided for @transitoCuantosDias.
  ///
  /// In es, this message translates to:
  /// **'Cuántos días (hasta {dias})'**
  String transitoCuantosDias(int dias);

  /// No description provided for @transitoMensaje.
  ///
  /// In es, this message translates to:
  /// **'Mensaje (opcional)'**
  String get transitoMensaje;

  /// No description provided for @transitoPedidoEnviado.
  ///
  /// In es, this message translates to:
  /// **'Pedido enviado. Te avisamos acá cuando responda.'**
  String get transitoPedidoEnviado;

  /// No description provided for @transitoSoloRefugios.
  ///
  /// In es, this message translates to:
  /// **'Solo para refugios y protectoras verificados.'**
  String get transitoSoloRefugios;

  /// No description provided for @transitoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Ese hogar ya no está disponible.'**
  String get transitoNoDisponible;

  /// No description provided for @transitoNoRecibe.
  ///
  /// In es, this message translates to:
  /// **'Ese hogar no recibe ese animal.'**
  String get transitoNoRecibe;

  /// No description provided for @transitoMasDias.
  ///
  /// In es, this message translates to:
  /// **'Son más días de los que puede ese hogar.'**
  String get transitoMasDias;

  /// No description provided for @transitoYaHayUno.
  ///
  /// In es, this message translates to:
  /// **'Ya le pediste algo que todavía no respondió.'**
  String get transitoYaHayUno;

  /// No description provided for @transitoLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de pedidos por hoy.'**
  String get transitoLimite;

  /// No description provided for @listo.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get listo;

  /// No description provided for @packTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pack adopción'**
  String get packTitulo;

  /// No description provided for @packTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Beneficios de comercios de tu zona por haber adoptado.'**
  String get packTarjeta;

  /// No description provided for @packTarjetaNegocio.
  ///
  /// In es, this message translates to:
  /// **'Un beneficio para quien adopta por la app. Es gratis.'**
  String get packTarjetaNegocio;

  /// No description provided for @packIntro.
  ///
  /// In es, this message translates to:
  /// **'Por haber adoptado por la app, estos comercios te dan un beneficio. Pedí el código y mostralo en el local.'**
  String get packIntro;

  /// No description provided for @packSinAdopcion.
  ///
  /// In es, this message translates to:
  /// **'El pack adopción es para quien adoptó por la app en los últimos 6 meses.'**
  String get packSinAdopcion;

  /// No description provided for @packSinBeneficios.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay beneficios en tu zona.'**
  String get packSinBeneficios;

  /// No description provided for @packQuiero.
  ///
  /// In es, this message translates to:
  /// **'Quiero este beneficio'**
  String get packQuiero;

  /// No description provided for @packTuCodigo.
  ///
  /// In es, this message translates to:
  /// **'Tu código:'**
  String get packTuCodigo;

  /// No description provided for @packMostralo.
  ///
  /// In es, this message translates to:
  /// **'Mostralo en el local. Se usa una sola vez.'**
  String get packMostralo;

  /// No description provided for @packUsado.
  ///
  /// In es, this message translates to:
  /// **'Ya lo usaste (código {codigo}).'**
  String packUsado(String codigo);

  /// No description provided for @packNegocioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Quien adoptó por la app pide el código y lo trae. Al canjearlo ves solo su primer nombre y el animal que adoptó.'**
  String get packNegocioAyuda;

  /// No description provided for @packCanjear.
  ///
  /// In es, this message translates to:
  /// **'Canjear un código'**
  String get packCanjear;

  /// No description provided for @packCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código de 6 letras y números'**
  String get packCodigo;

  /// No description provided for @packCanjearBoton.
  ///
  /// In es, this message translates to:
  /// **'Canjear'**
  String get packCanjearBoton;

  /// No description provided for @packCanjeado.
  ///
  /// In es, this message translates to:
  /// **'¡Código canjeado!'**
  String get packCanjeado;

  /// No description provided for @packPara.
  ///
  /// In es, this message translates to:
  /// **'Para {nombre}'**
  String packPara(String nombre);

  /// No description provided for @packAnimal.
  ///
  /// In es, this message translates to:
  /// **'Adoptó a {nombre}'**
  String packAnimal(String nombre);

  /// No description provided for @packTusBeneficios.
  ///
  /// In es, this message translates to:
  /// **'Tus beneficios'**
  String get packTusBeneficios;

  /// No description provided for @packNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo beneficio'**
  String get packNuevo;

  /// No description provided for @packEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar beneficio'**
  String get packEditar;

  /// No description provided for @packSinPropios.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaste ninguno.'**
  String get packSinPropios;

  /// No description provided for @packResumen.
  ///
  /// In es, this message translates to:
  /// **'{pedidos} lo pidieron · {usados} lo usaron'**
  String packResumen(int pedidos, int usados);

  /// No description provided for @packTituloCampo.
  ///
  /// In es, this message translates to:
  /// **'Qué le das'**
  String get packTituloCampo;

  /// No description provided for @packTituloEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Primera consulta con 20 % de descuento'**
  String get packTituloEjemplo;

  /// No description provided for @packDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Condiciones (opcional)'**
  String get packDescripcion;

  /// No description provided for @packSoloVerificados.
  ///
  /// In es, this message translates to:
  /// **'Solo para veterinarias, pet shops, agroveterinarias y peluquerías verificadas.'**
  String get packSoloVerificados;

  /// No description provided for @packDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Podés tener hasta 5 beneficios activos.'**
  String get packDemasiados;

  /// No description provided for @packNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Ese beneficio ya no está disponible.'**
  String get packNoDisponible;

  /// No description provided for @packCodigoInexistente.
  ///
  /// In es, this message translates to:
  /// **'Ese código no es de un beneficio de tu comercio.'**
  String get packCodigoInexistente;

  /// No description provided for @packCodigoUsado.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya se usó.'**
  String get packCodigoUsado;

  /// No description provided for @apadrinarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Apadrinar un refugio'**
  String get apadrinarTitulo;

  /// No description provided for @apadrinarPadrinos.
  ///
  /// In es, this message translates to:
  /// **'Padrinos del refugio'**
  String get apadrinarPadrinos;

  /// No description provided for @apadrinarTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Ayudá a un refugio de tu zona y que se vea en su ficha.'**
  String get apadrinarTarjeta;

  /// No description provided for @apadrinarTarjetaRefugio.
  ///
  /// In es, this message translates to:
  /// **'Comercios que se ofrecen a apadrinarte.'**
  String get apadrinarTarjetaRefugio;

  /// No description provided for @apadrinarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Elegí un refugio verificado de tu zona (o una feria suya) y contá qué aportás. Si el refugio acepta, su ficha muestra «Apadrinado por» con tu nombre.'**
  String get apadrinarAyuda;

  /// No description provided for @apadrinarRefugioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si aceptás, tu ficha (o la del evento) muestra «Apadrinado por» con el nombre del comercio y lo que aporta. Lo podés terminar cuando quieras.'**
  String get apadrinarRefugioAyuda;

  /// No description provided for @apadrinarSinRecibidos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no recibiste ofrecimientos.'**
  String get apadrinarSinRecibidos;

  /// No description provided for @apadrinarTuyos.
  ///
  /// In es, this message translates to:
  /// **'Lo que ofreciste'**
  String get apadrinarTuyos;

  /// No description provided for @apadrinarRefugios.
  ///
  /// In es, this message translates to:
  /// **'Refugios de tu zona'**
  String get apadrinarRefugios;

  /// No description provided for @apadrinarSinRefugios.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay refugios verificados en tu zona.'**
  String get apadrinarSinRefugios;

  /// No description provided for @apadrinarEventos.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 evento próximo} other{{n} eventos próximos}}'**
  String apadrinarEventos(int n);

  /// No description provided for @apadrinarOfrecer.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer'**
  String get apadrinarOfrecer;

  /// No description provided for @apadrinarA.
  ///
  /// In es, this message translates to:
  /// **'Apadrinar a {nombre}'**
  String apadrinarA(String nombre);

  /// No description provided for @apadrinarQue.
  ///
  /// In es, this message translates to:
  /// **'Qué apadrinás'**
  String get apadrinarQue;

  /// No description provided for @apadrinarAlRefugio.
  ///
  /// In es, this message translates to:
  /// **'Al refugio'**
  String get apadrinarAlRefugio;

  /// No description provided for @apadrinarAporte.
  ///
  /// In es, this message translates to:
  /// **'Qué aportás'**
  String get apadrinarAporte;

  /// No description provided for @apadrinarAporteEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Alimento para 20 perros por mes'**
  String get apadrinarAporteEjemplo;

  /// No description provided for @apadrinarFaltaAporte.
  ///
  /// In es, this message translates to:
  /// **'Contá qué aportás.'**
  String get apadrinarFaltaAporte;

  /// No description provided for @apadrinarAceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get apadrinarAceptar;

  /// No description provided for @apadrinarRechazar.
  ///
  /// In es, this message translates to:
  /// **'No, gracias'**
  String get apadrinarRechazar;

  /// No description provided for @apadrinarTerminar.
  ///
  /// In es, this message translates to:
  /// **'Terminar'**
  String get apadrinarTerminar;

  /// No description provided for @apadrinarRetirar.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get apadrinarRetirar;

  /// No description provided for @apadrinarPendiente.
  ///
  /// In es, this message translates to:
  /// **'Esperando que el refugio responda'**
  String get apadrinarPendiente;

  /// No description provided for @apadrinarActivo.
  ///
  /// In es, this message translates to:
  /// **'Activo: se ve en la ficha'**
  String get apadrinarActivo;

  /// No description provided for @apadrinarRechazado.
  ///
  /// In es, this message translates to:
  /// **'El refugio dijo que no'**
  String get apadrinarRechazado;

  /// No description provided for @apadrinarTerminado.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get apadrinarTerminado;

  /// No description provided for @apadrinadoPor.
  ///
  /// In es, this message translates to:
  /// **'Apadrinado por {nombres}'**
  String apadrinadoPor(String nombres);

  /// No description provided for @apadrinarSoloVerificados.
  ///
  /// In es, this message translates to:
  /// **'Solo los comercios verificados pueden apadrinar.'**
  String get apadrinarSoloVerificados;

  /// No description provided for @apadrinarNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Ese refugio o evento ya no está disponible.'**
  String get apadrinarNoDisponible;

  /// No description provided for @apadrinarYaHayUno.
  ///
  /// In es, this message translates to:
  /// **'Ya ofreciste apadrinar eso.'**
  String get apadrinarYaHayUno;

  /// No description provided for @apadrinarLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de ofrecimientos por hoy.'**
  String get apadrinarLimite;

  /// No description provided for @stockNoEsTuya.
  ///
  /// In es, this message translates to:
  /// **'Ese código no está entre las chapitas sin usar de tu stock.'**
  String get stockNoEsTuya;

  /// No description provided for @estadisticasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get estadisticasTitulo;

  /// No description provided for @estadisticasAbrir.
  ///
  /// In es, this message translates to:
  /// **'Ver estadísticas'**
  String get estadisticasAbrir;

  /// No description provided for @estadisticasAbrirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Cuántas personas te ven y te contactan, mes a mes'**
  String get estadisticasAbrirAyuda;

  /// No description provided for @estadisticasEsteMes.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get estadisticasEsteMes;

  /// No description provided for @estadisticasSinDatos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay movimiento para mostrar. Cuando la gente abra tu ficha, lo vas a ver acá.'**
  String get estadisticasSinDatos;

  /// No description provided for @estadisticasAperturas.
  ///
  /// In es, this message translates to:
  /// **'Vieron tu ficha'**
  String get estadisticasAperturas;

  /// No description provided for @estadisticasPersonas.
  ///
  /// In es, this message translates to:
  /// **'Personas distintas'**
  String get estadisticasPersonas;

  /// No description provided for @estadisticasContactos.
  ///
  /// In es, this message translates to:
  /// **'Te contactaron'**
  String get estadisticasContactos;

  /// No description provided for @estadisticasContactosAyuda.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp, llamadas, cómo llegar, web, Instagram, chats, consultas y pedidos'**
  String get estadisticasContactosAyuda;

  /// No description provided for @estadisticasFavoritos.
  ///
  /// In es, this message translates to:
  /// **'Te guardaron en favoritos'**
  String get estadisticasFavoritos;

  /// No description provided for @estadisticasVisitas.
  ///
  /// In es, this message translates to:
  /// **'Dijeron «Fui»'**
  String get estadisticasVisitas;

  /// No description provided for @estadisticasChats.
  ///
  /// In es, this message translates to:
  /// **'Chats nuevos'**
  String get estadisticasChats;

  /// No description provided for @estadisticasCatalogo.
  ///
  /// In es, this message translates to:
  /// **'Abrieron tu catálogo'**
  String get estadisticasCatalogo;

  /// No description provided for @estadisticasConsultas.
  ///
  /// In es, this message translates to:
  /// **'Consultas de productos y servicios'**
  String get estadisticasConsultas;

  /// No description provided for @estadisticasPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get estadisticasPedidos;

  /// No description provided for @estadisticasPagina.
  ///
  /// In es, this message translates to:
  /// **'Visitas a tu página'**
  String get estadisticasPagina;

  /// No description provided for @estadisticasResenas.
  ///
  /// In es, this message translates to:
  /// **'Reseñas nuevas'**
  String get estadisticasResenas;

  /// No description provided for @estadisticasMasQue.
  ///
  /// In es, this message translates to:
  /// **'{p} % más que el mes anterior'**
  String estadisticasMasQue(int p);

  /// No description provided for @estadisticasMenosQue.
  ///
  /// In es, this message translates to:
  /// **'{p} % menos que el mes anterior'**
  String estadisticasMenosQue(int p);

  /// No description provided for @estadisticasIgual.
  ///
  /// In es, this message translates to:
  /// **'Igual que el mes anterior'**
  String get estadisticasIgual;

  /// No description provided for @estadisticasNuevo.
  ///
  /// In es, this message translates to:
  /// **'El mes anterior: {n}'**
  String estadisticasNuevo(int n);

  /// No description provided for @estadisticasPorSemana.
  ///
  /// In es, this message translates to:
  /// **'Últimas 12 semanas'**
  String get estadisticasPorSemana;

  /// No description provided for @estadisticasPorMes.
  ///
  /// In es, this message translates to:
  /// **'Mes a mes'**
  String get estadisticasPorMes;

  /// No description provided for @estadisticasClics.
  ///
  /// In es, this message translates to:
  /// **'Qué tocaron en tu ficha'**
  String get estadisticasClics;

  /// No description provided for @estadisticasSoloResumen.
  ///
  /// In es, this message translates to:
  /// **'Con el plan Básico ves este resumen. Con Destacado o Plus ves todas las métricas, 6 meses y la evolución semana a semana.'**
  String get estadisticasSoloResumen;

  /// No description provided for @estadisticasPrivacidad.
  ///
  /// In es, this message translates to:
  /// **'Son cantidades: nunca se muestra quién fue.'**
  String get estadisticasPrivacidad;

  /// No description provided for @estadisticasSemanaDe.
  ///
  /// In es, this message translates to:
  /// **'Semana del {fecha}'**
  String estadisticasSemanaDe(String fecha);

  /// No description provided for @planTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu plan'**
  String get planTitulo;

  /// No description provided for @planAbrirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Qué incluye, cuándo vence y tus pagos'**
  String get planAbrirAyuda;

  /// No description provided for @planActual.
  ///
  /// In es, this message translates to:
  /// **'Plan {plan}'**
  String planActual(String plan);

  /// No description provided for @planVence.
  ///
  /// In es, this message translates to:
  /// **'Vence el {fecha}'**
  String planVence(String fecha);

  /// No description provided for @planVencido.
  ///
  /// In es, this message translates to:
  /// **'Venció el {fecha}. Tenés 7 días para pagarlo antes de volver a Básico.'**
  String planVencido(String fecha);

  /// No description provided for @planCancelado.
  ///
  /// In es, this message translates to:
  /// **'Diste de baja el plan: sigue hasta el {fecha}.'**
  String planCancelado(String fecha);

  /// No description provided for @planFundador.
  ///
  /// In es, this message translates to:
  /// **'Socio Fundador hasta el {fecha}: sin costo hasta esa fecha.'**
  String planFundador(String fecha);

  /// No description provided for @planPrecio.
  ///
  /// In es, this message translates to:
  /// **'Precio: \$ {precio} por mes'**
  String planPrecio(String precio);

  /// No description provided for @planIncluyeBasico.
  ///
  /// In es, this message translates to:
  /// **'Tu ficha en el mapa, hasta 3 fotos, responder reseñas y un resumen de tus estadísticas.'**
  String get planIncluyeBasico;

  /// No description provided for @planIncluyeDestacado.
  ///
  /// In es, this message translates to:
  /// **'Pin naranja y prioridad en el mapa y las búsquedas, galería de fotos, promoción, web, Instagram y WhatsApp, estadísticas completas y reporte mensual.'**
  String get planIncluyeDestacado;

  /// No description provided for @planIncluyePlus.
  ///
  /// In es, this message translates to:
  /// **'Todo lo de Destacado, más catálogo y pedidos, agenda, socios, servicios publicados y tu página propia.'**
  String get planIncluyePlus;

  /// No description provided for @planMejorar.
  ///
  /// In es, this message translates to:
  /// **'Mejorá tu plan'**
  String get planMejorar;

  /// No description provided for @planQuiero.
  ///
  /// In es, this message translates to:
  /// **'Quiero {plan}'**
  String planQuiero(String plan);

  /// No description provided for @planPedido.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Te vamos a contactar para activarlo.'**
  String get planPedido;

  /// No description provided for @planPedidoAbierto.
  ///
  /// In es, this message translates to:
  /// **'Ya pediste un plan: te vamos a contactar.'**
  String get planPedidoAbierto;

  /// No description provided for @planComoSePaga.
  ///
  /// In es, this message translates to:
  /// **'Por ahora se paga por transferencia o link de pago, de mes a mes. Te mandamos los datos cuando te contactemos.'**
  String get planComoSePaga;

  /// No description provided for @planPagos.
  ///
  /// In es, this message translates to:
  /// **'Tus pagos'**
  String get planPagos;

  /// No description provided for @planPago.
  ///
  /// In es, this message translates to:
  /// **'{fecha} · \$ {monto} · {meses, plural, =1{1 mes} other{{meses} meses}}'**
  String planPago(String fecha, String monto, int meses);

  /// No description provided for @planAntesDespues.
  ///
  /// In es, this message translates to:
  /// **'Desde que pasaste al plan pago'**
  String get planAntesDespues;

  /// No description provided for @planAntesDespuesTexto.
  ///
  /// In es, this message translates to:
  /// **'En {dias} días: {despues} aperturas de tu ficha y {contactosDespues} contactos. En los {dias} días anteriores: {antes} y {contactosAntes}.'**
  String planAntesDespuesTexto(
    int dias,
    int despues,
    int contactosDespues,
    int antes,
    int contactosAntes,
  );

  /// No description provided for @turnoReservar.
  ///
  /// In es, this message translates to:
  /// **'Reservar turno'**
  String get turnoReservar;

  /// No description provided for @turnoReservarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reservar un turno'**
  String get turnoReservarTitulo;

  /// No description provided for @turnoServicio.
  ///
  /// In es, this message translates to:
  /// **'¿Qué servicio?'**
  String get turnoServicio;

  /// No description provided for @turnoSinServicio.
  ///
  /// In es, this message translates to:
  /// **'Consulta general'**
  String get turnoSinServicio;

  /// No description provided for @turnoDia.
  ///
  /// In es, this message translates to:
  /// **'¿Qué día?'**
  String get turnoDia;

  /// No description provided for @turnoHorario.
  ///
  /// In es, this message translates to:
  /// **'¿A qué hora?'**
  String get turnoHorario;

  /// No description provided for @turnoSinHorarios.
  ///
  /// In es, this message translates to:
  /// **'No quedan horarios libres ese día. Probá con otro.'**
  String get turnoSinHorarios;

  /// No description provided for @turnoMascota.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué mascota?'**
  String get turnoMascota;

  /// No description provided for @turnoSinMascotas.
  ///
  /// In es, this message translates to:
  /// **'Primero agregá a tu mascota en la pestaña Mascotas.'**
  String get turnoSinMascotas;

  /// No description provided for @turnoNota.
  ///
  /// In es, this message translates to:
  /// **'Algo que el comercio tenga que saber (opcional)'**
  String get turnoNota;

  /// No description provided for @turnoConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Pedir el turno'**
  String get turnoConfirmar;

  /// No description provided for @turnoPedido.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! El comercio te va a confirmar el turno.'**
  String get turnoPedido;

  /// No description provided for @turnoOcupado.
  ///
  /// In es, this message translates to:
  /// **'Ese horario se acaba de ocupar. Elegí otro.'**
  String get turnoOcupado;

  /// No description provided for @turnoLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de turnos por ahora (3 por comercio, 10 por día).'**
  String get turnoLimite;

  /// No description provided for @turnoNoSePuede.
  ///
  /// In es, this message translates to:
  /// **'No se pudo hacer ese cambio.'**
  String get turnoNoSePuede;

  /// No description provided for @turnoIngresar.
  ///
  /// In es, this message translates to:
  /// **'Ingresá para reservar un turno'**
  String get turnoIngresar;

  /// No description provided for @turnoDuracion.
  ///
  /// In es, this message translates to:
  /// **'{min} min'**
  String turnoDuracion(int min);

  /// No description provided for @misTurnos.
  ///
  /// In es, this message translates to:
  /// **'Mis turnos'**
  String get misTurnos;

  /// No description provided for @misTurnosAyuda.
  ///
  /// In es, this message translates to:
  /// **'Los turnos que pediste y su estado'**
  String get misTurnosAyuda;

  /// No description provided for @misTurnosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no pediste turnos. Los comercios con agenda tienen «Reservar turno» en su ficha.'**
  String get misTurnosVacio;

  /// No description provided for @turnoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar el turno'**
  String get turnoCancelar;

  /// No description provided for @turnoCancelarTexto.
  ///
  /// In es, this message translates to:
  /// **'Se avisa al comercio. Se puede cancelar hasta 2 horas antes.'**
  String get turnoCancelarTexto;

  /// No description provided for @turnoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Turno cancelado.'**
  String get turnoCancelado;

  /// No description provided for @turnoNoCancelable.
  ///
  /// In es, this message translates to:
  /// **'Falta menos de 2 horas: si no podés ir, avisale al comercio por el chat.'**
  String get turnoNoCancelable;

  /// No description provided for @turnoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Esperando confirmación'**
  String get turnoPendiente;

  /// No description provided for @turnoConfirmado.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get turnoConfirmado;

  /// No description provided for @turnoRechazado.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get turnoRechazado;

  /// No description provided for @turnoCanceladoEstado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get turnoCanceladoEstado;

  /// No description provided for @turnoAtendido.
  ///
  /// In es, this message translates to:
  /// **'Atendido'**
  String get turnoAtendido;

  /// No description provided for @turnoCuando.
  ///
  /// In es, this message translates to:
  /// **'{dia} · {hora}'**
  String turnoCuando(String dia, String hora);

  /// No description provided for @agendaModulo.
  ///
  /// In es, this message translates to:
  /// **'Tomar turnos desde la app'**
  String get agendaModulo;

  /// No description provided for @agendaModuloAyuda.
  ///
  /// In es, this message translates to:
  /// **'Aparece «Reservar turno» en tu ficha. Vos confirmás o rechazás cada pedido.'**
  String get agendaModuloAyuda;

  /// No description provided for @agendaConfigurar.
  ///
  /// In es, this message translates to:
  /// **'Cómo das los turnos'**
  String get agendaConfigurar;

  /// No description provided for @agendaDuracion.
  ///
  /// In es, this message translates to:
  /// **'Duración de cada turno'**
  String get agendaDuracion;

  /// No description provided for @agendaALaVez.
  ///
  /// In es, this message translates to:
  /// **'Turnos al mismo tiempo'**
  String get agendaALaVez;

  /// No description provided for @agendaAnticipacion.
  ///
  /// In es, this message translates to:
  /// **'Con cuánta anticipación'**
  String get agendaAnticipacion;

  /// No description provided for @agendaDiasAdelante.
  ///
  /// In es, this message translates to:
  /// **'Hasta cuántos días adelante'**
  String get agendaDiasAdelante;

  /// No description provided for @agendaMinutos.
  ///
  /// In es, this message translates to:
  /// **'{n} min'**
  String agendaMinutos(int n);

  /// No description provided for @agendaHoras.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin anticipación} =1{1 hora antes} other{{n} horas antes}}'**
  String agendaHoras(int n);

  /// No description provided for @agendaDias.
  ///
  /// In es, this message translates to:
  /// **'{n} días'**
  String agendaDias(int n);

  /// No description provided for @agendaHorarioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se usan el horario de tu ficha y la duración de cada servicio (si la tiene).'**
  String get agendaHorarioAyuda;

  /// No description provided for @agendaGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get agendaGuardar;

  /// No description provided for @agendaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Agenda guardada.'**
  String get agendaGuardada;

  /// No description provided for @agendaBloqueados.
  ///
  /// In es, this message translates to:
  /// **'Días sin turnos'**
  String get agendaBloqueados;

  /// No description provided for @agendaBloquear.
  ///
  /// In es, this message translates to:
  /// **'Agregar un día sin turnos'**
  String get agendaBloquear;

  /// No description provided for @agendaSinBloqueados.
  ///
  /// In es, this message translates to:
  /// **'Ninguno por ahora.'**
  String get agendaSinBloqueados;

  /// No description provided for @agendaTurnos.
  ///
  /// In es, this message translates to:
  /// **'Turnos'**
  String get agendaTurnos;

  /// No description provided for @agendaSinTurnos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no te pidieron turnos.'**
  String get agendaSinTurnos;

  /// No description provided for @agendaConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get agendaConfirmar;

  /// No description provided for @agendaRechazar.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get agendaRechazar;

  /// No description provided for @agendaAtendido.
  ///
  /// In es, this message translates to:
  /// **'Atendido'**
  String get agendaAtendido;

  /// No description provided for @agendaCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get agendaCancelar;

  /// No description provided for @agendaCliente.
  ///
  /// In es, this message translates to:
  /// **'{nombre} · {mascota}'**
  String agendaCliente(String nombre, String mascota);

  /// No description provided for @miPlanTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi plan'**
  String get miPlanTitulo;

  /// No description provided for @miPlanAyuda.
  ///
  /// In es, this message translates to:
  /// **'Gratis, Pro o Familia: qué incluye cada uno'**
  String get miPlanAyuda;

  /// No description provided for @miPlanGratis.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get miPlanGratis;

  /// No description provided for @miPlanPro.
  ///
  /// In es, this message translates to:
  /// **'Pro'**
  String get miPlanPro;

  /// No description provided for @miPlanFamilia.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get miPlanFamilia;

  /// No description provided for @miPlanIncluyeGratis.
  ///
  /// In es, this message translates to:
  /// **'Todo lo que cuida a tu mascota: SOS, avisos por zona, chapita QR, foto, mapa, chat y recordatorios de medicación, comida y vacunas. Hasta 2 mascotas.'**
  String get miPlanIncluyeGratis;

  /// No description provided for @miPlanIncluyePro.
  ///
  /// In es, this message translates to:
  /// **'Todo lo de Gratis, más mascotas ilimitadas, sin publicidad, filtros y favoritos guardados, descuentos en comercios adheridos, historial de salud en PDF y temas de color.'**
  String get miPlanIncluyePro;

  /// No description provided for @miPlanIncluyeFamilia.
  ///
  /// In es, this message translates to:
  /// **'Todo lo de Pro, más el hogar compartido: hasta 5 personas cuidan a las mismas mascotas, con tareas y cuidador temporal. Las personas de tu hogar también tienen Pro.'**
  String get miPlanIncluyeFamilia;

  /// No description provided for @miPlanSiempreGratis.
  ///
  /// In es, this message translates to:
  /// **'Lo que hace a la seguridad y la salud de tu mascota es gratis siempre, con cualquier plan.'**
  String get miPlanSiempreGratis;

  /// No description provided for @miPlanPorHogar.
  ///
  /// In es, this message translates to:
  /// **'Tenés Familia porque sos parte de un hogar con ese plan.'**
  String get miPlanPorHogar;

  /// No description provided for @miPlanPrueba.
  ///
  /// In es, this message translates to:
  /// **'Prueba gratis de Familia hasta el {fecha}.'**
  String miPlanPrueba(String fecha);

  /// No description provided for @miPlanVencido.
  ///
  /// In es, this message translates to:
  /// **'Venció el {fecha}. Tenés 7 días para pagarlo antes de volver a Gratis.'**
  String miPlanVencido(String fecha);

  /// No description provided for @miPlanVolverGratis.
  ///
  /// In es, this message translates to:
  /// **'Diste de baja el plan: sigue hasta el {fecha}. Después volvés a Gratis y no perdés nada de lo cargado.'**
  String miPlanVolverGratis(String fecha);

  /// No description provided for @miPlanMascotas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 mascota} other{{n} mascotas}} de {limite}'**
  String miPlanMascotas(int n, int limite);

  /// No description provided for @miPlanPruebaFamilia.
  ///
  /// In es, this message translates to:
  /// **'Al invitar a la primera persona a tu hogar, tenés 30 días gratis de Familia.'**
  String get miPlanPruebaFamilia;

  /// No description provided for @miPlanPedido.
  ///
  /// In es, this message translates to:
  /// **'Ya pediste {plan}: te vamos a contactar.'**
  String miPlanPedido(String plan);

  /// No description provided for @miPlanLimiteMascotas.
  ///
  /// In es, this message translates to:
  /// **'Con el plan Gratis podés tener hasta 2 mascotas. Con Pro o Familia, todas las que quieras.'**
  String get miPlanLimiteMascotas;

  /// No description provided for @miPlanVerPlanes.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get miPlanVerPlanes;

  /// No description provided for @miPlanHogarFamilia.
  ///
  /// In es, this message translates to:
  /// **'El hogar compartido es del plan Familia y ya usaste la prueba gratis de 30 días.'**
  String get miPlanHogarFamilia;

  /// No description provided for @historialPdf.
  ///
  /// In es, this message translates to:
  /// **'Historial en PDF'**
  String get historialPdf;

  /// No description provided for @historialTitulo.
  ///
  /// In es, this message translates to:
  /// **'Historial de salud de {nombre}'**
  String historialTitulo(String nombre);

  /// No description provided for @historialPie.
  ///
  /// In es, this message translates to:
  /// **'Hecho con SOS Mascota el {fecha}'**
  String historialPie(String fecha);

  /// No description provided for @historialSi.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get historialSi;

  /// No description provided for @historialNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get historialNo;

  /// No description provided for @historialNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'En este dispositivo todavía no se puede descargar. Probá desde la web.'**
  String get historialNoDisponible;

  /// No description provided for @mapaFiltrosGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar como mis filtros'**
  String get mapaFiltrosGuardar;

  /// No description provided for @mapaFiltrosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Listo: el mapa va a abrir con estos filtros.'**
  String get mapaFiltrosGuardados;

  /// No description provided for @ajustesLetra.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de letra'**
  String get ajustesLetra;

  /// No description provided for @letraNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get letraNormal;

  /// No description provided for @letraGrande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get letraGrande;

  /// No description provided for @letraMuyGrande.
  ///
  /// In es, this message translates to:
  /// **'Muy grande'**
  String get letraMuyGrande;

  /// No description provided for @descuentosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Descuentos Pro'**
  String get descuentosTitulo;

  /// No description provided for @descuentosTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Descuentos en comercios de tu zona para Pro y Familia'**
  String get descuentosTarjeta;

  /// No description provided for @descuentosTarjetaNegocio.
  ///
  /// In es, this message translates to:
  /// **'Ofrecé un descuento a quienes tienen Pro: te traen clientes y es gratis'**
  String get descuentosTarjetaNegocio;

  /// No description provided for @descuentosIntroPro.
  ///
  /// In es, this message translates to:
  /// **'Pedí tu código y mostralo en el local. Sirve cada vez que vuelvas (una vez por día).'**
  String get descuentosIntroPro;

  /// No description provided for @descuentosIntroGratis.
  ///
  /// In es, this message translates to:
  /// **'Estos comercios tienen descuentos para quienes tienen Pro o Familia.'**
  String get descuentosIntroGratis;

  /// No description provided for @descuentosSinDescuentos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay descuentos en tu zona.'**
  String get descuentosSinDescuentos;

  /// No description provided for @descuentoQuiero.
  ///
  /// In es, this message translates to:
  /// **'Quiero mi código'**
  String get descuentoQuiero;

  /// No description provided for @descuentoMostralo.
  ///
  /// In es, this message translates to:
  /// **'Mostralo en el local antes de pagar.'**
  String get descuentoMostralo;

  /// No description provided for @descuentoSinPro.
  ///
  /// In es, this message translates to:
  /// **'Los descuentos son para quienes tienen Pro o Familia.'**
  String get descuentoSinPro;

  /// No description provided for @descuentoSoloVerificados.
  ///
  /// In es, this message translates to:
  /// **'Para ofrecer descuentos, tu negocio tiene que estar verificado.'**
  String get descuentoSoloVerificados;

  /// No description provided for @descuentoDemasiados.
  ///
  /// In es, this message translates to:
  /// **'Podés tener hasta 5 descuentos activos.'**
  String get descuentoDemasiados;

  /// No description provided for @descuentoNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Ese descuento ya no está disponible.'**
  String get descuentoNoDisponible;

  /// No description provided for @descuentoUsadoHoy.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya se usó hoy. Vale de nuevo mañana.'**
  String get descuentoUsadoHoy;

  /// No description provided for @descuentoVencido.
  ///
  /// In es, this message translates to:
  /// **'Ese descuento venció o está apagado.'**
  String get descuentoVencido;

  /// No description provided for @descuentoCanjeado.
  ///
  /// In es, this message translates to:
  /// **'Descuento válido'**
  String get descuentoCanjeado;

  /// No description provided for @descuentosNegocioAyuda.
  ///
  /// In es, this message translates to:
  /// **'Quien tiene Pro pide su código en la app y te lo muestra. Al canjearlo, la app confirma que su plan sigue vigente. Es gratis para tu negocio.'**
  String get descuentosNegocioAyuda;

  /// No description provided for @descuentosTuyos.
  ///
  /// In es, this message translates to:
  /// **'Tus descuentos'**
  String get descuentosTuyos;

  /// No description provided for @descuentoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo descuento'**
  String get descuentoNuevo;

  /// No description provided for @descuentoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar descuento'**
  String get descuentoEditar;

  /// No description provided for @descuentosSinPropios.
  ///
  /// In es, this message translates to:
  /// **'Todavía no cargaste descuentos.'**
  String get descuentosSinPropios;

  /// No description provided for @descuentoTituloEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: 10 % en baños'**
  String get descuentoTituloEjemplo;

  /// No description provided for @descuentoResumen.
  ///
  /// In es, this message translates to:
  /// **'{pedidos, plural, =1{1 código pedido} other{{pedidos} códigos pedidos}} · usado {usados, plural, =1{1 vez} other{{usados} veces}}'**
  String descuentoResumen(int pedidos, int usados);

  /// No description provided for @panelParaAtender.
  ///
  /// In es, this message translates to:
  /// **'Para atender'**
  String get panelParaAtender;

  /// No description provided for @panelPedidosNuevos.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 pedido nuevo} other{{n} pedidos nuevos}}'**
  String panelPedidosNuevos(int n);

  /// No description provided for @panelTurnosPendientes.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 turno por confirmar} other{{n} turnos por confirmar}}'**
  String panelTurnosPendientes(int n);

  /// No description provided for @planillaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cargar desde una planilla'**
  String get planillaTitulo;

  /// No description provided for @planillaTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Pegá tu lista de productos desde Excel o Google Sheets'**
  String get planillaTarjeta;

  /// No description provided for @planillaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Columnas, en este orden: nombre, descripción, precio y disponible (si o no). Copiá las filas de tu planilla y pegalas acá. Si un producto ya existe con el mismo nombre, se actualiza y conserva su foto.'**
  String get planillaAyuda;

  /// No description provided for @planillaModelo.
  ///
  /// In es, this message translates to:
  /// **'Descargar el modelo'**
  String get planillaModelo;

  /// No description provided for @planillaPegar.
  ///
  /// In es, this message translates to:
  /// **'Pegá acá las filas'**
  String get planillaPegar;

  /// No description provided for @planillaRevisar.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get planillaRevisar;

  /// No description provided for @planillaResumen.
  ///
  /// In es, this message translates to:
  /// **'{nuevos, plural, =1{1 producto nuevo} other{{nuevos} productos nuevos}} · {actualizados, plural, =1{1 se actualiza} other{{actualizados} se actualizan}} · {errores, plural, =0{sin errores} =1{1 fila con error} other{{errores} filas con error}}'**
  String planillaResumen(int nuevos, int actualizados, int errores);

  /// No description provided for @planillaErrorFila.
  ///
  /// In es, this message translates to:
  /// **'Fila {fila}: {motivo}'**
  String planillaErrorFila(int fila, String motivo);

  /// No description provided for @planillaSinNombre.
  ///
  /// In es, this message translates to:
  /// **'falta el nombre'**
  String get planillaSinNombre;

  /// No description provided for @planillaNombreLargo.
  ///
  /// In es, this message translates to:
  /// **'el nombre tiene más de 80 letras'**
  String get planillaNombreLargo;

  /// No description provided for @planillaPrecioInvalido.
  ///
  /// In es, this message translates to:
  /// **'el precio no es un número'**
  String get planillaPrecioInvalido;

  /// No description provided for @planillaRepetido.
  ///
  /// In es, this message translates to:
  /// **'el nombre está repetido en la planilla'**
  String get planillaRepetido;

  /// No description provided for @planillaCargar.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Cargar 1 producto} other{Cargar {n} productos}}'**
  String planillaCargar(int n);

  /// No description provided for @planillaLimite.
  ///
  /// In es, this message translates to:
  /// **'Se llegó al máximo de 200 productos. Se cargaron {n}.'**
  String planillaLimite(int n);

  /// No description provided for @reporteDescargar.
  ///
  /// In es, this message translates to:
  /// **'Descargar el reporte del mes en PDF'**
  String get reporteDescargar;

  /// No description provided for @reporteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reporte de {mes}'**
  String reporteTitulo(String mes);

  /// No description provided for @cuidadoPaseo.
  ///
  /// In es, this message translates to:
  /// **'Paseo'**
  String get cuidadoPaseo;

  /// No description provided for @cuidadoGuarderia.
  ///
  /// In es, this message translates to:
  /// **'Guardería de día'**
  String get cuidadoGuarderia;

  /// No description provided for @cuidadoEstadia.
  ///
  /// In es, this message translates to:
  /// **'Estadía'**
  String get cuidadoEstadia;

  /// No description provided for @cuidadoVisitas.
  ///
  /// In es, this message translates to:
  /// **'Visitas a domicilio'**
  String get cuidadoVisitas;

  /// No description provided for @cuidadoManana.
  ///
  /// In es, this message translates to:
  /// **'De mañana'**
  String get cuidadoManana;

  /// No description provided for @cuidadoTarde.
  ///
  /// In es, this message translates to:
  /// **'De tarde'**
  String get cuidadoTarde;

  /// No description provided for @cuidadoNoche.
  ///
  /// In es, this message translates to:
  /// **'De noche'**
  String get cuidadoNoche;

  /// No description provided for @cuidadoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta'**
  String get cuidadoPendiente;

  /// No description provided for @cuidadoAceptado.
  ///
  /// In es, this message translates to:
  /// **'Aceptado: coordinen por el chat'**
  String get cuidadoAceptado;

  /// No description provided for @cuidadoRechazado.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get cuidadoRechazado;

  /// No description provided for @cuidadoCanceladoEstado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get cuidadoCanceladoEstado;

  /// No description provided for @cuidadoTerminado.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get cuidadoTerminado;

  /// No description provided for @cuidadoElDia.
  ///
  /// In es, this message translates to:
  /// **'el {dia}'**
  String cuidadoElDia(String dia);

  /// No description provided for @cuidadoDelAl.
  ///
  /// In es, this message translates to:
  /// **'del {desde} al {hasta}'**
  String cuidadoDelAl(String desde, String hasta);

  /// No description provided for @cuidadoSinLugar.
  ///
  /// In es, this message translates to:
  /// **'No le queda lugar en alguno de esos días. Probá con otras fechas.'**
  String get cuidadoSinLugar;

  /// No description provided for @cuidadoLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo de pedidos por ahora (3 por prestador, 10 por día).'**
  String get cuidadoLimite;

  /// No description provided for @cuidadoFueraDeRango.
  ///
  /// In es, this message translates to:
  /// **'Esas fechas no se pueden pedir todavía.'**
  String get cuidadoFueraDeRango;

  /// No description provided for @cuidadoContratar.
  ///
  /// In es, this message translates to:
  /// **'Contratar: {servicios}'**
  String cuidadoContratar(String servicios);

  /// No description provided for @cuidadoIngresar.
  ///
  /// In es, this message translates to:
  /// **'Ingresá para contratar un paseo o una estadía'**
  String get cuidadoIngresar;

  /// No description provided for @cuidadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Contratar'**
  String get cuidadoTitulo;

  /// No description provided for @cuidadoCondiciones.
  ///
  /// In es, this message translates to:
  /// **'Condiciones del prestador'**
  String get cuidadoCondiciones;

  /// No description provided for @cuidadoQue.
  ///
  /// In es, this message translates to:
  /// **'¿Qué necesitás?'**
  String get cuidadoQue;

  /// No description provided for @cuidadoFechas.
  ///
  /// In es, this message translates to:
  /// **'¿Qué días?'**
  String get cuidadoFechas;

  /// No description provided for @cuidadoElegirFechas.
  ///
  /// In es, this message translates to:
  /// **'Elegir las fechas'**
  String get cuidadoElegirFechas;

  /// No description provided for @cuidadoMaximoDias.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Un día por pedido.} other{Hasta {n} días seguidos por pedido.}}'**
  String cuidadoMaximoDias(int n);

  /// No description provided for @cuidadoFranja.
  ///
  /// In es, this message translates to:
  /// **'¿En qué momento del día?'**
  String get cuidadoFranja;

  /// No description provided for @cuidadoSinFranja.
  ///
  /// In es, this message translates to:
  /// **'Me da igual'**
  String get cuidadoSinFranja;

  /// No description provided for @cuidadoMascotas.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué mascotas? (hasta 5)'**
  String get cuidadoMascotas;

  /// No description provided for @cuidadoNota.
  ///
  /// In es, this message translates to:
  /// **'Lo que tenga que saber: horarios, comida, medicación, carácter (opcional)'**
  String get cuidadoNota;

  /// No description provided for @cuidadoComoSigue.
  ///
  /// In es, this message translates to:
  /// **'Si acepta, se abre el chat para acordar la dirección, el precio y el pago. Tu teléfono y tu dirección no se comparten.'**
  String get cuidadoComoSigue;

  /// No description provided for @cuidadoEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar el pedido'**
  String get cuidadoEnviar;

  /// No description provided for @cuidadoPedido.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Te avisamos cuando responda.'**
  String get cuidadoPedido;

  /// No description provided for @misCuidados.
  ///
  /// In es, this message translates to:
  /// **'Mis paseos y estadías'**
  String get misCuidados;

  /// No description provided for @misCuidadosAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lo que pediste a paseadores, hoteles y cuidadores'**
  String get misCuidadosAyuda;

  /// No description provided for @misCuidadosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no pediste nada. Los paseadores y hoteles que toman pedidos tienen «Contratar» en su ficha.'**
  String get misCuidadosVacio;

  /// No description provided for @cuidadoChat.
  ///
  /// In es, this message translates to:
  /// **'Abrir el chat'**
  String get cuidadoChat;

  /// No description provided for @cuidadoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar el pedido'**
  String get cuidadoCancelar;

  /// No description provided for @cuidadoCancelarTexto.
  ///
  /// In es, this message translates to:
  /// **'Se avisa al prestador. Un pedido aceptado se cancela hasta el día anterior.'**
  String get cuidadoCancelarTexto;

  /// No description provided for @cuidadoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Pedido cancelado.'**
  String get cuidadoCancelado;

  /// No description provided for @cuidadoNoCancelable.
  ///
  /// In es, this message translates to:
  /// **'Ya empezó: si necesitás cambiar algo, escribile por el chat.'**
  String get cuidadoNoCancelable;

  /// No description provided for @cuidadosTab.
  ///
  /// In es, this message translates to:
  /// **'Paseos y estadías'**
  String get cuidadosTab;

  /// No description provided for @cuidadosTurnosTab.
  ///
  /// In es, this message translates to:
  /// **'Turnos'**
  String get cuidadosTurnosTab;

  /// No description provided for @cuidadosQueOfreces.
  ///
  /// In es, this message translates to:
  /// **'Qué ofrecés'**
  String get cuidadosQueOfreces;

  /// No description provided for @cuidadosQueOfrecesAyuda.
  ///
  /// In es, this message translates to:
  /// **'Aparece «Contratar» en tu ficha. Vos aceptás o rechazás cada pedido; al aceptar se abre el chat.'**
  String get cuidadosQueOfrecesAyuda;

  /// No description provided for @cuidadosCupo.
  ///
  /// In es, this message translates to:
  /// **'Mascotas por día (guardería y estadía)'**
  String get cuidadosCupo;

  /// No description provided for @cuidadosMaximoDias.
  ///
  /// In es, this message translates to:
  /// **'Días seguidos como máximo'**
  String get cuidadosMaximoDias;

  /// No description provided for @cuidadosCondiciones.
  ///
  /// In es, this message translates to:
  /// **'Condiciones (vacunas, tamaño, qué traer…)'**
  String get cuidadosCondiciones;

  /// No description provided for @cuidadosPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get cuidadosPedidos;

  /// No description provided for @cuidadosSinPedidos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no te pidieron nada.'**
  String get cuidadosSinPedidos;

  /// No description provided for @cuidadosAceptar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y abrir el chat'**
  String get cuidadosAceptar;

  /// No description provided for @cuidadosTerminado.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get cuidadosTerminado;

  /// No description provided for @panelCuidadosPendientes.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 pedido de paseo o estadía} other{{n} pedidos de paseo o estadía}}'**
  String panelCuidadosPendientes(int n);

  /// No description provided for @cuidadosPrenderAgenda.
  ///
  /// In es, this message translates to:
  /// **'Para que aparezca «Contratar» en tu ficha, prendé «Tomar turnos desde la app» en Turnos.'**
  String get cuidadosPrenderAgenda;

  /// No description provided for @comunidadPregunta.
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get comunidadPregunta;

  /// No description provided for @comunidadConsejo.
  ///
  /// In es, this message translates to:
  /// **'Consejo'**
  String get comunidadConsejo;

  /// No description provided for @comunidadExperiencia.
  ///
  /// In es, this message translates to:
  /// **'Experiencia'**
  String get comunidadExperiencia;

  /// No description provided for @comunidadProhibido.
  ///
  /// In es, this message translates to:
  /// **'En la comunidad no se publican ventas ni cruzas de animales. Para dar en adopción está la sección Adopción.'**
  String get comunidadProhibido;

  /// No description provided for @comunidadUnite.
  ///
  /// In es, this message translates to:
  /// **'Unite al grupo para participar'**
  String get comunidadUnite;

  /// No description provided for @comunidadLimite.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al máximo por hoy. Probá mañana.'**
  String get comunidadLimite;

  /// No description provided for @comunidadNoQuiere.
  ///
  /// In es, this message translates to:
  /// **'Esa persona no quiere chatear por ahora.'**
  String get comunidadNoQuiere;

  /// No description provided for @comunidadGrupos.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get comunidadGrupos;

  /// No description provided for @comunidadGruposAyuda.
  ///
  /// In es, this message translates to:
  /// **'Por raza, especie y temas: preguntas, consejos y experiencias'**
  String get comunidadGruposAyuda;

  /// No description provided for @comunidadReglas.
  ///
  /// In es, this message translates to:
  /// **'Sin ventas ni cruzas de animales, y sin datos de dónde vive tu mascota. De cada persona se ve solo el primer nombre.'**
  String get comunidadReglas;

  /// No description provided for @comunidadIngresar.
  ///
  /// In es, this message translates to:
  /// **'Ingresá para participar en los grupos'**
  String get comunidadIngresar;

  /// No description provided for @comunidadSaludos.
  ///
  /// In es, this message translates to:
  /// **'Saludos'**
  String get comunidadSaludos;

  /// No description provided for @comunidadTuRaza.
  ///
  /// In es, this message translates to:
  /// **'Sumate al grupo de la raza de tu mascota'**
  String get comunidadTuRaza;

  /// No description provided for @comunidadMisGrupos.
  ///
  /// In es, this message translates to:
  /// **'Tus grupos'**
  String get comunidadMisGrupos;

  /// No description provided for @comunidadPorEspecie.
  ///
  /// In es, this message translates to:
  /// **'Por especie'**
  String get comunidadPorEspecie;

  /// No description provided for @comunidadTemas.
  ///
  /// In es, this message translates to:
  /// **'Temas'**
  String get comunidadTemas;

  /// No description provided for @comunidadPorRaza.
  ///
  /// In es, this message translates to:
  /// **'Por raza'**
  String get comunidadPorRaza;

  /// No description provided for @comunidadMiembros.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin integrantes todavía} =1{1 integrante} other{{n} integrantes}}'**
  String comunidadMiembros(int n);

  /// No description provided for @comunidadActividad.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 publicación esta semana} other{{n} publicaciones esta semana}}'**
  String comunidadActividad(int n);

  /// No description provided for @comunidadSalir.
  ///
  /// In es, this message translates to:
  /// **'Salir del grupo'**
  String get comunidadSalir;

  /// No description provided for @comunidadPublicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get comunidadPublicar;

  /// No description provided for @comunidadUnirme.
  ///
  /// In es, this message translates to:
  /// **'Unirme al grupo'**
  String get comunidadUnirme;

  /// No description provided for @comunidadSinPublicaciones.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay publicaciones. ¡Hacé la primera pregunta!'**
  String get comunidadSinPublicaciones;

  /// No description provided for @comunidadAlguien.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get comunidadAlguien;

  /// No description provided for @comunidadFoto.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get comunidadFoto;

  /// No description provided for @comunidadComentarios.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin comentarios} =1{1 comentario} other{{n} comentarios}}'**
  String comunidadComentarios(int n);

  /// No description provided for @comunidadBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get comunidadBorrar;

  /// No description provided for @comunidadSaludar.
  ///
  /// In es, this message translates to:
  /// **'Saludar'**
  String get comunidadSaludar;

  /// No description provided for @comunidadSaludarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si acepta, se abre el chat. No compartas tu dirección ni tu teléfono.'**
  String get comunidadSaludarAyuda;

  /// No description provided for @comunidadMotivoVenta.
  ///
  /// In es, this message translates to:
  /// **'vende o cruza animales'**
  String get comunidadMotivoVenta;

  /// No description provided for @comunidadMotivoUbicacion.
  ///
  /// In es, this message translates to:
  /// **'muestra dónde vive una mascota'**
  String get comunidadMotivoUbicacion;

  /// No description provided for @comunidadReportar.
  ///
  /// In es, this message translates to:
  /// **'Reportar: {motivo}'**
  String comunidadReportar(String motivo);

  /// No description provided for @comunidadBorrado.
  ///
  /// In es, this message translates to:
  /// **'Borrado.'**
  String get comunidadBorrado;

  /// No description provided for @comunidadSaludado.
  ///
  /// In es, this message translates to:
  /// **'Saludo enviado. Si acepta, lo vas a ver en Saludos y en tus chats.'**
  String get comunidadSaludado;

  /// No description provided for @comunidadSaludoInicial.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Vi lo que escribiste en el grupo y me gustaría charlar.'**
  String get comunidadSaludoInicial;

  /// No description provided for @comunidadMandarSaludo.
  ///
  /// In es, this message translates to:
  /// **'Mandar el saludo'**
  String get comunidadMandarSaludo;

  /// No description provided for @comunidadOpciones.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get comunidadOpciones;

  /// No description provided for @comunidadComentar.
  ///
  /// In es, this message translates to:
  /// **'Escribí un comentario'**
  String get comunidadComentar;

  /// No description provided for @comunidadNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Esta publicación ya no está disponible.'**
  String get comunidadNoDisponible;

  /// No description provided for @comunidadTexto.
  ///
  /// In es, this message translates to:
  /// **'¿Qué querés contar o preguntar?'**
  String get comunidadTexto;

  /// No description provided for @comunidadAgregarFoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get comunidadAgregarFoto;

  /// No description provided for @comunidadSinSaludos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay saludos. Desde una publicación o un comentario podés saludar a quien lo escribió.'**
  String get comunidadSinSaludos;

  /// No description provided for @comunidadSaludoDe.
  ///
  /// In es, this message translates to:
  /// **'{nombre} te saluda'**
  String comunidadSaludoDe(String nombre);

  /// No description provided for @comunidadSaludoA.
  ///
  /// In es, this message translates to:
  /// **'Saludaste a {nombre}'**
  String comunidadSaludoA(String nombre);

  /// No description provided for @comunidadSobre.
  ///
  /// In es, this message translates to:
  /// **'Sobre: «{texto}»'**
  String comunidadSobre(String texto);

  /// No description provided for @comunidadAceptarSaludo.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y abrir el chat'**
  String get comunidadAceptarSaludo;

  /// No description provided for @comunidadAhoraNo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get comunidadAhoraNo;

  /// No description provided for @comunidadEsperando.
  ///
  /// In es, this message translates to:
  /// **'Esperando respuesta'**
  String get comunidadEsperando;

  /// No description provided for @comunidadNoAhora.
  ///
  /// In es, this message translates to:
  /// **'No aceptó por ahora'**
  String get comunidadNoAhora;

  /// No description provided for @equipoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get equipoTitulo;

  /// No description provided for @equipoAbrirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Sumá personas para que atiendan pedidos, turnos y el catálogo'**
  String get equipoAbrirAyuda;

  /// No description provided for @equipoAyudaDuenio.
  ///
  /// In es, this message translates to:
  /// **'Las personas del equipo atienden pedidos, turnos, paseos y estadías, socios, canjes y el catálogo. La ficha, el plan, las estadísticas y la configuración siguen siendo solo tuyos. Entre ustedes se ven solo el primer nombre.'**
  String get equipoAyudaDuenio;

  /// No description provided for @equipoAyudaEmpleado.
  ///
  /// In es, this message translates to:
  /// **'Sos parte del equipo de este negocio: atendés pedidos, turnos, paseos y estadías, socios, canjes y el catálogo. La ficha, el plan, las estadísticas y la configuración los maneja el dueño.'**
  String get equipoAyudaEmpleado;

  /// No description provided for @equipoSoloPlus.
  ///
  /// In es, this message translates to:
  /// **'El equipo es del plan Plus.'**
  String get equipoSoloPlus;

  /// No description provided for @equipoVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no sumaste a nadie.'**
  String get equipoVacio;

  /// No description provided for @equipoInvitar.
  ///
  /// In es, this message translates to:
  /// **'Invitar a alguien'**
  String get equipoInvitar;

  /// No description provided for @equipoLleno.
  ///
  /// In es, this message translates to:
  /// **'El equipo ya tiene {n} personas.'**
  String equipoLleno(int n);

  /// No description provided for @equipoDesde.
  ///
  /// In es, this message translates to:
  /// **'Desde el {fecha}'**
  String equipoDesde(String fecha);

  /// No description provided for @equipoQuitar.
  ///
  /// In es, this message translates to:
  /// **'Sacar del equipo'**
  String get equipoQuitar;

  /// No description provided for @equipoQuitarPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Sacar a {nombre} del equipo? Va a dejar de ver los pedidos y la agenda del negocio.'**
  String equipoQuitarPregunta(String nombre);

  /// No description provided for @equipoIrme.
  ///
  /// In es, this message translates to:
  /// **'Dejar el equipo'**
  String get equipoIrme;

  /// No description provided for @equipoIrmePregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Dejar el equipo de {negocio}? Para volver, el dueño te tiene que invitar de nuevo.'**
  String equipoIrmePregunta(String negocio);

  /// No description provided for @equipoInvitaciones.
  ///
  /// In es, this message translates to:
  /// **'Invitaciones sin usar'**
  String get equipoInvitaciones;

  /// No description provided for @equipoVence.
  ///
  /// In es, this message translates to:
  /// **'{codigo} · vence el {fecha}'**
  String equipoVence(String codigo, String fecha);

  /// No description provided for @equipoAnular.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get equipoAnular;

  /// No description provided for @equipoInvitacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Invitación al equipo'**
  String get equipoInvitacionTitulo;

  /// No description provided for @equipoInvitacionTexto.
  ///
  /// In es, this message translates to:
  /// **'Mandale este enlace a quien quieras sumar. Sirve una sola vez y vence en 7 días. También puede escribir el código en la app: {codigo}'**
  String equipoInvitacionTexto(String codigo);

  /// No description provided for @equipoMensajeInvitacion.
  ///
  /// In es, this message translates to:
  /// **'Te invito al equipo de {negocio} en SOS Mascota: {enlace}'**
  String equipoMensajeInvitacion(String negocio, String enlace);

  /// No description provided for @equipoTengoCodigo.
  ///
  /// In es, this message translates to:
  /// **'Tengo un código de equipo'**
  String get equipoTengoCodigo;

  /// No description provided for @equipoCodigo.
  ///
  /// In es, this message translates to:
  /// **'Código o enlace'**
  String get equipoCodigo;

  /// No description provided for @unirmeEquipoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Invitación a un equipo'**
  String get unirmeEquipoTitulo;

  /// No description provided for @unirmeEquipoTexto.
  ///
  /// In es, this message translates to:
  /// **'Te invitaron a ser parte del equipo de un negocio en SOS Mascota. Vas a atender pedidos, turnos y el catálogo desde el modo comercio. El dueño y el equipo van a ver tu primer nombre (nunca tu correo).'**
  String get unirmeEquipoTexto;

  /// No description provided for @unirmeEquipoBoton.
  ///
  /// In es, this message translates to:
  /// **'Unirme al equipo'**
  String get unirmeEquipoBoton;

  /// No description provided for @unirmeEquipoListo.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya sos parte del equipo.'**
  String get unirmeEquipoListo;

  /// No description provided for @equipoErrorCodigo.
  ///
  /// In es, this message translates to:
  /// **'Este código no existe, ya se usó o venció. Pedile uno nuevo al dueño.'**
  String get equipoErrorCodigo;

  /// No description provided for @equipoErrorDuenio.
  ///
  /// In es, this message translates to:
  /// **'Este código es de tu propio negocio: mandáselo a quien quieras sumar.'**
  String get equipoErrorDuenio;
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
