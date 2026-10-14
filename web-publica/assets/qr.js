// Página pública del QR: /m/<código>.
'use strict';

const ESTADOS = {
  not_found: ['Este código no existe', 'Revisá que la dirección esté completa.'],
  inactive: ['Este código ya no está activo', 'La familia de esta mascota lo cambió por uno nuevo.'],
  unactivated: ['Chapita sin activar', 'Activá esta chapita desde la app SOS Mascota para vincularla a tu mascota.'],
  error: ['No pudimos cargar la información', 'Revisá tu conexión y volvé a intentar.'],
};

function mostrarEstado(clave) {
  const [titulo, texto] = ESTADOS[clave] || ESTADOS.error;
  document.getElementById('estado-titulo').textContent = titulo;
  document.getElementById('estado-texto').textContent = texto;
  document.getElementById('estado').hidden = false;
}

function mostrarMascota(datos) {
  const m = datos.pet;
  document.title = `${m.name} · SOS Mascota`;
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
  document.getElementById('perdido').hidden = !datos.lost;
  document.getElementById('mascota').hidden = false;
}

async function iniciar() {
  const codigo = codigoDeLaDireccion();
  try {
    const datos = codigo ? await rpc('public_pet_page', { p_code: codigo }) : { status: 'not_found' };
    if (datos.status === 'active') {
      mostrarMascota(datos);
      window.dispatchEvent(new CustomEvent('sos:mascota', { detail: { codigo, datos } }));
    } else {
      mostrarEstado(datos.status);
    }
  } catch (e) {
    console.error(e);
    mostrarEstado('error');
  } finally {
    document.getElementById('cargando').hidden = true;
  }
}

iniciar();
