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
    try {
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
          // Insert default menu items
          await _insertDefaultMenuItems(db);
        },
      );
    } catch (e) {
      print("Error initializing the database: $e");
      rethrow;
    }
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
      try {
        await db.insert('menu_items', item);
      } catch (e) {
        print("Error inserting default item: ${item['name']} - Error: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      final db = await database;
      return await db.query('menu_items');
    } catch (e) {
      print("Error fetching menu items: $e");
      return [];
    }
  }

  Future<void> updateMenuItem(int id, int newPrice) async {
    try {
      final db = await database;
      await db.update(
        'menu_items',
        {'price': newPrice},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error updating menu item with ID $id: $e");
    }
  }

  Future<void> insertMenuItem(String name, int price) async {
    try {
      final db = await database;
      await db.insert(
        'menu_items',
        {'name': name, 'price': price},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting new menu item: $e");
    }
  }

  Future<void> deleteMenuItem(int id) async {
    try {
      final db = await database;
      await db.delete(
        'menu_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting menu item with ID $id: $e");
    }
  }
}
