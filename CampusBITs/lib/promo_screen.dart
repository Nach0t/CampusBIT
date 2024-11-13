import 'package:flutter/material.dart';

class PromoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promos de la Semana'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Promo desayuno'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Seleccionar'),
            ),
          ),
          ListTile(
            title: Text('Promo almuerzo'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text('Seleccionar'),
            ),
          ),
        ],
      ),
    );
  }
}
