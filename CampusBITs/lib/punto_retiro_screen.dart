import 'package:flutter/material.dart';
import 'MenuScreen.dart';
import 'dart:math';

class PuntoRetiroScreen extends StatelessWidget {
  final String username;

  PuntoRetiroScreen({required this.username});

  String _calcularTiempoEspera() {
    // Obtener la hora actual
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 13 && hour < 14) {
      return '20-30 minutos (mayor tiempo de espera entre 13:00 y 14:00)';
    } else {
      return '${Random().nextInt(10) + 5}-${Random().nextInt(15) + 10} minutos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Punto de Retiro',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF5B3E96), // Morado más oscuro
        elevation: 5.0,
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
                'Punto de retiro:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildLocalCard('Cafeteria'),
              SizedBox(height: 24),
              Text(
                'Tiempo de espera aproximado:',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _calcularTiempoEspera(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuScreen(username: username),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Color(0xFF5B3E96),
                ),
                child: Text(
                  'Ver Productos',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalCard(String localName) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        localName,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5B3E96),
        ),
      ),
    );
  }
}
