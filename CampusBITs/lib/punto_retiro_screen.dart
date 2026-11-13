import 'package:flutter/material.dart';

import 'logic/checkout.dart';
import 'menu_screen.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';
import 'wait_time_utils.dart';

class PuntoRetiroScreen extends StatelessWidget {
  final String username;
  final String localName;

  const PuntoRetiroScreen({
    super.key,
    required this.username,
    required this.localName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Punto de Retiro')),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ContentWidth(
            maxWidth: 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // El retiro es siempre en la Cafetería; el local AE elegido
                // es donde se hace el pedido.
                const Text(
                  pickupPointName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pedido desde $localName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 16),
                // Logo del local: tamaño fijo para que se vea nítido (a lo
                // ancho de la pantalla se pixelaba).
                Center(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/AECafeteria.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // `const Row` no compila en Flutter 3.50 (assert de
                        // CrossAxisAlignment); los hijos sí son const.
                        // ignore: prefer_const_constructors
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.schedule,
                                color: AppColors.textoSecundario),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Tiempo de espera aproximado:',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          calcularTiempoEspera(localName),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.celesteOscuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuScreen(
                          username: username,
                          localName: localName,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Ver Productos'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
