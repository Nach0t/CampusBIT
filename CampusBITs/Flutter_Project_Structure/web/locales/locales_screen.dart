// Placeholder for locales/locales_screen.dart

import 'package:flutter/material.dart';

class LocalesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locales'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Locales',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
