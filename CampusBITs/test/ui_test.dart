import 'package:campus_bit_app/admin_screen.dart';
import 'package:campus_bit_app/company_selection_screen.dart';
import 'package:campus_bit_app/data/db_helper.dart';
import 'package:campus_bit_app/data/sembast_app_database.dart';
import 'package:campus_bit_app/locales_screen.dart';
import 'package:campus_bit_app/login_screen.dart';
import 'package:campus_bit_app/logic/cart.dart';
import 'package:campus_bit_app/cart_screen.dart';
import 'package:campus_bit_app/main_screen.dart';
import 'package:campus_bit_app/map_screen.dart';
import 'package:campus_bit_app/menu_screen.dart';
import 'package:campus_bit_app/points_screen.dart';
import 'package:campus_bit_app/profile_screen.dart';
import 'package:campus_bit_app/punto_retiro_screen.dart';
import 'package:campus_bit_app/qr_codes_screen.dart';
import 'package:campus_bit_app/qr_detail_screen.dart';
import 'package:campus_bit_app/ui/app_theme.dart';
import 'package:campus_bit_app/ui/widgets.dart';
import 'package:campus_bit_app/wait_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'test_helpers.dart';

void main() {
  group('formatPrice', () {
    test('usa punto como separador de miles', () {
      expect(formatPrice(0), '\$0');
      expect(formatPrice(999), '\$999');
      expect(formatPrice(1800), '\$1.800');
      expect(formatPrice(25000), '\$25.000');
      expect(formatPrice(1234567), '\$1.234.567');
    });
  });

  group('validaciones del admin', () {
    test('precio', () {
      expect(validatePrice(''), isNotNull);
      expect(validatePrice('abc'), isNotNull);
      expect(validatePrice('0'), isNotNull);
      expect(validatePrice('-5'), isNotNull);
      expect(validatePrice('3500'), isNull);
      expect(validatePrice(' 3500 '), isNull);
    });

    test('nombre', () {
      expect(validateName('   '), isNotNull);
      expect(validateName('Completo'), isNull);
    });
  });

  group('calcularTiempoEspera', () {
    final mediodia = DateTime(2026, 3, 10, 13, 15);

    test('reconoce los locales concurridos por su nombre real', () {
      // Antes solo funcionaba con 'Cafeteria' o 'Hall' exactos.
      expect(calcularTiempoEspera('Punto Hall', now: mediodia),
          '20-30 minutos');
      expect(calcularTiempoEspera('Punto Casino', now: mediodia),
          '20-30 minutos');
      expect(calcularTiempoEspera('Cafeteria', now: mediodia),
          '20-30 minutos');
    });

    test('otros locales usan el cálculo genérico', () {
      // 13 h: 5 + (13 % 3) * 5 = 10 -> '10-20 minutos'
      expect(calcularTiempoEspera('Punto Domo', now: mediodia),
          '10-20 minutos');
    });
  });

  group('pantallas en distintos tamaños (sin desbordes)', () {
    late AppDatabase db;

    setUp(() async {
      db = await SembastAppDatabase.open(newDatabaseFactoryMemory(), 'ui');
      DBHelper.useDatabase(db);
    });
    tearDown(() async {
      DBHelper.useDatabase(null);
      await db.close();
    });

    // QR del usuario de prueba (aparece en la lista de 'ana').
    final qr = GeneratedQr(
      id: 'qr-ui',
      menuType: 'Almuerzo ejecutivo con un nombre bastante largo',
      price: 3500,
      username: 'ana',
      pickupPoint: 'Punto Estacionamiento',
      validity: DateTime(2030, 1, 1, 12),
    );

    // Para el detalle: textos largos que podrían desbordar en 320 px.
    final longQr = GeneratedQr(
      id: 'qr-largo',
      menuType: 'Almuerzo ejecutivo con un nombre bastante largo',
      price: 3500,
      username: 'estudiante_con_un_nombre_de_usuario_muy_largo',
      pickupPoint: 'Punto Estacionamiento',
      validity: DateTime(2030, 1, 1, 12),
    );

    // Pantalla -> (constructor, texto que debe verse en su contenido).
    final screens = <String, (Widget Function(), String)>{
      'Login': (() => const LoginScreen(), 'INGRESAR'),
      'Empresa': (
        () => const CompanySelectionScreen(username: 'ana'),
        'OTRO',
      ),
      'Principal': (() => const MainScreen(username: 'ana'), 'Punto Casino'),
      'Locales': (() => const LocalesScreen(username: 'ana'), 'Punto Casino'),
      'Punto de retiro': (
        () => const PuntoRetiroScreen(username: 'ana', localName: 'Punto Hall'),
        'Ver Productos',
      ),
      'Mapa': (() => const MapScreen(username: 'ana'), 'Punto Carpa'),
      'Menú': (
        () => const MenuScreen(username: 'ana', pickupPoint: 'Hall'),
        'Promo desayuno',
      ),
      'Carrito': (
        () => CartScreen(
              cart: Cart()
                ..add(const MenuItem(
                    id: 1, name: 'Almuerzo ejecutivo', price: 3500))
                ..add(const MenuItem(
                    id: 2, name: 'Promo desayuno', price: 1800)),
              username: 'ana',
              pickupPoint: 'Punto Estacionamiento',
            ),
        'Almuerzo ejecutivo',
      ),
      'Puntos': (() => const PointsScreen(username: 'ana'), 'Menú Junaeb'),
      'QR': (
        () => const QrCodesScreen(
            username: 'ana', message: '¡Compra realizada por \$5.300!'),
        'Menú: Almuerzo ejecutivo con un nombre bastante largo',
      ),
      'Detalle QR': (
        () => QrDetailScreen(qr: longQr),
        'Almuerzo ejecutivo con un nombre bastante largo',
      ),
      'Perfil': (() => const ProfileScreen(username: 'ana'), 'Cerrar Sesión'),
      'Admin': (() => const AdminScreen(), 'Agregar'),
    };

    const sizes = {
      'teléfono angosto': Size(320, 640),
      'teléfono': Size(390, 844),
      'web escritorio': Size(1280, 800),
    };

    for (final screen in screens.entries) {
      for (final size in sizes.entries) {
        testWidgets('${screen.key} · ${size.key}', (tester) async {
          tester.view.physicalSize = size.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await real(tester, () async {
            await db.insertQrCodes([qr]);
            await db.recordPurchase(
                username: 'ana', amount: 3500, pointsEarned: 30);
          });

          final (build, expectedText) = screen.value;
          await tester.pumpWidget(MaterialApp(
            theme: buildAppTheme(),
            home: build(),
          ));
          await settle(tester);

          // Un desborde (RenderFlex overflowed) haría fallar el test.
          expect(tester.takeException(), isNull);
          // El contenido principal debe verse (un panel que ocupara toda la
          // pantalla lo dejaría con alto 0).
          expect(find.text(expectedText).hitTestable(), findsWidgets);
        });
      }
    }
  });
}
