/// Textos del portal de administración (en voseo, como la app). El portal es
/// una herramienta interna: los textos están acá y no en un .arb (D76).
abstract final class T {
  static const titulo = 'SOS Mascota · Administración';
  static const ingresar = 'Ingresar';
  static const correo = 'Correo';
  static const enviarCodigo = 'Enviarme el código';
  static const codigoEnviado =
      'Te mandamos un correo. Escribí el código o tocá el enlace.';
  static const codigo = 'Código';
  static const entrar = 'Entrar';
  static const salir = 'Salir';
  static const noSePudo = 'No se pudo. Revisá los datos y probá de nuevo.';
  static const sinPermiso =
      'Esta cuenta no tiene permiso de administración. El rol lo da solo la base de datos.';
  static const errorConexion = 'No pudimos conectarnos. Probá de nuevo.';
  static const reintentar = 'Reintentar';

  // Secciones
  static const panel = 'Panel';
  static const moderacion = 'Moderación';
  static const lugares = 'Lugares';
  static const prospectos = 'Prospectos';
  static const ayuda = 'Ayuda';

  // Panel
  static const ultimos = 'Últimos';
  static const usuarios = 'Usuarios';
  static const usuariosNuevos = 'Usuarios nuevos';
  static const activosDia = 'Activos hoy';
  static const activosSemana = 'Activos en 7 días';
  static const activosMes = 'Activos en 30 días';
  static const mascotas = 'Mascotas';
  static const hogares = 'Hogares compartidos';
  static const sosActivos = 'SOS activos';
  static const sosPublicados = 'SOS publicados';
  static const sosResueltos = 'SOS resueltos';
  static const diasHastaResolver = 'Días hasta resolverse';
  static const escaneos = 'Escaneos de QR';
  static const avisos = 'Avisos al dueño';
  static const pendientes = 'Pendientes de moderar';
  static const comerciosPorRubro = 'Comercios por rubro';
  static const comerciosPorEstado = 'Comercios por estado';
  static const sinDatos = 'Sin datos todavía';

  // Moderación
  static const colaVacia = 'No hay nada para moderar.';
  static const aprobar = 'Aprobar';
  static const eliminar = 'Eliminar';
  static const advertir = 'Advertir';
  static const bloquear = 'Bloquear 30 días';
  static const historial = 'Historial';
  static const reportes = 'reportes';
  static const oculto = 'Oculto por reportes';
  static const sos = 'SOS';
  static const mensaje = 'Mensaje del chat';
  static const hecho = 'Listo.';
  static const motivo = 'Motivo (queda registrado)';
  static const confirmar = 'Confirmar';
  static const cancelar = 'Cancelar';
  static const bloqueado = 'Bloqueado';
  static const sanciones = 'Sanciones';
  static const levantar = 'Levantar';

  // Lugares
  static const buscar = 'Buscar por nombre';
  static const nuevoLugar = 'Nuevo lugar';
  static const editarLugar = 'Editar lugar';
  static const nombre = 'Nombre';
  static const rubro = 'Rubro';
  static const modalidad = 'Modalidad';
  static const direccion = 'Dirección';
  static const lat = 'Latitud';
  static const lng = 'Longitud';
  static const latLngAyuda =
      'Copiá las coordenadas de Google Maps (clic derecho en el lugar). Sin geocodificación: regla de costo.';
  static const telefono = 'Teléfono';
  static const whatsapp = 'WhatsApp';
  static const web = 'Web (https://…)';
  static const instagram = 'Instagram (sin @)';
  static const descripcion = 'Descripción';
  static const es24h = 'Abierto 24 h';
  static const urgencias = 'Atiende urgencias';
  static const verificado = 'Verificado ✔️';
  static const renac = 'Operador RENAC (coloca microchip)';
  static const visible = 'Visible en el mapa';
  static const horario = 'Horario (JSON por día)';
  static const horarioAyuda =
      'Ej.: {"mon": [["09:00","19:00"]], "sat": [["09:00","13:00"]]}';
  static const guardar = 'Guardar';
  static const aperturas = 'aperturas (30 días)';
  static const favoritos = 'favoritos';
  static const ejemplo = 'ejemplo';
  static const datosInvalidos =
      'Hay datos inválidos (revisá coordenadas, teléfonos, web o el horario).';

  // Comercios (1.3)
  static const comercios = 'Comercios';
  static const sinPendientes = 'No hay reclamos ni pedidos pendientes.';
  static const rechazar = 'Rechazar';
  static const tiposPendiente = {
    'claim': 'Reclamo de un lugar sin dueño',
    'dispute': 'Disputa (el lugar ya tiene dueño)',
    'verification': 'Pedido de verificación ✔️',
    'renac': 'Pedido de insignia Operador RENAC',
  };
  static const rut = 'RUT';
  static const socioFundador = 'Socio Fundador hasta…';
  static const revisarRenac =
      'Verificá el RUT contra el listado oficial de operadores RENAC del MGAP antes de aprobar.';

  // Prospectos
  static const nuevoProspecto = 'Nuevo prospecto';
  static const contacto = 'Contacto';
  static const etapa = 'Etapa';
  static const proximoContacto = 'Próximo contacto';
  static const sinFecha = 'Sin fecha';
  static const notas = 'Notas';
  static const embudoVacio = 'Todavía no hay prospectos.';
  static const etapas = {
    'prospect': 'Prospecto',
    'contacted': 'Contactado',
    'demo': 'Demo',
    'founder': 'Socio Fundador',
    'paying': 'Pagando',
    'renewed': 'Renovó',
    'lost': 'Perdido',
  };

  // Ayuda
  static const nuevaEntrada = 'Nueva entrada';
  static const tipo = 'Tipo';
  static const enlace = 'Enlace (https://…), por ejemplo, adopciones';
  static const activa = 'Visible en la app';
  static const tiposAyuda = {
    'refugio': 'Refugio',
    'protectora': 'Protectora',
    'grupo': 'Grupo de difusión',
    'organismo': 'Organismo',
  };

  static const rubros = {
    'vet': 'Veterinaria',
    'petshop': 'Petshop',
    'pharmacy': 'Farmacia veterinaria',
    'grooming': 'Peluquería',
    'walker': 'Paseador',
    'hotel': 'Hotel o guardería',
    'trainer': 'Adiestrador',
    'pet_friendly': 'Acepta mascotas',
    'shelter': 'Refugio',
  };

  static const modalidades = {
    'local': 'Con local',
    'online': 'Online',
    'domicilio': 'A domicilio',
  };

  static const estadosVerificacion = {
    'unverified': 'No verificado',
    'pending': 'Pendiente',
    'verified': 'Verificado',
  };
}
