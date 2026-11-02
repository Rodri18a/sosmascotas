/// Nombres de los eventos de métricas (tabla `events`).
/// La lista completa está en docs/08-arquitectura.md, sección Métricas.
/// Formato obligatorio (lo valida también la base): minúsculas, números y `_`.
abstract final class Eventos {
  static const appOpen = 'app_open';
  static const signup = 'signup';
  static const accountDelete = 'account_delete';
  static const petCreate = 'pet_create';
  static const alertReply = 'alert_reply';
  static const contentFlag = 'content_flag';
  static const alertZoneSet = 'alert_zone_set';
  static const alertZoneClear = 'alert_zone_clear';
  static const placeOpen = 'place_open';
  static const placeClick = 'place_click';
  static const helpClick = 'help_click';
  static const themeChange = 'theme_change';
  static const featureExposure = 'feature_exposure';
  static const pwaPrompt = 'pwa_prompt';
  static const pwaInstalled = 'pwa_installed';
  static const healthRecordCreate = 'health_record_create';
  static const renacStatusSet = 'renac_status_set';
  static const renacGuideOpen = 'renac_guide_open';
  static const renacVerifyClick = 'renac_verify_click';
  static const reminderCreate = 'reminder_create';
  static const reminderDone = 'reminder_done';
  static const householdInvite = 'household_invite';
  static const householdJoin = 'household_join';
  static const householdLeave = 'household_leave';
  static const taskCreate = 'task_create';
  static const taskDone = 'task_done';
  static const chatStart = 'chat_start';
  static const chatMessage = 'chat_message';
  static const chatBlock = 'chat_block';
  static const sosFollow = 'sos_follow';
  static const sosPoster = 'sos_poster';
  static const favoriteAdd = 'favorite_add';
  static const placeVisit = 'place_visit';
  static const myVetSet = 'my_vet_set';
  static const mapView = 'map_view';
  static const search = 'search';
  static const placeMark = 'place_mark';
  static const unclaimedOpen = 'unclaimed_open';
  static const businessCreate = 'business_create';
  static const businessClaim = 'business_claim';
  static const verificationRequest = 'verification_request';
  static const reviewCreate = 'review_create';
  static const reviewReply = 'review_reply';
  static const adoptionPublish = 'adoption_publish';
  static const adoptionInterest = 'adoption_interest';
  static const adoptionStage = 'adoption_stage';
  static const adoptionCommit = 'adoption_commit';
  static const adoptionFollowup = 'adoption_followup';
  static const eventPublish = 'event_publish';
  static const eventOpen = 'event_open';
  static const abuseReport = 'abuse_report';
  static const moduleToggle = 'module_toggle';
  static const vetShare = 'vet_share';
  static const vetRemind = 'vet_remind';
  static const vetSearchOptIn = 'vet_search_opt_in';
  static const vetSearchSnooze = 'vet_search_snooze';
  static const vetProposalSend = 'vet_proposal_send';
  static const vetProposalAnswer = 'vet_proposal_answer';
  static const newsOpen = 'news_open';
  static const newsLink = 'news_link';
  static const bannerOpen = 'banner_open';

  /// Un banner del carrusel se vio (una vez por sesión, `target_id`, D137).
  static const bannerView = 'banner_view';
  static const communityShare = 'community_share';
  static const communityUnshare = 'community_unshare';
  static const newsReaction = 'news_reaction';
  static const menuOpen = 'menu_open';

  /// Opción tocada en el menú ☰ (`item`: cuál), para ver qué se usa.
  static const menuItemOpen = 'menu_item_open';

  /// Recorrido guiado de una pantalla (D130): `screen`, y si arrancó solo
  /// (`auto`) o desde el botón ?. Al saltarlo se anota en qué paso (`step`).
  static const tourStart = 'tour_start';
  static const tourFinish = 'tour_finish';
  static const tourSkip = 'tour_skip';

  /// «Ver más» de una explicación corta (plan de mejoras 1.4): `item`, cuál.
  static const moreInfoOpen = 'more_info_open';

  /// Acceso directo desde la fila de una mascota en Mis mascotas (1.5):
  /// `action` = qr, libreta, recordatorio o reportar.
  static const petQuickAction = 'pet_quick_action';

