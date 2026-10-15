// Prueba el envío sin red: clave RSA generada al vuelo y fetch simulado.
// Correr con: npx deno test --allow-env supabase/functions/_shared/fcm_test.ts
import { assert, assertEquals } from 'jsr:@std/assert@1.0.13';
import { cuentaFcm, enviarPush } from './fcm.ts';

Deno.test('firma el JWT, manda una push por token y detecta los tokens vencidos', async () => {
  const par = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true,
    ['sign', 'verify'],
  );
  const pkcs8 = new Uint8Array(await crypto.subtle.exportKey('pkcs8', par.privateKey));
  const pem = `-----BEGIN PRIVATE KEY-----\n${btoa(String.fromCharCode(...pkcs8))}\n-----END PRIVATE KEY-----\n`;
  Deno.env.set('FIREBASE_SERVICE_ACCOUNT', JSON.stringify({
    project_id: 'sos-prueba',
    client_email: 'push@sos-prueba.iam.gserviceaccount.com',
    private_key: pem,
  }));
  assert(cuentaFcm());

  const mensajes: Record<string, unknown>[] = [];
  const original = globalThis.fetch;
  globalThis.fetch = (async (url: string | URL, init?: RequestInit) => {
    const u = String(url);
    if (u === 'https://oauth2.googleapis.com/token') {
      // El JWT viene firmado con la clave de la cuenta de servicio.
      const jwt = new URLSearchParams(String(init?.body)).get('assertion')!;
      const [h, d, f] = jwt.split('.');
      const b64 = (s: string) => Uint8Array.from(atob(s.replace(/-/g, '+').replace(/_/g, '/')), (c) => c.charCodeAt(0));
      const valido = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', par.publicKey, b64(f), new TextEncoder().encode(`${h}.${d}`));
      assert(valido, 'la firma del JWT no es válida');
      assertEquals(JSON.parse(new TextDecoder().decode(b64(d))).iss, 'push@sos-prueba.iam.gserviceaccount.com');
      return new Response(JSON.stringify({ access_token: 'acceso-prueba' }));
    }
    assertEquals(u, 'https://fcm.googleapis.com/v1/projects/sos-prueba/messages:send');
    assertEquals((init?.headers as Record<string, string>).Authorization, 'Bearer acceso-prueba');
    const { message } = JSON.parse(String(init?.body));
    mensajes.push(message);
    return message.token === 'vencido'
      ? new Response('{"error":{"status":"NOT_FOUND","details":[{"errorCode":"UNREGISTERED"}]}}', { status: 404 })
      : new Response('{}');
  }) as typeof fetch;

  try {
    const r = await enviarPush(['bueno-1', 'vencido', 'bueno-2'], {
      titulo: 'Título',
      cuerpo: 'Cuerpo',
      ruta: '/sos/123',
    });
    assertEquals(r, { enviados: 2, tokensInvalidos: ['vencido'] });
    assertEquals(mensajes.length, 3);
    assertEquals(mensajes[0].notification, { title: 'Título', body: 'Cuerpo' });
    assertEquals(mensajes[0].data, { ruta: '/sos/123' });
  } finally {
    globalThis.fetch = original;
  }
});
