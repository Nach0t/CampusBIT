import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'qr_screen.dart';

class GenerateQRCodeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> purchasedItems;
  final String lol;
  final String pickupPoint;

  GenerateQRCodeScreen({
    required this.purchasedItems,
    required this.lol,
    required this.pickupPoint,
  });

  @override
  _GenerateQRCodeScreenState createState() => _GenerateQRCodeScreenState();
}

class _GenerateQRCodeScreenState extends State<GenerateQRCodeScreen> {
  @override
  void initState() {
    super.initState();
    _generateQRList();
  }

  void _generateQRList() {
    final uuid = Uuid();
    for (var item in widget.purchasedItems) {
      final qr = {
        'id': uuid.v4(),
        'menuType': item['name'],
        'price': item['price'],
        'lol': widget.lol,
        'pickupPoint': widget.pickupPoint,
        'validity': DateTime.now().add(Duration(hours: 24)),
      };
      qrHubList.add(qr); // Agregar el QR generado al hub global
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar QR'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: qrHubList.isEmpty
          ? Center(
        child: Text(
          'No se han generado QR aún.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: qrHubList.length,
        itemBuilder: (context, index) {
          final qr = qrHubList[index];
          return Card(
            margin: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListTile(
              title: Text('Menú: ${qr['menuType']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuario: ${qr['lol']}'),
                  Text('Punto de Retiro: ${qr['pickupPoint']}'),
                  Text('Validez hasta: ${qr['validity']}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.qr_code),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScreen(qrData: qr),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
