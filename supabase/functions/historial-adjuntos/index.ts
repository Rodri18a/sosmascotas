// Plan de mejoras 2.2b (D133): adjuntos del historial compartido. Con un
// enlace vigente (pet_shares), devuelve enlaces firmados de 1 hora para las
// fotos y PDF del historial de vida de ESA mascota. El bucket pet-records es
// privado: sin un token válido no sale nada.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const responder = (estado: number, cuerpo: Record<string, unknown>) =>
  new Response(JSON.stringify(cuerpo), {
    status: estado,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return responder(405, { error: 'metodo_no_permitido' });

  let token: unknown;
  try {
    ({ token } = await req.json());
  } catch {
    return responder(400, { error: 'cuerpo_invalido' });
  }
  if (typeof token !== 'string' || !/^[A-Za-z0-9_-]{22}$/.test(token)) {
    return responder(404, { error: 'no_encontrado' });
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } },
  );

  const { data: enlace } = await admin
    .from('pet_shares')
    .select('pet_id')
    .eq('token', token)
    .is('revoked_at', null)
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();
  if (!enlace) return responder(404, { error: 'no_encontrado' });

  const { data: eventos, error } = await admin
    .from('life_events')
    .select('files')
    .eq('pet_id', enlace.pet_id);
  if (error) return responder(500, { error: 'no_disponible' });

  // Solo rutas de la carpeta de esa mascota (lo exige también la base).
  const rutas = (eventos ?? [])
    .flatMap((e) => (e.files as string[]) ?? [])
    .filter((r) => r.startsWith(`${enlace.pet_id}/`));
  if (rutas.length === 0) return responder(200, { urls: {} });

  const { data: firmadas, error: errorFirma } = await admin.storage
    .from('pet-records')
    .createSignedUrls(rutas, 3600);
  if (errorFirma) return responder(500, { error: 'no_disponible' });

  const urls: Record<string, string> = {};
  for (const f of firmadas ?? []) {
    if (f.path && f.signedUrl) urls[f.path] = f.signedUrl;
  }
  return responder(200, { urls });
});
