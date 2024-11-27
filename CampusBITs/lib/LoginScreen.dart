import 'package:flutter/material.dart';
import 'main_screen.dart'; // Importamos la pantalla principal
import 'edit_prices_screen.dart'; // Importamos la pantalla de edición de precios

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro para la barra
        elevation: 0,
        title: Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Celeste agua
              ),
            ),
          ),
          // Contenido del login
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono del usuario
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF87CEEB), width: 3.0),
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Campo de texto: Usuario
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          fontFamily: 'Exo2',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'USUARIO',
                          hintStyle: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: 'Exo2',
                          ),
                          filled: true,
                          fillColor: Color(0xFF4682B4), // Fondo celeste oscuro
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Campo de texto: Contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                          fontFamily: 'Exo2',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CONTRASEÑA',
                          hintStyle: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: 'Exo2',
                          ),
                          filled: true,
                          fillColor: Color(0xFF4682B4), // Fondo celeste oscuro
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Botón de ingresar
                      ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text == 'admin' &&
                              _passwordController.text == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPricesScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(username: _usernameController.text),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0), // Más grande
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: Color(0xFF4682B4), // Botón celeste oscuro
                          elevation: 5,
                        ),
                        child: Text(
                          'INGRESAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Pie de página
                      Text(
                        'Todos los derechos reservados para CampusBIT',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontFamily: 'Exo2',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
