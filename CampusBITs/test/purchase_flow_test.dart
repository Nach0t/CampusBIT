import 'package:campus_bit_app/cart_screen.dart';
import 'package:campus_bit_app/data/db_helper.dart';
import 'package:campus_bit_app/data/sembast_app_database.dart';
import 'package:campus_bit_app/menu_screen.dart';
import 'package:campus_bit_app/qr_codes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

/// Los widget tests corren con un reloj simulado; la base en memoria usa
/// async real, así que sus operaciones se ejecutan dentro de `runAsync`.
Future<T> real<T>(WidgetTester tester, Future<T> Function() action) async {
  return (await tester.runAsync(action)) as T;
}

/// Deja que terminen las operaciones de base pendientes y redibuja.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = await SembastAppDatabase.open(newDatabaseFactoryMemory(), 'flow');
    DBHelper.useDatabase(db);
  });
  tearDown(() async {
    DBHelper.useDatabase(null);
    await db.close();
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      // Key nueva en cada llamada: fuerza a recrear la pantalla.
      key: UniqueKey(),
      home: const MenuScreen(username: 'ana', pickupPoint: 'Hall'),
    ));
    await settle(tester);
  }

  testWidgets('el menú muestra los productos de la base de datos',
      (tester) async {
    final id = await real(
      tester,
      () => db.insertMenuItem(const MenuItem(
        name: 'Completo italiano',
        price: 2200,
        category: MenuCategory.promo,
      )),
    );
    await pumpMenu(tester);

    expect(find.text('Completo italiano - \$2200'), findsOneWidget);
    expect(find.text('Promo desayuno - \$1800'), findsOneWidget);

    // Un cambio de administración se refleja al volver a abrir el menú.
    await real(
      tester,
      () => db.updateMenuItem(const MenuItem(
        name: 'Completo XL',
        price: 2500,
        category: MenuCategory.promo,
      ).copyWith(id: id)),
    );
    await pumpMenu(tester);
    expect(find.text('Completo XL - \$2500'), findsOneWidget);
    expect(find.text('Completo italiano - \$2200'), findsNothing);
  });

  testWidgets('comprar, ver los QR y eliminar uno sin generar nuevos',
      (tester) async {
    await pumpMenu(tester);

    // Promo desayuno ($1.800) es el primer producto.
    await tester.tap(find.text('Añadir').first);
    await tester.tap(find.text('Añadir').first);
    await tester.pump();
    expect(find.text('2 en el carrito'), findsOneWidget);

    await tester.tap(find.text('Ir al Carrito'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('Total: \$3600'), findsOneWidget);

    // Cantidades: +1 => 3 unidades.
    await tester.tap(find.byTooltip('Agregar uno'));
    await tester.pump();
    expect(find.text('Total: \$5400'), findsOneWidget);
    expect(find.textContaining('Ganarás 50 puntos'), findsOneWidget);

    // Sin método de pago no se compra.
    await tester.tap(find.text('Pagar'));
    await tester.pump();
    expect(find.text('Por favor, selecciona un método de pago.'),
        findsOneWidget);
    expect(await real(tester, () => db.getQrCodesForUser('ana')), isEmpty);

    // Se toca el recuadro de la opción (la imagen no carga en el test).
    await tester.tap(find
        .ancestor(
          of: find.image(const AssetImage('assets/webpay.png')),
          matching: find.byType(GestureDetector),
        )
        .first);
    await tester.pumpAndSettle(); // el aviso de error se cierra al elegir
    await tester.tap(find.text('Pagar'));
    await settle(tester);

    // Pantalla de QR con los 3 códigos de la compra.
    expect(find.byType(QrCodesScreen), findsOneWidget);
    expect(find.textContaining('¡Compra realizada por \$5400!'), findsOneWidget);
    expect(find.text('Menú: Promo desayuno'), findsNWidgets(3));
    expect(await real(tester, () => db.getQrCodesForUser('ana')), hasLength(3));
    expect(await real(tester, () => db.getUserPoints('ana')), 50);

    // Eliminar uno: quedan 2 y no se genera ninguno nuevo.
    await tester.tap(find.byTooltip('Eliminar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Eliminar'));
    await settle(tester);
    expect(await real(tester, () => db.getQrCodesForUser('ana')), hasLength(2));
    expect(find.text('Menú: Promo desayuno'), findsNWidgets(2));
    expect(await real(tester, () => db.getTransactions('ana')), hasLength(1));

    // "Atrás" vuelve al menú con el carrito vacío, no al carrito pagado.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsNothing);
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.text('Carrito (0) · \$0'), findsOneWidget);
  });
}
