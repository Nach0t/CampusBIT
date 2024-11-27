import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDetailScreen extends StatelessWidget {
  final Map<String, dynamic> qrData;

  QrDetailScreen({required this.qrData});

  String formatValidity(String validity) {
    try {
      final dateTime = DateTime.parse(validity);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "Fecha no válida";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar que los datos del QR sean válidos
    if (qrData['menuType'] == null ||
        qrData['username'] == null ||
        qrData['pickupPoint'] == null ||
        qrData['validity'] == null ||
        qrData['price'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalles del QR'),
          backgroundColor: Color(0xFF87CEEB),
        ),
        body: Center(
          child: Text(
            'Datos del QR incompletos o inválidos.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del QR'),
        backgroundColor: Color(0xFF4682B4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menú: ${qrData['menuType']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Usuario: ${qrData['username']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Punto de Retiro: ${qrData['pickupPoint']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Validez: ${formatValidity(qrData['validity'])}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Center(
              child: QrImage(
                data: qrData['id'], // El dato a codificar en el QR
                version: QrVersions.auto, // Selección automática de la versión
                size: 200.0, // Tamaño del QR
                backgroundColor: Colors.white, // Fondo blanco para el QR
              ),
            ),
          ],
        ),
      ),
    );
  }
}
