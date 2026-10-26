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
  static const communityShare = 'community_share';
  static const communityUnshare = 'community_unshare';
  static const newsReaction = 'news_reaction';
  static const menuOpen = 'menu_open';
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
  static const bookingCreate = 'booking_create';
  static const bookingStatus = 'booking_status';
  static const agendaSave = 'agenda_save';

  /// Lo registra la web pública al abrir `/n/<id>` (no la app).
  static const businessPageOpen = 'business_page_open';
}

/// Valida el nombre de un evento con la misma regla que la base de datos.
bool nombreDeEventoValido(String nombre) =>
    RegExp(r'^[a-z][a-z0-9_]{1,62}$').hasMatch(nombre);
