import 'package:flutter/material.dart';

import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class MapScreen extends StatefulWidget {
  final String username;

  const MapScreen({super.key, required this.username});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Lista de ubicaciones con sus planos
  static const List<({String name, String image})> locations = [
    (name: 'Punto Casino', image: 'assets/MapaCacino.png'),
    (name: 'Punto Carpa', image: 'assets/MapaCarpa.png'),
    (name: 'Punto Domo', image: 'assets/MapaDomo.png'),
    (name: 'Punto Estacionamiento', image: 'assets/MapaEstacionamiento.png'),
    (name: 'Faculty', image: 'assets/MapaFuncionarios.png'),
    (name: 'Punto Hall', image: 'assets/MapaHall.png'),
    (name: 'Punto Hospital', image: 'assets/MapaHospital.png'),
  ];

  /// `null` = mostrar todas las ubicaciones.
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final filtered = selectedLocation == null
        ? locations
        : locations.where((loc) => loc.name == selectedLocation).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de AE')),
      body: AppBackground(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String?>(
                initialValue: selectedLocation,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                items: [
                  // Antes no había forma de volver a ver todos los mapas.
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas las ubicaciones'),
                  ),
                  for (final loc in locations)
                    DropdownMenuItem<String?>(
                      value: loc.name,
                      child: Text(loc.name),
                    ),
                ],
                onChanged: (value) => setState(() => selectedLocation = value),
              ),
              const SizedBox(height: 16),
              for (final loc in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.celesteOscuro,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              loc.image,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              semanticLabel: 'Mapa de ${loc.name}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
