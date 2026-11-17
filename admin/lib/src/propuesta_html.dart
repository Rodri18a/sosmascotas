import 'modelos.dart';
import 'textos.dart';

String _e(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _n(int? n) => n == null ? 'menos de 5' : '$n';

/// Propuesta de una página para mostrar en una visita (2.4, D102): se abre en
/// el navegador y se guarda como PDF con «Imprimir». Solo cantidades, nunca
/// datos de personas. Paleta Cielo (D62).
String htmlDePropuesta(Propuesta p, {required DateTime fecha}) {
  final rubro = T.rubros[p.rubro] ?? p.rubro;
  final zona = _e(p.zona ?? 'todas las zonas');
  final nombre = p.negocio?['nombre'] as String?;
  final titulo = 'Huellamy para ${_e(nombre ?? rubro)}';
  final aperturas = p.numeroDelNegocio('aperturas');
  final contactos = p.numeroDelNegocio('contactos');
  final favoritos = p.numeroDelNegocio('favoritos');

  final destacados = <(String, String)>[
    if (p.busquedas > 0)
      (
        '${p.busquedas}',
        'búsquedas de «${_e(rubro.toLowerCase())}» en ${p.dias} días'
            '${p.sinResultados > 0 ? ' (${p.sinResultados} sin resultados)' : ''}',
      ),
    ('${p.lugares}', 'lugares de este rubro en el mapa de $zona'),
    if (p.rubroAperturas > 0)
      ('${p.rubroAperturas}', 'veces se abrieron fichas de este rubro'),
    if (aperturas > 0)
      ('$aperturas', 'veces se abrió tu ficha, sin que hicieras nada'),
    if (contactos > 0)
      ('$contactos', 'contactos (WhatsApp, llamadas, cómo llegar…)'),
    if (favoritos > 0) ('$favoritos', 'personas te guardaron en favoritos'),
  ];

  final mascotas = [
    for (final m in p.mascotas)
      '${_n(m.cantidad)} ${_e(m.especie.toLowerCase())}',
  ].join(' · ');

  final casos = [
    for (final c in p.casos)
      '<blockquote><p>«${_e(c.cita)}»</p><footer>${_e(c.comercio)}'
          '${c.autor == null ? '' : ' — ${_e(c.autor!)}'}'
          '${c.numeros == null ? '' : '<br><strong>${_e(c.numeros!)}</strong>'}'
          '</footer></blockquote>',
  ].join('\n');

  final activos = p.activos == null
      ? ''
      : ', ${p.activos} activas en los últimos ${p.dias} días';

  return '''
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$titulo</title>
<style>
  @page { size: A4; margin: 16mm; }
  :root { --primario: #0B4F94; --celeste: #1AA0EA; --fondo: #F0F8FE; --tinta: #13294B; --gris: #4A5B72; }
  * { box-sizing: border-box; }
  body { margin: 0; padding: 24px; background: #fff; color: var(--tinta);
         font: 15px/1.45 "Nunito Sans", "Segoe UI", system-ui, sans-serif; }
  h1 { font: 900 26px/1.2 Nunito, "Segoe UI", system-ui, sans-serif; color: var(--primario); margin: 0 0 4px; }
  h2 { font: 800 16px/1.3 Nunito, "Segoe UI", system-ui, sans-serif; margin: 24px 0 8px; }
  .sub { color: var(--gris); margin: 0 0 20px; }
  .numeros { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; }
  .numero { background: var(--fondo); border-left: 4px solid var(--celeste); padding: 12px; border-radius: 6px; }
  .numero b { display: block; font: 900 28px/1.1 Nunito, "Segoe UI", system-ui, sans-serif; color: var(--primario); }
  ul { padding-left: 20px; margin: 0; }
  blockquote { margin: 0 0 12px; padding: 12px; background: var(--fondo); border-radius: 6px; }
  blockquote p { margin: 0 0 6px; font-style: italic; }
  footer, .nota { color: var(--gris); font-size: 13px; }
  .pie { margin-top: 28px; border-top: 1px solid #ddd; padding-top: 8px; }
</style>
</head>
<body>
<h1>$titulo</h1>
<p class="sub">Datos reales de la app en $zona · ${fecha.day}/${fecha.month}/${fecha.year}</p>

<h2>Lo que pasa en tu zona</h2>
<div class="numeros">
${[for (final (n, t) in destacados) '<div class="numero"><b>$n</b>$t</div>'].join('\n')}
</div>

<h2>Quiénes usan la app</h2>
<ul>
  <li>${_n(p.usuarios)} personas con cuenta$activos</li>
${mascotas.isEmpty ? '' : '  <li>Mascotas registradas: $mascotas</li>'}
</ul>

<h2>Qué te ofrecemos</h2>
<ul>
  <li><strong>Básico (gratis):</strong> tu ficha en el mapa, contactos, reseñas y un resumen de cuánta gente te ve.</li>
  <li><strong>Destacado:</strong> aparecés primero, con promoción y estadísticas completas todos los meses.</li>
  <li><strong>Plus:</strong> catálogo y pedidos, servicios, tu página propia y, si sos veterinaria, el módulo Socios.</li>
  <li><strong>Socios Fundadores:</strong> los primeros comercios tienen el plan Destacado gratis por un tiempo y el precio congelado después.</li>
</ul>

${casos.isEmpty ? '' : '<h2>Lo que dicen otros comercios</h2>\n$casos'}

<p class="nota pie">Huellamy · Hecho en Uruguay. Son cantidades de la app: nunca se comparte quién fue (Ley 18.331).</p>
</body>
</html>
''';
}
