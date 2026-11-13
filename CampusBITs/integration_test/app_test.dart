// Pruebas de integración: corren DENTRO de un dispositivo o emulador, con la
// app real y el plugin sqflite real de Android/iOS.
//
//   flutter test integration_test            (con un emulador abierto)
import 'package:campus_bit_app/data/db_helper.dart';
import 'package:campus_bit_app/data/sqlite_app_database.dart';
import 'package:campus_bit_app/logic/cart.dart';
import 'package:campus_bit_app/logic/checkout.dart';
import 'package:campus_bit_app/main.dart';
import 'package:campus_bit_app/qr_codes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('SQLite del dispositivo: los datos persisten al cerrar y reabrir',
      () async {
    final path = join(await getDatabasesPath(), 'integration_test.db');
    await deleteDatabase(path);
    addTearDown(() => deleteDatabase(path));

    var db = await SqliteAppDatabase.open(databaseFactory, path);
    final menu = await db.getMenuItems();
    expect(menu, hasLength(defaultMenuItems.length));

    final ejecutivo = menu.firstWhere((m) => m.name == 'Almuerzo ejecutivo');
    await db
        .updateMenuItem(ejecutivo.copyWith(name: 'Ejecutivo XL', price: 4100));
    await db.deleteMenuItem(menu.first.id!);

    final cart = Cart()
      ..add(ejecutivo.copyWith(price: 4100))
      ..add(ejecutivo.copyWith(price: 4100)); // $8.200 -> 80 puntos
    final result = await checkout(
        db: db, cart: cart, username: 'ana', localName: 'Punto Hall');
    expect(result.codes, hasLength(2));
    await db.close();

    // "Reinicio": se vuelve a abrir el mismo archivo.
    db = await SqliteAppDatabase.open(databaseFactory, path);
    final menuDespues = await db.getMenuItems();
    expect(menuDespues.map((m) => m.name), contains('Ejecutivo XL'));
    expect(menuDespues.map((m) => m.name), isNot(contains(menu.first.name)));
    expect(await db.getUserPoints('ana'), 80);
    expect(await db.getQrCodesForUser('ana'), hasLength(2));

    // Canje: 700 puntos no alcanzan; tras otra compra grande, sí.
    expect(await redeemReward(db: db, username: 'ana', reward: rewards.first),
        isNull);
    await db.recordPurchase(username: 'ana', amount: 70000, pointsEarned: 700);
    final premio =
        await redeemReward(db: db, username: 'ana', reward: rewards.first);
    expect(premio, isNotNull);
    expect(await db.getUserPoints('ana'), 80);
    expect(await db.getQrCodesForUser('ana'), hasLength(3));
    await db.close();
  });

  testWidgets('flujo completo en la app: login, compra, QR y puntos',
      (tester) async {
    // Base SQLite propia y nueva (plugin real del dispositivo), para no
    // depender de lo que haya en la base de la app (precios editados, etc.).
    final path = join(await getDatabasesPath(), 'integration_flow.db');
    await deleteDatabase(path);
    final db = await SqliteAppDatabase.open(databaseFactory, path);
    DBHelper.useDatabase(db);
    const user = 'alumno';
    // bySemanticsLabel necesita el árbol de accesibilidad activo.
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), user);
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text('INGRESAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Universidad San Sebastián'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Punto Casino'));
    await tester.pumpAndSettle();
    // El retiro es siempre en la Cafetería; el local es donde se pide.
    expect(find.text('Cafetería Principal'), findsOneWidget);
    expect(find.text('Pedido desde Punto Casino'), findsOneWidget);

    await tester.tap(find.text('Ver Productos'));
    await tester.pumpAndSettle();

    // Promo desayuno ($1.800) x2.
    await tester.tap(find.text('Añadir').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Añadir').first);
    await tester.pumpAndSettle();
    expect(find.text('2 en el carrito'), findsOneWidget);

    await tester.tap(find.text('Ir al Carrito'));
    await tester.pumpAndSettle();
    expect(find.text('Total: \$3.600'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('WebPay'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pagar'));
    await tester.pumpAndSettle();

    expect(find.byType(QrCodesScreen), findsOneWidget);
    expect(
        find.textContaining('¡Compra realizada por \$3.600!'), findsOneWidget);
    expect(find.text('Menú: Promo desayuno'), findsNWidgets(2));
    expect(find.text('Retiro: Cafetería Principal'), findsNWidgets(2));

    // Volver hasta la pantalla principal y abrir la pestaña Puntos.
    for (var i = 0; i < 3; i++) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Puntos'));
    await tester.pumpAndSettle();
    expect(find.text('Puntos Totales: 30'), findsOneWidget);
    expect(find.text('Compra en Punto Casino (2 productos)'), findsOneWidget);

    semantics.dispose(); // Debe liberarse antes de que termine el test
    DBHelper.useDatabase(null);
    await db.close();
    await deleteDatabase(path);
  });
}
