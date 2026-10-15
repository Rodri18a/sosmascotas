// Paso 0.6.3: al publicar un SOS, la app llama a esta función y se avisa por
// push a quienes están cerca (hasta su radio, como máximo 3 avisos por día).
// Cada SOS se difunde una sola vez: si la app reintenta, no se repite.
// Privacidad: nadie recibe datos de quién publicó ni la ubicación exacta;
// la distancia del aviso sale de la ubicación pública y se redondea.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { cuentaFcm, enviarPush } from '../_shared/fcm.ts';
import { textoDelAviso } from './texto.ts';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const TOPE_DIARIO = 3;

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

  // Sin Firebase no se marca nada: la app reintenta cuando esté configurado.
  if (!cuentaFcm()) {
    console.error('Falta FIREBASE_SERVICE_ACCOUNT: no se difunde el SOS');
    return responder(503, { error: 'push_sin_configurar' });
  }

  const { data: sos } = await admin
    .from('sos_reports')
    .select('kind, name, user_id, species(slug)')
    .eq('id', sosId)
    .maybeSingle();
  // Igual que si no existiera: no se revela si el SOS es de otra persona.
  if (!sos || sos.user_id !== autor) return responder(404, { error: 'no_encontrado' });

  const { data: destinatarios, error } = await admin.rpc('difundir_sos', {
    p_sos: sosId,
    p_autor: autor,
    p_tope_diario: TOPE_DIARIO,
  });
  if (error) {
    console.error('No se pudo difundir el SOS', sosId, error.message);
    return responder(500, { error: 'no_se_pudo_difundir' });
  }

  const especie = (sos.species as { slug?: string } | null)?.slug ?? null;
  let dispositivos = 0;
  const invalidos: string[] = [];
  for (const d of (destinatarios ?? []) as { distancia_m: number; tokens: string[] }[]) {
    const texto = textoDelAviso(sos.kind, especie, sos.name, d.distancia_m);
    try {
      const r = await enviarPush(d.tokens, { titulo: texto.titulo, cuerpo: texto.cuerpo, ruta: `/sos/${sosId}` });
      dispositivos += r.enviados;
      invalidos.push(...r.tokensInvalidos);
    } catch (e) {
      console.error('No se pudo mandar la push', (e as Error).message);
    }
  }
  if (invalidos.length > 0) {
    await admin.from('push_tokens').delete().in('token', invalidos);
  }

  const personas = destinatarios?.length ?? 0;
  // Métrica anónima: cuántos avisos salieron, sin datos de nadie.
  await admin.from('events').insert({
    name: 'sos_zone_alert',
    anon_id: crypto.randomUUID(),
    target_id: sosId,
    props: { personas, dispositivos, tipo: sos.kind },
  });
  return responder(200, { avisados: personas });
});
