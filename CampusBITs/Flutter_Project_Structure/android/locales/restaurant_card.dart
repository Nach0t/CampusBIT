// Placeholder for android/locales/restaurant_card.dart

// Archivo: lib/android/locales/restaurant_card.dart

import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos los restaurantes'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                    child: Image.asset(
                      'assets/AECafeteria.png', // Imagen de la carpeta assets
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alimento Express Cafeteria',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Comida Casera • €€',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star_border,
                              color: Colors.grey,
                              size: 20,
                            );
                          }),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(0)', // Puedes cambiar esto por la calificación real si está disponible
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF5B3E96),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '20% Dto.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
