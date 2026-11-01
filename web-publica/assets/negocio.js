// Página pública de un comercio para compartir: /n/<id> (2.10b, D90).
'use strict';

const RUBROS = {
  vet: 'Veterinaria', petshop: 'Petshop', pharmacy: 'Farmacia veterinaria',
  grooming: 'Peluquería', walker: 'Paseador', hotel: 'Hotel o guardería',
  trainer: 'Adiestrador', pet_friendly: 'Acepta mascotas', shelter: 'Refugio',
  agro: 'Agropecuaria / agroveterinaria',
};
const DIAS = [['mon', 'Lunes'], ['tue', 'Martes'], ['wed', 'Miércoles'], ['thu', 'Jueves'],
  ['fri', 'Viernes'], ['sat', 'Sábado'], ['sun', 'Domingo']];

/** "$ 1.780" o "$ 89,50" (igual que la app). */
function precio(n) {
  const centavos = Math.round(Number(n) * 100);
  const enteros = Math.floor(centavos / 100).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const resto = centavos % 100;
  return resto === 0 ? `$ ${enteros}` : `$ ${enteros},${String(resto).padStart(2, '0')}`;
}

function duracion(min) {
  const h = Math.floor(min / 60);
  const m = min % 60;
  if (h === 0) return `${m} min`;
  return m === 0 ? `${h} h` : `${h} h ${m} min`;
}

/** Día (clave de `hours`), fecha y minutos de ahora en Uruguay. */
function ahoraEnUruguay() {
  const partes = Object.fromEntries(new Intl.DateTimeFormat('en-US', {
    timeZone: 'America/Montevideo', weekday: 'short', year: 'numeric', month: '2-digit',
    day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23',
  }).formatToParts(new Date()).map((p) => [p.type, p.value]));
  return {
    dia: partes.weekday.toLowerCase().slice(0, 3),
    fecha: `${partes.year}-${partes.month}-${partes.day}`,
    minutos: Number(partes.hour) * 60 + Number(partes.minute),
  };
}

function aMinutos(hora) {
  const [h, m] = hora.split(':').map(Number);
  return h * 60 + m;
}

/** "Abierto · cierra a las 19:00", "Cerrado ahora" o null si no hay horario. */
function textoApertura(n) {
  if (n.is_24h) return ['Abierto las 24 horas', true];
  const ahora = ahoraEnUruguay();
  const franjas = (n.special_days || {})[ahora.fecha] ?? (n.hours || {})[ahora.dia];
  if (!n.hours || Object.keys(n.hours).length === 0) return null;
  for (const [desde, hasta] of franjas || []) {
    if (ahora.minutos >= aMinutos(desde) && ahora.minutos < aMinutos(hasta)) {
      return [`Abierto · cierra a las ${hasta}`, true];
    }
  }
  return ['Cerrado ahora', false];
}

function enlace(texto, url, clase = 'boton secundario') {
  const a = el('a', texto, clase);
  a.href = url;
  a.target = '_blank';
  a.rel = 'noopener';
  return a;
}

/** WhatsApp del comercio (dato público del local) con el mensaje armado. */
function urlWhatsapp(numero, texto) {
  let solo = String(numero).replace(/\D/g, '');
  if (solo.startsWith('0')) solo = `598${solo.slice(1)}`;
  else if (!solo.startsWith('598')) solo = `598${solo}`;
  return `https://wa.me/${solo}?text=${encodeURIComponent(texto)}`;
}

function renglon(titulo, detalle, n, que) {
  const li = el('li');
  const texto = el('div');
  texto.append(el('strong', titulo));
  if (detalle) texto.append(el('p', detalle, 'ayuda'));
  li.append(texto);
  if (n.whatsapp) {
    li.append(enlace('Consultar', urlWhatsapp(n.whatsapp,
      `Hola, te escribo desde Huellitas. Quería consultar por: ${que}`), 'consultar'));
  }
  return li;
}

function mostrarEstado(titulo, texto) {
  document.getElementById('estado-titulo').textContent = titulo;
  document.getElementById('estado-texto').textContent = texto;
  document.getElementById('estado').hidden = false;
}

