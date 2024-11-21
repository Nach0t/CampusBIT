import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'menu_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE menu_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE user_points (
            username TEXT PRIMARY KEY,
            points INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE redemption_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            item_name TEXT NOT NULL,
            cost INTEGER NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        await _insertDefaultMenuItems(db);
      },
    );
  }

  Future<void> _insertDefaultMenuItems(Database db) async {
    List<Map<String, dynamic>> defaultItems = [
      {'name': 'Promo desayuno', 'price': 1800},
      {'name': 'Promo almuerzo', 'price': 2500},
      {'name': 'Almuerzo ejecutivo', 'price': 3500},
      {'name': 'Menú Junaeb', 'price': 2800},
      {'name': 'Almuerzo normal', 'price': 3300},
    ];

    for (var item in defaultItems) {
      await db.insert('menu_items', item);
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await database;
    return await db.query('menu_items');
  }

  Future<void> updateMenuItem(int id, int newPrice) async {
    final db = await database;
    await db.update(
      'menu_items',
      {'price': newPrice},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertMenuItem(String name, int price) async {
    final db = await database;
    await db.insert(
      'menu_items',
      {'name': name, 'price': price},
    );
  }

  Future<void> deleteMenuItem(int id) async {
    final db = await database;
    await db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUserPoints(String username) async {
    final db = await database;
    var result = await db.query('user_points', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) {
      return result.first['points'] as int;
    } else {
      await db.insert('user_points', {'username': username, 'points': 0});
      return 0;
    }
  }

  Future<void> updateUserPoints(String username, int points) async {
    final db = await database;
    await db.update(
      'user_points',
      {'points': points},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<void> recordRedemptionTransaction(String username, String itemName, int cost) async {
    final db = await database;
    await db.insert('redemption_transactions', {
      'username': username,
      'item_name': itemName,
      'cost': cost,
    });
  }
}
