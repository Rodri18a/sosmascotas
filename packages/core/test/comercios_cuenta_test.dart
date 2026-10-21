import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('módulos según el tipo de negocio (06)', () {
    test('la tabla de 06', () {
      bool a(Categoria c, Modulo m, [Modalidad mod = Modalidad.local]) =>
          moduloAdmitido(c, mod, m);
      expect(a(Categoria.vet, Modulo.socios), isTrue);
      expect(a(Categoria.vet, Modulo.agenda), isTrue);
      expect(a(Categoria.petshop, Modulo.catalogo), isTrue);
      expect(a(Categoria.petshop, Modulo.agenda), isFalse);
      expect(a(Categoria.grooming, Modulo.agenda), isTrue);
      expect(a(Categoria.grooming, Modulo.catalogo), isFalse);
      expect(a(Categoria.pharmacy, Modulo.catalogo), isTrue);
      expect(a(Categoria.hotel, Modulo.agenda), isTrue);
      expect(a(Categoria.agro, Modulo.catalogo), isTrue);
      expect(a(Categoria.agro, Modulo.agenda), isFalse);
      expect(a(Categoria.walker, Modulo.agenda), isTrue);
      expect(a(Categoria.petshop, Modulo.catalogo, Modalidad.online), isTrue);
      expect(a(Categoria.vet, Modulo.socios, Modalidad.online), isFalse);
      expect(a(Categoria.grooming, Modulo.agenda, Modalidad.domicilio), isTrue);
    });

    test('activo solo con Plus, si aplica y si lo prendió', () {
      expect(
        moduloActivo(
          Categoria.vet,
          Modalidad.local,
          PlanComercio.plus,
          Modulo.agenda,
          prendido: true,
        ),
        isTrue,
      );
      expect(
        moduloActivo(
          Categoria.vet,
          Modalidad.local,
          PlanComercio.featured,
          Modulo.agenda,
          prendido: true,
        ),
        isFalse,
      );
      expect(
        moduloActivo(
          Categoria.petshop,
          Modalidad.local,
          PlanComercio.plus,
          Modulo.agenda,
          prendido: true,
        ),
        isFalse,
      );
    });
  });

  test('mi negocio lee lo que solo ve su dueño', () {
    final n = MiNegocio.fromJson({
      'id': 'b1',
      'name': 'Peluquería Luna',
      'business_type': 'grooming',
      'kind': 'local',
      'lat': -34.71,
      'lng': -55.95,
      'hours': {},
      'verification': 'pending',
      'plan': 'featured',
      'status': 'active',
      'rut': '211111110019',
      'founder_until': '2027-06-30',
      'verification_requested_at': '2026-10-18T12:00:00Z',
    });
    expect(n.verificacion, Verificacion.pending);
    expect(n.comercio.plan, PlanComercio.featured);
    expect(n.comercio.tieneDuenio, isTrue);
    expect(n.fundadorHasta, DateTime(2027, 6, 30));
    expect(n.verificacionPedida, isTrue);
    expect(n.rut, '211111110019');
  });

  test('lugar sin reclamar: gris, con su rubro y la cantidad de marcas', () {
    final l = LugarSinReclamar.fromJson({
      'grupo': 'trainer:abc',
      'category': 'trainer',
      'lat': -34.73,
      'lng': -55.93,
      'marcas': 2,
      'google_link': 'https://maps.app.goo.gl/abc',
    });
    expect(l.categoria, Categoria.trainer);
    expect(l.marcas, 2);
    expect(l.pin.tipo, TipoPin.sinReclamar);
    // El rubro viaja en el pin: define el ícono (D82).
    expect(l.pin.categoria, Categoria.trainer);
  });

  test('el pin de un lugar lleva su rubro (D82)', () {
    final c = Comercio.fromJson({
      'id': 'b1',
      'name': 'X',
      'business_type': 'grooming',
      'lat': -34.72,
      'lng': -55.95,
      'hours': {},
    });
    expect(c.pin?.tipo, TipoPin.comercio);
    expect(c.pin?.categoria, Categoria.grooming);
    const punto = Punto(-34.72, -55.95);
    expect(
      const Pin(id: 'a', tipo: TipoPin.comercio, punto: punto),
      isNot(
        const Pin(
          id: 'a',
          tipo: TipoPin.comercio,
          punto: punto,
          categoria: Categoria.petshop,
        ),
      ),
    );
  });

  test('RUT', () {
    expect(rutValido('21 234567 0019'), isTrue);
    expect(rutValido('21.234.567.0019'), isTrue);
    expect(rutValido('1234'), isFalse);
  });

  test('el mapa lee fotos, plan y si tiene dueño', () {
    final c = Comercio.fromJson({
      'id': 'b1',
      'name': 'X',
      'hours': {},
      'plan': 'plus',
      'has_owner': true,
      'photos': ['b1/a.jpg'],
      'promo': '10% los martes',
    });
    expect(c.plan, PlanComercio.plus);
    expect(c.tieneDuenio, isTrue);
    expect(c.fotos, ['b1/a.jpg']);
    expect(c.promo, '10% los martes');
  });

  test('enlace de la página pública del comercio (D90)', () {
    expect(urlPaginaComercio('n1'), 'https://sosmascotas.uy/n/n1');
    expect(
      urlPaginaComercio('n1', base: 'https://sosmascota-web.vercel.app/'),
      'https://sosmascota-web.vercel.app/n/n1',
    );
  });
}
