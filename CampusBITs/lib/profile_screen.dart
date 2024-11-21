import 'package:flutter/material.dart';
import 'login_screen.dart'; // Asegúrate de importar la pantalla de login correctamente

class ProfileScreen extends StatelessWidget {
  final String username;

  ProfileScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuario'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              username,
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Métodos de Pago'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial de Pedidos'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuraciones'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () {
              // Navegar a la pantalla de login
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
}
