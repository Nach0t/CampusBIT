import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'models.dart';

/// Persistencia para Android/iOS usando SQLite (sqflite).
///
/// Historial de versiones del esquema:
/// - v1: menu_items, user_points, redemption_transactions.
/// - v2: + generated_qr.
/// - v3: + menu_items.description; redemption_transactions se reemplaza por
///   transactions (compras y canjes con tipo y puntos), copiando los datos.
/// - v4: + menu_items.category ('promo' o 'almuerzo').
class SqliteAppDatabase implements AppDatabase {
  static const int schemaVersion = 4;

  final Database _db;

  SqliteAppDatabase._(this._db);

  /// Abre (o crea/migra) la base en [path] usando [factory].
  ///
  /// En la app se usa el `databaseFactory` de sqflite; en los tests,
  /// `databaseFactoryFfi` con `inMemoryDatabasePath`.
  static Future<SqliteAppDatabase> open(
    DatabaseFactory factory,
    String path,
  ) async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return SqliteAppDatabase._(db);
  }

  // ---------------------------------------------------------------------
  // Esquema y migraciones
  // ---------------------------------------------------------------------

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        images TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'almuerzo'
      )
    ''');
    batch.execute(_createUserPoints);
    batch.execute(_createGeneratedQr);
    batch.execute(_createTransactions);
    for (final item in defaultMenuItems) {
      batch.insert('menu_items', _menuItemToRow(item));
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int _) async {
    if (oldVersion < 2) {
      await db.execute(_createGeneratedQr);
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE menu_items ADD COLUMN description TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(_createUserPoints);
      await db.execute(_createTransactions);
      if (await _tableExists(db, 'redemption_transactions')) {
        // Antes las compras se guardaban con item_name = 'Purchase' y
        // cost = monto; los canjes con el nombre del artículo y su costo.
        await db.execute('''
          INSERT INTO transactions
            (username, type, description, amount, points, timestamp)
          SELECT
            username,
            CASE WHEN item_name = 'Purchase' THEN 'purchase' ELSE 'redemption' END,
            CASE WHEN item_name = 'Purchase' THEN 'Compra' ELSE item_name END,
            CASE WHEN item_name = 'Purchase' THEN cost ELSE 0 END,
            CASE WHEN item_name = 'Purchase' THEN (cost / 1000) * 10 ELSE -cost END,
            COALESCE(timestamp, CURRENT_TIMESTAMP)
          FROM redemption_transactions
          ORDER BY id
        ''');
        await db.execute('DROP TABLE redemption_transactions');
      }
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE menu_items ADD COLUMN category TEXT NOT NULL "
        "DEFAULT 'almuerzo'",
      );
      // Las promociones existentes se reconocen por su nombre.
      await db.execute(
        "UPDATE menu_items SET category = 'promo' WHERE name LIKE 'Promo%'",
      );
    }
  }

  static const _createUserPoints = '''
    CREATE TABLE IF NOT EXISTS user_points (
      username TEXT PRIMARY KEY,
      points INTEGER NOT NULL
    )
  ''';

  static const _createGeneratedQr = '''
    CREATE TABLE IF NOT EXISTS generated_qr (
      id TEXT PRIMARY KEY,
      menuType TEXT NOT NULL,
      price INTEGER NOT NULL,
      username TEXT NOT NULL,
      pickupPoint TEXT NOT NULL,
      validity TEXT NOT NULL
    )
  ''';

  static const _createTransactions = '''
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      type TEXT NOT NULL,
      description TEXT NOT NULL,
      amount INTEGER NOT NULL,
      points INTEGER NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''';

  static Future<bool> _tableExists(DatabaseExecutor db, String table) async {
    final rows = await db.query(
      'sqlite_master',
      where: 'type = ? AND name = ?',
      whereArgs: ['table', table],
    );
    return rows.isNotEmpty;
  }

  // ---------------------------------------------------------------------
  // Menú
  // ---------------------------------------------------------------------

  static Map<String, Object?> _menuItemToRow(MenuItem item) => {
        'name': item.name,
        'price': item.price,
        'description': item.description,
        'images': encodeImages(item.images),
        'category': item.category.name,
      };

  static MenuItem _menuItemFromRow(Map<String, Object?> row) => MenuItem(
        id: row['id'] as int,
        name: row['name'] as String,
        price: row['price'] as int,
        description: (row['description'] as String?) ?? '',
        images: decodeImages(row['images']),
        category: MenuCategory.fromName(row['category']),
      );

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final rows = await _db.query('menu_items', orderBy: 'id');
    return rows.map(_menuItemFromRow).toList();
  }

  @override
  Future<int> insertMenuItem(MenuItem item) {
    return _db.insert('menu_items', _menuItemToRow(item));
  }

  @override
  Future<void> updateMenuItem(MenuItem item) async {
    final id = item.id;
    if (id == null) {
      throw ArgumentError('updateMenuItem requiere un producto con id');
    }
    await _db.update(
      'menu_items',
      _menuItemToRow(item),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await _db.delete('menu_items', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------
  // Códigos QR
  // ---------------------------------------------------------------------

  @override
  Future<void> insertQrCodes(List<GeneratedQr> codes) async {
    await _db.transaction((txn) => _insertQrCodes(txn, codes));
  }

  static Future<void> _insertQrCodes(
    DatabaseExecutor db,
    List<GeneratedQr> codes,
  ) async {
    for (final code in codes) {
      await db.insert('generated_qr', code.toMap());
    }
  }

  @override
  Future<List<GeneratedQr>> getQrCodesForUser(String username) async {
    final rows = await _db.query(
      'generated_qr',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'validity DESC',
    );
    return rows.map(GeneratedQr.fromMap).toList();
  }

  @override
  Future<void> deleteQrCode(String id) async {
    await _db.delete('generated_qr', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------
  // Puntos y transacciones
  // ---------------------------------------------------------------------

  static Future<int> _readPoints(DatabaseExecutor db, String username) async {
    final rows = await db.query(
      'user_points',
      columns: ['points'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return rows.isEmpty ? 0 : rows.first['points'] as int;
  }

  static Future<void> _writePoints(
    DatabaseExecutor db,
    String username,
    int points,
  ) async {
    final updated = await db.update(
      'user_points',
      {'points': points},
      where: 'username = ?',
      whereArgs: [username],
    );
    if (updated == 0) {
      await db.insert('user_points', {'username': username, 'points': points});
    }
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
      await _writePoints(txn, username, balance);
      await txn.insert(
        'transactions',
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
      await _writePoints(txn, username, current - cost);
      if (qrCode != null) await _insertQrCodes(txn, [qrCode]);
      await txn.insert(
        'transactions',
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
    final rows = await _db.query(
      'transactions',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
    return rows.map((r) => PointsTransaction.fromMap(r)).toList();
  }

  @override
  Future<void> close() => _db.close();
}
