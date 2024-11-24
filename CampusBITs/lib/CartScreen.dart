import 'package:flutter/material.dart';
import 'qr_screen.dart';

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
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF87CEFA), // Celeste agua (color principal del AppBar)
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Gradiente de celeste agua
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8), // Fondo semitransparente
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Producto:',
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.menuItem,
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Precio:',
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${widget.price}',
                      style: TextStyle(
                        fontFamily: 'Exo2',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 24),
                    Column(
                      children: [
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
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: selectedOption != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRScreen(
                                    menuType: widget.menuItem,
                                    username: widget.username,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        backgroundColor: Color(0xFF87CEEB), // Celeste agua para el botón
                      ),
                      child: Text(
                        'PAGAR',
                        style: TextStyle(
                          fontFamily: 'Exo2',
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedOption == option ? Color(0xFF87CEEB) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
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
}
