// 0.8.6d (D156, D158): formulario de contacto de la landing (huellamy.com).
// Guarda el mensaje para el portal → Contactos. No muestra ni pide teléfonos.
//
// Defensas: anti-bots (Cloudflare Turnstile), campo trampa para robots, límite
// por dispositivo y límite general por hora, y validación de todos los campos.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const LIMITE_POR_DISPOSITIVO_HORA = 3;
const LIMITE_GENERAL_HORA = 60;
const TIPOS = ['owner', 'business', 'other'];
const CORREO = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

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
    console.error('Falta TURNSTILE_SECRET: se rechazan todos los mensajes');
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

  // 1. Campo trampa: una persona no lo ve ni lo completa. Se responde "ok"
  // sin guardar nada, para que el robot no aprenda.
  if (typeof cuerpo.website === 'string' && cuerpo.website.trim() !== '') {
    return responder(200, { ok: true });
  }

  // 2. Validar campos (antes de gastar una consulta a Turnstile).
  const tipo = typeof cuerpo.kind === 'string' && TIPOS.includes(cuerpo.kind) ? cuerpo.kind : null;
  const nombre = texto(cuerpo.name, 2, 80);
  const correo = texto(cuerpo.email, 5, 120)?.toLowerCase() ?? null;
  const comercio = texto(cuerpo.business, 1, 80);
  const mensaje = texto(cuerpo.message, 5, 2000);
  const token = texto(cuerpo.turnstile_token, 1, 4096);
  if (!tipo || !nombre || !mensaje) return responder(400, { error: 'datos_incompletos' });
  if (!correo || !CORREO.test(correo)) return responder(400, { error: 'correo_invalido' });
  if (cuerpo.consent !== true) return responder(400, { error: 'falta_consentimiento' });
  if (!token) return responder(400, { error: 'falta_antibots' });

  const ip = (req.headers.get('x-forwarded-for') ?? '').split(',')[0].trim();
  if (!(await pasaTurnstile(token, ip))) return responder(403, { error: 'antibots' });

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // 3. Límites por dispositivo y general (por si alguien insiste).
  const dispositivo = await sha256(`${ip}|${req.headers.get('user-agent') ?? ''}`);
  const haceUnaHora = new Date(Date.now() - 3600_000).toISOString();
  const [{ count: porDispositivo }, { count: general }] = await Promise.all([
    admin.from('contact_messages').select('id', { count: 'exact', head: true })
      .eq('device_hash', dispositivo).gte('created_at', haceUnaHora),
    admin.from('contact_messages').select('id', { count: 'exact', head: true })
      .gte('created_at', haceUnaHora),
  ]);
  if ((porDispositivo ?? 0) >= LIMITE_POR_DISPOSITIVO_HORA || (general ?? 0) >= LIMITE_GENERAL_HORA) {
    return responder(429, { error: 'demasiados_mensajes' });
  }

  // 4. Guardar.
  const { error } = await admin.from('contact_messages').insert({
    kind: tipo,
    name: nombre,
    email: correo,
    business: tipo === 'business' ? comercio : null,
    message: mensaje,
    device_hash: dispositivo,
  });
  if (error) {
    console.error('No se pudo guardar el mensaje', error.message);
    return responder(500, { error: 'no_se_pudo_guardar' });
  }

  // Métrica anónima (sin datos de quién escribe).
  await admin.from('events').insert({
    name: 'landing_contact',
    anon_id: texto(cuerpo.anon_id, 36, 36) ?? crypto.randomUUID(),
    platform: 'web',
    props: { tipo },
  });

  return responder(200, { ok: true });
});
