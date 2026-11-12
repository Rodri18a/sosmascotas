// Landing de huellamy.com (0.8.6d, D156, D158): enlaces a las dos apps,
// métricas anónimas y formulario de contacto (sin teléfonos).
'use strict';

const ERRORES_CONTACTO = {
  datos_incompletos: 'Completá tu nombre y un mensaje de al menos 5 letras.',
  correo_invalido: 'Revisá el correo: así no nos va a llegar la respuesta.',
  falta_consentimiento: 'Para enviar el mensaje tenés que aceptar que guardemos estos datos.',
  falta_antibots: 'Esperá a que termine el control anti-robots y volvé a enviar.',
  antibots: 'No pudimos verificar que no seas un robot. Recargá la página y probá de nuevo.',
  demasiados_mensajes: 'Se enviaron muchos mensajes en poco tiempo. Probá de nuevo en un rato.',
};
const CORREO_VALIDO = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

let tokenAntibots = null;
let widgetAntibots = null;

/** Id al azar de este navegador (el mismo que usan las otras páginas). */
function anonId() {
  try {
    let anon = localStorage.getItem('sos_anon_id');
    if (!anon) {
      anon = crypto.randomUUID();
      localStorage.setItem('sos_anon_id', anon);
    }
    return anon;
  } catch (_) {
    return crypto.randomUUID();
  }
}

/** Evento anónimo de métricas; si falla, no molesta a nadie. */
function registrar(nombre, props) {
  if (!CONF.supabaseUrl) return;
  fetch(`${CONF.supabaseUrl}/rest/v1/events`, {
    method: 'POST',
    headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json', Prefer: 'return=minimal' },
    body: JSON.stringify({ name: nombre, anon_id: anonId(), platform: 'web', props: props || {} }),
    keepalive: true,
  }).catch(() => {});
}

/** Los botones a las apps usan las direcciones de config.js (dev o prod). */
function prepararEnlaces() {
  const destinos = { app: CONF.appUrl, comercios: CONF.comerciosUrl };
  document.querySelectorAll('[data-destino]').forEach((a) => {
    const destino = a.dataset.destino;
    if (destinos[destino]) a.href = destinos[destino];
    a.addEventListener('click', () => registrar('landing_cta', { destino }));
  });
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

function mostrarError(mensaje) {
  const p = document.getElementById('error');
  p.textContent = mensaje;
  p.hidden = !mensaje;
}

function tipoElegido() {
  return document.querySelector('input[name="tipo"]:checked').value;
}

async function enviar(evento) {
  evento.preventDefault();
  mostrarError('');
  const valor = (id) => document.getElementById(id).value.trim();
  const tipo = tipoElegido();
  if (valor('nombre').length < 2 || valor('mensaje').length < 5) {
    mostrarError(ERRORES_CONTACTO.datos_incompletos);
    return;
  }
  if (!CORREO_VALIDO.test(valor('correo'))) {
    mostrarError(ERRORES_CONTACTO.correo_invalido);
    return;
  }
  if (!document.getElementById('consentimiento').checked) {
    mostrarError(ERRORES_CONTACTO.falta_consentimiento);
    return;
  }
  if (!tokenAntibots) {
    mostrarError(ERRORES_CONTACTO.falta_antibots);
    return;
  }

  const boton = document.getElementById('enviar');
  boton.disabled = true;
  boton.textContent = 'Enviando…';
  try {
    const r = await fetch(`${CONF.supabaseUrl}/functions/v1/landing-contact`, {
      method: 'POST',
      headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        kind: tipo,
        name: valor('nombre'),
        email: valor('correo'),
        business: tipo === 'business' ? valor('comercio') : null,
        message: valor('mensaje'),
        website: document.getElementById('sitio').value,
        consent: true,
        turnstile_token: tokenAntibots,
        anon_id: anonId(),
      }),
    });
    const datos = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(datos.error || 'error');
    document.getElementById('formulario').hidden = true;
    document.getElementById('enviado').hidden = false;
  } catch (e) {
    mostrarError(ERRORES_CONTACTO[e.message] || 'No pudimos enviar el mensaje. Revisá tu conexión y probá de nuevo.');
    if (window.turnstile && widgetAntibots !== null) window.turnstile.reset(widgetAntibots);
    tokenAntibots = null;
  } finally {
    boton.disabled = false;
    boton.textContent = 'Enviar';
  }
}

function iniciarLanding() {
  prepararEnlaces();
  registrar('landing_view', document.referrer ? { desde: new URL(document.referrer).hostname } : {});

  const formulario = document.getElementById('formulario');
  formulario.addEventListener('submit', enviar);
  // El anti-bots se carga recién cuando la persona empieza a escribir (si el
  // script de Turnstile todavía no llegó, se reintenta en el próximo toque).
  formulario.addEventListener('focusin', prepararAntibots);
  formulario.addEventListener('change', (e) => {
    if (e.target.name === 'tipo') {
      document.getElementById('campo-comercio').hidden = tipoElegido() !== 'business';
    }
  });
  // Si el script de Turnstile llega después del primer toque.
  window.addEventListener('load', () => {
    if (formulario.contains(document.activeElement)) prepararAntibots();
  });
}

iniciarLanding();
