/// Carga del catálogo por planilla (2.10, portal de empresas, D114): el
/// comercio pega lo copiado de Excel o Google Sheets (separado por tabulación)
/// o un CSV (con coma o punto y coma). Columnas: nombre, descripción, precio,
/// disponible. La primera fila puede ser el encabezado.
library;

import 'catalogo.dart';

/// Lo que dice el modelo para descargar (CSV con punto y coma, como lo abre
/// Excel en español).
const modeloPlanillaCatalogo =
    'nombre;descripcion;precio;disponible\n'
    'Alimento perro adulto 15 kg;Marca y sabor;1.890;si\n'
    'Collar regulable;Talles S a L;;si\n';

class FilaCatalogo {
  const FilaCatalogo({
    required this.fila,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.disponible = true,
  });

  /// Número de fila en la planilla (empieza en 1, contando el encabezado).
  final int fila;
  final String nombre;
  final String? descripcion;

  /// `null`: sin precio ("Consultar").
  final double? precio;
  final bool disponible;
}

enum ErrorFilaCatalogo { sinNombre, nombreLargo, precioInvalido, repetido }

typedef PlanillaCatalogo = ({
  List<FilaCatalogo> filas,
  List<(int, ErrorFilaCatalogo)> errores,
});

/// Lee la planilla. Las filas vacías se saltean; un nombre repetido en la
/// misma planilla es un error (se queda la primera).
PlanillaCatalogo leerPlanillaCatalogo(String texto) {
  final lineas = texto
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n');
  final filas = <FilaCatalogo>[];
  final errores = <(int, ErrorFilaCatalogo)>[];
  final vistos = <String>{};
  for (var i = 0; i < lineas.length; i++) {
    final linea = lineas[i];
    if (linea.trim().isEmpty) continue;
    final celdas = _celdas(linea, _separador(linea));
    final nombre = celdas.first.trim();
    if (i == 0 && nombre.toLowerCase() == 'nombre') continue;
    String celda(int n) => n < celdas.length ? celdas[n].trim() : '';
    final fila = i + 1;
    if (nombre.isEmpty) {
      errores.add((fila, ErrorFilaCatalogo.sinNombre));
      continue;
    }
    if (nombre.length > 80) {
      errores.add((fila, ErrorFilaCatalogo.nombreLargo));
      continue;
    }
    final textoPrecio = celda(2);
    final precio = leerPrecio(textoPrecio);
    if (textoPrecio.isNotEmpty && (precio == null || precio < 0)) {
      errores.add((fila, ErrorFilaCatalogo.precioInvalido));
      continue;
    }
    if (!vistos.add(nombre.toLowerCase())) {
      errores.add((fila, ErrorFilaCatalogo.repetido));
      continue;
    }
    final disponible = celda(3).toLowerCase();
    filas.add(
      FilaCatalogo(
        fila: fila,
        nombre: nombre,
        descripcion: switch (celda(1)) {
          '' => null,
          final d => d.length > 300 ? d.substring(0, 300) : d,
        },
        precio: precio,
        disponible: !const {
          'no',
          'n',
          'false',
          '0',
          'agotado',
        }.contains(disponible),
      ),
    );
  }
  return (filas: filas, errores: errores);
}

String _separador(String linea) {
  if (linea.contains('\t')) return '\t';
  if (linea.contains(';')) return ';';
  return ',';
}

/// Separa una línea respetando las comillas ("Collar, rojo" es una celda).
List<String> _celdas(String linea, String separador) {
  final celdas = <String>[];
  final actual = StringBuffer();
  var entreComillas = false;
  for (var i = 0; i < linea.length; i++) {
    final c = linea[i];
    if (c == '"') {
      if (entreComillas && i + 1 < linea.length && linea[i + 1] == '"') {
        actual.write('"');
        i++;
      } else {
        entreComillas = !entreComillas;
      }
    } else if (c == separador && !entreComillas) {
      celdas.add(actual.toString());
      actual.clear();
    } else {
      actual.write(c);
    }
  }
  celdas.add(actual.toString());
  return celdas;
}