function mostrarNegocio(n) {
  const rubro = RUBROS[n.business_type] || '';
  document.title = `${n.name} · Huellitas`;
  document.querySelector('meta[name=description]').content =
    n.description || `${rubro} en Huellitas: servicios, horario y cómo llegar.`;

  const fotos = document.getElementById('fotos');
  for (const ruta of (n.photos || []).slice(0, 6)) {
    const img = el('img', null, 'foto');
    img.src = urlFoto('business-photos', ruta);
    img.alt = `Foto de ${n.name}`;
    img.loading = 'lazy';
    fotos.append(img);
  }

  document.getElementById('nombre').textContent = n.name;
  document.getElementById('rubro').textContent = [
    rubro,
    n.kind === 'online' ? 'Online' : n.kind === 'domicilio' ? 'A domicilio' : null,
    (n.species || []).length ? `Atiende: ${n.species.join(', ')}` : null,
  ].filter(Boolean).join(' · ');
  document.getElementById('insignias').textContent = [
    n.verified ? '✔️ Verificado' : null,
    n.renac_operator ? 'Operador RENAC (coloca microchip)' : null,
    n.emergencies ? 'Urgencias' : null,
    n.reviews > 0 ? `★ ${String(n.rating).replace('.', ',')} (${n.reviews} ${n.reviews === 1 ? 'reseña' : 'reseñas'})` : null,
  ].filter(Boolean).join(' · ');

  const apertura = textoApertura(n);
  const pApertura = document.getElementById('apertura');
  if (apertura) {
    pApertura.textContent = apertura[0];
    pApertura.classList.add(apertura[1] ? 'abierto' : 'cerrado');
  }
  if (n.promo) {
    const p = document.getElementById('promo');
    p.textContent = n.promo;
    p.hidden = false;
  }
  document.getElementById('descripcion').textContent = n.description || '';
  document.getElementById('direccion').textContent = n.kind === 'local' ? (n.address || '') : (n.coverage || '');

  const acciones = document.getElementById('acciones');
  if (n.whatsapp) acciones.append(enlace('WhatsApp', urlWhatsapp(n.whatsapp, 'Hola, te escribo desde Huellitas.'), 'boton principal'));
  if (n.phone) {
    const a = el('a', `Llamar · ${n.phone}`, 'boton secundario');
    a.href = `tel:${n.phone.replace(/\s/g, '')}`;
    acciones.append(a);
  }
  if (n.lat != null && n.lng != null) {
    acciones.append(enlace('Cómo llegar', `https://www.google.com/maps/dir/?api=1&destination=${n.lat},${n.lng}`));
  }
  if (n.web && /^https?:\/\//.test(n.web)) acciones.append(enlace('Sitio web', n.web));
  if (n.instagram) acciones.append(enlace('Instagram', `https://www.instagram.com/${encodeURIComponent(n.instagram)}/`));
  if (n.facebook) acciones.append(enlace('Facebook', `https://www.facebook.com/${encodeURIComponent(n.facebook)}`));

  if ((n.services || []).length) {
    const lista = document.getElementById('servicios');
    for (const s of n.services) {
      const valor = s.price == null ? 'Consultar precio' : `${s.price_from ? 'desde ' : ''}${precio(s.price)}`;
      const detalle = [s.description, [s.duration_min ? duracion(s.duration_min) : null, valor].filter(Boolean).join(' · ')]
        .filter(Boolean).join('\n');
      lista.append(renglon(s.name, detalle, n, s.name));
    }
    document.getElementById('tarjeta-servicios').hidden = false;
  }

  if ((n.products || []).length) {
    const lista = document.getElementById('productos');
    for (const p of n.products) {
      const valor = p.price == null ? 'Consultar precio' : precio(p.price);
      lista.append(renglon(p.name, [p.description, valor].filter(Boolean).join('\n'), n, p.name));
    }
    document.getElementById('tarjeta-productos').hidden = false;
  }

  if (!n.is_24h && n.hours && Object.keys(n.hours).length) {
    const tabla = document.getElementById('horario');
    for (const [clave, nombre] of DIAS) {
      const fila = el('tr');
      const franjas = n.hours[clave] || [];
      fila.append(el('th', nombre), el('td', franjas.length ? franjas.map(([d, h]) => `${d} a ${h}`).join(' y ') : 'Cerrado'));
      tabla.append(fila);
    }
    document.getElementById('tarjeta-horario').hidden = false;
  }

  if (CONF.appUrl) {
    const a = document.getElementById('abrir-app');
    a.href = CONF.appUrl;
    a.hidden = false;
  }
  document.getElementById('negocio').hidden = false;
}

/** Métrica anónima: se abrió la página (id al azar guardado en este navegador). */
function registrarApertura(id) {
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
    body: JSON.stringify({ name: 'business_page_open', anon_id: anon, business_id: id, platform: 'web' }),
  }).catch(() => {});
}

async function iniciarNegocio() {
  const id = codigoDeLaDireccion().toLowerCase();
  try {
    if (!/^[0-9a-f-]{36}$/.test(id)) throw new Error('no_encontrado');
    const n = await rpc('pagina_comercio', { p_id: id });
    if (n.status !== 'ok') throw new Error('no_encontrado');
    mostrarNegocio(n);
    registrarApertura(id);
  } catch (e) {
    if (e.message === 'no_encontrado') {
      mostrarEstado('Esta página no está disponible', 'Puede que el comercio ya no la tenga o que el enlace esté incompleto.');
    } else {
      console.error(e);
      mostrarEstado('No pudimos cargar la página', 'Revisá tu conexión y volvé a intentar.');
    }
  } finally {
    document.getElementById('cargando').hidden = true;
  }
}

iniciarNegocio();
