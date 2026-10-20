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
