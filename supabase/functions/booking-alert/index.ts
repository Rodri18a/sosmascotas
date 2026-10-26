// Etapa 3.1 (D104): avisos de los turnos.
//  · La app la llama después de reservar o de cambiar el estado de un turno
//    (con la sesión): la base decide a quién avisar y no repite
//    (avisar_turno()). Nunca se manda el contacto de nadie.
//  · pg_cron la llama a las 18:00 con la clave compartida (CRON_SECRET) para
//    recordar los turnos confirmados de mañana (turnos_para_recordar()).
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { type AvisoTurno, textoRecordatorio, textoTurno } from './texto.ts';

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

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // Recordatorios del día anterior (pg_cron).
  const claveCron = Deno.env.get('CRON_SECRET');
  const cron = req.headers.get('x-cron-secret');
  if (cron !== null) {
    if (!claveCron || cron !== claveCron) return responder(401, { error: 'no_autorizado' });
    const { data, error } = await admin.rpc('turnos_para_recordar');
    if (error) {
      console.error('No se pudieron ver los turnos de mañana', error.message);
      return responder(500, { error: 'error' });
    }
    let avisados = 0;
    for (const r of (data ?? []) as { negocio: string; inicio: string; servicio: string; mascota: string; tokens: string[] }[]) {
      if (await avisarDispositivos(admin, r.tokens, textoRecordatorio(r)) > 0) avisados++;
    }
    await admin.from('events').insert({
      name: 'booking_reminder',
      anon_id: crypto.randomUUID(),
      props: { turnos: (data ?? []).length, avisados },
    });
    return responder(200, { ok: true, turnos: (data ?? []).length, avisados });
  }

  // Un cambio de estado (la app, con sesión).
  const sesion = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!sesion) return responder(401, { error: 'sin_sesion' });
  let turnoId: string | null = null;
  try {
    const cuerpo = await req.json();
    turnoId = typeof cuerpo.booking_id === 'string' && /^[0-9a-f-]{36}$/i.test(cuerpo.booking_id)
      ? cuerpo.booking_id
      : null;
  } catch {
    // Cuerpo inválido: se responde abajo.
  }
  if (!turnoId) return responder(400, { error: 'datos_incompletos' });

  const { data: usuario } = await admin.auth.getUser(sesion);
  const actor = usuario.user?.id;
  if (!actor) return responder(401, { error: 'sesion_invalida' });

  const { data, error } = await admin.rpc('avisar_turno', { p_turno: turnoId, p_actor: actor });
  if (error) {
    console.error('No se pudo ver a quién avisar del turno', turnoId, error.message);
    return responder(500, { error: 'error' });
  }
  const aviso = (data ?? [])[0] as (AvisoTurno & { tokens: string[] }) | undefined;
  const texto = aviso ? textoTurno(aviso) : null;
  if (!aviso || !texto || aviso.tokens.length === 0) return responder(200, { ok: true, avisados: 0 });

  const enviados = await avisarDispositivos(admin, aviso.tokens, texto);
  await admin.from('events').insert({
    name: 'booking_push',
    anon_id: crypto.randomUUID(),
    target_id: turnoId,
    props: { destino: aviso.destino, estado: aviso.estado, dispositivos: enviados },
  });
  return responder(200, { ok: true, avisados: enviados });
});
