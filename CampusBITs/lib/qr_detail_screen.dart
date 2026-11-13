import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'data/models.dart';
import 'ui/app_theme.dart';
import 'ui/widgets.dart';

class QrDetailScreen extends StatelessWidget {
  final GeneratedQr qr;

  const QrDetailScreen({super.key, required this.qr});

  @override
  Widget build(BuildContext context) {
    final expired = qr.isExpired;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del QR')),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ContentWidth(
            maxWidth: 480,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      qr.menuType,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expired
                          ? 'Este código está vencido'
                          : 'Muestra este código al retirar tu pedido',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: expired
                            ? AppColors.error
                            : AppColors.textoSecundario,
                        fontWeight: expired ? FontWeight.bold : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Opacity(
                        opacity: expired ? 0.4 : 1,
                        child: QrImage(
                          data: qr.id,
                          version: QrVersions.auto,
                          size: 240,
                          backgroundColor: Colors.white,
                          semanticsLabel: 'Código QR de ${qr.menuType}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _buildDetailRow(Icons.person_outline, 'Usuario', qr.username),
                    _buildDetailRow(
                        Icons.storefront, 'Punto de Retiro', qr.pickupPoint),
                    _buildDetailRow(
                      Icons.schedule,
                      'Validez',
                      formatDateTime(qr.validity),
                    ),
                    _buildDetailRow(
                      Icons.payments_outlined,
                      'Precio',
                      qr.price == 0 ? 'Canje con puntos' : formatPrice(qr.price),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Regresar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.celesteOscuro),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}
