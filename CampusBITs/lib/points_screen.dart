import 'package:flutter/material.dart';

class PointsScreen extends StatefulWidget {
  final String username;

  PointsScreen({required this.username});

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  /// Simulador para obtener los puntos de usuario
  Future<void> _loadUserPoints() async {
    // Simulación de carga de puntos del usuario (puedes reemplazarlo con tu lógica)
    await Future.delayed(Duration(milliseconds: 500)); // Simular retardo de carga
    setState(() {
      totalPoints = 1500; // Simular que el usuario tiene 1500 puntos
    });
  }

  /// Simulador para canjear un artículo
  Future<void> _redeemItem(String itemName, int cost) async {
    if (totalPoints >= cost) {
      // Restar los puntos al usuario
      setState(() {
        totalPoints -= cost;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Has canjeado: $itemName!', style: TextStyle(fontFamily: 'Exo2')),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Mostrar mensaje de error si no hay suficientes puntos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No tienes suficientes puntos para canjear este artículo',
            style: TextStyle(fontFamily: 'Exo2'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Canjea tus Puntos',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4682B4),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Puntos Totales: $totalPoints',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Opciones de Canje:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildRedeemOption('Menú Junaeb', 700),
              _buildRedeemOption('Menú Ejecutivo', 1200),
              _buildRedeemOption('Ticket de Compra por \$5000 CLP', 4500),
            ],
          ),
        ),
      ),
    );
  }

  /// Constructor de las opciones de canje
  Widget _buildRedeemOption(String itemName, int cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            itemName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            'Costo: $cost puntos',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: totalPoints >= cost
              ? ElevatedButton(
            onPressed: () => _redeemItem(itemName, cost),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF87CEEB),
            ),
            child: Text('Canjear', style: TextStyle(color: Colors.white)),
          )
              : Text(
            'No suficientes puntos',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
