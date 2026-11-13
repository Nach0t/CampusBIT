import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'logic/cart.dart';
import 'logic/checkout.dart';
import 'qr_codes_screen.dart';

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
      _showError(cart.isEmpty
          ? 'Por favor, agrega productos al carrito.'
          : 'Por favor, selecciona un método de pago.');
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
            message: '¡Compra realizada por \$${result.amount}! '
                'Ganaste ${result.pointsEarned} puntos '
                '(saldo: ${result.newBalance}).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      _showError('No se pudo completar la compra: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Exo2')),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrito de Compra',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4682B4), // Celeste oscuro
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo degradado celeste
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) => Column(
            children: [
              Expanded(
                child: cart.isEmpty
                    ? const Center(
                        child: Text(
                          'Tu carrito está vacío.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        children: [
                          for (final line in cart.lines) _buildLine(line),
                        ],
                      ),
              ),
              _buildSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(CartLine line) {
    return Card(
      color: Colors.white.withValues(alpha: 0.8), // Fondo blanco translúcido
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.item.name,
                    style: const TextStyle(
                      color: Color(0xFF4682B4),
                      fontSize: 18,
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${line.item.price} c/u · Subtotal: \$${line.subtotal}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Quitar uno',
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFF4682B4),
              onPressed: _paying ? null : () => cart.decrement(line.item),
            ),
            Text(
              '${line.quantity}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Agregar uno',
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFF4682B4),
              onPressed: _paying ? null : () => cart.add(line.item),
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _paying ? null : () => cart.remove(line.item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final points = pointsForAmount(cart.total);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5F9EA0), // Celeste oscuro para la sección inferior
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total: \$${cart.total}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Exo2',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Retiro en ${widget.pickupPoint} · Ganarás $points puntos',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona un método de pago:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Exo2',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaymentOption(1, 'assets/trasbank.png'),
                _buildPaymentOption(2, 'assets/webpay.png'),
                _buildPaymentOption(3, 'assets/MercadoLibre.png'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _paying || cart.isEmpty ? null : _pay,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: const Color(0xFF4682B4), // Botón principal
              ),
              child: _paying
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      'Pagar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Exo2',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int option, String imagePath) {
    return GestureDetector(
      onTap: _paying
          ? null
          : () {
              // Cierra el aviso "selecciona un método de pago", que tapa
              // el botón "Pagar".
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              setState(() {
                selectedOption = option;
              });
            },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedOption == option
              ? const Color(0xFF4682B4)
              : const Color(0xFF5F9EA0),
          border: Border.all(
            color: selectedOption == option ? Colors.white : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Image.asset(
          imagePath,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
