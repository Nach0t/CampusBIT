import 'package:flutter/material.dart';
import 'DBHelper.dart';

class PointsScreen extends StatefulWidget {
  final String username;

  PointsScreen({required this.username});

  @override
  _PointsScreenState createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int totalPoints = 0;
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    try {
      int points = await dbHelper.getUserPoints(widget.username);
      if (mounted) {
        setState(() {
          totalPoints = points;
        });
      }
    } catch (e) {
      print("Error loading user points: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar puntos de usuario')),
      );
    }
  }

  Future<void> _redeemItem(String itemName, int cost) async {
    if (totalPoints >= cost) {
      try {
        await dbHelper.updateUserPoints(widget.username, totalPoints - cost);
        await dbHelper.recordRedemptionTransaction(widget.username, itemName, cost);
        if (mounted) {
          setState(() {
            totalPoints -= cost;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Has canjeado: $itemName')),
        );
      } catch (e) {
        print("Error redeeming item: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al canjear el artículo')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No tienes suficientes puntos para canjear este artículo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canjea tus Puntos'),
        backgroundColor: Color(0xFF5B3E96),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71679C), Color(0xFF44337A)],
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
                child: Text(
                  'Puntos Totales: $totalPoints',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Opciones de Canje:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildRedeemOption('Menú Ejecutivo', 1000),
              _buildRedeemOption('Menú Junaeb', 1500),
              _buildRedeemOption('Ticket de Compra por \$2000 CLP', 2000),
              _buildRedeemOption('Ticket de Compra por \$3000 CLP', 3000),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedeemOption(String itemName, int cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: totalPoints >= cost ? Colors.white : Colors.grey[600],
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: totalPoints >= cost ? Colors.black : Colors.white,
            ),
          ),
          subtitle: Text(
            'Costo: $cost puntos',
            style: TextStyle(
              color: totalPoints >= cost ? Colors.black87 : Colors.white70,
            ),
          ),
          trailing: totalPoints >= cost
              ? ElevatedButton(
                  onPressed: () => _redeemItem(itemName, cost),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B3E96),
                  ),
                  child: Text('Canjear', style: TextStyle(color: Colors.white)),
                )
              : Icon(
                  Icons.lock,
                  color: Colors.redAccent,
                ),
        ),
      ),
    );
  }
}
