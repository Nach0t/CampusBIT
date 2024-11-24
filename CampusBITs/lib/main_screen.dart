import 'package:flutter/material.dart';
import 'locales_screen.dart';
import 'points_screen.dart';
import 'generate_qr_code_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;

  MainScreen({required this.username});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      LocalesScreen(username: widget.username),
      PointsScreen(username: widget.username),
      GenerateQRCodeScreen(
        purchasedItems: [],
        lol: widget.username,
        pickupPoint: 'Cafeteria',
      ),
      ProfileScreen(username: widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF20B2AA),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF66CDAA),
        type: BottomNavigationBarType.fixed,
        items: const [
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
