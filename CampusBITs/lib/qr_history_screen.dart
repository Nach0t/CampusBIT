import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'data/db_helper.dart';

class QrHistoryScreen extends StatefulWidget {
  final String username; // Usuario actual

  const QrHistoryScreen({super.key, required this.username});

  @override
  State<QrHistoryScreen> createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {
  List<GeneratedQr> qrHistory = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQrHistory();
  }

  Future<void> _loadQrHistory() async {
    try {
      final db = await DBHelper.database;
      final data = await db.getQrCodesForUser(widget.username);
      if (!mounted) return;
      setState(() {
        qrHistory = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar el historial de QR: $e';
        isLoading = false;
      });
    }
  }

  // Nueva funcionalidad: Eliminar un QR del historial
  Future<void> _deleteQr(String qrId) async {
    try {
      final db = await DBHelper.database;
      await db.deleteQrCode(qrId);
      _loadQrHistory(); // Recargar historial después de eliminar
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al eliminar el QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de QR'),
        backgroundColor: const Color(0xFF5B3E96),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : qrHistory.isEmpty
          ? const Center(
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
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                'Menú: ${qrData.menuType}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Precio: \$${qrData.price}'),
                  Text('Punto de Retiro: ${qrData.pickupPoint}'),
                  Text(
                    'Validez: ${qrData.validity.toLocal()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para eliminar QR
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteQr(qrData.id);
                    },
                  ),
                  // Vista de QR
                  SizedBox(
                    width: 80,
                    child: QrImage(
                      data: qrData.id,
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
