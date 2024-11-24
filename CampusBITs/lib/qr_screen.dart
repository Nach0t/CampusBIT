import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Lista global para almacenar los QR generados y comprados
List<Map<String, dynamic>> qrHubList = [];

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
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Menú: ${qrData['menuType']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Usuario: ${qrData['lol']}'),
                Text('Punto de Retiro: ${qrData['pickupPoint']}'),
                Text('Validez hasta: ${formatValidity(qrData['validity'])}'),
                SizedBox(height: 16),
                Center(
                  child: QrImageView(
                    data: qrData['id'], // UUID único como dato del QR
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B3E96),
                  ),
                  child: Text('Regresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
