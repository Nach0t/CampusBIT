import 'package:uuid/uuid.dart';

import '../data/app_database.dart';
import '../data/models.dart';
import 'cart.dart';

/// Tiempo durante el cual un QR de retiro es válido.
const Duration qrValidity = Duration(hours: 24);

/// Único punto de retiro: todo pedido (compra o canje) se retira en la
/// Cafetería, sin importar en qué local AE se hizo.
const String pickupPointName = 'Cafetería Principal';

/// Regla de puntos: 10 puntos por cada $1.000 de compra.
int pointsForAmount(int amount) => (amount ~/ 1000) * 10;

String _newUuid() => const Uuid().v4();

/// Resultado de una compra ya guardada.
class CheckoutResult {
  final List<GeneratedQr> codes;
  final int amount;
  final int pointsEarned;
  final int newBalance;

  const CheckoutResult({
    required this.codes,
    required this.amount,
    required this.pointsEarned,
    required this.newBalance,
  });
}

/// Paga el contenido del [cart]: genera un QR por unidad (para retirar en
/// [pickupPointName]) y guarda QR, puntos y movimiento en una sola
/// transacción. [localName] es el local AE donde se hizo el pedido.
///
/// No vacía el carrito: eso lo hace quien llama, solo si la compra se
/// guardó (así un error no hace perder el pedido).
Future<CheckoutResult> checkout({
  required AppDatabase db,
  required Cart cart,
  required String username,
  required String localName,
  DateTime? now,
  String Function() newId = _newUuid,
}) async {
  if (cart.isEmpty) {
    throw StateError('El carrito está vacío');
  }
  final validity = (now ?? DateTime.now()).add(qrValidity);
  final codes = [
    for (final line in cart.lines)
      for (var i = 0; i < line.quantity; i++)
        GeneratedQr(
          id: newId(),
          menuType: line.item.name,
          price: line.item.price,
          username: username,
          pickupPoint: pickupPointName,
          validity: validity,
        ),
  ];
  final amount = cart.total;
  final points = pointsForAmount(amount);
  final balance = await db.recordPurchase(
    username: username,
    amount: amount,
    pointsEarned: points,
    description: 'Compra en $localName (${cart.itemCount} '
        '${cart.itemCount == 1 ? 'producto' : 'productos'})',
    qrCodes: codes,
  );
  return CheckoutResult(
    codes: codes,
    amount: amount,
    pointsEarned: points,
    newBalance: balance,
  );
}

/// Premio que se puede canjear con puntos.
class Reward {
  final String name;
  final int cost;

  const Reward(this.name, this.cost);
}

/// Catálogo de canjes (los mismos que mostraba la pantalla de puntos).
const List<Reward> rewards = [
  Reward('Menú Junaeb', 700),
  Reward('Menú Ejecutivo', 1200),
  Reward('Ticket de compra por \$5.000', 4500),
];

/// Canjea [reward]: descuenta los puntos y genera un QR (precio 0) para
/// retirar el premio. Devuelve el QR, o `null` si el saldo no alcanza.
Future<GeneratedQr?> redeemReward({
  required AppDatabase db,
  required String username,
  required Reward reward,
  DateTime? now,
  String Function() newId = _newUuid,
}) async {
  final qr = GeneratedQr(
    id: newId(),
    menuType: 'Canje: ${reward.name}',
    price: 0,
    username: username,
    pickupPoint: pickupPointName,
    validity: (now ?? DateTime.now()).add(qrValidity),
  );
  final ok = await db.redeemPoints(
    username: username,
    itemName: reward.name,
    cost: reward.cost,
    qrCode: qr,
  );
  return ok ? qr : null;
}
