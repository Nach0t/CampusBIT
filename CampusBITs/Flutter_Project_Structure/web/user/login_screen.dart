// Placeholder for user/login_screen.dart

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Inicio de Sesión',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
