// Video 1 · «Huellamy en 30 segundos» (docs/25-guiones-videos.md). 1080 × 1920, 30 fps.
const { createCanvas, loadImage, GlobalFonts } = require('@napi-rs/canvas');
const { spawn } = require('child_process');
const QR = require('qrcode');
const ffmpeg = require('ffmpeg-static');
const path = require('path');

const REPO = path.resolve(__dirname, '../../../../..');
const W = 1080, H = 1920, FPS = 30;
const SOLO = process.argv[2] ? Number(process.argv[2]) : null; // segundo para sacar una foto de prueba

const F = REPO + '/app/assets/fuentes/';
GlobalFonts.registerFromPath(F + 'Nunito-Black.ttf', 'NunitoBlack');
GlobalFonts.registerFromPath(F + 'Nunito-ExtraBold.ttf', 'NunitoXB');
GlobalFonts.registerFromPath(F + 'NunitoSans-Bold.ttf', 'SansB');
GlobalFonts.registerFromPath(F + 'NunitoSans-SemiBold.ttf', 'SansSB');

const C = {
  fondo: '#F0F8FE', fondo2: '#D9ECFB', texto: '#13294B', suave: '#4A5B72', primario: '#0B4F94',
  brillante: '#1798DF', acento: '#E8923A', exito: '#17705F', rosa: '#E86A9A', rojo: '#D64545',
};

// Escenas: inicio, duración, título, subtítulos [texto, desde (s, relativo)]
const ESCENAS = [
  { d: 4.2, titulo: ['Todo para tu mascota,', 'en un mapa'], subs: [['¿Tenés perro o gato en Pando? Esto es para vos.', 0]] },
  { d: 9.4, titulo: ['Veterinarias, pet shops', 'y mucho más'], subs: [['Huellamy junta en un mapa todo lo que tu mascota necesita:', 0], ['veterinarias, pet shops, paseadores, guarderías y lugares que aceptan mascotas.', 3.9]] },
  { d: 5.1, titulo: ['¿Se perdió?', 'Avisás a tus vecinos'], subs: [['Si se pierde, publicás el aviso y les llega a los vecinos de la zona.', 0]] },
  { d: 5.7, titulo: ['Chapita QR', 'y su salud al día'], subs: [['Tiene su chapita QR y sus vacunas y remedios al día, con recordatorios.', 0]] },
  { d: 5.2, titulo: ['Su seguridad', 'y su salud'], subs: [['Y lo que hace a su seguridad y su salud es gratis. Siempre.', 0]] },
  { d: 4.0, titulo: [], subs: [['Entrá a huellamy.com', 0]] },
];
let acum = 0;
for (const e of ESCENAS) { e.t0 = acum; acum += e.d; }
const TOTAL = acum;
module.exports = { ESCENAS };

// ---------- utilidades ----------
const clamp = (v, a = 0, b = 1) => Math.max(a, Math.min(b, v));
const prog = (t, a, d) => clamp((t - a) / d);
const easeOut = (x) => 1 - Math.pow(1 - x, 3);
const easeInOut = (x) => (x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2);
const backOut = (x) => { const c1 = 1.70158, c3 = c1 + 1; return 1 + c3 * Math.pow(x - 1, 3) + c1 * Math.pow(x - 1, 2); };

function rrect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y); ctx.arcTo(x + w, y, x + w, y + h, r); ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r); ctx.arcTo(x, y, x + w, y, r); ctx.closePath();
}
function sombra(ctx, blur = 30, y = 10, a = 0.16) { ctx.shadowColor = `rgba(19,41,75,${a})`; ctx.shadowBlur = blur; ctx.shadowOffsetY = y; }
function sinSombra(ctx) { ctx.shadowColor = 'transparent'; ctx.shadowBlur = 0; ctx.shadowOffsetY = 0; }

