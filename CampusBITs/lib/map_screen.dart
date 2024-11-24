import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final String username;

  MapScreen({required this.username});

  // Lista de ubicaciones con posiciones exactas ajustadas para centrar los puntos
  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Cafetería',
      'position': Offset(75, 250), // Coordenadas ajustadas
      'waitTime': '10-15 minutos',
      'description': 'Lugar principal de alimentación en el campus.',
    },
    {
      'name': 'Hall',
      'position': Offset(180, 140), // Coordenadas ajustadas
      'waitTime': '5-10 minutos',
      'description': 'Zona central con acceso al auditorio.',
    },
    {
      'name': 'Auditorio',
      'position': Offset(230, 200), // Coordenadas ajustadas
      'waitTime': '5-8 minutos',
      'description': 'Espacio para eventos y conferencias.',
    },
    {
      'name': 'Estacionamiento',
      'position': Offset(300, 60), // Coordenadas ajustadas
      'waitTime': '2-5 minutos',
      'description': 'Estacionamiento amplio y seguro.',
    },
    {
      'name': 'Carpa',
      'position': Offset(350, 300), // Coordenadas ajustadas
      'waitTime': '15-20 minutos',
      'description': 'Espacio para reuniones temporales.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Locales'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Imagen de fondo (mapa del campus)
              Image.asset(
                'assets/MapaUSS.png',
                width: 400, // Ancho ajustado para mostrar toda la imagen
                height: 500, // Altura ajustada para mostrar toda la imagen
                fit: BoxFit.fill, // Asegura que la imagen ocupe el contenedor
              ),
              // Agregar puntos interactivos basados en las posiciones de la lista
              ...locations.map((location) {
                return Positioned(
                  left: location['position'].dx,
                  top: location['position'].dy,
                  child: GestureDetector(
                    onTap: () {
                      _showLocationInfo(context, location);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      color: Colors.transparent, // Contenedor invisible
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Muestra la información del local en un cuadro de diálogo
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
                'Tiempo de espera:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(location['waitTime'] ?? 'No disponible'),
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
