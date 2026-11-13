import 'package:flutter/material.dart';
import 'qr_detail_screen.dart';
import 'data/db_helper.dart';
import 'package:uuid/uuid.dart';

class GenerateQRCodeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> purchasedItems;
  final String username; // Nombre de usuario
  final String pickupPoint; // Punto de retiro

  const GenerateQRCodeScreen({super.key, 
    required this.purchasedItems,
    required this.username,
    required this.pickupPoint,
  });

  @override
  State<GenerateQRCodeScreen> createState() => _GenerateQRCodeScreenState();
}

class _GenerateQRCodeScreenState extends State<GenerateQRCodeScreen> {
  List<GeneratedQr> _qrList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateAndLoadQrData();
  }

  Future<void> _generateAndLoadQrData() async {
    const uuid = Uuid();
    try {
      final db = await DBHelper.database;
      if (widget.purchasedItems.isNotEmpty) {
        final validity = DateTime.now().add(const Duration(hours: 24));
        await db.insertQrCodes([
          for (final item in widget.purchasedItems)
            GeneratedQr(
              id: uuid.v4(),
              menuType: item['name'] ?? 'Sin nombre',
              price: item['price'] ?? 0,
              username: widget.username,
              pickupPoint: widget.pickupPoint,
              validity: validity,
            ),
        ]);
      }

      final data = await db.getQrCodesForUser(widget.username);
      if (!mounted) return;
      setState(() {
        _qrList = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al generar los QR: $e';
        isLoading = false;
      });
    }
  }

  void _showQrDetails(GeneratedQr qr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrDetailScreen(qr: qr),
      ),
    );
  }

  // Nueva funcionalidad para eliminar QR generado
  Future<void> _deleteQr(String qrId) async {
    try {
      final db = await DBHelper.database;
      await db.deleteQrCode(qrId);
      _generateAndLoadQrData(); // Refresca la lista después de eliminar
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al eliminar QR: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generar QR',
          style: TextStyle(
            fontFamily: 'Exo2',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4682B4),
        elevation: 5.0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _qrList.isEmpty
            ? const Center(
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
              onLongPress: () => _deleteQr(qr.id), // Permite eliminar QR con presión larga
              onTap: () => _showQrDetails(qr),
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menú: ${qr.menuType}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usuario: ${qr.username}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      Text(
                        'Punto de Retiro: ${qr.pickupPoint}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      Text(
                        'Validez hasta: ${qr.validity.toLocal()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Exo2',
                        ),
                      ),
                      const Align(
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
