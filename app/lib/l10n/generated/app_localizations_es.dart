// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNombre => 'SOS Mascota';

  @override
  String get pestanaMapa => 'Mapa';

  @override
  String get pestanaSos => 'SOS';

  @override
  String get pestanaMascotas => 'Mis mascotas';

  @override
  String get pestanaAyuda => 'Ayuda';

  @override
  String get mapaDescripcion =>
      'Veterinarias de urgencia y mascotas perdidas cerca tuyo';

  @override
  String get sosDescripcion => 'Reportá una mascota perdida o encontrada';

  @override
  String get mascotasDescripcion => 'Tus mascotas, su ficha y su chapita QR';

  @override
  String get ayudaDescripcion =>
      'Urgencias, refugios y grupos de difusión de tu zona';

  @override
  String enConstruccionPaso(String paso) {
    return 'Llega en el paso $paso';
  }

  @override
  String get ajustes => 'Ajustes';

  @override
  String get ajustesPerfil => 'Perfil, avisos y cuenta';

  @override
  String get ajustesDesarrollo => 'Desarrollo';

  @override
  String get conexionConectado => 'Conectado a Supabase dev ✅';

  @override
  String get conexionSinConfigurar =>
      'Falta configurar Supabase (config/dev.json) ⚠️';

  @override
  String get conexionSinConexion => 'Sin conexión a Supabase ❌';

  @override
  String get conexionConectando => 'Conectando con Supabase…';

  @override
  String get ingresarTitulo => 'Ingresar';

  @override
  String get ingresarExplicacion =>
      'Ingresá o creá tu cuenta con tu correo. Te mandamos un código: no hace falta contraseña.';

  @override
  String get ingresarCorreo => 'Tu correo';

  @override
  String get ingresarEnviarCodigo => 'Enviarme el código';

  @override
  String ingresarRevisaCorreo(String email) {
    return 'Te mandamos un correo a $email. Tocá el enlace del correo o escribí acá el código de 6 números.';
  }

  @override
  String get ingresarCodigo => 'Código';

  @override
  String get ingresarConfirmar => 'Ingresar';

  @override
  String get ingresarOtroCorreo => 'Usar otro correo';

  @override
  String get ingresarEmailInvalido =>
      'Revisá el correo: parece que le falta algo.';

  @override
  String get ingresarCodigoInvalido => 'El código tiene 6 números.';

  @override
  String get ingresarAvisoTerminos =>
      'Al crear tu cuenta te vamos a pedir que aceptes los términos y la política de privacidad.';

  @override
  String get ingresarOCrearCuenta => 'Ingresar o crear cuenta';

  @override
  String get ingresarSubtitulo =>
      'Para reportar, guardar tus mascotas y recibir avisos';

  @override
  String get cerrarSesion => 'Cerrar sesión';

  @override
  String get errorDemasiadosIntentos =>
      'Hiciste muchos intentos seguidos. Esperá unos minutos y probá de nuevo.';

  @override
  String get errorCodigoInvalido =>
      'El código no es correcto o ya venció. Pedí uno nuevo.';

  @override
  String get errorSinConexion =>
      'No pudimos conectarnos. Revisá tu internet y probá de nuevo.';

  @override
  String get errorNoConfigurado =>
      'El ingreso no está disponible en este momento.';

  @override
  String get errorDesconocido => 'Algo salió mal. Probá de nuevo en un rato.';

  @override
  String get ingresarConGoogle => 'Continuar con Google';

  @override
  String get ingresarOConCorreo => 'o con tu correo';

  @override
  String get cuentaNecesariaTitulo => 'Necesitás una cuenta';

  @override
  String get ahoraNo => 'Ahora no';

  @override
  String get sosReportar => 'Reportar mascota perdida o encontrada';

  @override
  String get sosMotivoCuenta =>
      'Para reportar necesitamos poder avisarte cuando alguien vea a la mascota. Tu teléfono nunca se muestra.';

  @override
  String get sosNuevoTitulo => 'Nuevo reporte';

  @override
  String get sosNuevoDescripcion =>
      'Foto, ubicación en el mapa y datos de la mascota';

  @override
  String get mascotasAgregar => 'Agregar mascota';

  @override
  String get mascotasMotivoCuenta =>
      'Para guardar tus mascotas, su ficha y su chapita QR, y recibir avisos si alguien la encuentra.';

  @override
  String get mascotaNuevaTitulo => 'Nueva mascota';

  @override
  String get mascotaNuevaDescripcion =>
      'Nombre, especie, raza y foto de tu mascota';

  @override
  String get legalTerminos => 'Términos y condiciones';

  @override
  String get legalPrivacidad => 'Política de privacidad';

  @override
  String get consentimientoTitulo => 'Antes de empezar';

  @override
  String get consentimientoExplicacion =>
      'Para usar tu cuenta necesitamos que leas y aceptes cómo funciona SOS Mascota y cómo cuidamos tus datos. En resumen:';

  @override
  String get consentimientoTelefono =>
      'Tu teléfono nunca se muestra a otras personas.';

  @override
  String get consentimientoUbicacion =>
      'Solo guardamos una zona aproximada, nunca tu ubicación exacta.';

  @override
  String get consentimientoMetricas =>
      'Medimos el uso de la app de forma anónima. No vendemos tus datos.';

  @override
  String get consentimientoBorrar => 'Podés borrar tu cuenta cuando quieras.';

  @override
  String get consentimientoCasilla =>
      'Leí y acepto los términos y la política de privacidad';

  @override
  String get consentimientoAceptar => 'Aceptar y continuar';

  @override
  String get consentimientoNoAcepto => 'No acepto (cerrar sesión)';
}