function huella(ctx, x, y, s, color) {
  ctx.fillStyle = color;
  ctx.beginPath(); ctx.ellipse(x, y + s * 0.25, s * 0.42, s * 0.34, 0, 0, Math.PI * 2); ctx.fill();
  [[-0.42, -0.22, -0.3], [-0.15, -0.5, -0.1], [0.15, -0.5, 0.1], [0.42, -0.22, 0.3]].forEach(([dx, dy, r]) => {
    ctx.beginPath(); ctx.ellipse(x + dx * s, y + dy * s, s * 0.15, s * 0.2, r, 0, Math.PI * 2); ctx.fill();
  });
}
function corazon(ctx, x, y, s, color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.moveTo(x, y + s * 0.35);
  ctx.bezierCurveTo(x - s * 0.9, y - s * 0.25, x - s * 0.45, y - s * 0.95, x, y - s * 0.45);
  ctx.bezierCurveTo(x + s * 0.45, y - s * 0.95, x + s * 0.9, y - s * 0.25, x, y + s * 0.35);
  ctx.fill();
}
function textoCentrado(ctx, txt, x, y, font, color) { ctx.font = font; ctx.fillStyle = color; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(txt, x, y); }
function partir(ctx, txt, ancho) {
  const pal = txt.split(' '); const lineas = []; let l = '';
  for (const p of pal) { const prueba = l ? l + ' ' + p : p; if (ctx.measureText(prueba).width > ancho && l) { lineas.push(l); l = p; } else l = prueba; }
  if (l) lineas.push(l); return lineas;
}

// ---------- fondo ----------
const HUELLAS = Array.from({ length: 14 }, (_, i) => ({ x: (i * 397) % W, y: (i * 619) % H, s: 40 + (i * 37) % 50, r: (i * 1.3) % 6.28, v: 12 + (i % 5) * 6 }));
function fondo(ctx, t) {
  const g = ctx.createLinearGradient(0, 0, 0, H); g.addColorStop(0, C.fondo); g.addColorStop(1, C.fondo2);
  ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
  for (const h of HUELLAS) {
    const y = ((h.y - t * h.v) % (H + 200) + H + 200) % (H + 200) - 100;
    ctx.save(); ctx.translate(h.x, y); ctx.rotate(h.r + Math.sin(t * 0.5 + h.x) * 0.1); ctx.globalAlpha = 0.18;
    huella(ctx, 0, 0, h.s, C.brillante); ctx.restore();
  }
}

// ---------- título y subtítulos ----------
function titulo(ctx, e, lt) {
  e.titulo.forEach((l, i) => {
    const p = easeOut(prog(lt, 0.1 + i * 0.15, 0.5));
    ctx.save(); ctx.globalAlpha = p; ctx.translate(0, (1 - p) * 40);
    textoCentrado(ctx, l, W / 2, 230 + i * 100, '86px NunitoBlack', i === 0 ? C.primario : C.brillante);
    ctx.restore();
  });
}
function subtitulos(ctx, e, lt) {
  let actual = null;
  for (const s of e.subs) if (lt >= s[1]) actual = s;
  if (!actual) return;
  const p = easeOut(prog(lt, actual[1], 0.25));
  ctx.font = '50px SansB';
  const lineas = partir(ctx, actual[0], 860);
  const alto = lineas.length * 66 + 50; const y0 = 1500 - alto / 2;
  ctx.save(); ctx.globalAlpha = p;
  sombra(ctx, 24, 6, 0.18); ctx.fillStyle = 'rgba(255,255,255,0.96)'; rrect(ctx, 70, y0, W - 140, alto, 36); ctx.fill(); sinSombra(ctx);
  lineas.forEach((l, i) => textoCentrado(ctx, l, W / 2, y0 + 25 + 33 + i * 66, '50px SansB', C.texto));
  ctx.restore();
}

