import 'dart:io';

import 'package:campus_bit_app/data/app_database.dart';
import 'package:campus_bit_app/data/models.dart';
import 'package:campus_bit_app/data/sembast_app_database.dart';
import 'package:campus_bit_app/data/sqlite_app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_memory.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Abre la base "name"; abrirla de nuevo con el mismo nombre debe ver los
/// mismos datos (simula reiniciar la app).
typedef Opener = Future<AppDatabase> Function(String name);

void main() {
  sqfliteFfiInit();

  late Directory tempDir;
  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('campusbit_test_');
  });
  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  var counter = 0;
  String uniqueName() => 'db_${counter++}';

  group('SQLite', () {
    runContract(
      (name) => SqliteAppDatabase.open(
        databaseFactoryFfi,
        p.join(tempDir.path, '$name.db'),
      ),
      uniqueName,
    );
  });

  group('Sembast', () {
    final factory = newDatabaseFactoryMemory();
    runContract((name) => SembastAppDatabase.open(factory, name), uniqueName);
  });

  group('Migración SQLite v2 -> v4', () {
    test('conserva menú, QR, puntos y transacciones', () async {
      final path = p.join(tempDir.path, 'legacy_v2.db');
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) async {
            // Esquema exacto de la versión anterior de DBHelper.
            await db.execute('CREATE TABLE menu_items (id INTEGER PRIMARY KEY '
                'AUTOINCREMENT, name TEXT NOT NULL, price INTEGER NOT NULL, '
                'images TEXT NOT NULL)');
            await db.execute('CREATE TABLE user_points (username TEXT PRIMARY '
                'KEY, points INTEGER NOT NULL)');
            await db.execute('CREATE TABLE redemption_transactions (id INTEGER '
                'PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, item_name '
                'TEXT NOT NULL, cost INTEGER NOT NULL, timestamp DATETIME '
                'DEFAULT CURRENT_TIMESTAMP)');
            await db.execute('CREATE TABLE generated_qr (id TEXT PRIMARY KEY, '
                'menuType TEXT NOT NULL, price INTEGER NOT NULL, username TEXT '
                'NOT NULL, pickupPoint TEXT NOT NULL, validity TEXT NOT NULL)');
          },
        ),
      );
      await old.insert('menu_items', {
        'name': 'Promo desayuno',
        'price': 1800,
        'images': '["assets/PromoDesayuno.png", "assets/Cafe.png"]',
      });
      await old.insert('menu_items',
          {'name': 'Agregado por admin', 'price': 999, 'images': '[]'});
      await old.insert('user_points', {'username': 'ana', 'points': 70});
      await old.insert('redemption_transactions', {
        'username': 'ana',
        'item_name': 'Purchase',
        'cost': 7500,
        'timestamp': '2024-11-20T12:00:00.000',
      });
      await old.insert('redemption_transactions', {
        'username': 'ana',
        'item_name': 'Café gratis',
        'cost': 50,
        'timestamp': '2024-11-21T09:30:00.000',
      });
      await old.insert('generated_qr', {
        'id': 'qr-1',
        'menuType': 'Promo desayuno',
        'price': 1800,
        'username': 'ana',
        'pickupPoint': 'Cafeteria',
        'validity': '2024-11-21T12:00:00.000',
      });
      await old.close();

      final db = await SqliteAppDatabase.open(databaseFactoryFfi, path);
      addTearDown(db.close);

      final menu = await db.getMenuItems();
      expect(menu.map((m) => m.name), ['Promo desayuno', 'Agregado por admin']);
      expect(menu.first.images, ['assets/PromoDesayuno.png', 'assets/Cafe.png']);
      expect(menu.last.images, isEmpty);
      expect(menu.first.description, '');
      expect(menu.first.category, MenuCategory.promo);
      expect(menu.last.category, MenuCategory.almuerzo);

      expect(await db.getUserPoints('ana'), 70);
      expect((await db.getQrCodesForUser('ana')).single.id, 'qr-1');

      final txs = await db.getTransactions('ana');
      expect(txs, hasLength(2));
      final redemption = txs[0];
      final purchase = txs[1];
      expect(redemption.type, TransactionType.redemption);
      expect(redemption.description, 'Café gratis');
      expect(redemption.points, -50);
      expect(purchase.type, TransactionType.purchase);
      expect(purchase.amount, 7500);
      expect(purchase.points, 70);
    });
  });

  group('Migración Sembast v1 -> v3', () {
    test('separa el store único en stores por tipo', () async {
      final factory = newDatabaseFactoryMemory();
      final main = sembast.StoreRef<Object?, Object?>.main();

      // Versión anterior: todo en el store principal.
      final old = await factory.openDatabase('menu_database_web');
      await main.record('Promo desayuno').put(old, {
        'name': 'Promo desayuno',
        'price': 1800,
        'images': '["assets/PromoDesayuno.png", "assets/Cafe.png"]',
      });
      await main.record('qr-1').put(old, {
        'id': 'qr-1',
        'menuType': 'Promo desayuno',
        'price': 1800,
        'username': 'ana',
        'pickupPoint': 'Cafeteria',
        'validity': '2024-11-21T12:00:00.000',
      });
      await main.record('ana').put(old, {'points': 40});
      await main.record('ana-purchase-x').put(old, {
        'username': 'ana',
        'purchaseAmount': 4000,
        'timestamp': '2024-11-20T12:00:00.000',
      });
      await main.record('anaCafé').put(old, {
        'username': 'ana',
        'item_name': 'Café',
        'cost': 30,
        'timestamp': '2024-11-21T12:00:00.000',
      });
      await old.close();

      final db = await SembastAppDatabase.open(factory, 'menu_database_web');
      addTearDown(db.close);

      final menu = await db.getMenuItems();
      expect(menu.single.name, 'Promo desayuno');
      expect(menu.single.images, hasLength(2));
      expect(menu.single.category, MenuCategory.promo);
      expect(await db.getUserPoints('ana'), 40);

      final qrs = await db.getQrCodesForUser('ana');
      expect(qrs.single.id, 'qr-1');

      final txs = await db.getTransactions('ana');
      expect(txs.map((t) => t.type).toSet(),
          {TransactionType.purchase, TransactionType.redemption});
    });
  });
}

