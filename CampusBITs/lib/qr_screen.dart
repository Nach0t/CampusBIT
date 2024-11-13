import 'package:flutter/material.dart';

class QRScreen extends StatelessWidget {
  final String menuType;
  final String username;

  QRScreen({required this.menuType, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71679C), Color(0xFF44337A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tipo de menú: $menuType',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 16),
              Image.asset('assets/qr_code.png', height: 200),
              SizedBox(height: 16),
              Text(
                'Nombre de la persona: $username',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
