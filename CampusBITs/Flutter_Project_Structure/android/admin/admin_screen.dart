// Placeholder for android/admin/admin_screen.dart

import 'package:flutter/material.dart';
import '../edit/edit_prices_screen.dart'; // Ruta ajustada para tu estructura de carpetas

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Índice para el control del BottomNavigationBar
  int _currentIndex = 0;

  // Lista de pantallas para el BottomNavigationBar
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista de pantallas
    _screens = [
      EditPricesScreen(), // Pantalla de edición de precios
      // Agrega más pantallas aquí si es necesario en el futuro
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador'),
        backgroundColor: Color(0xFF5B3E96), // Color personalizado para el AppBar
      ),
      // Muestra la pantalla activa según el índice seleccionado
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Índice seleccionado
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Actualiza el índice al tocar una opción
          });
        },
        selectedItemColor: Color(0xFF5B3E96), // Color para el elemento seleccionado
        unselectedItemColor: Colors.grey, // Color para los elementos no seleccionados
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit), // Icono para la primera opción
            label: 'Editar Precios', // Etiqueta para la primera opción
          ),
          // Si agregas más pantallas, agrega más BottomNavigationBarItem aquí
        ],
      ),
    );
  }
}
