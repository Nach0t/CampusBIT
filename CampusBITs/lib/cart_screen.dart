import 'package:flutter/material.dart';
import 'generate_qr_code_screen.dart'; // Importamos la pantalla de generación de QR

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Lista de productos en el carrito
  final String username;

  CartScreen({required this.cartItems, required this.username});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int? selectedOption;

  int getTotalPrice() {
    return widget.cartItems.fold(0, (sum, item) => sum + (item['price'] as int));
  }

  void _removeItem(int index) {
    setState(() {
      if (index >= 0 && index < widget.cartItems.length) {
        widget.cartItems.removeAt(index);
      }
    });
  }

  void _proceedToQR() async {
    if (widget.cartItems.isNotEmpty && selectedOption != null) {
      final totalPrice = getTotalPrice();

      // Calcular los puntos a otorgar
      final int earnedPoints = (totalPrice / 1000).floor() * 10;

      // Actualizar los puntos del usuario
      await _updateUserPoints(earnedPoints);

      // Navegar a la pantalla de generación de QR
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenerateQRCodeScreen(
            purchasedItems: widget.cartItems,
            lol: widget.username,
            pickupPoint: 'Cafeteria',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cartItems.isEmpty
                ? 'Por favor, agrega productos al carrito.'
                : 'Por favor, selecciona un método de pago.',
            style: TextStyle(fontFamily: 'Exo2'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _updateUserPoints(int earnedPoints) async {
    // Aquí puedes integrar con tu lógica para manejar los puntos
    // Por ejemplo, si tienes un DBHelper:
    /*
    final dbHelper = DBHelper();
    int currentPoints = await dbHelper.getUserPoints(widget.username);
    await dbHelper.updateUserPoints(widget.username, currentPoints + earnedPoints);
    */

    // Simulación de actualización en consola
    print('Se han agregado $earnedPoints puntos al usuario ${widget.username}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito de Compra',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo degradado celeste
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: widget.cartItems.isEmpty
                  ? Center(
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
                  : ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8), // Fondo blanco translúcido
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        '${item['name']} - \$${item['price']}',
                        style: TextStyle(
                          color: Color(0xFF4682B4),
                          fontSize: 18,
                          fontFamily: 'Exo2',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF5F9EA0), // Celeste oscuro para la sección inferior
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: \$${getTotalPrice()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo2',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selecciona un método de pago:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Exo2',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPaymentOption(1, 'assets/trasbank.png'),
                      _buildPaymentOption(2, 'assets/webpay.png'),
                      _buildPaymentOption(3, 'assets/MercadoLibre.png'),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _proceedToQR,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Color(0xFF4682B4), // Botón principal
                    ),
                    child: Text(
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int option, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedOption == option ? Color(0xFF4682B4) : Color(0xFF5F9EA0),
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
