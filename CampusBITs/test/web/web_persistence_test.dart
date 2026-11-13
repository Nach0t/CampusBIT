// Corre solo en el navegador, con IndexedDB real (lo mismo que usa la app
// en Web):
//
//   flutter test --platform chrome test/web
@TestOn('browser')
library;

import 'package:campus_bit_app/data/app_database.dart';
import 'package:campus_bit_app/data/models.dart';
import 'package:campus_bit_app/data/sembast_app_database.dart';
import 'package:campus_bit_app/logic/cart.dart';
import 'package:campus_bit_app/logic/checkout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast_web/sembast_web.dart';

void main() {
  // Nombre único por ejecución para no tocar la base real de la app.
  final dbName = 'campusbit_test_${DateTime.now().microsecondsSinceEpoch}';

  tearDownAll(() => databaseFactoryWeb.deleteDatabase(dbName));

  test('compra, canje y cambios del admin persisten al reabrir IndexedDB',
      () async {
    var db = await SembastAppDatabase.open(databaseFactoryWeb, dbName);

    // Menú inicial y cambio de administración.
    final menu = await db.getMenuItems();
    expect(menu, hasLength(defaultMenuItems.length));
    final ejecutivo = menu.firstWhere((m) => m.name == 'Almuerzo ejecutivo');
    await db.updateMenuItem(ejecutivo.copyWith(price: 3900));
    final borrado = menu.first;
    await db.deleteMenuItem(borrado.id!);

    // Compra: 2 almuerzos ejecutivos = $7.800 -> 70 puntos, 2 QR.
    final cart = Cart()
      ..add(ejecutivo.copyWith(price: 3900))
      ..add(ejecutivo.copyWith(price: 3900));
    final result = await checkout(
        db: db, cart: cart, username: 'ana', localName: 'Punto Hall');
    expect(result.codes, hasLength(2));
    expect(result.newBalance, 70);

    // Borrar un QR no genera otros.
    await db.deleteQrCode(result.codes.first.id);

    // "Reiniciar la app": cerrar y volver a abrir la base del navegador.
    await db.close();
    db = await SembastAppDatabase.open(databaseFactoryWeb, dbName);

    final menuDespues = await db.getMenuItems();
    expect(menuDespues.map((m) => m.name), isNot(contains(borrado.name)));
    expect(
      menuDespues.firstWhere((m) => m.name == 'Almuerzo ejecutivo').price,
      3900,
    );
    expect(await db.getUserPoints('ana'), 70);
    expect((await db.getQrCodesForUser('ana')).single.id, result.codes.last.id);
    expect(await db.getTransactions('ana'), hasLength(1));

    // Canje sin saldo suficiente: no cambia nada.
    expect(
      await redeemReward(db: db, username: 'ana', reward: rewards.first),
      isNull,
    );
    expect(await db.getUserPoints('ana'), 70);

    await db.close();
  });

  test('migra una base Web antigua (v1) guardada en IndexedDB', () async {
    final legacyName = '${dbName}_v1';
    addTearDown(() => databaseFactoryWeb.deleteDatabase(legacyName));

    // Así guardaba los datos la versión original de DBHelper.
    final old = await databaseFactoryWeb.openDatabase(legacyName);
    final main = sembast.StoreRef<Object?, Object?>.main();
    await main.record('Promo desayuno').put(old, {
      'name': 'Promo desayuno',
      'price': 1800,
      'images': '["assets/PromoDesayuno.png", "assets/Cafe.png"]',
    });
    await main.record('ana').put(old, {'points': 40});
    await old.close();

    final db = await SembastAppDatabase.open(databaseFactoryWeb, legacyName);
    final menu = await db.getMenuItems();
    expect(menu.single.name, 'Promo desayuno');
    expect(menu.single.category, MenuCategory.promo);
    expect(menu.single.images, hasLength(2));
    expect(await db.getUserPoints('ana'), 40);
    await db.close();
  });
}
