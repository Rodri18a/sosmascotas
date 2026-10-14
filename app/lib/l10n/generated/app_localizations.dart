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
