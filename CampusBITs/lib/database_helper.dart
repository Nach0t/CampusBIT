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

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE menu(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL
      )
    ''');

    // Datos iniciales
    await db.insert('menu', {'name': 'Desayuno Ejecutivo', 'price': 2500});
    await db.insert('menu', {'name': 'Almuerzo Especial', 'price': 4500});
    await db.insert('menu', {'name': 'Cena Ligera', 'price': 2000});
  }

  Future<int> insertMenuItem(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      return await db.insert('menu', row);
    } catch (e) {
      print('Error al insertar: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      Database db = await instance.database;
      return await db.query('menu');
    } catch (e) {
      print('Error al obtener elementos: $e');
      return [];
    }
  }

  Future<int> updateMenuItem(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      int id = row['id'];
      return await db.update('menu', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error al actualizar: $e');
      return -1;
    }
  }

  Future<int> deleteMenuItem(int id) async {
    try {
      Database db = await instance.database;
      return await db.delete('menu', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error al eliminar: $e');
      return -1;
    }
  }
}
