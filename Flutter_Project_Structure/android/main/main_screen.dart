// Placeholder for android/main/main_screen.dart

// Archivo: lib/android/main/main_screen.dart

import 'package:flutter/material.dart';
import '../locales/locales_screen.dart';
import '../points/points_screen.dart';
import '../qr/generate_qr_code_screen.dart';
import '../user/profile_screen.dart';

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
        selectedItemColor: Color(0xFF20B2AA), // Celeste agua seleccionado
        unselectedItemColor: Colors.grey, // Gris para no seleccionados
        backgroundColor: Color(0xFF66CDAA), // Fondo de la barra de navegación
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
