// Placeholder for android/user/profile_screen.dart

import 'package:flutter/material.dart';
import 'login_screen.dart'; // Ruta ajustada según la estructura de tu proyecto

class ProfileScreen extends StatelessWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario'),
        backgroundColor: Color(0xFF5B3E96), // Color principal de la barra de navegación
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SizedBox(height: 20),
          // Avatar del usuario
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'), // Imagen de perfil predeterminada
            ),
          ),
          SizedBox(height: 20),
          // Nombre de usuario
          Center(
            child: Text(
              username,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 20),
          // Opciones del usuario
          _buildListTile(
            context,
            icon: Icons.payment,
            title: 'Métodos de Pago',
            onTap: () {
              // Acción para métodos de pago
            },
          ),
          _buildListTile(
            context,
            icon: Icons.history,
            title: 'Historial de Pedidos',
            onTap: () {
              // Acción para historial de pedidos
            },
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Configuraciones',
            onTap: () {
              // Acción para configuraciones
            },
          ),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              // Navegar a la pantalla de inicio de sesión
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (Route<dynamic> route) => false, // Elimina el historial para evitar volver atrás
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon, required String title, required Function() onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF5B3E96)), // Color principal para los íconos
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
