// Paso 0.6.4: la página pública del QR la llama después de registrar un
// escaneo, y se avisa por push al dueño. No pide sesión (quien escanea no
// tiene cuenta): solo sirve el id del escaneo recién registrado, y
// aviso_escaneo() limita a una push por QR cada 10 minutos.
// Nunca se manda nada de quien escaneó.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { textoEscaneo } from './texto.ts';

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

  let escaneo: string | null = null;
  try {
    const cuerpo = await req.json();
    escaneo = typeof cuerpo.scan_id === 'string' && /^[0-9a-f-]{36}$/i.test(cuerpo.scan_id)
      ? cuerpo.scan_id
      : null;
  } catch {
    // Cuerpo inválido: se responde abajo.
  }
  if (!escaneo) return responder(400, { error: 'datos_incompletos' });

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  const { data, error } = await admin.rpc('aviso_escaneo', { p_scan: escaneo });
  if (error) {
    console.error('No se pudo leer el escaneo', error.message);
    return responder(500, { error: 'error' });
  }
  const aviso = (data ?? [])[0] as
    | { pet_id: string | null; pet_name: string | null; tokens: string[] }
    | undefined;
  // Siempre la misma respuesta: no se revela si avisó ni a quién.
  if (!aviso) return responder(200, { ok: true });

  const texto = textoEscaneo(aviso.pet_name);
  const enviados = await avisarDispositivos(admin, aviso.tokens, {
    titulo: texto.titulo,
    cuerpo: texto.cuerpo,
    ruta: aviso.pet_id ? `/mascotas/${aviso.pet_id}/qr` : '/mascotas',
  });
  await admin.from('events').insert({
    name: 'qr_scan_push',
    anon_id: crypto.randomUUID(),
    props: { dispositivos: enviados },
  });
  return responder(200, { ok: true });
});
