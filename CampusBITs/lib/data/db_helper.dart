import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'database_opener_io.dart'
    if (dart.library.js_interop) 'database_opener_web.dart' as platform;

export 'app_database.dart';
export 'models.dart';

/// Punto de acceso único a la base de datos de la app.
///
/// ```dart
/// final db = await DBHelper.database;
/// final menu = await db.getMenuItems();
/// ```
///
/// Elige automáticamente SQLite (Android/iOS) o sembast (Web).
class DBHelper {
  DBHelper._();

  static AppDatabase? _database;
  static Future<AppDatabase>? _opening;

  static Future<AppDatabase> get database async {
    final db = _database;
    if (db != null) return db;
    // Si dos pantallas piden la base a la vez, ambas esperan la misma
    // apertura en lugar de abrirla dos veces.
    _opening ??= platform.openPlatformDatabase();
    try {
      return _database = await _opening!;
    } catch (_) {
      _opening = null; // Permite reintentar si la apertura falló
      rethrow;
    }
  }

  /// Reemplaza la base por otra (por ejemplo, una en memoria en los tests).
  @visibleForTesting
  static void useDatabase(AppDatabase? database) {
    _database = database;
    _opening = null;
  }
}
