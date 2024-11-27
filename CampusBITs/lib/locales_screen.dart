import 'package:flutter/material.dart';
import 'punto_retiro_screen.dart';
import 'wait_time_utils.dart'; // Importamos la lógica del tiempo de espera
import 'map_screen.dart'; // Importamos la pantalla del mapa

class LocalesScreen extends StatelessWidget {
  final String username;

  LocalesScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    // Lista de locales
    final locales = [
      {'name': 'Punto Casino', 'description': ''},
      {'name': 'Punto Verde Casino', 'description': ''},
      {'name': 'Punto Hall', 'description': ''},
      {'name': 'Punto Estacionamiento', 'description': ''},
      {'name': 'Punto Carpa', 'description': ''},
      {'name': 'Faculty', 'description': ''},
      {'name': 'Punto Domo', 'description': ''},
      {'name': 'Punto Hospital', 'description': ''},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locales',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
        centerTitle: true,
        elevation: 5.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(username: username),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4682B4),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Ir al Mapa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: locales.length,
                itemBuilder: (context, index) {
                  final local = locales[index];
                  return _buildLocalCard(
                    context,
                    local['name']!,
                    local['description']!,
                    username,
                    calcularTiempoEspera(local['name']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalCard(
      BuildContext context,
      String localName,
      String description,
      String username,
      String tiempoEspera,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuntoRetiroScreen(username: username, localName: localName),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4682B4),
                fontFamily: 'Exo2',
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.black, // Fondo negro detrás de la imagen
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // Borde redondeado para la imagen
                child: Image.asset(
                  'assets/AECafeteria.png', // Imagen fija o personalizada
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Tiempo de espera: $tiempoEspera',
              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
