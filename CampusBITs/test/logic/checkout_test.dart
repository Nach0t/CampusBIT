import 'package:campus_bit_app/data/app_database.dart';
import 'package:campus_bit_app/data/models.dart';
import 'package:campus_bit_app/data/sembast_app_database.dart';
import 'package:campus_bit_app/logic/cart.dart';
import 'package:campus_bit_app/logic/checkout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  const almuerzo = MenuItem(id: 1, name: 'Almuerzo normal', price: 3300);
  const promo = MenuItem(id: 2, name: 'Promo desayuno', price: 1800);
  final now = DateTime(2026, 3, 10, 12, 30);

  late AppDatabase db;
  late Cart cart;
  var nextId = 0;
  String fakeId() => 'id-${nextId++}';

  setUp(() async {
    db = await SembastAppDatabase.open(newDatabaseFactoryMemory(), 'test');
    cart = Cart();
    nextId = 0;
  });
  tearDown(() => db.close());

  group('pointsForAmount', () {
    test('10 puntos por cada \$1.000 completos', () {
      expect(pointsForAmount(0), 0);
      expect(pointsForAmount(999), 0);
      expect(pointsForAmount(1000), 10);
      expect(pointsForAmount(8400), 80);
    });
  });

  group('checkout', () {
    test('genera un QR por unidad, una sola vez, con 24 h de vigencia',
        () async {
      cart
        ..add(almuerzo)
        ..add(almuerzo)
        ..add(promo);

      final result = await checkout(
        db: db,
        cart: cart,
        username: 'ana',
        pickupPoint: 'Hall',
        now: now,
        newId: fakeId,
      );

      expect(result.codes, hasLength(3));
      expect(result.codes.map((q) => q.menuType),
          ['Almuerzo normal', 'Almuerzo normal', 'Promo desayuno']);
      expect(result.codes.every((q) => q.pickupPoint == 'Hall'), isTrue);
      expect(result.codes.every((q) => q.validity == now.add(qrValidity)),
          isTrue);
      expect(result.codes.map((q) => q.id).toSet(), hasLength(3));

      final saved = await db.getQrCodesForUser('ana');
      expect(saved.map((q) => q.id).toSet(), {'id-0', 'id-1', 'id-2'});
    });

    test('suma los puntos y registra la compra', () async {
      cart
        ..add(almuerzo)
        ..add(almuerzo)
        ..add(promo); // 8.400 -> 80 puntos

      final result = await checkout(
          db: db, cart: cart, username: 'ana', pickupPoint: 'Hall');

      expect(result.amount, 8400);
      expect(result.pointsEarned, 80);
      expect(result.newBalance, 80);
      expect(await db.getUserPoints('ana'), 80);

      final tx = (await db.getTransactions('ana')).single;
      expect(tx.type, TransactionType.purchase);
      expect(tx.amount, 8400);
      expect(tx.points, 80);
    });

    test('no vacía el carrito (lo hace la pantalla tras guardar)', () async {
      cart.add(almuerzo);
      await checkout(db: db, cart: cart, username: 'ana', pickupPoint: 'Hall');
      expect(cart.itemCount, 1);
    });

    test('con el carrito vacío no guarda nada', () async {
      await expectLater(
        checkout(db: db, cart: cart, username: 'ana', pickupPoint: 'Hall'),
        throwsStateError,
      );
      expect(await db.getQrCodesForUser('ana'), isEmpty);
      expect(await db.getTransactions('ana'), isEmpty);
    });

    test('si falla al guardar no quedan QR ni puntos a medias', () async {
      // Fuerza un id repetido: el segundo QR choca con el primero.
      cart
        ..add(almuerzo)
        ..add(almuerzo);
      await expectLater(
        checkout(
          db: db,
          cart: cart,
          username: 'ana',
          pickupPoint: 'Hall',
          newId: () => 'mismo-id',
        ),
        throwsA(anything),
      );
      expect(await db.getQrCodesForUser('ana'), isEmpty);
      expect(await db.getUserPoints('ana'), 0);
      expect(cart.itemCount, 2); // el pedido se conserva para reintentar
    });
  });

  group('redeemReward', () {
    const reward = Reward('Menú Junaeb', 700);

    test('sin saldo suficiente no descuenta ni genera QR', () async {
      await db.recordPurchase(username: 'ana', amount: 60000, pointsEarned: 600);

      final qr = await redeemReward(db: db, username: 'ana', reward: reward);

      expect(qr, isNull);
      expect(await db.getUserPoints('ana'), 600);
      expect(await db.getQrCodesForUser('ana'), isEmpty);
    });

    test('con saldo descuenta, registra y entrega un QR sin costo', () async {
      await db.recordPurchase(username: 'ana', amount: 80000, pointsEarned: 800);

      final qr = await redeemReward(
          db: db, username: 'ana', reward: reward, now: now, newId: fakeId);

      expect(qr, isNotNull);
      expect(qr!.price, 0);
      expect(qr.menuType, 'Canje: Menú Junaeb');
      expect(qr.validity, now.add(qrValidity));
      expect(await db.getUserPoints('ana'), 100);
      expect((await db.getQrCodesForUser('ana')).single.id, qr.id);

      final last = (await db.getTransactions('ana')).first;
      expect(last.type, TransactionType.redemption);
      expect(last.points, -700);
    });

    test('el catálogo de canjes mantiene las opciones originales', () {
      expect(rewards.map((r) => r.cost), [700, 1200, 4500]);
    });
  });
}
