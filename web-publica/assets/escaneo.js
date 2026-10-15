// Registra el escaneo (la familia ve que alguien abrió la página) y permite
// compartir la ubicación con un toque.
'use strict';

window.addEventListener('sos:mascota', async (e) => {
  let escaneo = null;
  try {
    escaneo = await rpc('registrar_escaneo', { p_code: e.detail.codigo });
  } catch (error) {
    console.error(error);
  }
  // Aviso push al dueño (no se espera: si falla, la página sigue igual).
  if (escaneo) {
    fetch(`${CONF.supabaseUrl}/functions/v1/qr-scan-alert`, {
      method: 'POST',
      headers: { apikey: CONF.supabaseKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({ scan_id: escaneo }),
    }).catch((error) => console.error(error));
  }
  const boton = document.getElementById('compartir-ubicacion-escaneo');
  if (!escaneo || !navigator.geolocation) return;
  boton.hidden = false;
  boton.addEventListener('click', () => {
    boton.disabled = true;
    boton.textContent = 'Buscando tu ubicación…';
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        try {
          const ok = await rpc('compartir_ubicacion_escaneo', {
            p_scan_id: escaneo, p_lat: pos.coords.latitude, p_lng: pos.coords.longitude,
          });
          if (!ok) throw new Error('no_compartida');
          boton.hidden = true;
          document.getElementById('ubicacion-compartida').hidden = false;
        } catch {
          boton.disabled = false;
          boton.textContent = 'No se pudo compartir. Tocá para reintentar';
        }
      },
      () => {
        boton.disabled = false;
        boton.textContent = 'Necesitamos permiso de ubicación. Tocá para reintentar';
      },
      { enableHighAccuracy: true, timeout: 15000 },
    );
  });
});