// ---------- escenas ----------
let IMG = {};
async function cargar() {
  const logo = await loadImage(REPO + '/docs/guias/huellamy/logo-huellamy.png');
  // Ami y Mishi recortados del logo (sin la palabra), para la apertura
  const amiMishi = createCanvas(1180, 640); amiMishi.getContext('2d').drawImage(logo, 40, 60, 1180, 640, 0, 0, 1180, 640);
  const ami = createCanvas(240, 240); ami.getContext('2d').drawImage(logo, 250, 120, 420, 420, 0, 0, 240, 240);
  const qr = QR.create('https://huellamy.com', { errorCorrectionLevel: 'M' });
  IMG = { logo, amiMishi, ami, qr, mishi: await loadImage(REPO + '/app/assets/ilustraciones/mishi_festejando.png'),
    tienda: await loadImage(REPO + '/app/assets/ilustraciones/tienda.png') };
}

function escena0(ctx, lt) { // apertura: Ami saluda, Mishi asoma
  titulo(ctx, ESCENAS[0], lt);
  const p = backOut(prog(lt, 0.0, 0.7));
  const s = 0.6 + 0.4 * p;
  ctx.save(); ctx.translate(W / 2, 880); ctx.scale(s, s); ctx.rotate(Math.sin(lt * 3) * 0.015);
  ctx.globalAlpha = clamp(p);
  sombra(ctx, 40, 14); ctx.fillStyle = '#fff'; rrect(ctx, -470, -310, 940, 620, 70); ctx.fill(); sinSombra(ctx);
  ctx.save(); rrect(ctx, -470, -310, 940, 620, 70); ctx.clip();
  ctx.drawImage(IMG.amiMishi, -455, -250, 910, 494); ctx.restore();
  ctx.restore();
}

