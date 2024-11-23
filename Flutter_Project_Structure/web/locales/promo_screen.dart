// Placeholder for locales/promo_screen.dart

import 'package:flutter/material.dart';

class PromoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promociones'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Promociones',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
