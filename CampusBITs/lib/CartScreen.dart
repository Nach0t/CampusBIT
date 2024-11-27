import 'package:flutter/material.dart';
import 'QrHistoryScreen.dart';

class CartScreen extends StatefulWidget {
  final String menuItem;
  final int price;
  final String username;

  CartScreen({required this.menuItem, required this.price, required this.username});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int? selectedOption;

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
        centerTitle: true,
        backgroundColor: Color(0xFF87CEEB), // Celeste agua
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoText('Producto:', widget.menuItem, 22, 28),
                        SizedBox(height: 24),
                        _buildInfoText('Precio:', '\$${widget.price}', 22, 28),
                        SizedBox(height: 24),
                        Text(
                          'Selecciona un método de pago:',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOption(1, 'assets/trasbank.png'),
                            _buildOption(2, 'assets/webpay.png'),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildOption(3, 'assets/MercadoLibre.png'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedOption != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrHistoryScreen(username: widget.username),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: selectedOption != null
                      ? Color(0xFF4682B4)
                      : Colors.grey, // Botón deshabilitado si no hay opción seleccionada
                  elevation: 5,
                ),
                child: Text(
                  'PAGAR',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int option, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: selectedOption == option ? Color(0xFF4682B4) : Colors.white,
          border: Border.all(
            color: selectedOption == option ? Color(0xFF4682B4) : Color(0xFFB0E0E6),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          imagePath,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value, double labelSize, double valueSize) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Exo2',
            fontSize: labelSize,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Exo2',
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
