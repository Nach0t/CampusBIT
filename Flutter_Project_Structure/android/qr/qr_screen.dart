// Placeholder for android/qr/qr_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  final Map<String, dynamic> qrData;

  QRScreen({required this.qrData});

  String formatValidity(DateTime validity) {
    return "${validity.day}/${validity.month}/${validity.year} ${validity.hour}:${validity.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del QR'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Detalles del QR',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Menú: ${qrData['menuType']}'),
            Text('Usuario: ${qrData['lol']}'), // `lol` como username
            Text('Punto de Retiro: ${qrData['pickupPoint']}'),
            Text('Validez: ${formatValidity(qrData['validity'])}'),
            Text('Precio: \$${qrData['price']}'),
            SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: qrData['id'], // UUID como dato del QR
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B3E96),
              ),
              child: Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
