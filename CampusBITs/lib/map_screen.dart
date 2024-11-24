import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final String username;

  MapScreen({required this.username});

  final List<Map<String, dynamic>> locations = [
    {
      'name': 'Cafetería',
      'position': Offset(75, 250),
      'waitTime': '10-15 minutos',
      'description': 'Lugar principal de alimentación en el campus.',
    },
    {
      'name': 'Hall',
      'position': Offset(180, 140),
      'waitTime': '5-10 minutos',
      'description': 'Zona central con acceso al auditorio.',
    },
    {
      'name': 'Auditorio',
      'position': Offset(230, 200),
      'waitTime': '5-8 minutos',
      'description': 'Espacio para eventos y conferencias.',
    },
    {
      'name': 'Estacionamiento',
      'position': Offset(300, 60),
      'waitTime': '2-5 minutos',
      'description': 'Estacionamiento amplio y seguro.',
    },
    {
      'name': 'Carpa',
      'position': Offset(350, 300),
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
              Image.asset(
                'assets/MapaUSS.png',
                width: MediaQuery.of(context).size.width, // Ajuste responsivo
                height: MediaQuery.of(context).size.height * 0.8,
                fit: BoxFit.contain, // Escala la imagen para mantener proporciones
              ),
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
                      color: Colors.red.withOpacity(0.8),
                      size: 30, // Tamaño del ícono
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