/// Pruebas que deben cumplir ambas implementaciones de [AppDatabase].
void runContract(Opener open, String Function() newName) {
  late String name;
  late AppDatabase db;

  setUp(() async {
    name = newName();
    db = await open(name);
  });
  tearDown(() => db.close());

  GeneratedQr qr(String id, String user, {DateTime? validity}) => GeneratedQr(
        id: id,
        menuType: 'Almuerzo normal',
        price: 3300,
        username: user,
        pickupPoint: 'Cafeteria',
        validity: validity ?? DateTime(2030, 1, 1, 12),
      );

  group('menú', () {
    test('una base nueva trae los productos por defecto', () async {
      final menu = await db.getMenuItems();
      expect(menu.map((m) => m.name), defaultMenuItems.map((m) => m.name));
      expect(menu.every((m) => m.id != null), isTrue);
      final ejecutivo = menu.firstWhere((m) => m.name == 'Almuerzo ejecutivo');
      expect(ejecutivo.images, hasLength(4));
      expect(ejecutivo.description, isNotEmpty);
      expect(ejecutivo.category, MenuCategory.almuerzo);
      final promos = menu.where((m) => m.category == MenuCategory.promo);
      expect(promos.map((m) => m.name), ['Promo desayuno', 'Promo almuerzo']);
    });

    test('insertar, actualizar nombre y precio, y eliminar', () async {
      final id = await db.insertMenuItem(const MenuItem(
        name: 'Completo',
        price: 2000,
        images: ['assets/otros.png'],
        category: MenuCategory.promo,
      ));

      var item = (await db.getMenuItems()).firstWhere((m) => m.id == id);
      expect(item.name, 'Completo');
      expect(item.images, ['assets/otros.png']);

      await db.updateMenuItem(item.copyWith(name: 'Completo italiano', price: 2500));
      item = (await db.getMenuItems()).firstWhere((m) => m.id == id);
      expect(item.name, 'Completo italiano');
      expect(item.price, 2500);
      expect(item.images, ['assets/otros.png']);
      expect(item.category, MenuCategory.promo);

      await db.deleteMenuItem(id);
      expect((await db.getMenuItems()).where((m) => m.id == id), isEmpty);
    });

    test('un producto eliminado no reaparece al reiniciar', () async {
      final first = (await db.getMenuItems()).first;
      await db.deleteMenuItem(first.id!);
      await db.close();

      db = await open(name);
      final names = (await db.getMenuItems()).map((m) => m.name);
      expect(names, isNot(contains(first.name)));
      expect(names, hasLength(defaultMenuItems.length - 1));
    });
  });

  group('códigos QR', () {
    test('insertar, listar por usuario y eliminar', () async {
      await db.insertQrCodes([qr('a', 'ana'), qr('b', 'ana'), qr('c', 'luis')]);

      final ana = await db.getQrCodesForUser('ana');
      expect(ana.map((q) => q.id).toSet(), {'a', 'b'});
      expect(ana.first.validity, DateTime(2030, 1, 1, 12));

      await db.deleteQrCode('a');
      expect((await db.getQrCodesForUser('ana')).map((q) => q.id), ['b']);
      expect((await db.getQrCodesForUser('luis')).single.id, 'c');
    });

    test('ordena del más reciente al más antiguo', () async {
      await db.insertQrCodes([
        qr('viejo', 'ana', validity: DateTime(2030, 1, 1)),
        qr('nuevo', 'ana', validity: DateTime(2030, 6, 1)),
      ]);
      expect((await db.getQrCodesForUser('ana')).map((q) => q.id),
          ['nuevo', 'viejo']);
    });
  });

  group('puntos', () {
    test('un usuario nuevo tiene 0 puntos', () async {
      expect(await db.getUserPoints('nadie'), 0);
    });

    test('las compras suman puntos y quedan registradas', () async {
      expect(
        await db.recordPurchase(username: 'ana', amount: 3500, pointsEarned: 30),
        30,
      );
      expect(
        await db.recordPurchase(username: 'ana', amount: 2500, pointsEarned: 20),
        50,
      );
      expect(await db.getUserPoints('ana'), 50);
      expect(await db.getUserPoints('luis'), 0);

      final txs = await db.getTransactions('ana');
      expect(txs.map((t) => t.points), [20, 30]); // más reciente primero
      expect(txs.every((t) => t.type == TransactionType.purchase), isTrue);
    });

    test('el canje descuenta puntos y se registra', () async {
      await db.recordPurchase(username: 'ana', amount: 10000, pointsEarned: 100);

      expect(await db.redeemPoints(username: 'ana', itemName: 'Café', cost: 60),
          isTrue);
      expect(await db.getUserPoints('ana'), 40);

      final last = (await db.getTransactions('ana')).first;
      expect(last.type, TransactionType.redemption);
      expect(last.description, 'Café');
      expect(last.points, -60);
    });

    test('sin saldo suficiente el canje no cambia nada', () async {
      await db.recordPurchase(username: 'ana', amount: 3000, pointsEarned: 30);

      expect(await db.redeemPoints(username: 'ana', itemName: 'Combo', cost: 31),
          isFalse);
      expect(await db.getUserPoints('ana'), 30);
      expect(await db.getTransactions('ana'), hasLength(1));
    });

    test('la compra guarda sus QR en la misma operación', () async {
      await db.recordPurchase(
        username: 'ana',
        amount: 6600,
        pointsEarned: 60,
        qrCodes: [qr('q1', 'ana'), qr('q2', 'ana')],
      );
      expect((await db.getQrCodesForUser('ana')).map((q) => q.id).toSet(),
          {'q1', 'q2'});
      expect(await db.getUserPoints('ana'), 60);
    });

    test('si un QR falla, la compra no se guarda a medias', () async {
      await db.insertQrCodes([qr('repetido', 'ana')]);
      await expectLater(
        db.recordPurchase(
          username: 'ana',
          amount: 3300,
          pointsEarned: 30,
          qrCodes: [qr('nuevo', 'ana'), qr('repetido', 'ana')],
        ),
        throwsA(anything),
      );
      expect(await db.getUserPoints('ana'), 0);
      expect(await db.getTransactions('ana'), isEmpty);
      expect((await db.getQrCodesForUser('ana')).map((q) => q.id),
          ['repetido']);
    });

    test('el canje guarda el QR del premio solo si alcanza el saldo', () async {
      await db.recordPurchase(username: 'ana', amount: 8000, pointsEarned: 80);

      expect(
        await db.redeemPoints(
            username: 'ana', itemName: 'Caro', cost: 100, qrCode: qr('no', 'ana')),
        isFalse,
      );
      expect(await db.getQrCodesForUser('ana'), isEmpty);

      expect(
        await db.redeemPoints(
            username: 'ana', itemName: 'Café', cost: 50, qrCode: qr('si', 'ana')),
        isTrue,
      );
      expect((await db.getQrCodesForUser('ana')).single.id, 'si');
      expect(await db.getUserPoints('ana'), 30);
    });

    test('los puntos persisten al reiniciar', () async {
      await db.recordPurchase(username: 'ana', amount: 5000, pointsEarned: 50);
      await db.close();

      db = await open(name);
      expect(await db.getUserPoints('ana'), 50);
      expect(await db.getTransactions('ana'), hasLength(1));
    });
  });
}
