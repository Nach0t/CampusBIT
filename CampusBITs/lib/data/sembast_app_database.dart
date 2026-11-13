import 'package:sembast/sembast.dart';

import 'app_database.dart';
import 'models.dart';

/// Persistencia para Web usando sembast (IndexedDB en el navegador).
///
/// Historial de versiones:
/// - v1: todo se guardaba mezclado en el store principal (`StoreRef.main()`).
/// - v2: un store por tipo de dato; los datos de v1 se trasladan al abrir.
/// - v3: los productos guardan su categoría ('promo' o 'almuerzo').
class SembastAppDatabase implements AppDatabase {
  static const int schemaVersion = 3;

  static final _menu = intMapStoreFactory.store('menu_items');
  static final _qr = stringMapStoreFactory.store('generated_qr');
  static final _points = stringMapStoreFactory.store('user_points');
  static final _transactions = intMapStoreFactory.store('transactions');

  final Database _db;

  SembastAppDatabase._(this._db);

  /// Abre (o crea/migra) la base [name] usando [factory].
  ///
  /// En la app se usa `databaseFactoryWeb`; en los tests,
  /// `databaseFactoryMemory`.
  static Future<SembastAppDatabase> open(
    DatabaseFactory factory,
    String name,
  ) async {
    final db = await factory.openDatabase(
      name,
      version: schemaVersion,
      onVersionChanged: (db, oldVersion, newVersion) async {
        if (oldVersion == 0) {
          await _seedMenu(db); // Base nueva
          return;
        }
        if (oldVersion < 2) await _migrateFromMainStore(db);
        if (oldVersion < 3) await _addCategories(db);
      },
    );
    return SembastAppDatabase._(db);
  }

  static Future<void> _seedMenu(DatabaseClient db) async {
    for (final item in defaultMenuItems) {
      await _menu.add(db, _menuItemToValue(item));
    }
  }

  /// Traslada los registros de la v1 (store principal) a los nuevos stores.
  static Future<void> _migrateFromMainStore(Database db) async {
    final main = StoreRef<Object?, Object?>.main();
    await db.transaction((txn) async {
      final records = await main.find(txn);
      for (final record in records) {
        final value = record.value;
        if (value is! Map) continue;
        final map = value.cast<String, Object?>();

        if (map.containsKey('menuType')) {
          final code = GeneratedQr.fromMap(map);
          await _qr.record(code.id).put(txn, code.toMap());
        } else if (map.containsKey('name') && map.containsKey('price')) {
          await _menu.add(
            txn,
            _menuItemToValue(MenuItem(
              name: map['name'] as String,
              price: (map['price'] as num).toInt(),
              images: decodeImages(map['images']),
              category: _legacyCategory(map['name'] as String),
            )),
          );
        } else if (map.containsKey('item_name')) {
          final cost = (map['cost'] as num).toInt();
          await _transactions.add(
            txn,
            PointsTransaction(
              username: map['username'] as String,
              type: TransactionType.redemption,
              description: map['item_name'] as String,
              amount: 0,
              points: -cost,
              timestamp: DateTime.parse(map['timestamp'] as String),
            ).toMap(),
          );
        } else if (map.containsKey('purchaseAmount')) {
          final amount = (map['purchaseAmount'] as num).toInt();
          await _transactions.add(
            txn,
            PointsTransaction(
              username: map['username'] as String,
              type: TransactionType.purchase,
              description: 'Compra',
              amount: amount,
              points: (amount ~/ 1000) * 10,
              timestamp: DateTime.parse(map['timestamp'] as String),
            ).toMap(),
          );
        } else if (map.containsKey('points') && record.key is String) {
          // En v1 la clave del registro de puntos era el nombre de usuario.
          await _points.record(record.key as String).put(
            txn,
            {'points': (map['points'] as num).toInt()},
          );
        }
      }
      await main.delete(txn);
      if (await _menu.count(txn) == 0) {
        await _seedMenu(txn);
      }
    });
  }

  /// v3: asigna categoría a los productos que no la tienen.
  static Future<void> _addCategories(Database db) async {
    await db.transaction((txn) async {
      final records = await _menu.find(txn);
      for (final record in records) {
        if (record.value['category'] != null) continue;
        final category = _legacyCategory(record.value['name'] as String);
        await _menu.record(record.key).update(txn, {'category': category.name});
      }
    });
  }

  /// Datos anteriores a v3: las promociones se reconocen por su nombre
  /// (misma regla que la migración v4 de SQLite).
  static MenuCategory _legacyCategory(String name) =>
      name.startsWith('Promo') ? MenuCategory.promo : MenuCategory.almuerzo;

