// Paso 0.2.6: "Borrar mi cuenta" (Ley 18.331, derecho de supresión).
// Borra SOLO la cuenta de quien llama (identificada por su sesión): primero sus
// fotos y después la cuenta; en cascada se borran su perfil, sus contactos
// privados y sus mascotas. Los eventos de métricas quedan sin usuario (anónimos).
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

// Buckets donde cada usuario tiene su carpeta <user_id>/.
const BUCKETS_CON_CARPETA_DE_USUARIO = ['pet-photos', 'sos-photos'];

async function borrarArchivos(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<string | null> {
  for (const bucket of BUCKETS_CON_CARPETA_DE_USUARIO) {
    for (;;) {
      const { data: archivos, error } = await admin.storage
        .from(bucket)
        .list(userId, { limit: 100 });
      if (error) {
        // El bucket puede no existir todavía (sos-photos llega en 0.5.1).
        if (/not found/i.test(error.message)) break;
        return error.message;
      }
      if (!archivos || archivos.length === 0) break;
      const { error: errorBorrado } = await admin.storage
        .from(bucket)
        .remove(archivos.map((a) => `${userId}/${a.name}`));
      if (errorBorrado) return errorBorrado.message;
    }
  }
  return null;
}

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

  // Primero las fotos (los archivos no se borran en cascada con la base).
  const errorFotos = await borrarArchivos(admin, data.user.id);
  if (errorFotos) {
    console.error('No se pudieron borrar las fotos', data.user.id, errorFotos);
    return responder(500, { error: 'no_se_pudo_borrar' });
  }

  const { error: errorBorrado } = await admin.auth.admin.deleteUser(data.user.id);
  if (errorBorrado) {
    console.error('No se pudo borrar la cuenta', data.user.id, errorBorrado.message);
    return responder(500, { error: 'no_se_pudo_borrar' });
  }
  return responder(200, { borrada: true });
});
