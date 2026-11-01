import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/mascotas/historial_pdf.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'libreta_falsa.dart';
import 'mascotas_falsas.dart';
import 'plan_usuario_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

Future<void> _abrirFicha(WidgetTester tester, {required bool pro}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas([_luna]),
      libreta: LibretaFalsa(),
      planUsuario: PlanUsuarioFalso(
        MiPlanUsuario(plan: pro ? Plan.pro : Plan.free),
      ),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.libreta,
        Funcionalidades.planesUsuario,
      }),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Luna'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Libreta sanitaria'), 300);
  await tester.scrollUntilVisible(find.text('Agregar a la libreta'), 300);
}

void main() {
  test('arma un PDF con acentos y la libreta agrupada', () async {
    ByteData fuente(String nombre) => ByteData.sublistView(
      File('assets/fuentes/$nombre.ttf').readAsBytesSync(),
    );
    final bytes = await historialSaludPdf(
      normal: fuente('NunitoSans-Regular'),
      negrita: fuente('NunitoSans-Bold'),
      grupos: {
        TipoRegistroSalud.vaccine: [
          RegistroSalud(
            id: 'r1',
            mascotaId: 'm1',
            tipo: TipoRegistroSalud.vaccine,
            nombre: 'Antirrábica',
            fecha: DateTime(2026, 3, 1),
            proxima: DateTime(2027, 3, 1),
            notas: 'Dosis anual, Dra. Núñez',
          ),
        ],
      },
      textos: (
        titulo: 'Historial de salud de Ñandú',
        datos: [('Especie', 'Gato')],
        sinRegistros: 'Vacía',
        grupo: (t) => 'Vacunas',
        fecha: (f) => '${f.day}/${f.month}/${f.year}',
        proxima: (f) => 'Próxima: $f',
        pie: 'Hecho con Huellitas',
      ),
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  testWidgets('con Pro aparece «Historial en PDF»', (tester) async {
    await _abrirFicha(tester, pro: true);
    expect(find.text('Historial en PDF'), findsOneWidget);
  });

  testWidgets('con Gratis no', (tester) async {
    await _abrirFicha(tester, pro: false);
    expect(find.text('Historial en PDF'), findsNothing);
  });
}
