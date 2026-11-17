import 'modelos.dart';

/// Textos del portal de administración (en voseo, como la app). El portal es
/// una herramienta interna: los textos están acá y no en un .arb (D76).
abstract final class T {
  static const titulo = 'Huellamy · Administración';
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
  static const publicacion = 'Publicación de un grupo';
  static const comentario = 'Comentario de un grupo';
  static const promocionMuro = 'Promoción del muro';

  // Espacios de publicidad (3.2, D137).
  static const espacios = 'Espacios';
  static const espaciosAyuda =
      'Vistas, personas y toques de las promociones del muro y de los banners del carrusel. '
      'Una vista se cuenta una vez por sesión. Sirve para vender y para rendirle cuentas a cada patrocinador.';
  static String ultimosDias(int d) => '$d días';
  static const sinEspacios =
      'Todavía no hay promociones ni banners en este período.';
  static const tituloEspacio = 'Título';
  static const deQuien = 'Comercio o marca';
  static const vistas = 'Vistas';
  static const personas = 'Personas';
  static const toques = 'Toques';
  static const tasaToques = 'Toques / vistas';
  static const banner = 'Banner';
  static const estadosEspacio = {
    'active': 'Vigente',
    'published': 'Publicado',
    'ended': 'Terminada',
    'hidden': 'Oculta',
    'draft': 'Borrador',
  };

  // Grupos de la comunidad (3.4, D116)
  static const grupos = 'Grupos';
  static const nuevoGrupo = 'Nuevo grupo';
  static const grupoNombre = 'Nombre';
  static const grupoDescripcion = 'Descripción (opcional)';
  static const grupoIcono = 'Ícono (un emoji, opcional)';
  static const grupoActivo = 'Visible en la app';
  static const gruposAyuda =
      'Los de especie y tema los crea el equipo; los de raza se crean solos cuando alguien con una mascota de esa raza se une.';
  static const tiposGrupo = {
    'species': 'Especie',
    'breed': 'Raza',
    'topic': 'Tema',
  };
  static String grupoResumen(int miembros, int publicaciones, int ocultas) =>
      '$miembros integrantes · $publicaciones publicaciones'
      '${ocultas > 0 ? ' · $ocultas ocultas' : ''}';
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

