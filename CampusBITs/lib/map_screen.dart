import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  final String username;

  MapScreen({required this.username});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Lista de ubicaciones con sus detalles
  final List<Map<String, String>> locations = [
    {'name': 'Punto Casino', 'image': 'assets/MapaCacino.png'},
    {'name': 'Punto Carpa', 'image': 'assets/MapaCarpa.png'},
    {'name': 'Punto Domo', 'image': 'assets/MapaDomo.png'},
    {'name': 'Punto Estacionamiento', 'image': 'assets/MapaEstacionamiento.png'},
    {'name': 'Faculty', 'image': 'assets/MapaFuncionarios.png'},
    {'name': 'Punto Hall', 'image': 'assets/MapaHall.png'},
    {'name': 'Punto Hospital', 'image': 'assets/MapaHospital.png'},
  ];

  String? selectedLocation; // Variable para el filtro de búsqueda

  @override
  Widget build(BuildContext context) {
    // Filtrar ubicación seleccionada
    final filteredLocations = selectedLocation == null
        ? locations
        : locations.where((loc) => loc['name'] == selectedLocation).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de AE',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF4682B4), // Fondo celeste
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Gradiente de fondo celeste
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Filtro de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedLocation,
                hint: Text(
                  'Selecciona una ubicación',
                  style: TextStyle(fontSize: 18),
                ),
                items: locations
                    .map((loc) => DropdownMenuItem<String>(
                  value: loc['name'],
                  child: Text(loc['name']!),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                isExpanded: true,
              ),
            ),
            // Mostrar mapa correspondiente
            Expanded(
              child: filteredLocations.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final loc = filteredLocations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 12.0), // Más espacio interno
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc['name']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4682B4),
                              ),
                            ),
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0), // Bordes redondeados de la imagen
                              child: Image.asset(
                                loc['image']!,
                                width: MediaQuery.of(context).size.width * 0.75, // Imagen más pequeña
                                fit: BoxFit.contain, // Ajustar sin recortar
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'No se encontró la ubicación seleccionada.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
