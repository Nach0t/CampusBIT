import 'package:flutter/material.dart';
import 'login_screen.dart'; // Asegúrate de importar la pantalla de login correctamente

class ProfileScreen extends StatelessWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo con gradiente
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Encabezado destacado
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Fondo translúcido
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // Imagen de perfil
                  ),
                  SizedBox(height: 16),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Opciones del menú
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildProfileOption(
                    icon: Icons.payment,
                    title: 'Métodos de Pago',
                    onTap: () {
                      // Acción para Métodos de Pago
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navegando a Métodos de Pago...')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Historial de Pedidos',
                    onTap: () {
                      // Acción para Historial de Pedidos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navegando a Historial de Pedidos...')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Configuraciones',
                    onTap: () {
                      // Acción para Configuraciones
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navegando a Configuraciones...')),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    onTap: () {
                      // Navegar a la pantalla de login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                            (Route<dynamic> route) => false, // Elimina el historial
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Fondo translúcido
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
