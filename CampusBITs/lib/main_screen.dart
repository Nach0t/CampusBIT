import 'package:flutter/material.dart';
import 'locales_screen.dart';
import 'points_screen.dart';
import 'generate_qr_code_screen.dart'; // Cambio para manejar generación QR
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;

  MainScreen({required this.username});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      LocalesScreen(username: widget.username),
      PointsScreen(username: widget.username),
      GenerateQRCodeScreen(
        purchasedItems: [], // Lista vacía al inicio
        lol: widget.username, // lol como username
        pickupPoint: 'Cafeteria',
      ),
      ProfileScreen(username: widget.username),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF4682B4), // **Celeste oscuro** seleccionado
        unselectedItemColor: Colors.grey, // **Gris** para no seleccionados
        backgroundColor: Color(0xFFB0E0E6), // **Celeste agua** para el fondo de la barra
        type: BottomNavigationBarType.fixed, // Mantener el diseño fijo
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Locales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Puntos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuario',
          ),
        ],
      ),
    );
  }
}
