import 'package:flutter/material.dart';

class LocalesWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locales (Web)'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: Text(
          'Pantalla de Locales - Versión Web',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
