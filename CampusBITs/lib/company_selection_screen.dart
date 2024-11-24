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
        backgroundColor: Color(0xFF87CEEB), // Celeste agua
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Degradado celeste agua
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
                  'Bienvenido, $username.\nPor favor, selecciona la empresa a la que deseas acceder:',
                  style: TextStyle(
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
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
                          'USS',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF5B3E96), // Color púrpura USS
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Otra empresa no disponible actualmente'),
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
                          color: Color(0xFF5B3E96), // Color púrpura USS
                        ),
                        SizedBox(height: 8),
                        Text(
                          'OTRO',
                          style: TextStyle(
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF5B3E96), // Color púrpura USS
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
