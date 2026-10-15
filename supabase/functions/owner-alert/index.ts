// Paso 0.4.4: contacto inverso. Quien encuentra a una mascota (sin cuenta)
// deja un aviso al dueño. El teléfono del dueño nunca sale de la base.
//
// Defensas: anti-bots (Cloudflare Turnstile), límites por dispositivo y por
// mascota/reporte, remitentes bloqueados por estafa (se descartan en silencio)
// y validación de todos los campos.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { textoAvisoAlDueno } from '../qr-scan-alert/texto.ts';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const LIMITE_POR_DISPOSITIVO_HORA = 5;
const LIMITE_POR_DESTINO_HORA = 10;

const responder = (estado: number, cuerpo: Record<string, unknown>) =>
  new Response(JSON.stringify(cuerpo), {
    status: estado,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });

const texto = (v: unknown, min: number, max: number): string | null => {
  if (typeof v !== 'string') return null;
  const limpio = v.trim();
  return limpio.length >= min && limpio.length <= max ? limpio : null;
};

async function sha256(valor: string): Promise<string> {
  const datos = new TextEncoder().encode(valor);
  const hash = await crypto.subtle.digest('SHA-256', datos);
  return [...new Uint8Array(hash)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

async function pasaTurnstile(token: string, ip: string): Promise<boolean> {
  const secreto = Deno.env.get('TURNSTILE_SECRET');
  if (!secreto) {
    console.error('Falta TURNSTILE_SECRET: se rechazan todos los avisos');
    return false;
  }
  const form = new FormData();
  form.append('secret', secreto);
  form.append('response', token);
  if (ip) form.append('remoteip', ip);
  const r = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    body: form,
  });
  const datos = await r.json();
  return datos.success === true;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return responder(405, { error: 'metodo_no_permitido' });

  let cuerpo: Record<string, unknown>;
  try {
    cuerpo = await req.json();
  } catch {
    return responder(400, { error: 'json_invalido' });
  }

  // 1. Validar campos (antes de gastar una consulta a Turnstile).
  const tipo = cuerpo.target_type;
  const mensaje = texto(cuerpo.message, 1, 1000);
  const nombre = texto(cuerpo.sender_name, 1, 60);
  const contacto = texto(cuerpo.sender_contact, 6, 80);
  const token = texto(cuerpo.turnstile_token, 1, 4096);
  if ((tipo !== 'qr' && tipo !== 'sos') || !mensaje || !nombre || !contacto) {
    return responder(400, { error: 'datos_incompletos' });
  }
  if (cuerpo.consent !== true) return responder(400, { error: 'falta_consentimiento' });

  let ubicacion: string | null = null;
  const loc = cuerpo.location as { lat?: unknown; lng?: unknown } | undefined;
  if (loc && typeof loc.lat === 'number' && typeof loc.lng === 'number') {
    if (Math.abs(loc.lat) > 90 || Math.abs(loc.lng) > 180) {
      return responder(400, { error: 'ubicacion_invalida' });
    }
    ubicacion = `SRID=4326;POINT(${loc.lng} ${loc.lat})`;
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // 2. ¿Quién avisa? Con sesión (desde la app) ya está identificado y no hace
  // falta el anti-bots; sin sesión (página pública), Turnstile es obligatorio.
  let remitente: string | null = null;
  const sesion = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (sesion && sesion.split('.').length === 3) {
    const { data } = await admin.auth.getUser(sesion);
    remitente = data.user?.id ?? null;
  }
  const ip = (req.headers.get('x-forwarded-for') ?? '').split(',')[0].trim();
  if (!remitente) {
    if (!token) return responder(400, { error: 'falta_antibots' });
    if (!(await pasaTurnstile(token, ip))) return responder(403, { error: 'antibots' });
  }

  // 3. ¿A quién va el aviso? (el dueño nunca se expone en la respuesta)
  let destino:
    | { target_id: string; owner_id: string; pet_id: string | null; nombre: string | null }
    | null = null;
  if (tipo === 'qr') {
    const codigo = texto(cuerpo.code, 8, 8)?.toUpperCase();
    if (!codigo) return responder(400, { error: 'datos_incompletos' });
    const { data } = await admin
      .from('qr_tags')
      .select('id, owner_id, pet_id, active, pets(name)')
      .eq('code', codigo)
      .maybeSingle();
    if (data?.active && data.pet_id && data.owner_id) {
      destino = {
        target_id: data.id,
        owner_id: data.owner_id,
        pet_id: data.pet_id,
        nombre: (data.pets as { name?: string } | null)?.name ?? null,
      };
    }
  } else {
    const reporte = texto(cuerpo.report_id, 36, 36);
    if (!reporte) return responder(400, { error: 'datos_incompletos' });
    const { data } = await admin
      .from('sos_reports')
      .select('id, user_id, pet_id, status, name')
      .eq('id', reporte)
      .maybeSingle();
    if (data?.status === 'active') {
      destino = { target_id: data.id, owner_id: data.user_id, pet_id: data.pet_id, nombre: data.name };
    }
  }
  if (!destino) return responder(404, { error: 'no_encontrado' });

  // 4. Límites por dispositivo y por destino.
  const dispositivo = await sha256(`${ip}|${req.headers.get('user-agent') ?? ''}`);
  const haceUnaHora = new Date(Date.now() - 3600_000).toISOString();
  const [{ count: porDispositivo }, { count: porDestino }] = await Promise.all([
    admin.from('owner_alerts').select('id', { count: 'exact', head: true })
      .eq('device_hash', dispositivo).gte('created_at', haceUnaHora),
    admin.from('owner_alerts').select('id', { count: 'exact', head: true })
      .eq('target_id', destino.target_id).gte('created_at', haceUnaHora),
  ]);
  if ((porDispositivo ?? 0) >= LIMITE_POR_DISPOSITIVO_HORA ||
      (porDestino ?? 0) >= LIMITE_POR_DESTINO_HORA) {
    return responder(429, { error: 'demasiados_avisos' });
  }

  // 5. Remitente bloqueado por estafa: se responde "ok" sin guardar nada.
  const { data: bloqueado } = await admin
    .from('blocked_senders')
    .select('device_hash')
    .eq('owner_id', destino.owner_id)
    .eq('device_hash', dispositivo)
    .maybeSingle();
  if (bloqueado) return responder(200, { ok: true });

  // 6. Guardar (si quien avisa tiene sesión, se guarda quién es: chat en la Fase 1).
  const { error } = await admin.from('owner_alerts').insert({
    target_type: tipo,
    target_id: destino.target_id,
    owner_id: destino.owner_id,
    pet_id: destino.pet_id,
    from_user_id: remitente,
    sender_name: nombre,
    sender_contact: contacto,
    message: mensaje,
    location: ubicacion,
    device_hash: dispositivo,
  });
  if (error) {
    console.error('No se pudo guardar el aviso', error.message);
    return responder(500, { error: 'no_se_pudo_guardar' });
  }

  // Métrica anónima (sin datos de quién avisa).
  await admin.from('events').insert({
    name: tipo === 'qr' ? 'qr_alert' : 'sos_alert',
    anon_id: crypto.randomUUID(),
    target_id: destino.target_id,
    props: { con_ubicacion: ubicacion !== null },
  });

  // Push al dueño (0.6.4): abre la bandeja Avisos. Si no sale, el aviso ya
  // quedó guardado ahí. El correo de respaldo llega con 0.4.4b.
  const { data: dispositivos } = await admin
    .from('push_tokens')
    .select('token')
    .eq('user_id', destino.owner_id);
  const push = textoAvisoAlDueno(tipo, destino.nombre);
  await avisarDispositivos(admin, (dispositivos ?? []).map((d) => d.token), {
    titulo: push.titulo,
    cuerpo: push.cuerpo,
    ruta: '/avisos',
  });
  return responder(200, { ok: true });
});