const PINES = [
  { x: 260, y: 610, c: C.rojo, l: 'Veterinaria', ic: 'cruz', lado: 1 },
  { x: 800, y: 560, c: C.acento, l: 'Pet shop', ic: 'bolsa', lado: -1 },
  { x: 250, y: 930, c: C.exito, l: 'Paseador', ic: 'huella', lado: 1 },
  { x: 690, y: 1010, c: C.brillante, l: 'Guardería', ic: 'casa', lado: 1 },
  { x: 230, y: 1220, c: C.rosa, l: 'Acepta mascotas', ic: 'corazon', lado: 1 },
];
function icono(ctx, ic, x, y, s, color) {
  ctx.fillStyle = color; ctx.strokeStyle = color;
  if (ic === 'cruz') { ctx.fillRect(x - s * 0.12, y - s * 0.4, s * 0.24, s * 0.8); ctx.fillRect(x - s * 0.4, y - s * 0.12, s * 0.8, s * 0.24); }
  if (ic === 'bolsa') { rrect(ctx, x - s * 0.35, y - s * 0.2, s * 0.7, s * 0.6, 6); ctx.fill(); ctx.lineWidth = 6; ctx.beginPath(); ctx.arc(x, y - s * 0.2, s * 0.18, Math.PI, 0); ctx.stroke(); }
  if (ic === 'huella') huella(ctx, x, y, s * 0.75, color);
  if (ic === 'casa') { ctx.beginPath(); ctx.moveTo(x - s * 0.42, y - s * 0.02); ctx.lineTo(x, y - s * 0.42); ctx.lineTo(x + s * 0.42, y - s * 0.02); ctx.fill(); ctx.fillRect(x - s * 0.3, y - s * 0.05, s * 0.6, s * 0.42); }
  if (ic === 'corazon') corazon(ctx, x, y + s * 0.05, s * 0.7, color);
}
function pin(ctx, x, y, color, ic, s = 1) {
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  sombra(ctx, 16, 8, 0.25);
  ctx.fillStyle = color; ctx.beginPath(); ctx.arc(0, -70, 46, Math.PI * 0.8, Math.PI * 0.2); ctx.lineTo(0, 0); ctx.closePath(); ctx.fill();
  sinSombra(ctx);
  ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(0, -72, 32, 0, Math.PI * 2); ctx.fill();
  icono(ctx, ic, 0, -72, 44, color);
  ctx.restore();
}
function mapa(ctx, x, y, w, h, t) {
  ctx.save(); rrect(ctx, x, y, w, h, 48); ctx.clip();
  ctx.fillStyle = '#EEF3EA'; ctx.fillRect(x, y, w, h);
  ctx.fillStyle = '#D5EBCB'; rrect(ctx, x + 380, y + 280, 220, 170, 30); ctx.fill(); // plaza
  ctx.fillStyle = '#CFE6F7'; ctx.beginPath(); ctx.moveTo(x, y + h - 120); ctx.bezierCurveTo(x + 300, y + h - 220, x + 600, y + h - 20, x + w, y + h - 140); ctx.lineTo(x + w, y + h); ctx.lineTo(x, y + h); ctx.fill(); // arroyo
  ctx.strokeStyle = '#fff'; ctx.lineCap = 'round';
  [[0.18, 26], [0.45, 34], [0.72, 26]].forEach(([f, lw]) => { ctx.lineWidth = lw; ctx.beginPath(); ctx.moveTo(x + w * f, y); ctx.lineTo(x + w * f + 60, y + h); ctx.stroke(); });
  [[0.22, 26], [0.5, 40], [0.78, 26]].forEach(([f, lw]) => { ctx.lineWidth = lw; ctx.beginPath(); ctx.moveTo(x, y + h * f); ctx.lineTo(x + w, y + h * f - 50); ctx.stroke(); });
  ctx.restore();
  ctx.save(); ctx.strokeStyle = '#fff'; ctx.lineWidth = 10; rrect(ctx, x, y, w, h, 48); ctx.stroke(); ctx.restore();
}
function escena1(ctx, lt) { // el mapa con pines
  titulo(ctx, ESCENAS[1], lt);
  const pm = easeOut(prog(lt, 0, 0.5));
  ctx.save(); ctx.globalAlpha = pm; ctx.translate(0, (1 - pm) * 60);
  sombra(ctx, 40, 14); ctx.fillStyle = '#fff'; rrect(ctx, 80, 400, 920, 950, 52); ctx.fill(); sinSombra(ctx);
  mapa(ctx, 95, 415, 890, 920, lt);
  // vos
  const pul = (lt * 0.8) % 1;
  ctx.fillStyle = `rgba(23,152,223,${0.35 * (1 - pul)})`; ctx.beginPath(); ctx.arc(585, 770, 20 + pul * 70, 0, Math.PI * 2); ctx.fill();
  ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(585, 770, 22, 0, Math.PI * 2); ctx.fill();
  ctx.fillStyle = C.brillante; ctx.beginPath(); ctx.arc(585, 770, 15, 0, Math.PI * 2); ctx.fill();
  ctx.restore();
  PINES.forEach((p, i) => {
    const a = 0.6 + i * 0.75; // cada pin cae en su momento (sigue la voz)
    const q = prog(lt, a, 0.5);
    if (q <= 0) return;
    const caida = (1 - easeOut(q)) * -140;
    pin(ctx, p.x, p.y + caida, p.c, p.ic, 0.5 + 0.5 * backOut(q));
    const ql = easeOut(prog(lt, a + 0.25, 0.4));
    ctx.save(); ctx.globalAlpha = ql; ctx.font = '38px SansB';
    const tw = ctx.measureText(p.l).width + 44;
    const lx = p.lado > 0 ? p.x + 40 : p.x - 40 - tw;
    sombra(ctx, 14, 5, 0.2); ctx.fillStyle = '#fff'; rrect(ctx, lx, p.y - 100, tw, 62, 31); ctx.fill(); sinSombra(ctx);
    ctx.fillStyle = C.texto; ctx.textAlign = 'left'; ctx.textBaseline = 'middle'; ctx.fillText(p.l, lx + 22, p.y - 68);
    ctx.restore();
  });
  // Ami y Mishi de compras, abajo a la derecha
  const qt = backOut(prog(lt, 5.2, 0.6));
  if (qt > 0) { ctx.save(); ctx.translate(820, 1240); ctx.scale(qt, qt); ctx.drawImage(IMG.tienda, -150, -95, 300, 190); ctx.restore(); }
}

