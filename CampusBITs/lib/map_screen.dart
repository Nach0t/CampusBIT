import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final String username;

  MapScreen({required this.username});

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Cafeteria',
      'position': Offset(120, 300), // Ajusta estas coordenadas
      'waitTime': '10-20 minutos',
      'rating': 4.5,
      'description': 'Un lugar ideal para desayunar o almorzar.',
    },
    {
      'name': 'Hall',
      'position': Offset(180, 150), // Ajusta estas coordenadas
      'waitTime': '15-25 minutos',
      'rating': 4.2,
      'description': 'Zona central con acceso a múltiples servicios.',
    },
    {
      'name': 'Estacionamiento',
      'position': Offset(300, 80), // Ajusta estas coordenadas
      'waitTime': '5-10 minutos',
      'rating': 4.0,
      'description': 'Área de estacionamiento amplia y segura.',
    },
    {
      'name': 'Carpa',
      'position': Offset(400, 400), // Ajusta estas coordenadas
      'waitTime': '20-30 minutos',
      'rating': 3.8,
      'description': 'Espacio temporal para eventos y reuniones.',
    },
    {
      'name': 'Sala de funcionarios',
      'position': Offset(450, 350), // Ajusta estas coordenadas
      'waitTime': '25-35 minutos',
      'rating': 4.1,
      'description': 'Oficinas administrativas del campus.',
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
                image: AssetImage('assets/MapaUSS.png'), // Cambia a tu imagen del mapa
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(location['description'] ?? 'No disponible'),
              SizedBox(height: 10),
              Text(
                'Tiempo de demora:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(location['waitTime'] ?? 'No disponible'),
              SizedBox(height: 10),
              Text(
                'Valoración:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${location['rating']} estrellas'),
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
