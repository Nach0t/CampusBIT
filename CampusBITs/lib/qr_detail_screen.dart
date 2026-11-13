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
                    _buildDetailRow(
                        Icons.person_outline, 'Usuario', qr.username),
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
                      qr.price == 0
                          ? 'Canje con puntos'
                          : formatPrice(qr.price),
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
    // Etiqueta pequeña sobre el valor: se lee mejor que dos columnas y no
    // se parte en pantallas angostas (revisado en el emulador).
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.celesteOscuro),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textoSecundario,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