const CASAS = [[190, 640], [890, 610], [150, 1080], [930, 1110], [190, 1310], [890, 1320]];
function casa(ctx, x, y, color) {
  ctx.fillStyle = color; ctx.beginPath(); ctx.moveTo(x - 50, y); ctx.lineTo(x, y - 46); ctx.lineTo(x + 50, y); ctx.fill();
  rrect(ctx, x - 38, y - 4, 76, 60, 8); ctx.fill();
  ctx.fillStyle = '#fff'; rrect(ctx, x - 12, y + 20, 24, 36, 4); ctx.fill();
}
function campana(ctx, x, y, s, color) {
  ctx.fillStyle = color; ctx.beginPath();
  ctx.moveTo(x - s * 0.5, y + s * 0.3); ctx.quadraticCurveTo(x - s * 0.4, y + s * 0.15, x - s * 0.38, y - s * 0.1);
  ctx.arc(x, y - s * 0.1, s * 0.38, Math.PI, 0); ctx.quadraticCurveTo(x + s * 0.4, y + s * 0.15, x + s * 0.5, y + s * 0.3); ctx.closePath(); ctx.fill();
  ctx.beginPath(); ctx.arc(x, y + s * 0.4, s * 0.12, 0, Math.PI * 2); ctx.fill();
}
function escena2(ctx, lt) { // SOS: el aviso llega a los vecinos
  titulo(ctx, ESCENAS[2], lt);
  const cx = W / 2, cy = 900;
  // ondas
  for (let k = 0; k < 3; k++) {
    const q = ((lt - 1.2 - k * 0.6) % 1.8) / 1.8;
    if (lt < 1.2 + k * 0.6) continue;
    ctx.strokeStyle = `rgba(232,146,58,${0.5 * (1 - q)})`; ctx.lineWidth = 10;
    ctx.beginPath(); ctx.arc(cx, cy, 260 + q * 420, 0, Math.PI * 2); ctx.stroke();
  }
  CASAS.forEach(([x, y], i) => {
    const llego = lt > 1.6 + i * 0.25;
    casa(ctx, x, y, llego ? C.primario : '#B7C7D8');
    if (llego) {
      const q = backOut(prog(lt, 1.6 + i * 0.25, 0.4));
      ctx.save(); ctx.translate(x + 38, y - 50); ctx.scale(q, q);
      ctx.fillStyle = C.acento; ctx.beginPath(); ctx.arc(0, 0, 26, 0, Math.PI * 2); ctx.fill();
      campana(ctx, 0, -2, 30, '#fff'); ctx.restore();
    }
  });
  // teléfono
  const pt = backOut(prog(lt, 0, 0.6));
  ctx.save(); ctx.translate(cx, cy); ctx.scale(0.7 + 0.3 * pt, 0.7 + 0.3 * pt); ctx.globalAlpha = clamp(pt);
  sombra(ctx, 40, 16, 0.3); ctx.fillStyle = C.texto; rrect(ctx, -210, -380, 420, 760, 60); ctx.fill(); sinSombra(ctx);
  ctx.fillStyle = '#F3F8FC'; rrect(ctx, -192, -362, 384, 724, 46); ctx.fill();
  ctx.fillStyle = C.texto; rrect(ctx, -60, -350, 120, 26, 13); ctx.fill();
  // tarjeta del aviso
  const pa = easeOut(prog(lt, 0.5, 0.5));
  ctx.save(); ctx.translate(0, (1 - pa) * -120); ctx.globalAlpha = clamp(pt) * pa;
  sombra(ctx, 18, 6, 0.2); ctx.fillStyle = '#fff'; rrect(ctx, -170, -270, 340, 470, 30); ctx.fill(); sinSombra(ctx);
  ctx.fillStyle = C.acento; rrect(ctx, -170, -270, 340, 76, 30); ctx.fill(); ctx.fillRect(-170, -224, 340, 30);
  textoCentrado(ctx, 'SE PERDIÓ', 0, -230, '38px NunitoBlack', C.texto);
  ctx.save(); ctx.beginPath(); ctx.arc(0, -70, 100, 0, Math.PI * 2); ctx.clip(); ctx.fillStyle = '#FFF4E8'; ctx.fill(); ctx.drawImage(IMG.ami, -110, -180, 220, 220); ctx.restore();
  ctx.strokeStyle = C.acento; ctx.lineWidth = 6; ctx.beginPath(); ctx.arc(0, -70, 100, 0, Math.PI * 2); ctx.stroke();
  textoCentrado(ctx, 'Toby', 0, 75, '44px NunitoBlack', C.texto);
  textoCentrado(ctx, 'Collar azul · cerca tuyo', 0, 125, '28px SansSB', C.suave);
  ctx.fillStyle = C.primario; rrect(ctx, -130, 148, 260, 40, 20); ctx.fill();
  textoCentrado(ctx, 'Lo vi', 0, 169, '26px SansB', '#fff');
  ctx.restore();
  ctx.restore();
}

