import 'package:flutter/material.dart';
import 'admin_screen.dart';
import 'company_selection_screen.dart'; // Importamos la pantalla de selección de empresa

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _validateAndNavigate() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // Mostrar un mensaje de error si los campos están vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, ingresa un nombre de usuario y una contraseña.',
            style: TextStyle(fontFamily: 'Exo2'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else if (username == 'admin' && password == 'admin') {
      // Acceso de administración (credenciales de demo del prototipo)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminScreen()),
      );
    } else {
      // Navegar a la pantalla de selección de empresa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanySelectionScreen(
            username: username,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4682B4),
        elevation: 0,
        title: const Text(
          'Bienvenido a CampusBite',
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
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
                  margin: const EdgeInsets.only(top: 50.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const [
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
                      Image.asset(
                        'assets/LogoAPP.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      // Campo de texto: Usuario
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          fontFamily: 'Exo2',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'USUARIO',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Exo2',
                          ),
                          filled: true,
                          fillColor: const Color(0xFF5F9EA0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Campo de texto: Contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          fontFamily: 'Exo2',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CONTRASEÑA',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Exo2',
                          ),
                          filled: true,
                          fillColor: const Color(0xFF5F9EA0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón de ingresar
                      ElevatedButton(
                        onPressed: _validateAndNavigate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor: const Color(0xFF4682B4),
                          elevation: 5,
                        ),
                        child: const Text(
                          'INGRESAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Exo2',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Todos los derechos reservados para CampusBite',
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
