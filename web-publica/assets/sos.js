// Página pública de un SOS para compartir: /s/<id>.
'use strict';

const MESES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto',
  'septiembre', 'octubre', 'noviembre', 'diciembre'];

function fecha(iso) {
  const d = new Date(iso);
  return `${d.getDate()} de ${MESES[d.getMonth()]}`;
}

function mostrarEstadoSos(titulo, texto) {
  document.getElementById('estado-titulo').textContent = titulo;
  document.getElementById('estado-texto').textContent = texto;
  document.getElementById('estado').hidden = false;
}

function mostrarReporte(r) {
  const perdida = r.kind === 'lost';
  const nombre = r.name || r.species;
  document.title = `${perdida ? 'Se perdió' : 'Encontrada'}: ${nombre} · SOS Mascota`;

  const cartel = document.getElementById('cartel');
  if (r.status === 'active') {
    cartel.textContent = perdida ? 'Se busca 🆘' : 'Encontrada: busca a su familia';
    cartel.classList.toggle('calmo', !perdida);
  } else {
    cartel.textContent = r.status === 'resolved' ? '¡Apareció! Gracias por ayudar 💚' : 'Este reporte ya no está activo';
    cartel.classList.add('calmo');
    document.getElementById('tarjeta-contacto').hidden = true;
  }

  const fotos = document.getElementById('fotos');
  for (const ruta of r.photos || []) {
    const [bucket, ...resto] = ruta.split('/');
    const img = el('img', null, 'foto');
    img.src = urlFoto(bucket, resto.join('/'));
    img.alt = `Foto de ${nombre}`;
    img.style.marginBottom = '8px';
    fotos.append(img);
  }

  document.getElementById('titulo').textContent = perdida ? `Se perdió: ${nombre}` : `Encontrada: ${r.species}`;
  document.getElementById('detalle').textContent =
    [`${r.species_icon} ${r.species}`, r.breed, r.color].filter(Boolean).join(' · ');
  document.getElementById('cuando').textContent =
    `${perdida ? 'Se perdió el' : 'Encontrada el'} ${fecha(r.happened_at)}`;
  document.getElementById('senas').textContent = r.marks || '';
  document.getElementById('descripcion').textContent = r.description || '';
  if (r.reward) {
    const p = document.getElementById('recompensa');
    p.textContent = `Recompensa: ${r.reward}`;
    p.hidden = false;
  }
  document.getElementById('consejo').textContent = perdida
    ? 'Si la ves, no la persigas: avisá con el lugar y la hora. Si la tenés con vos, una veterinaria puede leer su microchip.'
    : 'Si es tuya o sabés de quién es, avisá: le llega tu mensaje a quien la encontró.';
  document.getElementById('zona').href =
    `https://www.google.com/maps/search/?api=1&query=${r.lat},${r.lng}`;
  document.getElementById('pedido-aviso').textContent = perdida
    ? '¿La viste o la tenés? Avisale a su familia: les llega tu mensaje y deciden cómo contactarte.'
    : '¿Es tuya o sabés de quién es? Avisale a quien la encontró.';
  document.getElementById('abrir-aviso').textContent = perdida ? 'Avisar a su familia' : 'Es mía / sé de quién es';
  document.getElementById('reporte').hidden = false;
}

async function iniciarSos() {
  const id = codigoDeLaDireccion().toLowerCase();
  try {
    if (!/^[0-9a-f-]{36}$/.test(id)) throw new Error('no_encontrado');
    const r = await rpc('sos_publico', { p_id: id });
    if (r.status === 'not_found') throw new Error('no_encontrado');
    mostrarReporte(r);
    if (r.status === 'active') window.dispatchEvent(new CustomEvent('sos:reporte', { detail: { id } }));
  } catch (e) {
    if (e.message === 'no_encontrado') {
      mostrarEstadoSos('Este reporte no existe', 'Puede que lo hayan borrado o que el enlace esté incompleto.');
    } else {
      console.error(e);
      mostrarEstadoSos('No pudimos cargar el reporte', 'Revisá tu conexión y volvé a intentar.');
    }
  } finally {
    document.getElementById('cargando').hidden = true;
  }
}

iniciarSos();