  // Planes y cobros (2.2, D103).
  static const planesCobros = 'Planes';
  static const planesAyuda =
      'Cobro manual (transferencia o link de pago) hasta que haya pagos en la '
      'app. Vencido el período, el plan sigue 7 días «con atraso» y después '
      'vuelve a Básico solo. No se cobra antes de formalizar (0.0.9d).';
  static const nuevoPlan = 'Nuevo plan pago';
  static const planesComercios = 'Comercios';
  static const planesPersonas = 'Personas';
  static const planesPersonasAyuda =
      'Pro y Familia de las personas, con cobro manual como los comercios. '
      'La prueba de Familia (30 días, una vez) arranca sola al invitar a '
      'alguien al hogar. Vencido, vuelve a Gratis sin perder nada.';
  static const nuevoPlanPersona = 'Nuevo plan Pro o Familia';
  static const pedidosDePlan = 'Pidieron un plan desde la app';
  static String pidio(String quien, String plan) => '$quien pidió $plan';
  static const activar = 'Activar';
  static const descartar = 'Descartar';
  static const faltanDatosPlanPersona =
      'Falta el correo, el precio o la fecha de vencimiento.';
  static const sinCuentaPlan =
      'No hay una cuenta con ese correo: primero tiene que registrarse en la app.';
  static const sinSuscripciones = 'Todavía no hay planes pagos.';
  static const precioMes = r'Precio por mes ($)';
  static const venceEl = 'Vence el…';
  static const esFundador = 'Socio Fundador (precio congelado)';
  static const notas = 'Notas';
  static const registrarPago = 'Registrar pago';
  static const monto = r'Monto ($)';
  static const metodo = 'Forma de pago';
  static const metodos = {
    'transfer': 'Transferencia',
    'payment_link': 'Link de pago',
    'cash': 'Efectivo',
    'other': 'Otro',
    'support': 'Soporte (desde la app)',
  };
  static const referencia = 'Referencia (n.º de transferencia…)';
  static const mesesPagados = 'Meses que paga';
  static const darDeBaja = 'Dar de baja';
  static const estadosPlan = {
    'active': 'Al día',
    'past_due': 'Con atraso',
    'cancelled': 'De baja (sigue hasta el fin)',
    'expired': 'Vencido',
  };
  static const faltanDatosPlan = 'Elegí el comercio, el plan y la fecha.';
  static const montoInvalido = 'Poné un monto mayor que 0.';
  static String pagoRegistrado(DateTime hasta) =>
      'Pago registrado: queda pago hasta el '
      '${hasta.day}/${hasta.month}/${hasta.year}.';
  static String resumenIngresos(Ingresos i) => [
    'Vigentes: Destacado ${i.vigentes['featured'] ?? 0} · '
        'Plus ${i.vigentes['plus'] ?? 0} · Pro ${i.vigentes['pro'] ?? 0} · '
        'Familia ${i.vigentes['family'] ?? 0}',
    'Esperado por mes (sin Socios Fundadores): '
        '\$ ${i.esperadoPorMes.toStringAsFixed(0)}',
  ].join('\n');
  static String suscripcionDetalle(Suscripcion s) => [
    '${planes[s.plan] ?? s.plan} · ${estadosPlan[s.estado] ?? s.estado}',
    'Vence el ${s.vence.day}/${s.vence.month}/${s.vence.year}'
        '${s.fundador ? ' · Socio Fundador' : ''}'
        '${s.prueba ? ' · Prueba gratis' : ''}',
    '\$ ${s.precio.toStringAsFixed(0)} por mes · cobrado '
        '\$ ${s.pagado.toStringAsFixed(0)}',
  ].join('\n');

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
    'pro': 'Pro',
    'family': 'Familia',
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
  // Banners del carrusel de Inicio (D128)
  static const banners = 'Banners';
  static const nuevoBanner = 'Nuevo banner';
  static const editarBanner = 'Editar banner';
  static const sinBanners =
      'Todavía no hay banners. Se ven en un carrusel arriba del Inicio de la app.';
  static const ayudaBanners =
      'Pasan solos cada 3 segundos, en el orden de abajo. Imagen apaisada 2:1 '
      '(por ejemplo 1200 × 600), PNG, JPG o WebP de hasta 1 MB.';
  static const tituloBanner = 'Título (también lo lee el lector de pantalla)';
  static const elegirImagenBanner = 'Elegir imagen';
  static const cambiarImagenBanner = 'Cambiar imagen';
  static const sinImagenBanner = 'Falta la imagen.';
  static const imagenBannerLista = 'Imagen lista';
  static const imagenBannerGrande =
      'La imagen tiene que ser PNG, JPG o WebP de hasta 1 MB.';
  static const estadosBanner = {
    'draft': 'Borrador',
    'published': 'Publicado',
    'hidden': 'Oculto',
  };
  static const destinoBanner = 'Al tocarlo';
  static const destinosBanner = {
    'nada': 'No hace nada',
    'enlace': 'Abre un enlace',
    'noticia': 'Abre una noticia',
  };
  static const noticiaBanner = 'Noticia publicada';
  static const enlaceBanner = 'Enlace (https://…)';
  static const faltaDestinoBanner =
      'Elegí la noticia o poné un enlace que empiece con https://.';
  static const ordenBanner = 'Orden (el más bajo va primero)';
  static const desde = 'Desde';
  static const hasta = 'Hasta';
  static const sinFin = 'sin fecha de fin';
  static const patrocinado = 'Patrocinado (se ve "Promocionado · marca")';
  static const faltaMarcaBanner = 'Un banner patrocinado necesita la marca.';
  static String resumenBanner(String estado, int orden, String fechas) =>
      '$estado · orden $orden · $fechas';
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

  /// Especies habilitadas (D149: la primera versión es de perros y gatos).
  static const especies = {1: 'Perro', 2: 'Gato'};

