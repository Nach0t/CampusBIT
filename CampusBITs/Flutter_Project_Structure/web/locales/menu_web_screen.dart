import 'package:flutter/material.dart';

class MenuWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú (Web)'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Menú - Versión Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
