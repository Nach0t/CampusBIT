import 'package:flutter/foundation.dart';

import '../data/models.dart';

/// Una línea del carrito: un producto y cuántas unidades se llevan.
class CartLine {
  final MenuItem item;
  final int quantity;

  const CartLine(this.item, this.quantity);

  int get subtotal => item.price * quantity;
}

/// Carrito de compra. Notifica a la interfaz cada vez que cambia.
///
/// Los productos se identifican por su id; el precio queda fijado al
/// momento de agregarlos.
class Cart extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;

  /// Cantidad total de unidades.
  int get itemCount => _lines.fold(0, (sum, line) => sum + line.quantity);

  /// Total a pagar en pesos.
  int get total => _lines.fold(0, (sum, line) => sum + line.subtotal);

  int quantityOf(MenuItem item) {
    final i = _indexOf(item);
    return i == -1 ? 0 : _lines[i].quantity;
  }

  void add(MenuItem item) {
    final i = _indexOf(item);
    if (i == -1) {
      _lines.add(CartLine(item, 1));
    } else {
      _lines[i] = CartLine(_lines[i].item, _lines[i].quantity + 1);
    }
    notifyListeners();
  }

  /// Quita una unidad; si era la última, elimina la línea.
  void decrement(MenuItem item) {
    final i = _indexOf(item);
    if (i == -1) return;
    final line = _lines[i];
    if (line.quantity <= 1) {
      _lines.removeAt(i);
    } else {
      _lines[i] = CartLine(line.item, line.quantity - 1);
    }
    notifyListeners();
  }

  void remove(MenuItem item) {
    final i = _indexOf(item);
    if (i == -1) return;
    _lines.removeAt(i);
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }

  int _indexOf(MenuItem item) => _lines.indexWhere((line) => item.id != null
      ? line.item.id == item.id
      : line.item.name == item.name);
}
