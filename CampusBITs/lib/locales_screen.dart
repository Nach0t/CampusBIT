import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'punto_retiro_screen.dart';

class LocalesScreen extends StatelessWidget {
  final String username;

  LocalesScreen({required this.username});

  String calcularTiempoEspera(String localName) {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (localName == 'Cafeteria') {
      if (hour >= 13 && hour < 14) return '20-30 minutos';
      if (hour >= 12 && hour < 13) return '10-20 minutos';
      if (hour >= 11 && hour < 12) return '5-10 minutos';
      return '30-45 minutos o más';
    } else if (localName == 'Hall') {
      return '10-15 minutos';
    } else if (localName == 'Estacionamiento') {
      return '5-10 minutos';
    } else if (localName == 'Carpa') {
      return '25-35 minutos';
    } else if (localName == 'Sala de funcionarios') {
      return '15-25 minutos';
    }
    return '30-45 minutos o más';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locales',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5B3E96),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71679C), Color(0xFF44337A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(username: username),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Mapa Locales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B3E96),
                    ),
                  ),
                ),
              ),
            ),
            _buildLocalCard(
              context,
              'Cafeteria',
              'Cafetería principal del campus.',
              username,
              calcularTiempoEspera('Cafeteria'),
              'assets/AECafeteria.png',
            ),
            _buildLocalCard(
              context,
              'Hall',
              'Sala de espera central.',
              username,
              calcularTiempoEspera('Hall'),
              'assets/Hall.png',
            ),
            _buildLocalCard(
              context,
              'Estacionamiento',
              'Zona de estacionamiento segura.',
              username,
              calcularTiempoEspera('Estacionamiento'),
              'assets/Estacionamiento.png',
            ),
            _buildLocalCard(
              context,
              'Carpa',
              'Área exterior techada.',
              username,
              calcularTiempoEspera('Carpa'),
              'assets/Carpa.png',
            ),
            _buildLocalCard(
              context,
              'Sala de funcionarios',
              'Sala privada para reuniones administrativas.',
              username,
              calcularTiempoEspera('Sala de funcionarios'),
              'assets/SalaFuncionarios.png',
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
    String imagePath,
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
          color: Colors.white,
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5B3E96)),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              'Tiempo de espera: $tiempoEspera',
              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: Colors.grey,
                      size: 20,
                    );
                  }),
                ),
                SizedBox(width: 8),
                Text(
                  '(0)', // Cambia esto si tienes calificaciones reales
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
