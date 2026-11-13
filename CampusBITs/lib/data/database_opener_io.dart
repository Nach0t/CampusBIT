import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'sqlite_app_database.dart';

/// Android/iOS: SQLite en el directorio de bases de datos de la app.
///
/// Se mantiene el nombre de archivo original para conservar los datos
/// existentes.
Future<AppDatabase> openPlatformDatabase() async {
  final path = join(await getDatabasesPath(), 'menu_database.db');
  return SqliteAppDatabase.open(databaseFactory, path);
}
