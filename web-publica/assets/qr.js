// Página pública del QR: /m/<código>.
'use strict';

const ESTADOS = {
  not_found: ['Este código no existe', 'Revisá que la dirección esté completa.'],
  inactive: ['Este código ya no está activo', 'La familia de esta mascota lo cambió por uno nuevo.'],
  inactive_physical: ['Esta chapita ya no está activa', 'Su familia la dio de baja. Si encontraste una mascota con ella, llevala a una veterinaria para que le lean el microchip.'],
  error: ['No pudimos cargar la información', 'Revisá tu conexión y volvé a intentar.'],
};

function mostrarEstado(clave) {
  const [titulo, texto] = ESTADOS[clave] || ESTADOS.error;
  document.getElementById('estado-titulo').textContent = titulo;
  document.getElementById('estado-texto').textContent = texto;
  document.getElementById('estado').hidden = false;
}

// Chapita física sin vincular (1.8b.3, D95): invita a su dueño a activarla.
function mostrarSinActivar(codigo) {
  document.title = 'Chapita sin activar · SOS Mascotas';
  document.getElementById('codigo-chapita').textContent = codigo;
  if (CONF.appUrl) {
    const boton = document.getElementById('activar-chapita');
    boton.href = `${CONF.appUrl.replace(/\/+$/, '')}/activar/${encodeURIComponent(codigo)}`;
    boton.hidden = false;
  }
  document.getElementById('sin-activar').hidden = false;
}

function mostrarMascota(datos) {
  const m = datos.pet;
  document.title = `${m.name} · SOS Mascotas`;
  document.getElementById('nombre').textContent = m.name;
  document.getElementById('detalle').textContent =
    [m.species_icon && m.species ? `${m.species_icon} ${m.species}` : m.species, m.breed, m.color]
      .filter(Boolean).join(' · ');
  document.getElementById('senas').textContent = m.marks || '';

  const contenedor = document.getElementById('foto-contenedor');
  const url = urlFoto('pet-photos', m.photo_path);
  if (url) {
    const img = el('img', null, 'foto');
    img.src = url;
    img.alt = `Foto de ${m.name}`;
    contenedor.append(img);
  } else {
    const sinFoto = el('div', m.species_icon || '🐾', 'foto sin-foto');
    sinFoto.setAttribute('aria-hidden', 'true');
    contenedor.append(sinFoto);
  }

  if (m.public_note) {
    const nota = document.getElementById('nota');
    nota.textContent = m.public_note;
    nota.hidden = false;
  }
  document.getElementById('chip').hidden = !m.has_microchip;
  const perdido = document.getElementById('perdido');
  perdido.hidden = !datos.lost;
  if (datos.sos_id) perdido.href = `/s/${encodeURIComponent(datos.sos_id)}`;
  document.getElementById('mascota').hidden = false;
}

// Sponsor del lote de la chapita (2.9, D105): chico y abajo, la página es para una emergencia.
function mostrarSponsor(sponsor) {
  if (!sponsor || !sponsor.name) return;
  const pie = document.getElementById('sponsor');
  pie.append(el('span', 'Chapita donada por '));
  const url = urlFoto('sponsor-logos', sponsor.logo_path);
  if (url) {
    const logo = el('img', null, 'sponsor-logo');
    logo.src = url;
    logo.alt = sponsor.name;
    pie.append(logo);
  } else {
    pie.append(el('strong', sponsor.name));
  }
  pie.hidden = false;
}

async function iniciar() {
  const codigo = codigoDeLaDireccion();
  try {
    const datos = codigo ? await rpc('public_pet_page', { p_code: codigo }) : { status: 'not_found' };
    if (datos.status === 'active') {
      mostrarMascota(datos);
      window.dispatchEvent(new CustomEvent('sos:mascota', { detail: { codigo, datos } }));
      mostrarSponsor(datos.sponsor);
    } else if (datos.status === 'unactivated') {
      mostrarSinActivar(datos.code || codigo);
      mostrarSponsor(datos.sponsor);
    } else {
      mostrarEstado(datos.status === 'inactive' && datos.kind === 'physical' ? 'inactive_physical' : datos.status);
    }
  } catch (e) {
    console.error(e);
    mostrarEstado('error');
  } finally {
    document.getElementById('cargando').hidden = true;
  }
}

iniciar();