function hueso(ctx, w, h) {
  const r = h * 0.3, bx = w / 2 - r, by = h / 2 - r;
  ctx.beginPath();
  ctx.rect(-bx, -h * 0.36, bx * 2, h * 0.72);
  for (const [sx, sy] of [[-1, -1], [1, -1], [-1, 1], [1, 1]]) { ctx.moveTo(sx * bx + r, sy * by); ctx.arc(sx * bx, sy * by, r, 0, Math.PI * 2); }
}
function escena3(ctx, lt) { // chapita QR + recordatorio
  titulo(ctx, ESCENAS[3], lt);
  // chapita que se balancea
  const pc = backOut(prog(lt, 0, 0.6));
  ctx.save(); ctx.translate(W / 2, 470); ctx.rotate(Math.sin(lt * 2.2) * 0.06); ctx.scale(pc, pc);
  ctx.strokeStyle = '#9AA8B6'; ctx.lineWidth = 12; ctx.beginPath(); ctx.arc(0, 0, 36, 0, Math.PI * 2); ctx.stroke();
  ctx.translate(0, 250);
  sombra(ctx, 30, 12, 0.25);
  const g = ctx.createLinearGradient(-330, 0, 330, 0); g.addColorStop(0, C.primario); g.addColorStop(1, C.brillante);
  ctx.fillStyle = g; hueso(ctx, 780, 440); ctx.fill('nonzero'); sinSombra(ctx);
  ctx.fillStyle = '#fff'; rrect(ctx, -120, -150, 240, 240, 20); ctx.fill();
  const m = IMG.qr.modules; const n = m.size; const cel = 204 / n;
  ctx.fillStyle = C.texto;
  for (let r = 0; r < n; r++) for (let c = 0; c < n; c++) if (m.get(r, c)) ctx.fillRect(-102 + c * cel, -132 + r * cel, cel + 0.5, cel + 0.5);
  textoCentrado(ctx, 'huellamy.com', 0, 126, '30px NunitoXB', '#fff');
  // escaneo
  const sc = (lt * 0.9) % 1;
  if (lt > 0.8) { ctx.fillStyle = 'rgba(232,146,58,0.75)'; ctx.fillRect(-130, -145 + sc * 230, 260, 7); }
  ctx.restore();
  // recordatorio
  const pr = easeOut(prog(lt, 1.6, 0.5));
  ctx.save(); ctx.globalAlpha = pr; ctx.translate(0, (1 - pr) * 80);
  sombra(ctx, 30, 10, 0.18); ctx.fillStyle = '#fff'; rrect(ctx, 110, 1010, 860, 300, 40); ctx.fill(); sinSombra(ctx);
  ctx.fillStyle = '#E4F1FB'; ctx.beginPath(); ctx.arc(210, 1110, 56, 0, Math.PI * 2); ctx.fill();
  campana(ctx, 210, 1105, 64, C.primario);
  ctx.textAlign = 'left'; ctx.textBaseline = 'middle';
  ctx.font = '44px NunitoBlack'; ctx.fillStyle = C.texto; ctx.fillText('Antiparasitario de Ami', 290, 1085);
  ctx.font = '34px SansSB'; ctx.fillStyle = C.suave; ctx.fillText('Hoy · 20:00', 290, 1140);
  const hecho = lt > 3.6;
  const pb = backOut(prog(lt, 3.6, 0.4));
  ctx.fillStyle = hecho ? C.exito : C.primario; rrect(ctx, 290, 1190, 420, 84, 42); ctx.fill();
  textoCentrado(ctx, hecho ? '¡Listo!' : 'Ya se la di', 500, 1233, '38px SansB', '#fff');
  if (lt > 3.3 && lt < 4.1) { const q = prog(lt, 3.3, 0.8); ctx.fillStyle = `rgba(255,255,255,${0.6 * (1 - q)})`; ctx.beginPath(); ctx.arc(500, 1232, 30 + q * 120, 0, Math.PI * 2); ctx.fill(); }
  if (hecho) { ctx.save(); ctx.translate(860, 1130); ctx.scale(pb, pb); corazon(ctx, 0, 0, 70, C.rosa); ctx.restore(); }
  ctx.restore();
}

