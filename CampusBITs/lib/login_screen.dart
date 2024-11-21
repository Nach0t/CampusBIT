import 'package:flutter/material.dart';
import 'company_selection_screen.dart'; // Importamos la pantalla de selección de empresa

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      // Navegar a la pantalla de selección de empresa
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanySelectionScreen(username: username),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un usuario y contraseña válidos'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido a CambusBIT',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF71679C),
        centerTitle: true,
        elevation: 0,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/LogoAPP.png', // Ruta de tu logo
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24),
              Text(
                'Inicia sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Exo2',
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24),
              _buildTextField(
                controller: _usernameController,
                label: 'Usuario',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B3E96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  'Ingresar',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Exo2',
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontFamily: 'Exo2',
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Exo2',
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: isPassword,
    );
  }
}
