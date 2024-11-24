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

  void _proceedToQR() {
    if (widget.cartItems.isNotEmpty && selectedOption != null) {
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
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
        backgroundColor: Color(0xFF87CEEB), // Celeste agua
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Card(
                  color: Colors.white.withOpacity(0.1),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ListTile(
                    title: Text(
                      '${item['name']} - \$${item['price']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Exo2',
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
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
            color: Colors.grey[800],
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: \$${getTotalPrice()}',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Selecciona un método de pago:',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPaymentOption(1, 'assets/trasbank.png'),
                    _buildPaymentOption(2, 'assets/webpay.png'),
                    _buildPaymentOption(3, 'assets/MercadoLibre.png'),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _proceedToQR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF87CEEB), // Celeste agua
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(
                    'Pagar',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Exo2',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          color: selectedOption == option ? Color(0xFF87CEEB) : Colors.grey[800],
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
