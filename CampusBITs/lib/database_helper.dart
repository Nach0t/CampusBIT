import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // Constructor privado para el patrón Singleton
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'menu.db');
    return await openDatabase(
      path,
      version: 2, // Incrementa la versión si agregas nuevas tablas
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Método que se ejecuta al crear la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Crear la tabla `menu`
      await db.execute('''
        CREATE TABLE menu(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price INTEGER NOT NULL
        )
      ''');

      // Crear la tabla `generated_qr`
      await db.execute('''
        CREATE TABLE generated_qr (
          id TEXT PRIMARY KEY,
          menuType TEXT NOT NULL,
          price INTEGER NOT NULL,
          username TEXT NOT NULL,
          pickupPoint TEXT NOT NULL,
          validity TEXT NOT NULL
        )
      ''');
    } catch (e) {
      throw Exception('Error al crear la base de datos: $e');
    }
  }

  // Método que se ejecuta al actualizar la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Crear la tabla `generated_qr` si no existe
        await db.execute('''
          CREATE TABLE generated_qr (
            id TEXT PRIMARY KEY,
            menuType TEXT NOT NULL,
            price INTEGER NOT NULL,
            username TEXT NOT NULL,
            pickupPoint TEXT NOT NULL,
            validity TEXT NOT NULL
          )
        ''');
      } catch (e) {
        throw Exception('Error al actualizar la base de datos: $e');
      }
    }
  }

  // Inserta un nuevo elemento en la tabla `menu`
  Future<int> insertMenuItem(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      return await db.insert('menu', row);
    } catch (e) {
      throw Exception('Error al insertar un elemento en el menú: $e');
    }
  }

  // Obtiene todos los elementos de la tabla `menu`
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      Database db = await instance.database;
      return await db.query('menu');
    } catch (e) {
      throw Exception('Error al obtener los elementos del menú: $e');
    }
  }

  // Actualiza un elemento en la tabla `menu`
  Future<int> updateMenuItem(Map<String, dynamic> row) async {
    try {
      Database db = await instance.database;
      int id = row['id'];
      return await db.update('menu', row, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Error al actualizar un elemento del menú: $e');
    }
  }

  // Elimina un elemento de la tabla `menu`
  Future<int> deleteMenuItem(int id) async {
    try {
      Database db = await instance.database;
      return await db.delete('menu', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Error al eliminar un elemento del menú: $e');
    }
  }

  // Inserta un código QR generado para un usuario específico
  Future<void> insertQrForUser(Map<String, dynamic> qrData) async {
    try {
      Database db = await instance.database;
      await db.insert('generated_qr', qrData);
    } catch (e) {
      throw Exception('Error al insertar un código QR: $e');
    }
  }

  // Obtiene todos los códigos QR generados para un usuario específico
  Future<List<Map<String, dynamic>>> getQrForUser(String username) async {
    try {
      Database db = await instance.database;
      return await db.query(
        'generated_qr',
        where: 'username = ?',
        whereArgs: [username],
      );
    } catch (e) {
      throw Exception('Error al obtener los códigos QR del usuario: $e');
    }
  }
}
