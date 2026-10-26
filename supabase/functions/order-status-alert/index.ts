// Etapa 3.2 (D100): después de pedir o de cambiar el estado de un pedido, la
// app llama a esta función y se avisa por push a la otra parte (el comercio o
// quien pidió). La base decide a quién y no repite el aviso de un mismo
// estado (avisar_pedido()). Nunca se manda el contacto de nadie.
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { type AvisoPedido, textoPedido } from './texto.ts';

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

  let pedidoId: string | null = null;
  try {
    const cuerpo = await req.json();
    pedidoId = typeof cuerpo.order_id === 'string' && /^[0-9a-f-]{36}$/i.test(cuerpo.order_id)
      ? cuerpo.order_id
      : null;
  } catch {
    // Cuerpo inválido: se responde abajo.
  }
  if (!pedidoId) return responder(400, { error: 'datos_incompletos' });

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  const { data: usuario } = await admin.auth.getUser(sesion);
  const actor = usuario.user?.id;
  if (!actor) return responder(401, { error: 'sesion_invalida' });

  const { data, error } = await admin.rpc('avisar_pedido', { p_pedido: pedidoId, p_actor: actor });
  if (error) {
    console.error('No se pudo ver a quién avisar del pedido', pedidoId, error.message);
    return responder(500, { error: 'error' });
  }
  const aviso = (data ?? [])[0] as (AvisoPedido & { tokens: string[] }) | undefined;
  const texto = aviso ? textoPedido(aviso) : null;
  if (!aviso || !texto || aviso.tokens.length === 0) return responder(200, { ok: true, avisados: 0 });

  const enviados = await avisarDispositivos(admin, aviso.tokens, texto);
  await admin.from('events').insert({
    name: 'order_push',
    anon_id: crypto.randomUUID(),
    target_id: pedidoId,
    props: { destino: aviso.destino, estado: aviso.estado, dispositivos: enviados },
  });
  return responder(200, { ok: true, avisados: enviados });
});
