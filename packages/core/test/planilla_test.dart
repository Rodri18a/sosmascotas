import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee lo pegado de Excel (tabulación) con encabezado', () {
    final p = leerPlanillaCatalogo(
      'Nombre\tDescripción\tPrecio\tDisponible\n'
      'Alimento 15 kg\tAdulto\t1.890\tsi\n'
      'Collar\t\t\tno\n',
    );
    expect(p.errores, isEmpty);
    expect(p.filas.map((f) => f.nombre), ['Alimento 15 kg', 'Collar']);
    expect(p.filas[0].precio, 1890);
    expect(p.filas[0].descripcion, 'Adulto');
    expect(p.filas[1].precio, isNull);
    expect(p.filas[1].disponible, isFalse);
  });

  test('CSV con punto y coma, comillas y precio con coma', () {
    final p = leerPlanillaCatalogo(
      'Pipeta "antipulgas";"Para perros; de 10 a 20 kg";\$ 450,50;\n',
    );
    expect(p.filas.single.nombre, 'Pipeta antipulgas');
    expect(p.filas.single.descripcion, 'Para perros; de 10 a 20 kg');
    expect(p.filas.single.precio, 450.5);
    expect(p.filas.single.disponible, isTrue);
  });

  test('el modelo se lee sin errores', () {
    final p = leerPlanillaCatalogo(modeloPlanillaCatalogo);
    expect(p.errores, isEmpty);
    expect(p.filas, hasLength(2));
  });

  test('errores con su número de fila', () {
    final p = leerPlanillaCatalogo(
      'nombre,descripcion,precio\n'
      ',sin nombre,10\n'
      'Hueso,,diez\n'
      'Pelota,,100\n'
      'pelota,,120\n'
      '\n'
      '${'x' * 81},,1\n',
    );
    expect(p.filas.map((f) => f.nombre), ['Pelota']);
    expect(p.errores, [
      (2, ErrorFilaCatalogo.sinNombre),
      (3, ErrorFilaCatalogo.precioInvalido),
      (5, ErrorFilaCatalogo.repetido),
      (7, ErrorFilaCatalogo.nombreLargo),
    ]);
  });
}