  // Contactos de la landing (D158) y soporte desde la app (D160)
  static const contactos = 'Contactos';
  static const sinContactos = 'No hay mensajes acá.';
  static const marcarRespondido = 'Marcar respondido';
  static const archivar = 'Archivar';
  static const volverANuevo = 'Volver a nuevo';
  static const pasarAProspectos = 'Pasar a prospectos';
  static const pasadoAProspectos = 'Quedó en Prospectos como contactado.';
  static const responderPorCorreo =
      'Respondé desde soporte@huellamy.com (al correo de cada mensaje) y '
      'después marcalo respondido. Soporte: en menos de 24 horas.';
  static const tiposContacto = {
    'owner': 'Dueño',
    'business': 'Comercio',
    'other': 'Otro',
  };
  static const estadosContacto = {
    'new': 'Nuevos',
    'answered': 'Respondidos',
    'archived': 'Archivados',
  };

  // Prospectos
  static const nuevoProspecto = 'Nuevo prospecto';
  static const contacto = 'Contacto';
  static const etapa = 'Etapa';
  static const proximoContacto = 'Próximo contacto';
  static const sinFecha = 'Sin fecha';
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
  static String resumenLote(
    int cantidad,
    int activadas,
    int escaneos,
    int reencuentros,
  ) =>
      '$cantidad chapitas · $activadas activadas · $escaneos escaneos · '
      '$reencuentros ${reencuentros == 1 ? 'reencuentro' : 'reencuentros'}';

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

  // Sponsors y stock de chapitas (2.9, D105)
  static const sponsors = 'Sponsors';
  static const sponsorsAyuda =
      'Marcas o comercios que pagan un lote. Su logo va en el reverso de la chapita y, chico y abajo, en la página del QR.';
  static const nuevoSponsor = 'Nuevo sponsor';
  static const sinSponsors = 'Todavía no hay sponsors.';
  static const editarSponsor = 'Editar sponsor';
  static const nombreSponsor = 'Nombre (se ve en la página del QR)';
  static const notasSponsor = 'Notas privadas (contacto, acuerdo)';
  static const sponsorActivo =
      'Activo (se muestra en las chapitas de sus lotes)';
  static const elegirLogo = 'Elegir logo';
  static const cambiarLogo = 'Cambiar logo';
  static const logoListo = 'Logo cargado';
  static const sinLogo = 'Sin logo: se muestra el nombre';
  static const logoGrande =
      'El logo tiene que ser PNG, JPEG o WebP de hasta 500 KB.';
  static const faltaNombre = 'Falta el nombre.';
  static const inactivo = 'inactivo';
  static String resumenSponsor(int lotes, int chapitas) =>
      '$lotes ${lotes == 1 ? 'lote' : 'lotes'} · $chapitas chapitas';
  static const reporte = 'Reporte';
  static String reporteTitulo(String sponsor) => 'Reporte para $sponsor';
  static const reporteAyuda =
      'Solo números: ningún dato de las familias. Reencuentro = un «se perdió» de una mascota con una chapita del lote, marcado «¡Apareció!».';
  static const sinLotesSponsor = 'Este sponsor todavía no tiene lotes.';
  static String lineaReporte(
    String fecha,
    int cantidad,
    int activadas,
    int escaneos,
    int reencuentros,
  ) =>
      'Lote del $fecha: $cantidad chapitas · $activadas activadas · '
      '$escaneos escaneos · $reencuentros reencuentros';
  static const ponerSponsor = 'Sponsor del lote…';
  static const sinSponsor = 'Sin sponsor';
  static String sponsorDe(String nombre) => 'Sponsor: $nombre';
  static const pasarAStock = 'Pasar a una veterinaria…';
  static const stockTitulo = 'Stock en veterinarias';
  static const stockAyuda =
      'Chapitas en blanco que tiene cada veterinaria: el dueño la activa en el local, o la veterinaria la entrega para un pedido.';
  static const sinStock = 'Ninguna veterinaria tiene chapitas todavía.';
  static String resumenStock(int recibidas, int disponibles, int activadas) =>
      '$recibidas recibidas · $disponibles disponibles · $activadas activadas';
  static String enStock(int n) => '$n en stock';
  static const veterinaria = 'Veterinaria verificada';
  static const sinVeterinarias =
      'No hay veterinarias verificadas: el stock es solo para ellas.';
  static const cantidadStock = 'Cantidad (1 a 200)';
  static const asignar = 'Pasar';
  static const noAlcanzan =
      'No alcanzan: el lote no tiene tantas chapitas libres.';
  static String codigosParaEntregar(int n) =>
      'Entregale estas $n chapitas (y solo estas):';
  static const quitarUna = 'Quitar una';
  static const quitarStockTitulo = 'Sacar una chapita del stock';
  static const codigoStock = 'Código (sin activar, del stock)';
  static const quitar = 'Quitar';

