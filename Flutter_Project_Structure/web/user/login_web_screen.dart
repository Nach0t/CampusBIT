import 'package:flutter/material.dart';

class LoginWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión (Web)'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Inicio de Sesión - Versión Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
