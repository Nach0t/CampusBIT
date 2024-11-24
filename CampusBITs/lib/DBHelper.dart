import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Singleton Pattern
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // Nombres de tablas y columnas
  static const String tableMenuItems = 'menu_items';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnPrice = 'price';

  static const String tableUserPoints = 'user_points';
  static const String columnUsername = 'username';
  static const String columnPoints = 'points';

  static const String tableRedemptionTransactions = 'redemption_transactions';
  static const String columnItemName = 'item_name';
  static const String columnCost = 'cost';
  static const String columnTimestamp = 'timestamp';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'menu_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Crear tablas
        await db.execute('''
          CREATE TABLE $tableMenuItems (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnPrice INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableUserPoints (
            $columnUsername TEXT PRIMARY KEY,
            $columnPoints INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableRedemptionTransactions (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUsername TEXT NOT NULL,
            $columnItemName TEXT NOT NULL,
            $columnCost INTEGER NOT NULL,
            $columnTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Insertar menú predeterminado
        await _insertDefaultMenuItems(db);
      },
    );
  }

  // Inserta elementos predeterminados en el menú
  Future<void> _insertDefaultMenuItems(Database db) async {
    List<Map<String, dynamic>> defaultItems = [
      {'name': 'Promo desayuno', 'price': 1800},
      {'name': 'Promo almuerzo', 'price': 2500},
      {'name': 'Almuerzo ejecutivo', 'price': 3500},
      {'name': 'Menú Junaeb', 'price': 2800},
      {'name': 'Almuerzo normal', 'price': 3300},
    ];

    for (var item in defaultItems) {
      await db.insert(tableMenuItems, item);
    }
  }

  // Consultar todos los elementos del menú
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await database;
    return await db.query(tableMenuItems);
  }

  // Actualizar precio de un elemento del menú
  Future<void> updateMenuItem(int id, int newPrice) async {
    final db = await database;
    await db.update(
      tableMenuItems,
      {columnPrice: newPrice},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Insertar un nuevo elemento en el menú
  Future<void> insertMenuItem(String name, int price) async {
    final db = await database;
    await db.insert(
      tableMenuItems,
      {columnName: name, columnPrice: price},
    );
  }

  // Eliminar un elemento del menú
  Future<void> deleteMenuItem(int id) async {
    final db = await database;
    await db.delete(
      tableMenuItems,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Obtener puntos de usuario
  Future<int> getUserPoints(String username) async {
    final db = await database;
    var result = await db.query(tableUserPoints, where: '$columnUsername = ?', whereArgs: [username]);
    if (result.isNotEmpty) {
      return result.first[columnPoints] as int;
    } else {
      await db.insert(tableUserPoints, {columnUsername: username, columnPoints: 0});
      return 0;
    }
  }

  // Actualizar puntos de usuario
  Future<void> updateUserPoints(String username, int points) async {
    final db = await database;
    await db.update(
      tableUserPoints,
      {columnPoints: points},
      where: '$columnUsername = ?',
      whereArgs: [username],
    );
  }

  // Registrar una transacción de canje
  Future<void> recordRedemptionTransaction(String username, String itemName, int cost) async {
    final db = await database;
    await db.insert(tableRedemptionTransactions, {
      columnUsername: username,
      columnItemName: itemName,
      columnCost: cost,
    });
  }
}
