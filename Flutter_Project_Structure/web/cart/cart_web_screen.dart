import 'package:flutter/material.dart';

class CartWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito (Web)'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Carrito de compras - Versión Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
