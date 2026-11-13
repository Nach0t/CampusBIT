import 'package:flutter/material.dart';
import 'main_screen.dart';

class CompanySelectionScreen extends StatelessWidget {
  final String username;

  const CompanySelectionScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Empresa',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4682B4), // Celeste oscuro
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
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
                  style: const TextStyle(
                    fontFamily: 'Exo2',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/uss_logo.png', // Imagen representativa de USS
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        const Text(
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
                const SizedBox(height: 24),
                // Botón para Otra Empresa
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    // `const Column` no compila en Flutter 3.50 (assert de CrossAxisAlignment)
                    // ignore: prefer_const_constructors
                    child: Column(
                      children: const [
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
