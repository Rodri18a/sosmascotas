// Paso 1.4.5: cuando el autor marca "¡Apareció!", la app llama a esta
// función y se avisa por push a quienes seguían el SOS (una sola vez por
// persona: si la app reintenta, no se repite). No se manda nada del autor.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { textoReencuentro } from './texto.ts';

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

  const sesion = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!sesion) return responder(401, { error: 'sin_sesion' });

  let sosId: string | null = null;
  try {
    const cuerpo = await req.json();
    sosId = typeof cuerpo.sos_id === 'string' && /^[0-9a-f-]{36}$/i.test(cuerpo.sos_id)
      ? cuerpo.sos_id
      : null;
  } catch {
    // Cuerpo inválido: se responde abajo.
  }
  if (!sosId) return responder(400, { error: 'datos_incompletos' });

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  const { data: usuario } = await admin.auth.getUser(sesion);
  const autor = usuario.user?.id;
  if (!autor) return responder(401, { error: 'sesion_invalida' });

  // Solo hace algo si el SOS es del autor y ya está resuelto.
  const { data, error } = await admin.rpc('avisar_seguidores_sos', {
    p_sos: sosId,
    p_autor: autor,
  });
  if (error) {
    console.error('No se pudo avisar a los seguidores', sosId, error.message);
    return responder(500, { error: 'error' });
  }
  const aviso = (data ?? [])[0] as { nombre: string | null; tokens: string[] } | undefined;
  if (!aviso || aviso.tokens.length === 0) return responder(200, { ok: true, avisados: 0 });

  const texto = textoReencuentro(aviso.nombre);
  const enviados = await avisarDispositivos(admin, aviso.tokens, {
    titulo: texto.titulo,
    cuerpo: texto.cuerpo,
    ruta: `/sos/${sosId}`,
  });
  await admin.from('events').insert({
    name: 'sos_follow_push',
    anon_id: crypto.randomUUID(),
    target_id: sosId,
    props: { dispositivos: enviados },
  });
  return responder(200, { ok: true, avisados: enviados });
});
