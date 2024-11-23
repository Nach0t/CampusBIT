// Placeholder for locales/menu_screen.dart

import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Menú',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
