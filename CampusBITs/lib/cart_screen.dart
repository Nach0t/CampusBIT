import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'logic/cart.dart';
import 'logic/checkout.dart';
import 'qr_codes_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

/// Métodos de pago disponibles (el pago en sí es simulado en el prototipo).
const _paymentOptions = [
  (id: 1, name: 'Transbank', image: 'assets/trasbank.png'),
  (id: 2, name: 'WebPay', image: 'assets/webpay.png'),
  (id: 3, name: 'Mercado Pago', image: 'assets/MercadoLibre.png'),
];

class CartScreen extends StatefulWidget {
  final Cart cart;
  final String username;
  final String pickupPoint;

  const CartScreen({
    super.key,
    required this.cart,
    required this.username,
    required this.pickupPoint,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int? selectedOption;
  bool _paying = false;

  Cart get cart => widget.cart;

  Future<void> _pay() async {
    if (_paying) return; // Evita pagar dos veces con un doble toque
    if (cart.isEmpty || selectedOption == null) {
      showAppMessage(
        context,
        cart.isEmpty
            ? 'Por favor, agrega productos al carrito.'
            : 'Por favor, selecciona un método de pago.',
        type: MessageType.error,
      );
      return;
    }

    setState(() => _paying = true);
    try {
      final db = await DBHelper.database;
      final result = await checkout(
        db: db,
        cart: cart,
        username: widget.username,
        pickupPoint: widget.pickupPoint,
      );
      // La compra ya quedó guardada: recién ahora se vacía el carrito.
      cart.clear();
      if (!mounted) return;
      // Se reemplaza el carrito por los QR para que "atrás" no vuelva a un
      // carrito ya pagado.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QrCodesScreen(
            username: widget.username,
            newCodes: result.codes,
            message: '¡Compra realizada por ${formatPrice(result.amount)}! '
                'Ganaste ${result.pointsEarned} puntos '
                '(saldo: ${result.newBalance}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      showAppMessage(context, 'No se pudo completar la compra: $e',
          type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Compra')),
      body: AppBackground(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) => cart.isEmpty
              ? MessageView(
                  icon: Icons.remove_shopping_cart_outlined,
                  message: 'Tu carrito está vacío.',
                  actionLabel: 'Volver al menú',
                  onAction: () => Navigator.pop(context),
                )
              : ContentWidth(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final line in cart.lines) _buildLine(line),
                    ],
                  ),
                ),
        ),
      ),
      // En bottomNavigationBar los avisos flotantes aparecen encima del
      // panel y nunca tapan el botón "Pagar".
      bottomNavigationBar: ListenableBuilder(
        listenable: cart,
        builder: (context, _) =>
            cart.isEmpty ? const SizedBox.shrink() : _buildSummary(),
      ),
    );
  }

  Widget _buildLine(CartLine line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.item.name,
                      style: const TextStyle(
                        color: AppColors.texto,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPrice(line.item.price)} c/u · '
                      'Subtotal: ${formatPrice(line.subtotal)}',
                      style: const TextStyle(color: AppColors.textoSecundario),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Quitar uno',
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.celesteOscuro,
                onPressed: _paying ? null : () => cart.decrement(line.item),
              ),
              Text(
                '${line.quantity}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: 'Agregar uno',
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.celesteOscuro,
                onPressed: _paying ? null : () => cart.add(line.item),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                onPressed: _paying ? null : () => cart.remove(line.item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final points = pointsForAmount(cart.total);
    return Material(
      color: AppColors.petroleo,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Solo el alto necesario
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ${formatPrice(cart.total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Retiro en ${widget.pickupPoint} · Ganarás $points puntos',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecciona un método de pago:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final option in _paymentOptions)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildPaymentOption(
                              option.id, option.name, option.image),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _paying ? null : _pay,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.celesteOscuro,
                  ),
                  child: _paying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Pagar', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int option, String name, String imagePath) {
    final selected = selectedOption == option;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        onTap: _paying
            ? null
            : () {
                // Cierra el aviso "selecciona un método de pago".
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                setState(() => selectedOption = option);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.celesteOscuro : Colors.transparent,
              width: 3,
            ),
          ),
          child: Stack(
            children: [
              Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
              if (selected)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.check_circle,
                      color: AppColors.celesteOscuro, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
