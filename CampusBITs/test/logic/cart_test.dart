import 'package:campus_bit_app/data/models.dart';
import 'package:campus_bit_app/logic/cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const almuerzo = MenuItem(id: 1, name: 'Almuerzo normal', price: 3300);
  const promo = MenuItem(id: 2, name: 'Promo desayuno', price: 1800);

  late Cart cart;
  var notifications = 0;

  setUp(() {
    cart = Cart();
    notifications = 0;
    cart.addListener(() => notifications++);
  });

  test('empieza vacío', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.total, 0);
    expect(cart.itemCount, 0);
  });

  test('agregar el mismo producto aumenta la cantidad', () {
    cart.add(almuerzo);
    cart.add(almuerzo);
    cart.add(promo);

    expect(cart.lines, hasLength(2));
    expect(cart.quantityOf(almuerzo), 2);
    expect(cart.itemCount, 3);
    expect(cart.total, 3300 * 2 + 1800);
    expect(cart.lines.first.subtotal, 6600);
    expect(notifications, 3);
  });

  test('decrement quita una unidad y la línea al llegar a cero', () {
    cart.add(almuerzo);
    cart.add(almuerzo);

    cart.decrement(almuerzo);
    expect(cart.quantityOf(almuerzo), 1);

    cart.decrement(almuerzo);
    expect(cart.isEmpty, isTrue);
    expect(cart.total, 0);
  });

  test('remove elimina la línea completa', () {
    cart.add(almuerzo);
    cart.add(almuerzo);
    cart.add(promo);

    cart.remove(almuerzo);
    expect(cart.quantityOf(almuerzo), 0);
    expect(cart.total, 1800);
  });

  test('operaciones sobre productos ausentes no notifican', () {
    cart.decrement(promo);
    cart.remove(promo);
    cart.clear();
    expect(notifications, 0);
  });

  test('clear vacía el carrito', () {
    cart.add(almuerzo);
    cart.clear();
    expect(cart.isEmpty, isTrue);
  });

  test('las líneas no se pueden modificar desde fuera', () {
    cart.add(almuerzo);
    expect(() => cart.lines.clear(), throwsUnsupportedError);
  });
}
