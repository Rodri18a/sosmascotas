// Historial compartido de solo lectura (D133): /h/<token>.
'use strict';

const TIPOS_LIBRETA = {
  vaccine: 'Vacunas', deworming: 'Desparasitaciones', checkup: 'Controles',
  allergy: 'Alergias', other: 'Otros',
};
const TIPOS_VIDA = {
  surgery: 'Operación', accident: 'Accidente', illness: 'Enfermedad',
  treatment: 'Tratamiento', diagnosis: 'Diagnóstico', other: 'Otro',
};
const SEXO = { male: 'Macho', female: 'Hembra' };

/** Fecha «AAAA-MM-DD» (de la base) como «14/03/2026», sin corrimientos de zona. */
function fecha(texto) {
  if (!texto) return '';
  const [a, m, d] = texto.slice(0, 10).split('-');
  return `${d}/${m}/${a}`;
}

function edad(nacimiento) {
  if (!nacimiento) return null;
  const n = new Date(`${nacimiento}T12:00:00`);
  const hoy = new Date();
  let meses = (hoy.getFullYear() - n.getFullYear()) * 12 + hoy.getMonth() - n.getMonth();
  if (hoy.getDate() < n.getDate()) meses -= 1;
  if (meses < 12) return meses === 1 ? '1 mes' : `${Math.max(meses, 0)} meses`;
  const anios = Math.floor(meses / 12);
  return anios === 1 ? '1 año' : `${anios} años`;
}

function mostrarEstado(titulo, texto) {
  document.getElementById('estado-titulo').textContent = titulo;
  document.getElementById('estado-texto').textContent = texto;
  document.getElementById('estado').hidden = false;
}

function renglon(titulo, ...extras) {
  const div = el('div', null, 'renglon');
  div.append(el('strong', titulo));
  for (const x of extras) if (x) div.append(el('p', x, 'ayuda'));
  return div;
}

/** Fotos (miniatura) y PDF (enlace) de un acontecimiento, ya firmados. */
function adjuntos(rutas, urls) {
  const div = el('div', null, 'adjuntos');
  let n = 0;
  let fotos = 0;
  let documentos = 0;
  for (const ruta of rutas || []) {
    const url = urls[ruta];
    if (!url) continue;
    n += 1;
    const a = el('a', null, 'adjunto');
    a.href = url;
    a.target = '_blank';
    a.rel = 'noopener noreferrer';
    if (ruta.toLowerCase().endsWith('.pdf')) {
      documentos += 1;
      a.textContent = `📄 Documento ${documentos} (PDF)`;
    } else {
      const img = el('img');
      img.src = url;
      fotos += 1;
      img.alt = `Foto ${fotos}`;
      img.loading = 'lazy';
      a.append(img);
    }
    div.append(a);
  }
  return n ? div : null;
}

/** Enlaces firmados de 1 hora para los adjuntos (Edge Function, D133). */
async function urlsDeAdjuntos(token) {
  try {
    const r = await fetch(`${CONF.supabaseUrl}/functions/v1/historial-adjuntos`, {
      method: 'POST',
      headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });
    if (!r.ok) return {};
    return (await r.json()).urls || {};
  } catch (_) {
    return {};
  }
}

function mostrar(h, urls) {
  const p = h.pet;
  document.title = `Historial de ${p.name} · Huellamy`;
  const foto = urlFoto('pet-photos', p.photo_path);
  const contenedor = document.getElementById('foto-contenedor');
  if (foto) {
    const img = el('img', null, 'foto');
    img.src = foto;
    img.alt = `Foto de ${p.name}`;
    contenedor.append(img);
  }
  document.getElementById('nombre').textContent = p.name;
  document.getElementById('detalle').textContent =
    [p.species, p.breed, SEXO[p.sex], edad(p.birth)].filter(Boolean).join(' · ');
  document.getElementById('datos').textContent = [
    p.birth ? `Nació el ${fecha(p.birth)}` : null,
    p.neutered === true ? 'Castrada/o' : p.neutered === false ? 'Sin castrar' : null,
    p.microchip ? `Microchip ${p.microchip}` : null,
  ].filter(Boolean).join(' · ');
  document.getElementById('vence').textContent =
    `Este enlace vence el ${new Date(h.expires_at).toLocaleDateString('es-UY')}.`;

  const libreta = document.getElementById('libreta');
  if (!h.health.length) libreta.append(el('p', 'Sin registros.', 'ayuda'));
  let grupo = null;
  for (const r of h.health) {
    if (r.kind !== grupo) {
      grupo = r.kind;
      libreta.append(el('h3', TIPOS_LIBRETA[r.kind] || 'Otros'));
    }
    libreta.append(renglon(
      [r.name, fecha(r.date)].filter(Boolean).join(' · '),
      r.next_date ? `Próxima: ${fecha(r.next_date)}` : null,
      r.notes,
    ));
  }

  const vida = document.getElementById('vida');
  if (!h.life.length) vida.append(el('p', 'Sin acontecimientos.', 'ayuda'));
  for (const e of h.life) {
    const fila = renglon(`${fecha(e.date)} · ${TIPOS_VIDA[e.kind] || 'Otro'} · ${e.title}`, e.notes);
    const extra = adjuntos(e.paths, urls);
    if (extra) {
      fila.append(extra);
    } else if (e.files) {
      // Sin los enlaces (por ejemplo, sin conexión a la función): se avisa.
      fila.append(el('p', `${e.files === 1 ? '1 adjunto' : `${e.files} adjuntos`}: pedíselos a la familia.`, 'ayuda'));
    }
    vida.append(fila);
  }
  document.getElementById('historial').hidden = false;
}

/** Métrica anónima: se abrió un historial compartido. */
function registrarApertura() {
  let anon = null;
  try {
    anon = localStorage.getItem('sos_anon_id');
    if (!anon) {
      anon = crypto.randomUUID();
      localStorage.setItem('sos_anon_id', anon);
    }
  } catch (_) {
    anon = crypto.randomUUID();
  }
  fetch(`${CONF.supabaseUrl}/rest/v1/events`, {
    method: 'POST',
    headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json', Prefer: 'return=minimal' },
    body: JSON.stringify({ name: 'history_share_open', anon_id: anon, platform: 'web' }),
  }).catch(() => {});
}

async function iniciarHistorial() {
  // El enlace distingue mayúsculas: no se usa codigoDeLaDireccion().
  const partes = location.pathname.split('/').filter(Boolean);
  const token = decodeURIComponent(partes[partes.length - 1] || '').trim();
  try {
    if (!/^[A-Za-z0-9_-]{22}$/.test(token)) throw new Error('no_encontrado');
    const h = await rpc('historial_compartido', { p_token: token });
    if (!h) throw new Error('no_encontrado');
    const conAdjuntos = h.life.some((e) => e.files);
    mostrar(h, conAdjuntos ? await urlsDeAdjuntos(token) : {});
    registrarApertura();
  } catch (e) {
    if (e.message === 'no_encontrado') {
      mostrarEstado('Este enlace ya no funciona', 'Puede que haya vencido o que la familia lo haya cortado. Pediles uno nuevo.');
    } else {
      console.error(e);
      mostrarEstado('No pudimos cargar el historial', 'Revisá tu conexión y volvé a intentar.');
    }
  } finally {
    document.getElementById('cargando').hidden = true;
  }
}

iniciarHistorial();
