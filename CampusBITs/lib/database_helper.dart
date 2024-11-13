import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'menu.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE menu(
        id INTEGER PRIMARY KEY,
        name TEXT,
        price INTEGER
      )
    ''');
  }

  // Insert a new menu item
  Future<int> insertMenuItem(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('menu', row);
  }

  // Get all menu items
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    Database db = await instance.database;
    return await db.query('menu');
  }

  // Update a menu item
  Future<int> updateMenuItem(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('menu', row, where: 'id = ?', whereArgs: [id]);
  }

  // Delete a menu item
  Future<int> deleteMenuItem(int id) async {
    Database db = await instance.database;
    return await db.delete('menu', where: 'id = ?', whereArgs: [id]);
  }
}