const CONFETI = Array.from({ length: 60 }, (_, i) => ({ x: (i * 173) % W, v: 300 + (i * 53) % 300, r: (i * 0.7) % 6.28, c: [C.acento, C.brillante, C.rosa, '#F5C842', C.exito][i % 5], d: (i * 0.037) % 1.2 }));
function escena4(ctx, lt) { // gratis, siempre
  titulo(ctx, ESCENAS[4], lt);
  const pul = 1 + 0.04 * Math.sin(lt * 6);
  const ph = backOut(prog(lt, 0.1, 0.6));
  ctx.save(); ctx.translate(W / 2, 780); ctx.scale(ph * 0.92 * pul, ph * 0.92 * pul);
  sombra(ctx, 40, 14, 0.2); corazon(ctx, 0, 60, 640, C.brillante); sinSombra(ctx);
  ctx.save(); ctx.beginPath(); ctx.arc(0, -10, 190, 0, Math.PI * 2); ctx.clip(); ctx.fillStyle = '#FBD3E0'; ctx.fill(); ctx.drawImage(IMG.mishi, -200, -210, 400, 400); ctx.restore();
  ctx.strokeStyle = '#fff'; ctx.lineWidth = 12; ctx.beginPath(); ctx.arc(0, -10, 190, 0, Math.PI * 2); ctx.stroke();
  ctx.restore();
  const pg = backOut(prog(lt, 1.9, 0.5));
  if (pg > 0) {
    ctx.save(); ctx.translate(W / 2, 1150); ctx.rotate(-0.05); ctx.scale(pg, pg);
    sombra(ctx, 24, 10, 0.25); ctx.fillStyle = C.acento; rrect(ctx, -300, -80, 600, 160, 80); ctx.fill(); sinSombra(ctx);
    textoCentrado(ctx, 'GRATIS', 0, 4, '110px NunitoBlack', C.texto);
    ctx.restore();
  }
  const ps = easeOut(prog(lt, 3.2, 0.5));
  ctx.save(); ctx.globalAlpha = ps; textoCentrado(ctx, 'Siempre.', W / 2, 1310, '64px NunitoBlack', C.primario); ctx.restore();
  if (lt > 1.9) CONFETI.forEach((k) => {
    const tt = lt - 1.9 - k.d; if (tt < 0) return;
    const y = -40 + tt * k.v; if (y > H) return;
    ctx.save(); ctx.translate(k.x + Math.sin(tt * 3 + k.x) * 40, y); ctx.rotate(k.r + tt * 4); ctx.fillStyle = k.c; ctx.fillRect(-10, -6, 20, 12); ctx.restore();
  });
}

