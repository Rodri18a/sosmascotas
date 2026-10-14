// Utilidades compartidas por las páginas públicas.
'use strict';

const CONF = window.SOS_CONFIG || {};

/** Llama a una función RPC pública de Supabase. */
async function rpc(nombre, parametros) {
  const r = await fetch(`${CONF.supabaseUrl}/rest/v1/rpc/${nombre}`, {
    method: 'POST',
    headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json' },
    body: JSON.stringify(parametros),
  });
  if (!r.ok) throw new Error(`rpc ${nombre}: ${r.status}`);
  return r.json();
}

/** Enlace público de una foto guardada en Storage. */
function urlFoto(bucket, ruta) {
  return ruta ? `${CONF.supabaseUrl}/storage/v1/object/public/${bucket}/${ruta.split('/').map(encodeURIComponent).join('/')}` : null;
}

/** Crea un elemento con texto (nunca HTML: evita inyecciones). */
function el(etiqueta, texto, clase) {
  const e = document.createElement(etiqueta);
  if (texto != null) e.textContent = texto;
  if (clase) e.className = clase;
  return e;
}

/** Último segmento de la dirección: /m/K7M2QX9P → K7M2QX9P. */
function codigoDeLaDireccion() {
  const partes = location.pathname.split('/').filter(Boolean);
  return decodeURIComponent(partes[partes.length - 1] || '').trim().toUpperCase();
}
