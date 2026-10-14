// "Avisar a mi familia" (contacto inverso): quien encuentra a la mascota deja
// su contacto; el teléfono del dueño nunca se muestra.
'use strict';

const ERRORES_AVISO = {
  datos_incompletos: 'Completá el mensaje, tu nombre y tu teléfono.',
  falta_consentimiento: 'Para enviar el aviso tenés que aceptar compartir tu contacto con la familia.',
  falta_antibots: 'Esperá a que termine el control anti-robots y volvé a enviar.',
  antibots: 'No pudimos verificar que no seas un robot. Recargá la página y probá de nuevo.',
  demasiados_avisos: 'Se enviaron muchos avisos en poco tiempo. Probá de nuevo en un rato.',
  no_encontrado: 'Este código o reporte ya no está activo.',
};

let tokenAntibots = null;
let widgetAntibots = null;
let ubicacion = null;
// Destino del aviso: { target_type: 'qr', code } o { target_type: 'sos', report_id }.
let destinoActual = null;

function mostrarErrorAviso(mensaje) {
  const p = document.getElementById('error-aviso');
  p.textContent = mensaje;
  p.hidden = !mensaje;
}

function prepararAntibots() {
  if (widgetAntibots !== null || !window.turnstile) return;
  widgetAntibots = window.turnstile.render('#antibots', {
    sitekey: CONF.turnstileSiteKey,
    language: 'es',
    callback: (token) => { tokenAntibots = token; },
    'expired-callback': () => { tokenAntibots = null; },
  });
}

function pedirUbicacion(casilla) {
  if (!casilla.checked) { ubicacion = null; return; }
  if (!navigator.geolocation) { casilla.checked = false; return; }
  navigator.geolocation.getCurrentPosition(
    (pos) => { ubicacion = { lat: pos.coords.latitude, lng: pos.coords.longitude }; },
    () => { casilla.checked = false; ubicacion = null; },
    { enableHighAccuracy: true, timeout: 15000 },
  );
}

async function enviarAviso(evento) {
  evento.preventDefault();
  mostrarErrorAviso('');
  const valor = (id) => document.getElementById(id).value.trim();
  if (!valor('mensaje') || !valor('nombre-remitente') || valor('contacto').length < 6) {
    mostrarErrorAviso(ERRORES_AVISO.datos_incompletos);
    return;
  }
  if (!document.getElementById('consentimiento').checked) {
    mostrarErrorAviso(ERRORES_AVISO.falta_consentimiento);
    return;
  }
  if (!tokenAntibots) {
    mostrarErrorAviso(ERRORES_AVISO.falta_antibots);
    return;
  }

  const boton = document.getElementById('enviar-aviso');
  boton.disabled = true;
  boton.textContent = 'Enviando…';
  try {
    const r = await fetch(`${CONF.supabaseUrl}/functions/v1/owner-alert`, {
      method: 'POST',
      headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...destinoActual,
        message: valor('mensaje'),
        sender_name: valor('nombre-remitente'),
        sender_contact: valor('contacto'),
        consent: true,
        location: ubicacion,
        turnstile_token: tokenAntibots,
      }),
    });
    const datos = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(datos.error || 'error');
    document.getElementById('aviso').hidden = true;
    document.getElementById('aviso').reset();
    document.getElementById('aviso-enviado').hidden = false;
  } catch (e) {
    mostrarErrorAviso(ERRORES_AVISO[e.message] || 'No pudimos enviar el aviso. Revisá tu conexión y probá de nuevo.');
    if (window.turnstile && widgetAntibots !== null) window.turnstile.reset(widgetAntibots);
    tokenAntibots = null;
  } finally {
    boton.disabled = false;
    boton.textContent = 'Enviar aviso';
  }
}

function habilitarAviso(destino) {
  destinoActual = destino;
  document.getElementById('abrir-aviso').addEventListener('click', () => {
    document.getElementById('tarjeta-contacto').hidden = true;
    document.getElementById('aviso').hidden = false;
    prepararAntibots();
    document.getElementById('mensaje').focus();
  });
}

window.addEventListener('sos:mascota', (e) => habilitarAviso({ target_type: 'qr', code: e.detail.codigo }));
window.addEventListener('sos:reporte', (e) => habilitarAviso({ target_type: 'sos', report_id: e.detail.id }));

document.getElementById('compartir-ubicacion').addEventListener('change', (e) => pedirUbicacion(e.target));
document.getElementById('aviso').addEventListener('submit', enviarAviso);
