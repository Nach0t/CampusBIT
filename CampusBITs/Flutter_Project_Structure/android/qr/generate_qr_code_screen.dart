// Placeholder for android/qr/generate_qr_code_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class GenerateQRCodeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> purchasedItems;
  final String lol;
  final String pickupPoint;

  GenerateQRCodeScreen({
    required this.purchasedItems,
    required this.lol,
    required this.pickupPoint,
  });

  @override
  Widget build(BuildContext context) {
    final uuid = Uuid();
    final qrList = purchasedItems.map((item) {
      return {
        'id': uuid.v4(),
        'menuType': item['name'],
        'price': item['price'],
        'username': lol,
        'pickupPoint': pickupPoint,
        'validity': DateTime.now().add(Duration(hours: 24)),
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Generar QR'),
        backgroundColor: Color(0xFF20B2AA), // Celeste agua
      ),
      body: ListView.builder(
        itemCount: qrList.length,
        itemBuilder: (context, index) {
          final qr = qrList[index];
          return Card(
            margin: EdgeInsets.all(16.0),
            child: ListTile(
              title: Text('Menú: ${qr['menuType']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${qr['username']}'),
                  Text('Punto de Retiro: ${qr['pickupPoint']}'),
                  Text('Validez hasta: ${qr['validity']}'),
                  SizedBox(height: 10),
                  Center(
                    child: QrImageView(
                      data: qr['id'], // UUID como dato del QR
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
