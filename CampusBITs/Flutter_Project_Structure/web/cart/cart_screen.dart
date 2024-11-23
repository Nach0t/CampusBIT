// Placeholder for cart/cart_screen.dart

import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Carrito de compras',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
