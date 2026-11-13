import 'models.dart';

/// Operaciones de persistencia de CampusBIT.
///
/// Hay dos implementaciones con el mismo comportamiento:
/// - [SqliteAppDatabase] (Android/iOS, sqflite).
/// - [SembastAppDatabase] (Web, sembast sobre IndexedDB).
abstract class AppDatabase {
  // ---------- Menú ----------
  Future<List<MenuItem>> getMenuItems();

  /// Inserta el producto y devuelve su id.
  Future<int> insertMenuItem(MenuItem item);

  /// Actualiza nombre, precio, descripción e imágenes del producto [item.id].
  Future<void> updateMenuItem(MenuItem item);

  Future<void> deleteMenuItem(int id);

  // ---------- Códigos QR ----------
  Future<void> insertQrCodes(List<GeneratedQr> codes);
  Future<List<GeneratedQr>> getQrCodesForUser(String username);
  Future<void> deleteQrCode(String id);

  // ---------- Puntos y transacciones ----------
  /// Saldo actual (0 si el usuario aún no tiene registro).
  Future<int> getUserPoints(String username);

  /// Registra una compra y suma [pointsEarned] al saldo, de forma atómica.
  /// Devuelve el nuevo saldo.
  Future<int> recordPurchase({
    required String username,
    required int amount,
    required int pointsEarned,
    String description = 'Compra',
  });

  /// Canjea [cost] puntos. Si el saldo no alcanza no cambia nada y
  /// devuelve `false`. Todo ocurre dentro de una transacción.
  Future<bool> redeemPoints({
    required String username,
    required String itemName,
    required int cost,
  });

  /// Historial del usuario, del más reciente al más antiguo.
  Future<List<PointsTransaction>> getTransactions(String username);

  Future<void> close();
}

/// Productos con los que se crea una base nueva.
///
/// Precios y descripciones coinciden con lo que hoy muestra el menú.
const List<MenuItem> defaultMenuItems = [
  MenuItem(
    name: 'Promo desayuno',
    price: 1800,
    description: 'Desayuno con café.',
    images: ['assets/PromoDesayuno.png', 'assets/Cafe.png'],
  ),
  MenuItem(
    name: 'Promo almuerzo',
    price: 2500,
    description: 'Almuerzo con café.',
    images: ['assets/PromoAlmuerzo.png', 'assets/Cafe.png'],
  ),
  MenuItem(
    name: 'Almuerzo ejecutivo',
    price: 3500,
    description: 'Incluye consomé, plato fuerte, ensalada y jugo.',
    images: [
      'assets/Pollo.png',
      'assets/Consome.png',
      'assets/Jugo.png',
      'assets/Ensa.png',
    ],
  ),
  MenuItem(
    name: 'Menú Junaeb',
    price: 2800,
    description: 'Incluye consomé, plato fuerte y jugo.',
    images: ['assets/Pollo.png', 'assets/Consome.png', 'assets/Jugo.png'],
  ),
  MenuItem(
    name: 'Almuerzo normal',
    price: 3300,
    description: 'Incluye consomé, plato fuerte y jugo.',
    images: ['assets/Pollo.png', 'assets/Consome.png', 'assets/Jugo.png'],
  ),
  MenuItem(
    name: 'Hipocalórico',
    price: 3200,
    description: 'Bowl naturista a elección.',
    images: ['assets/Bawl.png'],
  ),
  MenuItem(
    name: 'Vegetariano',
    price: 3000,
    description: 'Hamburguesa de quinoa con arroz.',
    images: ['assets/Vegano.png'],
  ),
];
