import 'package:flutter/material.dart';
import 'punto_retiro_screen.dart';

class LocalesScreen extends StatelessWidget {
  final String username;

  LocalesScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locales USS',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Bienvenido, por favor selecciona un punto de distribución de Alimento Express para comprar tu ticket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Seleccione un local:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                _buildLocalButton(context, 'Estacionamiento'),
                _buildLocalButton(context, 'Carpa'),
                _buildLocalButton(context, 'Hall'),
                _buildLocalButton(context, 'Cafeteria'),
                _buildLocalButton(context, 'Sala de Profe'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalButton(BuildContext context, String localName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 250, // Tamaño consistente para todos los botones
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PuntoRetiroScreen(username: username),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            backgroundColor: Color(0xFF5B3E96),
            elevation: 5.0,
          ),
          child: Text(
            localName,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
