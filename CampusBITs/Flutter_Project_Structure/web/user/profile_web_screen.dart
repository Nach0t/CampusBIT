import 'package:flutter/material.dart';

class ProfileWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario (Web)'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Perfil de Usuario - Versión Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
