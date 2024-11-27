import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal(); // Singleton
  factory DBHelper() => _instance;
  DBHelper._internal(); // Constructor privado

  static DBHelper get instance => _instance; // Getter para acceder al singleton

  static dynamic _database; // Base de datos puede ser de tipo sqflite o sembast
  static final _store = StoreRef.main(); // Para Sembast (Web)

  Future<dynamic> get database async {
    if (_database != null) return _database;
    _database = await _initDB();
    return _database!;
  }

  Future<dynamic> _initDB() async {
    if (kIsWeb) {
      // Base de datos para web (Sembast)
      final factory = databaseFactoryWeb;
      final db = await factory.openDatabase('menu_database_web');
      await _insertDefaultMenuItems(db); // Cargar datos predeterminados
      return db;
    } else {
      // Base de datos para móvil/escritorio (Sqflite)
      sqfliteFfiInit(); // Necesario para escritorio
      String path = join(await getDatabasesPath(), 'menu_database.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          await _createTables(db);
          await _insertDefaultMenuItems(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createGeneratedQrTable(db);
          }
        },
      );
    }
  }

  Future<void> _createTables(dynamic db) async {
    if (!kIsWeb) {
      await db.execute('''
        CREATE TABLE menu_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price INTEGER NOT NULL,
          images TEXT NOT NULL
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
      await _createGeneratedQrTable(db);
    }
  }

  Future<void> _createGeneratedQrTable(dynamic db) async {
    if (!kIsWeb) {
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
    }
  }

  Future<void> _insertDefaultMenuItems(dynamic db) async {
    final defaultItems = [
      {
        'name': 'Promo desayuno',
        'price': 1800,
        'images': '["assets/PromoDesayuno.png", "assets/Cafe.png"]'
      },
      {
        'name': 'Promo almuerzo',
        'price': 2500,
        'images': '["assets/PromoAlmuerzo.png", "assets/Cafe.png"]'
      },
      {
        'name': 'Almuerzo ejecutivo',
        'price': 3500,
        'images': '["assets/Pollo.png", "assets/Consome.png", "assets/Ensalada.png", "assets/Jugo.png"]'
      },
      {
        'name': 'Menú Junaeb',
        'price': 2800,
        'images': '["assets/Pollo.png", "assets/Consome.png", "assets/Jugo.png"]'
      },
      {
        'name': 'Almuerzo normal',
        'price': 3300,
        'images': '["assets/Pollo.png", "assets/Consome.png", "assets/Jugo.png"]'
      },
      {
        'name': 'Hipocalórico',
        'price': 1800,
        'images': '["assets/Bawl.png"]'
      },
      {
        'name': 'Vegetariano',
        'price': 3000,
        'images': '[]'
      },
    ];

    if (kIsWeb) {
      for (var item in defaultItems) {
        final existingRecord = await _store.record(item['name']).get(db);
        if (existingRecord == null) {
          await _store.record(item['name']).put(db, item);
        }
      }
    } else {
      for (var item in defaultItems) {
        final existingRecords = await db.query(
          'menu_items',
          where: 'name = ?',
          whereArgs: [item['name']],
        );
        if (existingRecords.isEmpty) {
          await db.insert('menu_items', item);
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await database;
    if (kIsWeb) {
      final records = await _store.find(db);
      return records.map((record) => record.value as Map<String, dynamic>).toList();
    } else {
      final data = await db.query('menu_items');
      return data.map((item) {
        item['images'] = (item['images'] as String).isNotEmpty
            ? List<String>.from(item['images']
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(','))
            : [];
        return item;
      }).toList();
    }
  }

  Future<void> insertMenuItem(String name, int price, String images) async {
    final db = await database;
    final item = {'name': name, 'price': price, 'images': images};
    if (kIsWeb) {
      await _store.record(name).put(db, item);
    } else {
      await db.insert('menu_items', item);
    }
  }

  Future<void> deleteMenuItem(int id) async {
    final db = await database;
    if (kIsWeb) {
      final finder = Finder(filter: Filter.byKey(id));
      await _store.delete(db, finder: finder);
    } else {
      await db.delete(
        'menu_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> updateMenuItem(int id, int newPrice, [String? newName]) async {
    final db = await database;
    final updateData = {'price': newPrice};
    if (newName != null) updateData['name'];
    if (kIsWeb) {
      final finder = Finder(filter: Filter.byKey(id));
      final recordSnapshot = await _store.findFirst(db, finder: finder);
      if (recordSnapshot != null) {
        await _store.record(recordSnapshot.key).put(db, updateData);
      }
    } else {
      await db.update(
        'menu_items',
        updateData,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getGeneratedQr() async {
    final db = await database;
    if (kIsWeb) {
      final records = await _store.find(db);
      return records.map((record) => record.value as Map<String, dynamic>).toList();
    } else {
      return await db.query('generated_qr');
    }
  }

  Future<void> insertGeneratedQr(Map<String, dynamic> qrData) async {
    final db = await database;
    if (kIsWeb) {
      await _store.record(qrData['id']).put(db, qrData);
    } else {
      qrData['price'] = qrData['price'] is String
          ? int.tryParse(qrData['price']) ?? 0
          : qrData['price'];
      await db.insert('generated_qr', qrData);
    }
  }

  Future<void> deleteQrById(String qrId) async {
    final db = await database;
    if (kIsWeb) {
      final finder = Finder(filter: Filter.byKey(qrId));
      await _store.delete(db, finder: finder);
    } else {
      await db.delete(
        'generated_qr',
        where: 'id = ?',
        whereArgs: [qrId],
      );
    }
  }

  Future<int> getUserPoints(String username) async {
    final db = await database;
    if (kIsWeb) {
      final finder = Finder(filter: Filter.equals('username', username));
      final record = await _store.findFirst(db, finder: finder);
      if (record != null) {
        return (record.value as Map<String, dynamic>)['points'];
      } else {
        await _store.record(username).put(db, {'points': 0});
        return 0;
      }
    } else {
      var result = await db.query('user_points', where: 'username = ?', whereArgs: [username]);
      if (result.isNotEmpty) {
        return result.first['points'] as int;
      } else {
        await db.insert('user_points', {'username': username, 'points': 0});
        return 0;
      }
    }
  }

  Future<void> updateUserPoints(String username, int points) async {
    final db = await database;
    if (kIsWeb) {
      await _store.record(username).put(db, {'points': points});
    } else {
      await db.update(
        'user_points',
        {'points': points},
        where: 'username = ?',
        whereArgs: [username],
      );
    }
  }

  Future<void> recordRedemptionTransaction(String username, String itemName, int cost) async {
    final db = await database;
    if (kIsWeb) {
      final record = {
        'username': username,
        'item_name': itemName,
        'cost': cost,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _store.record(username + itemName).put(db, record);
    } else {
      await db.insert('redemption_transactions', {
        'username': username,
        'item_name': itemName,
        'cost': cost,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getQrForUser(String username) async {
    final db = await database;
    if (kIsWeb) {
      final finder = Finder(filter: Filter.equals('username', username));
      final records = await _store.find(db, finder: finder);
      return records.map((record) => record.value as Map<String, dynamic>).toList();
    } else {
      return await db.query(
        'generated_qr',
        where: 'username = ?',
        whereArgs: [username],
      );
    }
  }

  // Nuevas funciones
  Future<void> addPurchasePoints(String username, int purchaseAmount) async {
    final db = await database;
    int pointsToAdd = (purchaseAmount / 1000).floor() * 10;

    if (kIsWeb) {
      final existingRecord = await _store.record(username).get(db);
      int currentPoints = existingRecord != null
          ? (existingRecord as Map<String, dynamic>)['points'] ?? 0
          : 0;

      await _store.record(username).put(db, {'points': currentPoints + pointsToAdd});
    } else {
      final existingRecords = await db.query(
        'user_points',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (existingRecords.isNotEmpty) {
        int currentPoints = existingRecords.first['points'] as int;
        await db.update(
          'user_points',
          {'points': currentPoints + pointsToAdd},
          where: 'username = ?',
          whereArgs: [username],
        );
      } else {
        await db.insert('user_points', {'username': username, 'points': pointsToAdd});
      }
    }
  }

  Future<void> recordPurchaseTransaction(String username, int purchaseAmount) async {
    final db = await database;

    if (kIsWeb) {
      final transactionRecord = {
        'username': username,
        'purchaseAmount': purchaseAmount,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _store.record('$username-purchase-${DateTime.now().toIso8601String()}').put(db, transactionRecord);
    } else {
      await db.insert('redemption_transactions', {
        'username': username,
        'item_name': 'Purchase',
        'cost': purchaseAmount,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }
}
