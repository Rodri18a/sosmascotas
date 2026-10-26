import 'modelos.dart';

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
  static const chapitas = 'Chapitas';

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
  static const demandaSinCubrir = 'Demanda sin cubrir';
  static const demandaExplicacion =
      'Búsquedas en la app por rubro contra los lugares de ese rubro en el mapa.';
  static String demandaRubro(
    String rubro,
    int busquedas,
    int sinResultados,
    int lugares,
  ) =>
      '$rubro: $busquedas búsquedas ($sinResultados sin resultados) · '
      '$lugares en el mapa';
  static const demandaTextos = 'Lo más buscado sin resultados (sin rubro)';
  static String demandaTexto(String texto, int veces) => '«$texto»: $veces';

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
  static const resena = 'Reseña';
  static const adopcionesRevision = 'Adopciones en revisión';
  static const adopcionesRevisionAyuda =
      'Particulares con 2 camadas o más en 12 meses (posible cría irregular). Antes de aprobar, ofrecé información sobre castración.';
  static const animales = 'animales';
  static const camadas12m = 'camadas en 12 meses';
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
  static const plan = 'Plan…';
  static const resultados = 'Resultados';

  // Propuestas y casos de éxito (2.4, D102).
  static const propuestas = 'Propuestas';
  static const armarPropuesta = 'Armar una propuesta';
  static const propuestaAyuda =
      'Elegí un rubro, o un comercio del mapa para sumar sus propios números. '
      'Se descarga una página lista para imprimir o guardar como PDF.';
  static const comercioOpcional = 'Comercio del mapa (opcional)';
  static const verDatos = 'Ver datos';
  static const descargarPropuesta = 'Descargar para imprimir';
  static const propuestaDescargada =
      'Listo. Abrila y usá «Imprimir» → «Guardar como PDF».';
  static const faltaRubro = 'Elegí un rubro o un comercio.';
  static const casosExito = 'Casos de éxito';
  static const casosAyuda =
      'Testimonios con números para usar en ventas. Solo se muestran en las '
      'propuestas los publicados, y para publicar hace falta el permiso de la empresa.';
  static const nuevoCaso = 'Nuevo caso';
  static const editarCaso = 'Editar caso';
  static const sinCasos = 'Todavía no hay casos de éxito.';
  static const cita = 'Lo que dijo';
  static const autorCita = 'Quién lo dijo (ej.: Laura, dueña)';
  static const numerosCaso = 'Números (ej.: de 40 a 140 aperturas por mes)';
  static const traerNumeros = 'Traer sus números';
  static const permisoCaso = 'La empresa autorizó usar su nombre y sus números';
  static const publicadoCaso = 'Publicado (se usa en las propuestas)';
  static const borrador = 'Borrador';
  static const publicado = 'Publicado';
  static const borrar = 'Borrar';
  static const casoIncompleto =
      'Faltan el comercio, el rubro o lo que dijo (10 caracteres o más).';
  static String numerosDeAperturas(int desde, int hasta) =>
      'De $desde a $hasta aperturas de la ficha por mes';
  static String propuestaResumen(Propuesta p) => [
    'Zona: ${p.zona ?? 'todas'}',
    'Búsquedas del rubro (${p.dias} días): ${p.busquedas}'
        '${p.sinResultados > 0 ? ' (${p.sinResultados} sin resultados)' : ''}',
    'Lugares del rubro en el mapa: ${p.lugares} (${p.verificados} verificados)',
    'Personas con cuenta: ${p.usuarios ?? 'menos de 5'}',
    if (p.negocio != null)
      'El comercio: ${p.numeroDelNegocio('aperturas')} aperturas, '
          '${p.numeroDelNegocio('contactos')} contactos, '
          '${p.numeroDelNegocio('favoritos')} favoritos',
    'Casos de éxito del rubro: ${p.casos.length}',
  ].join('\n');
  static const resultadosSinDatos = 'Sin movimiento en estos meses.';
  static const resultadosAperturas = 'Aperturas de la ficha';
  static const resultadosPersonas = 'Personas distintas';
  static const resultadosContactos = 'Contactos';
  static const resultadosAyuda =
      'Mes a mes (el último es el mes en curso). Son cantidades: nunca quién fue.';
  static const planes = {
    'basic': 'Básico',
    'featured': 'Destacado',
    'plus': 'Plus (módulos, como Socios)',
  };
  static const revisarRenac =
      'Verificá el RUT contra el listado oficial de operadores RENAC del MGAP antes de aprobar.';

  // Denuncias (2.7)
  static const denuncias = 'Denuncias';
  static const sinDenuncias = 'No hay denuncias.';
  static const derivar = 'Derivada al INBA o la policía';
  static const cerrar = 'Cerrar';
  static const estadosDenuncia = {
    'new': 'Nueva',
    'referred': 'Derivada',
    'closed': 'Cerrada',
  };
  static const verUbicacion = 'Ver ubicación';

  // Noticias (2.8)
  static const noticias = 'Noticias';
  static const nuevaNoticia = 'Nueva noticia';
  static const estado = 'Estado';
  static const todasLasEspecies = 'Todas las especies';
  static const sinNoticias = 'Todavía no hay noticias.';
  static const tituloNoticia = 'Título';
  static const cuerpo = 'Texto';
  static const fuente = 'Fuente';
  static const especiesNoticia = 'Para qué especies (ninguna marcada: todas)';
  static const patrocinada = 'Patrocinada (se ve "Promocionado · marca")';
  static const marca = 'Marca';
  static const faltaMarca = 'Una noticia patrocinada necesita la marca.';
  // Novedades de la comunidad (D86)
  static const comunidad = 'Comunidad';
  static const sinNovedades = 'Todavía no hay novedades de la comunidad.';
  static const ayudaNovedades =
      'Se generan solas (reencuentros que el dueño compartió, adopciones, '
      'lugares verificados y eventos). Apagá la que no deba verse.';
  static const tiposNovedad = {
    'reencuentro': 'Reencuentro',
    'adopcion': 'Adopción',
    'comercio': 'Lugar verificado',
    'evento': 'Evento',
  };
  static const sinNombre = 'Sin nombre';
  static const novedadVisible = 'Visible';
  static const oculta = 'Oculta';
  static const estadosNoticia = {
    'draft': 'Borrador',
    'published': 'Publicada',
    'hidden': 'Oculta',
  };
  static const especies = {
    1: 'Perro',
    2: 'Gato',
    3: 'Ave',
    4: 'Conejo',
    5: 'Roedor',
    6: 'Tortuga',
    7: 'Reptil',
    8: 'Pez',
    9: 'Caballo',
    10: 'Otro',
  };

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
    'agro': 'Agropecuaria',
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

  // Chapitas (1.8b.1, D95)
  static const nuevoLote = 'Nuevo lote';
  static const sinLotes =
      'Todavía no hay lotes. Cada lote genera códigos únicos para imprimir en las chapitas.';
  static const cantidad = 'Cantidad (1 a 500)';
  static const productor = 'Productor';
  static const material = 'Material';
  static const costoUnidad = r'Costo por unidad ($)';
  static const crear = 'Crear';
  static const descargarCsv = 'Descargar CSV';
  static const avisoDireccion =
      'Cada código lleva la dirección de la web pública de este entorno: los lotes que se imprimen de verdad se crean en producción, con el dominio definitivo.';
  static String resumenLote(int cantidad, int activadas, int escaneos) =>
      '$cantidad chapitas · $activadas activadas · $escaneos escaneos';

  // Lugares sin reclamar (1.8.5, D99)
  static String sinReclamarTitulo(int n) => 'Sin reclamar con tracción ($n)';
  static const sinReclamarAyuda =
      'Lugares que marcaron los usuarios y nadie dio de alta: buenos candidatos para ir a visitar.';
  static const sinReclamarNinguno = 'Todavía no hay lugares marcados.';
  static String sinReclamar(String rubro, int marcas, int aperturas) =>
      '$rubro · marcado por $marcas ${marcas == 1 ? 'persona' : 'personas'} · '
      '$aperturas aperturas (30 días)';
  static const verEnGoogle = 'Ver en Google Maps';

  // Pedidos de chapitas (1.8b.4, D98)
  static const pedidosChapita = 'Pedidos con retiro en veterinaria';
  static const sinPedidosChapita = 'No hay pedidos abiertos.';
  static const lotes = 'Lotes';
  static String pedidoChapita(int numero, String mascota, String grabado) =>
      'N.º $numero · $mascota · grabado «$grabado»';
  static const estadosPedidoChapita = {
    'new': 'Nuevo: falta mandarlo',
    'sent': 'Enviado a la veterinaria',
    'ready': 'En la veterinaria, para retirar',
    'delivered': 'Entregado',
    'cancelled': 'Cancelado',
  };
  static const enviar = 'Enviar';
  static const cancelarPedido = 'Cancelar';
  static const enviarPedidoTitulo = 'Mandar a la veterinaria';
  static const codigoChapita = 'Código de la chapita (de un lote, sin usar)';
  static const chapitaNoDisponible =
      'Ese código no existe, ya se usó o está reservado para otro pedido.';
}
