import 'package:flutter/material.dart';

import 'data/db_helper.dart';
import 'qr_detail_screen.dart';

/// Lista los códigos QR del usuario (pestaña "QR" e historial).
///
/// Esta pantalla solo lee y elimina: los códigos se crean al pagar o al
/// canjear puntos, una sola vez, dentro de la transacción de la compra.
class QrCodesScreen extends StatefulWidget {
  final String username;

  /// Códigos recién creados (se resaltan al llegar desde el carrito).
  final List<GeneratedQr> newCodes;

  /// Mensaje opcional que se muestra arriba de la lista.
  final String? message;

  const QrCodesScreen({
    super.key,
    required this.username,
    this.newCodes = const [],
    this.message,
  });

  @override
  State<QrCodesScreen> createState() => _QrCodesScreenState();
}

class _QrCodesScreenState extends State<QrCodesScreen> {
  List<GeneratedQr> _qrList = [];
  bool isLoading = true;
  String errorMessage = '';

  late final Set<String> _newIds = widget.newCodes.map((q) => q.id).toSet();

  @override
  void initState() {
    super.initState();
    _loadQrCodes();
  }

  Future<void> _loadQrCodes() async {
    try {
      final db = await DBHelper.database;
      final data = await db.getQrCodesForUser(widget.username);
      if (!mounted) return;
      setState(() {
        _qrList = data;
        errorMessage = '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error al cargar los QR: $e';
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

  Future<void> _confirmDelete(GeneratedQr qr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar código QR'),
        content: Text('¿Eliminar el QR de "${qr.menuType}"? '
            'No podrás usarlo para retirar el pedido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final db = await DBHelper.database;
      await db.deleteQrCode(qr.id);
      await _loadQrCodes(); // Solo recarga; no genera nada nuevo
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar QR: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis códigos QR',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB0E0E6), Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadQrCodes,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        if (widget.message != null) _buildMessage(),
                        if (_qrList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Text(
                              'No hay códigos QR disponibles.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Exo2',
                              ),
                            ),
                          ),
                        for (final qr in _qrList) _buildQrCard(qr),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildMessage() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green.shade600,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(GeneratedQr qr) {
    final isNew = _newIds.contains(qr.id);
    final expired = qr.isExpired;
    return GestureDetector(
      onTap: () => _showQrDetails(qr),
      onLongPress: () => _confirmDelete(qr),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white.withValues(alpha: isNew ? 0.3 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isNew
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
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
                      'Punto de Retiro: ${qr.pickupPoint}',
                      style: _detailStyle,
                    ),
                    Text(
                      qr.price == 0 ? 'Canje con puntos' : 'Precio: \$${qr.price}',
                      style: _detailStyle,
                    ),
                    Text(
                      expired
                          ? 'Vencido el ${_formatDate(qr.validity)}'
                          : 'Válido hasta: ${_formatDate(qr.validity)}',
                      style: _detailStyle.copyWith(
                        color: expired ? Colors.red.shade100 : Colors.white70,
                        fontWeight: expired ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.qr_code, color: Colors.white70, size: 32),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                onPressed: () => _confirmDelete(qr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _detailStyle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
    fontFamily: 'Exo2',
  );
}
