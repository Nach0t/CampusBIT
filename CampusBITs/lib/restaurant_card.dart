import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todos los restaurantes',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF4682B4), // Celeste oscuro
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen destacada
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
              // Información del restaurante
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
                        fontFamily: 'Exo2',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Comida Casera • €€',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Exo2',
                      ),
                    ),
                    SizedBox(height: 8),
                    // Calificación
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star_border,
                              color: Color(0xFF4682B4), // Celeste oscuro para las estrellas
                              size: 20,
                            );
                          }),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(0)', // Calificación
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4682B4), // Celeste oscuro para el texto
                            fontFamily: 'Exo2',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Descuento
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF5F9EA0), // Verde azulado para el descuento
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '20% Dto.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Exo2',
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
