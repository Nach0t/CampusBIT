import 'package:sembast_web/sembast_web.dart';

import 'app_database.dart';
import 'sembast_app_database.dart';

/// Web: sembast sobre IndexedDB. Se mantiene el nombre original de la base
/// para conservar (y migrar) los datos existentes del navegador.
Future<AppDatabase> openPlatformDatabase() {
  return SembastAppDatabase.open(databaseFactoryWeb, 'menu_database_web');
}
