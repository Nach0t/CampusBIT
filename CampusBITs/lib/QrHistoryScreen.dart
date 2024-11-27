import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'DBHelper.dart';

class QrHistoryScreen extends StatefulWidget {
  final String username; // Usuario actual

  QrHistoryScreen({required this.username});

  @override
  _QrHistoryScreenState createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {
  List<Map<String, dynamic>> qrHistory = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQrHistory();
  }

  Future<void> _loadQrHistory() async {
    try {
      final dbHelper = DBHelper.instance;
      final data = await dbHelper.getQrForUser(widget.username);
      setState(() {
        qrHistory = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar el historial de QR: $e';
        isLoading = false;
      });
    }
  }

  // Nueva funcionalidad: Eliminar un QR del historial
  Future<void> _deleteQr(String qrId) async {
    try {
      final dbHelper = DBHelper.instance;
      await dbHelper.deleteQrById(qrId); // Asumiendo que este método existe en DBHelper
      _loadQrHistory(); // Recargar historial después de eliminar
    } catch (e) {
      setState(() {
        errorMessage = 'Error al eliminar el QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de QR'),
        backgroundColor: Color(0xFF5B3E96),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : qrHistory.isEmpty
          ? Center(
        child: Text(
          'No hay QR generados.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: qrHistory.length,
        itemBuilder: (context, index) {
          final qrData = qrHistory[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'Menú: ${qrData['menuType']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Precio: \$${qrData['price']}'),
                  Text('Punto de Retiro: ${qrData['pickupPoint']}'),
                  Text(
                    'Validez: ${DateTime.parse(qrData['validity']).toLocal()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para eliminar QR
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteQr(qrData['id']);
                    },
                  ),
                  // Vista de QR
                  SizedBox(
                    width: 80,
                    child: QrImage(
                      data: qrData['id'],
                      version: QrVersions.auto,
                      size: 50,
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
