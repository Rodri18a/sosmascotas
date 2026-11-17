// Música suave generada (sin derechos de autor): arpegio C - G - Am - F.
const fs = require('fs');
const SR = 44100, DUR = 34;
const n = SR * DUR;
const buf = new Float32Array(n);
const hz = (m) => 440 * Math.pow(2, (m - 69) / 12);
const beat = 60 / 96;
const acordes = [[60, 64, 67, 72], [55, 59, 62, 67], [57, 60, 64, 69], [53, 57, 60, 65]];
const bajos = [48, 43, 45, 41];
function nota(t0, midi, vol, dec, armonico) {
  const f = hz(midi);
  const i0 = Math.floor(t0 * SR);
  const len = Math.floor(dec * 5 * SR);
  for (let i = 0; i < len && i0 + i < n; i++) {
    const t = i / SR;
    const env = Math.min(1, t / 0.008) * Math.exp(-t / dec);
    buf[i0 + i] += vol * env * (Math.sin(2 * Math.PI * f * t) + armonico * Math.sin(4 * Math.PI * f * t) + 0.1 * Math.sin(6 * Math.PI * f * t));
  }
}
const patron = [0, 1, 2, 3, 2, 1, 2, 3];
for (let compas = 0; compas * 4 * beat < DUR; compas++) {
  const c = compas % 4;
  const t = compas * 4 * beat;
  nota(t, bajos[c], 0.5, 0.9, 0.2);
  patron.forEach((p, k) => nota(t + k * beat / 2, acordes[c][p], 0.22, 0.35, 0.3));
  if (compas % 2 === 1) nota(t + 3.5 * beat, acordes[c][3] + 12, 0.08, 0.6, 0.1); // brillito
}
let max = 0;
for (const v of buf) max = Math.max(max, Math.abs(v));
const out = Buffer.alloc(44 + n * 2);
out.write('RIFF', 0); out.writeUInt32LE(36 + n * 2, 4); out.write('WAVE', 8);
out.write('fmt ', 12); out.writeUInt32LE(16, 16); out.writeUInt16LE(1, 20); out.writeUInt16LE(1, 22);
out.writeUInt32LE(SR, 24); out.writeUInt32LE(SR * 2, 28); out.writeUInt16LE(2, 32); out.writeUInt16LE(16, 34);
out.write('data', 36); out.writeUInt32LE(n * 2, 40);
for (let i = 0; i < n; i++) {
  const fade = Math.min(1, i / (SR * 0.5), (n - i) / (SR * 2.5));
  out.writeInt16LE(Math.round((buf[i] / max) * 0.8 * fade * 32767), 44 + i * 2);
}
fs.writeFileSync(__dirname + '/musica.wav', out);
console.log('musica.wav lista');