  /// Historial de vida (D131): se carga un acontecimiento (`kind`) o se le
  /// suma un adjunto (`type`: photo o pdf).
  static const lifeEventCreate = 'life_event_create';
  static const lifeEventFileAdd = 'life_event_file_add';

  /// Pasar una mascota a otra persona (D132): se genera el código y se acepta.
  static const petTransferCreate = 'pet_transfer_create';
  static const petTransferAccept = 'pet_transfer_accept';

  /// Historial compartido (D133): se crea el enlace (`days`) y se abre la
  /// página (desde la web pública).
  static const historyShareCreate = 'history_share_create';
  static const historyShareOpen = 'history_share_open';

  /// Preguntas (D134): se pregunta (`topic`), se busca, se responde y quien
  /// preguntó marca la respuesta que le sirvió.
  static const questionCreate = 'question_create';
  static const questionSearch = 'question_search';
  static const questionAnswer = 'question_answer';
  static const questionSolved = 'question_solved';

  /// Una veterinaria verificada firma su respuesta (D135).
  static const professionalAnswerMark = 'professional_answer_mark';

  /// Promociones en el muro (D136), con `business_id` para sus estadísticas:
  /// se vio (una vez por sesión), se tocó, el comercio la publicó o la reportaron.
  static const promoView = 'promo_view';
  static const promoClick = 'promo_click';
  static const promoCreate = 'promo_create';
  static const promoReport = 'promo_report';
  static const tabOpen = 'tab_open';
  static const tagActivate = 'tag_activate';
  static const tagUnlink = 'tag_unlink';
  static const tagOrderCreate = 'tag_order_create';
  static const tagOrderCancel = 'tag_order_cancel';
  static const tagOrderStatus = 'tag_order_status';
  static const tagPickupToggle = 'tag_pickup_toggle';
  static const tagStockDeliver = 'tag_stock_deliver';
  static const fosterHomeSave = 'foster_home_save';
  static const fosterRequestCreate = 'foster_request_create';
  static const fosterRequestAnswer = 'foster_request_answer';
  static const fosterRequestClose = 'foster_request_close';
  static const perkSave = 'perk_save';
  static const perkClaim = 'perk_claim';
  static const perkRedeem = 'perk_redeem';
  static const sponsorshipStatus = 'sponsorship_status';
  static const petSelect = 'pet_select';
  static const catalogOpen = 'catalog_open';
  static const catalogAsk = 'catalog_ask';
  static const productSave = 'product_save';
  static const orderCreate = 'order_create';
  static const orderStatus = 'order_status';
  static const orderWhatsapp = 'order_whatsapp';
  static const orderSettingsSave = 'order_settings_save';
  static const serviceAsk = 'service_ask';
  static const serviceSave = 'service_save';
  static const businessPageShare = 'business_page_share';
  static const planRequest = 'plan_request';
  static const healthPdf = 'health_pdf';
  static const filtersSave = 'filters_save';
  static const textSizeChange = 'text_size_change';
  static const discountClaim = 'discount_claim';
  static const discountRedeem = 'discount_redeem';
  static const discountSave = 'discount_save';
  static const catalogImport = 'catalog_import';
  static const reportDownload = 'report_download';
  static const bookingCreate = 'booking_create';
  static const bookingStatus = 'booking_status';
  static const agendaSave = 'agenda_save';
  static const careRequest = 'care_request';
  static const careStatus = 'care_status';
  static const careSave = 'care_save';
  static const groupJoin = 'group_join';
  static const postCreate = 'post_create';
  static const commentCreate = 'comment_create';
  static const greetingSend = 'greeting_send';
  static const greetingAnswer = 'greeting_answer';
  static const teamInvite = 'team_invite';
  static const teamJoin = 'team_join';
  static const teamLeave = 'team_leave';

  /// Lo registra la web pública al abrir `/n/<id>` (no la app).
  static const businessPageOpen = 'business_page_open';
}

/// Valida el nombre de un evento con la misma regla que la base de datos.
bool nombreDeEventoValido(String nombre) =>
    RegExp(r'^[a-z][a-z0-9_]{1,62}$').hasMatch(nombre);
