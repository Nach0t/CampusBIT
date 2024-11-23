// Placeholder for cart/punto_retiro_screen.dart

import 'package:flutter/material.dart';

class PuntoRetiroScreen extends StatelessWidget {
  final String username;
  final String localName;

  PuntoRetiroScreen({required this.username, required this.localName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Punto de Retiro'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Usuario: $username',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Local: $localName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
