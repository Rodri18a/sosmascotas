// Envío de push con Firebase Cloud Messaging (API HTTP v1). Lo usan las Edge
// Functions que avisan (0.6.3 SOS por zona, 0.6.4 escaneo del QR).
//
// Necesita el secreto FIREBASE_SERVICE_ACCOUNT: el JSON de una cuenta de
// servicio de Firebase (Configuración del proyecto → Cuentas de servicio).
// Nunca va al repositorio: se carga con `supabase secrets set`.

type CuentaDeServicio = { project_id: string; client_email: string; private_key: string };

export type Push = {
  titulo: string;
  cuerpo: string;
  /** Ruta de la app que se abre al tocar la notificación (D55). */
  ruta: string;
};

export type ResultadoEnvio = { enviados: number; tokensInvalidos: string[] };

// Solo se recuerda la cuenta válida: si falta el secreto, se vuelve a leer
// (al cargarlo, la instancia que ya estaba corriendo lo toma sin redesplegar).
let cuenta: CuentaDeServicio | null = null;
let acceso: { token: string; vence: number } | null = null;

/** La cuenta de servicio, o `null` si falta el secreto (no se puede enviar). */
export function cuentaFcm(): CuentaDeServicio | null {
  if (cuenta) return cuenta;
  let leida: CuentaDeServicio | null = null;
  try {
    const json = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '');
    if (json.project_id && json.client_email && json.private_key) leida = json;
  } catch {
    // Falta el secreto o no es un JSON válido.
  }
  cuenta = leida;
  return leida;
}

const base64url = (datos: Uint8Array | string) =>
  btoa(typeof datos === 'string' ? datos : String.fromCharCode(...datos))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

/** Token de acceso de Google (OAuth con JWT firmado), guardado ~55 minutos. */
async function tokenDeAcceso(c: CuentaDeServicio): Promise<string> {
  if (acceso && acceso.vence > Date.now()) return acceso.token;
  const ahora = Math.floor(Date.now() / 1000);
  const encabezado = base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const datos = base64url(JSON.stringify({
    iss: c.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: ahora,
    exp: ahora + 3600,
  }));
  const pem = c.private_key.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  const clave = await crypto.subtle.importKey(
    'pkcs8',
    Uint8Array.from(atob(pem), (ch) => ch.charCodeAt(0)),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const firma = new Uint8Array(await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    clave,
    new TextEncoder().encode(`${encabezado}.${datos}`),
  ));
  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${encabezado}.${datos}.${base64url(firma)}`,
    }),
  });
  if (!r.ok) throw new Error(`Google OAuth respondió ${r.status}: ${await r.text()}`);
  const { access_token } = await r.json();
  acceso = { token: access_token, vence: Date.now() + 55 * 60_000 };
  return access_token;
}

/**
 * Manda la misma push a varios dispositivos. Devuelve cuántas salieron y qué
 * tokens ya no existen (para borrarlos de push_tokens).
 */
export async function enviarPush(tokens: string[], push: Push): Promise<ResultadoEnvio> {
  const c = cuentaFcm();
  if (!c) throw new Error('Falta FIREBASE_SERVICE_ACCOUNT');
  const bearer = await tokenDeAcceso(c);
  const url = `https://fcm.googleapis.com/v1/projects/${c.project_id}/messages:send`;
  const resultado: ResultadoEnvio = { enviados: 0, tokensInvalidos: [] };

  // De a 20 a la vez para no saturar la función.
  for (let i = 0; i < tokens.length; i += 20) {
    await Promise.all(tokens.slice(i, i + 20).map(async (token) => {
      const r = await fetch(url, {
        method: 'POST',
        headers: { Authorization: `Bearer ${bearer}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: push.titulo, body: push.cuerpo },
            data: { ruta: push.ruta },
          },
        }),
      });
      if (r.ok) {
        resultado.enviados++;
        return;
      }
      const error = await r.text();
      // El dispositivo se desinstaló o el token venció: no sirve más.
      if (r.status === 404 || error.includes('UNREGISTERED') ||
          (r.status === 400 && error.includes('registration token'))) {
        resultado.tokensInvalidos.push(token);
      } else {
        console.error('FCM no aceptó la push', r.status, error.slice(0, 300));
      }
    }));
  }
  return resultado;
}
