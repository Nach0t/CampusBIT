import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDetailScreen extends StatelessWidget {
  final Map<String, dynamic> qrData;

  const QrDetailScreen({super.key, required this.qrData});

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
    // Validar los datos del QR antes de renderizar la pantalla
    if (qrData['menuType'] == null ||
        qrData['username'] == null ||
        qrData['pickupPoint'] == null ||
        qrData['validity'] == null ||
        qrData['price'] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del QR'),
          backgroundColor: const Color(0xFF87CEEB),
        ),
        body: const Center(
          child: Text(
            'Datos del QR incompletos o inválidos.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB), // Celeste agua
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)], // Fondo degradado
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Detalles del QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Menú', qrData['menuType']),
            _buildDetailRow('Usuario', qrData['username']),
            _buildDetailRow('Punto de Retiro', qrData['pickupPoint']),
            _buildDetailRow('Validez', formatValidity(qrData['validity'])),
            _buildDetailRow('Precio', "\$${qrData['price']}"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: QrImage(
                data: qrData['id'] ?? "QR no disponible",
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB), // Botón celeste agua
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Regresar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis, // Agrega puntos suspensivos si el texto es muy largo
            ),
          ),
        ],
      ),
    );
  }
}
