import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';

void main() {
  test('sin Supabase configurado no hay comercios (no falla)', () async {
    const repo = ComerciosSinConfigurar();
    expect(
      await repo.enZona(
        const Limites(minLat: -35, minLng: -56, maxLat: -34, maxLng: -55),
      ),
      isEmpty,
    );
  });

  test('el repositorio falso devuelve solo los de la zona visible', () async {
    final repo = ComerciosFalsos([
      const Comercio(
        id: 'centro',
        nombre: 'Veterinaria Ejemplo Centro',
        punto: centroPando,
        horario: Horario({}),
      ),
      const Comercio(
        id: 'mvd',
        nombre: 'Lejos',
        punto: Punto(-34.9, -56.16),
        horario: Horario({}),
      ),
    ]);
    final enPando = await repo.enZona(
      const Limites(minLat: -34.75, minLng: -56, maxLat: -34.7, maxLng: -55.9),
    );
    expect(enPando.map((c) => c.id), ['centro']);
  });
}
