// Paso 0.2.6: "Borrar mi cuenta" (Ley 18.331, derecho de supresión).
// Borra SOLO la cuenta de quien llama (identificada por su sesión). En cascada se
// borran su perfil, sus contactos privados y (más adelante) sus mascotas; los
// eventos de métricas quedan sin usuario (anónimos).
import { createClient } from 'npm:@supabase/supabase-js@2.117.2';

const CORS = {
  'Access-Control-Allow-Origin': '*', // Sin cookies: la identidad va en el token.
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

  const token = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return responder(401, { error: 'sin_sesion' });

  // Cliente con la clave secreta: solo vive en el servidor, nunca en la app.
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // Valida el token con el servidor de login y obtiene a quién pertenece.
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return responder(401, { error: 'sesion_invalida' });

  const { error: errorBorrado } = await admin.auth.admin.deleteUser(data.user.id);
  if (errorBorrado) {
    console.error('No se pudo borrar la cuenta', data.user.id, errorBorrado.message);
    return responder(500, { error: 'no_se_pudo_borrar' });
  }
  return responder(200, { borrada: true });
});