  // Equipo, zonas y auditoría (3.6, D109)
  static const equipo = 'Equipo';
  static const zonas = 'Zonas';
  static const auditoria = 'Auditoría';
  static const rolesEquipo = {
    'admin': 'Administración (todo)',
    'moderator': 'Moderación (moderación y denuncias)',
    'sales': 'Ventas (lugares, prospectos y propuestas)',
  };
  static const equipoAyuda =
      'El rol se da a una cuenta que ya existe en la app, por su correo. Nadie se cambia el suyo y siempre queda al menos una persona con administración.';
  static const sumarAlEquipo = 'Sumar o cambiar rol';
  static const correoCuenta = 'Correo de la cuenta';
  static const rol = 'Rol';
  static const sacarDelEquipo = 'Sacar del equipo';
  static const vos = 'vos';
  static String ultimaAccion(String fecha) => 'Última acción: $fecha';
  static const sinAcciones = 'Sin acciones todavía';
  static const errorRol = {
    'sin_cuenta':
        'No hay una cuenta con ese correo: primero tiene que registrarse en la app.',
    'no_tu_propio_rol': 'No podés cambiar tu propio rol.',
    'ultimo_admin': 'Tiene que quedar al menos una persona con administración.',
  };
  static const zonasAyuda =
      'El área es un rectángulo (latitud y longitud de las esquinas): se copia de un mapa, sin geocodificar. Una zona nueva arranca apagada.';
  static const nuevaZona = 'Nueva zona';
  static const editarZona = 'Editar zona';
  static const slugZona = 'Identificador (minúsculas y guiones)';
  static const nombreZona = 'Nombre';
  static const latMin = 'Latitud sur (mínima)';
  static const latMax = 'Latitud norte (máxima)';
  static const lngMin = 'Longitud oeste (mínima)';
  static const lngMax = 'Longitud este (máxima)';
  static const zonaActiva = 'Prendida (visible en la app)';
  static const areaInvalida =
      'El rectángulo no es válido: el sur tiene que ser menor que el norte, el oeste menor que el este, y cada lado de hasta 5 grados.';
  static String resumenZona(int usuarios, int mascotas, int lugares, int sos) =>
      '$usuarios usuarios · $mascotas mascotas · $lugares lugares · $sos SOS activos';
  static const apagada = 'apagada';
  static const auditoriaAyuda =
      'Cada acción del equipo queda registrada: quién, qué y cuándo. Se ven las últimas 500.';
  static const todasLasAcciones = 'Todas las acciones';
  static const sinRegistro = 'No hay acciones en este período.';
  static String susZonas(List<String> zonas) => 'Zonas: ${zonas.join(', ')}';
  static const sinZonas = 'Sin zonas: no ve nada';
  static String zonasDeIntegrante(String correo) => 'Zonas de $correo';
  static const zonasIntegranteAyuda =
      'Ve solo lo de estas zonas: SOS, mensajes, reseñas, denuncias, lugares, prospectos y propuestas. Sin ninguna, no ve nada.';
  static String tusZonas(List<String> zonas) =>
      'Ves solo lo de tus zonas: ${zonas.join(', ')}.';
  static const sinTusZonas =
      'Todavía no tenés zonas asignadas, así que no vas a ver datos. Pedíselas a la administración.';
}
