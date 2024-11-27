import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'QrDetailScreen.dart';
import 'QrHistoryScreen.dart';
import 'DBHelper.dart';
import 'package:uuid/uuid.dart';

class GenerateQRCodeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> purchasedItems;
  final String lol; // Nombre de usuario
  final String pickupPoint; // Punto de retiro

  GenerateQRCodeScreen({
    required this.purchasedItems,
    required this.lol,
    required this.pickupPoint,
  });

  @override
  _GenerateQRCodeScreenState createState() => _GenerateQRCodeScreenState();
}

class _GenerateQRCodeScreenState extends State<GenerateQRCodeScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _qrList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateAndLoadQrData();
  }

  Future<void> _generateAndLoadQrData() async {
    final uuid = Uuid();
    try {
      if (widget.purchasedItems.isNotEmpty) {
        for (var item in widget.purchasedItems) {
          final qrData = {
            'id': uuid.v4(),
            'menuType': item['name'] ?? 'Sin nombre',
            'price': item['price'] ?? 0,
            'username': widget.lol,
            'pickupPoint': widget.pickupPoint,
            'validity': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
          };

          await _dbHelper.insertGeneratedQr(qrData);
        }
      }

      final data = await _dbHelper.getQrForUser(widget.lol);
      setState(() {
        _qrList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al generar los QR: $e';
        isLoading = false;
      });
    }
  }

  void _showQrDetails(Map<String, dynamic> qrData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrDetailScreen(qrData: qrData),
      ),
    );
  }

  // Nueva funcionalidad para eliminar QR generado
  Future<void> _deleteQr(String qrId) async {
    try {
      await _dbHelper.deleteQrById(qrId); // Se asume que el DBHelper tiene esta funcionalidad
      _generateAndLoadQrData(); // Refresca la lista después de eliminar
    } catch (e) {
      setState(() {
        errorMessage = 'Error al eliminar QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generar QR',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4682B4),
        elevation: 5.0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _qrList.isEmpty
            ? Center(
          child: Text(
            'No hay códigos QR disponibles.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Exo2',
            ),
          ),
        )
            : ListView.builder(
          itemCount: _qrList.length,
          itemBuilder: (context, index) {
            final qr = _qrList[index];
            return GestureDetector(
              onLongPress: () => _deleteQr(qr['id']), // Permite eliminar QR con presión larga
              onTap: () => _showQrDetails(qr),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menú: ${qr['menuType']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Usuario: ${qr['username']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      Text(
                        'Punto de Retiro: ${qr['pickupPoint']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      Text(
                        'Validez hasta: ${DateTime.parse(qr['validity']).toLocal()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.qr_code,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
