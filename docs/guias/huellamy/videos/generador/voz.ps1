Add-Type -AssemblyName System.Speech
New-Item -ItemType Directory -Force (Join-Path $PSScriptRoot "voz") | Out-Null
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice('Microsoft Helena Desktop')
$s.Rate = 1
$lineas = @(
 '¿Tenés perro o gato? Esto es para vos.',
 'Huellami junta en un mapa todo lo que tu mascota necesita: veterinarias, pet shops, paseadores, guarderías y lugares que aceptan mascotas.',
 'Si se pierde, publicás el aviso, y les llega a los vecinos de la zona.',
 'Tiene su chapita QR, y sus vacunas y remedios al día, con recordatorios.',
 'Y lo que hace a su seguridad y su salud, es gratis. Siempre.',
 'Entrá a huellami punto com.'
)
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(44100, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
for ($i=0; $i -lt $lineas.Length; $i++) {
  $s.SetOutputToWaveFile("$PSScriptRoot\voz\l$i.wav", $fmt)
  $s.Speak($lineas[$i])
}
$s.SetOutputToNull()
