// Etapa 2.3 (D101): el día 1 pg_cron (pedir_reporte_mensual()) llama a esta
// función con la clave compartida, y se le manda a cada comercio el resumen
// del mes anterior por push. La base arma cada reporte una sola vez y solo
// para los comercios con la marca `estadisticas` (reporte_mensual_pendiente()).
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';
import { avisarDispositivos } from '../_shared/fcm.ts';
import { mesAnterior, type ReporteMensual, textoReporte } from './texto.ts';

const responder = (estado: number, cuerpo: Record<string, unknown>) =>
  new Response(JSON.stringify(cuerpo), { status: estado, headers: { 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method !== 'POST') return responder(405, { error: 'metodo_no_permitido' });
  const clave = Deno.env.get('MONTHLY_REPORT_SECRET');
  if (!clave || req.headers.get('x-cron-secret') !== clave) return responder(401, { error: 'no_autorizado' });

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  const mes = mesAnterior(new Date());
  const { data, error } = await admin.rpc('reporte_mensual_pendiente', { p_mes: mes });
  if (error) {
    console.error('No se pudieron armar los reportes de', mes, error.message);
    return responder(500, { error: 'error' });
  }

  let avisados = 0;
  for (const r of (data ?? []) as (ReporteMensual & { tokens: string[] })[]) {
    const enviados = await avisarDispositivos(admin, r.tokens, textoReporte(r));
    if (enviados > 0) avisados++;
    await admin.from('monthly_reports').update({ devices: enviados })
      .eq('business_id', r.business_id).eq('month', mes);
  }
  await admin.from('events').insert({
    name: 'monthly_report',
    anon_id: crypto.randomUUID(),
    props: { mes, reportes: (data ?? []).length, avisados },
  });
  return responder(200, { ok: true, mes, reportes: (data ?? []).length, avisados });
});
