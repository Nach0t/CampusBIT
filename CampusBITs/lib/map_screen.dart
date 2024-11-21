import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final String username;

  MapScreen({required this.username});

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Cafeteria',
      'position': Offset(100, 200),
      'waitTime': '10-20 minutos',
      'rating': 4.5,
    },
    {
      'name': 'Hall',
      'position': Offset(200, 300),
      'waitTime': '15-25 minutos',
      'rating': 4.2,
    },
    {
      'name': 'Estacionamiento',
      'position': Offset(300, 400),
      'waitTime': '5-10 minutos',
      'rating': 4.0,
    },
    {
      'name': 'Carpa',
      'position': Offset(400, 500),
      'waitTime': '20-30 minutos',
      'rating': 3.8,
    },
    {
      'name': 'Sala de funcionarios',
      'position': Offset(500, 600),
      'waitTime': '25-35 minutos',
      'rating': 4.1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Locales'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Stack(
        children: [
          // Fondo del mapa
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/map_image.png'), // Cambia a tu imagen del mapa
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Puntos interactivos
          ...locations.map((location) {
            return Positioned(
              left: location['position'].dx,
              top: location['position'].dy,
              child: GestureDetector(
                onTap: () {
                  _showLocationInfo(context, location);
                },
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showLocationInfo(BuildContext context, Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(location['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tiempo de demora: ${location['waitTime']}'),
              Text('Valoración: ${location['rating']} estrellas'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
