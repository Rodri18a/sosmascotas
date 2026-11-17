# Generador de videos (video 1 · «Huellamy en 30 segundos»)

Arma el video del guion 1 de `docs/25-guiones-videos.md`: animaciones dibujadas en código con la paleta y la letra de la marca, subtítulos, voz de Windows y música generada (sin derechos de autor).

Desde esta carpeta, en Git Bash:

```sh
npm install                                   # @napi-rs/canvas, ffmpeg-static, qrcode
powershell -NoProfile -ExecutionPolicy Bypass -File voz.ps1   # voz/l0.wav … l5.wav (voz Helena, es-ES)
node musica.js                                # musica.wav
node render.js 10                             # (opcional) foto del segundo 10 para revisar
node render.js                                # video_mudo.mp4
```

Después se mezcla con ffmpeg (`node_modules/ffmpeg-static/ffmpeg.exe`): la voz de cada línea va con `adelay` al inicio de su escena + 250 ms (0, 4,2, 13,6, 18,7, 24,4 y 29,6 s) y la música al 22 %. Los videos terminados están en la carpeta de arriba.

`voz.ps1` tiene que quedar en UTF-8 **con BOM**, si no Windows PowerShell lee mal las tildes.
