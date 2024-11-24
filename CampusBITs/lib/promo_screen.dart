import 'package:flutter/material.dart';

class PromoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Promos de la Semana',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.w500,
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promoción Semanal:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo2',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              _buildPromoCard(
                context,
                'Promo desayuno',
                1800,
                'assets/desayuno.png',
              ),
              SizedBox(height: 16),
              _buildPromoCard(
                context,
                'Promo almuerzo',
                2500,
                'assets/almuerzo.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context, String title, int price, String imagePath) {
    return Card(
      elevation: 3,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Image.asset(
          imagePath,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          '$title - \$${price}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Exo2',
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Seleccionaste: $title')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF71679C),
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text('Seleccionar', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
