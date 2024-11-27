import 'package:flutter/material.dart';
import 'main_screen.dart';

class CompanySelectionScreen extends StatelessWidget {
  final String username;

  CompanySelectionScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Empresa',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Gradiente celeste agua
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido, $username. Por favor, selecciona la empresa a la que deseas acceder:',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Botón para USS
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainScreen(username: username),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/uss_logo.png', // Imagen representativa de USS
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4682B4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Botón para Otra Empresa
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Otra empresa no disponible actualmente',
                          style: TextStyle(fontFamily: 'Exo2'),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business,
                          size: 100,
                          color: Color(0xFF5F9EA0), // Celeste oscuro claro
                        ),
                        SizedBox(height: 8),
                        Text(
                          'OTRO',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5F9EA0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
