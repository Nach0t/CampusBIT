import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'punto_retiro_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';
import 'wait_time_utils.dart';

/// Locales donde se puede retirar un pedido.
const List<String> locales = [
  'Punto Casino',
  'Punto Verde Casino',
  'Punto Hall',
  'Punto Estacionamiento',
  'Punto Carpa',
  'Faculty',
  'Punto Domo',
  'Punto Hospital',
];

class LocalesScreen extends StatelessWidget {
  final String username;

  const LocalesScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Locales')),
      body: AppBackground(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(username: username),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ir al Mapa'),
              ),
              const SizedBox(height: 8),
              const SectionTitle('Elige dónde retirar tu pedido'),
              for (final local in locales)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LocalCard(username: username, localName: local),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalCard extends StatelessWidget {
  final String username;
  final String localName;

  const _LocalCard({required this.username, required this.localName});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PuntoRetiroScreen(username: username, localName: localName),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/AECafeteria.png',
              height: 160,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.celesteOscuro,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 18, color: AppColors.textoSecundario),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Tiempo de espera: '
                                '${calcularTiempoEspera(localName)}',
                                style: const TextStyle(
                                    color: AppColors.textoSecundario),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.celesteOscuro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