function escena5(ctx, lt) { // cierre fijo
  const pl = backOut(prog(lt, 0, 0.7));
  ctx.save(); ctx.translate(W / 2, 760); ctx.scale(pl, pl);
  sombra(ctx, 40, 14, 0.15); ctx.fillStyle = '#fff'; rrect(ctx, -460, -460, 920, 920, 90); ctx.fill(); sinSombra(ctx);
  ctx.drawImage(IMG.logo, -440, -440, 880, 880);
  ctx.restore();
  const pu = easeOut(prog(lt, 0.5, 0.5));
  ctx.save(); ctx.globalAlpha = pu; ctx.translate(0, (1 - pu) * 40);
  sombra(ctx, 24, 10, 0.25); ctx.fillStyle = C.primario; rrect(ctx, 190, 1290, 700, 120, 60); ctx.fill(); sinSombra(ctx);
  textoCentrado(ctx, 'huellamy.com', W / 2, 1352, '68px NunitoBlack', '#fff');
  ctx.restore();
  const pp = easeOut(prog(lt, 0.9, 0.5));
  ctx.save(); ctx.globalAlpha = pp;
  textoCentrado(ctx, 'Hecho en Pando, Uruguay', W / 2 - 30, 1490, '46px NunitoXB', C.texto);
  ctx.font = '46px NunitoXB'; const tw = ctx.measureText('Hecho en Pando, Uruguay').width;
  corazon(ctx, W / 2 - 30 + tw / 2 + 45, 1492, 50, C.brillante);
  ctx.restore();
}

const DIBUJAR = [escena0, escena1, escena2, escena3, escena4, escena5];
const FUNDIDO = 0.3;
function cuadro(ctx, t) {
  fondo(ctx, t);
  let i = ESCENAS.findIndex((e) => t < e.t0 + e.d); if (i < 0) i = ESCENAS.length - 1;
  const e = ESCENAS[i]; const lt = t - e.t0;
  if (i > 0 && lt < FUNDIDO) {
    const prev = ESCENAS[i - 1];
    ctx.save(); ctx.globalAlpha = 1 - lt / FUNDIDO; DIBUJAR[i - 1](ctx, prev.d + lt); ctx.restore();
  }
  ctx.save(); ctx.globalAlpha = i > 0 ? clamp(lt / FUNDIDO) : 1; DIBUJAR[i](ctx, lt); ctx.restore();
  if (i < 5) subtitulos(ctx, e, lt);
  else { ctx.save(); ctx.globalAlpha = clamp(lt / 0.3); ctx.restore(); }
}

async function main() {
  await cargar();
  const cv = createCanvas(W, H); const ctx = cv.getContext('2d');
  if (SOLO !== null) {
    cuadro(ctx, SOLO);
    require('fs').writeFileSync(path.join(__dirname, `foto_${SOLO}.png`), cv.toBuffer('image/png'));
    return;
  }
  const out = path.join(__dirname, 'video_mudo.mp4');
  const ff = spawn(ffmpeg, ['-y', '-f', 'rawvideo', '-pix_fmt', 'rgba', '-s', `${W}x${H}`, '-r', String(FPS), '-i', '-',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p', out], { stdio: ['pipe', 'ignore', 'inherit'] });
  const frames = Math.ceil(TOTAL * FPS);
  for (let f = 0; f < frames; f++) {
    cuadro(ctx, f / FPS);
    const data = Buffer.from(ctx.getImageData(0, 0, W, H).data.buffer);
    if (!ff.stdin.write(data)) await new Promise((r) => ff.stdin.once('drain', r));
    if (f % 150 === 0) process.stderr.write(`cuadro ${f}/${frames}\n`);
  }
  ff.stdin.end();
  await new Promise((r) => ff.on('close', r));
  console.log('listo', out, TOTAL.toFixed(2) + ' s');
}
if (require.main === module) main();