  // ---------------------------------------------------------------------
  // Menú
  // ---------------------------------------------------------------------

  static Map<String, Object?> _menuItemToValue(MenuItem item) => {
        'name': item.name,
        'price': item.price,
        'description': item.description,
        'images': item.images,
        'category': item.category.name,
      };

  static MenuItem _menuItemFromRecord(
    RecordSnapshot<int, Map<String, Object?>> record,
  ) {
    final v = record.value;
    return MenuItem(
      id: record.key,
      name: v['name'] as String,
      price: (v['price'] as num).toInt(),
      description: (v['description'] as String?) ?? '',
      images: decodeImages(v['images']),
      category: MenuCategory.fromName(v['category']),
    );
  }

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final records = await _menu.find(
      _db,
      finder: Finder(sortOrders: [SortOrder(Field.key)]),
    );
    return records.map(_menuItemFromRecord).toList();
  }

  @override
  Future<int> insertMenuItem(MenuItem item) {
    return _menu.add(_db, _menuItemToValue(item));
  }

  @override
  Future<void> updateMenuItem(MenuItem item) async {
    final id = item.id;
    if (id == null) {
      throw ArgumentError('updateMenuItem requiere un producto con id');
    }
    await _menu.record(id).update(_db, _menuItemToValue(item));
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await _menu.record(id).delete(_db);
  }

  // ---------------------------------------------------------------------
  // Códigos QR
  // ---------------------------------------------------------------------

  @override
  Future<void> insertQrCodes(List<GeneratedQr> codes) async {
    await _db.transaction((txn) => _insertQrCodes(txn, codes));
  }

  static Future<void> _insertQrCodes(
    DatabaseClient db,
    List<GeneratedQr> codes,
  ) async {
    for (final code in codes) {
      // Igual que la clave primaria en SQLite: un id repetido es un error
      // y deshace toda la transacción (nunca se sobrescribe un QR).
      final key = await _qr.record(code.id).add(db, code.toMap());
      if (key == null) {
        throw StateError('Ya existe un código QR con id ${code.id}');
      }
    }
  }

  @override
  Future<List<GeneratedQr>> getQrCodesForUser(String username) async {
    final records = await _qr.find(
      _db,
      finder: Finder(
        filter: Filter.equals('username', username),
        sortOrders: [SortOrder('validity', false)],
      ),
    );
    return records.map((r) => GeneratedQr.fromMap(r.value)).toList();
  }

  @override
  Future<void> deleteQrCode(String id) async {
    await _qr.record(id).delete(_db);
  }

  // ---------------------------------------------------------------------
  // Puntos y transacciones
  // ---------------------------------------------------------------------

  static Future<int> _readPoints(DatabaseClient db, String username) async {
    final value = await _points.record(username).get(db);
    return value == null ? 0 : (value['points'] as num).toInt();
  }

  @override
  Future<int> getUserPoints(String username) => _readPoints(_db, username);

  @override
  Future<int> recordPurchase({
    required String username,
    required int amount,
    required int pointsEarned,
    String description = 'Compra',
    List<GeneratedQr> qrCodes = const [],
  }) {
    return _db.transaction((txn) async {
      await _insertQrCodes(txn, qrCodes);
      final balance = await _readPoints(txn, username) + pointsEarned;
      await _points.record(username).put(txn, {'points': balance});
      await _transactions.add(
        txn,
        PointsTransaction(
          username: username,
          type: TransactionType.purchase,
          description: description,
          amount: amount,
          points: pointsEarned,
          timestamp: DateTime.now(),
        ).toMap(),
      );
      return balance;
    });
  }

  @override
  Future<bool> redeemPoints({
    required String username,
    required String itemName,
    required int cost,
    GeneratedQr? qrCode,
  }) {
    return _db.transaction((txn) async {
      final current = await _readPoints(txn, username);
      if (cost <= 0 || current < cost) return false;
      await _points.record(username).put(txn, {'points': current - cost});
      if (qrCode != null) await _insertQrCodes(txn, [qrCode]);
      await _transactions.add(
        txn,
        PointsTransaction(
          username: username,
          type: TransactionType.redemption,
          description: itemName,
          amount: 0,
          points: -cost,
          timestamp: DateTime.now(),
        ).toMap(),
      );
      return true;
    });
  }

  @override
  Future<List<PointsTransaction>> getTransactions(String username) async {
    final records = await _transactions.find(
      _db,
      finder: Finder(
        filter: Filter.equals('username', username),
        sortOrders: [SortOrder(Field.key, false)],
      ),
    );
    return records
        .map((r) => PointsTransaction.fromMap(r.value, id: r.key))
        .toList();
  }

  @override
  Future<void> close() => _db.close();
}
